package com.bimo.learnflutter.core.domain

/** A single XP grant. [key] is unique per one-time reward so the ledger can reject duplicates. */
data class XpAward(val key: String, val amount: Int, val reason: String)

object XpRules {
    const val LESSON_COMPLETE = 20
    const val QUIZ_PASSED = 30
    const val PERFECT_QUIZ_BONUS = 20
    const val DAILY_ACTIVITY = 10
    const val PROJECT_COMPLETE = 100
    const val MODULE_COMPLETE = 150
    const val FINAL_EXAM_PASSED = 250
    const val CHALLENGE_COMPLETE = 25
    const val REWARDED_AD_BONUS = 15
    const val MAX_REWARDED_BONUSES_PER_DAY = 3

    fun lessonKey(lessonId: String) = "lesson:$lessonId"
    fun quizKey(lessonId: String) = "quiz:$lessonId"
    fun perfectKey(lessonId: String) = "perfect:$lessonId"
    fun projectKey(lessonId: String) = "project:$lessonId"
    fun moduleKey(moduleId: String) = "module:$moduleId"
    fun dailyKey(epochDay: Long) = "daily:$epochDay"
    fun challengeKey(challengeId: String) = "challenge:$challengeId"
    fun rewardedKey(epochDay: Long, slot: Int) = "rewarded:$epochDay:$slot"
    const val FINAL_EXAM_KEY = "final-exam"

    /**
     * Rewards for a passed lesson quiz. Every award has a deterministic key, so calling this again
     * for an already-completed lesson produces the same keys and the ledger grants nothing new.
     */
    fun awardsForPassedLesson(
        lessonId: String,
        lessonTitle: String,
        isProject: Boolean,
        quiz: QuizResult,
        completedModule: Pair<String, String>?,
        epochDay: Long,
    ): List<XpAward> {
        if (!quiz.passed) return emptyList()
        val awards = mutableListOf(
            XpAward(lessonKey(lessonId), LESSON_COMPLETE, "Completed “$lessonTitle”"),
            XpAward(quizKey(lessonId), QUIZ_PASSED, "Passed the quiz"),
        )
        if (quiz.perfect) awards += XpAward(perfectKey(lessonId), PERFECT_QUIZ_BONUS, "Perfect score bonus")
        if (isProject) awards += XpAward(projectKey(lessonId), PROJECT_COMPLETE, "Project completed")
        completedModule?.let { (id, title) ->
            awards += XpAward(moduleKey(id), MODULE_COMPLETE, "Module completed: $title")
        }
        awards += XpAward(dailyKey(epochDay), DAILY_ACTIVITY, "Daily learning activity")
        return awards
    }

    /** Next free rewarded-ad slot for today, or null when the daily cap has been reached. */
    fun nextRewardedKey(existingKeys: Set<String>, epochDay: Long): String? =
        (1..MAX_REWARDED_BONUSES_PER_DAY).map { rewardedKey(epochDay, it) }.firstOrNull { it !in existingKeys }
}

data class LevelInfo(
    val level: Int,
    val title: String,
    val xpIntoLevel: Int,
    val xpForNextLevel: Int,
) {
    val progress: Float get() = if (xpForNextLevel == 0) 1f else xpIntoLevel.toFloat() / xpForNextLevel
}

object LevelCalculator {
    /** XP needed to go from [level] to level + 1: 100, 150, 200, ... */
    fun xpToAdvance(level: Int): Int = 100 + (level - 1) * 50

    fun levelFor(totalXp: Int): LevelInfo {
        var level = 1
        var remaining = totalXp.coerceAtLeast(0)
        while (remaining >= xpToAdvance(level)) {
            remaining -= xpToAdvance(level)
            level++
        }
        return LevelInfo(level, titleFor(level), remaining, xpToAdvance(level))
    }

    fun titleFor(level: Int): String = when {
        level < 3 -> "Curious Beginner"
        level < 6 -> "Dart Explorer"
        level < 10 -> "Widget Builder"
        level < 15 -> "Layout Artisan"
        level < 20 -> "State Wrangler"
        level < 30 -> "Flutter Engineer"
        level < 40 -> "Senior Flutter Craftsperson"
        else -> "Flutter Master"
    }
}
