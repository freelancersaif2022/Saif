package com.bimo.learnflutter.ui.screens.quiz

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedContent
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.scaleIn
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.animation.togetherWith
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.selection.selectableGroup
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.OndemandVideo
import androidx.compose.material.icons.filled.Replay
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.scale
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.semantics.LiveRegionMode
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.liveRegion
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.bimo.learnflutter.core.content.QuestionType
import com.bimo.learnflutter.core.domain.QuizAnswer
import com.bimo.learnflutter.core.domain.QuizGrader
import com.bimo.learnflutter.ui.components.CodeBlock
import com.bimo.learnflutter.ui.components.ConfettiOverlay
import com.bimo.learnflutter.ui.components.EmptyState
import com.bimo.learnflutter.ui.components.ListSkeleton
import com.bimo.learnflutter.ui.components.ProgressRing
import com.bimo.learnflutter.ui.components.findActivity
import com.bimo.learnflutter.ui.components.formatDuration
import com.bimo.learnflutter.ui.components.inlineMarkdown
import com.bimo.learnflutter.ui.components.rememberSoundPlayer
import com.bimo.learnflutter.ui.navigation.BimoNavigator
import com.bimo.learnflutter.ui.navigation.Routes
import com.bimo.learnflutter.ui.screens.achievements.achievementIcon
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.BimoGradients
import com.bimo.learnflutter.ui.theme.LocalReduceMotion

@Composable
fun QuizScreen(navigator: BimoNavigator, viewModel: QuizViewModel = hiltViewModel()) {
    val state by viewModel.state.collectAsStateWithLifecycle()
    when (val s = state) {
        QuizUiState.Loading -> ListSkeleton()
        is QuizUiState.Blocked -> Box(Modifier.fillMaxSize().statusBarsPadding(), contentAlignment = Alignment.Center) {
            EmptyState(Icons.Filled.Lock, s.title, s.message, actionLabel = "Go back", onAction = navigator::back)
        }
        is QuizUiState.Active -> ActiveQuiz(s, viewModel, navigator)
        is QuizUiState.Finished -> QuizResultView(s, viewModel, navigator)
    }
}

