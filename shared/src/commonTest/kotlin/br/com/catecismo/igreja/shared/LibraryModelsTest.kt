package br.com.catecismo.igreja.shared

import kotlin.test.Test
import kotlin.test.assertEquals

class LibraryModelsTest {
    @Test
    fun normalizesSearchWhitespace() {
        assertEquals("fé e oração", normalizeSearchQuery("  fé   e oração  "))
    }

    @Test
    fun calculatesProgressWithinBounds() {
        val progress = ReadingProgress("o-dom-da-fe", chapterIndex = 1, paragraphIndex = 5)
        assertEquals(0.3125, progressFraction(progress, chapterCount = 4, paragraphCount = 20))
    }
}
