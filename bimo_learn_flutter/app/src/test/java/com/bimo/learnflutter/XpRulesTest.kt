package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.LevelCalculator
import com.bimo.learnflutter.core.domain.QuizResult
import com.bimo.learnflutter.core.domain.XpRules
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class XpRulesTest {
    private fun result(correct: Int, total: Int = 10) = QuizResult("q", total, correct, 70, emptyList())

    @Test
    fun passedLessonAwards() {
        val awards = XpRules.awardsForPassedLesson("l1", "Hello", false, result(8), null, 100)
        assertEquals(listOf("lesson:l1", "quiz:l1", "daily:100"), awards.map { it.key })
        assertEquals(20 + 30 + 10, awards.sumOf { it.amount })
    }

    @Test
    fun perfectProjectAndModuleBonuses() {
        val awards = XpRules.awardsForPassedLesson("p1", "Counter", true, result(10), "m1" to "Basics", 100)
        val keys = awards.map { it.key }
        assertTrue("perfect:p1" in keys)
        assertTrue("project:p1" in keys)
        assertTrue("module:m1" in keys)
        assertEquals(20 + 30 + 20 + 100 + 150 + 10, awards.sumOf { it.amount })
    }

    @Test
    fun failedQuizAwardsNothing() {
        assertTrue(XpRules.awardsForPassedLesson("l1", "Hello", false, result(5), null, 1).isEmpty())
    }

    @Test
    fun repeatedCompletionProducesSameKeysSoLedgerCanRejectFarming() {
        val first = XpRules.awardsForPassedLesson("l1", "Hello", false, result(10), null, 5).map { it.key }.toSet()
        val again = XpRules.awardsForPassedLesson("l1", "Hello", false, result(10), null, 5).map { it.key }.toSet()
        assertEquals(first, again)
        // Simulate a ledger with unique keys.
        val ledger = mutableMapOf<String, Int>()
        listOf(first, again).forEach { keys -> keys.forEach { ledger.putIfAbsent(it, 1) } }
        assertEquals(first.size, ledger.size)
    }

    @Test
    fun rewardedSlotsAreCappedPerDay() {
        val keys = mutableSetOf<String>()
        repeat(XpRules.MAX_REWARDED_BONUSES_PER_DAY) { keys += XpRules.nextRewardedKey(keys, 7)!! }
        assertNull(XpRules.nextRewardedKey(keys, 7))
        assertEquals("rewarded:8:1", XpRules.nextRewardedKey(keys, 8))
    }

    @Test
    fun levels() {
        assertEquals(1, LevelCalculator.levelFor(0).level)
        assertEquals(1, LevelCalculator.levelFor(99).level)
        assertEquals(2, LevelCalculator.levelFor(100).level)
        assertEquals(3, LevelCalculator.levelFor(250).level)
        val info = LevelCalculator.levelFor(300)
        assertEquals(3, info.level)
        assertEquals(50, info.xpIntoLevel)
        assertEquals(200, info.xpForNextLevel)
        assertEquals(0.25f, info.progress, 0.001f)
        assertEquals(1, LevelCalculator.levelFor(-10).level)
    }
}
