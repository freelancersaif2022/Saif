package com.bimo.learnflutter.core.content

/** Minimal file abstraction so the loader works with Android assets and with plain files in tests. */
interface ContentSource {
    /** Names (not paths) of the entries in [dir]. */
    fun list(dir: String): List<String>
    fun read(path: String): String
}

/**
 * Assembles the full [Curriculum] from `curriculum/<course>/course.bimo` manifests, module files
 * (`NN_slug.bimo`, sorted by name) and the final assessment in `curriculum/final/exam.bimo`.
 */
object CurriculumLoader {
    const val ROOT = "curriculum"

    fun load(source: ContentSource): Curriculum {
        val courseDirs = source.list(ROOT).filter { name ->
            name != "final" && source.list("$ROOT/$name").contains("course.bimo")
        }
        val courses = courseDirs.map { dir ->
            val manifest = CurriculumParser.parseCourseManifest(source.read("$ROOT/$dir/course.bimo"), "$dir/course.bimo")
            val modules = source.list("$ROOT/$dir")
                .filter { it.endsWith(".bimo") && it != "course.bimo" }
                .map { it to source.read("$ROOT/$dir/$it") }
            CurriculumParser.buildCourse(manifest, modules)
        }.sortedBy { it.order }
        val exam = if (source.list("$ROOT/final").contains("exam.bimo")) {
            CurriculumParser.parseExam(source.read("$ROOT/final/exam.bimo"), "final/exam.bimo")
        } else null
        return Curriculum(courses, exam)
    }

    fun loadChallenges(source: ContentSource): List<Challenge> =
        if (source.list(ROOT).contains("challenges.bimo")) {
            CurriculumParser.parseChallenges(source.read("$ROOT/challenges.bimo"))
        } else emptyList()
}
