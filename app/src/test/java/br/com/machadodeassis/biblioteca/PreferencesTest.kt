package br.com.machadodeassis.biblioteca

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
        p.toggleFavorite("dom")
        assertTrue(p.favorites().contains("dom"))
        p.toggleFavorite("dom")
        assertTrue(!p.favorites().contains("dom"))
    }

    @Test fun `citação estruturada roundtrip`() = runBlocking {
        val p = prefs()
        val q = Quote("dom:0:5", "dom", "Dom Casmurro", "Capítulo I", 5, "Uma noite destas.")
        p.addQuote(q)
        val all = p.quotes()
        assertEquals(1, all.size)
        assertEquals("dom", all[0].workId)
        assertEquals("Capítulo I", all[0].chapterTitle)
        assertEquals(5, all[0].paragraphIndex)
        p.removeQuote("dom:0:5")
        assertTrue(p.quotes().isEmpty())
    }

    @Test fun `citação duplicada não insere duas vezes`() = runBlocking {
        val p = prefs()
        val q = Quote("dom:0:5", "dom", "Dom Casmurro", "Capítulo I", 5, "Uma noite destas.")
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
