package com.bimo.learnflutter.data.repository

import androidx.room.withTransaction
import com.bimo.learnflutter.core.content.Curriculum
import com.bimo.learnflutter.core.content.Lesson
import com.bimo.learnflutter.core.content.Question
import com.bimo.learnflutter.core.content.Quiz
import com.bimo.learnflutter.core.domain.AchievementCatalog
import com.bimo.learnflutter.core.domain.AchievementDefinition
import com.bimo.learnflutter.core.domain.CertificateEligibility
import com.bimo.learnflutter.core.domain.CertificateRules
import com.bimo.learnflutter.core.domain.LearnerStats
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.core.domain.QuizAnswer
import com.bimo.learnflutter.core.domain.QuizGrader
import com.bimo.learnflutter.core.domain.QuizResult
import com.bimo.learnflutter.core.domain.StreakCalculator
import com.bimo.learnflutter.core.domain.StreakInfo
import com.bimo.learnflutter.core.domain.XpAward
import com.bimo.learnflutter.core.domain.XpRules
import com.bimo.learnflutter.data.db.BimoDatabase
import com.bimo.learnflutter.data.db.entity.AchievementEntity
import com.bimo.learnflutter.data.db.entity.ActivityDayEntity
import com.bimo.learnflutter.data.db.entity.ChallengeProgressEntity
import com.bimo.learnflutter.data.db.entity.LessonProgressEntity
import com.bimo.learnflutter.data.db.entity.QuizAttemptEntity
import com.bimo.learnflutter.data.db.entity.WrongAnswerEntity
import com.bimo.learnflutter.data.db.entity.XpEventEntity
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import java.time.LocalDate
import java.time.ZoneId
import javax.inject.Inject
import javax.inject.Singleton

/** Abstraction over the clock so time-dependent logic is testable. */
open class TimeProvider @Inject constructor() {
    open fun nowMillis(): Long = System.currentTimeMillis()
    open fun today(): LocalDate = LocalDate.now()
    fun todayEpochDay(): Long = today().toEpochDay()
    fun startOfDayMillis(day: LocalDate = today()): Long =
        day.atStartOfDay(ZoneId.systemDefault()).toInstant().toEpochMilli()
}

data class LessonQuizOutcome(
    val result: QuizResult,
    val attemptId: Long,
    val firstCompletion: Boolean,
    val awarded: List<XpAward>,
    val newAchievements: List<AchievementDefinition>,
    val nextLessonId: String?,
    val completedModuleTitle: String?,
    val courseCompleted: Boolean,
) {
    val xpEarned: Int get() = awarded.sumOf { it.amount }
}

data class ReviewItem(
    val attempt: QuizAttemptEntity,
    val question: Question,
    val givenAnswer: String,
)

