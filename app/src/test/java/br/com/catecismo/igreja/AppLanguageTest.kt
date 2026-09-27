package br.com.catecismo.igreja

import org.junit.Assert.assertEquals
import org.junit.Test

class AppLanguageTest {
    @Test fun `system language maps to the nearest supported content`() {
        assertEquals("en", AppLanguage.contentTag(AppLanguage.SYSTEM, "en-GB"))
        assertEquals("es", AppLanguage.contentTag(AppLanguage.SYSTEM, "es-MX"))
        assertEquals("fr", AppLanguage.contentTag(AppLanguage.SYSTEM, "fr-CA"))
        assertEquals("pt-BR", AppLanguage.contentTag(AppLanguage.SYSTEM, "pt-PT"))
        assertEquals("pt-BR", AppLanguage.contentTag(AppLanguage.SYSTEM, "de-DE"))
    }

    @Test fun `explicit language overrides device language`() {
        assertEquals("fr", AppLanguage.contentTag("fr", "en-US"))
        assertEquals("es", AppLanguage.contentTag("es", "pt-BR"))
    }
}
