package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.LessonStatus
import com.bimo.learnflutter.core.domain.ProgressionEngine
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class ProgressionEngineTest {
    private val curriculum = TestFixtures.curriculum()
    private val dart = curriculum.course("dart")!!
    private val projects = curriculum.course("projects")!!

    @Test
    fun onlyFirstLessonUnlockedInitially() {
        val states = ProgressionEngine.courseStates(dart, curriculum, emptySet(), emptySet())
        assertEquals(listOf(LessonStatus.AVAILABLE, LessonStatus.LOCKED, LessonStatus.LOCKED), states.map { it.status })
        assertNotNull(states[1].lockReason)
        assertTrue(states[1].lockReason!!.contains("Hello"))
    }

    @Test
    fun completingLessonUnlocksNextAcrossModules() {
        val states = ProgressionEngine.courseStates(dart, curriculum, setOf("d1", "d2"), setOf("d3"))
        assertEquals(listOf(LessonStatus.COMPLETED, LessonStatus.COMPLETED, LessonStatus.IN_PROGRESS), states.map { it.status })
    }

    @Test
    fun cannotBypassProgressionByNavigation() {
        assertTrue(ProgressionEngine.canOpen("d1", curriculum, emptySet()))
        assertFalse(ProgressionEngine.canOpen("d2", curriculum, emptySet()))
        assertFalse(ProgressionEngine.canOpen("d3", curriculum, setOf("d1")))
        assertTrue(ProgressionEngine.canOpen("d3", curriculum, setOf("d1", "d2")))
        assertFalse(ProgressionEngine.canOpen("unknown", curriculum, emptySet()))
    }

    @Test
    fun completedLessonsStayOpenEvenIfEarlierProgressMissing() {
        // Defensive: data restored from an older version must never lock a completed lesson.
        assertTrue(ProgressionEngine.canOpen("d3", curriculum, setOf("d3")))
    }

    @Test
    fun coursePrerequisiteGatesFirstLesson() {
        assertFalse(ProgressionEngine.canOpen("p1", curriculum, emptySet()))
        val locked = ProgressionEngine.courseStates(projects, curriculum, emptySet(), emptySet())
        assertTrue(locked.all { it.status == LessonStatus.LOCKED })
        assertTrue(locked[0].lockReason!!.contains("Module 1"))
        assertTrue(ProgressionEngine.canOpen("p1", curriculum, setOf("d1", "d2")))
    }

    @Test
    fun independentCoursesStartUnlocked() {
        assertTrue(ProgressionEngine.canOpen("f1", curriculum, emptySet()))
    }

    @Test
    fun nextAndRecommendedLessons() {
        assertEquals("d2", ProgressionEngine.nextLesson(dart, setOf("d1"))!!.id)
        assertNull(ProgressionEngine.nextLesson(dart, setOf("d1", "d2", "d3")))
        assertEquals("d2", ProgressionEngine.lessonAfter("d1", curriculum)!!.id)
        assertNull(ProgressionEngine.lessonAfter("d3", curriculum))
        assertEquals("d1", ProgressionEngine.recommendedLesson(curriculum, emptySet(), null)!!.id)
        assertEquals("f1", ProgressionEngine.recommendedLesson(curriculum, setOf("d1"), "f1")!!.id)
        assertEquals("d2", ProgressionEngine.recommendedLesson(curriculum, setOf("d1"), "d1")!!.id)
    }

    @Test
    fun moduleAndCourseProgress() {
        val m1 = curriculum.module("dart-m1")!!
        val progress = ProgressionEngine.moduleProgress(m1, setOf("d1"))
        assertEquals(1, progress.completed)
        assertEquals(0.5f, progress.fraction, 0.001f)
        assertFalse(progress.isComplete)
        assertTrue(ProgressionEngine.moduleProgress(m1, setOf("d1", "d2")).isComplete)
        assertEquals(2f / 3f, ProgressionEngine.courseFraction(dart, setOf("d1", "d2")), 0.001f)
        assertTrue(ProgressionEngine.isCourseComplete(dart, setOf("d1", "d2", "d3")))
    }
}