@Composable
private fun ActiveQuiz(state: QuizUiState.Active, viewModel: QuizViewModel, navigator: BimoNavigator) {
    var confirmExit by remember { mutableStateOf(false) }
    val sound = rememberSoundPlayer()
    val reduceMotion = LocalReduceMotion.current
    BackHandler { confirmExit = true }

    val progress by animateFloatAsState(
        (state.index + if (state.currentChecked) 1 else 0).toFloat() / state.questions.size,
        label = "quizProgress",
    )

    Column(
        Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .statusBarsPadding()
            .navigationBarsPadding()
            .imePadding(),
    ) {
        Row(Modifier.padding(horizontal = 8.dp, vertical = 4.dp), verticalAlignment = Alignment.CenterVertically) {
            IconButton(onClick = { confirmExit = true }) { Icon(Icons.Filled.Close, "Leave quiz") }
            Column(Modifier.weight(1f)) {
                Text(state.title, style = MaterialTheme.typography.titleSmall, maxLines = 1)
                Text(
                    "Question ${state.index + 1} of ${state.questions.size}" + if (state.mode == QuizMode.PRACTICE) " • Practice" else "",
                    style = MaterialTheme.typography.labelMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                )
            }
            Surface(shape = CircleShape, color = BimoColors.Success.copy(alpha = 0.15f), modifier = Modifier.padding(end = 12.dp)) {
                Text(
                    "✓ ${state.correctSoFar}",
                    Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                    style = MaterialTheme.typography.labelLarge,
                    color = BimoColors.Success,
                )
            }
        }
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier.fillMaxWidth().padding(horizontal = 20.dp).height(8.dp).clip(CircleShape),
        )

        AnimatedContent(
            targetState = state.index,
            transitionSpec = {
                if (reduceMotion) fadeIn() togetherWith fadeOut()
                else (slideInHorizontally { it / 3 } + fadeIn()) togetherWith (slideOutHorizontally { -it / 3 } + fadeOut())
            },
            modifier = Modifier.weight(1f),
            label = "question",
        ) { index ->
            val prepared = state.questions[index]
            val q = prepared.question
            val answer = state.answers[q.id]
            val checked = q.id in state.checked
            Column(
                Modifier
                    .fillMaxSize()
                    .verticalScroll(rememberScrollState())
                    .padding(20.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp),
            ) {
                Surface(shape = CircleShape, color = MaterialTheme.colorScheme.secondaryContainer) {
                    Text(
                        q.type.label.uppercase(),
                        Modifier.padding(horizontal = 12.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.labelSmall,
                        color = MaterialTheme.colorScheme.onSecondaryContainer,
                    )
                }
                Text(inlineMarkdown(q.prompt), style = MaterialTheme.typography.titleLarge)
                q.code?.let { CodeBlock(it, "dart") }
                when (q.type) {
                    QuestionType.FILL_BLANK -> FillAnswer(q.id, answer, checked, q.acceptedAnswers.first()) { viewModel.answer(it) }
                    QuestionType.CODE_ORDER -> OrderAnswer(prepared, answer, checked) { viewModel.answer(it) }
                    else -> ChoiceAnswer(prepared, answer, checked) { viewModel.answer(it) }
                }
                AnimatedVisibility(checked, enter = fadeIn() + slideInVertically { it / 4 }) {
                    Feedback(QuizGrader.isCorrect(q, answer), q.explanation, q.correctAnswerText, q.type)
                }
            }
        }

        val current = state.current.question
        val hasAnswer = when (val a = state.answers[current.id]) {
            null -> false
            is QuizAnswer.Text -> a.value.isNotBlank()
            else -> true
        } || current.type == QuestionType.CODE_ORDER
        Button(
            onClick = {
                if (!state.currentChecked) {
                    if (current.type == QuestionType.CODE_ORDER && state.answers[current.id] == null) {
                        viewModel.answer(QuizAnswer.Order(state.current.scrambled))
                    }
                    val correct = viewModel.check()
                    if (correct) sound?.correct() else sound?.wrong()
                } else {
                    viewModel.next()
                }
            },
            enabled = hasAnswer && !state.submitting,
            modifier = Modifier
                .fillMaxWidth()
                .padding(20.dp)
                .height(54.dp),
        ) {
            Text(
                when {
                    !state.currentChecked -> "Check answer"
                    state.isLast -> if (state.submitting) "Saving…" else "See results"
                    else -> "Next question"
                },
                style = MaterialTheme.typography.titleMedium,
            )
        }
    }

    if (confirmExit) {
        AlertDialog(
            onDismissRequest = { confirmExit = false },
            title = { Text("Leave the quiz?") },
            text = { Text("Your answers for this attempt will not be saved. You can restart the quiz at any time.") },
            confirmButton = { TextButton(onClick = { confirmExit = false; navigator.back() }) { Text("Leave") } },
            dismissButton = { TextButton(onClick = { confirmExit = false }) { Text("Keep going") } },
        )
    }
}

@Composable
private fun ChoiceAnswer(prepared: PreparedQuestion, answer: QuizAnswer?, checked: Boolean, onAnswer: (QuizAnswer) -> Unit) {
    val q = prepared.question
    val selected = (answer as? QuizAnswer.Choice)?.index
    Column(Modifier.selectableGroup(), verticalArrangement = Arrangement.spacedBy(10.dp)) {
        prepared.optionOrder.forEachIndexed { position, optionIndex ->
            val isSelected = selected == optionIndex
            val isCorrect = optionIndex == q.correctIndex
            val (border, bg) = when {
                checked && isCorrect -> BimoColors.Success to BimoColors.Success.copy(alpha = 0.12f)
                checked && isSelected -> BimoColors.Error to BimoColors.Error.copy(alpha = 0.12f)
                isSelected -> MaterialTheme.colorScheme.primary to MaterialTheme.colorScheme.primaryContainer
                else -> MaterialTheme.colorScheme.outlineVariant to MaterialTheme.colorScheme.surface
            }
            val scale by animateFloatAsState(if (checked && isCorrect) 1.02f else 1f, spring(), label = "optScale")
            Surface(
                shape = RoundedCornerShape(16.dp),
                color = bg,
                border = BorderStroke(if (isSelected || (checked && isCorrect)) 2.dp else 1.dp, border),
                modifier = Modifier
                    .fillMaxWidth()
                    .scale(scale)
                    .selectable(selected = isSelected, enabled = !checked, role = Role.RadioButton) {
                        onAnswer(QuizAnswer.Choice(optionIndex))
                    },
            ) {
                Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        Modifier.size(30.dp).clip(CircleShape).background(border.copy(alpha = 0.15f)),
                        contentAlignment = Alignment.Center,
                    ) {
                        when {
                            checked && isCorrect -> Icon(Icons.Filled.CheckCircle, "Correct answer", tint = BimoColors.Success)
                            checked && isSelected -> Icon(Icons.Filled.Cancel, "Your answer", tint = BimoColors.Error)
                            else -> Text(('A' + position).toString(), style = MaterialTheme.typography.labelLarge)
                        }
                    }
                    Spacer(Modifier.width(12.dp))
                    Text(inlineMarkdown(q.options[optionIndex]), style = MaterialTheme.typography.bodyLarge)
                }
            }
        }
    }
}

