package com.beam.share.ui.screens

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import com.beam.share.BeamApp
import com.beam.share.media.AppEntry
import com.beam.share.media.MediaEntry
import com.beam.share.util.Permissions
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

enum class PickerTab(val label: String) { PHOTOS("Photos"), VIDEOS("Videos"), APPS("Apps"), FILES("Files") }

data class LoadState<T>(val loading: Boolean = false, val loaded: Boolean = false, val items: List<T> = emptyList())

class PickerViewModel(app: Application) : AndroidViewModel(app) {
    private val media = (app as BeamApp).container.media

    private val _photos = MutableStateFlow(LoadState<MediaEntry>())
    val photos: StateFlow<LoadState<MediaEntry>> = _photos.asStateFlow()

    private val _videos = MutableStateFlow(LoadState<MediaEntry>())
    val videos: StateFlow<LoadState<MediaEntry>> = _videos.asStateFlow()

    private val _apps = MutableStateFlow(LoadState<AppEntry>())
    val apps: StateFlow<LoadState<AppEntry>> = _apps.asStateFlow()

    private val _tab = MutableStateFlow(PickerTab.PHOTOS)
    val tab: StateFlow<PickerTab> = _tab.asStateFlow()

    fun select(tab: PickerTab) {
        _tab.value = tab
        ensureLoaded(tab)
    }

    fun ensureLoaded(tab: PickerTab, force: Boolean = false) {
        val context = getApplication<Application>()
        when (tab) {
            PickerTab.PHOTOS -> if (Permissions.hasMediaAccess(context) && (force || !_photos.value.loaded) && !_photos.value.loading) {
                _photos.value = _photos.value.copy(loading = true)
                viewModelScope.launch { _photos.value = LoadState(loaded = true, items = media.loadImages()) }
            }
            PickerTab.VIDEOS -> if (Permissions.hasMediaAccess(context) && (force || !_videos.value.loaded) && !_videos.value.loading) {
                _videos.value = _videos.value.copy(loading = true)
                viewModelScope.launch { _videos.value = LoadState(loaded = true, items = media.loadVideos()) }
            }
            PickerTab.APPS -> if ((force || !_apps.value.loaded) && !_apps.value.loading) {
                _apps.value = _apps.value.copy(loading = true)
                viewModelScope.launch { _apps.value = LoadState(loaded = true, items = media.loadApps()) }
            }
            PickerTab.FILES -> Unit
        }
    }

    fun reloadMedia() {
        ensureLoaded(PickerTab.PHOTOS, force = true)
        ensureLoaded(PickerTab.VIDEOS, force = true)
    }
}
