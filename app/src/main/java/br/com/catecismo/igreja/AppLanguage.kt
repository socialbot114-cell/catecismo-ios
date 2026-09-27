package br.com.catecismo.igreja

import java.util.Locale

object AppLanguage {
    const val SYSTEM = "system"
    const val PORTUGUESE = "pt-BR"
    const val ENGLISH = "en"
    const val SPANISH = "es"
    const val FRENCH = "fr"

    val choices = listOf(SYSTEM, PORTUGUESE, ENGLISH, SPANISH, FRENCH)

    fun labelResource(tag: String): Int = when (tag) {
        PORTUGUESE -> R.string.language_portuguese
        ENGLISH -> R.string.language_english
        SPANISH -> R.string.language_spanish
        FRENCH -> R.string.language_french
        else -> R.string.language_system
    }

    fun contentTag(selectedTag: String, systemTag: String): String {
        val language = Locale.forLanguageTag(if (selectedTag == SYSTEM) systemTag else selectedTag).language
        return when (language.lowercase(Locale.ROOT)) {
            "en" -> ENGLISH
            "es" -> SPANISH
            "fr" -> FRENCH
            "pt" -> PORTUGUESE
            else -> PORTUGUESE
        }
    }
}
