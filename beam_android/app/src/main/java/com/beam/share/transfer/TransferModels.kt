package com.beam.share.transfer

import android.net.Uri
import com.beam.share.model.FileKind

enum class Direction { SEND, RECEIVE }

enum class Phase {
    /** Sender: asking the other phone to connect. Receiver: connected, waiting for the file list. */
    CONNECTING,
    /** Sender: file list sent, waiting for the other person to tap Accept. */
    AWAITING_ACCEPT,
    /** Receiver: showing the Accept / Decline sheet. */
    INCOMING_REQUEST,
    TRANSFERRING,
    COMPLETED,
    FAILED,
    DECLINED,
    CANCELLED;

    val isTerminal: Boolean get() = this == COMPLETED || this == FAILED || this == DECLINED || this == CANCELLED
}

enum class FileState { WAITING, IN_PROGRESS, SAVING, DONE, FAILED }

data class FileProgress(
    val payloadId: Long,
    val name: String,
    val size: Long,
    val mime: String,
    val transferred: Long = 0,
    val state: FileState = FileState.WAITING,
    val savedUri: Uri? = null,
    val sourceUri: Uri? = null,
    val packageName: String? = null,
) {
    val kind: FileKind get() = FileKind.from(mime, name)
    val fraction: Float
        get() = when {
            state == FileState.DONE || state == FileState.SAVING -> 1f
            size <= 0 -> 0f
            else -> (transferred.toFloat() / size).coerceIn(0f, 1f)
        }
}

data class NearbyDevice(val endpointId: String, val name: String)

data class TransferSession(
    val id: Long,
    val direction: Direction,
    val endpointId: String,
    val deviceName: String,
    val phase: Phase,
    val authCode: String? = null,
    val files: List<FileProgress> = emptyList(),
    val speedBytesPerSec: Long = 0,
    val startedAt: Long = 0,
    val finishedAt: Long = 0,
    val error: String? = null,
) {
    val totalBytes: Long get() = files.sumOf { it.size }

    val transferredBytes: Long
        get() = files.sumOf {
            when (it.state) {
                FileState.DONE, FileState.SAVING -> it.size
                else -> it.transferred.coerceIn(0, it.size.coerceAtLeast(0))
            }
        }

    val progress: Float
        get() = when {
            files.isEmpty() -> 0f
            totalBytes <= 0 -> files.count { it.state == FileState.DONE }.toFloat() / files.size
            else -> (transferredBytes.toFloat() / totalBytes).coerceIn(0f, 1f)
        }

    val doneCount: Int get() = files.count { it.state == FileState.DONE }
    val failedCount: Int get() = files.count { it.state == FileState.FAILED }

    /** Seconds left at the current speed, or null when unknown. */
    val etaSeconds: Long?
        get() = if (speedBytesPerSec <= 0) null else (totalBytes - transferredBytes).coerceAtLeast(0) / speedBytesPerSec

    val elapsedMs: Long
        get() = if (startedAt == 0L) 0 else (if (finishedAt > 0) finishedAt else System.currentTimeMillis()) - startedAt

    val isActive: Boolean get() = !phase.isTerminal
}

sealed interface EngineEvent {
    data class Message(val text: String) : EngineEvent
}
