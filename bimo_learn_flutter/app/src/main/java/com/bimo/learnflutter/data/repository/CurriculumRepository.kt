package com.bimo.learnflutter.data.repository

import android.content.Context
import android.util.Log
import com.bimo.learnflutter.core.content.Challenge
import com.bimo.learnflutter.core.content.ContentSource
import com.bimo.learnflutter.core.content.Curriculum
import com.bimo.learnflutter.core.content.CurriculumLoader
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

private class AssetContentSource(private val context: Context) : ContentSource {
    override fun list(dir: String): List<String> = context.assets.list(dir)?.sorted() ?: emptyList()
    override fun read(path: String): String = context.assets.open(path).bufferedReader().use { it.readText() }
}

sealed interface CurriculumState {
    data object Loading : CurriculumState
    data class Ready(val curriculum: Curriculum, val challenges: List<Challenge>) : CurriculumState
    data class Failed(val message: String) : CurriculumState
}

/**
 * Loads the bundled, offline curriculum once (off the main thread) and keeps it in memory.
 * Parsing ~300 lessons takes a few hundred milliseconds on a mid-range device.
 */
@Singleton
class CurriculumRepository @Inject constructor(
    @ApplicationContext private val context: Context,
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val mutex = Mutex()
    private val _state = MutableStateFlow<CurriculumState>(CurriculumState.Loading)
    val state: StateFlow<CurriculumState> = _state.asStateFlow()

    private val _curriculum = MutableStateFlow<Curriculum?>(null)

    init {
        scope.launch { load() }
    }

    fun reload() {
        scope.launch {
            _state.value = CurriculumState.Loading
            load(force = true)
        }
    }

    private suspend fun load(force: Boolean = false) = mutex.withLock {
        if (!force && _curriculum.value != null) return@withLock
        try {
            val source = AssetContentSource(context)
            val (curriculum, challenges) = withContext(Dispatchers.IO) {
                CurriculumLoader.load(source) to CurriculumLoader.loadChallenges(source)
            }
            _curriculum.value = curriculum
            _state.value = CurriculumState.Ready(curriculum, challenges)
        } catch (e: Exception) {
            Log.e("CurriculumRepository", "Failed to load curriculum", e)
            _state.value = CurriculumState.Failed(e.message ?: "Unknown error")
        }
    }

    /** Suspends until the curriculum is available. */
    suspend fun curriculum(): Curriculum = _curriculum.filterNotNull().first()

    val curriculumFlow = _curriculum.filterNotNull()
}
