package com.beam.share.ui

import android.widget.Toast
import androidx.compose.animation.core.tween
import androidx.compose.animation.fadeIn
import androidx.compose.animation.fadeOut
import androidx.compose.animation.slideInHorizontally
import androidx.compose.animation.slideOutHorizontally
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.beam.share.AppContainer
import com.beam.share.data.Settings
import com.beam.share.transfer.Direction
import com.beam.share.transfer.EngineEvent
import com.beam.share.transfer.Phase
import com.beam.share.ui.screens.HistoryScreen
import com.beam.share.ui.screens.HomeScreen
import com.beam.share.ui.screens.IncomingSheet
import com.beam.share.ui.screens.NearbyScreen
import com.beam.share.ui.screens.OnboardingScreen
import com.beam.share.ui.screens.PickerScreen
import com.beam.share.ui.screens.ReceiveScreen
import com.beam.share.ui.screens.SettingsScreen
import com.beam.share.ui.screens.TransferScreen
import com.beam.share.util.Permissions

object Routes {
    const val ONBOARDING = "onboarding"
    const val HOME = "home"
    const val PICKER = "picker"
    const val NEARBY = "nearby"
    const val RECEIVE = "receive"
    const val TRANSFER = "transfer"
    const val HISTORY = "history"
    const val SETTINGS = "settings"

    val tabs = setOf(HOME, HISTORY, SETTINGS)
}

/** Navigates to a bottom-bar tab without stacking copies of it. */
fun NavHostController.openTab(route: String) {
    navigate(route) {
        popUpTo(Routes.HOME) { saveState = true }
        launchSingleTop = true
        restoreState = true
    }
}

@Composable
fun BeamRoot(container: AppContainer, settings: Settings) {
    val context = LocalContext.current
    val nav = rememberNavController()
    val engine = container.engine
    val session by engine.session.collectAsStateWithLifecycle()
    val pendingShare by container.pendingShare.collectAsStateWithLifecycle()
    val backStack by nav.currentBackStackEntryAsState()
    val currentRoute = backStack?.destination?.route

    val start = remember {
        if (settings.onboarded && Permissions.hasNearby(context)) Routes.HOME else Routes.ONBOARDING
    }

    // Toasts from the engine ("Ali cancelled the request", …)
    LaunchedEffect(engine) {
        engine.events.collect { event ->
            when (event) {
                is EngineEvent.Message -> Toast.makeText(context, event.text, Toast.LENGTH_SHORT).show()
            }
        }
    }

    // Once a receive is accepted, jump to the progress screen from wherever the user is.
    LaunchedEffect(session?.id, session?.phase) {
        val s = session ?: return@LaunchedEffect
        if (s.direction == Direction.RECEIVE && s.phase == Phase.TRANSFERRING && currentRoute != Routes.TRANSFER) {
            nav.navigate(Routes.TRANSFER) { launchSingleTop = true }
        }
    }

    // Files shared from another app: go straight to the device list.
    LaunchedEffect(pendingShare, currentRoute) {
        if (pendingShare && currentRoute != null && currentRoute != Routes.ONBOARDING) {
            container.pendingShare.value = false
            if (session?.isActive != true) {
                nav.navigate(Routes.NEARBY) {
                    popUpTo(Routes.HOME)
                    launchSingleTop = true
                }
            }
        }
    }

    Box(Modifier.fillMaxSize().background(MaterialTheme.colorScheme.background)) {
        NavHost(
            navController = nav,
            startDestination = start,
            enterTransition = { slideInHorizontally(tween(280)) { it / 6 } + fadeIn(tween(280)) },
            exitTransition = { fadeOut(tween(180)) },
            popEnterTransition = { fadeIn(tween(220)) },
            popExitTransition = { slideOutHorizontally(tween(260)) { it / 6 } + fadeOut(tween(220)) },
        ) {
            composable(Routes.ONBOARDING) {
                OnboardingScreen(
                    container = container,
                    onDone = {
                        nav.navigate(Routes.HOME) {
                            popUpTo(Routes.ONBOARDING) { inclusive = true }
                        }
                    },
                )
            }
            composable(
                Routes.HOME,
                enterTransition = { fadeIn(tween(200)) },
                exitTransition = { fadeOut(tween(160)) },
            ) {
                HomeScreen(
                    container = container,
                    onSend = { nav.navigate(Routes.PICKER) },
                    onReceive = { nav.navigate(Routes.RECEIVE) },
                    onOpenTab = { nav.openTab(it) },
                )
            }
            composable(Routes.PICKER) {
                PickerScreen(
                    container = container,
                    onBack = { nav.popBackStack() },
                    onNext = { nav.navigate(Routes.NEARBY) },
                )
            }
            composable(Routes.NEARBY) {
                NearbyScreen(
                    container = container,
                    onBack = { nav.popBackStack() },
                    onChooseFiles = {
                        nav.navigate(Routes.PICKER) {
                            popUpTo(Routes.HOME)
                            launchSingleTop = true
                        }
                    },
                    onSending = { nav.navigate(Routes.TRANSFER) { launchSingleTop = true } },
                )
            }
            composable(Routes.RECEIVE) {
                ReceiveScreen(container = container, onBack = { nav.popBackStack() })
            }
            composable(Routes.TRANSFER) {
                TransferScreen(
                    container = container,
                    onClose = {
                        engine.dismiss()
                        if (!nav.popBackStack(Routes.HOME, inclusive = false)) nav.navigate(Routes.HOME)
                    },
                    onSendMore = {
                        engine.dismiss()
                        container.selection.clear()
                        nav.navigate(Routes.PICKER) { popUpTo(Routes.HOME) }
                    },
                    onRetry = {
                        engine.dismiss()
                        nav.navigate(Routes.NEARBY) { popUpTo(Routes.HOME) }
                    },
                )
            }
            composable(
                Routes.HISTORY,
                enterTransition = { fadeIn(tween(200)) },
                exitTransition = { fadeOut(tween(160)) },
            ) {
                HistoryScreen(container = container, onOpenTab = { nav.openTab(it) })
            }
            composable(
                Routes.SETTINGS,
                enterTransition = { fadeIn(tween(200)) },
                exitTransition = { fadeOut(tween(160)) },
            ) {
                SettingsScreen(container = container, onOpenTab = { nav.openTab(it) })
            }
        }

        val s = session
        if (s != null && s.direction == Direction.RECEIVE && s.phase == Phase.INCOMING_REQUEST) {
            IncomingSheet(
                session = s,
                onAccept = { engine.acceptIncoming() },
                onDecline = { engine.declineIncoming() },
            )
        }
    }
}
