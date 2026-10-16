package com.bimo.learnflutter.data.repository

import android.content.Context
import android.content.Intent
import androidx.core.content.FileProvider
import com.bimo.learnflutter.BuildConfig
import com.bimo.learnflutter.data.db.BimoDatabase
import com.bimo.learnflutter.data.prefs.SettingsDataStore
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.io.File
import java.time.Instant
import javax.inject.Inject
import javax.inject.Singleton

/** Export of learning data (GDPR-style portability) and full local reset. */
@Singleton
class DataManagementRepository @Inject constructor(
    @ApplicationContext private val context: Context,
    private val db: BimoDatabase,
    private val learning: LearningRepository,
    private val settings: SettingsDataStore,
) {
    suspend fun exportJson(): String = withContext(Dispatchers.IO) {
        val root = JSONObject()
        root.put("app", "Bimo – Learn Flutter")
        root.put("version", BuildConfig.VERSION_NAME)
        root.put("exportedAt", Instant.now().toString())
        db.profileDao().get()?.let { p ->
            root.put("profile", JSONObject().apply {
                put("name", p.name)
                put("experienceLevel", p.experienceLevel)
                put("learningGoal", p.learningGoal)
                put("dailyGoalLessons", p.dailyGoalLessons)
                put("createdAt", Instant.ofEpochMilli(p.createdAt).toString())
            })
        }
        root.put("totalXp", learning.totalXp.first())
        root.put("completedLessons", JSONArray(db.progressDao().completedIds().sorted()))
        root.put("lessonProgress", JSONArray().apply {
            db.progressDao().observeAll().first().forEach { lp ->
                put(JSONObject().apply {
                    put("lessonId", lp.lessonId)
                    put("bestScore", lp.bestScore)
                    put("attempts", lp.attempts)
                    put("completedAt", lp.completedAt?.let { Instant.ofEpochMilli(it).toString() } ?: JSONObject.NULL)
                })
            }
        })
        root.put("quizAttempts", JSONArray().apply {
            learning.attempts.first().forEach { a ->
                put(JSONObject().apply {
                    put("quizId", a.quizId)
                    put("title", a.title)
                    put("percent", a.percent)
                    put("passed", a.passed)
                    put("takenAt", Instant.ofEpochMilli(a.takenAt).toString())
                })
            }
        })
        root.put("achievements", JSONArray().apply {
            learning.achievements.first().forEach { put(JSONObject().put("id", it.id).put("unlockedAt", Instant.ofEpochMilli(it.unlockedAt).toString())) }
        })
        root.put("studyDays", JSONArray(learning.activityDays.first().map { it.epochDay }))
        root.put("certificates", JSONArray().apply {
            db.certificateDao().observeAll().first().forEach {
                put(JSONObject().put("id", it.certificateId).put("score", it.finalScore).put("issuedAt", Instant.ofEpochMilli(it.issuedAt).toString()))
            }
        })
        root.toString(2)
    }

    suspend fun exportShareIntent(): Intent = withContext(Dispatchers.IO) {
        val dir = File(context.cacheDir, "shared").apply { mkdirs() }
        val file = File(dir, "bimo-learning-data.json")
        file.writeText(exportJson())
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val send = Intent(Intent.ACTION_SEND).apply {
            type = "application/json"
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        Intent.createChooser(send, "Export learning data").addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
    }

    suspend fun resetLearningProgress() = learning.resetProgress()

    /** Deletes everything, including the profile and settings – the app restarts at onboarding. */
    suspend fun resetAllData() {
        withContext(Dispatchers.IO) { db.clearAllTables() }
        settings.clearAll()
        withContext(Dispatchers.IO) {
            context.filesDir.listFiles { f -> f.name.startsWith("avatar_") }?.forEach { it.delete() }
            File(context.cacheDir, "shared").deleteRecursively()
        }
    }
}
