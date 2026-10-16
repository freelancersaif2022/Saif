package com.bimo.learnflutter.ui.screens.profile

import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.PickVisualMediaRequest
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
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
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Insights
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.PhotoCamera
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
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
import androidx.compose.ui.geometry.CornerRadius
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.content.Curriculum
import com.bimo.learnflutter.core.domain.LearnerStats
import com.bimo.learnflutter.core.domain.LevelCalculator
import com.bimo.learnflutter.core.domain.ProfileValidator
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.data.db.entity.ActivityDayEntity
import com.bimo.learnflutter.data.db.entity.CertificateEntity
import com.bimo.learnflutter.data.db.entity.QuizAttemptEntity
import com.bimo.learnflutter.data.db.entity.UserProfileEntity
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import com.bimo.learnflutter.data.repository.CertificateRepository
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.data.repository.PremiumRepository
import com.bimo.learnflutter.data.repository.PremiumStatus
import com.bimo.learnflutter.data.repository.ProfileRepository
import com.bimo.learnflutter.ui.components.EmptyState
import com.bimo.learnflutter.ui.components.GradientProgressBar
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.PremiumBadge
import com.bimo.learnflutter.ui.components.StatTile
import com.bimo.learnflutter.ui.components.formatDate
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.home.Avatar
import com.bimo.learnflutter.ui.screens.practice.TopBar
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import java.time.LocalDate
import javax.inject.Inject

/** Premium cosmetic avatar frames. */
enum class AvatarFrame(val id: String, val label: String, val brush: Brush?) {
    NONE("none", "None", null),
    GOLD("gold", "Gold", BimoGradients.Gold),
    AURORA("aurora", "Aurora", BimoGradients.Brand),
    FIRE("fire", "Fire", BimoGradients.Fire),
    ;
    companion object { fun of(id: String) = entries.firstOrNull { it.id == id } ?: NONE }
}

data class ProfileUiState(
    val loading: Boolean = true,
    val profile: UserProfileEntity? = null,
    val stats: LearnerStats = LearnerStats(),
    val curriculum: Curriculum? = null,
    val completed: Set<String> = emptySet(),
    val certificates: List<CertificateEntity> = emptyList(),
    val premium: PremiumStatus = PremiumStatus.FREE,
    val frame: AvatarFrame = AvatarFrame.NONE,
)

@HiltViewModel
class ProfileViewModel @Inject constructor(
    private val profiles: ProfileRepository,
    learning: LearningRepository,
    curriculumRepository: CurriculumRepository,
    certificates: CertificateRepository,
    premium: PremiumRepository,
    private val settings: SettingsDataStore,
) : ViewModel() {
    val state: StateFlow<ProfileUiState> = combine(
        combine(profiles.profile, settings.settings) { p, s -> p to AvatarFrame.of(s.avatarFrame) },
        learning.stats,
        combine(curriculumRepository.curriculumFlow, learning.completedLessonIds) { c, d -> c to d },
        certificates.certificates,
        premium.status,
    ) { (profile, frame), stats, (curriculum, completed), certs, premiumStatus ->
        ProfileUiState(false, profile, stats, curriculum, completed, certs, premiumStatus, frame)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), ProfileUiState())

    fun rename(name: String) = viewModelScope.launch { profiles.update { it.copy(name = name.trim()) } }
    fun setAvatar(uri: android.net.Uri) = viewModelScope.launch { profiles.setAvatarFromUri(uri) }
    fun setEmoji(emoji: String) = viewModelScope.launch {
        profiles.clearAvatar()
        profiles.update { it.copy(avatarEmoji = emoji) }
    }
    fun setFrame(frame: AvatarFrame) = viewModelScope.launch { settings.setAvatarFrame(frame.id) }
}

