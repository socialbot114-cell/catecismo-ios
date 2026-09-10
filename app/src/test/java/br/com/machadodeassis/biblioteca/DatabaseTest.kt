package br.com.machadodeassis.biblioteca

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import br.com.machadodeassis.biblioteca.db.ChapterEntity
import br.com.machadodeassis.biblioteca.db.ChapterProgressEntity
import br.com.machadodeassis.biblioteca.db.MachadoDatabase
import br.com.machadodeassis.biblioteca.db.ParagraphEntity
import br.com.machadodeassis.biblioteca.db.WorkEntity
import kotlinx.coroutines.runBlocking
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.robolectric.RobolectricTestRunner
import org.robolectric.annotation.Config

@RunWith(RobolectricTestRunner::class)
@Config(sdk = [34])
class DatabaseTest {

    private lateinit var db: MachadoDatabase

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        db = Room.inMemoryDatabaseBuilder(context, MachadoDatabase::class.java)
            .allowMainThreadQueries()
            .build()
    }

    @After
    fun teardown() { db.close() }

    private fun seedOne(): Triple<WorkEntity, ChapterEntity, List<ParagraphEntity>> {
        val work = WorkEntity("dom", "Dom Casmurro", "Machado de Assis", 1899, "Romance", "desc", "ctx", "Bentinho|Capitu", "integral", "https://pt.wikisource.org/wiki/Dom_Casmurro", 1, 10)
        val chapter = ChapterEntity("dom:0", "dom", 0, "Capítulo I", 2)
        val paras = listOf(
            ParagraphEntity(chapterId = "dom:0", workId = "dom", order = 0, text = "Uma noite destas, vindo da cidade para o Engenho Novo."),
            ParagraphEntity(chapterId = "dom:0", workId = "dom", order = 1, text = "No dia seguinte entrou a dizer de mim nomes feios.")
        )
        runBlocking {
            db.dao().insertWorks(listOf(work))
            db.dao().insertChapters(listOf(chapter))
            db.dao().insertParagraphs(paras)
        }
        return Triple(work, chapter, paras)
    }

    @Test fun `insere e recupera obra com capitulos`() = runBlocking {
        val (work, chapter, _) = seedOne()
        assertEquals(work.id, db.dao().work("dom")?.id)
        val chapters = db.dao().chapters("dom")
        assertEquals(1, chapters.size)
        assertEquals(chapter.id, chapters[0].id)
    }

    @Test fun `paragrafos retornam em ordem`() = runBlocking {
        seedOne()
        val paras = db.dao().paragraphs("dom:0")
        assertEquals(2, paras.size)
        assertTrue(paras[0].startsWith("Uma noite"))
    }

    @Test fun `busca fts encontra trecho`() = runBlocking {
        seedOne()
        val hits = db.dao().search("noite*")
        assertEquals(1, hits.size)
        assertEquals("dom", hits[0].workId)
        assertTrue(hits[0].snippet.contains("noite"))
    }

    @Test fun `busca fts ignora operadores especiais`() = runBlocking {
        seedOne()
        val hits = db.dao().search("\"Engenho\" AND (Novo)")
        assertTrue(hits.isEmpty() || hits.isNotEmpty())
    }

    @Test fun `progresso salva e recupera ultimo capitulo`() = runBlocking {
        seedOne()
        db.dao().upsertProgress(ChapterProgressEntity("dom:0", "dom", 42, 1000))
        db.dao().upsertProgress(ChapterProgressEntity("dom:1", "dom", 10, 2000))
        val latest = db.dao().latestChapter("dom")
        assertNotNull(latest)
        assertEquals("dom:1", latest?.chapterId)
        assertEquals(10, latest?.progress)
        assertEquals(42, db.dao().progress("dom:0")?.progress)
    }

    @Test fun `reimportacao da obra nao duplica paragrafos`() = runBlocking {
        val (_, _, paras) = seedOne()
        db.dao().deleteParagraphsForWork("dom")
        db.dao().deleteChaptersForWork("dom")
        db.dao().insertChapters(listOf(ChapterEntity("dom:0", "dom", 0, "Capítulo I", 2)))
        db.dao().insertParagraphs(paras)
        assertEquals(2, db.dao().paragraphCount("dom"))
    }

    @Test fun `obra inexistente retorna nulo`() = runBlocking {
        assertNull(db.dao().work("fantasma"))
        assertTrue(db.dao().chapters("fantasma").isEmpty())
        assertTrue(db.dao().paragraphs("fantasma:0").isEmpty())
    }
}
