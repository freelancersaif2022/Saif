package com.bimo.learnflutter.ui.screens.achievements

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
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.GridItemSpan
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.filled.AutoStories
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Code
import androidx.compose.material.icons.filled.Construction
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Extension
import androidx.compose.material.icons.filled.FactCheck
import androidx.compose.material.icons.filled.Inventory
import androidx.compose.material.icons.filled.LocalFireDepartment
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.MilitaryTech
import androidx.compose.material.icons.filled.PhoneAndroid
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.filled.Replay
import androidx.compose.material.icons.filled.School
import androidx.compose.material.icons.filled.Stairs
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.Stars
import androidx.compose.material.icons.filled.TrackChanges
import androidx.compose.material.icons.filled.Verified
import androidx.compose.material.icons.filled.Whatshot
import androidx.compose.material.icons.filled.Work
import androidx.compose.material.icons.filled.WorkspacePremium
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.domain.AchievementCatalog
import com.bimo.learnflutter.core.domain.AchievementDefinition
import com.bimo.learnflutter.core.domain.AchievementTier
import com.bimo.learnflutter.core.domain.LearnerStats
import com.bimo.learnflutter.core.domain.LevelCalculator
import com.bimo.learnflutter.core.domain.StreakInfo
import com.bimo.learnflutter.data.db.entity.AchievementEntity
import com.bimo.learnflutter.data.db.entity.CertificateEntity
import com.bimo.learnflutter.data.repository.CertificateRepository
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.ui.components.GradientProgressBar
import com.bimo.learnflutter.ui.components.ProgressRing
import com.bimo.learnflutter.ui.components.formatDate
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

fun achievementIcon(name: String): ImageVector = when (name) {
    "school" -> Icons.Filled.School
    "menu_book" -> Icons.AutoMirrored.Filled.MenuBook
    "auto_stories" -> Icons.Filled.AutoStories
    "psychology" -> Icons.Filled.Psychology
    "verified" -> Icons.Filled.Verified
    "target" -> Icons.Filled.TrackChanges
    "replay" -> Icons.Filled.Replay
    "local_fire_department" -> Icons.Filled.LocalFireDepartment
    "whatshot" -> Icons.Filled.Whatshot
    "bolt" -> Icons.Filled.Bolt
    "star" -> Icons.Filled.Star
    "stars" -> Icons.Filled.Stars
    "military_tech" -> Icons.Filled.MilitaryTech
    "inventory" -> Icons.Filled.Inventory
    "stairs" -> Icons.Filled.Stairs
    "code" -> Icons.Filled.Code
    "phone_android" -> Icons.Filled.PhoneAndroid
    "construction" -> Icons.Filled.Construction
    "work" -> Icons.Filled.Work
    "extension" -> Icons.Filled.Extension
    "fact_check" -> Icons.Filled.FactCheck
    "workspace_premium" -> Icons.Filled.WorkspacePremium
    else -> Icons.Filled.EmojiEvents
}

fun tierBrush(tier: AchievementTier): Brush = when (tier) {
    AchievementTier.BRONZE -> Brush.linearGradient(listOf(Color(0xFFE6A06B), Color(0xFFA0582A)))
    AchievementTier.SILVER -> Brush.linearGradient(listOf(Color(0xFFE6E9F2), Color(0xFF9097AD)))
    AchievementTier.GOLD -> BimoGradients.Gold
    AchievementTier.PLATINUM -> Brush.linearGradient(listOf(Color(0xFFB9F3FF), Color(0xFF6750F5)))
}

data class AchievementsUiState(
    val stats: LearnerStats = LearnerStats(),
    val streak: StreakInfo = StreakInfo(0, 0, false),
    val unlocked: Map<String, AchievementEntity> = emptyMap(),
    val certificates: List<CertificateEntity> = emptyList(),
)

@HiltViewModel
class AchievementsViewModel @Inject constructor(
    private val learning: LearningRepository,
    certificates: CertificateRepository,
) : ViewModel() {
    val state: StateFlow<AchievementsUiState> = combine(
        learning.stats, learning.streak, learning.achievements, certificates.certificates,
    ) { stats, streak, achievements, certs ->
        AchievementsUiState(stats, streak, achievements.associateBy { it.id }, certs)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), AchievementsUiState())

    fun markSeen() {
        viewModelScope.launch { learning.markAchievementsSeen() }
    }
}

