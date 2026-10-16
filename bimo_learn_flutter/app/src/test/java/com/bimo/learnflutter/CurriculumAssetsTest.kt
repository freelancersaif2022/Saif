package com.bimo.learnflutter

import com.bimo.learnflutter.core.content.CurriculumLoader
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** Loads the real shipped curriculum and checks its structure. */
class CurriculumAssetsTest {
    private val source = TestFixtures.FileContentSource(TestFixtures.assetsRoot())
    private val curriculum = CurriculumLoader.load(source)

    @Test
    fun coursesAndModules() {
        assertEquals(listOf("dart", "flutter", "projects"), curriculum.courses.map { it.id })
        assertEquals(7, curriculum.course("dart")!!.modules.size)
        assertEquals(20, curriculum.course("flutter")!!.modules.size)
        assertEquals(15, curriculum.course("projects")!!.lessonCount)
    }

    @Test
    fun everyLessonHasContentAndIdsAreUnique() {
        val ids = curriculum.lessons.map { it.id }
        assertEquals(ids.size, ids.toSet().size)
        curriculum.lessons.forEach { lesson ->
            assertTrue(lesson.id, lesson.blocks.size >= 3)
            assertTrue(lesson.id, lesson.codeExampleCount >= 1)
            assertTrue(lesson.id, lesson.quiz.questions.isEmpty() || lesson.quiz.questions.size >= 5)
        }
    }

    @Test
    fun finalExamAndChallenges() {
        assertNotNull(curriculum.finalExam)
        assertTrue(curriculum.finalExam!!.questions.size >= 20)
        assertTrue(CurriculumLoader.loadChallenges(source).isNotEmpty())
        assertEquals("flutter-m03", curriculum.course("projects")!!.requiresModuleId)
        assertNotNull(curriculum.module("flutter-m03"))
    }
}
