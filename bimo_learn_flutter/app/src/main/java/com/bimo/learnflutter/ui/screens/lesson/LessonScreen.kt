package com.bimo.learnflutter.ui.screens.lesson

import androidx.compose.foundation.background
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
import androidx.compose.foundation.layout.widthIn
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Code
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Quiz
import androidx.compose.material.icons.filled.Replay
import androidx.compose.material.icons.outlined.Schedule
import androidx.compose.material.icons.outlined.TaskAlt
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.content.Course
import com.bimo.learnflutter.core.content.Lesson
import com.bimo.learnflutter.core.content.Module
import com.bimo.learnflutter.core.domain.ProgressionEngine
import com.bimo.learnflutter.data.repository.CurriculumRepository
import com.bimo.learnflutter.data.repository.LearningRepository
import com.bimo.learnflutter.ui.components.EmptyState
import com.bimo.learnflutter.ui.components.LessonBlock
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.inlineMarkdown
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.quiz.QuizMode
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed interface LessonUiState {
    data object Loading : LessonUiState
    data class Locked(val reason: String) : LessonUiState
    data object NotFound : LessonUiState
    data class Ready(
        val lesson: Lesson,
        val course: Course,
        val module: Module,
        val positionInModule: Int,
        val completed: Boolean,
        val bestScore: Int,
        val nextLessonId: String?,
    ) : LessonUiState
}

@HiltViewModel
class LessonViewModel @Inject constructor(
    savedStateHandle: SavedStateHandle,
    private val curriculumRepository: CurriculumRepository,
    private val learning: LearningRepository,
) : ViewModel() {
    private val lessonId: String = checkNotNull(savedStateHandle["lessonId"])
    private val _state = MutableStateFlow<LessonUiState>(LessonUiState.Loading)
    val state: StateFlow<LessonUiState> = _state.asStateFlow()

    init {
        viewModelScope.launch {
            val curriculum = curriculumRepository.curriculum()
            val lesson = curriculum.lesson(lessonId)
            if (lesson == null) {
                _state.value = LessonUiState.NotFound
                return@launch
            }
            // Guard: deep links or stale back stacks can never open a locked lesson.
            if (!learning.openLesson(lesson)) {
                val completed = learning.completedLessonIds
                var reason = "Complete the previous lesson first."
                completed.collectLatest { ids ->
                    reason = ProgressionEngine.lockReason(lesson.id, curriculum, ids) ?: reason
                    _state.value = LessonUiState.Locked(reason)
                }
                return@launch
            }
            val course = curriculum.course(lesson.courseId)!!
            val module = curriculum.module(lesson.moduleId)!!
            learning.observeLessonProgress(lesson.id).collectLatest { progress ->
                _state.value = LessonUiState.Ready(
                    lesson = lesson,
                    course = course,
                    module = module,
                    positionInModule = module.lessons.indexOfFirst { it.id == lesson.id } + 1,
                    completed = progress?.completedAt != null,
                    bestScore = progress?.bestScore ?: 0,
                    nextLessonId = ProgressionEngine.lessonAfter(lesson.id, curriculum)?.id,
                )
            }
        }
    }

    /** For lessons without a quiz: completes the lesson and returns the next lesson id. */
    fun completeWithoutQuiz(onDone: (String?) -> Unit) {
        val ready = _state.value as? LessonUiState.Ready ?: return
        viewModelScope.launch {
            learning.markLessonRead(ready.lesson)
            val outcome = learning.completeLessonWithoutQuiz(ready.lesson)
            onDone(outcome?.nextLessonId)
        }
    }

    /** Marks the content as read, then hands control to the quiz. */
    fun startQuiz(onReady: () -> Unit) {
        val ready = _state.value as? LessonUiState.Ready ?: return
        viewModelScope.launch {
            learning.markLessonRead(ready.lesson)
            onReady()
        }
    }
}

