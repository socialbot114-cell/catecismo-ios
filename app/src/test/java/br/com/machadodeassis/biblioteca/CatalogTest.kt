package br.com.machadodeassis.biblioteca

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File
import java.util.zip.GZIPInputStream

class CatalogTest {

    private fun readGzip(path: String): String =
        GZIPInputStream(File(path).inputStream()).use { it.readBytes().toString(Charsets.UTF_8) }

    private fun textsDir(): File {
        val candidates = listOf(File("src/main/assets/texts"), File("app/src/main/assets/texts"))
        return candidates.first { it.isDirectory }
    }

    private fun index(): JSONArray = JSONArray(readGzip(File(textsDir(), "index.json.gzdata").path))

    @Test fun `index tem pelo menos 12 obras integrais`() {
        val index = index()
        assertTrue("index com ${index.length()} obras", index.length() >= 12)
        for (i in 0 until index.length()) {
            assertEquals("integral", index.getJSONObject(i).getString("status"))
        }
    }

    @Test fun `cada obra do index tem asset correspondente com capitulos`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val meta = index.getJSONObject(i)
            val id = meta.getString("id")
            val asset = File(dir, "$id.json.gzdata")
            assertTrue("faltando asset $id", asset.exists() && asset.length() > 0)
            val work = JSONObject(readGzip(asset.path))
            assertEquals(id, work.getString("id"))
            assertEquals("Machado de Assis", work.getString("author"))
            assertTrue("obra $id sem capítulos", work.getJSONArray("chapters").length() > 0)
            assertTrue("obra $id sem palavras", meta.getInt("words") > 0)
            assertEquals(meta.getInt("chapters"), work.getJSONArray("chapters").length())
        }
    }

    @Test fun `capitulos tem titulo e paragrafos não vazios`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val id = index.getJSONObject(i).getString("id")
            val work = JSONObject(readGzip(File(dir, "$id.json.gzdata").path))
            val chapters = work.getJSONArray("chapters")
            for (c in 0 until chapters.length()) {
                val chapter = chapters.getJSONObject(c)
                assertTrue("capítulo vazio em $id:$c", chapter.getString("title").isNotBlank())
                val paras = chapter.getJSONArray("paragraphs")
                assertTrue("$id:$c sem parágrafos", paras.length() > 0)
                for (p in 0 until paras.length()) {
                    assertTrue("$id:$c:$p vazio", paras.getString(p).isNotBlank())
                }
            }
        }
    }

    @Test fun `texto não contem html`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val id = index.getJSONObject(i).getString("id")
            val raw = readGzip(File(dir, "$id.json.gzdata").path)
            assertTrue("$id contém html", !raw.contains("<p>") && !raw.contains("</div>"))
        }
    }

    @Test fun `obras contidas tem ano e categoria`() {
        val index = index()
        for (i in 0 until index.length()) {
            val meta = index.getJSONObject(i)
            assertTrue(meta.getInt("year") in 1839..1908)
            assertTrue(meta.getString("category") in listOf("Romance", "Conto"))
        }
    }
}
