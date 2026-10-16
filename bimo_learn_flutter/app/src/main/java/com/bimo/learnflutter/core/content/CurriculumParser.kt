package com.bimo.learnflutter.core.content

class CurriculumFormatException(message: String) : IllegalArgumentException(message)

/**
 * Parser for the `.bimo` curriculum format. The format is documented in
 * `assets/curriculum/FORMAT.md` and in the README. It is deliberately plain text so
 * educators can edit lessons without touching Kotlin.
 *
 * This class is pure Kotlin (no Android dependencies) so it can be unit tested on the JVM.
 */
object CurriculumParser {

    data class CourseManifest(
        val id: String,
        val title: String,
        val subtitle: String,
        val description: String,
        val level: String,
        val accentHex: String,
        val icon: String,
        val order: Int,
        val requiresModuleId: String?,
        val isProjectCourse: Boolean,
    )

    fun parseCourseManifest(text: String, source: String = "course.bimo"): CourseManifest {
        val values = mutableMapOf<String, String>()
        text.lines().forEachIndexed { index, raw ->
            val line = raw.trim()
            if (line.isEmpty() || line.startsWith("#")) return@forEachIndexed
            val colon = line.indexOf(':')
            if (colon <= 0) throw CurriculumFormatException("$source:${index + 1}: expected 'key: value'")
            values[line.substring(0, colon).trim().lowercase()] = line.substring(colon + 1).trim()
        }
        fun req(key: String) = values[key]?.takeIf { it.isNotBlank() }
            ?: throw CurriculumFormatException("$source: missing '$key'")
        return CourseManifest(
            id = req("id"),
            title = req("title"),
            subtitle = req("subtitle"),
            description = req("description"),
            level = req("level"),
            accentHex = values["accent"] ?: "#6750F5",
            icon = values["icon"] ?: "book",
            order = values["order"]?.toIntOrNull() ?: 0,
            requiresModuleId = values["requires"]?.takeIf { it.isNotBlank() },
            isProjectCourse = values["projects"]?.toBoolean() ?: false,
        )
    }

    fun buildCourse(manifest: CourseManifest, moduleFiles: List<Pair<String, String>>): Course {
        val modules = moduleFiles
            .sortedBy { it.first }
            .mapIndexed { index, (name, text) ->
                parseModule(manifest.id, index + 1, text, name, manifest.isProjectCourse)
            }
        return Course(
            id = manifest.id,
            title = manifest.title,
            subtitle = manifest.subtitle,
            description = manifest.description,
            level = manifest.level,
            accentHex = manifest.accentHex,
            icon = manifest.icon,
            order = manifest.order,
            requiresModuleId = manifest.requiresModuleId,
            isProjectCourse = manifest.isProjectCourse,
            modules = modules,
        )
    }

