package br.com.machadodeassis.biblioteca

import android.content.Context
import androidx.datastore.preferences.core.*
import androidx.datastore.preferences.preferencesDataStore
import kotlinx.coroutines.flow.first
import org.json.JSONArray
import org.json.JSONObject

private val Context.prefs by preferencesDataStore("machado_preferences")

data class Quote(
    val id: String,
    val workId: String,
    val workTitle: String,
    val chapterTitle: String,
    val paragraphIndex: Int,
    val text: String
) {
    fun toJson(): JSONObject = JSONObject()
        .put("id", id)
        .put("workId", workId)
        .put("workTitle", workTitle)
        .put("chapterTitle", chapterTitle)
        .put("paragraphIndex", paragraphIndex)
        .put("text", text)

    companion object {
        fun fromJson(o: JSONObject): Quote = Quote(
            id = o.getString("id"),
            workId = o.optString("workId"),
            workTitle = o.optString("workTitle"),
            chapterTitle = o.optString("chapterTitle"),
            paragraphIndex = o.optInt("paragraphIndex", -1),
            text = o.getString("text")
        )
    }
}

class Preferences(private val context: Context) {
    private val kFav = stringSetPreferencesKey("favorites")
    private val kCharacterFav = stringSetPreferencesKey("favorite_characters")
    private val kQuotesLegacy = stringSetPreferencesKey("quotes")
    private val kQuotes = stringPreferencesKey("quotes_v2")
    private val kTheme = stringPreferencesKey("theme")
    private val kFont = floatPreferencesKey("font")

    suspend fun favorites(): List<String> =
        context.prefs.data.first()[kFav]?.toList() ?: emptyList()

    suspend fun theme(): String =
        context.prefs.data.first()[kTheme] ?: "Claro"

    suspend fun fontSize(): Float =
        context.prefs.data.first()[kFont] ?: 20f

    suspend fun quotes(): List<Quote> {
        val data = context.prefs.data.first()
        val raw = data[kQuotes]
        if (raw != null) {
            return runCatching {
                JSONArray(raw).let { arr -> (0 until arr.length()).map { Quote.fromJson(arr.getJSONObject(it)) } }
            }.getOrDefault(emptyList())
        }
        val legacy = data[kQuotesLegacy] ?: return emptyList()
        val migrated = legacy.map { text -> Quote(id = "legacy:${text.hashCode()}", workId = "", workTitle = "", chapterTitle = "", paragraphIndex = -1, text = text) }
        if (migrated.isNotEmpty()) {
            context.prefs.edit { it[kQuotes] = JSONArray().apply { migrated.forEach { put(it.toJson()) } }.toString() }
            context.prefs.edit { it.remove(kQuotesLegacy) }
        }
        return migrated
    }

    suspend fun toggleFavorite(id: String) {
        val cur = favorites().toMutableSet()
        if (!cur.add(id)) cur.remove(id)
        context.prefs.edit { it[kFav] = cur }
    }

    suspend fun favoriteCharacters(): List<String> =
        context.prefs.data.first()[kCharacterFav]?.toList() ?: emptyList()

    suspend fun toggleCharacterFavorite(id: String) {
        val cur = favoriteCharacters().toMutableSet()
        if (!cur.add(id)) cur.remove(id)
        context.prefs.edit { it[kCharacterFav] = cur }
    }

    suspend fun addQuote(quote: Quote) {
        val cur = quotes().toMutableList()
        if (cur.any { it.id == quote.id }) return
        cur.add(quote)
        context.prefs.edit { it[kQuotes] = JSONArray().apply { cur.forEach { put(it.toJson()) } }.toString() }
    }

    suspend fun removeQuote(id: String) {
        val cur = quotes().filterNot { it.id == id }
        context.prefs.edit { it[kQuotes] = JSONArray().apply { cur.forEach { put(it.toJson()) } }.toString() }
    }

    suspend fun setTheme(value: String) {
        context.prefs.edit { it[kTheme] = value }
    }

    suspend fun setFontSize(value: Float) {
        context.prefs.edit { it[kFont] = value }
    }
}
