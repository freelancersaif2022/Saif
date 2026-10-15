package com.beam.share.data.db

import androidx.room.Dao
import androidx.room.Database
import androidx.room.Entity
import androidx.room.Insert
import androidx.room.PrimaryKey
import androidx.room.Query
import androidx.room.RoomDatabase
import kotlinx.coroutines.flow.Flow

@Entity(tableName = "transfers")
data class TransferEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val direction: String,
    val deviceName: String,
    val fileCount: Int,
    val totalBytes: Long,
    val status: String,
    val timestamp: Long,
    val durationMs: Long,
    val filesJson: String,
)

@Dao
interface TransferDao {
    @Query("SELECT * FROM transfers ORDER BY timestamp DESC")
    fun observeAll(): Flow<List<TransferEntity>>

    @Insert
    suspend fun insert(entity: TransferEntity): Long

    @Query("DELETE FROM transfers WHERE id = :id")
    suspend fun delete(id: Long)

    @Query("DELETE FROM transfers")
    suspend fun clear()
}

@Database(entities = [TransferEntity::class], version = 1, exportSchema = false)
abstract class BeamDatabase : RoomDatabase() {
    abstract fun transferDao(): TransferDao
}
