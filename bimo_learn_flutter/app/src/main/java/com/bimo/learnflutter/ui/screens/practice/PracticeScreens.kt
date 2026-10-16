package com.bimo.learnflutter.ui.screens.practice

import android.app.Activity
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Extension
import androidx.compose.material.icons.filled.History
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.OndemandVideo
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.material.icons.filled.RateReview
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.automirrored.filled.TrendingUp
import androidx.compose.material.icons.outlined.Inbox
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.ads.AdsManager
import com.bimo.learnflutter.core.content.Challenge
import com.bimo.learnflutter.core.content.Lesson
import com.bimo.learnflutter.core.domain.AdPolicy
import com.bimo.learnflutter.data.db.entity.QuizAttemptEntity
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.CurriculumState
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.ReviewItem
import com.bimo.learnflutter.ui.components.CodeBlock
import com.bimo.learnflutter.ui.components.EmptyState
import com.bimo.learnflutter.ui.components.LessonBlock
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.PremiumBadge
import com.bimo.learnflutter.ui.components.SectionHeader
import com.bimo.learnflutter.ui.components.StatTile
import com.bimo.learnflutter.ui.components.findActivity
import com.bimo.learnflutter.ui.components.formatDateTime
import com.bimo.learnflutter.ui.components.formatDuration
import com.bimo.learnflutter.ui.components.inlineMarkdown
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.quiz.QuizMode
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

// ------------------------------------------------------------------ Practice hub

data class PracticeUiState(
    val loading: Boolean = true,
    val practiceQuizzes: List<Lesson> = emptyList(),
    val challenges: List<Challenge> = emptyList(),
    val solvedChallenges: Set<String> = emptySet(),
    val unlockedChallenges: Set<String> = emptySet(),
    val attempts: List<QuizAttemptEntity> = emptyList(),
    val mistakesCount: Int = 0,
    val isPremium: Boolean = false,
    val rewardedReady: Boolean = false,
    val message: String? = null,
) {
    val averageScore: Int get() = if (attempts.isEmpty()) 0 else attempts.sumOf { it.percent } / attempts.size
    val passRate: Int get() = if (attempts.isEmpty()) 0 else attempts.count { it.passed } * 100 / attempts.size
    val totalPracticeSeconds: Int get() = attempts.sumOf { it.durationSeconds }
}

@HiltViewModel
class PracticeViewModel @Inject constructor(
    curriculumRepository: CurriculumRepository,
    private val learning: LearningRepository,
    premium: PremiumRepository,
    private val settings: SettingsDataStore,
    private val ads: AdsManager,
) : ViewModel() {
    private val message = MutableStateFlow<String?>(null)

    val state: StateFlow<PracticeUiState> = combine(
        combine(curriculumRepository.state, learning.completedLessonIds) { cs, done -> cs to done },
        combine(learning.completedChallenges, settings.settings) { solved, prefs -> solved to prefs.rewardUnlockedChallenges },
        combine(learning.attempts, learning.recentMistakes()) { a, m -> a to m.size },
        combine(premium.isPremium, ads.rewardedReady) { p, r -> p to r },
        message,
    ) { (cs, done), (solved, unlocked), (attempts, mistakes), (isPremium, rewarded), msg ->
        val ready = cs as? CurriculumState.Ready
        PracticeUiState(
            loading = ready == null,
            practiceQuizzes = ready?.curriculum?.lessons?.filter { it.id in done }?.reversed().orEmpty(),
            challenges = ready?.challenges.orEmpty(),
            solvedChallenges = solved,
            unlockedChallenges = unlocked,
            attempts = attempts,
            mistakesCount = mistakes,
            isPremium = isPremium,
            rewardedReady = rewarded,
            message = msg,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), PracticeUiState())

    fun watchForBonus(activity: Activity?) {
        activity ?: return
        viewModelScope.launch {
            if (learning.rewardedBonusesLeftToday() <= 0) {
                message.value = "You've collected today's bonus XP. Come back tomorrow!"
                return@launch
            }
            ads.showRewarded(
                activity,
                onReward = {
                    viewModelScope.launch {
                        val award = learning.grantRewardedBonus()
                        message.value = if (award != null) "+${award.amount} bonus XP added!" else "Daily bonus limit reached."
                    }
                },
                onClosed = { earned -> if (!earned) message.value = "Ad closed before the reward was earned." },
            )
        }
    }

    fun clearMessage() { message.value = null }
}

