package com.bimo.learnflutter.ui.screens.quiz

import android.app.Activity
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.ads.AdsManager
import com.bimo.learnflutter.core.content.Question
import com.bimo.learnflutter.core.content.QuestionType
import com.bimo.learnflutter.core.domain.AchievementDefinition
import com.bimo.learnflutter.core.domain.AdPolicy
import com.bimo.learnflutter.core.domain.CertificateRules
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.core.domain.QuizAnswer
import com.bimo.learnflutter.core.domain.QuizGrader
import com.bimo.learnflutter.core.domain.QuizResult
import com.bimo.learnflutter.core.domain.XpAward
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.CertificateRepository
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.TimeProvider
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

enum class QuizMode { LESSON, PRACTICE, FINAL_EXAM }

/** A question prepared for display: choice options are shuffled, order items scrambled. */
data class PreparedQuestion(
    val question: Question,
    /** Display position -> index into question.options. */
    val optionOrder: List<Int>,
    /** Initial (scrambled) order for CODE_ORDER questions. */
    val scrambled: List<String>,
)

data class QuizOutcomeUi(
    val result: QuizResult,
    val attemptId: Long?,
    val firstCompletion: Boolean,
    val awards: List<XpAward>,
    val achievements: List<AchievementDefinition>,
    val nextLessonId: String?,
    val completedModuleTitle: String?,
    val courseCompleted: Boolean,
    val certificateIssued: Boolean,
)

sealed interface QuizUiState {
    data object Loading : QuizUiState
    data class Blocked(val title: String, val message: String) : QuizUiState
    data class Active(
        val mode: QuizMode,
        val title: String,
        val lessonId: String?,
        val courseId: String?,
        val questions: List<PreparedQuestion>,
        val index: Int = 0,
        val answers: Map<String, QuizAnswer> = emptyMap(),
        /** Ids of questions whose answer has been checked (feedback visible). */
        val checked: Set<String> = emptySet(),
        val submitting: Boolean = false,
    ) : QuizUiState {
        val current: PreparedQuestion get() = questions[index]
        val isLast: Boolean get() = index == questions.lastIndex
        val currentChecked: Boolean get() = current.question.id in checked
        val correctSoFar: Int get() = questions.count { it.question.id in checked && QuizGrader.isCorrect(it.question, answers[it.question.id]) }
    }
    data class Finished(
        val mode: QuizMode,
        val title: String,
        val lessonId: String?,
        val courseId: String?,
        val outcome: QuizOutcomeUi,
        val durationSeconds: Int,
        val rewardedAvailable: Boolean = false,
        val rewardedBonus: XpAward? = null,
        val rewardMessage: String? = null,
    ) : QuizUiState
}

