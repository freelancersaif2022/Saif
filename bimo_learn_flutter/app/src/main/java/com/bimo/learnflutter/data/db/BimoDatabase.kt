package com.bimo.learnflutter.data.db

import androidx.room.Database
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import com.bimo.learnflutter.data.db.dao.AchievementDao
import com.bimo.learnflutter.data.db.dao.ActivityDao
import com.bimo.learnflutter.data.db.dao.CertificateDao
import com.bimo.learnflutter.data.db.dao.ChallengeDao
import com.bimo.learnflutter.data.db.dao.EntitlementDao
import com.bimo.learnflutter.data.db.dao.ProfileDao
import com.bimo.learnflutter.data.db.dao.ProgressDao
import com.bimo.learnflutter.data.db.dao.QuizDao
import com.bimo.learnflutter.data.db.dao.XpDao
import com.bimo.learnflutter.data.db.entity.AchievementEntity
import com.bimo.learnflutter.data.db.entity.ActivityDayEntity
import com.bimo.learnflutter.data.db.entity.CertificateEntity
import com.bimo.learnflutter.data.db.entity.ChallengeProgressEntity
import com.bimo.learnflutter.data.db.entity.EntitlementEntity
import com.bimo.learnflutter.data.db.entity.LessonProgressEntity
import com.bimo.learnflutter.data.db.entity.QuizAttemptEntity
import com.bimo.learnflutter.data.db.entity.UserProfileEntity
import com.bimo.learnflutter.data.db.entity.WrongAnswerEntity
import com.bimo.learnflutter.data.db.entity.XpEventEntity

@Database(
    entities = [
        UserProfileEntity::class,
        LessonProgressEntity::class,
        QuizAttemptEntity::class,
        WrongAnswerEntity::class,
        XpEventEntity::class,
        ActivityDayEntity::class,
        AchievementEntity::class,
        CertificateEntity::class,
        EntitlementEntity::class,
        ChallengeProgressEntity::class,
    ],
    version = BimoDatabase.VERSION,
    exportSchema = true,
)
abstract class BimoDatabase : RoomDatabase() {
    abstract fun profileDao(): ProfileDao
    abstract fun progressDao(): ProgressDao
    abstract fun quizDao(): QuizDao
    abstract fun xpDao(): XpDao
    abstract fun activityDao(): ActivityDao
    abstract fun achievementDao(): AchievementDao
    abstract fun certificateDao(): CertificateDao
    abstract fun entitlementDao(): EntitlementDao
    abstract fun challengeDao(): ChallengeDao

    companion object {
        const val VERSION = 1
        const val NAME = "bimo.db"

        /**
         * Every schema change must bump [VERSION] and add a [Migration] here. Learner progress must
         * never be dropped, so destructive fallback is intentionally NOT enabled for upgrades.
         * Exported schemas are written to app/schemas for MigrationTestHelper-based tests.
         */
        val MIGRATIONS: Array<Migration> = emptyArray()
    }
}
