package com.beam.share.transfer

import android.util.Base64
import com.google.android.gms.nearby.connection.Strategy
import org.json.JSONArray
import org.json.JSONObject

/**
 * Control messages exchanged as Nearby BYTES payloads.
 *
 * Flow:
 *  sender  ── offer (file list + payload ids) ──▶ receiver   (receiver shows Accept / Decline)
 *  sender  ◀── accept | decline ──────────────── receiver
 *  sender  ── FILE payloads, one after another ─▶ receiver
 *  sender  ◀── done ──────────────────────────── receiver   (all files saved)
 *  either side may send cancel at any time.
 */
object Protocol {
    const val SERVICE_ID = "com.beam.share.v1"
    val STRATEGY: Strategy = Strategy.P2P_POINT_TO_POINT

    /** Nearby BYTES payloads are limited to 32 KB, so large offers are split. */
    private const val CHUNK_BYTES = 20_000

    data class OfferFile(val payloadId: Long, val name: String, val size: Long, val mime: String)

    data class Offer(val sender: String, val files: List<OfferFile>)

    sealed interface Message {
        data class OfferPart(val seq: Int, val count: Int, val data: ByteArray) : Message
        data object Accept : Message
        data object Decline : Message
        data object Cancel : Message
        data object Done : Message
    }

    fun encodeOffer(offer: Offer): List<ByteArray> {
        val files = JSONArray()
        offer.files.forEach {
            files.put(
                JSONObject()
                    .put("id", it.payloadId)
                    .put("n", it.name)
                    .put("s", it.size)
                    .put("m", it.mime)
            )
        }
        val raw = JSONObject().put("sender", offer.sender).put("files", files).toString().toByteArray(Charsets.UTF_8)
        val chunks = raw.toList().chunked(CHUNK_BYTES).map { it.toByteArray() }.ifEmpty { listOf(ByteArray(0)) }
        return chunks.mapIndexed { i, chunk ->
            JSONObject()
                .put("t", "offer")
                .put("seq", i)
                .put("count", chunks.size)
                .put("data", Base64.encodeToString(chunk, Base64.NO_WRAP))
                .toString()
                .toByteArray(Charsets.UTF_8)
        }
    }

    fun decodeOffer(raw: ByteArray): Offer? = runCatching {
        val o = JSONObject(String(raw, Charsets.UTF_8))
        val arr = o.getJSONArray("files")
        Offer(
            sender = o.optString("sender"),
            files = (0 until arr.length()).map { i ->
                val f = arr.getJSONObject(i)
                OfferFile(
                    payloadId = f.getLong("id"),
                    name = sanitizeName(f.optString("n", "file")),
                    size = f.optLong("s"),
                    mime = f.optString("m", "application/octet-stream"),
                )
            }
        )
    }.getOrNull()

    fun encode(message: Message): ByteArray {
        val type = when (message) {
            Message.Accept -> "accept"
            Message.Decline -> "decline"
            Message.Cancel -> "cancel"
            Message.Done -> "done"
            is Message.OfferPart -> error("Use encodeOffer")
        }
        return JSONObject().put("t", type).toString().toByteArray(Charsets.UTF_8)
    }

    fun decode(bytes: ByteArray): Message? = runCatching {
        val o = JSONObject(String(bytes, Charsets.UTF_8))
        when (o.optString("t")) {
            "offer" -> Message.OfferPart(
                seq = o.getInt("seq"),
                count = o.getInt("count"),
                data = Base64.decode(o.getString("data"), Base64.NO_WRAP),
            )
            "accept" -> Message.Accept
            "decline" -> Message.Decline
            "cancel" -> Message.Cancel
            "done" -> Message.Done
            else -> null
        }
    }.getOrNull()

    fun sanitizeName(name: String): String {
        val cleaned = name.substringAfterLast('/').substringAfterLast('\\')
            .replace(Regex("[\\u0000-\\u001f:*?\"<>|]"), "_")
            .trim()
            .trimStart('.')
        return cleaned.take(120).ifBlank { "file" }
    }
}
