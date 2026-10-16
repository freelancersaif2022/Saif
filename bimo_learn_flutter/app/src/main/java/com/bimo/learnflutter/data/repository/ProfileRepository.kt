package com.bimo.learnflutter.data.repository

import android.content.Context
import android.net.Uri
import com.bimo.learnflutter.data.db.dao.CertificateDao
import com.bimo.learnflutter.data.db.dao.ProfileDao
import com.bimo.learnflutter.data.db.entity.UserProfileEntity
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.withContext
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

enum class ExperienceLevel(val label: String, val description: String) {
    BEGINNER("Beginner", "I'm new to programming or to Dart."),
    INTERMEDIATE("Intermediate", "I know another language and want to learn Flutter."),
    ADVANCED("Advanced", "I've built apps and want to go deeper."),
}

@Singleton
class ProfileRepository @Inject constructor(
    @ApplicationContext private val context: Context,
    private val profileDao: ProfileDao,
    private val certificateDao: CertificateDao,
) {
    val profile: Flow<UserProfileEntity?> = profileDao.observe()

    suspend fun get(): UserProfileEntity? = profileDao.get()

    suspend fun createProfile(
        name: String,
        level: ExperienceLevel,
        goal: String,
        dailyGoal: Int,
        avatarEmoji: String,
    ) {
        profileDao.upsert(
            UserProfileEntity(
                name = name.trim(),
                avatarPath = null,
                avatarEmoji = avatarEmoji,
                experienceLevel = level.name,
                learningGoal = goal,
                dailyGoalLessons = dailyGoal.coerceIn(1, 10),
                createdAt = System.currentTimeMillis(),
            ),
        )
    }

    suspend fun update(transform: (UserProfileEntity) -> UserProfileEntity) {
        val current = profileDao.get() ?: return
        val updated = transform(current)
        profileDao.upsert(updated)
        if (updated.name != current.name) certificateDao.renameAll(updated.name)
    }

    /**
     * Copies a picked image into app-private storage so the avatar survives even after the
     * temporary read permission granted by the photo picker expires.
     */
    suspend fun setAvatarFromUri(uri: Uri): Boolean = withContext(Dispatchers.IO) {
        try {
            val target = File(context.filesDir, "avatar_${System.currentTimeMillis()}.jpg")
            context.contentResolver.openInputStream(uri)?.use { input ->
                target.outputStream().use { output -> input.copyTo(output) }
            } ?: return@withContext false
            val old = profileDao.get()?.avatarPath
            update { it.copy(avatarPath = target.absolutePath) }
            old?.let { File(it).takeIf { f -> f.exists() && f.absolutePath != target.absolutePath }?.delete() }
            true
        } catch (e: Exception) {
            false
        }
    }

    suspend fun clearAvatar() = withContext(Dispatchers.IO) {
        profileDao.get()?.avatarPath?.let { File(it).delete() }
        update { it.copy(avatarPath = null) }
    }
}