@Composable
fun LessonScreen(navigator: BimoNavigator, viewModel: LessonViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    when (val s = state) {
        LessonUiState.Loading -> ListSkeleton()
        LessonUiState.NotFound -> Box(Modifier.fillMaxSize().statusBarsPadding(), contentAlignment = Alignment.Center) {
            EmptyState(Icons.Filled.Lock, "Lesson not found", "This lesson is not part of the current curriculum.", actionLabel = "Go back", onAction = navigator::back)
        }
        is LessonUiState.Locked -> Box(Modifier.fillMaxSize().statusBarsPadding(), contentAlignment = Alignment.Center) {
            EmptyState(Icons.Filled.Lock, "This lesson is locked", s.reason, actionLabel = "Go back", onAction = navigator::back)
        }
        is LessonUiState.Ready -> LessonContentScreen(s, navigator, onComplete = {
            viewModel.completeWithoutQuiz { next -> if (next != null) navigator.replace(Routes.lesson(next)) else navigator.back() }
        }, onStartQuiz = {
            viewModel.startQuiz {
                navigator.to(Routes.quiz(if (s.completed) QuizMode.PRACTICE else QuizMode.LESSON, s.lesson.id))
            }
        })
    }
}

@Composable
private fun LessonContentScreen(state: LessonUiState.Ready, navigator: BimoNavigator, onComplete: () -> Unit, onStartQuiz: () -> Unit) {
    val lesson = state.lesson
    val listState = rememberLazyListState()
    val readProgress by remember {
        derivedStateOf {
            val info = listState.layoutInfo
            val lastVisible = info.visibleItemsInfo.lastOrNull()?.index ?: 0
            if (info.totalItemsCount == 0) 0f else ((lastVisible + 1).toFloat() / info.totalItemsCount).coerceIn(0f, 1f)
        }
    }

    Column(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Surface(color = MaterialTheme.colorScheme.surface, shadowElevation = 2.dp) {
            Column(Modifier.statusBarsPadding()) {
                Row(Modifier.padding(horizontal = 4.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
                    IconButton(onClick = navigator::back) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Back") }
                    Column(Modifier.weight(1f)) {
                        Text(
                            "${state.course.title} • Module ${state.module.number}",
                            style = MaterialTheme.typography.labelMedium,
                            color = MaterialTheme.colorScheme.primary,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis,
                        )
                        Text(lesson.title, style = MaterialTheme.typography.titleMedium, maxLines = 1, overflow = TextOverflow.Ellipsis)
                    }
                    if (state.completed) {
                        Icon(Icons.Filled.CheckCircle, "Completed", tint = BimoColors.Success, modifier = Modifier.padding(end = 12.dp))
                    }
                }
                LinearProgressIndicator(
                    progress = { readProgress },
                    modifier = Modifier.fillMaxWidth().height(3.dp),
                    trackColor = Color.Transparent,
                )
            }
        }

        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 20.dp, bottom = 40.dp),
            verticalArrangement = Arrangement.spacedBy(14.dp),
        ) {
            item(key = "header") { LessonHeader(state) }
            itemsIndexed(lesson.blocks, key = { index, _ -> "b$index" }) { _, block ->
                Box(Modifier.widthIn(max = 760.dp)) { LessonBlock(block) }
            }
            item(key = "footer") {
                LessonFooter(state, onStartQuiz, onComplete, onNext = { id -> navigator.replace(Routes.lesson(id)) })
            }
            item(key = "spacer") { Spacer(Modifier.navigationBarsPadding()) }
        }
    }
}

