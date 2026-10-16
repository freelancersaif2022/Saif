package com.bimo.learnflutter.ui.screens.courses

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.animateContentSize
import androidx.compose.animation.core.animateFloatAsState
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.automirrored.filled.FactCheck
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.outlined.Schedule
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.rotate
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.content.Course
import com.bimo.learnflutter.core.domain.CertificateEligibility
import com.bimo.learnflutter.core.domain.LessonState
import com.bimo.learnflutter.core.domain.LessonStatus
import com.bimo.learnflutter.core.domain.ModuleProgress
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.CurriculumState
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.ui.components.CourseBadge
import com.bimo.learnflutter.ui.components.ErrorState
import com.bimo.learnflutter.ui.components.GradientProgressBar
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.ProgressRing
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import javax.inject.Inject

// ------------------------------------------------------------------ Courses list

data class CourseListItem(
    val course: Course,
    val completed: Int,
    val fraction: Float,
    val lockedReason: String?,
)

data class CoursesUiState(
    val loading: Boolean = true,
    val error: String? = null,
    val courses: List<CourseListItem> = emptyList(),
    val certificate: CertificateEligibility? = null,
)

@HiltViewModel
class CoursesViewModel @Inject constructor(
    private val curriculumRepository: CurriculumRepository,
    learning: LearningRepository,
) : ViewModel() {
    val state: StateFlow<CoursesUiState> = combine(
        curriculumRepository.state, learning.completedLessonIds, learning.certificateEligibility,
    ) { cs, completed, cert ->
        when (cs) {
            CurriculumState.Loading -> CoursesUiState()
            is CurriculumState.Failed -> CoursesUiState(loading = false, error = cs.message)
            is CurriculumState.Ready -> CoursesUiState(
                loading = false,
                courses = cs.curriculum.courses.map { c ->
                    val prereq = ProgressionEngine.prerequisiteMet(c, cs.curriculum, completed)
                    CourseListItem(
                        course = c,
                        completed = c.lessons.count { it.id in completed },
                        fraction = ProgressionEngine.courseFraction(c, completed),
                        lockedReason = if (prereq) null else ProgressionEngine.courseStates(c, cs.curriculum, completed, emptySet()).first().lockReason,
                    )
                },
                certificate = cert,
            )
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), CoursesUiState())

    fun retry() = curriculumRepository.reload()
}

