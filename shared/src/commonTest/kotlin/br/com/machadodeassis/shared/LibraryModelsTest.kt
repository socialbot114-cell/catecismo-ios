package br.com.machadodeassis.shared

import kotlin.test.Test
import kotlin.test.assertEquals

class LibraryModelsTest {
    @Test
    fun normalizesSearchWhitespace() {
        assertEquals("dom casmurro", normalizeSearchQuery("  dom   casmurro  "))
    }

    @Test
    fun calculatesProgressWithinBounds() {
        val progress = ReadingProgress("dom", chapterIndex = 1, paragraphIndex = 5)
        assertEquals(0.3125, progressFraction(progress, chapterCount = 4, paragraphCount = 20))
    }
}
