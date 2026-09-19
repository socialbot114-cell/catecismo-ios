package br.com.catecismo.igreja.data

import android.content.Context
import br.com.catecismo.igreja.db.ChapterEntity
import br.com.catecismo.igreja.db.ChapterProgressEntity
import br.com.catecismo.igreja.db.CatecismoDatabase
import br.com.catecismo.igreja.db.SearchHit
import br.com.catecismo.igreja.db.Seeder
import br.com.catecismo.igreja.db.WorkEntity
import kotlinx.coroutines.flow.Flow

class LibraryRepository(context: Context) {
    private val db = CatecismoDatabase.get(context)
    private val seeder = Seeder(context, db)

    suspend fun seedIfNeeded(onProgress: (Int, Int) -> Unit) = seeder.seedIfNeeded(onProgress)

    suspend fun worksOnce(): List<WorkEntity> = db.dao().worksOnce()
    fun works(): Flow<List<WorkEntity>> = db.dao().works()
    suspend fun work(id: String): WorkEntity? = db.dao().work(id)
    suspend fun chapters(workId: String): List<ChapterEntity> = db.dao().chapters(workId)
    suspend fun paragraphs(chapterId: String): List<String> = db.dao().paragraphs(chapterId)
    suspend fun paragraphCount(workId: String): Int = db.dao().paragraphCount(workId)

    suspend fun saveProgress(chapter: ChapterEntity, workId: String, progress: Int, paragraphIndex: Int = -1) {
        val pct = progress.coerceIn(0, 100)
        val completed = pct >= 100
        val now = System.currentTimeMillis()
        if (db.dao().updatePosition(chapter.id, pct, paragraphIndex, now, completed, if (completed) now else null) == 0) {
            db.dao().upsertProgress(ChapterProgressEntity(chapter.id, workId, pct, now, paragraphIndex, isCompleted = completed, completedAt = if (completed) now else null))
        }
    }

    suspend fun addActivity(chapter: ChapterEntity, workId: String, readingMs: Long = 0, listeningMs: Long = 0) {
        if (db.dao().addActivity(chapter.id, readingMs, listeningMs, System.currentTimeMillis()) == 0) {
            db.dao().upsertProgress(ChapterProgressEntity(chapter.id, workId, 0, System.currentTimeMillis(), readingTimeMs = readingMs, listeningTimeMs = listeningMs))
        }
    }

    suspend fun latestChapter(workId: String): ChapterProgressEntity? = db.dao().latestChapter(workId)
    suspend fun progress(chapterId: String): ChapterProgressEntity? = db.dao().progress(chapterId)
    suspend fun allProgress(): List<ChapterProgressEntity> = db.dao().allProgress()

    suspend fun search(query: String): List<SearchHit> {
        val escaped = query.trim()
            .replace(Regex("[\"*()]"), " ")
            .split(Regex("\\s+"))
            .filter { it.isNotBlank() }
            .joinToString(" ") { "$it*" }
        if (escaped.isBlank()) return emptyList()
        return runCatching { db.dao().search(escaped) }.getOrDefault(emptyList())
    }
}
