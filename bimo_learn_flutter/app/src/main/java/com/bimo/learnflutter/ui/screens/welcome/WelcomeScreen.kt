package com.bimo.learnflutter.ui.screens.welcome

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material3.Button
import androidx.compose.material3.FilterChip
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalFocusManager
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardCapitalization
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.bimo.learnflutter.core.domain.ProfileValidator
import com.bimo.learnflutter.data.repository.ExperienceLevel
import com.bimo.learnflutter.data.repository.ProfileRepository
import com.bimo.learnflutter.ui.components.BimoLogo
import com.bimo.learnflutter.ui.theme.BimoGradients
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

val LEARNING_GOALS = listOf(
    "Build my first app",
    "Get a Flutter developer job",
    "Level up existing skills",
    "Ship my startup idea",
    "Just curious",
)

val AVATAR_EMOJIS = listOf("🦊", "🐼", "🦉", "🐯", "🐙", "🚀", "🧠", "🦄")

@HiltViewModel
class WelcomeViewModel @Inject constructor(
    private val profiles: ProfileRepository,
) : ViewModel() {
    fun save(name: String, level: ExperienceLevel, goal: String, dailyGoal: Int, emoji: String, onDone: () -> Unit) {
        viewModelScope.launch {
            profiles.createProfile(name, level, goal, dailyGoal, emoji)
            onDone()
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun WelcomeScreen(
    onStart: () -> Unit,
    viewModel: WelcomeViewModel = hiltViewModel(),
) {
    var name by rememberSaveable { mutableStateOf("") }
    var nameError by rememberSaveable { mutableStateOf<String?>(null) }
    var level by rememberSaveable { mutableStateOf(ExperienceLevel.BEGINNER) }
    var goal by rememberSaveable { mutableStateOf(LEARNING_GOALS.first()) }
    var dailyGoal by rememberSaveable { mutableIntStateOf(1) }
    var emoji by rememberSaveable { mutableStateOf(AVATAR_EMOJIS.first()) }
    var saving by rememberSaveable { mutableStateOf(false) }
    val focus = LocalFocusManager.current

    fun submit() {
        val error = ProfileValidator.validateName(name)
        nameError = error
        if (error == null && !saving) {
            saving = true
            focus.clearFocus()
            viewModel.save(name, level, goal, dailyGoal, emoji, onStart)
        }
    }

    Box(
        Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background),
    ) {
        Box(
            Modifier
                .fillMaxWidth()
                .height(260.dp)
                .background(BimoGradients.BrandVertical),
        )
        Column(
            Modifier
                .fillMaxSize()
                .statusBarsPadding()
                .navigationBarsPadding()
                .imePadding()
                .verticalScroll(rememberScrollState())
                .padding(20.dp),
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                BimoLogo(size = 44.dp)
                Spacer(Modifier.width(12.dp))
                Column {
                    Text("Welcome to Bimo", style = MaterialTheme.typography.headlineSmall, color = Color.White)
                    Text("Learn Flutter & Dart, one lesson at a time.", style = MaterialTheme.typography.bodyMedium, color = Color.White.copy(alpha = 0.85f))
                }
            }
            Spacer(Modifier.height(24.dp))
            Surface(
                shape = RoundedCornerShape(28.dp),
                color = MaterialTheme.colorScheme.surface,
                shadowElevation = 6.dp,
                modifier = Modifier.fillMaxWidth(),
            ) {
                Column(Modifier.padding(20.dp), verticalArrangement = Arrangement.spacedBy(18.dp)) {
                    Text(
                        "No account needed. Your progress is saved on this device and everything works offline.",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                    )

                    Text("Pick an avatar", style = MaterialTheme.typography.titleMedium)
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(10.dp), verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        AVATAR_EMOJIS.forEach { e ->
                            val selected = e == emoji
                            Box(
                                Modifier
                                    .size(48.dp)
                                    .clip(CircleShape)
                                    .background(if (selected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceVariant)
                                    .selectable(selected, role = Role.RadioButton) { emoji = e },
                                contentAlignment = Alignment.Center,
                            ) { Text(e, fontSize = 24.sp) }
                        }
                    }

                    OutlinedTextField(
                        value = name,
                        onValueChange = {
                            if (it.length <= ProfileValidator.MAX_NAME_LENGTH) name = it
                            if (nameError != null) nameError = ProfileValidator.validateName(it)
                        },
                        label = { Text("Your name") },
                        placeholder = { Text("e.g. Alex Morgan") },
                        leadingIcon = { Icon(Icons.Outlined.Person, contentDescription = null) },
                        isError = nameError != null,
                        supportingText = {
                            Text(nameError ?: "Shown on your dashboard and on your certificate.")
                        },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(capitalization = KeyboardCapitalization.Words, imeAction = ImeAction.Done),
                        keyboardActions = KeyboardActions(onDone = { focus.clearFocus() }),
                        modifier = Modifier.fillMaxWidth(),
                    )

                    Text("Your experience", style = MaterialTheme.typography.titleMedium)
                    Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                        ExperienceLevel.entries.forEach { option ->
                            val selected = option == level
                            Surface(
                                shape = RoundedCornerShape(18.dp),
                                color = if (selected) MaterialTheme.colorScheme.primaryContainer else MaterialTheme.colorScheme.surfaceContainerLow,
                                border = BorderStroke(if (selected) 2.dp else 1.dp, if (selected) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.outlineVariant),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .selectable(selected, role = Role.RadioButton) { level = option },
                            ) {
                                Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                                    Column(Modifier.weight(1f)) {
                                        Text(option.label, style = MaterialTheme.typography.titleSmall)
                                        Text(option.description, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                    }
                                    if (selected) Icon(Icons.Filled.CheckCircle, contentDescription = "Selected", tint = MaterialTheme.colorScheme.primary)
                                }
                            }
                        }
                    }

                    Text("Your goal (optional)", style = MaterialTheme.typography.titleMedium)
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(8.dp), verticalArrangement = Arrangement.spacedBy(4.dp)) {
                        LEARNING_GOALS.forEach { g ->
                            FilterChip(selected = g == goal, onClick = { goal = g }, label = { Text(g) })
                        }
                    }

                    Text("Daily goal", style = MaterialTheme.typography.titleMedium)
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        listOf(1 to "Casual", 2 to "Regular", 3 to "Serious").forEach { (count, label) ->
                            val selected = count == dailyGoal
                            Surface(
                                shape = RoundedCornerShape(16.dp),
                                color = if (selected) MaterialTheme.colorScheme.secondaryContainer else MaterialTheme.colorScheme.surfaceContainerLow,
                                border = BorderStroke(1.dp, if (selected) MaterialTheme.colorScheme.secondary else MaterialTheme.colorScheme.outlineVariant),
                                modifier = Modifier
                                    .weight(1f)
                                    .clickable(role = Role.RadioButton) { dailyGoal = count },
                            ) {
                                Column(Modifier.padding(vertical = 12.dp), horizontalAlignment = Alignment.CenterHorizontally) {
                                    Text("$count", style = MaterialTheme.typography.headlineSmall)
                                    Text(if (count == 1) "lesson/day" else "lessons/day", style = MaterialTheme.typography.labelSmall)
                                    Text(label, style = MaterialTheme.typography.bodySmall, color = MaterialTheme.colorScheme.onSurfaceVariant, textAlign = TextAlign.Center)
                                }
                            }
                        }
                    }

                    Button(
                        onClick = ::submit,
                        enabled = !saving,
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(54.dp),
                    ) {
                        Text("Start learning", style = MaterialTheme.typography.titleMedium)
                    }
                }
            }
        }
    }
}