@Composable
private fun FillAnswer(id: String, answer: QuizAnswer?, checked: Boolean, correct: String, onAnswer: (QuizAnswer) -> Unit) {
    val text = (answer as? QuizAnswer.Text)?.value ?: ""
    OutlinedTextField(
        value = text,
        onValueChange = { onAnswer(QuizAnswer.Text(it)) },
        enabled = !checked,
        label = { Text("Your answer") },
        singleLine = true,
        textStyle = MaterialTheme.typography.bodyLarge.copy(fontFamily = FontFamily.Monospace),
        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.None, autoCorrectEnabled = false, imeAction = ImeAction.Done),
        supportingText = { Text(if (checked) "Accepted answer: $correct" else "Letter case and a trailing semicolon are ignored.") },
        modifier = Modifier.fillMaxWidth().semantics { contentDescription = "Answer for question $id" },
    )
}

@Composable
private fun OrderAnswer(prepared: PreparedQuestion, answer: QuizAnswer?, checked: Boolean, onAnswer: (QuizAnswer) -> Unit) {
    val items = remember(prepared.question.id) {
        mutableStateListOf<String>().apply { addAll((answer as? QuizAnswer.Order)?.items ?: prepared.scrambled) }
    }
    fun move(from: Int, to: Int) {
        if (to !in items.indices || checked) return
        val item = items.removeAt(from)
        items.add(to, item)
        onAnswer(QuizAnswer.Order(items.toList()))
    }
    Text(
        "Use the arrows to put the lines in the correct order.",
        style = MaterialTheme.typography.bodySmall,
        color = MaterialTheme.colorScheme.onSurfaceVariant,
    )
    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
        items.forEachIndexed { index, line ->
            val correctHere = checked && prepared.question.orderedItems.getOrNull(index)?.trim() == line.trim()
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = BimoColors.CodeBackground,
                border = BorderStroke(
                    if (checked) 2.dp else 1.dp,
                    when {
                        !checked -> BimoColors.CodeHeader
                        correctHere -> BimoColors.Success
                        else -> BimoColors.Error
                    },
                ),
            ) {
                Row(Modifier.fillMaxWidth().padding(start = 12.dp), verticalAlignment = Alignment.CenterVertically) {
                    Text("${index + 1}", color = BimoColors.CodeLineNumber, style = MaterialTheme.typography.labelMedium)
                    Spacer(Modifier.width(10.dp))
                    Text(
                        line,
                        color = BimoColors.CodeText,
                        style = MaterialTheme.typography.bodyMedium.copy(fontFamily = FontFamily.Monospace),
                        modifier = Modifier.weight(1f).padding(vertical = 10.dp),
                    )
                    IconButton(onClick = { move(index, index - 1) }, enabled = !checked && index > 0) {
                        Icon(Icons.Filled.ArrowUpward, "Move line ${index + 1} up", tint = BimoColors.CodeComment)
                    }
                    IconButton(onClick = { move(index, index + 1) }, enabled = !checked && index < items.lastIndex) {
                        Icon(Icons.Filled.ArrowDownward, "Move line ${index + 1} down", tint = BimoColors.CodeComment)
                    }
                }
            }
        }
    }
}

