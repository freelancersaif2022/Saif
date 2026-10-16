package com.bimo.learnflutter.core.domain

import com.bimo.learnflutter.core.content.Question
import com.bimo.learnflutter.core.content.QuestionType
import com.bimo.learnflutter.core.content.Quiz

sealed interface QuizAnswer {
    /** Index into the question's *authoring-order* options list. */
    data class Choice(val index: Int) : QuizAnswer
    data class Text(val value: String) : QuizAnswer
    data class Order(val items: List<String>) : QuizAnswer
}

data class QuizResult(
    val quizId: String,
    val total: Int,
    val correct: Int,
    val passPercent: Int,
    val wrongQuestionIds: List<String>,
) {
    val percent: Int get() = if (total == 0) 0 else Math.round(correct * 100f / total)
    val passed: Boolean get() = total > 0 && percent >= passPercent
    val perfect: Boolean get() = total > 0 && correct == total
}

object QuizGrader {
    const val DEFAULT_PASS_PERCENT = 70

    fun isCorrect(question: Question, answer: QuizAnswer?): Boolean = when (answer) {
        null -> false
        is QuizAnswer.Choice -> question.isChoice && answer.index == question.correctIndex
        is QuizAnswer.Text -> question.type == QuestionType.FILL_BLANK &&
            question.acceptedAnswers.any { normalize(it) == normalize(answer.value) }
        is QuizAnswer.Order -> question.type == QuestionType.CODE_ORDER &&
            answer.items.map { it.trim() } == question.orderedItems.map { it.trim() }
    }

    fun grade(
        quiz: Quiz,
        answers: Map<String, QuizAnswer>,
        passPercent: Int = DEFAULT_PASS_PERCENT,
    ): QuizResult {
        val wrong = quiz.questions.filterNot { isCorrect(it, answers[it.id]) }.map { it.id }
        return QuizResult(
            quizId = quiz.id,
            total = quiz.questions.size,
            correct = quiz.questions.size - wrong.size,
            passPercent = passPercent,
            wrongQuestionIds = wrong,
        )
    }

    /**
     * Fill-in answers are compared leniently: surrounding whitespace, repeated inner spaces,
     * a trailing semicolon and letter case are ignored.
     */
    fun normalize(value: String): String =
        value.trim().removeSuffix(";").trim().replace(Regex("\\s+"), " ").lowercase()
}
