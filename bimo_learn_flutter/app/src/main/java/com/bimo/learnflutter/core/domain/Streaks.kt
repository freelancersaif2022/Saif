package com.bimo.learnflutter.core.domain

data class StreakInfo(
    val current: Int,
    val longest: Int,
    val studiedToday: Boolean,
) {
    /** True when the streak is alive only because of yesterday's activity. */
    val atRisk: Boolean get() = current > 0 && !studiedToday
}

/**
 * Streaks are computed from the set of epoch days on which the learner did something meaningful
 * (finished reading a lesson, submitted a quiz, solved a challenge). A streak stays alive until the
 * end of the day after the last activity.
 */
object StreakCalculator {
    fun compute(activeDays: Set<Long>, today: Long): StreakInfo {
        if (activeDays.isEmpty()) return StreakInfo(0, 0, false)
        val studiedToday = today in activeDays
        val anchor = when {
            studiedToday -> today
            (today - 1) in activeDays -> today - 1
            else -> null
        }
        var current = 0
        if (anchor != null) {
            var day = anchor
            while (day in activeDays) { current++; day-- }
        }
        var longest = 0
        var run = 0
        var previous: Long? = null
        for (day in activeDays.sorted()) {
            run = if (previous != null && day == previous + 1) run + 1 else 1
            longest = maxOf(longest, run)
            previous = day
        }
        return StreakInfo(current, maxOf(longest, current), studiedToday)
    }
}

data class DailyGoalProgress(val goal: Int, val doneToday: Int) {
    val fraction: Float get() = if (goal <= 0) 0f else (doneToday.toFloat() / goal).coerceAtMost(1f)
    val met: Boolean get() = goal > 0 && doneToday >= goal
}

enum class StartDestination { ONBOARDING, WELCOME, HOME }

object StartDestinationResolver {
    fun resolve(onboardingCompleted: Boolean, hasProfile: Boolean): StartDestination = when {
        !onboardingCompleted -> StartDestination.ONBOARDING
        !hasProfile -> StartDestination.WELCOME
        else -> StartDestination.HOME
    }
}

object ProfileValidator {
    const val MAX_NAME_LENGTH = 40

    /** Returns an error message, or null when [name] is acceptable. */
    fun validateName(name: String): String? {
        val trimmed = name.trim()
        return when {
            trimmed.isEmpty() -> "Please enter your name."
            trimmed.length < 2 -> "Your name needs at least 2 characters."
            trimmed.length > MAX_NAME_LENGTH -> "Please keep your name under $MAX_NAME_LENGTH characters."
            trimmed.any { it.isISOControl() } -> "Your name contains unsupported characters."
            else -> null
        }
    }
}
