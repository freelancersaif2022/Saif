package com.bimo.learnflutter.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.expandVertically
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.shrinkVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.text.selection.SelectionContainer
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.ContentCopy
import androidx.compose.material.icons.filled.ExpandMore
import androidx.compose.material.icons.outlined.Info
import androidx.compose.material.icons.outlined.Lightbulb
import androidx.compose.material.icons.outlined.Psychology
import androidx.compose.material.icons.outlined.ReportProblem
import androidx.compose.material.icons.outlined.TaskAlt
import androidx.compose.material.icons.outlined.WarningAmber
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.LocalClipboardManager
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.heading
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.AnnotatedString
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import com.bimo.learnflutter.core.content.CalloutKind
import com.bimo.learnflutter.core.content.CodeTokenizer
import com.bimo.learnflutter.core.content.CollapsibleKind
import com.bimo.learnflutter.core.content.ContentBlock
import com.bimo.learnflutter.core.content.TokenKind
import com.bimo.learnflutter.ui.theme.BimoColors
import com.bimo.learnflutter.ui.theme.CodeTextStyle
import kotlinx.coroutines.delay

/**
 * Renders a lesson's content blocks. Designed to be emitted inside a LazyColumn item-by-item
 * (see [LessonBlock]) so very long lessons stay smooth.
 */
@Composable
fun LessonBlock(block: ContentBlock, modifier: Modifier = Modifier) {
    when (block) {
        is ContentBlock.Heading -> HeadingBlock(block, modifier)
        is ContentBlock.Paragraph -> Text(
            text = inlineMarkdown(block.text),
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onSurface,
            modifier = modifier,
        )
        is ContentBlock.ListBlock -> ListContent(block, modifier)
        is ContentBlock.Code -> CodeBlock(block.code, block.language, modifier)
        is ContentBlock.Callout -> CalloutCard(block, modifier)
        is ContentBlock.Collapsible -> CollapsibleCard(block, modifier)
        ContentBlock.Divider -> HorizontalDivider(modifier.padding(vertical = 4.dp))
    }
}

@Composable
private fun HeadingBlock(block: ContentBlock.Heading, modifier: Modifier) {
    val style = when (block.level) {
        1 -> MaterialTheme.typography.headlineSmall
        2 -> MaterialTheme.typography.titleLarge
        else -> MaterialTheme.typography.titleMedium
    }
    val icon = sectionIcon(block.text)
    Row(
        modifier
            .fillMaxWidth()
            .padding(top = if (block.level <= 2) 12.dp else 4.dp)
            .semantics { heading() },
        verticalAlignment = Alignment.CenterVertically,
    ) {
        if (icon != null && block.level <= 2) {
            Box(
                Modifier
                    .size(30.dp)
                    .clip(RoundedCornerShape(9.dp))
                    .background(MaterialTheme.colorScheme.primaryContainer),
                contentAlignment = Alignment.Center,
            ) {
                Icon(icon, null, tint = MaterialTheme.colorScheme.primary, modifier = Modifier.size(18.dp))
            }
            Spacer(Modifier.width(10.dp))
        }
        Text(block.text, style = style, color = MaterialTheme.colorScheme.onSurface)
    }
}

private fun sectionIcon(title: String): ImageVector? {
    val t = title.lowercase()
    return when {
        t.startsWith("learning objectives") -> Icons.Outlined.TaskAlt
        t.startsWith("common mistakes") -> Icons.Outlined.ReportProblem
        t.startsWith("best practices") -> Icons.Outlined.Lightbulb
        t.startsWith("exercise") || t.startsWith("practice") -> Icons.Outlined.Psychology
        t.startsWith("summary") || t.startsWith("key takeaways") -> Icons.Filled.Check
        t.startsWith("further learning") -> Icons.Outlined.Info
        else -> null
    }
}

@Composable
private fun ListContent(block: ContentBlock.ListBlock, modifier: Modifier) {
    Column(modifier.fillMaxWidth(), verticalArrangement = Arrangement.spacedBy(6.dp)) {
        block.items.forEachIndexed { index, item ->
            Row {
                if (block.ordered) {
                    Box(
                        Modifier
                            .padding(top = 2.dp)
                            .size(22.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primaryContainer),
                        contentAlignment = Alignment.Center,
                    ) {
                        Text("${index + 1}", style = MaterialTheme.typography.labelSmall, color = MaterialTheme.colorScheme.primary)
                    }
                } else {
                    Box(
                        Modifier
                            .padding(top = 10.dp, start = 6.dp, end = 6.dp)
                            .size(7.dp)
                            .clip(CircleShape)
                            .background(MaterialTheme.colorScheme.primary),
                    )
                }
                Spacer(Modifier.width(10.dp))
                Text(inlineMarkdown(item), style = MaterialTheme.typography.bodyLarge, modifier = Modifier.weight(1f))
            }
        }
    }
}

