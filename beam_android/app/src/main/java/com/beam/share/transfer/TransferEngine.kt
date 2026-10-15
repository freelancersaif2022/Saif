package com.beam.share.transfer

import android.content.Context
import android.os.ParcelFileDescriptor
import android.os.SystemClock
import android.util.Log
import com.beam.share.data.HistoryFile
import com.beam.share.data.HistoryRepository
import com.beam.share.data.HistoryStatus
import com.beam.share.data.Settings
import com.beam.share.model.ShareItem
import com.beam.share.util.Haptics
import com.beam.share.util.Permissions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.nearby.Nearby
import com.google.android.gms.nearby.connection.AdvertisingOptions
import com.google.android.gms.nearby.connection.ConnectionInfo
import com.google.android.gms.nearby.connection.ConnectionLifecycleCallback
import com.google.android.gms.nearby.connection.ConnectionResolution
import com.google.android.gms.nearby.connection.ConnectionsClient
import com.google.android.gms.nearby.connection.ConnectionsStatusCodes
import com.google.android.gms.nearby.connection.DiscoveredEndpointInfo
import com.google.android.gms.nearby.connection.DiscoveryOptions
import com.google.android.gms.nearby.connection.EndpointDiscoveryCallback
import com.google.android.gms.nearby.connection.Payload
import com.google.android.gms.nearby.connection.PayloadCallback
import com.google.android.gms.nearby.connection.PayloadTransferUpdate
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.delay
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.drop
import kotlinx.coroutines.flow.filterNotNull
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import java.io.File
import java.io.FileNotFoundException

/**
 * Owns everything Nearby: advertising (receiving), discovery (sending), connections and payloads.
 * All Nearby callbacks arrive on the main thread, and every state change happens there too.
 */