    fun parseModule(
        courseId: String,
        number: Int,
        text: String,
        source: String,
        isProject: Boolean = false,
    ): Module {
        val lines = text.replace("\r\n", "\n").lines()
        var moduleId: String? = null
        var moduleTitle: String? = null
        var summary = ""
        val lessons = mutableListOf<Lesson>()

        var i = 0
        // Header
        while (i < lines.size && !lines[i].startsWith("@lesson ")) {
            val line = lines[i].trim()
            when {
                line.startsWith("@module ") -> {
                    val parts = line.removePrefix("@module ").split("|").map { it.trim() }
                    if (parts.size < 2) throw CurriculumFormatException("$source:${i + 1}: '@module id | title' expected")
                    moduleId = parts[0]
                    moduleTitle = parts[1]
                }
                line.startsWith("@summary ") -> summary = line.removePrefix("@summary ").trim()
                line.isEmpty() || line.startsWith("//") -> Unit
                else -> throw CurriculumFormatException("$source:${i + 1}: unexpected text before first lesson")
            }
            i++
        }
        val mId = moduleId ?: throw CurriculumFormatException("$source: missing @module header")

        while (i < lines.size) {
            val header = lines[i]
            if (!header.startsWith("@lesson ")) throw CurriculumFormatException("$source:${i + 1}: '@lesson' expected")
            val parts = header.removePrefix("@lesson ").split("|").map { it.trim() }
            if (parts.size < 2) throw CurriculumFormatException("$source:${i + 1}: '@lesson id | title | minutes' expected")
            val lessonId = parts[0]
            val title = parts[1]
            val minutes = parts.getOrNull(2)?.toIntOrNull() ?: 10
            i++

            val bodyStart = i
            var inFence = false
            while (i < lines.size) {
                val l = lines[i]
                if (l.trimStart().startsWith("```")) inFence = !inFence
                if (!inFence && (l.trim() == "@quiz" || l.startsWith("@lesson "))) break
                i++
            }
            val body = lines.subList(bodyStart, i)
            if (i >= lines.size || lines[i].trim() != "@quiz") {
                throw CurriculumFormatException("$source: lesson '$lessonId' has no @quiz section")
            }
            i++ // skip @quiz
            val quizStart = i
            inFence = false
            while (i < lines.size) {
                val l = lines[i]
                if (l.trimStart().startsWith("```")) inFence = !inFence
                if (!inFence && l.startsWith("@lesson ")) break
                i++
            }
            val quizLines = lines.subList(quizStart, i)
            val blocks = parseBlocks(body, "$source/$lessonId")
            if (blocks.isEmpty()) throw CurriculumFormatException("$source: lesson '$lessonId' has no content")
            val questions = parseQuestions(quizLines, lessonId, "$source/$lessonId")
            lessons += Lesson(
                id = lessonId,
                courseId = courseId,
                moduleId = mId,
                title = title,
                minutes = minutes,
                blocks = blocks,
                quiz = Quiz(id = "quiz-$lessonId", questions = questions),
                isProject = isProject,
            )
        }
        if (lessons.isEmpty()) throw CurriculumFormatException("$source: module has no lessons")
        return Module(
            id = mId,
            courseId = courseId,
            number = number,
            title = moduleTitle ?: mId,
            summary = summary,
            lessons = lessons,
        )
    }

    /** Parses a standalone assessment file that starts with `@exam id | title`. */
    fun parseExam(text: String, source: String): Quiz {
        val lines = text.replace("\r\n", "\n").lines()
        val headerIndex = lines.indexOfFirst { it.startsWith("@exam ") }
        if (headerIndex < 0) throw CurriculumFormatException("$source: missing @exam header")
        val id = lines[headerIndex].removePrefix("@exam ").split("|").first().trim()
        val questions = parseQuestions(lines.drop(headerIndex + 1), id, source)
        return Quiz(id = id, questions = questions)
    }

    /**
     * Parses `challenges.bimo`: a list of `@challenge id | title | difficulty | premium` sections,
     * each followed by Markdown-like content (usually including a `:::solution` block).
     */
    fun parseChallenges(text: String, source: String = "challenges.bimo"): List<Challenge> {
        val lines = text.replace("\r\n", "\n").lines()
        val result = mutableListOf<Challenge>()
        var i = 0
        while (i < lines.size && !lines[i].startsWith("@challenge ")) i++
        while (i < lines.size) {
            val parts = lines[i].removePrefix("@challenge ").split("|").map { it.trim() }
            if (parts.size < 3) throw CurriculumFormatException("$source:${i + 1}: '@challenge id | title | difficulty | premium' expected")
            i++
            val start = i
            var fence = false
            while (i < lines.size) {
                if (lines[i].trimStart().startsWith("```")) fence = !fence
                if (!fence && lines[i].startsWith("@challenge ")) break
                i++
            }
            val blocks = parseBlocks(lines.subList(start, i), "$source/${parts[0]}")
            if (blocks.isEmpty()) throw CurriculumFormatException("$source: challenge '${parts[0]}' has no content")
            result += Challenge(parts[0], parts[1], parts[2], parts.getOrNull(3)?.toBoolean() ?: false, blocks)
        }
        return result
    }

    // ---------------------------------------------------------------- blocks

