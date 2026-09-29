package br.com.catecismo.igreja

import org.json.JSONArray
import org.json.JSONObject
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test
import java.io.File

class CatalogTest {

    private fun readJson(path: String): String = File(path).readText()

    private fun textsDir(): File {
        val candidates = listOf(File("src/main/assets/texts"), File("app/src/main/assets/texts"))
        return candidates.first { it.isDirectory }
    }

    private fun index(): JSONArray = JSONArray(readJson(File(textsDir(), "index.json").path))

    @Test fun `index tem oito guias e quatro partes do Catecismo`() {
        val index = index()
        assertEquals(12, index.length())
        var guides = 0
        var catechismParts = 0
        for (i in 0 until index.length()) {
            when (index.getJSONObject(i).getString("status")) {
                "guia" -> guides++
                "catecismo" -> catechismParts++
                else -> throw AssertionError("status inválido no índice")
            }
        }
        assertEquals(8, guides)
        assertEquals(4, catechismParts)
    }

    @Test fun `cada guia do index tem asset correspondente com secoes`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val meta = index.getJSONObject(i)
            val id = meta.getString("id")
            val asset = File(dir, "$id.json")
            assertTrue("faltando asset $id", asset.exists() && asset.length() > 0)
            val work = JSONObject(readJson(asset.path))
            assertEquals(id, work.getString("id"))
            val status = meta.getString("status")
            val expectedAuthor = if (status == "guia") "Equipe Catecismo" else "Catecismo da Igreja Católica"
            assertEquals(expectedAuthor, work.getString("author"))
            assertTrue("guia $id sem seçãos", work.getJSONArray("chapters").length() > 0)
            assertTrue("guia $id sem palavras", meta.getInt("words") > 0)
            assertEquals(meta.getInt("chapters"), work.getJSONArray("chapters").length())
        }
    }

    @Test fun `secoes tem titulo e paragrafos não vazios`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val id = index.getJSONObject(i).getString("id")
            val work = JSONObject(readJson(File(dir, "$id.json").path))
            val chapters = work.getJSONArray("chapters")
            for (c in 0 until chapters.length()) {
                val chapter = chapters.getJSONObject(c)
                assertTrue("seção vazio em $id:$c", chapter.getString("title").isNotBlank())
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
            val raw = readJson(File(dir, "$id.json").path)
            assertTrue("$id contém html", !raw.contains("<p>") && !raw.contains("</div>"))
        }
    }

    @Test fun `obras tem ano e categoria coerentes com o tipo`() {
        val index = index()
        for (i in 0 until index.length()) {
            val meta = index.getJSONObject(i)
            assertEquals(if (meta.getString("status") == "guia") 2026 else 1997, meta.getInt("year"))
            assertTrue(meta.getString("category").isNotBlank())
        }
    }
}
