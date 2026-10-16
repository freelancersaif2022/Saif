package com.bimo.learnflutter.data.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Upsert
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
import kotlinx.coroutines.flow.Flow

@Dao
interface ProfileDao {
    @Query("SELECT * FROM user_profile WHERE id = 1")
    fun observe(): Flow<UserProfileEntity?>

    @Query("SELECT * FROM user_profile WHERE id = 1")
    suspend fun get(): UserProfileEntity?

    @Upsert
    suspend fun upsert(profile: UserProfileEntity)

    @Query("DELETE FROM user_profile")
    suspend fun clear()
}

@Dao
interface ProgressDao {
    @Query("SELECT * FROM lesson_progress")
    fun observeAll(): Flow<List<LessonProgressEntity>>

    @Query("SELECT lesson_id FROM lesson_progress WHERE completed_at IS NOT NULL")
    fun observeCompletedIds(): Flow<List<String>>

    @Query("SELECT lesson_id FROM lesson_progress WHERE completed_at IS NOT NULL")
    suspend fun completedIds(): List<String>

    @Query("SELECT * FROM lesson_progress WHERE lesson_id = :lessonId")
    suspend fun get(lessonId: String): LessonProgressEntity?

    @Query("SELECT * FROM lesson_progress WHERE lesson_id = :lessonId")
    fun observe(lessonId: String): Flow<LessonProgressEntity?>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertIfAbsent(entity: LessonProgressEntity): Long

    @Upsert
    suspend fun upsert(entity: LessonProgressEntity)

    @Query("UPDATE lesson_progress SET read_at = :readAt WHERE lesson_id = :lessonId AND read_at IS NULL")
    suspend fun markRead(lessonId: String, readAt: Long)

    @Query("SELECT COUNT(*) FROM lesson_progress WHERE completed_at >= :fromMillis AND completed_at < :toMillis")
    fun observeCompletedBetween(fromMillis: Long, toMillis: Long): Flow<Int>

    @Query("DELETE FROM lesson_progress")
    suspend fun clear()
}

@Dao
interface QuizDao {
    @Insert
    suspend fun insertAttempt(attempt: QuizAttemptEntity): Long

    @Insert
    suspend fun insertWrongAnswers(answers: List<WrongAnswerEntity>)

    @Query("SELECT * FROM quiz_attempt ORDER BY taken_at DESC")
    fun observeAttempts(): Flow<List<QuizAttemptEntity>>

    @Query("SELECT * FROM quiz_attempt WHERE id = :id")
    suspend fun attempt(id: Long): QuizAttemptEntity?

    @Query("SELECT * FROM quiz_attempt WHERE quiz_id = :quizId ORDER BY taken_at DESC")
    suspend fun attemptsFor(quizId: String): List<QuizAttemptEntity>

    @Query("SELECT * FROM wrong_answer WHERE attempt_id = :attemptId")
    suspend fun wrongAnswers(attemptId: Long): List<WrongAnswerEntity>

    /** Most recent wrong answers across all attempts, newest first. */
    @Query(
        """
        SELECT w.* FROM wrong_answer w
        JOIN quiz_attempt a ON a.id = w.attempt_id
        ORDER BY a.taken_at DESC
        LIMIT :limit
        """,
    )
    fun observeRecentWrongAnswers(limit: Int): Flow<List<WrongAnswerEntity>>

    @Query("SELECT COUNT(*) FROM quiz_attempt WHERE quiz_id = :quizId AND passed = 0")
    suspend fun failedCount(quizId: String): Int

    @Query("SELECT EXISTS(SELECT 1 FROM quiz_attempt a WHERE a.passed = 1 AND EXISTS(SELECT 1 FROM quiz_attempt b WHERE b.quiz_id = a.quiz_id AND b.passed = 0 AND b.taken_at < a.taken_at))")
    fun observeComebackExists(): Flow<Boolean>

    @Query("DELETE FROM quiz_attempt")
    suspend fun clear()
}

@Dao
interface XpDao {
    /** Returns -1 when the key already exists, i.e. the reward was already granted. */
    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(event: XpEventEntity): Long

    @Query("SELECT COALESCE(SUM(amount), 0) FROM xp_event")
    fun observeTotal(): Flow<Int>

    @Query("SELECT * FROM xp_event ORDER BY earned_at DESC LIMIT :limit")
    fun observeRecent(limit: Int): Flow<List<XpEventEntity>>

    @Query("SELECT key FROM xp_event WHERE key LIKE :prefix || '%'")
    suspend fun keysWithPrefix(prefix: String): List<String>

    @Query("DELETE FROM xp_event")
    suspend fun clear()
}

@Dao
interface ActivityDao {
    @Query("SELECT * FROM activity_day")
    fun observeAll(): Flow<List<ActivityDayEntity>>

    @Query("SELECT epoch_day FROM activity_day")
    suspend fun days(): List<Long>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insertIfAbsent(day: ActivityDayEntity): Long

    @Query("UPDATE activity_day SET lessons_completed = lessons_completed + :lessons, quizzes_taken = quizzes_taken + :quizzes WHERE epoch_day = :day")
    suspend fun increment(day: Long, lessons: Int, quizzes: Int)

    @Query("DELETE FROM activity_day")
    suspend fun clear()
}

@Dao
interface AchievementDao {
    @Query("SELECT * FROM achievement ORDER BY unlocked_at DESC")
    fun observeAll(): Flow<List<AchievementEntity>>

    @Query("SELECT id FROM achievement")
    suspend fun ids(): List<String>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(entity: AchievementEntity): Long

    @Query("UPDATE achievement SET seen = 1")
    suspend fun markAllSeen()

    @Query("DELETE FROM achievement")
    suspend fun clear()
}

@Dao
interface CertificateDao {
    @Query("SELECT * FROM certificate ORDER BY issued_at DESC")
    fun observeAll(): Flow<List<CertificateEntity>>

    @Query("SELECT * FROM certificate WHERE certificate_id = :id")
    suspend fun get(id: String): CertificateEntity?

    @Insert(onConflict = OnConflictStrategy.ABORT)
    suspend fun insert(entity: CertificateEntity)

    @Query("UPDATE certificate SET learner_name = :name")
    suspend fun renameAll(name: String)

    @Query("DELETE FROM certificate")
    suspend fun clear()
}

@Dao
interface EntitlementDao {
    @Query("SELECT * FROM premium_entitlement ORDER BY expiry_millis DESC")
    fun observeAll(): Flow<List<EntitlementEntity>>

    @Query("SELECT * FROM premium_entitlement ORDER BY expiry_millis DESC")
    suspend fun all(): List<EntitlementEntity>

    @Insert
    suspend fun insert(entity: EntitlementEntity): Long

    @Upsert
    suspend fun upsert(entity: EntitlementEntity)

    @Query("UPDATE premium_entitlement SET auto_renewing = 0 WHERE source = :source")
    suspend fun cancelAutoRenew(source: String)

    @Query("DELETE FROM premium_entitlement WHERE source = :source")
    suspend fun deleteBySource(source: String)
}

@Dao
interface ChallengeDao {
    @Query("SELECT * FROM challenge_progress")
    fun observeAll(): Flow<List<ChallengeProgressEntity>>

    @Insert(onConflict = OnConflictStrategy.IGNORE)
    suspend fun insert(entity: ChallengeProgressEntity): Long

    @Query("DELETE FROM challenge_progress")
    suspend fun clear()
}