@Composable
fun PracticeScreen(navigator: BimoNavigator, viewModel: PracticeViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val activity = LocalContext.current.findActivity()
    if (state.loading) { ListSkeleton(); return }

    LazyColumn(
        Modifier.fillMaxSize().statusBarsPadding(),
        contentPadding = PaddingValues(20.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp),
    ) {
        item { Text("Practice", style = MaterialTheme.typography.headlineMedium) }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                StatTile("Quiz attempts", "${state.attempts.size}", Icons.Filled.Quiz, MaterialTheme.colorScheme.primary, Modifier.weight(1f))
                StatTile("Average", "${state.averageScore}%", Icons.AutoMirrored.Filled.TrendingUp, BimoColors.Success, Modifier.weight(1f))
                StatTile("Pass rate", "${state.passRate}%", Icons.Filled.CheckCircle, MaterialTheme.colorScheme.secondary, Modifier.weight(1f))
            }
        }
        item {
            Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                ActionCard("Quiz history", "${state.attempts.size} attempts", Icons.Filled.History, Modifier.weight(1f)) {
                    navigator.to(Routes.HISTORY)
                }
                ActionCard("Review mistakes", "${state.mistakesCount} to review", Icons.Filled.RateReview, Modifier.weight(1f)) {
                    navigator.to(Routes.MISTAKES)
                }
            }
        }
        if (!state.isPremium) {
            item {
                Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.tertiaryContainer, modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(16.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.Star, null, tint = BimoColors.Gold)
                            Spacer(Modifier.width(8.dp))
                            Text("Daily bonus XP", style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.onTertiaryContainer)
                        }
                        Text(
                            "Optionally watch a short ad to earn +15 XP (up to 3 times a day).",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onTertiaryContainer,
                        )
                        Spacer(Modifier.height(8.dp))
                        OutlinedButton(onClick = { viewModel.watchForBonus(activity) }, enabled = state.rewardedReady) {
                            Icon(Icons.Filled.OndemandVideo, null)
                            Spacer(Modifier.width(6.dp))
                            Text(if (state.rewardedReady) "Watch ad" else "No ad available right now")
                        }
                    }
                }
            }
        }
        state.message?.let { msg ->
            item {
                Surface(shape = RoundedCornerShape(14.dp), color = MaterialTheme.colorScheme.primaryContainer, modifier = Modifier.fillMaxWidth().clickable { viewModel.clearMessage() }) {
                    Text(msg, Modifier.padding(14.dp), color = MaterialTheme.colorScheme.onPrimaryContainer)
                }
            }
        }
        item { SectionHeader("Coding challenges") }
        items(state.challenges, key = { "c-" + it.id }) { challenge ->
            val locked = challenge.premium && !state.isPremium && challenge.id !in state.unlockedChallenges
            ChallengeRow(challenge, challenge.id in state.solvedChallenges, locked) { navigator.to(Routes.challenge(challenge.id)) }
        }
        item { SectionHeader("Practice quizzes") }
        if (state.practiceQuizzes.isEmpty()) {
            item {
                EmptyState(
                    Icons.Outlined.Inbox,
                    "No practice quizzes yet",
                    "Complete a lesson and its quiz becomes available here for unlimited practice.",
                    actionLabel = "Go to courses",
                    onAction = { navigator.tab(Routes.COURSES) },
                )
            }
        } else {
            items(state.practiceQuizzes.take(60), key = { "q-" + it.id }) { lesson ->
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = MaterialTheme.colorScheme.surface,
                    modifier = Modifier.fillMaxWidth().clickable { navigator.to(Routes.quiz(QuizMode.PRACTICE, lesson.id)) },
                ) {
                    Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.Quiz, null, tint = MaterialTheme.colorScheme.primary)
                        Spacer(Modifier.width(12.dp))
                        Column(Modifier.weight(1f)) {
                            Text(lesson.title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                            Text("${lesson.quiz.questions.size} questions", style = MaterialTheme.typography.bodySmall)
                        }
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, null)
                    }
                }
            }
        }
    }
}

