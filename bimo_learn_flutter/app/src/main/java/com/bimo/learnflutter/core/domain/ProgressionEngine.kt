package com.bimo.learnflutter.core.domain

import com.bimo.learnflutter.core.content.Course
import com.bimo.learnflutter.core.content.Curriculum
import com.bimo.learnflutter.core.content.Lesson
import com.bimo.learnflutter.core.content.Module

enum class LessonStatus { LOCKED, AVAILABLE, IN_PROGRESS, COMPLETED }

data class LessonState(
    val lesson: Lesson,
    val status: LessonStatus,
    val lockReason: String?,
) {
    val isOpenable: Boolean get() = status != LessonStatus.LOCKED
}

data class ModuleProgress(
    val module: Module,
    val completed: Int,
    val total: Int,
) {
    val fraction: Float get() = if (total == 0) 0f else completed.toFloat() / total
    val isComplete: Boolean get() = total > 0 && completed == total
}

/**
 * Strict sequential progression:
 *  - The first lesson of every course is available (once the course prerequisite, if any, is met).
 *  - Every other lesson unlocks only after the previous lesson in the same course is COMPLETED,
 *    which in turn requires the lesson to be read and its quiz to be passed.
 *
 * The engine is pure and deterministic so the same rules guard both the UI (lock icons) and
 * navigation (a deep link or stale back-stack entry cannot open a locked lesson).
 */
object ProgressionEngine {

    fun prerequisiteMet(course: Course, curriculum: Curriculum, completed: Set<String>): Boolean {
        val required = course.requiresModuleId ?: return true
        val module = curriculum.module(required) ?: return true
        return module.lessons.all { it.id in completed }
    }

    fun courseStates(
        course: Course,
        curriculum: Curriculum,
        completed: Set<String>,
        started: Set<String>,
    ): List<LessonState> {
        val prereq = prerequisiteMet(course, curriculum, completed)
        val prereqTitle = course.requiresModuleId?.let { curriculum.module(it) }?.let { m ->
            val c = curriculum.course(m.courseId)
            "${c?.title ?: m.courseId} – Module ${m.number}: ${m.title}"
        }
        val lessons = course.lessons
        return lessons.mapIndexed { index, lesson ->
            when {
                lesson.id in completed -> LessonState(lesson, LessonStatus.COMPLETED, null)
                !prereq -> LessonState(
                    lesson, LessonStatus.LOCKED,
                    "Finish $prereqTitle to unlock this course.",
                )
                index == 0 || lessons[index - 1].id in completed -> LessonState(
                    lesson,
                    if (lesson.id in started) LessonStatus.IN_PROGRESS else LessonStatus.AVAILABLE,
                    null,
                )
                else -> LessonState(
                    lesson, LessonStatus.LOCKED,
                    "Complete “${lessons[index - 1].title}” and pass its quiz to unlock this lesson.",
                )
            }
        }
    }

    fun canOpen(lessonId: String, curriculum: Curriculum, completed: Set<String>): Boolean {
        val lesson = curriculum.lesson(lessonId) ?: return false
        val course = curriculum.course(lesson.courseId) ?: return false
        if (lessonId in completed) return true
        if (!prerequisiteMet(course, curriculum, completed)) return false
        val lessons = course.lessons
        val index = lessons.indexOfFirst { it.id == lessonId }
        return index == 0 || (index > 0 && lessons[index - 1].id in completed)
    }

    fun lockReason(lessonId: String, curriculum: Curriculum, completed: Set<String>): String? {
        val lesson = curriculum.lesson(lessonId) ?: return "This lesson does not exist."
        val course = curriculum.course(lesson.courseId) ?: return "This lesson does not exist."
        return courseStates(course, curriculum, completed, emptySet()).first { it.lesson.id == lessonId }.lockReason
    }

    /** The first lesson in the course that is not yet completed (null when the course is finished). */
    fun nextLesson(course: Course, completed: Set<String>): Lesson? =
        course.lessons.firstOrNull { it.id !in completed }

    /** The lesson after [lessonId] in the same course, or null at the end of the course. */
    fun lessonAfter(lessonId: String, curriculum: Curriculum): Lesson? {
        val lesson = curriculum.lesson(lessonId) ?: return null
        val lessons = curriculum.course(lesson.courseId)?.lessons ?: return null
        val index = lessons.indexOfFirst { it.id == lessonId }
        return lessons.getOrNull(index + 1)
    }

    fun moduleProgress(module: Module, completed: Set<String>): ModuleProgress =
        ModuleProgress(module, module.lessons.count { it.id in completed }, module.lessons.size)

    fun courseFraction(course: Course, completed: Set<String>): Float {
        val total = course.lessonCount
        if (total == 0) return 0f
        return course.lessons.count { it.id in completed }.toFloat() / total
    }

    fun isCourseComplete(course: Course, completed: Set<String>): Boolean =
        course.lessonCount > 0 && course.lessons.all { it.id in completed }

    /**
     * Recommended lesson for the dashboard: continue the most recently started course,
     * otherwise the first incomplete, unlocked lesson in course order.
     */
    fun recommendedLesson(
        curriculum: Curriculum,
        completed: Set<String>,
        lastOpenedLessonId: String?,
    ): Lesson? {
        val last = lastOpenedLessonId?.let { curriculum.lesson(it) }
        if (last != null) {
            if (last.id !in completed && canOpen(last.id, curriculum, completed)) return last
            curriculum.course(last.courseId)?.let { course ->
                nextLesson(course, completed)?.takeIf { canOpen(it.id, curriculum, completed) }?.let { return it }
            }
        }
        return curriculum.courses.sortedBy { it.order }.firstNotNullOfOrNull { course ->
            nextLesson(course, completed)?.takeIf { canOpen(it.id, curriculum, completed) }
        }
    }
}
