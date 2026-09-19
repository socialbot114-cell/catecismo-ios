package br.com.catecismo.igreja

import android.content.Context
import androidx.test.core.app.ApplicationProvider
import kotlinx.coroutines.runBlocking
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class PreferencesTest {

    private fun prefs(): Preferences = Preferences(ApplicationProvider.getApplicationContext<Context>())

    @Test fun `favoritos toggle`() = runBlocking {
        val p = prefs()
        p.toggleFavorite("o-dom-da-fe")
        assertTrue(p.favorites().contains("o-dom-da-fe"))
        p.toggleFavorite("o-dom-da-fe")
        assertTrue(!p.favorites().contains("o-dom-da-fe"))
    }

    @Test fun `citação estruturada roundtrip`() = runBlocking {
        val p = prefs()
        val q = Quote("o-dom-da-fe:0:1", "o-dom-da-fe", "O dom da fé", "Escutar e responder", 1, "A fé é dom recebido e resposta oferecida.")
        p.addQuote(q)
        val all = p.quotes()
        assertEquals(1, all.size)
        assertEquals("o-dom-da-fe", all[0].workId)
        assertEquals("Escutar e responder", all[0].chapterTitle)
        assertEquals(1, all[0].paragraphIndex)
        p.removeQuote("o-dom-da-fe:0:1")
        assertTrue(p.quotes().isEmpty())
    }

    @Test fun `citação duplicada não insere duas vezes`() = runBlocking {
        val p = prefs()
        val q = Quote("o-dom-da-fe:0:1", "o-dom-da-fe", "O dom da fé", "Escutar e responder", 1, "A fé é dom recebido e resposta oferecida.")
        p.addQuote(q)
        p.addQuote(q)
        assertEquals(1, p.quotes().size)
    }

    @Test fun `tema e fonte persistem`() = runBlocking {
        val p = prefs()
        p.setTheme("Sépia")
        p.setFontSize(24f)
        assertEquals("Sépia", p.theme())
        assertEquals(24f, p.fontSize())
    }
}
