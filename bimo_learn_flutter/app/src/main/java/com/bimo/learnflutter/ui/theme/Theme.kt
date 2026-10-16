package com.bimo.learnflutter.ui.theme

import android.app.Activity
import android.provider.Settings
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.remember
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.platform.LocalView
import androidx.compose.ui.unit.Density
import androidx.core.view.WindowCompat
import com.bimo.learnflutter.data.prefs.AccentPalette
import com.bimo.learnflutter.data.prefs.ThemeMode

/** True when animations should be reduced (user setting or the system "remove animations" option). */
val LocalReduceMotion = staticCompositionLocalOf { false }

/** Whether quiz sound effects are enabled. */
val LocalSoundEnabled = staticCompositionLocalOf { true }

private data class PaletteColors(
    val primary: Color, val secondary: Color, val tertiary: Color,
    val primaryDark: Color, val secondaryDark: Color, val tertiaryDark: Color,
)

private fun paletteColors(palette: AccentPalette) = when (palette) {
    AccentPalette.VIOLET -> PaletteColors(
        Color(0xFF6750F5), Color(0xFF0390A8), Color(0xFF4F7A00),
        Color(0xFFB4A8FF), Color(0xFF5ED6EC), Color(0xFFB9F34C),
    )
    AccentPalette.OCEAN -> PaletteColors(
        Color(0xFF0B63BE), Color(0xFF00897B), Color(0xFF00796B),
        Color(0xFF9CCBFF), Color(0xFF6ED8CB), Color(0xFF7FE7C4),
    )
    AccentPalette.SUNSET -> PaletteColors(
        Color(0xFFC8344A), Color(0xFFB85A12), Color(0xFF8A6A00),
        Color(0xFFFFB2BB), Color(0xFFFFB783), Color(0xFFFFD166),
    )
    AccentPalette.FOREST -> PaletteColors(
        Color(0xFF2E7D4F), Color(0xFF55822A), Color(0xFF7A6200),
        Color(0xFF8FD8A9), Color(0xFFB6DB8A), Color(0xFFF2C14E),
    )
    AccentPalette.MIDNIGHT -> PaletteColors(
        Color(0xFF3A3C8F), Color(0xFF8A6D1F), Color(0xFF6F5A12),
        Color(0xFFBFC2FF), Color(0xFFE8C766), Color(0xFFE8D48B),
    )
}

private fun lightScheme(p: PaletteColors): ColorScheme = lightColorScheme(
    primary = p.primary,
    onPrimary = Color.White,
    primaryContainer = p.primary.copy(alpha = 0.14f).compositeOver(BimoColors.BackgroundLight),
    onPrimaryContainer = p.primary.darken(0.45f),
    secondary = p.secondary,
    onSecondary = Color.White,
    secondaryContainer = p.secondary.copy(alpha = 0.16f).compositeOver(BimoColors.BackgroundLight),
    onSecondaryContainer = p.secondary.darken(0.5f),
    tertiary = p.tertiary,
    onTertiary = Color.White,
    tertiaryContainer = Color(0xFFE6FBC4),
    onTertiaryContainer = Color(0xFF243600),
    background = BimoColors.BackgroundLight,
    onBackground = Color(0xFF171A2B),
    surface = Color.White,
    onSurface = Color(0xFF171A2B),
    surfaceVariant = Color(0xFFEDEEF6),
    onSurfaceVariant = Color(0xFF4C5068),
    surfaceContainerLowest = Color.White,
    surfaceContainerLow = Color(0xFFF6F7FC),
    surfaceContainer = Color(0xFFF1F2F9),
    surfaceContainerHigh = Color(0xFFEBECF5),
    surfaceContainerHighest = Color(0xFFE5E6F0),
    outline = Color(0xFF7C809A),
    outlineVariant = Color(0xFFD9DBE8),
    error = Color(0xFFC62F3A),
    onError = Color.White,
    errorContainer = Color(0xFFFFDADB),
    onErrorContainer = Color(0xFF5F0A12),
)