    fun parseBlocks(lines: List<String>, source: String = "content"): List<ContentBlock> {
        val blocks = mutableListOf<ContentBlock>()
        val paragraph = StringBuilder()
        var listItems = mutableListOf<String>()
        var listOrdered = false
        var calloutKind: CalloutKind? = null
        val callout = StringBuilder()

        fun flushParagraph() {
            if (paragraph.isNotBlank()) blocks += ContentBlock.Paragraph(paragraph.toString().trim())
            paragraph.clear()
        }
        fun flushList() {
            if (listItems.isNotEmpty()) blocks += ContentBlock.ListBlock(listItems.toList(), listOrdered)
            listItems = mutableListOf()
        }
        fun flushCallout() {
            calloutKind?.let { blocks += ContentBlock.Callout(it, callout.toString().trim()) }
            calloutKind = null
            callout.clear()
        }
        fun flushAll() {
            flushParagraph(); flushList(); flushCallout()
        }

        var i = 0
        while (i < lines.size) {
            val raw = lines[i].trimEnd()
            val line = raw.trim()
            when {
                line.startsWith("```") -> {
                    flushAll()
                    val language = line.removePrefix("```").trim().ifEmpty { "text" }
                    val code = StringBuilder()
                    i++
                    while (i < lines.size && lines[i].trim() != "```") {
                        code.append(lines[i].trimEnd()).append('\n')
                        i++
                    }
                    if (i >= lines.size) throw CurriculumFormatException("$source: unterminated code block")
                    blocks += ContentBlock.Code(language, code.toString().trimEnd('\n'))
                }
                line.startsWith(":::solution") || line.startsWith(":::check") -> {
                    flushAll()
                    val kind = if (line.startsWith(":::solution")) CollapsibleKind.SOLUTION else CollapsibleKind.CHECK
                    val title = line.substringAfter(if (kind == CollapsibleKind.SOLUTION) ":::solution" else ":::check").trim()
                        .ifEmpty { if (kind == CollapsibleKind.SOLUTION) "Show solution" else "Knowledge check" }
                    val inner = mutableListOf<String>()
                    var fence = false
                    i++
                    while (i < lines.size) {
                        val l = lines[i]
                        if (l.trim().startsWith("```")) fence = !fence
                        if (!fence && l.trim() == ":::") break
                        inner += l
                        i++
                    }
                    if (i >= lines.size) throw CurriculumFormatException("$source: unterminated ::: block")
                    blocks += ContentBlock.Collapsible(kind, title, parseBlocks(inner, source))
                }
                line.isEmpty() -> flushAll()
                line == "---" -> {
                    flushAll(); blocks += ContentBlock.Divider
                }
                line.startsWith("#") -> {
                    flushAll()
                    val level = line.takeWhile { it == '#' }.length.coerceIn(1, 3)
                    blocks += ContentBlock.Heading(level, line.trimStart('#').trim())
                }
                line.startsWith("> ") || line == ">" -> {
                    flushParagraph(); flushList()
                    val content = line.removePrefix(">").trim()
                    if (calloutKind == null) {
                        val upper = content.substringBefore(':').uppercase()
                        val kind = CalloutKind.entries.firstOrNull { it.name == upper }
                        if (kind != null && content.contains(':')) {
                            calloutKind = kind
                            callout.append(content.substringAfter(':').trim())
                        } else {
                            calloutKind = CalloutKind.NOTE
                            callout.append(content)
                        }
                    } else {
                        if (callout.isNotEmpty()) callout.append(' ')
                        callout.append(content)
                    }
                }
                line.startsWith("- ") || line.startsWith("* ") -> {
                    flushParagraph(); flushCallout()
                    if (listItems.isNotEmpty() && listOrdered) flushList()
                    listOrdered = false
                    listItems += line.substring(2).trim()
                }
                ORDERED.matches(line) -> {
                    flushParagraph(); flushCallout()
                    if (listItems.isNotEmpty() && !listOrdered) flushList()
                    listOrdered = true
                    listItems += line.substringAfter(". ").trim()
                }
                raw.startsWith("  ") && listItems.isNotEmpty() -> {
                    listItems[listItems.lastIndex] = listItems.last() + " " + line
                }
                else -> {
                    flushList(); flushCallout()
                    if (paragraph.isNotEmpty()) paragraph.append(' ')
                    paragraph.append(line)
                }
            }
            i++
        }
        flushAll()
        return blocks
    }

    private val ORDERED = Regex("^\\d+\\.\\s.*")

    // ------------------------------------------------------------- questions