@HiltViewModel
class QuizViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val curriculumRepository: CurriculumRepository,
    private val learning: LearningRepository,
    private val certificates: CertificateRepository,
    private val premium: PremiumRepository,
    private val settings: SettingsDataStore,
    private val ads: AdsManager,
    private val time: TimeProvider,
) : ViewModel() {
    private val mode: QuizMode = runCatching { QuizMode.valueOf(savedStateHandle.get<String>("mode") ?: "") }.getOrDefault(QuizMode.LESSON)
    private val id: String = savedStateHandle.get<String>("id") ?: ""
    private val _state = MutableStateFlow<QuizUiState>(QuizUiState.Loading)
    val state: StateFlow<QuizUiState> = _state.asStateFlow()
    private var startedAt = 0L
    private var interstitialHandled = false

    init {
        load()
    }

    private fun load() {
        viewModelScope.launch {
            val curriculum = curriculumRepository.curriculum()
            val completed = learning.completedLessonIds.first()
            when (mode) {
                QuizMode.FINAL_EXAM -> {
                    val exam = curriculum.finalExam
                    val eligibility = CertificateRules.evaluate(curriculum, completed, false)
                    _state.value = when {
                        exam == null -> QuizUiState.Blocked("Assessment unavailable", "The final assessment is missing from this build.")
                        !eligibility.finalExamUnlocked -> QuizUiState.Blocked(
                            "Final assessment locked",
                            "Complete every lesson in the Dart, Flutter and Projects courses to unlock the final assessment.",
                        )
                        else -> QuizUiState.Active(mode, "Final assessment", null, null, prepare(exam.questions))
                    }
                }
                else -> {
                    val lesson = curriculum.lesson(id)
                    _state.value = when {
                        lesson == null -> QuizUiState.Blocked("Quiz not found", "This quiz is not part of the curriculum.")
                        !ProgressionEngine.canOpen(lesson.id, curriculum, completed) -> QuizUiState.Blocked(
                            "Quiz locked",
                            ProgressionEngine.lockReason(lesson.id, curriculum, completed) ?: "Complete the previous lesson first.",
                        )
                        mode == QuizMode.LESSON && !learning.isLessonRead(lesson.id) -> QuizUiState.Blocked(
                            "Read the lesson first",
                            "Work through the lesson content, then start the quiz from the end of the lesson.",
                        )
                        else -> QuizUiState.Active(mode, lesson.title, lesson.id, lesson.courseId, prepare(lesson.quiz.questions))
                    }
                }
            }
            startedAt = time.nowMillis()
        }
    }

    private fun prepare(questions: List<Question>): List<PreparedQuestion> = questions.map { q ->
        val order = when {
            q.type == QuestionType.TRUE_FALSE -> q.options.indices.toList()
            q.isChoice -> q.options.indices.shuffled()
            else -> emptyList()
        }
        val scrambled = if (q.type == QuestionType.CODE_ORDER) {
            var s = q.orderedItems.shuffled()
            var guard = 0
            while (s == q.orderedItems && guard++ < 10) s = q.orderedItems.shuffled()
            s
        } else emptyList()
        PreparedQuestion(q, order, scrambled)
    }

    fun answer(answer: QuizAnswer) {
        _state.update { s ->
            if (s is QuizUiState.Active && !s.currentChecked) s.copy(answers = s.answers + (s.current.question.id to answer)) else s
        }
    }

    /** Shows feedback for the current question. Returns whether the answer was correct. */
    fun check(): Boolean {
        val s = _state.value as? QuizUiState.Active ?: return false
        val q = s.current.question
        _state.value = s.copy(checked = s.checked + q.id)
        return QuizGrader.isCorrect(q, s.answers[q.id])
    }

    fun next() {
        val s = _state.value as? QuizUiState.Active ?: return
        if (s.isLast) submit() else _state.value = s.copy(index = s.index + 1)
    }

    private fun submit() {
        val s = _state.value as? QuizUiState.Active ?: return
        if (s.submitting) return
        _state.value = s.copy(submitting = true)
        val duration = ((time.nowMillis() - startedAt) / 1000).toInt()
        viewModelScope.launch {
            val curriculum = curriculumRepository.curriculum()
            val outcome: QuizOutcomeUi = when (s.mode) {
                QuizMode.LESSON -> {
                    val lesson = curriculum.lesson(s.lessonId!!)!!
                    val o = learning.submitLessonQuiz(lesson, s.answers, duration)
                    QuizOutcomeUi(o.result, o.attemptId, o.firstCompletion, o.awarded, o.newAchievements,
                        o.nextLessonId, o.completedModuleTitle, o.courseCompleted, false)
                }
                QuizMode.PRACTICE -> {
                    val lesson = curriculum.lesson(s.lessonId!!)!!
                    val (result, attemptId) = learning.submitPracticeQuiz(lesson, s.answers, duration)
                    QuizOutcomeUi(result, attemptId, false, emptyList(), emptyList(),
                        ProgressionEngine.lessonAfter(lesson.id, curriculum)?.id, null, false, false)
                }
                QuizMode.FINAL_EXAM -> {
                    val (result, achievements) = learning.submitFinalExam(s.answers, duration)
                    val cert = if (result.passed) certificates.issueIfEligible() else null
                    QuizOutcomeUi(result, null, result.passed, emptyList(), achievements, null, null, false, cert != null)
                }
            }
            val rewardedAvailable = AdPolicy.rewardedAvailable(
                isPremium = premium.currentlyPremium(),
                adLoaded = ads.rewardedReady.value,
                rewardSlotFree = learning.rewardedBonusesLeftToday() > 0,
            ) && outcome.result.passed
            _state.value = QuizUiState.Finished(s.mode, s.title, s.lessonId, s.courseId, outcome, duration, rewardedAvailable)
        }
    }

    fun retry() {
        interstitialHandled = false
        _state.value = QuizUiState.Loading
        load()
    }

    /**
     * Called when the learner leaves the result screen. Shows an interstitial only when AdPolicy
     * allows it (never for premium, never for repeat completions, only if one is loaded), then
     * continues navigation whether or not an ad was shown.
     */
    fun continueAfterResult(activity: Activity?, navigate: () -> Unit) {
        val s = _state.value as? QuizUiState.Finished
        if (s == null || activity == null || interstitialHandled || s.mode == QuizMode.PRACTICE) {
            navigate(); return
        }
        interstitialHandled = true
        viewModelScope.launch {
            val prefs = settings.current()
            val now = time.nowMillis()
            val decision = AdPolicy.interstitialAfterLesson(
                isPremium = premium.currentlyPremium(),
                adLoaded = ads.interstitialReady.value,
                completionSaved = true,
                rewardsFinished = true,
                firstCompletion = s.outcome.firstCompletion && s.outcome.result.passed,
                lastInterstitialMillis = prefs.lastInterstitialMillis,
                nowMillis = now,
            )
            if (decision.show) {
                ads.showInterstitial(activity) { shown ->
                    if (shown) viewModelScope.launch { settings.setLastInterstitial(now) }
                    navigate()
                }
            } else {
                navigate()
            }
        }
    }

    /** Optional rewarded ad for bonus XP. XP is granted only from the SDK's reward callback. */
    fun watchRewarded(activity: Activity?) {
        if (_state.value !is QuizUiState.Finished || activity == null) return
        ads.showRewarded(
            activity,
            onReward = {
                viewModelScope.launch {
                    val award = learning.grantRewardedBonus()
                    _state.update { st ->
                        if (st is QuizUiState.Finished) st.copy(
                            rewardedAvailable = false,
                            rewardedBonus = award,
                            rewardMessage = if (award != null) "+${award.amount} bonus XP added!" else "Daily bonus limit reached.",
                        ) else st
                    }
                }
            },
            onClosed = { rewarded ->
                if (!rewarded) _state.update { st ->
                    if (st is QuizUiState.Finished) st.copy(rewardedAvailable = false, rewardMessage = "The ad was closed before the reward was earned.") else st
                }
            },
        )
    }
}