/** Parses `inline code`, **bold** and *italic* into an AnnotatedString. */
@Composable
fun inlineMarkdown(text: String): AnnotatedString {
    val codeBg = MaterialTheme.colorScheme.surfaceVariant
    val codeFg = MaterialTheme.colorScheme.primary
    return remember(text, codeBg, codeFg) {
        buildAnnotatedString {
            var i = 0
            while (i < text.length) {
                when {
                    text[i] == '`' -> {
                        val end = text.indexOf('`', i + 1)
                        if (end < 0) { append(text.substring(i)); i = text.length } else {
                            withStyle(SpanStyle(fontFamily = FontFamily.Monospace, background = codeBg, color = codeFg)) {
                                append(" " + text.substring(i + 1, end) + " ")
                            }
                            i = end + 1
                        }
                    }
                    text.startsWith("**", i) -> {
                        val end = text.indexOf("**", i + 2)
                        if (end < 0) { append(text.substring(i)); i = text.length } else {
                            withStyle(SpanStyle(fontWeight = FontWeight.Bold)) { append(text.substring(i + 2, end)) }
                            i = end + 2
                        }
                    }
                    text[i] == '*' && i + 1 < text.length && text[i + 1] != ' ' -> {
                        val end = text.indexOf('*', i + 1)
                        if (end < 0) { append(text[i]); i++ } else {
                            withStyle(SpanStyle(fontStyle = FontStyle.Italic)) { append(text.substring(i + 1, end)) }
                            i = end + 1
                        }
                    }
                    else -> { append(text[i]); i++ }
                }
            }
        }
    }
}

/** Syntax-highlighted, selectable, horizontally scrollable code block with a copy button. */
@Composable
fun CodeBlock(code: String, language: String, modifier: Modifier = Modifier, showLineNumbers: Boolean = true) {
    val clipboard = LocalClipboardManager.current
    var copied by remember { mutableStateOf(false) }
    LaunchedEffect(copied) {
        if (copied) { delay(1500); copied = false }
    }
    val isDiagram = language == "diagram"
    val highlighted = remember(code, language) { highlight(code, language) }
    val lines = remember(code) { code.lines().size }
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        color = if (isDiagram) MaterialTheme.colorScheme.surfaceContainerHigh else BimoColors.CodeBackground,
    ) {
        Column {
            Row(
                Modifier
                    .fillMaxWidth()
                    .background(if (isDiagram) MaterialTheme.colorScheme.surfaceContainerHighest else BimoColors.CodeHeader)
                    .padding(start = 14.dp, end = 4.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                if (!isDiagram) {
                    listOf(Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)).forEach {
                        Box(Modifier.padding(end = 6.dp).size(9.dp).clip(CircleShape).background(it))
                    }
                    Spacer(Modifier.width(6.dp))
                }
                Text(
                    text = languageLabel(language),
                    style = MaterialTheme.typography.labelMedium,
                    color = if (isDiagram) MaterialTheme.colorScheme.onSurfaceVariant else BimoColors.CodeComment,
                    modifier = Modifier.weight(1f),
                )
                IconButton(onClick = {
                    clipboard.setText(AnnotatedString(code))
                    copied = true
                }) {
                    Icon(
                        if (copied) Icons.Filled.Check else Icons.Filled.ContentCopy,
                        contentDescription = if (copied) "Copied" else "Copy code",
                        tint = if (copied) BimoColors.Accent else if (isDiagram) MaterialTheme.colorScheme.onSurfaceVariant else BimoColors.CodeComment,
                        modifier = Modifier.size(18.dp),
                    )
                }
            }
            Row(
                Modifier
                    .horizontalScroll(rememberScrollState())
                    .padding(vertical = 12.dp),
            ) {
                if (showLineNumbers && !isDiagram) {
                    Text(
                        text = (1..lines).joinToString("\n"),
                        style = CodeTextStyle,
                        color = BimoColors.CodeLineNumber,
                        modifier = Modifier.padding(start = 12.dp, end = 12.dp),
                    )
                }
                SelectionContainer {
                    Text(
                        text = highlighted,
                        style = CodeTextStyle,
                        color = if (isDiagram) MaterialTheme.colorScheme.onSurface else BimoColors.CodeText,
                        softWrap = false,
                        modifier = Modifier.padding(start = if (isDiagram) 16.dp else 0.dp, end = 16.dp),
                    )
                }
            }
        }
    }
}

private fun languageLabel(language: String): String = when (language.lowercase()) {
    "dart" -> "Dart"
    "yaml", "yml" -> "pubspec.yaml"
    "bash", "shell", "sh" -> "Terminal"
    "kotlin", "kt" -> "Kotlin"
    "json" -> "JSON"
    "diagram" -> "Diagram"
    "swift" -> "Swift"
    "groovy" -> "Gradle"
    "xml" -> "XML"
    else -> language.replaceFirstChar { it.uppercase() }
}

