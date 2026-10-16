package com.bimo.learnflutter.ui.navigation

import androidx.annotation.StringRes
import androidx.compose.animation.AnimatedContentTransitionScope
import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.MenuBook
import androidx.compose.material.icons.automirrored.outlined.MenuBook
import androidx.compose.material.icons.filled.EmojiEvents
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Psychology
import androidx.compose.material.icons.outlined.EmojiEvents
import androidx.compose.material.icons.outlined.Home
import androidx.compose.material.icons.outlined.Person
import androidx.compose.material.icons.outlined.Psychology
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.bimo.learnflutter.R
import com.bimo.learnflutter.core.domain.StartDestination
import com.bimo.learnflutter.ui.screens.achievements.AchievementsScreen
import com.bimo.learnflutter.ui.screens.certificate.CertificateScreen
import com.bimo.learnflutter.ui.screens.courses.CourseDetailScreen
import com.bimo.learnflutter.ui.screens.courses.CoursesScreen
import com.bimo.learnflutter.ui.screens.home.HomeScreen
import com.bimo.learnflutter.ui.screens.lesson.LessonScreen
import com.bimo.learnflutter.ui.screens.onboarding.OnboardingScreen
import com.bimo.learnflutter.ui.screens.practice.ChallengeScreen
import com.bimo.learnflutter.ui.screens.practice.HistoryScreen
import com.bimo.learnflutter.ui.screens.practice.PracticeScreen
import com.bimo.learnflutter.ui.screens.practice.ReviewScreen
import com.bimo.learnflutter.ui.screens.premium.PremiumScreen
import com.bimo.learnflutter.ui.screens.profile.InsightsScreen
import com.bimo.learnflutter.ui.screens.profile.ProfileScreen
import com.bimo.learnflutter.ui.screens.quiz.QuizMode
import com.bimo.learnflutter.ui.screens.quiz.QuizScreen
import com.bimo.learnflutter.ui.screens.settings.LegalScreen
import com.bimo.learnflutter.ui.screens.settings.SettingsScreen
import com.bimo.learnflutter.ui.screens.welcome.WelcomeScreen
import com.bimo.learnflutter.ui.theme.LocalReduceMotion

object Routes {
    const val ONBOARDING = "onboarding"
    const val WELCOME = "welcome"
    const val HOME = "home"
    const val COURSES = "courses"
    const val PRACTICE = "practice"
    const val ACHIEVEMENTS = "achievements"
    const val PROFILE = "profile"
    const val COURSE = "course/{courseId}"
    const val LESSON = "lesson/{lessonId}"
    const val QUIZ = "quiz/{mode}/{id}"
    const val CERTIFICATE = "certificate"
    const val PREMIUM = "premium"
    const val SETTINGS = "settings"
    const val HISTORY = "history"
    const val REVIEW = "review/{attemptId}"
    const val CHALLENGE = "challenge/{challengeId}"
    const val LEGAL = "legal/{doc}"
    const val INSIGHTS = "insights"

    fun course(id: String) = "course/$id"
    fun lesson(id: String) = "lesson/$id"
    fun quiz(mode: QuizMode, id: String) = "quiz/${mode.name}/$id"
    fun finalExam() = quiz(QuizMode.FINAL_EXAM, "final")
    fun review(attemptId: Long) = "review/$attemptId"
    /** Review of the most recent mistakes across all quizzes. */
    const val MISTAKES = "review/-1"
    fun challenge(id: String) = "challenge/$id"
    fun legal(doc: String) = "legal/$doc"
}

private data class TopLevel(val route: String, @StringRes val label: Int, val selected: ImageVector, val unselected: ImageVector)

private val topLevel = listOf(
    TopLevel(Routes.HOME, R.string.nav_home, Icons.Filled.Home, Icons.Outlined.Home),
    TopLevel(Routes.COURSES, R.string.nav_courses, Icons.AutoMirrored.Filled.MenuBook, Icons.AutoMirrored.Outlined.MenuBook),
    TopLevel(Routes.PRACTICE, R.string.nav_practice, Icons.Filled.Psychology, Icons.Outlined.Psychology),
    TopLevel(Routes.ACHIEVEMENTS, R.string.nav_achievements, Icons.Filled.EmojiEvents, Icons.Outlined.EmojiEvents),
    TopLevel(Routes.PROFILE, R.string.nav_profile, Icons.Filled.Person, Icons.Outlined.Person),
)

