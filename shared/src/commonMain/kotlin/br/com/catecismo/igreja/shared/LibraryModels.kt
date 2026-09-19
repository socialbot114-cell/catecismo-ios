package br.com.catecismo.igreja.shared

data class WorkSummary(
    val id: String,
    val title: String,
    val author: String = "Catecismo da Igreja Católica",
    val year: Int? = null,
    val category: String,
    val description: String,
    val sourceUrl: String,
    val contentHash: String,
    val coverKey: String? = null,
)

data class ChapterSummary(
    val workId: String,
    val index: Int,
    val title: String,
    val paragraphCount: Int,
)

data class Paragraph(
    val workId: String,
    val chapterIndex: Int,
    val index: Int,
    val text: String,
)

data class ReadingProgress(
    val workId: String,
    val chapterIndex: Int,
    val paragraphIndex: Int,
    val completed: Boolean = false,
    val readingSeconds: Long = 0,
    val listeningSeconds: Long = 0,
)

data class Quote(
    val id: String,
    val workId: String,
    val chapterIndex: Int,
    val paragraphIndex: Int,
    val text: String,
)

data class CharacterSummary(
    val id: String,
    val name: String,
    val workId: String,
    val summary: String,
    val avatarKey: String? = null,
)

fun normalizeSearchQuery(query: String): String = query.trim().replace(Regex("\\s+"), " ")

fun progressFraction(progress: ReadingProgress, chapterCount: Int, paragraphCount: Int): Double {
    if (chapterCount <= 0 || paragraphCount <= 0) return 0.0
    val completedChapters = progress.chapterIndex.coerceIn(0, chapterCount - 1)
    val paragraph = progress.paragraphIndex.coerceIn(0, paragraphCount)
    return ((completedChapters.toDouble() + paragraph.toDouble() / paragraphCount) / chapterCount)
        .coerceIn(0.0, 1.0)
}