class TransferEngine(
    private val context: Context,
    private val settings: StateFlow<Settings?>,
    private val history: HistoryRepository,
    private val scope: CoroutineScope,
) {
    private val client: ConnectionsClient = Nearby.getConnectionsClient(context)
    private val saver = FileSaver(context)

    private val _devices = MutableStateFlow<List<NearbyDevice>>(emptyList())
    val devices: StateFlow<List<NearbyDevice>> = _devices.asStateFlow()

    private val _session = MutableStateFlow<TransferSession?>(null)
    val session: StateFlow<TransferSession?> = _session.asStateFlow()

    private val _advertising = MutableStateFlow(false)
    val advertising: StateFlow<Boolean> = _advertising.asStateFlow()

    private val _discovering = MutableStateFlow(false)
    val discovering: StateFlow<Boolean> = _discovering.asStateFlow()

    /** Last radio problem (e.g. Bluetooth off). Cleared once advertising / discovery works again. */
    private val _radioError = MutableStateFlow<String?>(null)
    val radioError: StateFlow<String?> = _radioError.asStateFlow()

    private val _events = MutableSharedFlow<EngineEvent>(extraBufferCapacity = 8)
    val events: SharedFlow<EngineEvent> = _events.asSharedFlow()

    private var appInForeground = false
    private var discoveryRequested = false
    private var advertisingPending = false
    private var discoveryPending = false

    // Sender state
    private var pendingItems: List<ShareItem> = emptyList()
    private val outgoing = LinkedHashMap<Long, Payload>()
    private val descriptors = mutableListOf<ParcelFileDescriptor>()

    // Receiver state
    private val incoming = HashMap<Long, Payload>()
    private val offerParts = HashMap<Int, ByteArray>()

    /** Receiver: the sender already hung up while the last files were being saved. */
    private var peerGone = false

    private var speedJob: Job? = null
    private var timeoutJob: Job? = null
    private var sessionCounter = 0L

    init {
        // Restart advertising when the device name or visibility changes.
        scope.launch {
            settings.filterNotNull()
                .map { it.deviceName to it.visible }
                .distinctUntilChanged()
                .drop(1)
                .collect {
                    if (_advertising.value) {
                        client.stopAdvertising()
                        _advertising.value = false
                    }
                    refreshRadios()
                }
        }
    }

    // ---------------------------------------------------------------------------------------------
    // Public API
    // ---------------------------------------------------------------------------------------------

    fun onAppForeground(foreground: Boolean) {
        appInForeground = foreground
        refreshRadios()
    }

    fun setDiscoveryWanted(wanted: Boolean) {
        discoveryRequested = wanted
        refreshRadios()
    }

    /** Call after permissions change. */
    fun refresh() = refreshRadios()

    fun send(device: NearbyDevice, items: List<ShareItem>) {
        if (items.isEmpty()) return
        val current = _session.value
        if (current != null && current.isActive) return
        resetTransientState()
        pendingItems = items
        _session.value = TransferSession(
            id = ++sessionCounter,
            direction = Direction.SEND,
            endpointId = device.endpointId,
            deviceName = device.name,
            phase = Phase.CONNECTING,
            files = items.mapIndexed { i, item ->
                FileProgress(
                    payloadId = -(i + 1L),
                    name = item.name,
                    size = item.size,
                    mime = item.mime,
                    sourceUri = item.uri,
                    packageName = item.packageName,
                )
            },
        )
        TransferService.start(context)
        client.requestConnection(myName(), device.endpointId, connectionCallback)
            .addOnSuccessListener { refreshRadios() }
            .addOnFailureListener { e ->
                Log.w(TAG, "requestConnection failed", e)
                val code = (e as? ApiException)?.statusCode
                if (code == ConnectionsStatusCodes.STATUS_ALREADY_CONNECTED_TO_ENDPOINT) return@addOnFailureListener
                finish(Phase.FAILED, "Couldn't reach ${device.name}. Make sure Beam is open on that phone.", disconnect = false)
            }
        // Ask timeout: the other side never answers.
        timeoutJob = scope.launch {
            delay(CONNECT_TIMEOUT_MS)
            val s = _session.value
            if (s != null && s.direction == Direction.SEND && s.phase == Phase.CONNECTING) {
                finish(Phase.FAILED, "${device.name} didn't respond. Try again.")
            }
        }
    }

    fun acceptIncoming() {
        val s = _session.value ?: return
        if (s.direction != Direction.RECEIVE || s.phase != Phase.INCOMING_REQUEST) return
        timeoutJob?.cancel()
        sendMessage(s.endpointId, Protocol.Message.Accept)
        _session.value = s.copy(phase = Phase.TRANSFERRING, startedAt = System.currentTimeMillis())
        startSpeedTicker()
        TransferService.start(context)
    }

    fun declineIncoming() {
        val s = _session.value ?: return
        if (s.direction != Direction.RECEIVE || s.phase != Phase.INCOMING_REQUEST) return
        timeoutJob?.cancel()
        sendMessage(s.endpointId, Protocol.Message.Decline)
        _session.value = null
        disconnectLater(s.endpointId)
    }

    fun cancel() {
        val s = _session.value ?: return
        if (s.phase.isTerminal) {
            dismiss()
            return
        }
        s.files.filter { it.state == FileState.IN_PROGRESS || it.state == FileState.WAITING }
            .forEach { if (it.payloadId > 0) client.cancelPayload(it.payloadId) }
        if (s.phase != Phase.CONNECTING) sendMessage(s.endpointId, Protocol.Message.Cancel)
        finish(Phase.CANCELLED, null)
    }

    /** Clears a finished session from the screen. */
    fun dismiss() {
        val s = _session.value ?: return
        if (s.isActive) return
        _session.value = null
        refreshRadios()
    }

    // ---------------------------------------------------------------------------------------------
    // Radios
    // ---------------------------------------------------------------------------------------------

    private fun refreshRadios() {
        if (!Permissions.hasNearby(context)) {
            if (_advertising.value) client.stopAdvertising()
            if (_discovering.value) client.stopDiscovery()
            _advertising.value = false
            _discovering.value = false
            return
        }
        val busy = _session.value?.isActive == true
        val wantDiscovery = appInForeground && discoveryRequested && !busy
        val wantAdvertising = appInForeground && !discoveryRequested && !busy && settings.value?.visible == true

        if (!wantDiscovery && _discovering.value) {
            client.stopDiscovery()
            _discovering.value = false
            _devices.value = emptyList()
        }
        if (!wantAdvertising && _advertising.value) {
            client.stopAdvertising()
            _advertising.value = false
        }
        if (wantAdvertising && !_advertising.value && !advertisingPending) startAdvertising()
        if (wantDiscovery && !_discovering.value && !discoveryPending) startDiscovery()
    }

    private fun startAdvertising() {
        advertisingPending = true
        val options = AdvertisingOptions.Builder().setStrategy(Protocol.STRATEGY).build()
        client.startAdvertising(myName(), Protocol.SERVICE_ID, connectionCallback, options)
            .addOnSuccessListener {
                advertisingPending = false
                _advertising.value = true
                _radioError.value = null
                refreshRadios()
            }
            .addOnFailureListener { e ->
                advertisingPending = false
                if ((e as? ApiException)?.statusCode == ConnectionsStatusCodes.STATUS_ALREADY_ADVERTISING) {
                    _advertising.value = true
                } else {
                    Log.w(TAG, "startAdvertising failed", e)
                    _radioError.value = radioMessage(e)
                }
            }
    }

    private fun startDiscovery() {
        discoveryPending = true
        _devices.value = emptyList()
        val options = DiscoveryOptions.Builder().setStrategy(Protocol.STRATEGY).build()
        client.startDiscovery(Protocol.SERVICE_ID, discoveryCallback, options)
            .addOnSuccessListener {
                discoveryPending = false
                _discovering.value = true
                _radioError.value = null
                refreshRadios()
            }
            .addOnFailureListener { e ->
                discoveryPending = false
                if ((e as? ApiException)?.statusCode == ConnectionsStatusCodes.STATUS_ALREADY_DISCOVERING) {
                    _discovering.value = true
                } else {
                    Log.w(TAG, "startDiscovery failed", e)
                    _radioError.value = radioMessage(e)
                }
            }
    }

    private fun radioMessage(e: Exception): String {
        val code = (e as? ApiException)?.statusCode ?: return "Nearby sharing isn't available right now."
        val name = runCatching { ConnectionsStatusCodes.getStatusCodeString(code) }.getOrDefault("")
        return when {
            code == ConnectionsStatusCodes.STATUS_BLUETOOTH_ERROR -> "Bluetooth isn't working. Turn it off and on again."
            name.contains("PERMISSION", ignoreCase = true) -> "Beam needs the Nearby devices and Location permissions."
            name.contains("API_NOT_CONNECTED", ignoreCase = true) || name.contains("SERVICE", ignoreCase = true) ->
                "Google Play services is needed for Beam. Update it from the Play Store."
            else -> "Nearby sharing isn't available right now ($code)."
        }
    }

    private fun myName(): String = settings.value?.deviceName?.takeIf { it.isNotBlank() } ?: android.os.Build.MODEL

    // ---------------------------------------------------------------------------------------------
    // Nearby callbacks
    // ---------------------------------------------------------------------------------------------

    private val discoveryCallback = object : EndpointDiscoveryCallback() {
        override fun onEndpointFound(endpointId: String, info: DiscoveredEndpointInfo) {
            if (info.serviceId != Protocol.SERVICE_ID) return
            _devices.update { list -> list.filterNot { it.endpointId == endpointId } + NearbyDevice(endpointId, info.endpointName) }
        }

        override fun onEndpointLost(endpointId: String) {
            _devices.update { list -> list.filterNot { it.endpointId == endpointId } }
        }
    }

    private val connectionCallback = object : ConnectionLifecycleCallback() {
        override fun onConnectionInitiated(endpointId: String, info: ConnectionInfo) {
            val current = _session.value
            if (info.isIncomingConnection) {
                if ((current != null && current.isActive) || settings.value?.visible == false) {
                    client.rejectConnection(endpointId)
                    return
                }
                resetTransientState()
                _session.value = TransferSession(
                    id = ++sessionCounter,
                    direction = Direction.RECEIVE,
                    endpointId = endpointId,
                    deviceName = info.endpointName,
                    phase = Phase.CONNECTING,
                    authCode = info.authenticationDigits,
                )
                client.acceptConnection(endpointId, payloadCallback)
                    .addOnFailureListener { e ->
                        Log.w(TAG, "acceptConnection (receiver) failed", e)
                        if (_session.value?.endpointId == endpointId) _session.value = null
                        refreshRadios()
                    }
                timeoutJob = scope.launch {
                    delay(OFFER_TIMEOUT_MS)
                    val s = _session.value
                    if (s != null && s.endpointId == endpointId && s.phase == Phase.CONNECTING) {
                        _session.value = null
                        client.disconnectFromEndpoint(endpointId)
                        refreshRadios()
                    }
                }
            } else {
                if (current == null || current.endpointId != endpointId || current.direction != Direction.SEND || !current.isActive) {
                    client.rejectConnection(endpointId)
                    return
                }
                _session.value = current.copy(authCode = info.authenticationDigits)
                client.acceptConnection(endpointId, payloadCallback)
                    .addOnFailureListener { e ->
                        Log.w(TAG, "acceptConnection (sender) failed", e)
                        finish(Phase.FAILED, "Couldn't connect to ${current.deviceName}.")
                    }
            }
        }

        override fun onConnectionResult(endpointId: String, result: ConnectionResolution) {
            val s = _session.value ?: return
            if (s.endpointId != endpointId || !s.isActive) return
            if (result.status.isSuccess) {
                if (s.direction == Direction.SEND) sendOffer()
                return
            }
            when (s.direction) {
                Direction.SEND -> if (result.status.statusCode == ConnectionsStatusCodes.STATUS_CONNECTION_REJECTED) {
                    finish(Phase.DECLINED, "${s.deviceName} is busy right now.", disconnect = false)
                } else {
                    finish(Phase.FAILED, "Couldn't connect to ${s.deviceName}. Try again.", disconnect = false)
                }
                Direction.RECEIVE -> {
                    _session.value = null
                    refreshRadios()
                }
            }
        }

        override fun onDisconnected(endpointId: String) {
            val s = _session.value ?: return
            if (s.endpointId != endpointId) return
            if (!s.isActive) {
                refreshRadios()
                return
            }
            when {
                s.direction == Direction.RECEIVE && s.phase == Phase.CONNECTING -> {
                    _session.value = null
                    refreshRadios()
                }
                s.direction == Direction.RECEIVE && s.phase == Phase.INCOMING_REQUEST -> {
                    _session.value = null
                    emit("${s.deviceName} cancelled the request")
                    refreshRadios()
                }
                s.direction == Direction.SEND && s.files.isNotEmpty() && s.files.all { it.state == FileState.DONE } ->
                    finish(Phase.COMPLETED, null, disconnect = false)
                // Every byte arrived and the last files are still being copied: let saving finish.
                s.direction == Direction.RECEIVE && s.phase == Phase.TRANSFERRING &&
                    s.files.all { it.state == FileState.SAVING || it.state == FileState.DONE || it.state == FileState.FAILED } -> {
                    peerGone = true
                    checkReceiverFinished()
                }
                else -> finish(Phase.FAILED, "Connection to ${s.deviceName} was lost.", disconnect = false)
            }
        }
    }

    private val payloadCallback = object : PayloadCallback() {
        override fun onPayloadReceived(endpointId: String, payload: Payload) {
            val s = _session.value ?: return
            if (s.endpointId != endpointId) return
            when (payload.type) {
                Payload.Type.BYTES -> payload.asBytes()?.let { onMessage(it) }
                Payload.Type.FILE -> {
                    if (s.direction == Direction.RECEIVE && s.files.any { it.payloadId == payload.id }) {
                        incoming[payload.id] = payload
                        updateFile(payload.id) { if (it.state == FileState.WAITING) it.copy(state = FileState.IN_PROGRESS) else it }
                    } else {
                        // Not part of an accepted offer: drop it.
                        client.cancelPayload(payload.id)
                        saver.discard(payload.asFile())
                    }
                }
                else -> Unit
            }
        }

        override fun onPayloadTransferUpdate(endpointId: String, update: PayloadTransferUpdate) {
            val s = _session.value ?: return
            if (s.endpointId != endpointId) return
            val id = update.payloadId
            if (s.files.none { it.payloadId == id }) return
            when (update.status) {
                PayloadTransferUpdate.Status.IN_PROGRESS -> updateFile(id) {
                    if (it.state == FileState.WAITING || it.state == FileState.IN_PROGRESS) {
                        it.copy(state = FileState.IN_PROGRESS, transferred = update.bytesTransferred)
                    } else it
                }
                PayloadTransferUpdate.Status.SUCCESS -> onFileSuccess(id)
                PayloadTransferUpdate.Status.FAILURE, PayloadTransferUpdate.Status.CANCELED -> onFileFailed(id)
            }
        }
    }

    // ---------------------------------------------------------------------------------------------
    // Protocol handling
    // ---------------------------------------------------------------------------------------------

    private fun onMessage(bytes: ByteArray) {
        val s = _session.value ?: return
        when (val m = Protocol.decode(bytes)) {
            is Protocol.Message.OfferPart -> if (s.direction == Direction.RECEIVE && s.phase == Phase.CONNECTING) {
                offerParts[m.seq] = m.data
                if (offerParts.size >= m.count) {
                    val raw = (0 until m.count).mapNotNull { offerParts[it] }
                        .fold(ByteArray(0)) { acc, part -> acc + part }
                    offerParts.clear()
                    val offer = Protocol.decodeOffer(raw)
                    if (offer == null || offer.files.isEmpty()) {
                        client.disconnectFromEndpoint(s.endpointId)
                        _session.value = null
                        refreshRadios()
                        return
                    }
                    onOffer(offer)
                }
            }
            Protocol.Message.Accept -> if (s.direction == Direction.SEND && s.phase == Phase.AWAITING_ACCEPT) {
                _session.value = s.copy(phase = Phase.TRANSFERRING, startedAt = System.currentTimeMillis())
                startSpeedTicker()
                sendNext()
            }
            Protocol.Message.Decline -> if (s.direction == Direction.SEND && s.isActive) {
                finish(Phase.DECLINED, "${s.deviceName} declined the files.")
            }
            Protocol.Message.Cancel -> if (s.isActive) {
                if (s.direction == Direction.RECEIVE && s.phase == Phase.INCOMING_REQUEST) {
                    _session.value = null
                    emit("${s.deviceName} cancelled the request")
                    disconnectLater(s.endpointId)
                } else {
                    finish(Phase.CANCELLED, "${s.deviceName} cancelled the transfer.")
                }
            }
            Protocol.Message.Done -> if (s.direction == Direction.SEND && s.isActive) {
                finish(Phase.COMPLETED, null)
            }
            null -> Unit
        }
    }

    private fun onOffer(offer: Protocol.Offer) {
        timeoutJob?.cancel()
        val s = _session.value ?: return
        _session.value = s.copy(
            phase = Phase.INCOMING_REQUEST,
            deviceName = offer.sender.ifBlank { s.deviceName },
            files = offer.files.map { FileProgress(payloadId = it.payloadId, name = it.name, size = it.size, mime = it.mime) },
        )
        if (settings.value?.vibrate != false) Haptics.alert(context)
        // Auto-decline if nobody answers.
        timeoutJob = scope.launch {
            delay(DECISION_TIMEOUT_MS)
            if (_session.value?.let { it.id == s.id && it.phase == Phase.INCOMING_REQUEST } == true) {
                declineIncoming()
            }
        }
    }

    private fun sendOffer() {
        val s = _session.value ?: return
        timeoutJob?.cancel()
        val resolver = context.contentResolver
        val files = ArrayList<FileProgress>()
        pendingItems.forEachIndexed { index, item ->
            val payload: Payload? = try {
                if (item.uri.scheme == "file") {
                    Payload.fromFile(File(item.uri.path ?: throw FileNotFoundException()))
                } else {
                    val pfd = resolver.openFileDescriptor(item.uri, "r") ?: throw FileNotFoundException()
                    descriptors += pfd
                    Payload.fromFile(pfd)
                }
            } catch (e: Exception) {
                Log.w(TAG, "Can't open ${item.name}", e)
                null
            }
            if (payload != null) {
                outgoing[payload.id] = payload
                val base = s.files.getOrNull(index) ?: return@forEachIndexed
                val size = if (base.size > 0) base.size else payload.asFile()?.size ?: 0L
                files += base.copy(payloadId = payload.id, size = size)
            }
        }
        if (files.isEmpty()) {
            finish(Phase.FAILED, "The selected files couldn't be opened.")
            return
        }
        _session.value = s.copy(phase = Phase.AWAITING_ACCEPT, files = files)
        val offer = Protocol.Offer(
            sender = myName(),
            files = files.map { Protocol.OfferFile(it.payloadId, it.name, it.size, it.mime) },
        )
        Protocol.encodeOffer(offer).forEach { client.sendPayload(s.endpointId, Payload.fromBytes(it)) }
        timeoutJob = scope.launch {
            delay(DECISION_TIMEOUT_MS + 5_000)
            val now = _session.value
            if (now != null && now.id == s.id && now.phase == Phase.AWAITING_ACCEPT) {
                sendMessage(now.endpointId, Protocol.Message.Cancel)
                finish(Phase.FAILED, "${now.deviceName} didn't answer.")
            }
        }
    }

    /** Sends files one at a time so each one shows its own progress. */
    private fun sendNext() {
        val s = _session.value ?: return
        if (s.direction != Direction.SEND || s.phase != Phase.TRANSFERRING) return
        if (s.files.any { it.state == FileState.IN_PROGRESS }) return
        val next = s.files.firstOrNull { it.state == FileState.WAITING }
        if (next == null) {
            onAllSent()
            return
        }
        val payload = outgoing[next.payloadId]
        if (payload == null) {
            updateFile(next.payloadId) { it.copy(state = FileState.FAILED) }
            sendNext()
            return
        }
        updateFile(next.payloadId) { it.copy(state = FileState.IN_PROGRESS) }
        client.sendPayload(s.endpointId, payload).addOnFailureListener { e ->
            Log.w(TAG, "sendPayload failed", e)
            updateFile(next.payloadId) { it.copy(state = FileState.FAILED) }
            sendNext()
        }
    }

    private fun onAllSent() {
        val s = _session.value ?: return
        if (s.doneCount == 0) {
            finish(Phase.FAILED, "The files couldn't be sent.")
            return
        }
        // Wait for the receiver's "done"; fall back to completing after a while.
        timeoutJob?.cancel()
        timeoutJob = scope.launch {
            delay(DONE_FALLBACK_MS)
            val now = _session.value
            if (now != null && now.id == s.id && now.phase == Phase.TRANSFERRING) finish(Phase.COMPLETED, null)
        }
    }

    private fun onFileSuccess(payloadId: Long) {
        val s = _session.value ?: return
        val file = s.files.firstOrNull { it.payloadId == payloadId } ?: return
        if (file.state == FileState.DONE || file.state == FileState.SAVING) return
        when (s.direction) {
            Direction.SEND -> {
                updateFile(payloadId) { it.copy(state = FileState.DONE, transferred = it.size) }
                sendNext()
            }
            Direction.RECEIVE -> {
                updateFile(payloadId) { it.copy(state = FileState.SAVING, transferred = it.size) }
                val payload = incoming.remove(payloadId)
                scope.launch {
                    val uri = payload?.asFile()?.let { saver.save(it, file.name, file.mime) }
                    val now = _session.value
                    if (now == null || now.id != s.id) return@launch
                    updateFile(payloadId) {
                        if (uri != null) it.copy(state = FileState.DONE, savedUri = uri) else it.copy(state = FileState.FAILED)
                    }
                    checkReceiverFinished()
                }
            }
        }
    }

    private fun onFileFailed(payloadId: Long) {
        val s = _session.value ?: return
        if (!s.isActive) return
        updateFile(payloadId) { if (it.state == FileState.DONE) it else it.copy(state = FileState.FAILED) }
        when (s.direction) {
            Direction.SEND -> sendNext()
            Direction.RECEIVE -> {
                saver.discard(incoming.remove(payloadId)?.asFile())
                checkReceiverFinished()
            }
        }
    }

    private fun checkReceiverFinished() {
        val s = _session.value ?: return
        if (s.direction != Direction.RECEIVE || s.phase != Phase.TRANSFERRING) return
        if (s.files.any { it.state != FileState.DONE && it.state != FileState.FAILED }) return
        if (!peerGone) sendMessage(s.endpointId, Protocol.Message.Done)
        if (s.doneCount > 0) finish(Phase.COMPLETED, null, disconnect = !peerGone)
        else finish(Phase.FAILED, "The files couldn't be saved.", disconnect = !peerGone)
    }

    // ---------------------------------------------------------------------------------------------
    // Helpers
    // ---------------------------------------------------------------------------------------------

    private fun finish(phase: Phase, error: String?, disconnect: Boolean = true) {
        val s = _session.value ?: return
        if (s.phase.isTerminal) return
        timeoutJob?.cancel()
        speedJob?.cancel()
        val now = System.currentTimeMillis()
        val files = if (phase == Phase.COMPLETED || phase == Phase.DECLINED) s.files
        else s.files.map { if (it.state == FileState.DONE) it else it.copy(state = FileState.FAILED) }
        val final = s.copy(phase = phase, error = error, finishedAt = now, speedBytesPerSec = 0, files = files)
        _session.value = final

        val wasTransferring = s.phase == Phase.TRANSFERRING
        val record = phase == Phase.COMPLETED || wasTransferring || (phase == Phase.DECLINED && s.direction == Direction.SEND)
        if (record && files.isNotEmpty()) {
            val status = when (phase) {
                Phase.COMPLETED -> HistoryStatus.COMPLETED
                Phase.DECLINED -> HistoryStatus.DECLINED
                Phase.CANCELLED -> HistoryStatus.CANCELLED
                else -> HistoryStatus.FAILED
            }
            val historyFiles = files.map {
                HistoryFile(
                    name = it.name,
                    size = it.size,
                    mime = it.mime,
                    uri = (it.savedUri ?: it.sourceUri)?.toString(),
                    ok = it.state == FileState.DONE,
                )
            }
            scope.launch {
                runCatching {
                    history.add(
                        direction = s.direction,
                        deviceName = s.deviceName,
                        files = historyFiles,
                        status = status,
                        timestamp = now,
                        durationMs = if (s.startedAt > 0) now - s.startedAt else 0,
                    )
                }
            }
        }
        if (phase == Phase.COMPLETED && settings.value?.vibrate != false) Haptics.success(context)

        // Clean up partial downloads and open file handles.
        incoming.values.forEach { saver.discard(it.asFile()) }
        incoming.clear()
        scope.launch {
            delay(1_500)
            closeDescriptors()
        }
        if (disconnect) disconnectLater(s.endpointId) else refreshRadios()
    }

    private fun disconnectLater(endpointId: String) {
        scope.launch {
            delay(800)
            client.disconnectFromEndpoint(endpointId)
            refreshRadios()
        }
    }

    private fun startSpeedTicker() {
        speedJob?.cancel()
        speedJob = scope.launch {
            var lastBytes = _session.value?.transferredBytes ?: 0L
            var lastTime = SystemClock.elapsedRealtime()
            var smoothed = 0.0
            while (isActive) {
                delay(500)
                val s = _session.value ?: break
                if (s.phase != Phase.TRANSFERRING) break
                val now = SystemClock.elapsedRealtime()
                val bytes = s.transferredBytes
                val instant = (bytes - lastBytes).coerceAtLeast(0) * 1000.0 / (now - lastTime).coerceAtLeast(1)
                smoothed = if (smoothed == 0.0) instant else smoothed * 0.7 + instant * 0.3
                lastBytes = bytes
                lastTime = now
                _session.update { it?.copy(speedBytesPerSec = smoothed.toLong()) }
            }
        }
    }

    private inline fun updateFile(payloadId: Long, crossinline transform: (FileProgress) -> FileProgress) {
        _session.update { s ->
            s?.copy(files = s.files.map { if (it.payloadId == payloadId) transform(it) else it })
        }
    }

    private fun sendMessage(endpointId: String, message: Protocol.Message) {
        client.sendPayload(endpointId, Payload.fromBytes(Protocol.encode(message)))
            .addOnFailureListener { e -> Log.w(TAG, "sendMessage $message failed", e) }
    }

    private fun resetTransientState() {
        timeoutJob?.cancel()
        speedJob?.cancel()
        outgoing.clear()
        closeDescriptors()
        incoming.clear()
        offerParts.clear()
        pendingItems = emptyList()
        peerGone = false
    }

    private fun closeDescriptors() {
        if (_session.value?.isActive == true) return
        descriptors.forEach { runCatching { it.close() } }
        descriptors.clear()
    }

    private fun emit(text: String) {
        _events.tryEmit(EngineEvent.Message(text))
    }

    companion object {
        private const val TAG = "BeamEngine"
        private const val CONNECT_TIMEOUT_MS = 30_000L
        private const val OFFER_TIMEOUT_MS = 20_000L
        private const val DECISION_TIMEOUT_MS = 60_000L
        private const val DONE_FALLBACK_MS = 90_000L
    }
}
