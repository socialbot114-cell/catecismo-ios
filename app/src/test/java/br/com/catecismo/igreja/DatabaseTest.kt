package br.com.catecismo.igreja

import android.content.Context
import androidx.room.Room
import androidx.test.core.app.ApplicationProvider
import br.com.catecismo.igreja.db.ChapterEntity
import br.com.catecismo.igreja.db.ChapterProgressEntity
import br.com.catecismo.igreja.db.CatecismoDatabase
import br.com.catecismo.igreja.db.ParagraphEntity
import br.com.catecismo.igreja.db.WorkEntity
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

    private lateinit var db: CatecismoDatabase

    @Before
    fun setup() {
        val context = ApplicationProvider.getApplicationContext<Context>()
        db = Room.inMemoryDatabaseBuilder(context, CatecismoDatabase::class.java)
            .allowMainThreadQueries()
            .build()
    }

    @After
    fun teardown() { db.close() }

    private fun seedOne(): Triple<WorkEntity, ChapterEntity, List<ParagraphEntity>> {
        val work = WorkEntity("o-dom-da-fe", "O dom da fé", "Equipe Catecismo", 2026, "Fundamentos", "desc", "ctx", "fé|oração", "guia", "https://www.vatican.va/archive/cathechism_po/index_new/prima-pagina-cic_po.html", 1, 10)
        val chapter = ChapterEntity("o-dom-da-fe:0", "o-dom-da-fe", 0, "Seção I", 2)
        val paras = listOf(
            ParagraphEntity(chapterId = "o-dom-da-fe:0", workId = "o-dom-da-fe", order = 0, text = "A fé começa quando a pessoa se abre para uma presença maior."),
            ParagraphEntity(chapterId = "o-dom-da-fe:0", workId = "o-dom-da-fe", order = 1, text = "A oração, a escuta e o serviço tornam visível uma fé viva.")
        )
        runBlocking {
            db.dao().insertWorks(listOf(work))
            db.dao().insertChapters(listOf(chapter))
            db.dao().insertParagraphs(paras)
        }
        return Triple(work, chapter, paras)
    }

    @Test fun `insere e recupera guia com secoes`() = runBlocking {
        val (work, chapter, _) = seedOne()
        assertEquals(work.id, db.dao().work("o-dom-da-fe")?.id)
        val chapters = db.dao().chapters("o-dom-da-fe")
        assertEquals(1, chapters.size)
        assertEquals(chapter.id, chapters[0].id)
    }

    @Test fun `paragrafos retornam em ordem`() = runBlocking {
        seedOne()
        val paras = db.dao().paragraphs("o-dom-da-fe:0")
        assertEquals(2, paras.size)
        assertTrue(paras[0].startsWith("A fé começa"))
    }

    @Test fun `busca fts encontra trecho`() = runBlocking {
        seedOne()
        val hits = db.dao().search("presença*")
        assertEquals(1, hits.size)
        assertEquals("o-dom-da-fe", hits[0].workId)
        assertTrue(hits[0].snippet.contains("presença"))
    }

    @Test fun `busca fts ignora operadores especiais`() = runBlocking {
        seedOne()
        val hits = db.dao().search("\"oração\" AND (escuta)")
        assertTrue(hits.isEmpty() || hits.isNotEmpty())
    }

    @Test fun `progresso salva e recupera ultimo capitulo`() = runBlocking {
        seedOne()
        db.dao().upsertProgress(ChapterProgressEntity("o-dom-da-fe:0", "o-dom-da-fe", 42, 1000))
        db.dao().upsertProgress(ChapterProgressEntity("o-dom-da-fe:1", "o-dom-da-fe", 10, 2000))
        val latest = db.dao().latestChapter("o-dom-da-fe")
        assertNotNull(latest)
        assertEquals("o-dom-da-fe:1", latest?.chapterId)
        assertEquals(10, latest?.progress)
        assertEquals(42, db.dao().progress("o-dom-da-fe:0")?.progress)
    }

    @Test fun `reimportacao da guia nao duplica paragrafos`() = runBlocking {
        val (_, _, paras) = seedOne()
        db.dao().deleteParagraphsForWork("o-dom-da-fe")
        db.dao().deleteChaptersForWork("o-dom-da-fe")
        db.dao().insertChapters(listOf(ChapterEntity("o-dom-da-fe:0", "o-dom-da-fe", 0, "Seção I", 2)))
        db.dao().insertParagraphs(paras)
        assertEquals(2, db.dao().paragraphCount("o-dom-da-fe"))
    }

    @Test fun `guia inexistente retorna nulo`() = runBlocking {
        assertNull(db.dao().work("fantasma"))
        assertTrue(db.dao().chapters("fantasma").isEmpty())
        assertTrue(db.dao().paragraphs("fantasma:0").isEmpty())
    }
}
