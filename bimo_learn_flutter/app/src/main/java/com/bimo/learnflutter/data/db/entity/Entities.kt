package com.bimo.learnflutter.data.db.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

/** The single local learner profile (no account is required). */
@Entity(tableName = "user_profile")
data class UserProfileEntity(
    @PrimaryKey val id: Int = 1,
    val name: String,
    @ColumnInfo(name = "avatar_path") val avatarPath: String?,
    @ColumnInfo(name = "avatar_emoji") val avatarEmoji: String,
    /** BEGINNER, INTERMEDIATE or ADVANCED – chosen on the welcome screen. */
    @ColumnInfo(name = "experience_level") val experienceLevel: String,
    @ColumnInfo(name = "learning_goal") val learningGoal: String,
    @ColumnInfo(name = "daily_goal_lessons") val dailyGoalLessons: Int,
    @ColumnInfo(name = "created_at") val createdAt: Long,
)

/**
 * Progress for one curriculum lesson. Lesson text lives in assets; only ids are stored here.
 * A lesson is COMPLETED when [completedAt] is set, which requires [readAt] and a passed quiz.
 */
@Entity(
    tableName = "lesson_progress",
    indices = [Index("course_id"), Index("module_id"), Index("completed_at")],
)
data class LessonProgressEntity(
    @PrimaryKey @ColumnInfo(name = "lesson_id") val lessonId: String,
    @ColumnInfo(name = "course_id") val courseId: String,
    @ColumnInfo(name = "module_id") val moduleId: String,
    @ColumnInfo(name = "started_at") val startedAt: Long,
    @ColumnInfo(name = "read_at") val readAt: Long? = null,
    @ColumnInfo(name = "completed_at") val completedAt: Long? = null,
    @ColumnInfo(name = "best_score") val bestScore: Int = 0,
    @ColumnInfo(name = "attempts") val attempts: Int = 0,
)

@Entity(
    tableName = "quiz_attempt",
    indices = [Index("quiz_id"), Index("taken_at")],
)
data class QuizAttemptEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    @ColumnInfo(name = "quiz_id") val quizId: String,
    /** Lesson the quiz belongs to, or null for the final assessment. */
    @ColumnInfo(name = "lesson_id") val lessonId: String?,
    val title: String,
    val correct: Int,
    val total: Int,
    val percent: Int,
    val passed: Boolean,
    val perfect: Boolean,
    @ColumnInfo(name = "taken_at") val takenAt: Long,
    @ColumnInfo(name = "duration_seconds") val durationSeconds: Int,
)

/** One incorrectly answered question of an attempt, used by "Review incorrect answers". */
@Entity(
    tableName = "wrong_answer",
    foreignKeys = [
        ForeignKey(
            entity = QuizAttemptEntity::class,
            parentColumns = ["id"],
            childColumns = ["attempt_id"],
            onDelete = ForeignKey.CASCADE,
        ),
    ],
    indices = [Index("attempt_id"), Index("question_id")],
)
data class WrongAnswerEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    @ColumnInfo(name = "attempt_id") val attemptId: Long,
    @ColumnInfo(name = "question_id") val questionId: String,
    @ColumnInfo(name = "given_answer") val givenAnswer: String,
)

/** XP ledger. The primary key makes one-time rewards impossible to farm. */
@Entity(tableName = "xp_event", indices = [Index("earned_at")])
data class XpEventEntity(
    @PrimaryKey val key: String,
    val amount: Int,
    val reason: String,
    @ColumnInfo(name = "earned_at") val earnedAt: Long,
)

/** A day (epoch day, local time zone) on which the learner studied. Drives streaks and daily goals. */
@Entity(tableName = "activity_day")
data class ActivityDayEntity(
    @PrimaryKey @ColumnInfo(name = "epoch_day") val epochDay: Long,
    @ColumnInfo(name = "lessons_completed") val lessonsCompleted: Int = 0,
    @ColumnInfo(name = "quizzes_taken") val quizzesTaken: Int = 0,
)

@Entity(tableName = "achievement")
data class AchievementEntity(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "unlocked_at") val unlockedAt: Long,
    val seen: Boolean = false,
)

@Entity(tableName = "certificate")
data class CertificateEntity(
    @PrimaryKey @ColumnInfo(name = "certificate_id") val certificateId: String,
    @ColumnInfo(name = "learner_name") val learnerName: String,
    @ColumnInfo(name = "course_title") val courseTitle: String,
    @ColumnInfo(name = "issued_at") val issuedAt: Long,
    @ColumnInfo(name = "final_score") val finalScore: Int,
)

@Entity(tableName = "premium_entitlement", indices = [Index("expiry_millis")])
data class EntitlementEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    /** MOCK_SUBSCRIPTION, PLAY_SUBSCRIPTION or PROMO_TRIAL. */
    val source: String,
    val plan: String?,
    @ColumnInfo(name = "start_millis") val startMillis: Long,
    @ColumnInfo(name = "expiry_millis") val expiryMillis: Long,
    @ColumnInfo(name = "auto_renewing") val autoRenewing: Boolean,
    @ColumnInfo(name = "purchase_token") val purchaseToken: String? = null,
)

@Entity(tableName = "challenge_progress")
data class ChallengeProgressEntity(
    @PrimaryKey @ColumnInfo(name = "challenge_id") val challengeId: String,
    @ColumnInfo(name = "completed_at") val completedAt: Long,
)