/** Navigation actions shared by all screens. */
class BimoNavigator(private val nav: NavHostController) {
    fun back() { nav.popBackStack() }
    fun to(route: String) { nav.navigate(route) { launchSingleTop = true } }
    fun tab(route: String) {
        nav.navigate(route) {
            popUpTo(nav.graph.findStartDestination().id) { saveState = true }
            launchSingleTop = true
            restoreState = true
        }
    }
    /** Replaces the current screen, e.g. lesson → quiz → next lesson without a deep back stack. */
    fun replace(route: String) {
        val current = nav.currentDestination?.route
        nav.navigate(route) {
            if (current != null) popUpTo(current) { inclusive = true }
            launchSingleTop = true
        }
    }
    fun resetTo(route: String) {
        nav.navigate(route) {
            popUpTo(0) { inclusive = true }
            launchSingleTop = true
        }
    }
}

@Composable
fun BimoNavHost(startDestination: StartDestination) {
    val navController = rememberNavController()
    val navigator = remember(navController) { BimoNavigator(navController) }
    val backStack by navController.currentBackStackEntryAsState()
    val currentRoute = backStack?.destination?.route
    val showBottomBar = topLevel.any { it.route == currentRoute }
    val reduceMotion = LocalReduceMotion.current

    val start = when (startDestination) {
        StartDestination.ONBOARDING -> Routes.ONBOARDING
        StartDestination.WELCOME -> Routes.WELCOME
        StartDestination.HOME -> Routes.HOME
    }

    val enter: AnimatedContentTransitionScope<NavBackStackEntry>.() -> EnterTransition = {
        if (reduceMotion) EnterTransition.None
        else fadeIn(tween(220)) + slideIntoContainer(AnimatedContentTransitionScope.SlideDirection.Start, tween(280)) { it / 8 }
    }
    val exit: AnimatedContentTransitionScope<NavBackStackEntry>.() -> ExitTransition = {
        if (reduceMotion) ExitTransition.None else fadeOut(tween(180))
    }
    val popEnter: AnimatedContentTransitionScope<NavBackStackEntry>.() -> EnterTransition = {
        if (reduceMotion) EnterTransition.None
        else fadeIn(tween(220)) + slideIntoContainer(AnimatedContentTransitionScope.SlideDirection.End, tween(280)) { it / 8 }
    }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        bottomBar = {
            if (showBottomBar) {
                NavigationBar(containerColor = MaterialTheme.colorScheme.surface, tonalElevation = 3.dp) {
                    topLevel.forEach { item ->
                        val selected = currentRoute == item.route
                        NavigationBarItem(
                            selected = selected,
                            onClick = { navigator.tab(item.route) },
                            icon = { Icon(if (selected) item.selected else item.unselected, contentDescription = null) },
                            label = { Text(stringResource(item.label)) },
                        )
                    }
                }
            }
        },
    ) { padding ->
        Box(Modifier.fillMaxSize().padding(padding)) {
            NavHost(
                navController = navController,
                startDestination = start,
                enterTransition = { enter() },
                exitTransition = { exit() },
                popEnterTransition = { popEnter() },
                popExitTransition = { exit() },
            ) {
                composable(Routes.ONBOARDING) {
                    OnboardingScreen(onFinished = { navigator.resetTo(Routes.WELCOME) })
                }
                composable(Routes.WELCOME) {
                    WelcomeScreen(onStart = { navigator.resetTo(Routes.HOME) })
                }
                composable(Routes.HOME) { HomeScreen(navigator) }
                composable(Routes.COURSES) { CoursesScreen(navigator) }
                composable(Routes.PRACTICE) { PracticeScreen(navigator) }
                composable(Routes.ACHIEVEMENTS) { AchievementsScreen(navigator) }
                composable(Routes.PROFILE) { ProfileScreen(navigator) }
                composable(Routes.COURSE, arguments = listOf(navArgument("courseId") { type = NavType.StringType })) {
                    CourseDetailScreen(navigator)
                }
                composable(Routes.LESSON, arguments = listOf(navArgument("lessonId") { type = NavType.StringType })) {
                    LessonScreen(navigator)
                }
                composable(
                    Routes.QUIZ,
                    arguments = listOf(
                        navArgument("mode") { type = NavType.StringType },
                        navArgument("id") { type = NavType.StringType },
                    ),
                ) { QuizScreen(navigator) }
                composable(Routes.CERTIFICATE) { CertificateScreen(navigator) }
                composable(Routes.PREMIUM) { PremiumScreen(navigator) }
                composable(Routes.SETTINGS) { SettingsScreen(navigator) }
                composable(Routes.HISTORY) { HistoryScreen(navigator) }
                composable(Routes.REVIEW, arguments = listOf(navArgument("attemptId") { type = NavType.LongType })) {
                    ReviewScreen(navigator)
                }
                composable(Routes.CHALLENGE, arguments = listOf(navArgument("challengeId") { type = NavType.StringType })) {
                    ChallengeScreen(navigator)
                }
                composable(Routes.LEGAL, arguments = listOf(navArgument("doc") { type = NavType.StringType })) {
                    LegalScreen(navigator)
                }
                composable(Routes.INSIGHTS) { InsightsScreen(navigator) }
            }
        }
    }
}
