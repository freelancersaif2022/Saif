package com.beam.share.data

import com.beam.share.data.db.TransferDao
import com.beam.share.data.db.TransferEntity
import com.beam.share.model.FileKind
import com.beam.share.transfer.Direction
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import org.json.JSONArray
import org.json.JSONObject

enum class HistoryStatus { COMPLETED, FAILED, CANCELLED, DECLINED }

data class HistoryFile(
    val name: String,
    val size: Long,
    val mime: String,
    val uri: String?,
    val ok: Boolean,
) {
    val kind: FileKind get() = FileKind.from(mime, name)
}

data class HistoryEntry(
    val id: Long,
    val direction: Direction,
    val deviceName: String,
    val files: List<HistoryFile>,
    val totalBytes: Long,
    val status: HistoryStatus,
    val timestamp: Long,
    val durationMs: Long,
) {
    val title: String
        get() = when {
            files.size == 1 -> files.first().name
            files.isNotEmpty() && files.all { it.kind == FileKind.IMAGE } -> "${files.size} photos"
            files.isNotEmpty() && files.all { it.kind == FileKind.VIDEO } -> "${files.size} videos"
            files.isNotEmpty() && files.all { it.kind == FileKind.APP } -> "${files.size} apps"
            else -> "${files.size} files"
        }
}

class HistoryRepository(private val dao: TransferDao) {

    val entries: Flow<List<HistoryEntry>> = dao.observeAll().map { list -> list.map(::toEntry) }

    suspend fun add(
        direction: Direction,
        deviceName: String,
        files: List<HistoryFile>,
        status: HistoryStatus,
        timestamp: Long,
        durationMs: Long,
    ) {
        val json = JSONArray().apply {
            files.forEach { f ->
                put(
                    JSONObject()
                        .put("n", f.name)
                        .put("s", f.size)
                        .put("m", f.mime)
                        .put("u", f.uri ?: JSONObject.NULL)
                        .put("ok", f.ok)
                )
            }
        }
        dao.insert(
            TransferEntity(
                direction = direction.name,
                deviceName = deviceName,
                fileCount = files.size,
                totalBytes = files.sumOf { it.size },
                status = status.name,
                timestamp = timestamp,
                durationMs = durationMs,
                filesJson = json.toString(),
            )
        )
    }

    suspend fun delete(id: Long) = dao.delete(id)

    suspend fun clear() = dao.clear()

    private fun toEntry(e: TransferEntity): HistoryEntry {
        val files = runCatching {
            val arr = JSONArray(e.filesJson)
            (0 until arr.length()).map { i ->
                val o = arr.getJSONObject(i)
                HistoryFile(
                    name = o.optString("n"),
                    size = o.optLong("s"),
                    mime = o.optString("m"),
                    uri = if (o.isNull("u")) null else o.optString("u"),
                    ok = o.optBoolean("ok", true),
                )
            }
        }.getOrDefault(emptyList())
        return HistoryEntry(
            id = e.id,
            direction = runCatching { Direction.valueOf(e.direction) }.getOrDefault(Direction.SEND),
            deviceName = e.deviceName,
            files = files,
            totalBytes = e.totalBytes,
            status = runCatching { HistoryStatus.valueOf(e.status) }.getOrDefault(HistoryStatus.COMPLETED),
            timestamp = e.timestamp,
            durationMs = e.durationMs,
        )
    }
}
