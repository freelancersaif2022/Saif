package com.bimo.learnflutter

import com.bimo.learnflutter.core.domain.AchievementCatalog
import com.bimo.learnflutter.core.domain.LearnerStats
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class AchievementsTest {
    @Test
    fun idsAreUnique() {
        val ids = AchievementCatalog.all.map { it.id }
        assertEquals(ids.size, ids.toSet().size)
    }

    @Test
    fun nothingUnlockedForNewLearner() {
        assertTrue(AchievementCatalog.newlyUnlocked(LearnerStats(), emptySet()).isEmpty())
    }

    @Test
    fun firstLessonAndPerfectUnlock() {
        val stats = LearnerStats(lessonsCompleted = 1, quizzesPassed = 1, perfectQuizzes = 1, totalXp = 80)
        val ids = AchievementCatalog.newlyUnlocked(stats, emptySet()).map { it.id }
        assertEquals(listOf("first_lesson", "perfect_1"), ids)
    }

    @Test
    fun alreadyUnlockedAreNotReported() {
        val stats = LearnerStats(lessonsCompleted = 12)
        val ids = AchievementCatalog.newlyUnlocked(stats, setOf("first_lesson")).map { it.id }
        assertEquals(listOf("lessons_10"), ids)
    }

    @Test
    fun progressIsReportedForLockedBadges() {
        val def = AchievementCatalog.byId("lessons_50")!!
        assertEquals(20 to 50, def.progress(LearnerStats(lessonsCompleted = 20)))
    }

    @Test
    fun streakUsesLongestSoBadgesSurviveBreaks() {
        val stats = LearnerStats(currentStreak = 0, longestStreak = 7)
        val ids = AchievementCatalog.newlyUnlocked(stats, emptySet()).map { it.id }
        assertTrue("streak_7" in ids && "streak_3" in ids)
    }
}
