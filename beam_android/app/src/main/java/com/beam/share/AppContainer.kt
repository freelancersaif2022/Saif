package com.beam.share

import android.app.Application
import androidx.room.Room
import com.beam.share.data.HistoryRepository
import com.beam.share.data.SelectionStore
import com.beam.share.data.Settings
import com.beam.share.data.SettingsRepository
import com.beam.share.data.db.BeamDatabase
import com.beam.share.media.MediaRepository
import com.beam.share.transfer.TransferEngine
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn

/** Simple manual dependency container, created once in [BeamApp]. */
class AppContainer(app: Application) {
    val appScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)

    val settingsRepository = SettingsRepository(app)
    val settings: StateFlow<Settings?> = settingsRepository.settings
        .stateIn(appScope, SharingStarted.Eagerly, null)

    private val database = Room.databaseBuilder(app, BeamDatabase::class.java, "beam.db")
        .fallbackToDestructiveMigration()
        .build()

    val history = HistoryRepository(database.transferDao())
    val media = MediaRepository(app)
    val selection = SelectionStore()

    /** Set when files arrive through Android's Share menu; the UI then jumps to the device list. */
    val pendingShare = MutableStateFlow(false)

    val engine = TransferEngine(app, settings, history, appScope)
}