@Composable
private fun LessonHeader(state: LessonUiState.Ready) {
    val lesson = state.lesson
    Column {
        Box(
            Modifier
                .fillMaxWidth()
                .clip(RoundedCornerShape(24.dp))
                .background(BimoGradients.forCourse(state.course.id))
                .padding(20.dp),
        ) {
            Column {
                Text(
                    if (lesson.isProject) "PROJECT ${state.positionInModule}" else "LESSON ${state.positionInModule} OF ${state.module.lessons.size}",
                    style = MaterialTheme.typography.labelMedium,
                    color = Color.White.copy(alpha = 0.85f),
                )
                Spacer(Modifier.height(4.dp))
                Text(lesson.title, style = MaterialTheme.typography.headlineSmall, color = Color.White)
                Spacer(Modifier.height(12.dp))
                Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
                    MetaChip(Icons.Outlined.Schedule, "${lesson.minutes} min")
                    MetaChip(Icons.Filled.Code, "${lesson.codeExampleCount} examples")
                    if (lesson.quiz.questions.isNotEmpty()) MetaChip(Icons.Filled.Quiz, "${lesson.quiz.questions.size} questions")
                }
            }
        }
        val objectives = lesson.objectives
        if (objectives.isNotEmpty()) {
            Spacer(Modifier.height(14.dp))
            Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.primaryContainer) {
                Column(Modifier.fillMaxWidth().padding(16.dp)) {
                    Text("In this lesson you will", style = MaterialTheme.typography.titleSmall, color = MaterialTheme.colorScheme.onPrimaryContainer)
                    Spacer(Modifier.height(8.dp))
                    objectives.forEach {
                        Row(Modifier.padding(vertical = 3.dp)) {
                            Icon(Icons.Outlined.TaskAlt, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(18.dp))
                            Spacer(Modifier.width(8.dp))
                            Text(inlineMarkdown(it), style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.onPrimaryContainer)
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun MetaChip(icon: androidx.compose.ui.graphics.vector.ImageVector, text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Icon(icon, null, tint = Color.White, modifier = Modifier.size(16.dp))
        Spacer(Modifier.width(4.dp))
        Text(text, style = MaterialTheme.typography.labelMedium, color = Color.White)
    }
}

@Composable
private fun LessonFooter(state: LessonUiState.Ready, onStartQuiz: () -> Unit, onComplete: () -> Unit, onNext: (String) -> Unit) {
    Surface(
        shape = RoundedCornerShape(24.dp),
        color = MaterialTheme.colorScheme.surface,
        shadowElevation = 3.dp,
        modifier = Modifier.fillMaxWidth().padding(top = 12.dp),
    ) {
        Column(Modifier.padding(20.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            if (state.completed) {
                Icon(Icons.Filled.CheckCircle, null, tint = BimoColors.Success, modifier = Modifier.size(44.dp))
                Spacer(Modifier.height(8.dp))
                Text("Lesson completed", style = MaterialTheme.typography.titleMedium)
                Text("Best quiz score: ${state.bestScore}%", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(14.dp))
                state.nextLessonId?.let { next ->
                    Button(onClick = { onNext(next) }, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                        Text("Next lesson")
                        Spacer(Modifier.width(6.dp))
                        Icon(Icons.AutoMirrored.Filled.ArrowForward, null)
                    }
                    Spacer(Modifier.height(8.dp))
                }
                if (state.lesson.quiz.questions.isNotEmpty()) OutlinedButton(onClick = onStartQuiz, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                    Icon(Icons.Filled.Replay, null)
                    Spacer(Modifier.width(6.dp))
                    Text("Practise this quiz again")
                }
            } else if (state.lesson.quiz.questions.isEmpty()) {
                Icon(Icons.Filled.CheckCircle, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(44.dp))
                Spacer(Modifier.height(8.dp))
                Text("Finished reading?", style = MaterialTheme.typography.titleMedium)
                Text("Mark this lesson complete to unlock the next one.", style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                Spacer(Modifier.height(14.dp))
                Button(onClick = onComplete, modifier = Modifier.fillMaxWidth().height(50.dp)) { Text("Mark as complete") }
            } else {
                Icon(Icons.Filled.Quiz, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(44.dp))
                Spacer(Modifier.height(8.dp))
                Text("Ready for the quiz?", style = MaterialTheme.typography.titleMedium)
                Text(
                    "Score at least 70% to complete this lesson and unlock the next one. You can retry as often as you like.",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
                Spacer(Modifier.height(14.dp))
                Button(onClick = onStartQuiz, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                    Text("Take the quiz (${state.lesson.quiz.questions.size} questions)")
                }
            }
        }
    }
}
