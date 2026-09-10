package br.com.machadodeassis.biblioteca.db

import androidx.room.Entity
import androidx.room.Fts4
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(tableName = "works")
data class WorkEntity(
    @PrimaryKey val id: String,
    val title: String,
    val author: String,
    val year: Int,
    val category: String,
    val description: String,
    val context: String,
    val characters: String,
    val status: String,
    val sourceUrl: String,
    val chapterCount: Int,
    val wordCount: Int
) {
    val characterList: List<String>
        get() = characters.split("|").filter { it.isNotBlank() }
}

@Entity(tableName = "chapters", indices = [Index("workId")])
data class ChapterEntity(
    @PrimaryKey val id: String,
    val workId: String,
    val order: Int,
    val title: String,
    val paragraphCount: Int
)

@Entity(tableName = "paragraphs", indices = [Index("chapterId"), Index("workId")])
data class ParagraphEntity(
    @PrimaryKey(autoGenerate = true) val rowId: Long = 0,
    val chapterId: String,
    val workId: String,
    val order: Int,
    val text: String
)

@Fts4(contentEntity = ParagraphEntity::class)
@Entity(tableName = "paragraphs_fts")
data class ParagraphFts(val text: String)

@Entity(tableName = "chapter_progress", indices = [Index("workId")])
data class ChapterProgressEntity(
    @PrimaryKey val chapterId: String,
    val workId: String,
    val progress: Int,
    val updatedAt: Long,
    val paragraphIndex: Int = -1,
    val readingTimeMs: Long = 0,
    val listeningTimeMs: Long = 0,
    val isCompleted: Boolean = false,
    val completedAt: Long? = null
)
