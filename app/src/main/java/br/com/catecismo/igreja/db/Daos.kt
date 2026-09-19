package br.com.catecismo.igreja.db

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

data class ChapterWithProgress(
    val chapterId: String,
    val workId: String,
    val order: Int,
    val title: String,
    val paragraphCount: Int,
    val progress: Int
)

data class SearchHit(
    val workId: String,
    val workTitle: String,
    val chapterId: String,
    val chapterOrder: Int,
    val chapterTitle: String,
    val snippet: String
)

data class ProgressEntity(
    val chapterId: String,
    val workId: String,
    val progress: Int
)

@Dao
interface LibraryDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertWorks(works: List<WorkEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertChapters(chapters: List<ChapterEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertParagraphs(paragraphs: List<ParagraphEntity>)

    @Query("DELETE FROM paragraphs WHERE workId = :workId")
    suspend fun deleteParagraphsForWork(workId: String)

    @Query("DELETE FROM chapters WHERE workId = :workId")
    suspend fun deleteChaptersForWork(workId: String)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsertProgress(entity: ChapterProgressEntity)

    @Query("UPDATE chapter_progress SET progress = :progress, paragraphIndex = :paragraphIndex, updatedAt = :updatedAt, isCompleted = :completed, completedAt = :completedAt WHERE chapterId = :chapterId")
    suspend fun updatePosition(chapterId: String, progress: Int, paragraphIndex: Int, updatedAt: Long, completed: Boolean, completedAt: Long?): Int

    @Query("UPDATE chapter_progress SET readingTimeMs = readingTimeMs + :readingMs, listeningTimeMs = listeningTimeMs + :listeningMs, updatedAt = :updatedAt WHERE chapterId = :chapterId")
    suspend fun addActivity(chapterId: String, readingMs: Long, listeningMs: Long, updatedAt: Long): Int

    @Query("SELECT COUNT(*) FROM works")
    suspend fun workCount(): Int

    @Query("SELECT * FROM works ORDER BY year")
    fun works(): Flow<List<WorkEntity>>

    @Query("SELECT * FROM works WHERE id = :id")
    suspend fun work(id: String): WorkEntity?

    @Query("SELECT * FROM works ORDER BY year")
    suspend fun worksOnce(): List<WorkEntity>

    @Query("SELECT * FROM chapters WHERE workId = :workId ORDER BY `order`")
    suspend fun chapters(workId: String): List<ChapterEntity>

    @Query("SELECT * FROM chapters WHERE workId = :workId ORDER BY `order`")
    fun chaptersFlow(workId: String): Flow<List<ChapterEntity>>

    @Query("SELECT * FROM chapters WHERE id = :chapterId")
    suspend fun chapter(chapterId: String): ChapterEntity?

    @Query("SELECT text FROM paragraphs WHERE chapterId = :chapterId ORDER BY `order`")
    suspend fun paragraphs(chapterId: String): List<String>

    @Query("SELECT text FROM paragraphs WHERE chapterId = :chapterId ORDER BY `order`")
    fun paragraphsFlow(chapterId: String): Flow<List<String>>

    @Query("SELECT COUNT(*) FROM paragraphs WHERE workId = :workId")
    suspend fun paragraphCount(workId: String): Int

    @Query("SELECT chapter_progress.* FROM chapter_progress WHERE workId = :workId ORDER BY updatedAt DESC LIMIT 1")
    suspend fun latestChapter(workId: String): ChapterProgressEntity?

    @Query("SELECT chapter_progress.* FROM chapter_progress ORDER BY updatedAt DESC LIMIT 1")
    suspend fun latestAny(): ChapterProgressEntity?

    @Query("SELECT chapter_progress.* FROM chapter_progress WHERE chapterId = :chapterId")
    suspend fun progress(chapterId: String): ChapterProgressEntity?

    @Query("SELECT * FROM chapter_progress ORDER BY updatedAt DESC")
    suspend fun allProgress(): List<ChapterProgressEntity>

    @Query("SELECT p.workId as workId, w.title as workTitle, p.chapterId as chapterId, c.`order` as chapterOrder, c.title as chapterTitle, substr(p.text,1,200) as snippet FROM paragraphs_fts JOIN paragraphs p ON p.rowId = paragraphs_fts.rowid JOIN chapters c ON c.id = p.chapterId JOIN works w ON w.id = p.workId WHERE paragraphs_fts MATCH :query LIMIT 40")
    suspend fun search(query: String): List<SearchHit>
}