@Composable
private fun ActionCard(title: String, subtitle: String, icon: ImageVector, modifier: Modifier, onClick: () -> Unit) {
    Surface(modifier.clickable(onClick = onClick), shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.secondaryContainer) {
        Column(Modifier.padding(16.dp)) {
            Icon(icon, null, tint = MaterialTheme.colorScheme.secondary)
            Spacer(Modifier.height(8.dp))
            Text(title, style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.onSecondaryContainer)
            Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSecondaryContainer)
        }
    }
}

@Composable
private fun ChallengeRow(challenge: Challenge, solved: Boolean, locked: Boolean, onClick: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 1.dp,
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
    ) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(40.dp).clip(RoundedCornerShape(12.dp))
                    .background(if (solved) BimoColors.Success else MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Icon(
                    when { solved -> Icons.Filled.CheckCircle; locked -> Icons.Filled.Lock; else -> Icons.Filled.Extension },
                    null,
                    tint = if (solved) Color.White else MaterialTheme.colorScheme.primary,
                )
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(challenge.title, style = MaterialTheme.typography.titleSmall)
                Text(challenge.difficulty, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            if (challenge.premium) PremiumBadge(label = "PRO")
        }
    }
}

// ------------------------------------------------------------------ Quiz history

@HiltViewModel
class HistoryViewModel @Inject constructor(learning: LearningRepository) : ViewModel() {
    val attempts: StateFlow<List<QuizAttemptEntity>?> =
        learning.attempts.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)
}

