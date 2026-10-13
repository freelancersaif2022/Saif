package com.saif.browser.engine

import android.net.Uri
import android.webkit.GeolocationPermissions
import android.webkit.HttpAuthHandler
import android.webkit.PermissionRequest
import android.webkit.ValueCallback

class PendingFileChooser(
    val callback: ValueCallback<Array<Uri>>,
    val acceptTypes: List<String>,
    val multiple: Boolean,
)

class PendingGeolocation(val origin: String, val callback: GeolocationPermissions.Callback)

/** Holds WebView callbacks that wait for a decision made in the Dart UI. */
class PendingRequests {
    private var nextId = 1
    private val fileChoosers = HashMap<Int, PendingFileChooser>()
    private val permissions = HashMap<Int, PermissionRequest>()
    private val geolocation = HashMap<Int, PendingGeolocation>()
    private val httpAuth = HashMap<Int, HttpAuthHandler>()

    fun addFileChooser(chooser: PendingFileChooser): Int {
        val id = nextId++
        fileChoosers[id] = chooser
        return id
    }

    fun takeFileChooser(id: Int): PendingFileChooser? = fileChoosers.remove(id)

    fun addPermission(request: PermissionRequest): Int {
        val id = nextId++
        permissions[id] = request
        return id
    }

    fun takePermission(id: Int): PermissionRequest? = permissions.remove(id)

    fun removePermission(request: PermissionRequest): Int? {
        val entry = permissions.entries.firstOrNull { it.value === request } ?: return null
        permissions.remove(entry.key)
        return entry.key
    }

    fun addGeolocation(request: PendingGeolocation): Int {
        val id = nextId++
        geolocation[id] = request
        return id
    }

    fun takeGeolocation(id: Int): PendingGeolocation? = geolocation.remove(id)

    fun clearGeolocation(): Int? {
        val key = geolocation.keys.firstOrNull() ?: return null
        geolocation.remove(key)
        return key
    }

    fun addHttpAuth(handler: HttpAuthHandler): Int {
        val id = nextId++
        httpAuth[id] = handler
        return id
    }

    fun takeHttpAuth(id: Int): HttpAuthHandler? = httpAuth.remove(id)

    /** Rejects every outstanding request, e.g. when the engine shuts down. */
    fun cancelAll() {
        fileChoosers.values.forEach { it.callback.onReceiveValue(null) }
        permissions.values.forEach { it.deny() }
        geolocation.values.forEach { it.callback.invoke(it.origin, false, false) }
        httpAuth.values.forEach { it.cancel() }
        fileChoosers.clear()
        permissions.clear()
        geolocation.clear()
        httpAuth.clear()
    }
}
