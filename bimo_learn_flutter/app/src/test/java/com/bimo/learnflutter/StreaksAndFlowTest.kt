package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.DailyGoalProgress
import com.bimo.learnflutter.core.domain.ProfileValidator
import com.bimo.learnflutter.core.domain.StartDestination
import com.bimo.learnflutter.core.domain.StartDestinationResolver
import com.bimo.learnflutter.core.domain.StreakCalculator
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class StreaksAndFlowTest {
    @Test
    fun emptyHistory() {
        val s = StreakCalculator.compute(emptySet(), 100)
        assertEquals(0, s.current)
        assertEquals(0, s.longest)
    }

    @Test
    fun streakIncludingToday() {
        val s = StreakCalculator.compute(setOf(98, 99, 100), 100)
        assertEquals(3, s.current)
        assertTrue(s.studiedToday)
        assertFalse(s.atRisk)
    }

    @Test
    fun streakAliveFromYesterdayIsAtRisk() {
        val s = StreakCalculator.compute(setOf(97, 98, 99), 100)
        assertEquals(3, s.current)
        assertTrue(s.atRisk)
    }

    @Test
    fun brokenStreakKeepsLongest() {
        val s = StreakCalculator.compute(setOf(10, 11, 12, 13, 50, 51), 100)
        assertEquals(0, s.current)
        assertEquals(4, s.longest)
    }

    @Test
    fun onboardingRouting() {
        assertEquals(StartDestination.ONBOARDING, StartDestinationResolver.resolve(false, false))
        assertEquals(StartDestination.ONBOARDING, StartDestinationResolver.resolve(false, true))
        assertEquals(StartDestination.WELCOME, StartDestinationResolver.resolve(true, false))
        assertEquals(StartDestination.HOME, StartDestinationResolver.resolve(true, true))
    }

    @Test
    fun welcomeNameValidation() {
        assertNotNull(ProfileValidator.validateName("   "))
        assertNotNull(ProfileValidator.validateName("A"))
        assertNotNull(ProfileValidator.validateName("x".repeat(41)))
        assertNull(ProfileValidator.validateName("  Saif  "))
    }

    @Test
    fun dailyGoal() {
        assertEquals(0.5f, DailyGoalProgress(2, 1).fraction, 0.001f)
        assertTrue(DailyGoalProgress(2, 3).met)
        assertEquals(1f, DailyGoalProgress(2, 3).fraction, 0.001f)
        assertFalse(DailyGoalProgress(0, 3).met)
    }
}
