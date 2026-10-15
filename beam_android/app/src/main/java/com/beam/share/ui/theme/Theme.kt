package com.beam.share.ui.theme

import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Shapes
import androidx.compose.material3.Typography
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.Immutable
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.beam.share.R

private val LightColors = lightColorScheme(
    primary = Color(0xFF2447D6),
    onPrimary = Color(0xFFFFFFFF),
    primaryContainer = Color(0xFFE6EBFC),
    onPrimaryContainer = Color(0xFF14298A),
    inversePrimary = Color(0xFF9DB0FF),
    secondary = Color(0xFFC2410C),
    onSecondary = Color(0xFFFFFFFF),
    secondaryContainer = Color(0xFFFDEBDD),
    onSecondaryContainer = Color(0xFF7A2A08),
    tertiary = Color(0xFF1E7A46),
    onTertiary = Color(0xFFFFFFFF),
    tertiaryContainer = Color(0xFFE3F2E9),
    onTertiaryContainer = Color(0xFF0E4A28),
    background = Color(0xFFF5F6F3),
    onBackground = Color(0xFF111513),
    surface = Color(0xFFF5F6F3),
    onSurface = Color(0xFF111513),
    surfaceVariant = Color(0xFFEEF0EC),
    onSurfaceVariant = Color(0xFF575E5A),
    surfaceTint = Color(0xFF2447D6),
    inverseSurface = Color(0xFF242826),
    inverseOnSurface = Color(0xFFF1F3F0),
    error = Color(0xFFB42318),
    onError = Color(0xFFFFFFFF),
    errorContainer = Color(0xFFFDE7E4),
    onErrorContainer = Color(0xFF7A1A10),
    outline = Color(0xFFC6CBC4),
    outlineVariant = Color(0xFFE3E6E1),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFFFFFFFF),
    surfaceDim = Color(0xFFE9EBE7),
    surfaceContainerLowest = Color(0xFFFFFFFF),
    surfaceContainerLow = Color(0xFFFFFFFF),
    surfaceContainer = Color(0xFFFFFFFF),
    surfaceContainerHigh = Color(0xFFFFFFFF),
    surfaceContainerHighest = Color(0xFFE8EAE6),
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFF8EA2FF),
    onPrimary = Color(0xFF0A1A6B),
    primaryContainer = Color(0xFF1D2D78),
    onPrimaryContainer = Color(0xFFDDE3FF),
    inversePrimary = Color(0xFF2447D6),
    secondary = Color(0xFFFFA071),
    onSecondary = Color(0xFF4A1A00),
    secondaryContainer = Color(0xFF4A220F),
    onSecondaryContainer = Color(0xFFFFDCCB),
    tertiary = Color(0xFF6FD69B),
    onTertiary = Color(0xFF003919),
    tertiaryContainer = Color(0xFF113A22),
    onTertiaryContainer = Color(0xFFBFF0D2),
    background = Color(0xFF0D100F),
    onBackground = Color(0xFFE9ECEA),
    surface = Color(0xFF0D100F),
    onSurface = Color(0xFFE9ECEA),
    surfaceVariant = Color(0xFF202522),
    onSurfaceVariant = Color(0xFFA6AEA9),
    surfaceTint = Color(0xFF8EA2FF),
    inverseSurface = Color(0xFFE9ECEA),
    inverseOnSurface = Color(0xFF1A1E1C),
    error = Color(0xFFFF8A80),
    onError = Color(0xFF5C0F08),
    errorContainer = Color(0xFF4A1410),
    onErrorContainer = Color(0xFFFFDAD5),
    outline = Color(0xFF4A514D),
    outlineVariant = Color(0xFF2A302D),
    scrim = Color(0xFF000000),
    surfaceBright = Color(0xFF2A2F2C),
    surfaceDim = Color(0xFF0D100F),
    surfaceContainerLowest = Color(0xFF131715),
    surfaceContainerLow = Color(0xFF161A18),
    surfaceContainer = Color(0xFF181D1A),
    surfaceContainerHigh = Color(0xFF1E2320),
    surfaceContainerHighest = Color(0xFF272C29),
)

val SpaceGrotesk = FontFamily(
    Font(R.font.space_grotesk_medium, FontWeight.Medium),
    Font(R.font.space_grotesk_semibold, FontWeight.SemiBold),
    Font(R.font.space_grotesk_bold, FontWeight.Bold),
)

