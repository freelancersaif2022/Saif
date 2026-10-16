package com.bimo.learnflutter.core.content

/**
 * Immutable, in-memory representation of the offline curriculum that ships in
 * `assets/curriculum`. Curriculum text is never copied into Room: the database
 * only stores progress keyed by the stable ids defined here.
 */
data class Curriculum(
    val courses: List<Course>,
    val finalExam: Quiz?,
) {
    val lessons: List<Lesson> = courses.flatMap { course -> course.modules.flatMap { it.lessons } }
    private val lessonIndex: Map<String, Lesson> = lessons.associateBy { it.id }
    private val moduleIndex: Map<String, Module> =
        courses.flatMap { it.modules }.associateBy { it.id }
    private val courseIndex: Map<String, Course> = courses.associateBy { it.id }

    fun lesson(id: String): Lesson? = lessonIndex[id]
    fun module(id: String): Module? = moduleIndex[id]
    fun course(id: String): Course? = courseIndex[id]

    val totalQuestions: Int get() = lessons.sumOf { it.quiz.questions.size } + (finalExam?.questions?.size ?: 0)

    companion object {
        val EMPTY = Curriculum(emptyList(), null)
    }
}

data class Course(
    val id: String,
    val title: String,
    val subtitle: String,
    val description: String,
    val level: String,
    val accentHex: String,
    val icon: String,
    val order: Int,
    /** Module id that must be fully completed before the first lesson of this course unlocks. */
    val requiresModuleId: String?,
    val isProjectCourse: Boolean,
    val modules: List<Module>,
) {
    val lessons: List<Lesson> get() = modules.flatMap { it.lessons }
    val lessonCount: Int get() = modules.sumOf { it.lessons.size }
    val totalMinutes: Int get() = modules.sumOf { m -> m.lessons.sumOf { it.minutes } }
}

data class Module(
    val id: String,
    val courseId: String,
    val number: Int,
    val title: String,
    val summary: String,
    val lessons: List<Lesson>,
)

data class Lesson(
    val id: String,
    val courseId: String,
    val moduleId: String,
    val title: String,
    val minutes: Int,
    val blocks: List<ContentBlock>,
    val quiz: Quiz,
    val isProject: Boolean,
) {
    /** Learning objectives are taken from the first list under a heading named "Learning objectives". */
    val objectives: List<String>
        get() {
            val headingIndex = blocks.indexOfFirst {
                it is ContentBlock.Heading && it.text.equals("Learning objectives", ignoreCase = true)
            }
            if (headingIndex < 0) return emptyList()
            return (blocks.drop(headingIndex + 1).firstOrNull() as? ContentBlock.ListBlock)?.items.orEmpty()
        }

    val codeExampleCount: Int
        get() = blocks.count { it is ContentBlock.Code }
}

sealed interface ContentBlock {
    data class Heading(val level: Int, val text: String) : ContentBlock
    data class Paragraph(val text: String) : ContentBlock
    data class ListBlock(val items: List<String>, val ordered: Boolean) : ContentBlock
    data class Code(val language: String, val code: String) : ContentBlock
    data class Callout(val kind: CalloutKind, val text: String) : ContentBlock
    data class Collapsible(val kind: CollapsibleKind, val title: String, val blocks: List<ContentBlock>) : ContentBlock
    data object Divider : ContentBlock
}

enum class CalloutKind { NOTE, TIP, WARNING, MISTAKE, IMPORTANT }

enum class CollapsibleKind { SOLUTION, CHECK }

data class Quiz(
    val id: String,
    val questions: List<Question>,
)

enum class QuestionType(val label: String) {
    MULTIPLE_CHOICE("Multiple choice"),
    TRUE_FALSE("True or false"),
    CODE_OUTPUT("Code output"),
    FILL_BLANK("Fill in the blank"),
    CODE_ORDER("Order the code"),
    SCENARIO("Scenario"),
}

data class Question(
    val id: String,
    val type: QuestionType,
    val prompt: String,
    val code: String?,
    /** Choice-based questions: all options, in authoring order. */
    val options: List<String> = emptyList(),
    /** Choice-based questions: index of the correct option within [options]. */
    val correctIndex: Int = -1,
    /** Fill-in-the-blank: every accepted spelling. */
    val acceptedAnswers: List<String> = emptyList(),
    /** Code ordering: the lines in their correct order. */
    val orderedItems: List<String> = emptyList(),
    val explanation: String,
) {
    val isChoice: Boolean
        get() = type == QuestionType.MULTIPLE_CHOICE || type == QuestionType.TRUE_FALSE ||
            type == QuestionType.CODE_OUTPUT || type == QuestionType.SCENARIO

    val correctAnswerText: String
        get() = when (type) {
            QuestionType.FILL_BLANK -> acceptedAnswers.first()
            QuestionType.CODE_ORDER -> orderedItems.joinToString("\n")
            else -> options.getOrElse(correctIndex) { "" }
        }
}

/** Optional coding challenge from `assets/curriculum/challenges.bimo` (Practice tab). */
data class Challenge(
    val id: String,
    val title: String,
    val difficulty: String,
    val premium: Boolean,
    val blocks: List<ContentBlock>,
)
