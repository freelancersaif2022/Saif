package com.bimo.learnflutter.ui.screens.home

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import coil.compose.AsyncImage
import com.bimo.learnflutter.core.content.Course
import com.bimo.learnflutter.core.content.Lesson
import com.bimo.learnflutter.core.domain.AchievementCatalog
import com.bimo.learnflutter.core.domain.AchievementDefinition
import com.bimo.learnflutter.core.domain.CertificateEligibility
import com.bimo.learnflutter.core.domain.DailyGoalProgress
import com.bimo.learnflutter.core.domain.LevelCalculator
import com.bimo.learnflutter.core.domain.LevelInfo
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.core.domain.StreakInfo
import com.bimo.learnflutter.data.db.entity.UserProfileEntity
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.CurriculumState
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.ProfileRepository
import com.bimo.learnflutter.ui.components.CourseBadge
import com.bimo.learnflutter.ui.components.ErrorState
import com.bimo.learnflutter.ui.components.GradientProgressBar
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.PremiumBadge
import com.bimo.learnflutter.ui.components.ProgressRing
import com.bimo.learnflutter.ui.components.SectionHeader
import com.bimo.learnflutter.ui.components.StreakPill
import com.bimo.learnflutter.ui.components.XpPill
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.achievements.achievementIcon
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import java.time.LocalTime
import javax.inject.Inject

data class CourseSummary(val course: Course, val fraction: Float, val completed: Int)

data class HomeUiState(
    val loading: Boolean = true,
    val error: String? = null,
    val profile: UserProfileEntity? = null,
    val streak: StreakInfo = StreakInfo(0, 0, false),
    val xp: Int = 0,
    val level: LevelInfo = LevelCalculator.levelFor(0),
    val lessonsCompleted: Int = 0,
    val totalLessons: Int = 0,
    val courses: List<CourseSummary> = emptyList(),
    val recommended: Lesson? = null,
    val recommendedCourse: Course? = null,
    val continueLesson: Boolean = false,
    val dailyGoal: DailyGoalProgress = DailyGoalProgress(1, 0),
    val recentAchievements: List<AchievementDefinition> = emptyList(),
    val isPremium: Boolean = false,
    val certificate: CertificateEligibility? = null,
) {
    val overallFraction: Float get() = if (totalLessons == 0) 0f else lessonsCompleted.toFloat() / totalLessons
}

@HiltViewModel
class HomeViewModel @Inject constructor(
    curriculumRepository: CurriculumRepository,
    profiles: ProfileRepository,
    learning: LearningRepository,
    premium: PremiumRepository,
    settings: SettingsDataStore,
) : ViewModel() {
    val reload: () -> Unit = curriculumRepository::reload

    private val progress = combine(
        learning.completedLessonIds, learning.totalXp, learning.streak, learning.completedToday, learning.achievements,
    ) { completed, xp, streak, today, achievements -> Progress(completed, xp, streak, today, achievements.map { it.id }) }

    val state: StateFlow<HomeUiState> = combine(
        curriculumRepository.state,
        combine(profiles.profile, settings.settings) { p, s -> p to s.lastOpenedLessonId },
        progress,
        premium.isPremium,
        learning.certificateEligibility,
    ) { curriculumState, (profile, lastLesson), p, isPremium, certificate ->
        when (curriculumState) {
            is CurriculumState.Loading -> HomeUiState(loading = true)
            is CurriculumState.Failed -> HomeUiState(loading = false, error = curriculumState.message)
            is CurriculumState.Ready -> {
                val curriculum = curriculumState.curriculum
                val recommended = ProgressionEngine.recommendedLesson(curriculum, p.completed, lastLesson)
                HomeUiState(
                    loading = false,
                    profile = profile,
                    streak = p.streak,
                    xp = p.xp,
                    level = LevelCalculator.levelFor(p.xp),
                    lessonsCompleted = p.completed.size,
                    totalLessons = curriculum.lessons.size,
                    courses = curriculum.courses.map {
                        CourseSummary(it, ProgressionEngine.courseFraction(it, p.completed), it.lessons.count { l -> l.id in p.completed })
                    },
                    recommended = recommended,
                    recommendedCourse = recommended?.let { curriculum.course(it.courseId) },
                    continueLesson = recommended != null && recommended.id == lastLesson,
                    dailyGoal = DailyGoalProgress(profile?.dailyGoalLessons ?: 1, p.today),
                    recentAchievements = p.achievementIds.take(4).mapNotNull { AchievementCatalog.byId(it) },
                    isPremium = isPremium,
                    certificate = certificate,
                )
            }
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), HomeUiState())

    private data class Progress(
        val completed: Set<String>,
        val xp: Int,
        val streak: StreakInfo,
        val today: Int,
        val achievementIds: List<String>,
    )
}