@Composable
fun CoursesScreen(navigator: BimoNavigator, viewModel: CoursesViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    when {
        state.loading -> ListSkeleton()
        state.error != null -> ErrorState(state.error ?: "", onRetry = viewModel::retry)
        else -> LazyColumn(
            Modifier.fillMaxSize().statusBarsPadding(),
            contentPadding = PaddingValues(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            item {
                Text("Courses", style = MaterialTheme.typography.headlineMedium)
                Text(
                    "Lessons unlock one by one: finish a lesson and pass its quiz to open the next.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            items(state.courses, key = { it.course.id }) { item ->
                CourseListCard(item) { navigator.to(Routes.course(item.course.id)) }
            }
            item {
                FinalAssessmentCard(state.certificate) {
                    if (state.certificate?.finalExamUnlocked == true) navigator.to(Routes.finalExam())
                    else navigator.to(Routes.CERTIFICATE)
                }
            }
        }
    }
}

@Composable
private fun CourseListCard(item: CourseListItem, onClick: () -> Unit) {
    val c = item.course
    Surface(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 2.dp,
    ) {
        Column {
            Box(Modifier.fillMaxWidth().background(BimoGradients.forCourse(c.id)).padding(18.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Column(Modifier.weight(1f)) {
                        Text(c.level.uppercase(), style = MaterialTheme.typography.labelSmall, color = Color.White.copy(alpha = 0.85f))
                        Text(c.title, style = MaterialTheme.typography.titleLarge, color = Color.White)
                        Text(c.subtitle, style = MaterialTheme.typography.bodySmall, color = Color.White.copy(alpha = 0.9f))
                    }
                    ProgressRing(
                        item.fraction, size = 58.dp,
                        brush = androidx.compose.ui.graphics.SolidColor(Color.White),
                        trackColor = Color.White.copy(alpha = 0.25f),
                    ) { Text("${(item.fraction * 100).toInt()}%", color = Color.White, style = MaterialTheme.typography.labelMedium) }
                }
            }
            Column(Modifier.padding(16.dp)) {
                Text(c.description, style = MaterialTheme.typography.bodyMedium, maxLines = 3, overflow = TextOverflow.Ellipsis)
                Spacer(Modifier.height(10.dp))
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(Icons.Outlined.Schedule, null, modifier = Modifier.size(16.dp), tint = MaterialTheme.colorScheme.onSurfaceVariant)
                    Spacer(Modifier.width(4.dp))
                    Text(
                        "${c.modules.size} modules • ${c.lessonCount} lessons • ~${c.totalMinutes / 60} h",
                        style = MaterialTheme.typography.labelMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.weight(1f),
                    )
                    Text("${item.completed}/${c.lessonCount}", style = MaterialTheme.typography.labelLarge)
                }
                item.lockedReason?.let {
                    Spacer(Modifier.height(10.dp))
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(Icons.Filled.Lock, null, tint = MaterialTheme.colorScheme.outline, modifier = Modifier.size(16.dp))
                        Spacer(Modifier.width(6.dp))
                        Text(it, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                    }
                }
            }
        }
    }
}

@Composable
private fun FinalAssessmentCard(cert: CertificateEligibility?, onClick: () -> Unit) {
    val unlocked = cert?.finalExamUnlocked == true
    Surface(
        modifier = Modifier.fillMaxWidth().clickable(onClick = onClick),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 2.dp,
    ) {
        Row(Modifier.padding(18.dp), verticalAlignment = Alignment.CenterVertically) {
            Box(
                Modifier.size(52.dp).clip(RoundedCornerShape(16.dp)).background(BimoGradients.Gold),
                contentAlignment = Alignment.Center,
            ) { Icon(if (unlocked) Icons.AutoMirrored.Filled.FactCheck else Icons.Filled.Lock, null, tint = Color(0xFF3A2A00)) }
            Spacer(Modifier.width(14.dp))
            Column(Modifier.weight(1f)) {
                Text("Final assessment", style = MaterialTheme.typography.titleMedium)
                Text(
                    when {
                        cert?.finalExamPassed == true -> "Passed — view your certificate"
                        unlocked -> "Unlocked! Pass with 70% to earn your certificate."
                        else -> "Unlocks after you complete the Dart, Flutter and Projects courses."
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Icon(Icons.AutoMirrored.Filled.ArrowForward, contentDescription = null)
        }
    }
}

// ------------------------------------------------------------------ Course detail

data class ModuleUi(val progress: ModuleProgress, val lessons: List<LessonState>)

data class CourseDetailUiState(
    val loading: Boolean = true,
    val course: Course? = null,
    val modules: List<ModuleUi> = emptyList(),
    val fraction: Float = 0f,
    val nextLessonId: String? = null,
    val notFound: Boolean = false,
)

@HiltViewModel
class CourseDetailViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    curriculumRepository: CurriculumRepository,
    learning: LearningRepository,
) : ViewModel() {
    private val courseId: String = checkNotNull(savedStateHandle["courseId"])

    val state: StateFlow<CourseDetailUiState> = combine(
        curriculumRepository.curriculumFlow, learning.completedLessonIds, learning.progressByLesson,
    ) { curriculum, completed, progress ->
        val course = curriculum.course(courseId) ?: return@combine CourseDetailUiState(loading = false, notFound = true)
        val started = progress.keys
        val states = ProgressionEngine.courseStates(course, curriculum, completed, started).associateBy { it.lesson.id }
        CourseDetailUiState(
            loading = false,
            course = course,
            modules = course.modules.map { m ->
                ModuleUi(ProgressionEngine.moduleProgress(m, completed), m.lessons.mapNotNull { states[it.id] })
            },
            fraction = ProgressionEngine.courseFraction(course, completed),
            nextLessonId = ProgressionEngine.nextLesson(course, completed)
                ?.takeIf { ProgressionEngine.canOpen(it.id, curriculum, completed) }?.id,
        )
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), CourseDetailUiState())
}

@Composable
fun CourseDetailScreen(navigator: BimoNavigator, viewModel: CourseDetailViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    var lockedDialog by remember { mutableStateOf<String?>(null) }
    val course = state.course
    if (state.loading) { ListSkeleton(); return }
    if (course == null) {
        ErrorState("This course could not be found.", onRetry = { navigator.back() })
        return
    }
    // The module containing the next lesson starts expanded.
    val nextModuleId = state.modules.firstOrNull { m -> m.lessons.any { it.lesson.id == state.nextLessonId } }?.progress?.module?.id

    LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(bottom = 32.dp)) {
        item {
            Box(
                Modifier
                    .fillMaxWidth()
                    .clip(RoundedCornerShape(bottomStart = 32.dp, bottomEnd = 32.dp))
                    .background(BimoGradients.forCourse(course.id)),
            ) {
                Column(Modifier.statusBarsPadding().padding(start = 8.dp, end = 20.dp, bottom = 20.dp)) {
                    IconButton(onClick = navigator::back) {
                        Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back", tint = Color.White)
                    }
                    Row(Modifier.padding(start = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Column(Modifier.weight(1f)) {
                            Text(course.title, style = MaterialTheme.typography.headlineSmall, color = Color.White)
                            Text(course.subtitle, style = MaterialTheme.typography.bodyMedium, color = Color.White.copy(alpha = 0.9f))
                            Spacer(Modifier.height(8.dp))
                            Text(
                                "${course.modules.size} modules • ${course.lessonCount} lessons • ${course.level}",
                                style = MaterialTheme.typography.labelMedium,
                                color = Color.White.copy(alpha = 0.85f),
                            )
                        }
                        ProgressRing(
                            state.fraction, size = 72.dp,
                            brush = androidx.compose.ui.graphics.SolidColor(BimoColors.Accent),
                            trackColor = Color.White.copy(alpha = 0.25f),
                        ) { Text("${(state.fraction * 100).toInt()}%", color = Color.White, style = MaterialTheme.typography.titleSmall) }
                    }
                    state.nextLessonId?.let { next ->
                        Spacer(Modifier.height(16.dp))
                        Surface(
                            onClick = { navigator.to(Routes.lesson(next)) },
                            shape = CircleShape,
                            color = Color.White,
                            modifier = Modifier.padding(start = 12.dp),
                        ) {
                            Row(Modifier.padding(horizontal = 18.dp, vertical = 10.dp), verticalAlignment = Alignment.CenterVertically) {
                                Icon(Icons.Filled.PlayArrow, null, tint = Color(0xFF2B1C6E))
                                Spacer(Modifier.width(6.dp))
                                Text(if (state.fraction > 0f) "Continue course" else "Start course", color = Color(0xFF2B1C6E), style = MaterialTheme.typography.labelLarge)
                            }
                        }
                    }
                }
            }
        }
        items(state.modules, key = { it.progress.module.id }) { module ->
            ModuleSection(
                module = module,
                initiallyExpanded = module.progress.module.id == nextModuleId,
                onLesson = { ls ->
                    if (ls.isOpenable) navigator.to(Routes.lesson(ls.lesson.id)) else lockedDialog = ls.lockReason
                },
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp),
            )
        }
    }

    lockedDialog?.let { reason ->
        AlertDialog(
            onDismissRequest = { lockedDialog = null },
            icon = { Icon(Icons.Filled.Lock, null) },
            title = { Text("Lesson locked") },
            text = { Text(reason + "\n\nBimo teaches step by step so every lesson builds on the one before it.") },
            confirmButton = { TextButton(onClick = { lockedDialog = null }) { Text("Got it") } },
        )
    }
}

@Composable
private fun ModuleSection(
    module: ModuleUi,
    initiallyExpanded: Boolean,
    onLesson: (LessonState) -> Unit,
    modifier: Modifier = Modifier,
) {
    var expanded by rememberSaveable(module.progress.module.id) { mutableStateOf(initiallyExpanded) }
    val rotation by animateFloatAsState(if (expanded) 180f else 0f, label = "chevron")
    val p = module.progress
    Surface(
        modifier.fillMaxWidth().animateContentSize(),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 1.dp,
    ) {
        Column {
            Row(
                Modifier
                    .fillMaxWidth()
                    .clickable(role = Role.Button, onClickLabel = if (expanded) "Collapse module" else "Expand module") { expanded = !expanded }
                    .padding(16.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Box(
                    Modifier.size(40.dp).clip(RoundedCornerShape(12.dp))
                        .background(if (p.isComplete) BimoColors.Success else MaterialTheme.colorScheme.primaryContainer),
                    contentAlignment = Alignment.Center,
                ) {
                    if (p.isComplete) Icon(Icons.Filled.Check, "Module complete", tint = Color.White)
                    else Text("${p.module.number}", style = MaterialTheme.typography.titleMedium, color = MaterialTheme.colorScheme.primary)
                }
                Spacer(Modifier.width(12.dp))
                Column(Modifier.weight(1f)) {
                    Text("Module ${p.module.number}", style = MaterialTheme.typography.labelMedium, color = MaterialTheme.colorScheme.primary)
                    Text(p.module.title, style = MaterialTheme.typography.titleMedium)
                    Spacer(Modifier.height(6.dp))
                    GradientProgressBar(p.fraction, height = 6.dp)
                    Spacer(Modifier.height(2.dp))
                    Text("${p.completed}/${p.total} lessons", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                }
                Icon(Icons.Filled.ExpandMore, null, modifier = Modifier.rotate(rotation))
            }
            AnimatedVisibility(expanded) {
                Column(Modifier.padding(bottom = 8.dp)) {
                    if (p.module.summary.isNotBlank()) {
                        Text(
                            p.module.summary,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        )
                    }
                    module.lessons.forEachIndexed { index, ls -> LessonRow(index + 1, ls) { onLesson(ls) } }
                }
            }
        }
    }
}

@Composable
private fun LessonRow(number: Int, state: LessonState, onClick: () -> Unit) {
    val locked = state.status == LessonStatus.LOCKED
    val statusText = when (state.status) {
        LessonStatus.LOCKED -> "Locked"
        LessonStatus.AVAILABLE -> "Available"
        LessonStatus.IN_PROGRESS -> "In progress"
        LessonStatus.COMPLETED -> "Completed"
    }
    Row(
        Modifier
            .fillMaxWidth()
            .clickable(role = Role.Button, onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 10.dp)
            .semantics(mergeDescendants = true) { stateDescription = statusText },
        verticalAlignment = Alignment.CenterVertically,
    ) {
        Box(
            Modifier
                .size(34.dp)
                .clip(CircleShape)
                .background(
                    when (state.status) {
                        LessonStatus.COMPLETED -> BimoColors.Success
                        LessonStatus.LOCKED -> MaterialTheme.colorScheme.surfaceVariant
                        else -> MaterialTheme.colorScheme.primary
                    },
                ),
            contentAlignment = Alignment.Center,
        ) {
            when (state.status) {
                LessonStatus.COMPLETED -> Icon(Icons.Filled.Check, null, tint = Color.White, modifier = Modifier.size(18.dp))
                LessonStatus.LOCKED -> Icon(Icons.Filled.Lock, null, tint = MaterialTheme.colorScheme.outline, modifier = Modifier.size(16.dp))
                else -> Icon(Icons.Filled.PlayArrow, null, tint = Color.White, modifier = Modifier.size(18.dp))
            }
        }
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(
                "$number. ${state.lesson.title}",
                style = MaterialTheme.typography.bodyLarge,
                color = if (locked) MaterialTheme.colorScheme.onSurfaceVariant else MaterialTheme.colorScheme.onSurface,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis,
            )
            Text(
                "${state.lesson.minutes} min • ${state.lesson.quiz.questions.size} quiz questions" +
                    if (state.status == LessonStatus.IN_PROGRESS) " • In progress" else "",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
            )
        }
    }
}