@Composable
fun AchievementsScreen(navigator: BimoNavigator, viewModel: AchievementsViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    var selected by remember { mutableStateOf<AchievementDefinition?>(null) }
    LaunchedEffect(Unit) { viewModel.markSeen() }
    val level = LevelCalculator.levelFor(state.stats.totalXp)

    LazyVerticalGrid(
        columns = GridCells.Adaptive(104.dp),
        modifier = Modifier.fillMaxSize().statusBarsPadding(),
        contentPadding = PaddingValues(20.dp),
        horizontalArrangement = Arrangement.spacedBy(12.dp),
        verticalArrangement = Arrangement.spacedBy(12.dp),
    ) {
        item(span = { GridItemSpan(maxLineSpan) }) {
            Text("Achievements", style = MaterialTheme.typography.headlineMedium)
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(28.dp))
                    .background(BimoGradients.Premium)
                    .padding(20.dp),
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    ProgressRing(
                        level.progress, size = 92.dp, strokeWidth = 10.dp, brush = BimoGradients.Gold,
                        trackColor = Color.White.copy(alpha = 0.2f),
                    ) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Text("LVL", style = MaterialTheme.typography.labelSmall, color = Color.White.copy(alpha = 0.8f))
                            Text("${level.level}", style = MaterialTheme.typography.headlineSmall, color = Color.White)
                        }
                    }
                    Spacer(Modifier.width(18.dp))
                    Column {
                        Text(level.title, style = MaterialTheme.typography.titleLarge, color = Color.White)
                        Text("${state.stats.totalXp} XP total", style = MaterialTheme.typography.bodyMedium, color = BimoColors.Gold)
                        Text(
                            "${level.xpForNextLevel - level.xpIntoLevel} XP to level ${level.level + 1}",
                            style = MaterialTheme.typography.bodySmall,
                            color = Color.White.copy(alpha = 0.85f),
                        )
                    }
                }
            }
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Row(horizontalArrangement = Arrangement.spacedBy(12.dp)) {
                MiniStat("Current streak", "${state.streak.current} days", Icons.Filled.LocalFireDepartment, BimoColors.Fire, Modifier.weight(1f))
                MiniStat("Longest streak", "${state.streak.longest} days", Icons.Filled.Whatshot, BimoColors.Warning, Modifier.weight(1f))
            }
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Text(
                "Badges • ${state.unlocked.size}/${AchievementCatalog.all.size}",
                style = MaterialTheme.typography.titleLarge,
                modifier = Modifier.padding(top = 8.dp),
            )
        }
        items(AchievementCatalog.all, key = { it.id }) { def ->
            BadgeTile(def, state.unlocked[def.id], state.stats) { selected = def }
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Text("Milestones", style = MaterialTheme.typography.titleLarge, modifier = Modifier.padding(top = 8.dp))
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Milestone("Dart course", state.stats.dartCourseComplete)
                Milestone("Flutter course", state.stats.flutterCourseComplete)
                Milestone("Real-world projects", state.stats.projectsCourseComplete)
                Milestone("Final assessment", state.stats.finalExamPassed)
                Milestone("Certificate earned", state.stats.certificateEarned)
            }
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            Text("Certificates", style = MaterialTheme.typography.titleLarge, modifier = Modifier.padding(top = 8.dp))
        }
        item(span = { GridItemSpan(maxLineSpan) }) {
            if (state.certificates.isEmpty()) {
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = MaterialTheme.colorScheme.surfaceContainerLow,
                    modifier = Modifier.fillMaxWidth().clickable { navigator.to(Routes.CERTIFICATE) },
                ) {
                    Text(
                        "No certificate yet. Tap to see what's left to earn your Bimo certificate.",
                        Modifier.padding(16.dp),
                        style = MaterialTheme.typography.bodyMedium,
                    )
                }
            } else {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    state.certificates.forEach { c ->
                        Surface(
                            shape = RoundedCornerShape(20.dp),
                            color = MaterialTheme.colorScheme.surface,
                            shadowElevation = 1.dp,
                            modifier = Modifier.fillMaxWidth().clickable { navigator.to(Routes.CERTIFICATE) },
                        ) {
                            Row(Modifier.padding(16.dp), verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Filled.WorkspacePremium, null, tint = BimoColors.Gold, modifier = Modifier.size(36.dp))
                                Spacer(Modifier.width(12.dp))
                                Column {
                                    Text(c.courseTitle, style = MaterialTheme.typography.titleSmall)
                                    Text("${formatDate(c.issuedAt)} • ${c.certificateId}", style = MaterialTheme.typography.bodySmall)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    selected?.let { def ->
        val unlocked = state.unlocked[def.id]
        val (value, target) = def.progress(state.stats)
        AlertDialog(
            onDismissRequest = { selected = null },
            icon = { Icon(achievementIcon(def.icon), null) },
            title = { Text(def.title) },
            text = {
                Column {
                    Text(def.description)
                    Spacer(Modifier.height(10.dp))
                    if (unlocked != null) Text("Unlocked on ${formatDate(unlocked.unlockedAt)}", color = BimoColors.Success)
                    else {
                        Text("Progress: ${minOf(value, target)}/$target")
                        Spacer(Modifier.height(6.dp))
                        GradientProgressBar(value.toFloat() / target)
                    }
                }
            },
            confirmButton = { TextButton(onClick = { selected = null }) { Text("Close") } },
        )
    }
}

@Composable
private fun MiniStat(label: String, value: String, icon: ImageVector, tint: Color, modifier: Modifier) {
    Surface(modifier, shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp) {
        Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
            Icon(icon, null, tint = tint, modifier = Modifier.size(30.dp))
            Spacer(Modifier.width(10.dp))
            Column {
                Text(value, style = MaterialTheme.typography.titleMedium)
                Text(label, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
            }
        }
    }
}

@Composable
private fun BadgeTile(def: AchievementDefinition, unlocked: AchievementEntity?, stats: LearnerStats, onClick: () -> Unit) {
    val isUnlocked = unlocked != null
    val (value, target) = def.progress(stats)
    Column(
        Modifier
            .clip(RoundedCornerShape(20.dp))
            .background(MaterialTheme.colorScheme.surface)
            .clickable(onClick = onClick)
            .padding(10.dp)
            .semantics(mergeDescendants = true) {
                contentDescription = "${def.title}, ${if (isUnlocked) "unlocked" else "locked, $value of $target"}"
            },
        horizontalAlignment = Alignment.CenterHorizontally,
    ) {
        Box(
            Modifier
                .size(62.dp)
                .clip(CircleShape)
                .background(if (isUnlocked) tierBrush(def.tier) else Brush.linearGradient(listOf(MaterialTheme.colorScheme.surfaceVariant, MaterialTheme.colorScheme.surfaceVariant))),
            contentAlignment = Alignment.Center,
        ) {
            Icon(
                if (isUnlocked) achievementIcon(def.icon) else Icons.Filled.Lock,
                null,
                tint = if (isUnlocked) Color(0xFF2A1E00) else MaterialTheme.colorScheme.outline,
                modifier = Modifier.size(30.dp),
            )
        }
        Spacer(Modifier.height(6.dp))
        Text(
            def.title,
            style = MaterialTheme.typography.labelMedium,
            textAlign = TextAlign.Center,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis,
            modifier = Modifier.alpha(if (isUnlocked) 1f else 0.7f),
        )
        if (!isUnlocked) {
            Spacer(Modifier.height(4.dp))
            GradientProgressBar(value.toFloat() / target, height = 4.dp)
        }
    }
}

@Composable
private fun Milestone(label: String, done: Boolean) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            Modifier.size(28.dp).clip(CircleShape).background(if (done) BimoColors.Success else MaterialTheme.colorScheme.surfaceVariant),
            contentAlignment = Alignment.Center,
        ) { if (done) Icon(Icons.Filled.Check, null, tint = Color.White, modifier = Modifier.size(16.dp)) }
        Spacer(Modifier.width(12.dp))
        Text(label, style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
        Text(if (done) "Done" else "In progress", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.onSurfaceVariant)
    }
}