private fun highlight(code: String, language: String): AnnotatedString = buildAnnotatedString {
    append(code)
    CodeTokenizer.tokenize(code, language).forEach { token ->
        val color = when (token.kind) {
            TokenKind.KEYWORD -> BimoColors.CodeKeyword
            TokenKind.TYPE -> BimoColors.CodeType
            TokenKind.STRING -> BimoColors.CodeString
            TokenKind.NUMBER -> BimoColors.CodeNumber
            TokenKind.COMMENT -> BimoColors.CodeComment
            TokenKind.ANNOTATION -> BimoColors.CodeAnnotation
            TokenKind.FUNCTION -> BimoColors.CodeFunction
            TokenKind.PUNCTUATION -> BimoColors.CodePunctuation
            TokenKind.PLAIN -> return@forEach
        }
        val style = if (token.kind == TokenKind.COMMENT) SpanStyle(color = color, fontStyle = FontStyle.Italic) else SpanStyle(color = color)
        addStyle(style, token.start, token.end)
    }
}

@Composable
private fun CalloutCard(block: ContentBlock.Callout, modifier: Modifier) {
    val (icon, color, label) = when (block.kind) {
        CalloutKind.NOTE -> Triple(Icons.Outlined.Info, MaterialTheme.colorScheme.secondary, "Note")
        CalloutKind.TIP -> Triple(Icons.Outlined.Lightbulb, BimoColors.Success, "Tip")
        CalloutKind.WARNING -> Triple(Icons.Outlined.WarningAmber, BimoColors.Warning, "Warning")
        CalloutKind.MISTAKE -> Triple(Icons.Outlined.ReportProblem, BimoColors.Error, "Common mistake")
        CalloutKind.IMPORTANT -> Triple(Icons.Outlined.TaskAlt, MaterialTheme.colorScheme.primary, "Important")
    }
    Row(
        modifier
            .fillMaxWidth()
            .clip(RoundedCornerShape(16.dp))
            .background(color.copy(alpha = 0.10f))
            .border(1.dp, color.copy(alpha = 0.35f), RoundedCornerShape(16.dp))
            .padding(14.dp),
    ) {
        Icon(icon, contentDescription = label, tint = color, modifier = Modifier.size(22.dp))
        Spacer(Modifier.width(12.dp))
        Column(Modifier.weight(1f)) {
            Text(label, style = MaterialTheme.typography.labelLarge, color = color)
            Spacer(Modifier.height(2.dp))
            Text(inlineMarkdown(block.text), style = MaterialTheme.typography.bodyMedium)
        }
    }
}

@Composable
private fun CollapsibleCard(block: ContentBlock.Collapsible, modifier: Modifier) {
    var expanded by rememberSaveable(block.title) { mutableStateOf(false) }
    val rotation by animateFloatAsState(if (expanded) 180f else 0f, label = "chevron")
    val isSolution = block.kind == CollapsibleKind.SOLUTION
    val accent = if (isSolution) BimoColors.Success else MaterialTheme.colorScheme.secondary
    Surface(
        modifier = modifier.fillMaxWidth(),
        shape = RoundedCornerShape(16.dp),
        color = MaterialTheme.colorScheme.surfaceContainer,
        border = androidx.compose.foundation.BorderStroke(1.dp, accent.copy(alpha = 0.4f)),
    ) {
        Column {
            Row(
                Modifier
                    .fillMaxWidth()
                    .clickable(role = Role.Button, onClickLabel = if (expanded) "Hide" else "Reveal") { expanded = !expanded }
                    .padding(14.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Icon(
                    if (isSolution) Icons.Outlined.Lightbulb else Icons.Outlined.Psychology,
                    null, tint = accent, modifier = Modifier.size(22.dp),
                )
                Spacer(Modifier.width(10.dp))
                Column(Modifier.weight(1f)) {
                    Text(
                        if (isSolution) "Solution" else "Knowledge check",
                        style = MaterialTheme.typography.labelMedium,
                        color = accent,
                    )
                    Text(inlineMarkdown(block.title), style = MaterialTheme.typography.titleSmall)
                }
                Icon(Icons.Filled.ExpandMore, contentDescription = null, modifier = Modifier.rotate(rotation))
            }
            AnimatedVisibility(expanded, enter = expandVertically() + fadeIn(), exit = shrinkVertically() + fadeOut()) {
                Column(
                    Modifier.padding(start = 14.dp, end = 14.dp, bottom = 14.dp),
                    verticalArrangement = Arrangement.spacedBy(10.dp),
                ) {
                    block.blocks.forEach { LessonBlock(it) }
                }
            }
        }
    }
}