@Composable
fun HistoryScreen(navigator: BimoNavigator, viewModel: HistoryViewModel = hiltViewModel()) {
    val attempts by viewModel.attempts.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar("Quiz history", navigator)
        val list = attempts
        when {
            list == null -> ListSkeleton()
            list.isEmpty() -> EmptyState(Icons.Filled.History, "No attempts yet", "Your quiz attempts will appear here.")
            else -> LazyColumn(
                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 24.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp),
                modifier = Modifier.navigationBarsPadding(),
            ) {
                items(list, key = { it.id }) { a ->
                    Surface(
                        shape = RoundedCornerShape(16.dp),
                        color = MaterialTheme.colorScheme.surface,
                        modifier = Modifier.fillMaxWidth().clickable(enabled = !a.perfect) { navigator.to(Routes.review(a.id)) },
                    ) {
                        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                            Icon(
                                if (a.passed) Icons.Filled.CheckCircle else Icons.Filled.Cancel, null,
                                tint = if (a.passed) BimoColors.Success else BimoColors.Error,
                            )
                            Spacer(Modifier.width(12.dp))
                            Column(Modifier.weight(1f)) {
                                Text(a.title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                Text(
                                    "${formatDateTime(a.takenAt)} • ${formatDuration(a.durationSeconds)}",
                                    style = MaterialTheme.typography.bodySmall,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                )
                            }
                            Column(horizontalAlignment = Alignment.End) {
                                Text("${a.percent}%", style = MaterialTheme.typography.titleMedium)
                                Text("${a.correct}/${a.total}", style = MaterialTheme.typography.labelSmall)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun TopBar(title: String, navigator: BimoNavigator, actions: @Composable () -> Unit = {}) {
    Row(Modifier.fillMaxWidth().padding(horizontal = 4.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
        IconButton(onClick = navigator::back) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back") }
        Text(title, style = MaterialTheme.typography.titleLarge, modifier = Modifier.weight(1f))
        actions()
    }
}

// ------------------------------------------------------------------ Review incorrect answers

@HiltViewModel
class ReviewViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    learning: LearningRepository,
) : ViewModel() {
    private val attemptId: Long = savedStateHandle.get<Long>("attemptId") ?: -1L
    val isMistakeBank = attemptId < 0
    private val single = MutableStateFlow<List<ReviewItem>?>(null)

    val items: StateFlow<List<ReviewItem>?> =
        (if (isMistakeBank) learning.recentMistakes() else single)
            .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    init {
        if (!isMistakeBank) viewModelScope.launch { single.value = learning.reviewItems(attemptId) }
    }
}

@Composable
fun ReviewScreen(navigator: BimoNavigator, viewModel: ReviewViewModel = hiltViewModel()) {
    val items by viewModel.items.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar(if (viewModel.isMistakeBank) "Review mistakes" else "Incorrect answers", navigator)
        val list = items
        when {
            list == null -> ListSkeleton()
            list.isEmpty() -> EmptyState(Icons.Filled.CheckCircle, "Nothing to review", "No incorrect answers here. Great job!")
            else -> LazyColumn(
                contentPadding = PaddingValues(start = 16.dp, end = 16.dp, bottom = 24.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                modifier = Modifier.navigationBarsPadding(),
            ) {
                items(list, key = { it.attempt.id.toString() + it.question.id }) { item ->
                    Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
                        Column(Modifier.fillMaxWidth().padding(16.dp), verticalArrangement = Arrangement.spacedBy(8.dp)) {
                            Text(item.attempt.title, style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.primary)
                            Text(inlineMarkdown(item.question.prompt), style = MaterialTheme.typography.titleMedium)
                            item.question.code?.let { CodeBlock(it, "dart") }
                            Row(verticalAlignment = Alignment.Top) {
                                Icon(Icons.Filled.Cancel, null, tint = BimoColors.Error, modifier = Modifier.size(18.dp))
                                Spacer(Modifier.width(6.dp))
                                Text("Your answer: ${item.givenAnswer}", style = MaterialTheme.typography.bodyMedium)
                            }
                            Row(verticalAlignment = Alignment.Top) {
                                Icon(Icons.Filled.CheckCircle, null, tint = BimoColors.Success, modifier = Modifier.size(18.dp))
                                Spacer(Modifier.width(6.dp))
                                Text("Correct: ${item.question.correctAnswerText}", style = MaterialTheme.typography.bodyMedium)
                            }
                            Text(inlineMarkdown(item.question.explanation), style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                            item.attempt.lessonId?.let { lessonId ->
                                TextButton(onClick = { navigator.to(Routes.lesson(lessonId)) }) { Text("Revisit lesson") }
                            }
                        }
                    }
                }
            }
        }
    }
}

// ------------------------------------------------------------------ Challenge detail

data class ChallengeUiState(
    val challenge: Challenge? = null,
    val solved: Boolean = false,
    val locked: Boolean = false,
    val rewardedReady: Boolean = false,
    val loading: Boolean = true,
)

@HiltViewModel
class ChallengeViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    curriculumRepository: CurriculumRepository,
    private val learning: LearningRepository,
    premium: PremiumRepository,
    private val settings: SettingsDataStore,
    private val ads: AdsManager,
) : ViewModel() {
    private val challengeId: String = savedStateHandle.get<String>("challengeId") ?: ""

    val state: StateFlow<ChallengeUiState> = combine(
        curriculumRepository.state,
        learning.completedChallenges,
        premium.isPremium,
        settings.settings,
        ads.rewardedReady,
    ) { cs, solved, isPremium, prefs, rewarded ->
        val challenge = (cs as? CurriculumState.Ready)?.challenges?.firstOrNull { it.id == challengeId }
        ChallengeUiState(
            challenge = challenge,
            solved = challengeId in solved,
            locked = challenge != null && challenge.premium && !isPremium && challengeId !in prefs.rewardUnlockedChallenges,
            rewardedReady = AdPolicy.rewardedAvailable(isPremium, rewarded, true),
            loading = cs !is CurriculumState.Ready,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), ChallengeUiState())

    fun markSolved() {
        viewModelScope.launch { learning.completeChallenge(challengeId) }
    }

    /** Free learners can unlock one premium challenge per rewarded ad – granted only on reward callback. */
    fun unlockWithAd(activity: Activity?) {
        activity ?: return
        ads.showRewarded(activity, onReward = {
            viewModelScope.launch { settings.unlockChallenge(challengeId) }
        }, onClosed = {})
    }
}

@Composable
fun ChallengeScreen(navigator: BimoNavigator, viewModel: ChallengeViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    val activity = LocalContext.current.findActivity()
    var confirm by remember { mutableStateOf(false) }
    val challenge = state.challenge
    if (state.loading) { ListSkeleton(); return }
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar("Coding challenge", navigator)
        if (challenge == null) {
            EmptyState(Icons.Filled.Extension, "Challenge not found", "This challenge is not available.")
            return@Column
        }
        LazyColumn(
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, bottom = 32.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
            modifier = Modifier.navigationBarsPadding(),
        ) {
            item {
                Box(Modifier.fillMaxWidth().clip(RoundedCornerShape(24.dp)).background(BimoGradients.Brand).padding(20.dp)) {
                    Column {
                        Text(challenge.difficulty.uppercase(), style = MaterialTheme.typography.labelMedium, color = Color.White.copy(alpha = 0.85f))
                        Text(challenge.title, style = MaterialTheme.typography.headlineSmall, color = Color.White)
                        if (challenge.premium) { Spacer(Modifier.height(8.dp)); PremiumBadge() }
                    }
                }
            }
            if (state.locked) {
                item {
                    EmptyState(
                        Icons.Filled.Lock,
                        "Premium challenge",
                        "Upgrade to Premium for every extra challenge, or unlock this one by watching an optional rewarded ad.",
                    )
                }
                item {
                    Button(onClick = { navigator.to(Routes.PREMIUM) }, modifier = Modifier.fillMaxWidth().height(50.dp)) { Text("See Premium plans") }
                }
                item {
                    OutlinedButton(
                        onClick = { viewModel.unlockWithAd(activity) },
                        enabled = state.rewardedReady,
                        modifier = Modifier.fillMaxWidth().height(50.dp),
                    ) { Text(if (state.rewardedReady) "Unlock with a rewarded ad" else "No ad available right now") }
                }
            } else {
                items(challenge.blocks.size) { i -> LessonBlock(challenge.blocks[i]) }
                item {
                    if (state.solved) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.CheckCircle, null, tint = BimoColors.Success)
                            Spacer(Modifier.width(8.dp))
                            Text("Solved — nice work!", style = MaterialTheme.typography.titleMedium, color = BimoColors.Success)
                        }
                    } else {
                        Button(onClick = { confirm = true }, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                            Text("I solved it (+25 XP)")
                        }
                    }
                }
            }
        }
    }
    if (confirm) {
        AlertDialog(
            onDismissRequest = { confirm = false },
            title = { Text("Mark as solved?") },
            text = { Text("Be honest with yourself: compare your solution with the reference solution first. XP for a challenge is awarded once.") },
            confirmButton = { TextButton(onClick = { confirm = false; viewModel.markSolved() }) { Text("Yes, I solved it") } },
            dismissButton = { TextButton(onClick = { confirm = false }) { Text("Not yet") } },
        )
    }
}