private fun darkScheme(p: PaletteColors): ColorScheme = darkColorScheme(
    primary = p.primaryDark,
    onPrimary = Color(0xFF1A1050),
    primaryContainer = p.primary.copy(alpha = 0.35f).compositeOver(BimoColors.SurfaceDark),
    onPrimaryContainer = Color(0xFFE6E1FF),
    secondary = p.secondaryDark,
    onSecondary = Color(0xFF00363F),
    secondaryContainer = p.secondary.copy(alpha = 0.3f).compositeOver(BimoColors.SurfaceDark),
    onSecondaryContainer = Color(0xFFCDF6FF),
    tertiary = p.tertiaryDark,
    onTertiary = Color(0xFF1F2E00),
    tertiaryContainer = Color(0xFF34480C),
    onTertiaryContainer = Color(0xFFDCF8A8),
    background = BimoColors.BackgroundDark,
    onBackground = Color(0xFFE6E8F4),
    surface = BimoColors.SurfaceDark,
    onSurface = Color(0xFFE6E8F4),
    surfaceVariant = Color(0xFF2A2E40),
    onSurfaceVariant = Color(0xFFB9BDD3),
    surfaceContainerLowest = Color(0xFF0C0E16),
    surfaceContainerLow = Color(0xFF161926),
    surfaceContainer = Color(0xFF1B1E2B),
    surfaceContainerHigh = Color(0xFF232738),
    surfaceContainerHighest = Color(0xFF2B3043),
    outline = Color(0xFF8A8FA8),
    outlineVariant = Color(0xFF363B50),
    error = Color(0xFFFF8A8F),
    onError = Color(0xFF5F0A12),
    errorContainer = Color(0xFF7A1A22),
    onErrorContainer = Color(0xFFFFDADB),
)

private fun Color.compositeOver(background: Color): Color {
    val a = alpha
    return Color(
        red = red * a + background.red * (1 - a),
        green = green * a + background.green * (1 - a),
        blue = blue * a + background.blue * (1 - a),
        alpha = 1f,
    )
}

private fun Color.darken(fraction: Float): Color =
    Color(red * (1 - fraction), green * (1 - fraction), blue * (1 - fraction), alpha)

@Composable
fun BimoTheme(
    themeMode: ThemeMode = ThemeMode.SYSTEM,
    palette: AccentPalette = AccentPalette.VIOLET,
    textScale: Float = 1f,
    reduceMotion: Boolean = false,
    soundEnabled: Boolean = true,
    content: @Composable () -> Unit,
) {
    val dark = when (themeMode) {
        ThemeMode.SYSTEM -> isSystemInDarkTheme()
        ThemeMode.LIGHT -> false
        ThemeMode.DARK -> true
    }
    val colors = remember(dark, palette) {
        val p = paletteColors(palette)
        if (dark) darkScheme(p) else lightScheme(p)
    }
    val context = LocalContext.current
    val systemAnimationsOff = remember {
        runCatching {
            Settings.Global.getFloat(context.contentResolver, Settings.Global.ANIMATOR_DURATION_SCALE, 1f) == 0f
        }.getOrDefault(false)
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as? Activity)?.window ?: return@SideEffect
            val controller = WindowCompat.getInsetsController(window, view)
            controller.isAppearanceLightStatusBars = !dark
            controller.isAppearanceLightNavigationBars = !dark
        }
    }

    val density = LocalDensity.current
    CompositionLocalProvider(
        LocalDensity provides Density(density.density, density.fontScale * textScale),
        LocalReduceMotion provides (reduceMotion || systemAnimationsOff),
        LocalSoundEnabled provides soundEnabled,
    ) {
        MaterialTheme(
            colorScheme = colors,
            typography = BimoTypography,
            shapes = BimoShapes,
            content = content,
        )
    }
}