private fun greeting(): String = when (LocalTime.now().hour) {
    in 5..11 -> "Good morning"
    in 12..17 -> "Good afternoon"
    else -> "Good evening"
}

@Composable
fun HomeScreen(navigator: BimoNavigator, viewModel: HomeViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    when {
        state.loading -> ListSkeleton()
        state.error != null -> ErrorState(state.error ?: "", onRetry = viewModel.reload)
        else -> HomeContent(state, navigator)
    }
}

@Composable
private fun HomeContent(state: HomeUiState, navigator: BimoNavigator) {
    LazyColumn(
        Modifier.fillMaxSize(),
        verticalArrangement = Arrangement.spacedBy(18.dp),
    ) {
        item { HeroHeader(state, navigator) }
        item {
            ContinueCard(state, navigator, Modifier.padding(horizontal = 20.dp))
        }
        item {
            Row(Modifier.padding(horizontal = 20.dp), horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                DailyGoalCard(state.dailyGoal, Modifier.weight(1f))
                QuickQuizCard(Modifier.weight(1f)) { navigator.tab(Routes.PRACTICE) }
            }
        }
        item { SectionHeader("Your courses", Modifier.padding(horizontal = 20.dp), "See all") { navigator.tab(Routes.COURSES) } }
        item {
            LazyRow(
                contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                items(state.courses, key = { it.course.id }) { summary ->
                    CourseCard(summary) { navigator.to(Routes.course(summary.course.id)) }
                }
            }
        }
        if (!state.isPremium) {
            item { PremiumBanner(Modifier.padding(horizontal = 20.dp)) { navigator.to(Routes.PREMIUM) } }
        }
        item { CertificateProgressCard(state.certificate, Modifier.padding(horizontal = 20.dp)) { navigator.to(Routes.CERTIFICATE) } }
        item { SectionHeader("Recent achievements", Modifier.padding(horizontal = 20.dp), "All") { navigator.tab(Routes.ACHIEVEMENTS) } }
        item {
            if (state.recentAchievements.isEmpty()) {
                Surface(
                    shape = MaterialTheme.shapes.large,
                    color = MaterialTheme.colorScheme.surfaceContainerLow,
                    modifier = Modifier
                        .padding(horizontal = 20.dp)
                        .fillMaxWidth(),
                ) {
                    Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.EmojiEvents, null, tint = BimoColors.Gold, modifier = Modifier.size(32.dp))
                        Spacer(Modifier.width(12.dp))
                        Text(
                            "Complete your first lesson to earn the “First Steps” badge.",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
            } else {
                LazyRow(
                    contentPadding = androidx.compose.foundation.layout.PaddingValues(horizontal = 20.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                ) {
                    items(state.recentAchievements, key = { it.id }) { a ->
                        Surface(shape = MaterialTheme.shapes.large, color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
                            Column(Modifier.width(120.dp).padding(14.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                                Box(
                                    Modifier.size(48.dp).clip(CircleShape).background(BimoGradients.Gold),
                                    contentAlignment = Alignment.Center,
                                ) { Icon(achievementIcon(a.icon), null, tint = Color(0xFF3A2A00)) }
                                Spacer(Modifier.height(8.dp))
                                Text(a.title, style = MaterialTheme.typography.labelLarge, maxLines = 2, overflow = TextOverflow.Ellipsis)
                            }
                        }
                    }
                }
            }
        }
        item { Spacer(Modifier.height(16.dp)) }
    }
}

@Composable
fun Avatar(profile: UserProfileEntity?, size: Dp, modifier: Modifier = Modifier) {
    Box(
        modifier
            .size(size)
            .clip(CircleShape)
            .background(Color.White.copy(alpha = 0.25f))
            .semantics { contentDescription = "Profile picture" },
        contentAlignment = Alignment.Center,
    ) {
        val path = profile?.avatarPath
        if (path != null) {
            AsyncImage(model = java.io.File(path), contentDescription = null, contentScale = ContentScale.Crop, modifier = Modifier.fillMaxSize())
        } else {
            Text(profile?.avatarEmoji ?: "🦊", fontSize = (size.value * 0.5f).sp)
        }
    }
}

@Composable
private fun HeroHeader(state: HomeUiState, navigator: BimoNavigator) {
    Box(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(bottomStart = 32.dp, bottomEnd = 32.dp))
            .background(BimoGradients.BrandVertical),
    ) {
        Column(
            Modifier
                .statusBarsPadding()
                .padding(20.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Avatar(state.profile, 52.dp, Modifier.clickable { navigator.tab(Routes.PROFILE) })
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("${greeting()},", style = MaterialTheme.typography.bodyMedium, color = Color.White.copy(alpha = 0.85f))
                    Text(
                        state.profile?.name?.substringBefore(' ') ?: "Learner",
                        style = MaterialTheme.typography.headlineSmall,
                        color = Color.White,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                    )
                }
                if (state.isPremium) PremiumBadge()
                IconButton(onClick = { navigator.to(Routes.SETTINGS) }) {
                    Icon(Icons.Filled.Settings, contentDescription = "Settings", tint = Color.White)
                }
            }
            Spacer(Modifier.height(16.dp))
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                StreakPill(state.streak.current)
                XpPill(state.xp)
                Surface(shape = CircleShape, color = Color.White.copy(alpha = 0.18f)) {
                    Text(
                        "Level ${state.level.level}",
                        Modifier.padding(horizontal = 12.dp, vertical = 6.dp),
                        style = MaterialTheme.typography.labelLarge,
                        color = Color.White,
                    )
                }
            }
            Spacer(Modifier.height(18.dp))
            Surface(shape = RoundedCornerShape(22.dp), color = Color.White.copy(alpha = 0.14f)) {
                Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                    ProgressRing(
                        state.overallFraction, size = 64.dp,
                        brush = androidx.compose.ui.graphics.SolidColor(BimoColors.Accent),
                        trackColor = Color.White.copy(alpha = 0.2f),
                    ) {
                        Text("${(state.overallFraction * 100).toInt()}%", color = Color.White, style = MaterialTheme.typography.labelLarge)
                    }
                    Spacer(Modifier.width(16.dp))
                    Column(Modifier.weight(1f)) {
                        Text("Overall progress", color = Color.White, style = MaterialTheme.typography.titleMedium)
                        Text(
                            "${state.lessonsCompleted} of ${state.totalLessons} lessons completed",
                            color = Color.White.copy(alpha = 0.85f),
                            style = MaterialTheme.typography.bodySmall,
                        )
                        Spacer(Modifier.height(8.dp))
                        Text(
                            "${state.level.title} • ${state.level.xpForNextLevel - state.level.xpIntoLevel} XP to level ${state.level.level + 1}",
                            color = Color.White.copy(alpha = 0.85f),
                            style = MaterialTheme.typography.bodySmall,
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun ContinueCard(state: HomeUiState, navigator: BimoNavigator, modifier: Modifier) {
    val lesson = state.recommended
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 3.dp,
    ) {
        Column(Modifier.padding(18.dp)) {
            if (lesson == null) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Filled.CheckCircle, null, tint = BimoColors.Success, modifier = Modifier.size(36.dp))
                    Spacer(Modifier.width(12.dp))
                    Column {
                        Text("Every lesson is complete!", style = MaterialTheme.typography.titleMedium)
                        Text("Take the final assessment to earn your certificate.", style = MaterialTheme.typography.bodySmall)
                    }
                }
                Spacer(Modifier.height(12.dp))
                Button(onClick = { navigator.to(Routes.CERTIFICATE) }, modifier = Modifier.fillMaxWidth()) { Text("Go to certificate") }
            } else {
                Text(
                    if (state.continueLesson) "CONTINUE LEARNING" else "RECOMMENDED NEXT LESSON",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.primary,
                )
                Spacer(Modifier.height(10.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    state.recommendedCourse?.let { CourseBadge(it.id, it.icon, 48.dp) }
                    Spacer(Modifier.width(12.dp))
                    Column(Modifier.weight(1f)) {
                        Text(lesson.title, style = MaterialTheme.typography.titleMedium, maxLines = 2, overflow = TextOverflow.Ellipsis)
                        Text(
                            "${state.recommendedCourse?.title ?: ""} • ${lesson.minutes} min",
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                        )
                    }
                }
                Spacer(Modifier.height(14.dp))
                Button(
                    onClick = { navigator.to(Routes.lesson(lesson.id)) },
                    modifier = Modifier.fillMaxWidth().height(48.dp),
                ) {
                    Icon(Icons.Filled.PlayArrow, null)
                    Spacer(Modifier.width(6.dp))
                    Text(if (state.continueLesson) "Continue" else "Start lesson")
                }
            }
        }
    }
}

@Composable
private fun DailyGoalCard(goal: DailyGoalProgress, modifier: Modifier) {
    Surface(modifier, shape = MaterialTheme.shapes.large, color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
        Column(Modifier.padding(16.dp)) {
            Text("Daily goal", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.onSurfaceVariant)
            Spacer(Modifier.height(10.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                ProgressRing(goal.fraction, size = 48.dp, strokeWidth = 6.dp, brush = BimoGradients.Fire) {
                    Icon(Icons.Filled.Bolt, null, tint = BimoColors.Fire, modifier = Modifier.size(20.dp))
                }
                Spacer(Modifier.width(10.dp))
                Column {
                    Text("${goal.doneToday.coerceAtMost(goal.goal)}/${goal.goal}", style = MaterialTheme.typography.titleLarge)
                    Text(if (goal.met) "Goal met!" else "lessons today", style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}

@Composable
private fun QuickQuizCard(modifier: Modifier, onClick: () -> Unit) {
    Surface(
        modifier.clickable(onClick = onClick),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.secondaryContainer,
    ) {
        Column(Modifier.padding(16.dp)) {
            Text("Quick quiz", style = MaterialTheme.typography.labelLarge, color = MaterialTheme.colorScheme.onSecondaryContainer)
            Spacer(Modifier.height(10.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(Icons.Filled.Quiz, null, tint = MaterialTheme.colorScheme.secondary, modifier = Modifier.size(40.dp))
                Spacer(Modifier.width(8.dp))
                Text("Practise & review", style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.onSecondaryContainer)
            }
        }
    }
}

@Composable
fun CourseCard(summary: CourseSummary, onClick: () -> Unit) {
    val course = summary.course
    Box(
        Modifier
            .width(250.dp)
            .clip(MaterialTheme.shapes.large)
            .background(BimoGradients.forCourse(course.id))
            .clickable(onClick = onClick)
            .padding(18.dp),
    ) {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    Modifier.size(44.dp).clip(RoundedCornerShape(14.dp)).background(Color.White.copy(alpha = 0.2f)),
                    contentAlignment = Alignment.Center,
                ) { Icon(com.bimo.learnflutter.ui.components.courseIcon(course.icon), null, tint = Color.White) }
                Spacer(Modifier.weight(1f))
                Text("${(summary.fraction * 100).toInt()}%", color = Color.White, style = MaterialTheme.typography.titleMedium)
            }
            Spacer(Modifier.height(16.dp))
            Text(course.title, color = Color.White, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(
                "${course.modules.size} modules • ${course.lessonCount} lessons",
                color = Color.White.copy(alpha = 0.85f),
                style = MaterialTheme.typography.bodySmall,
            )
            Spacer(Modifier.height(12.dp))
            GradientProgressBar(summary.fraction, height = 8.dp, brush = androidx.compose.ui.graphics.SolidColor(Color.White))
        }
    }
}

@Composable
private fun PremiumBanner(modifier: Modifier, onClick: () -> Unit) {
    Box(
        modifier
            .fillMaxWidth()
            .clip(MaterialTheme.shapes.large)
            .background(BimoGradients.Premium)
            .clickable(onClick = onClick)
            .padding(18.dp),
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(Icons.Filled.WorkspacePremium, null, tint = BimoColors.Gold, modifier = Modifier.size(40.dp))
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text("Go Premium", color = Color.White, style = MaterialTheme.typography.titleMedium)
                Text(
                    "Ad-free learning, premium themes, extra challenges and insights.",
                    color = Color.White.copy(alpha = 0.85f),
                    style = MaterialTheme.typography.bodySmall,
                )
            }
            Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = "Open premium", tint = Color.White)
        }
    }
}

@Composable
private fun CertificateProgressCard(eligibility: CertificateEligibility?, modifier: Modifier, onClick: () -> Unit) {
    val fraction = eligibility?.overallFraction ?: 0f
    Surface(
        modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 1.dp,
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(48.dp).clip(RoundedCornerShape(14.dp)).background(BimoGradients.Gold),
                contentAlignment = Alignment.Center,
            ) { Icon(Icons.Filled.School, null, tint = Color(0xFF3A2A00)) }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text("Certificate progress", style = MaterialTheme.typography.titleSmall)
                Spacer(Modifier.height(6.dp))
                GradientProgressBar(fraction, height = 8.dp, brush = BimoGradients.Gold)
                Spacer(Modifier.height(4.dp))
                Text(
                    when {
                        eligibility?.eligible == true -> "Your certificate is ready!"
                        eligibility?.finalExamUnlocked == true -> "Final assessment unlocked"
                        else -> "${(fraction * 100).toInt()}% of requirements met"
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
        }
    }
}