@Composable
fun ProfileScreen(navigator: BimoNavigator, viewModel: ProfileViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    var editName by remember { mutableStateOf(false) }
    var avatarSheet by remember { mutableStateOf(false) }
    val picker = rememberLauncherForActivityResult(ActivityResultContracts.PickVisualMedia()) { uri ->
        uri?.let { viewModel.setAvatar(it) }
    }
    if (state.loading) { ListSkeleton(); return }
    val level = LevelCalculator.levelFor(state.stats.totalXp)

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(bottom = 24.dp), verticalArrangement = Arrangement.spacedBy(16.dp)) {
        item {
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(bottomStart = 32.dp, bottomEnd = 32.dp))
                    .background(BimoGradients.BrandVertical),
            ) {
                Column(
                    Modifier.statusBarsPadding().padding(20.dp).fillMaxWidth(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    Row(Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.End) {
                        IconButton(onClick = { navigator.to(Routes.SETTINGS) }) { Icon(Icons.Filled.Settings, "Settings", tint = Color.White) }
                    }
                    Box(contentAlignment = Alignment.BottomEnd) {
                        val frameBrush = if (state.premium.isPremium) state.frame.brush else null
                        Box(
                            Modifier
                                .then(if (frameBrush != null) Modifier.border(4.dp, frameBrush, CircleShape).padding(6.dp) else Modifier)
                                .clickable { avatarSheet = true },
                        ) { Avatar(state.profile, 96.dp) }
                        Surface(shape = CircleShape, color = Color.White, shadowElevation = 2.dp, modifier = Modifier.size(32.dp).clickable { avatarSheet = true }) {
                            Box(contentAlignment = Alignment.Center) { Icon(Icons.Filled.PhotoCamera, "Change avatar", tint = Color(0xFF2B1C6E), modifier = Modifier.size(18.dp)) }
                        }
                    }
                    Spacer(Modifier.height(10.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(state.profile?.name ?: "Learner", style = MaterialTheme.typography.headlineSmall, color = Color.White)
                        IconButton(onClick = { editName = true }) { Icon(Icons.Filled.Edit, "Edit name", tint = Color.White) }
                    }
                    Text("Level ${level.level} • ${level.title}", style = MaterialTheme.typography.bodyMedium, color = Color.White.copy(alpha = 0.9f))
                    state.profile?.let {
                        Text(
                            "Learning since ${formatDate(it.createdAt)} • Goal: ${it.learningGoal}",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.White.copy(alpha = 0.8f),
                        )
                    }
                    if (state.premium.isPremium) { Spacer(Modifier.height(8.dp)); PremiumBadge() }
                }
            }
        }
        item {
            Column(Modifier.padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Learning statistics", style = MaterialTheme.typography.titleLarge)
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    StatTile("Total XP", "${state.stats.totalXp}", Icons.Filled.Star, BimoColors.Gold, Modifier.weight(1f))
                    StatTile("Lessons", "${state.stats.lessonsCompleted}", Icons.Filled.School, MaterialTheme.colorScheme.primary, Modifier.weight(1f))
                }
                Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                    StatTile("Quizzes passed", "${state.stats.quizzesPassed}", Icons.Filled.Quiz, MaterialTheme.colorScheme.secondary, Modifier.weight(1f))
                    StatTile("Best streak", "${state.stats.longestStreak} d", Icons.Filled.LocalFireDepartment, BimoColors.Fire, Modifier.weight(1f))
                }
            }
        }
        item {
            Column(Modifier.padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                Text("Course progress", style = MaterialTheme.typography.titleLarge)
                state.curriculum?.courses?.forEach { course ->
                    val fraction = ProgressionEngine.courseFraction(course, state.completed)
                    Surface(
                        shape = RoundedCornerShape(18.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp,
                        modifier = Modifier.fillMaxWidth().clickable { navigator.to(Routes.course(course.id)) },
                    ) {
                        Column(Modifier.padding(14.dp)) {
                            Row {
                                Text(course.title, style = MaterialTheme.typography.titleSmall, modifier = Modifier.weight(1f))
                                Text("${(fraction * 100).toInt()}%", style = MaterialTheme.typography.labelLarge)
                            }
                            Spacer(Modifier.height(8.dp))
                            GradientProgressBar(fraction, height = 8.dp, brush = BimoGradients.forCourse(course.id))
                        }
                    }
                }
            }
        }
        item {
            Column(Modifier.padding(horizontal = 20.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                ProfileLink(Icons.Filled.WorkspacePremium, "Certificates",
                    if (state.certificates.isEmpty()) "Not earned yet" else "${state.certificates.size} earned") { navigator.to(Routes.CERTIFICATE) }
                ProfileLink(Icons.Filled.Insights, "Advanced learning insights", if (state.premium.isPremium) "Premium" else "Premium feature") {
                    navigator.to(Routes.INSIGHTS)
                }
                ProfileLink(
                    Icons.Filled.Star, "Premium status",
                    state.premium.active?.let { "Active • ${it.remainingDays(System.currentTimeMillis())} days left" } ?: "Free plan",
                ) { navigator.to(Routes.PREMIUM) }
                ProfileLink(Icons.Filled.Settings, "Settings", "Theme, reminders, data") { navigator.to(Routes.SETTINGS) }
            }
        }
    }

    if (editName) {
        var value by remember { mutableStateOf(state.profile?.name ?: "") }
        val error = ProfileValidator.validateName(value)
        AlertDialog(
            onDismissRequest = { editName = false },
            title = { Text("Edit name") },
            text = {
                Column {
                    OutlinedTextField(
                        value = value,
                        onValueChange = { if (it.length <= ProfileValidator.MAX_NAME_LENGTH) value = it },
                        singleLine = true,
                        isError = error != null,
                        supportingText = { Text(error ?: "This name also appears on your certificate.") },
                    )
                }
            },
            confirmButton = {
                TextButton(enabled = error == null, onClick = { viewModel.rename(value); editName = false }) { Text("Save") }
            },
            dismissButton = { TextButton(onClick = { editName = false }) { Text("Cancel") } },
        )
    }

    if (avatarSheet) {
        AlertDialog(
            onDismissRequest = { avatarSheet = false },
            title = { Text("Your avatar") },
            text = {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Button(onClick = {
                        avatarSheet = false
                        picker.launch(PickVisualMediaRequest(ActivityResultContracts.PickVisualMedia.ImageOnly))
                    }, modifier = Modifier.fillMaxWidth()) { Text("Choose a photo") }
                    Text("Or pick an emoji", style = MaterialTheme.typography.labelLarge)
                    Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                        com.bimo.learnflutter.ui.screens.welcome.AVATAR_EMOJIS.forEach { e ->
                            Text(e, style = MaterialTheme.typography.headlineSmall, modifier = Modifier.clickable {
                                viewModel.setEmoji(e); avatarSheet = false
                            })
                        }
                    }
                    Text("Avatar frame (Premium cosmetic)", style = MaterialTheme.typography.labelLarge)
                    Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        AvatarFrame.entries.forEach { f ->
                            val enabled = state.premium.isPremium || f == AvatarFrame.NONE
                            Box(
                                Modifier
                                    .size(40.dp)
                                    .clip(CircleShape)
                                    .background(f.brush ?: Brush.linearGradient(listOf(Color.LightGray, Color.LightGray)))
                                    .border(if (f == state.frame) 3.dp else 0.dp, MaterialTheme.colorScheme.onSurface, CircleShape)
                                    .clickable(enabled = enabled) { viewModel.setFrame(f) }
                                    .semantics { contentDescription = "${f.label} frame" + if (!enabled) ", premium only" else "" },
                                contentAlignment = Alignment.Center,
                            ) { if (!enabled) Icon(Icons.Filled.Lock, null, tint = Color.White, modifier = Modifier.size(16.dp)) }
                        }
                    }
                }
            },
            confirmButton = { TextButton(onClick = { avatarSheet = false }) { Text("Done") } },
        )
    }
}