@Composable
private fun Feedback(correct: Boolean, explanation: String, correctAnswer: String, type: QuestionType) {
    val color = if (correct) BimoColors.Success else BimoColors.Error
    Surface(
        shape = RoundedCornerShape(18.dp),
        color = color.copy(alpha = 0.10f),
        border = BorderStroke(1.dp, color.copy(alpha = 0.4f)),
        modifier = Modifier.fillMaxWidth().semantics { liveRegion = LiveRegionMode.Polite },
    ) {
        Column(Modifier.padding(16.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(if (correct) Icons.Filled.CheckCircle else Icons.Filled.Cancel, null, tint = color)
                Spacer(Modifier.width(8.dp))
                Text(if (correct) "Correct!" else "Not quite", style = MaterialTheme.typography.titleMedium, color = color)
            }
            if (!correct && type != QuestionType.CODE_ORDER) {
                Spacer(Modifier.height(6.dp))
                Text(inlineMarkdown("Correct answer: **$correctAnswer**"), style = MaterialTheme.typography.bodyMedium)
            }
            if (!correct && type == QuestionType.CODE_ORDER) {
                Spacer(Modifier.height(6.dp))
                CodeBlock(correctAnswer, "dart", showLineNumbers = true)
            }
            Spacer(Modifier.height(6.dp))
            Text(inlineMarkdown(explanation), style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun QuizResultView(state: QuizUiState.Finished, viewModel: QuizViewModel, navigator: BimoNavigator) {
    val result = state.outcome.result
    val activity = LocalContext.current.findActivity()
    val sound = rememberSoundPlayer()
    LaunchedEffect(result) { if (result.passed) sound?.success() }

    fun leave(route: String?) {
        viewModel.continueAfterResult(activity) {
            if (route == null) navigator.back() else navigator.replace(route)
        }
    }
    BackHandler { leave(null) }

    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        Column(
            Modifier
                .fillMaxSize()
                .verticalScroll(rememberScrollState())
                .statusBarsPadding()
                .navigationBarsPadding()
                .padding(20.dp),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.spacedBy(16.dp),
        ) {
            Spacer(Modifier.height(12.dp))
            ProgressRing(
                result.percent / 100f,
                size = 150.dp,
                strokeWidth = 14.dp,
                brush = if (result.passed) BimoGradients.Brand else BimoGradients.Fire,
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Text("${result.percent}%", style = MaterialTheme.typography.displaySmall)
                    Text("${result.correct}/${result.total} correct", style = MaterialTheme.typography.labelMedium)
                }
            }
            Text(
                when {
                    result.perfect -> "Perfect score! 🎉"
                    result.passed -> "You passed!"
                    else -> "Almost there"
                },
                style = MaterialTheme.typography.headlineMedium,
                textAlign = TextAlign.Center,
            )
            Text(
                when {
                    state.mode == QuizMode.FINAL_EXAM && result.passed && state.outcome.certificateIssued ->
                        "You have completed the Bimo curriculum. Your certificate is ready."
                    state.mode == QuizMode.FINAL_EXAM && result.passed -> "Assessment passed."
                    state.mode == QuizMode.PRACTICE -> "Practice attempt saved to your quiz history. Completion rewards are only earned once."
                    result.passed && state.outcome.firstCompletion && state.outcome.nextLessonId != null -> "Lesson complete — the next lesson is now unlocked."
                    result.passed -> "Nice work! Your best score has been saved."
                    else -> "You need ${result.passPercent}% to pass. Review the explanations and try again — every attempt helps it stick."
                },
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                textAlign = TextAlign.Center,
            )
            Text("Time: ${formatDuration(state.durationSeconds)}", style = MaterialTheme.typography.labelMedium)

            state.outcome.completedModuleTitle?.let {
                Banner("Module complete: $it", BimoGradients.Projects)
            }
            if (state.outcome.courseCompleted) Banner("Course complete! Amazing dedication.", BimoGradients.Gold)

            if (state.outcome.awards.isNotEmpty() || state.rewardedBonus != null) {
                Surface(shape = RoundedCornerShape(20.dp), color = MaterialTheme.colorScheme.surface, shadowElevation = 1.dp, modifier = Modifier.fillMaxWidth()) {
                    Column(Modifier.padding(16.dp), verticalArrangement = Arrangement.spacedBy(6.dp)) {
                        val total = state.outcome.awards.sumOf { it.amount } + (state.rewardedBonus?.amount ?: 0)
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Icon(Icons.Filled.Star, null, tint = BimoColors.Gold)
                            Spacer(Modifier.width(6.dp))
                            Text("+$total XP earned", style = MaterialTheme.typography.titleMedium)
                        }
                        (state.outcome.awards + listOfNotNull(state.rewardedBonus)).forEach {
                            Row {
                                Text(it.reason, style = MaterialTheme.typography.bodyMedium, modifier = Modifier.weight(1f))
                                Text("+${it.amount}", style = MaterialTheme.typography.labelLarge, color = BimoColors.Gold)
                            }
                        }
                    }
                }
            }

            state.outcome.achievements.forEach { a ->
                AnimatedVisibility(visible = true, enter = scaleIn() + fadeIn()) {
                    Surface(shape = RoundedCornerShape(20.dp), color = Color.Transparent, modifier = Modifier.fillMaxWidth()) {
                        Row(
                            Modifier.background(BimoGradients.Premium).padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically,
                        ) {
                            Box(Modifier.size(44.dp).clip(CircleShape).background(BimoGradients.Gold), contentAlignment = Alignment.Center) {
                                Icon(achievementIcon(a.icon), null, tint = Color(0xFF3A2A00))
                            }
                            Spacer(Modifier.width(12.dp))
                            Column {
                                Text("Achievement unlocked", style = MaterialTheme.typography.labelMedium, color = BimoColors.Gold)
                                Text(a.title, style = MaterialTheme.typography.titleMedium, color = Color.White)
                                Text(a.description, style = MaterialTheme.typography.bodySmall, color = Color.White.copy(alpha = 0.85f))
                            }
                        }
                    }
                }
            }

            state.rewardMessage?.let { Text(it, style = MaterialTheme.typography.bodyMedium, color = MaterialTheme.colorScheme.primary) }
            if (state.rewardedAvailable) {
                OutlinedButton(onClick = { viewModel.watchRewarded(activity) }, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                    Icon(Icons.Filled.OndemandVideo, null)
                    Spacer(Modifier.width(8.dp))
                    Text("Watch an ad for +15 bonus XP (optional)")
                }
            }

            // Primary actions
            when {
                state.mode == QuizMode.FINAL_EXAM && result.passed -> PrimaryAction("View my certificate", Icons.Filled.EmojiEvents) { leave(Routes.CERTIFICATE) }
                result.passed && state.outcome.nextLessonId != null && state.mode == QuizMode.LESSON ->
                    PrimaryAction("Continue to next lesson", null) { leave(Routes.lesson(state.outcome.nextLessonId)) }
                result.passed && state.courseId != null -> PrimaryAction("Back to course", null) { leave(Routes.course(state.courseId)) }
                !result.passed -> PrimaryAction("Try again", Icons.Filled.Replay) { viewModel.retry() }
                else -> PrimaryAction("Done", null) { leave(null) }
            }
            if (result.wrongQuestionIds.isNotEmpty() && state.outcome.attemptId != null) {
                OutlinedButton(onClick = { navigator.to(Routes.review(state.outcome.attemptId)) }, modifier = Modifier.fillMaxWidth().height(50.dp)) {
                    Text("Review incorrect answers (${result.wrongQuestionIds.size})")
                }
            }
            if (!result.passed && state.lessonId != null) {
                TextButton(onClick = { navigator.replace(Routes.lesson(state.lessonId)) }) { Text("Re-read the lesson") }
            }
            if (result.passed && state.mode != QuizMode.FINAL_EXAM) {
                TextButton(onClick = { viewModel.retry() }) { Text("Retake quiz") }
            }
        }
        ConfettiOverlay(if (result.passed) result else null)
    }
}

@Composable
private fun PrimaryAction(label: String, icon: androidx.compose.ui.graphics.vector.ImageVector?, onClick: () -> Unit) {
    Button(
        onClick = onClick,
        modifier = Modifier.fillMaxWidth().height(54.dp),
        colors = ButtonDefaults.buttonColors(),
    ) {
        icon?.let { Icon(it, null); Spacer(Modifier.width(8.dp)) }
        Text(label, style = MaterialTheme.typography.titleMedium)
    }
}

@Composable
private fun Banner(text: String, brush: androidx.compose.ui.graphics.Brush) {
    Box(
        Modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(18.dp))
            .background(brush)
            .padding(14.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(text, style = MaterialTheme.typography.titleSmall, color = Color.White, textAlign = TextAlign.Center)
    }
}