@Singleton
class LearningRepository @Inject constructor(
    private val db: BimoDatabase,
    private val curriculumRepository: CurriculumRepository,
    private val settings: SettingsDataStore,
    private val time: TimeProvider,
) {
    private val progressDao = db.progressDao()
    private val quizDao = db.quizDao()
    private val xpDao = db.xpDao()
    private val activityDao = db.activityDao()
    private val achievementDao = db.achievementDao()
    private val challengeDao = db.challengeDao()
    private val certificateDao = db.certificateDao()

    // ------------------------------------------------------------------ observation

    val completedLessonIds: Flow<Set<String>> =
        progressDao.observeCompletedIds().map { it.toSet() }.distinctUntilChanged()

    val progressByLesson: Flow<Map<String, LessonProgressEntity>> =
        progressDao.observeAll().map { list -> list.associateBy { it.lessonId } }

    val totalXp: Flow<Int> = xpDao.observeTotal()
    val recentXp = xpDao.observeRecent(20)
    val attempts: Flow<List<QuizAttemptEntity>> = quizDao.observeAttempts()
    val achievements: Flow<List<AchievementEntity>> = achievementDao.observeAll()
    val completedChallenges: Flow<Set<String>> = challengeDao.observeAll().map { l -> l.map { it.challengeId }.toSet() }

    val streak: Flow<StreakInfo> = activityDao.observeAll().map { days ->
        StreakCalculator.compute(days.map { it.epochDay }.toSet(), time.todayEpochDay())
    }

    val activityDays: Flow<List<ActivityDayEntity>> = activityDao.observeAll()

    /** Lessons completed today (local time) – drives the daily goal ring. */
    val completedToday: Flow<Int> = activityDao.observeAll().map { days ->
        days.firstOrNull { it.epochDay == time.todayEpochDay() }?.lessonsCompleted ?: 0
    }

    val finalExamPassed: Flow<Boolean> = attempts.map { list ->
        list.any { it.lessonId == null && it.passed }
    }

    val certificateEligibility: Flow<CertificateEligibility> = combine(
        curriculumRepository.curriculumFlow, completedLessonIds, finalExamPassed,
    ) { curriculum, completed, examPassed ->
        CertificateRules.evaluate(curriculum, completed, examPassed)
    }

    val stats: Flow<LearnerStats> = combine(
        combine(curriculumRepository.curriculumFlow, completedLessonIds, attempts) { c, done, a -> Triple(c, done, a) },
        totalXp,
        streak,
        completedChallenges,
        combine(quizDao.observeComebackExists(), certificateDao.observeAll()) { comeback, certs -> comeback to certs.isNotEmpty() },
    ) { (curriculum, completed, attemptList), xp, streakInfo, challenges, (comeback, certified) ->
        buildStats(curriculum, completed, attemptList, xp, streakInfo, challenges.size, comeback, certified)
    }

    private fun buildStats(
        curriculum: Curriculum,
        completed: Set<String>,
        attemptList: List<QuizAttemptEntity>,
        xp: Int,
        streakInfo: StreakInfo,
        challenges: Int,
        comeback: Boolean,
        certified: Boolean,
    ): LearnerStats {
        val modules = curriculum.courses.flatMap { it.modules }
        fun courseDone(id: String) = curriculum.course(id)?.let { ProgressionEngine.isCourseComplete(it, completed) } ?: false
        return LearnerStats(
            lessonsCompleted = completed.size,
            quizzesPassed = attemptList.filter { it.passed }.map { it.quizId }.toSet().size,
            perfectQuizzes = attemptList.filter { it.perfect }.map { it.quizId }.toSet().size,
            quizAttempts = attemptList.size,
            currentStreak = streakInfo.current,
            longestStreak = streakInfo.longest,
            totalXp = xp,
            modulesCompleted = modules.count { m -> m.lessons.isNotEmpty() && m.lessons.all { it.id in completed } },
            projectsCompleted = curriculum.lessons.count { it.isProject && it.id in completed },
            challengesCompleted = challenges,
            dartCourseComplete = courseDone("dart"),
            flutterCourseComplete = courseDone("flutter"),
            projectsCourseComplete = courseDone("projects"),
            finalExamPassed = attemptList.any { it.lessonId == null && it.passed },
            certificateEarned = certified,
            retriedAfterFailing = comeback,
        )
    }

    fun observeLessonProgress(lessonId: String): Flow<LessonProgressEntity?> = progressDao.observe(lessonId)

    // ------------------------------------------------------------------ mutations

    /** Records that a lesson was opened. Refuses (returns false) if progression rules lock it. */
    suspend fun openLesson(lesson: Lesson): Boolean {
        val curriculum = curriculumRepository.curriculum()
        val completed = progressDao.completedIds().toSet()
        if (!ProgressionEngine.canOpen(lesson.id, curriculum, completed)) return false
        progressDao.insertIfAbsent(
            LessonProgressEntity(lesson.id, lesson.courseId, lesson.moduleId, startedAt = time.nowMillis()),
        )
        settings.setLastOpenedLesson(lesson.id)
        return true
    }

    /** The learner reached the end of the lesson content; required before the quiz can complete it. */
    suspend fun markLessonRead(lesson: Lesson) {
        db.withTransaction {
            progressDao.insertIfAbsent(
                LessonProgressEntity(lesson.id, lesson.courseId, lesson.moduleId, startedAt = time.nowMillis()),
            )
            progressDao.markRead(lesson.id, time.nowMillis())
            touchActivity(lessons = 0, quizzes = 0)
        }
    }

    suspend fun isLessonRead(lessonId: String): Boolean = progressDao.get(lessonId)?.readAt != null

    /**
     * Grades a lesson quiz and, if it passed, completes the lesson, grants XP (idempotently)
     * and evaluates achievements. Everything is persisted in one transaction *before* the
     * caller shows any celebration or advertisement.
     */
    suspend fun submitLessonQuiz(
        lesson: Lesson,
        answers: Map<String, QuizAnswer>,
        durationSeconds: Int,
    ): LessonQuizOutcome {
        val curriculum = curriculumRepository.curriculum()
        val result = QuizGrader.grade(lesson.quiz, answers)
        val now = time.nowMillis()
        val today = time.todayEpochDay()

        val outcome = db.withTransaction {
            val attemptId = recordAttempt(lesson.quiz, lesson.id, lesson.title, result, answers, durationSeconds)
            val existing = progressDao.get(lesson.id)
                ?: LessonProgressEntity(lesson.id, lesson.courseId, lesson.moduleId, startedAt = now)
            val wasCompleted = existing.completedAt != null
            val canComplete = result.passed && existing.readAt != null
            val firstCompletion = canComplete && !wasCompleted
            progressDao.upsert(
                existing.copy(
                    readAt = existing.readAt,
                    completedAt = existing.completedAt ?: if (canComplete) now else null,
                    bestScore = maxOf(existing.bestScore, result.percent),
                    attempts = existing.attempts + 1,
                ),
            )
            touchActivity(lessons = if (firstCompletion) 1 else 0, quizzes = 1)

            val completed = progressDao.completedIds().toSet()
            val module = curriculum.module(lesson.moduleId)
            val moduleJustCompleted = module != null && firstCompletion &&
                ProgressionEngine.moduleProgress(module, completed).isComplete
            val course = curriculum.course(lesson.courseId)
            val courseJustCompleted = course != null && firstCompletion &&
                ProgressionEngine.isCourseComplete(course, completed)

            val candidates = if (canComplete) {
                XpRules.awardsForPassedLesson(
                    lessonId = lesson.id,
                    lessonTitle = lesson.title,
                    isProject = lesson.isProject,
                    quiz = result,
                    completedModule = if (moduleJustCompleted) module!!.id to module.title else null,
                    epochDay = today,
                )
            } else emptyList()
            val granted = grant(candidates, now)
            LessonQuizOutcome(
                result = result,
                attemptId = attemptId,
                firstCompletion = firstCompletion,
                awarded = granted,
                newAchievements = emptyList(),
                nextLessonId = if (canComplete) ProgressionEngine.lessonAfter(lesson.id, curriculum)?.id else null,
                completedModuleTitle = if (moduleJustCompleted) module!!.title else null,
                courseCompleted = courseJustCompleted,
            )
        }
        return outcome.copy(newAchievements = evaluateAchievements())
    }

    /** Completes a lesson that has no quiz (requires that the content was read). */
    suspend fun completeLessonWithoutQuiz(lesson: Lesson): LessonQuizOutcome? {
        if (lesson.quiz.questions.isNotEmpty()) return null
        val curriculum = curriculumRepository.curriculum()
        val now = time.nowMillis()
        val outcome = db.withTransaction {
            val existing = progressDao.get(lesson.id)
                ?: LessonProgressEntity(lesson.id, lesson.courseId, lesson.moduleId, startedAt = now)
            val firstCompletion = existing.completedAt == null
            progressDao.upsert(existing.copy(readAt = existing.readAt ?: now, completedAt = existing.completedAt ?: now, bestScore = 100))
            touchActivity(lessons = if (firstCompletion) 1 else 0, quizzes = 0)
            val completed = progressDao.completedIds().toSet()
            val module = curriculum.module(lesson.moduleId)
            val moduleDone = module != null && firstCompletion && ProgressionEngine.moduleProgress(module, completed).isComplete
            val course = curriculum.course(lesson.courseId)
            val awards = buildList {
                add(XpAward(XpRules.lessonKey(lesson.id), XpRules.LESSON_COMPLETE, "Completed “${lesson.title}”"))
                if (lesson.isProject) add(XpAward(XpRules.projectKey(lesson.id), XpRules.PROJECT_COMPLETE, "Project completed"))
                if (moduleDone) add(XpAward(XpRules.moduleKey(module!!.id), XpRules.MODULE_COMPLETE, "Module completed: ${module.title}"))
                add(XpAward(XpRules.dailyKey(time.todayEpochDay()), XpRules.DAILY_ACTIVITY, "Daily learning activity"))
            }
            LessonQuizOutcome(
                result = QuizResult(lesson.quiz.id, 0, 0, QuizGrader.DEFAULT_PASS_PERCENT, emptyList()),
                attemptId = -1,
                firstCompletion = firstCompletion,
                awarded = grant(awards, now),
                newAchievements = emptyList(),
                nextLessonId = ProgressionEngine.lessonAfter(lesson.id, curriculum)?.id,
                completedModuleTitle = if (moduleDone) module!!.title else null,
                courseCompleted = course != null && firstCompletion && ProgressionEngine.isCourseComplete(course, completed),
            )
        }
        return outcome.copy(newAchievements = evaluateAchievements())
    }

    /** Practice re-take of an already completed lesson's quiz: recorded in history, no completion logic. */
    suspend fun submitPracticeQuiz(lesson: Lesson, answers: Map<String, QuizAnswer>, durationSeconds: Int): Pair<QuizResult, Long> {
        val result = QuizGrader.grade(lesson.quiz, answers)
        val id = db.withTransaction {
            val attemptId = recordAttempt(lesson.quiz, lesson.id, lesson.title, result, answers, durationSeconds)
            touchActivity(0, 1)
            attemptId
        }
        evaluateAchievements()
        return result to id
    }

    suspend fun submitFinalExam(answers: Map<String, QuizAnswer>, durationSeconds: Int): Pair<QuizResult, List<AchievementDefinition>> {
        val curriculum = curriculumRepository.curriculum()
        val exam = curriculum.finalExam ?: error("Final assessment is missing from the curriculum")
        val completed = progressDao.completedIds().toSet()
        check(CertificateRules.evaluate(curriculum, completed, false).finalExamUnlocked) {
            "The final assessment is locked until every course is complete."
        }
        val result = QuizGrader.grade(exam, answers)
        db.withTransaction {
            recordAttempt(exam, null, "Final assessment", result, answers, durationSeconds)
            touchActivity(0, 1)
            if (result.passed) {
                grant(listOf(XpAward(XpRules.FINAL_EXAM_KEY, XpRules.FINAL_EXAM_PASSED, "Passed the final assessment")), time.nowMillis())
            }
        }
        return result to evaluateAchievements()
    }

    suspend fun bestFinalExamPercent(): Int? {
        val examId = curriculumRepository.curriculum().finalExam?.id ?: return null
        return quizDao.attemptsFor(examId).filter { it.passed }.maxOfOrNull { it.percent }
    }

    /** Bonus XP for watching a rewarded ad, limited per day. Returns the award or null if capped. */
    suspend fun grantRewardedBonus(): XpAward? {
        val today = time.todayEpochDay()
        val existing = xpDao.keysWithPrefix("rewarded:$today:").toSet()
        val key = XpRules.nextRewardedKey(existing, today) ?: return null
        val award = XpAward(key, XpRules.REWARDED_AD_BONUS, "Rewarded bonus")
        val granted = grant(listOf(award), time.nowMillis())
        evaluateAchievements()
        return granted.firstOrNull()
    }

    suspend fun rewardedBonusesLeftToday(): Int {
        val today = time.todayEpochDay()
        return XpRules.MAX_REWARDED_BONUSES_PER_DAY - xpDao.keysWithPrefix("rewarded:$today:").size
    }

    suspend fun completeChallenge(challengeId: String): XpAward? {
        val inserted = challengeDao.insert(ChallengeProgressEntity(challengeId, time.nowMillis()))
        if (inserted == -1L) return null
        val granted = grant(
            listOf(XpAward(XpRules.challengeKey(challengeId), XpRules.CHALLENGE_COMPLETE, "Coding challenge solved")),
            time.nowMillis(),
        )
        touchActivity(0, 0)
        evaluateAchievements()
        return granted.firstOrNull()
    }

    suspend fun reviewItems(attemptId: Long): List<ReviewItem> {
        val attempt = quizDao.attempt(attemptId) ?: return emptyList()
        val curriculum = curriculumRepository.curriculum()
        val quiz = attempt.lessonId?.let { curriculum.lesson(it)?.quiz } ?: curriculum.finalExam
        val byId = quiz?.questions?.associateBy { it.id } ?: return emptyList()
        return quizDao.wrongAnswers(attemptId).mapNotNull { wrong ->
            byId[wrong.questionId]?.let { ReviewItem(attempt, it, wrong.givenAnswer) }
        }
    }

    /** Recent wrong answers across all quizzes (Practice ▸ Review mistakes). */
    fun recentMistakes(limit: Int = 40): Flow<List<ReviewItem>> =
        combine(quizDao.observeRecentWrongAnswers(limit), attempts, curriculumRepository.curriculumFlow) { wrongs, attemptList, curriculum ->
            val attemptsById = attemptList.associateBy { it.id }
            wrongs.mapNotNull { wrong ->
                val attempt = attemptsById[wrong.attemptId] ?: return@mapNotNull null
                val quiz = attempt.lessonId?.let { curriculum.lesson(it)?.quiz } ?: curriculum.finalExam
                val question = quiz?.questions?.firstOrNull { it.id == wrong.questionId } ?: return@mapNotNull null
                ReviewItem(attempt, question, wrong.givenAnswer)
            }.distinctBy { it.question.id }
        }

    suspend fun markAchievementsSeen() = achievementDao.markAllSeen()

    /** Deletes learning progress but keeps the profile, settings and premium entitlements. */
    suspend fun resetProgress() {
        db.withTransaction {
            progressDao.clear()
            quizDao.clear()
            xpDao.clear()
            activityDao.clear()
            achievementDao.clear()
            challengeDao.clear()
            certificateDao.clear()
        }
        settings.resetLearningState()
    }

    // ------------------------------------------------------------------ helpers

    private suspend fun recordAttempt(
        quiz: Quiz,
        lessonId: String?,
        title: String,
        result: QuizResult,
        answers: Map<String, QuizAnswer>,
        durationSeconds: Int,
    ): Long {
        val attemptId = quizDao.insertAttempt(
            QuizAttemptEntity(
                quizId = quiz.id,
                lessonId = lessonId,
                title = title,
                correct = result.correct,
                total = result.total,
                percent = result.percent,
                passed = result.passed,
                perfect = result.perfect,
                takenAt = time.nowMillis(),
                durationSeconds = durationSeconds,
            ),
        )
        val questions = quiz.questions.associateBy { it.id }
        val wrong = result.wrongQuestionIds.map { id ->
            WrongAnswerEntity(
                attemptId = attemptId,
                questionId = id,
                givenAnswer = describe(questions[id], answers[id]),
            )
        }
        if (wrong.isNotEmpty()) quizDao.insertWrongAnswers(wrong)
        return attemptId
    }

    private fun describe(question: Question?, answer: QuizAnswer?): String = when (answer) {
        null -> "(no answer)"
        is QuizAnswer.Choice -> question?.options?.getOrNull(answer.index) ?: "(no answer)"
        is QuizAnswer.Text -> answer.value.ifBlank { "(empty)" }
        is QuizAnswer.Order -> answer.items.joinToString("\n")
    }

    private suspend fun touchActivity(lessons: Int, quizzes: Int) {
        val day = time.todayEpochDay()
        activityDao.insertIfAbsent(ActivityDayEntity(day))
        if (lessons != 0 || quizzes != 0) activityDao.increment(day, lessons, quizzes)
    }

    /** Inserts awards into the ledger and returns only those that were not granted before. */
    private suspend fun grant(awards: List<XpAward>, now: Long): List<XpAward> =
        awards.filter { award ->
            xpDao.insert(XpEventEntity(award.key, award.amount, award.reason, now)) != -1L
        }

    private suspend fun evaluateAchievements(): List<AchievementDefinition> {
        val stats = stats.first()
        val unlocked = achievementDao.ids().toSet()
        val fresh = AchievementCatalog.newlyUnlocked(stats, unlocked)
        val now = time.nowMillis()
        return fresh.filter { achievementDao.insert(AchievementEntity(it.id, now)) != -1L }
    }
}