@Composable
private fun ProfileLink(icon: ImageVector, title: String, subtitle: String, onClick: () -> Unit) {
    Surface(
        shape = RoundedCornerShape(18.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp,
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
    ) {
        Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(Modifier.size(40.dp).clip(RoundedCornerShape(12.dp)).background(MaterialTheme.colorScheme.primaryContainer), contentAlignment = Alignment.Center) {
                Icon(icon, null, tint = MaterialTheme.colorScheme.primary)
            }
            Spacer(Modifier.width(12.dp))
            Column(Modifier.weight(1f)) {
                Text(title, style = MaterialTheme.typography.titleSmall)
                Text(subtitle, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
            Icon(Icons.AutoMirrored.Filled.ArrowForward, null)
        }
    }
}

// ------------------------------------------------------------------ Advanced insights (Premium)

data class ModuleInsight(val title: String, val courseTitle: String, val averageScore: Int, val attempts: Int)

data class InsightsUiState(
    val loading: Boolean = true,
    val isPremium: Boolean = false,
    val modules: List<ModuleInsight> = emptyList(),
    val last14Days: List<Pair<LocalDate, Int>> = emptyList(),
    val totalMinutes: Int = 0,
    val firstTryPassRate: Int = 0,
)

@HiltViewModel
class InsightsViewModel @Inject constructor(
    curriculumRepository: CurriculumRepository,
    learning: LearningRepository,
    premium: PremiumRepository,
) : ViewModel() {
    val state: StateFlow<InsightsUiState> = combine(
        curriculumRepository.curriculumFlow, learning.attempts, learning.activityDays, premium.isPremium,
    ) { curriculum, attempts, days, isPremium ->
        InsightsUiState(
            loading = false,
            isPremium = isPremium,
            modules = moduleInsights(curriculum, attempts),
            last14Days = lastDays(days),
            totalMinutes = attempts.sumOf { it.durationSeconds } / 60 +
                curriculum.lessons.filter { l -> attempts.any { it.lessonId == l.id && it.passed } }.sumOf { it.minutes },
            firstTryPassRate = firstTryRate(attempts),
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), InsightsUiState())

    private fun moduleInsights(curriculum: Curriculum, attempts: List<QuizAttemptEntity>): List<ModuleInsight> {
        val byLesson = attempts.filter { it.lessonId != null }.groupBy { it.lessonId!! }
        return curriculum.courses.flatMap { course ->
            course.modules.mapNotNull { m ->
                val list = m.lessons.flatMap { byLesson[it.id].orEmpty() }
                if (list.isEmpty()) null
                else ModuleInsight(m.title, course.title, list.sumOf { it.percent } / list.size, list.size)
            }
        }.sortedBy { it.averageScore }
    }

    private fun lastDays(days: List<ActivityDayEntity>): List<Pair<LocalDate, Int>> {
        val map = days.associateBy { it.epochDay }
        val today = LocalDate.now()
        return (13 downTo 0).map { offset ->
            val d = today.minusDays(offset.toLong())
            d to (map[d.toEpochDay()]?.let { it.lessonsCompleted + it.quizzesTaken } ?: 0)
        }
    }

    private fun firstTryRate(attempts: List<QuizAttemptEntity>): Int {
        val first = attempts.groupBy { it.quizId }.mapValues { (_, l) -> l.minByOrNull { it.takenAt }!! }.values
        if (first.isEmpty()) return 0
        return first.count { it.passed } * 100 / first.size
    }
}

@Composable
fun InsightsScreen(navigator: BimoNavigator, viewModel: InsightsViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    Column(Modifier.fillMaxSize().statusBarsPadding()) {
        TopBar("Learning insights", navigator)
        when {
            state.loading -> ListSkeleton()
            !state.isPremium -> Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                EmptyState(
                    Icons.Filled.Insights,
                    "Advanced insights are Premium",
                    "See your accuracy per module, your weakest topics, activity trends and first-try pass rate.",
                    actionLabel = "See Premium",
                    onAction = { navigator.to(Routes.PREMIUM) },
                )
            }
            else -> LazyColumn(
                contentPadding = PaddingValues(20.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp),
                modifier = Modifier.navigationBarsPadding(),
            ) {
                item {
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        StatTile("Study time", "${state.totalMinutes} min", Icons.Filled.School, MaterialTheme.colorScheme.primary, Modifier.weight(1f))
                        StatTile("First-try pass", "${state.firstTryPassRate}%", Icons.Filled.Quiz, BimoColors.Success, Modifier.weight(1f))
                    }
                }
                item {
                    Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
                        Column(Modifier.fillMaxWidth().padding(16.dp)) {
                            Text("Activity • last 14 days", style = MaterialTheme.typography.titleSmall)
                            Spacer(Modifier.height(12.dp))
                            ActivityChart(state.last14Days)
                        }
                    }
                }
                item { Text("Focus areas (lowest average first)", style = MaterialTheme.typography.titleMedium) }
                if (state.modules.isEmpty()) {
                    item { Text("Take a few quizzes to see per-module insights.", style = MaterialTheme.typography.bodyMedium) }
                }
                items(state.modules) { m ->
                    Surface(shape = RoundedCornerShape(16.dp), color = MaterialTheme.colorScheme.surface) {
                        Column(Modifier.fillMaxWidth().padding(14.dp)) {
                            Row {
                                Column(Modifier.weight(1f)) {
                                    Text(m.title, style = MaterialTheme.typography.titleSmall, maxLines = 1, overflow = TextOverflow.Ellipsis)
                                    Text("${m.courseTitle} • ${m.attempts} attempts", style = MaterialTheme.typography.bodySmall)
                                }
                                Text("${m.averageScore}%", style = MaterialTheme.typography.titleMedium,
                                    color = if (m.averageScore < 70) BimoColors.Error else BimoColors.Success)
                            }
                            Spacer(Modifier.height(6.dp))
                            GradientProgressBar(m.averageScore / 100f, height = 6.dp)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ActivityChart(days: List<Pair<LocalDate, Int>>) {
    val max = (days.maxOfOrNull { it.second } ?: 0).coerceAtLeast(1)
    val barColor = MaterialTheme.colorScheme.primary
    val track = MaterialTheme.colorScheme.surfaceVariant
    Canvas(
        Modifier
            .fillMaxWidth()
            .height(120.dp)
            .semantics { contentDescription = "Activity chart: " + days.joinToString { "${it.first.dayOfMonth}: ${it.second}" } },
    ) {
        val gap = 6.dp.toPx()
        val w = (size.width - gap * (days.size - 1)) / days.size
        days.forEachIndexed { i, (_, value) ->
            val x = i * (w + gap)
            drawRoundRect(track, Offset(x, 0f), Size(w, size.height), CornerRadius(w / 3))
            val h = size.height * value / max
            if (h > 0) drawRoundRect(barColor, Offset(x, size.height - h), Size(w, h), CornerRadius(w / 3))
        }
    }
}
