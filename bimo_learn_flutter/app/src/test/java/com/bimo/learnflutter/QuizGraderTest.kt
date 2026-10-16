package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.QuizAnswer
import com.bimo.learnflutter.core.domain.QuizGrader
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class QuizGraderTest {
    private val quiz = TestFixtures.curriculum().lesson("d1")!!.quiz
    private val q = quiz.questions

    private fun allCorrect() = mapOf(
        q[0].id to QuizAnswer.Choice(1),
        q[1].id to QuizAnswer.Choice(0),
        q[2].id to QuizAnswer.Text("  CONST; "),
        q[3].id to QuizAnswer.Order(q[3].orderedItems),
        q[4].id to QuizAnswer.Choice(0),
    )

    @Test
    fun perfectScore() {
        val result = QuizGrader.grade(quiz, allCorrect())
        assertEquals(5, result.correct)
        assertEquals(100, result.percent)
        assertTrue(result.passed)
        assertTrue(result.perfect)
        assertTrue(result.wrongQuestionIds.isEmpty())
    }

    @Test
    fun seventyPercentThresholdIsInclusive() {
        // 4/5 = 80% passes, 3/5 = 60% fails.
        val oneWrong = allCorrect() + (q[0].id to QuizAnswer.Choice(0))
        assertTrue(QuizGrader.grade(quiz, oneWrong).passed)
        val twoWrong = oneWrong + (q[2].id to QuizAnswer.Text("var"))
        val failed = QuizGrader.grade(quiz, twoWrong)
        assertEquals(60, failed.percent)
        assertFalse(failed.passed)
        assertEquals(listOf(q[0].id, q[2].id), failed.wrongQuestionIds)
    }

    @Test
    fun unansweredQuestionsAreWrong() {
        val result = QuizGrader.grade(quiz, emptyMap())
        assertEquals(0, result.correct)
        assertFalse(result.passed)
    }

    @Test
    fun orderMustMatchExactly() {
        assertFalse(QuizGrader.isCorrect(q[3], QuizAnswer.Order(q[3].orderedItems.reversed())))
        assertTrue(QuizGrader.isCorrect(q[3], QuizAnswer.Order(q[3].orderedItems.map { it.trim() })))
    }

    @Test
    fun answerTypeMismatchIsWrong() {
        assertFalse(QuizGrader.isCorrect(q[0], QuizAnswer.Text("Right")))
        assertFalse(QuizGrader.isCorrect(q[2], QuizAnswer.Choice(0)))
    }

    @Test
    fun retryProducesFreshResult() {
        val first = QuizGrader.grade(quiz, emptyMap())
        val second = QuizGrader.grade(quiz, allCorrect())
        assertFalse(first.passed)
        assertTrue(second.passed)
    }

    @Test
    fun emptyQuizNeverPasses() {
        val result = QuizGrader.grade(quiz.copy(questions = emptyList()), emptyMap())
        assertFalse(result.passed)
    }
}