val DmSans = FontFamily(
    Font(R.font.dm_sans_regular, FontWeight.Normal),
    Font(R.font.dm_sans_medium, FontWeight.Medium),
    Font(R.font.dm_sans_semibold, FontWeight.SemiBold),
    Font(R.font.dm_sans_bold, FontWeight.Bold),
)

private val BeamTypography = Typography(
    displayLarge = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 56.sp, lineHeight = 60.sp, letterSpacing = (-1.5).sp),
    displayMedium = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 44.sp, lineHeight = 48.sp, letterSpacing = (-1).sp),
    displaySmall = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 34.sp, lineHeight = 40.sp, letterSpacing = (-0.5).sp),
    headlineLarge = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 30.sp, lineHeight = 36.sp, letterSpacing = (-0.5).sp),
    headlineMedium = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 26.sp, lineHeight = 32.sp, letterSpacing = (-0.3).sp),
    headlineSmall = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 22.sp, lineHeight = 28.sp),
    titleLarge = TextStyle(fontFamily = SpaceGrotesk, fontWeight = FontWeight.Bold, fontSize = 20.sp, lineHeight = 26.sp),
    titleMedium = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.SemiBold, fontSize = 16.sp, lineHeight = 22.sp),
    titleSmall = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.SemiBold, fontSize = 14.sp, lineHeight = 20.sp),
    bodyLarge = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.Normal, fontSize = 16.sp, lineHeight = 24.sp),
    bodyMedium = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.Normal, fontSize = 14.sp, lineHeight = 20.sp),
    bodySmall = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.Normal, fontSize = 12.sp, lineHeight = 16.sp),
    labelLarge = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.SemiBold, fontSize = 15.sp, lineHeight = 20.sp),
    labelMedium = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.Medium, fontSize = 12.sp, lineHeight = 16.sp),
    labelSmall = TextStyle(fontFamily = DmSans, fontWeight = FontWeight.SemiBold, fontSize = 11.sp, lineHeight = 16.sp, letterSpacing = 0.6.sp),
)

private val BeamShapes = Shapes(
    extraSmall = RoundedCornerShape(8.dp),
    small = RoundedCornerShape(12.dp),
    medium = RoundedCornerShape(16.dp),
    large = RoundedCornerShape(24.dp),
    extraLarge = RoundedCornerShape(28.dp),
)

/** Extra brand colours that Material's scheme has no slot for. */
@Immutable
data class BeamExtraColors(
    val purpleContainer: Color,
    val onPurpleContainer: Color,
    val tealContainer: Color,
    val onTealContainer: Color,
    val amberContainer: Color,
    val onAmberContainer: Color,
    val success: Color,
    val onSuccess: Color,
)

private val LightExtra = BeamExtraColors(
    purpleContainer = Color(0xFFEDE4F5), onPurpleContainer = Color(0xFF5E3592),
    tealContainer = Color(0xFFDDF1F1), onTealContainer = Color(0xFF0F6060),
    amberContainer = Color(0xFFFBF0D6), onAmberContainer = Color(0xFF7A5000),
    success = Color(0xFF1E7A46), onSuccess = Color(0xFFFFFFFF),
)

private val DarkExtra = BeamExtraColors(
    purpleContainer = Color(0xFF33224A), onPurpleContainer = Color(0xFFE2CCFA),
    tealContainer = Color(0xFF0F3333), onTealContainer = Color(0xFFB5ECEC),
    amberContainer = Color(0xFF3D2C06), onAmberContainer = Color(0xFFFBE2A8),
    success = Color(0xFF6FD69B), onSuccess = Color(0xFF003919),
)

val LocalBeamColors = staticCompositionLocalOf { LightExtra }
val LocalIsDark = staticCompositionLocalOf { false }

object BeamTheme {
    val extra: BeamExtraColors
        @Composable get() = LocalBeamColors.current
}

@Composable
fun BeamTheme(darkTheme: Boolean, content: @Composable () -> Unit) {
    val colors: ColorScheme = if (darkTheme) DarkColors else LightColors
    CompositionLocalProvider(
        LocalBeamColors provides if (darkTheme) DarkExtra else LightExtra,
        LocalIsDark provides darkTheme,
    ) {
        MaterialTheme(
            colorScheme = colors,
            typography = BeamTypography,
            shapes = BeamShapes,
            content = content,
        )
    }
}
