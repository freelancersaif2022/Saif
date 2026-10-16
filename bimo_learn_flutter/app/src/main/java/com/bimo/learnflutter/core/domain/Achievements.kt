package com.bimo.learnflutter.core.domain

/** Aggregated numbers that achievements are evaluated against. */
data class LearnerStats(
    val lessonsCompleted: Int = 0,
    val quizzesPassed: Int = 0,
    val perfectQuizzes: Int = 0,
    val quizAttempts: Int = 0,
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val totalXp: Int = 0,
    val modulesCompleted: Int = 0,
    val projectsCompleted: Int = 0,
    val challengesCompleted: Int = 0,
    val dartCourseComplete: Boolean = false,
    val flutterCourseComplete: Boolean = false,
    val projectsCourseComplete: Boolean = false,
    val finalExamPassed: Boolean = false,
    val certificateEarned: Boolean = false,
    val retriedAfterFailing: Boolean = false,
)

enum class AchievementTier { BRONZE, SILVER, GOLD, PLATINUM }

data class AchievementDefinition(
    val id: String,
    val title: String,
    val description: String,
    val icon: String,
    val tier: AchievementTier,
    /** Current progress and target, used for progress bars on locked badges. */
    val progress: (LearnerStats) -> Pair<Int, Int>,
) {
    fun isUnlocked(stats: LearnerStats): Boolean = progress(stats).let { (value, target) -> value >= target }
}

object AchievementCatalog {
    private fun flag(value: Boolean) = (if (value) 1 else 0) to 1

    val all: List<AchievementDefinition> = listOf(
        AchievementDefinition("first_lesson", "First Steps", "Complete your first lesson.", "school", AchievementTier.BRONZE) { it.lessonsCompleted to 1 },
        AchievementDefinition("lessons_10", "Getting Serious", "Complete 10 lessons.", "menu_book", AchievementTier.BRONZE) { it.lessonsCompleted to 10 },
        AchievementDefinition("lessons_50", "Bookworm", "Complete 50 lessons.", "auto_stories", AchievementTier.SILVER) { it.lessonsCompleted to 50 },
        AchievementDefinition("lessons_150", "Knowledge Engine", "Complete 150 lessons.", "psychology", AchievementTier.GOLD) { it.lessonsCompleted to 150 },
        AchievementDefinition("perfect_1", "Flawless", "Score 100% on a quiz.", "verified", AchievementTier.BRONZE) { it.perfectQuizzes to 1 },
        AchievementDefinition("perfect_25", "Precision Coder", "Score 100% on 25 quizzes.", "target", AchievementTier.GOLD) { it.perfectQuizzes to 25 },
        AchievementDefinition("comeback", "Never Give Up", "Pass a quiz after failing it first.", "replay", AchievementTier.BRONZE) { flag(it.retriedAfterFailing) },
        AchievementDefinition("streak_3", "On a Roll", "Learn 3 days in a row.", "local_fire_department", AchievementTier.BRONZE) { it.longestStreak to 3 },
        AchievementDefinition("streak_7", "Week Warrior", "Learn 7 days in a row.", "whatshot", AchievementTier.SILVER) { it.longestStreak to 7 },
        AchievementDefinition("streak_30", "Unstoppable", "Learn 30 days in a row.", "bolt", AchievementTier.GOLD) { it.longestStreak to 30 },
        AchievementDefinition("xp_500", "XP Collector", "Earn 500 XP.", "star", AchievementTier.BRONZE) { it.totalXp to 500 },
        AchievementDefinition("xp_5000", "XP Hoarder", "Earn 5,000 XP.", "stars", AchievementTier.SILVER) { it.totalXp to 5000 },
        AchievementDefinition("xp_20000", "XP Legend", "Earn 20,000 XP.", "military_tech", AchievementTier.PLATINUM) { it.totalXp to 20000 },
        AchievementDefinition("module_1", "Module Master", "Complete an entire module.", "inventory", AchievementTier.BRONZE) { it.modulesCompleted to 1 },
        AchievementDefinition("module_10", "Curriculum Climber", "Complete 10 modules.", "stairs", AchievementTier.SILVER) { it.modulesCompleted to 10 },
        AchievementDefinition("dart_done", "Dart Graduate", "Finish the complete Dart course.", "code", AchievementTier.GOLD) { flag(it.dartCourseComplete) },
        AchievementDefinition("flutter_done", "Flutter Graduate", "Finish the complete Flutter course.", "phone_android", AchievementTier.GOLD) { flag(it.flutterCourseComplete) },
        AchievementDefinition("project_1", "Builder", "Complete your first real-world project.", "construction", AchievementTier.BRONZE) { it.projectsCompleted to 1 },
        AchievementDefinition("projects_done", "Portfolio Ready", "Complete all real-world projects.", "work", AchievementTier.GOLD) { flag(it.projectsCourseComplete) },
        AchievementDefinition("challenge_5", "Problem Solver", "Solve 5 coding challenges.", "extension", AchievementTier.SILVER) { it.challengesCompleted to 5 },
        AchievementDefinition("final_exam", "Assessment Ace", "Pass the final assessment.", "fact_check", AchievementTier.PLATINUM) { flag(it.finalExamPassed) },
        AchievementDefinition("certified", "Certified Flutter Developer", "Earn your Bimo course-completion certificate.", "workspace_premium", AchievementTier.PLATINUM) { flag(it.certificateEarned) },
    )

    fun byId(id: String): AchievementDefinition? = all.firstOrNull { it.id == id }

    /** Achievements whose condition is met but which are not yet recorded as unlocked. */
    fun newlyUnlocked(stats: LearnerStats, alreadyUnlocked: Set<String>): List<AchievementDefinition> =
        all.filter { it.id !in alreadyUnlocked && it.isUnlocked(stats) }
}
