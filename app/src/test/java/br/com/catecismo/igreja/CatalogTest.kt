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

    @Test fun `index tem doze obras entre guias e catecismo`() {
        val index = index()
        assertTrue("index com ${index.length()} obras", index.length() >= 12)
        for (i in 0 until index.length()) {
            val status = index.getJSONObject(i).getString("status")
            assertTrue("status inválido: $status", status == "guia" || status == "catecismo")
        }
    }

    @Test fun `cada obra tem asset correspondente com seções`() {
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
            assertEquals(status, work.getString("status"))
            when (status) {
                "guia" -> assertEquals("Equipe Catecismo", work.getString("author"))
                "catecismo" -> assertEquals("Catecismo da Igreja Católica", work.getString("author"))
            }
            assertTrue("obra $id sem seções", work.getJSONArray("chapters").length() > 0)
            assertTrue("obra $id sem palavras", meta.getInt("words") > 0)
            assertEquals(meta.getInt("chapters"), work.getJSONArray("chapters").length())
        }
    }

    @Test fun `seções tem título e parágrafos não vazios`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val id = index.getJSONObject(i).getString("id")
            val work = JSONObject(readJson(File(dir, "$id.json").path))
            val chapters = work.getJSONArray("chapters")
            for (c in 0 until chapters.length()) {
                val chapter = chapters.getJSONObject(c)
                assertTrue("seção vazia em $id:$c", chapter.getString("title").isNotBlank())
                val paras = chapter.getJSONArray("paragraphs")
                assertTrue("$id:$c sem parágrafos", paras.length() > 0)
                for (p in 0 until paras.length()) {
                    assertTrue("$id:$c:$p vazio", paras.getString(p).isNotBlank())
                }
            }
        }
    }

    @Test fun `texto não contém html`() {
        val dir = textsDir()
        val index = index()
        for (i in 0 until index.length()) {
            val id = index.getJSONObject(i).getString("id")
            val raw = readJson(File(dir, "$id.json").path)
            assertTrue("$id contém html", !raw.contains("<p>") && !raw.contains("</div>"))
        }
    }

    @Test fun `textos integrais cobrem os quatro partes do Catecismo`() {
        val index = index()
        val catecismo = (0 until index.length()).mapNotNull { i ->
            val entry = index.getJSONObject(i)
            if (entry.getString("status") == "catecismo") entry.getString("id") else null
        }
        assertTrue("faltam obras do Catecismo", catecismo.size >= 4)
        val set = catecismo.toSet()
        assertTrue("catecismo-parte-1" in set)
        assertTrue("catecismo-parte-2" in set)
        assertTrue("catecismo-parte-3" in set)
        assertTrue("catecismo-parte-4" in set)
    }

    @Test fun `ano e categoria corretos por status`() {
        val index = index()
        for (i in 0 until index.length()) {
            val meta = index.getJSONObject(i)
            val year = meta.getInt("year")
            val status = meta.getString("status")
            val id = meta.getString("id")
            val expectedYear = if (status == "guia") 2026 else 1997
            assertEquals("ano de $id incorreto para o status", expectedYear, year)
            assertTrue(meta.getString("category").isNotBlank())
        }
    }
}
