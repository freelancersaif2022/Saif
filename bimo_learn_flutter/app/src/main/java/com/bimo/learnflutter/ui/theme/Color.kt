package com.bimo.learnflutter.ui.theme

import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color

object BimoColors {
    val Primary = Color(0xFF6750F5)
    val Secondary = Color(0xFF03B6D4)
    val Accent = Color(0xFFB9F34C)
    val BackgroundLight = Color(0xFFF8F9FD)
    val BackgroundDark = Color(0xFF10121C)
    val SurfaceDark = Color(0xFF1B1E2B)
    val Gold = Color(0xFFE0B84A)
    val Success = Color(0xFF22A06B)
    val SuccessContainer = Color(0xFFD7F5E6)
    val Error = Color(0xFFE5484D)
    val Warning = Color(0xFFF5A524)
    val Fire = Color(0xFFFF7A1A)

    // Code editor palette (used in both themes for a consistent "IDE" look).
    val CodeBackground = Color(0xFF151827)
    val CodeHeader = Color(0xFF1F2335)
    val CodeText = Color(0xFFE3E6F3)
    val CodeKeyword = Color(0xFFC792EA)
    val CodeType = Color(0xFF82AAFF)
    val CodeString = Color(0xFFC3E88D)
    val CodeNumber = Color(0xFFF78C6C)
    val CodeComment = Color(0xFF7A819E)
    val CodeAnnotation = Color(0xFFFFCB6B)
    val CodeFunction = Color(0xFF89DDFF)
    val CodePunctuation = Color(0xFFB4BAD6)
    val CodeLineNumber = Color(0xFF4B5170)
}

/** Brand gradients. */
object BimoGradients {
    val Brand = Brush.linearGradient(listOf(Color(0xFF6750F5), Color(0xFF03B6D4)))
    val BrandVertical = Brush.verticalGradient(listOf(Color(0xFF6750F5), Color(0xFF4F8DF0), Color(0xFF03B6D4)))
    val Dart = Brush.linearGradient(listOf(Color(0xFF0175C2), Color(0xFF03B6D4)))
    val Flutter = Brush.linearGradient(listOf(Color(0xFF6750F5), Color(0xFF02569B)))
    val Projects = Brush.linearGradient(listOf(Color(0xFF2E9E6A), Color(0xFF9BD23C)))
    val Premium = Brush.linearGradient(listOf(Color(0xFF2B1C6E), Color(0xFF6750F5), Color(0xFFE0B84A)))
    val Fire = Brush.linearGradient(listOf(Color(0xFFFF5F6D), Color(0xFFFFC371)))
    val Gold = Brush.linearGradient(listOf(Color(0xFFF5D976), Color(0xFFC9A227)))

    fun forCourse(courseId: String): Brush = when (courseId) {
        "dart" -> Dart
        "flutter" -> Flutter
        "projects" -> Projects
        else -> Brand
    }
}
