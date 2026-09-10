package br.com.machadodeassis.biblioteca.db

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.preferencesDataStore
import androidx.room.withTransaction
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.withContext
import org.json.JSONArray
import org.json.JSONObject
import java.util.zip.GZIPInputStream

private val Context.seedStore by preferencesDataStore("machado_seed")

class Seeder(private val context: Context, private val db: MachadoDatabase) {

    suspend fun seedIfNeeded(onProgress: (Int, Int) -> Unit = { _, _ -> }): Boolean = withContext(Dispatchers.IO) {
        val key = booleanPreferencesKey("seeded_v2")
        val done = context.seedStore.data.first()[key] ?: false
        if (done && db.dao().workCount() > 0) return@withContext true

        val indexJson = readGzipJson("texts/index.json.gzdata") ?: return@withContext false
        val array = JSONObject("{\"items\":$indexJson}").getJSONArray("items")
        val total = array.length()
        var imported = 0
        onProgress(0, total)

        for (i in 0 until array.length()) {
            val meta = array.getJSONObject(i)
            val id = meta.getString("id")
            val workJson = readGzipJson("texts/$id.json.gzdata")
            if (workJson == null) {
                onProgress(imported, total)
                continue
            }
            val w = JSONObject(workJson)
            val chaptersArr = w.getJSONArray("chapters")
            if (w.getString("id") != id) continue
            if (meta.has("chapters") && chaptersArr.length() != meta.getInt("chapters")) continue
            if (meta.has("author") && w.getString("author") != meta.getString("author")) continue
            importWork(w)
            imported++
            onProgress(imported, total)
        }

        if (imported == total && total > 0) {
            context.seedStore.edit { it[key] = true }
            true
        } else {
            false
        }
    }

    private suspend fun importWork(w: JSONObject) = db.withTransaction {
        val wid = w.getString("id")
        val works = w.getJSONArray("chapters")
        db.dao().deleteParagraphsForWork(wid)
        db.dao().deleteChaptersForWork(wid)
        db.dao().insertWorks(listOf(
            WorkEntity(
                id = wid, title = w.getString("title"), author = w.getString("author"),
                year = w.getInt("year"), category = w.getString("category"),
                description = w.optString("description"), context = w.optString("context"),
                characters = join(w.optJSONArray("characters")),
                status = w.getString("status"), sourceUrl = w.optString("sourceUrl"),
                chapterCount = works.length(),
                wordCount = sumWords(works)
            )
        ))
        db.dao().insertChapters(
            (0 until works.length()).map { ci ->
                val c = works.getJSONObject(ci)
                ChapterEntity(id = "$wid:$ci", workId = wid, order = ci, title = c.getString("title"), paragraphCount = c.getJSONArray("paragraphs").length())
            }
        )
        (0 until works.length()).forEach { ci ->
            val c = works.getJSONObject(ci)
            val paras = c.getJSONArray("paragraphs")
            db.dao().insertParagraphs(
                (0 until paras.length()).map { pi -> ParagraphEntity(chapterId = "$wid:$ci", workId = wid, order = pi, text = paras.getString(pi)) }
            )
        }
    }

    private fun join(a: JSONArray?): String {
        if (a == null) return ""
        val out = StringBuilder()
        for (i in 0 until a.length()) { if (i > 0) out.append("|"); out.append(a.getString(i)) }
        return out.toString()
    }

    private fun sumWords(works: JSONArray): Int {
        var n = 0
        for (i in 0 until works.length()) {
            val paras = works.getJSONObject(i).getJSONArray("paragraphs")
            for (j in 0 until paras.length()) n += paras.getString(j).split(" ").size
        }
        return n
    }

    private fun readGzipJson(path: String): String? = runCatching {
        context.assets.open(path).use { raw -> GZIPInputStream(raw).use { gz -> gz.readBytes().toString(Charsets.UTF_8) } }
    }.getOrNull()
}
