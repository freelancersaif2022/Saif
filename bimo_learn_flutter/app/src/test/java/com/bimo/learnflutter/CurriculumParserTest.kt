package com.bimo.learnflutter

import com.bimo.learnflutter.core.content.CalloutKind
import com.bimo.learnflutter.core.content.CollapsibleKind
import com.bimo.learnflutter.core.content.ContentBlock
import com.bimo.learnflutter.core.content.CurriculumFormatException
import com.bimo.learnflutter.core.content.CurriculumParser
import com.bimo.learnflutter.core.content.QuestionType
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Assert.fail
import org.junit.Test

class CurriculumParserTest {

    @Test
    fun parsesBlocksOfEveryKind() {
        val blocks = CurriculumParser.parseBlocks(
            """
            ## Heading
            First line
            continues here.

            - one
            - two
              wrapped
            1. first
            2. second

            > TIP: Use const.
            > It is faster.

            ```dart
            @override
            Widget build(BuildContext context) => const Text('x');
            ```
            ---
            :::solution Reveal
            ```dart
            print('done');
            ```
            :::
            :::check What is 2 + 2?
            Four.
            :::
            """.trimIndent().lines(),
        )
        assertEquals(ContentBlock.Heading(2, "Heading"), blocks[0])
        assertEquals(ContentBlock.Paragraph("First line continues here."), blocks[1])
        assertEquals(ContentBlock.ListBlock(listOf("one", "two wrapped"), false), blocks[2])
        assertEquals(ContentBlock.ListBlock(listOf("first", "second"), true), blocks[3])
        assertEquals(ContentBlock.Callout(CalloutKind.TIP, "Use const. It is faster."), blocks[4])
        val code = blocks[5] as ContentBlock.Code
        assertEquals("dart", code.language)
        assertTrue(code.code.startsWith("@override"))
        assertEquals(ContentBlock.Divider, blocks[6])
        val solution = blocks[7] as ContentBlock.Collapsible
        assertEquals(CollapsibleKind.SOLUTION, solution.kind)
        assertEquals("Reveal", solution.title)
        assertTrue(solution.blocks.single() is ContentBlock.Code)
        val check = blocks[8] as ContentBlock.Collapsible
        assertEquals(CollapsibleKind.CHECK, check.kind)
        assertEquals("What is 2 + 2?", check.title)
    }

    @Test
    fun parsesEveryQuestionType() {
        val curriculum = TestFixtures.curriculum()
        val quiz = curriculum.lesson("d1")!!.quiz
        assertEquals(5, quiz.questions.size)
        val types = quiz.questions.map { it.type }
        assertEquals(
            listOf(QuestionType.MULTIPLE_CHOICE, QuestionType.TRUE_FALSE, QuestionType.FILL_BLANK, QuestionType.CODE_ORDER, QuestionType.CODE_OUTPUT),
            types,
        )
        assertEquals(1, quiz.questions[0].correctIndex)
        assertEquals(0, quiz.questions[1].correctIndex)
        assertEquals(listOf("const", "final"), quiz.questions[2].acceptedAnswers)
        assertEquals("  print('hi');", quiz.questions[3].orderedItems[1])
        assertEquals("print(1 + 1);", quiz.questions[4].code)
        assertEquals("d1-q1", quiz.questions[0].id)
    }

    @Test
    fun lessonObjectivesAreExtracted() {
        val lesson = TestFixtures.curriculum().lesson("d2")!!
        assertEquals(listOf("Understand Variables"), lesson.objectives)
        assertEquals(1, lesson.codeExampleCount)
    }

    @Test
    fun rejectsQuestionWithoutCorrectOption() {
        try {
            CurriculumParser.parseQuestions(listOf("? mcq: Pick", "- a", "- b", "> nope"), "x", "test")
            fail("expected exception")
        } catch (e: CurriculumFormatException) {
            assertTrue(e.message!!.contains("exactly one"))
        }
    }

    @Test
    fun lessonsWithoutQuizAreAllowed() {
        val m = CurriculumParser.parseModule("c", 1, "@module m | M\n@lesson l | L | 3\nText only\n@lesson l2 | L2 | 3\nMore\n", "test")
        assertEquals(2, m.lessons.size)
        assertTrue(m.lessons.all { it.quiz.questions.isEmpty() })
    }

    @Test
    fun parsesChallenges() {
        val list = CurriculumParser.parseChallenges(
            "@challenge c1 | FizzBuzz | Easy | false\nWrite it.\n:::solution\n```dart\nvoid main() {}\n```\n:::\n" +
                "@challenge c2 | Hard one | Hard | true\nDo it.\n",
        )
        assertEquals(2, list.size)
        assertEquals(false, list[0].premium)
        assertEquals(true, list[1].premium)
    }
}