    fun parseQuestions(lines: List<String>, ownerId: String, source: String): List<Question> {
        val questions = mutableListOf<Question>()
        var i = 0
        while (i < lines.size) {
            val line = lines[i].trimEnd()
            if (line.isBlank() || line.trim().startsWith("//")) { i++; continue }
            if (!line.startsWith("? ")) throw CurriculumFormatException("$source: expected '? type: prompt' but found '$line'")
            val header = line.removePrefix("? ")
            val typeToken = header.substringBefore(':').trim().lowercase()
            val type = when (typeToken) {
                "mcq" -> QuestionType.MULTIPLE_CHOICE
                "tf" -> QuestionType.TRUE_FALSE
                "output" -> QuestionType.CODE_OUTPUT
                "fill" -> QuestionType.FILL_BLANK
                "order" -> QuestionType.CODE_ORDER
                "scenario" -> QuestionType.SCENARIO
                else -> throw CurriculumFormatException("$source: unknown question type '$typeToken'")
            }
            val prompt = StringBuilder(header.substringAfter(':').trim())
            var code: String? = null
            val options = mutableListOf<String>()
            var correct = -1
            var correctCount = 0
            val accepted = mutableListOf<String>()
            val ordered = mutableListOf<String>()
            val explanation = StringBuilder()
            i++
            while (i < lines.size && !lines[i].startsWith("? ")) {
                val l = lines[i].trimEnd()
                when {
                    l.trim().startsWith("```") -> {
                        val sb = StringBuilder()
                        i++
                        while (i < lines.size && lines[i].trim() != "```") {
                            sb.append(lines[i].trimEnd()).append('\n'); i++
                        }
                        if (i >= lines.size) throw CurriculumFormatException("$source: unterminated code in question")
                        code = sb.toString().trimEnd('\n')
                    }
                    l.startsWith("+ ") -> { correct = options.size; correctCount++; options += l.substring(2).trim() }
                    l.startsWith("- ") -> options += l.substring(2).trim()
                    l.startsWith("= ") -> accepted += l.substring(2).split("|").map { it.trim() }.filter { it.isNotEmpty() }
                    l.startsWith("~ ") -> ordered += l.substring(2)
                    l.startsWith("> ") -> {
                        if (explanation.isNotEmpty()) explanation.append(' ')
                        explanation.append(l.substring(2).trim())
                    }
                    l.isBlank() -> Unit
                    else -> {
                        if (options.isNotEmpty() || accepted.isNotEmpty() || ordered.isNotEmpty()) {
                            throw CurriculumFormatException("$source: unexpected line '$l' after answers")
                        }
                        prompt.append('\n').append(l.trim())
                    }
                }
                i++
            }
            val id = "$ownerId-q${questions.size + 1}"
            val q = when (type) {
                QuestionType.TRUE_FALSE -> {
                    val value = accepted.firstOrNull()?.lowercase()
                        ?: throw CurriculumFormatException("$source/$id: tf needs '= true' or '= false'")
                    if (value != "true" && value != "false") throw CurriculumFormatException("$source/$id: tf answer must be true/false")
                    Question(id, type, prompt.toString(), code, listOf("True", "False"),
                        if (value == "true") 0 else 1, explanation = explanation.toString())
                }
                QuestionType.FILL_BLANK -> {
                    if (accepted.isEmpty()) throw CurriculumFormatException("$source/$id: fill needs '= answer'")
                    Question(id, type, prompt.toString(), code, acceptedAnswers = accepted, explanation = explanation.toString())
                }
                QuestionType.CODE_ORDER -> {
                    if (ordered.size < 2) throw CurriculumFormatException("$source/$id: order needs at least two '~ ' items")
                    Question(id, type, prompt.toString(), code, orderedItems = ordered, explanation = explanation.toString())
                }
                else -> {
                    if (options.size < 2) throw CurriculumFormatException("$source/$id: needs at least two options")
                    if (correctCount != 1) throw CurriculumFormatException("$source/$id: needs exactly one '+' option")
                    if (options.toSet().size != options.size) throw CurriculumFormatException("$source/$id: duplicate options")
                    Question(id, type, prompt.toString(), code, options, correct, explanation = explanation.toString())
                }
            }
            if (q.explanation.isBlank()) throw CurriculumFormatException("$source/$id: missing '> explanation'")
            if (q.prompt.isBlank()) throw CurriculumFormatException("$source/$id: missing prompt")
            questions += q
        }
        return questions
    }
}
