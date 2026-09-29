package br.com.catecismo.igreja

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.appcompat.app.AppCompatDelegate
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private const val PORTUGUESE_SOURCE = "https://www.montfort.org.br/bra/documentos/catecismo/catecismo_s_pio_x/"
private const val PORTUGUESE_FACSIMILE = "https://archive.org/details/catecismo-maior-de-sc3a3o-pio-x"
private const val ITALIAN_SOURCE = "https://it.wikisource.org/wiki/Compendio_della_dottrina_cristiana/Catechismo_maggiore"
private const val ENGLISH_SOURCE = "https://archive.org/details/catechism-of-pope-saint-pius-x"
private const val SPANISH_SOURCE = "https://archive.org/details/catecismo-mayor-de-san-pio-x-1906"
private const val FRENCH_FULL_SOURCE = "https://archive.org/details/catechisme-de-rome-de-st-pie-x-1905"
private const val FRENCH_ABRIDGED_SOURCE = "https://archive.org/details/catechisme-de-rome-de-saint-pie-x-1912"

@Composable
fun PiusXScreen() {
    val context = LocalContext.current
    val selectedLanguage = AppCompatDelegate.getApplicationLocales().toLanguageTags().ifBlank { AppLanguage.SYSTEM }
    val systemLanguage = context.resources.configuration.locales[0]?.toLanguageTag() ?: AppLanguage.PORTUGUESE
    val contentLanguage = AppLanguage.contentTag(selectedLanguage, systemLanguage)

    Column(
        modifier = Modifier
            .fillMaxSize()
            .verticalScroll(rememberScrollState())
            .padding(horizontal = 22.dp, vertical = 18.dp),
        verticalArrangement = Arrangement.spacedBy(14.dp)
    ) {
        Card(
            colors = CardDefaults.cardColors(containerColor = paper),
            shape = RoundedCornerShape(20.dp)
        ) {
            Column(Modifier.padding(18.dp)) {
                Text(stringResource(R.string.language_catechism_major), color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                Text(stringResource(R.string.language_catechism_heading), fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green, modifier = Modifier.padding(top = 7.dp))
                Text(
                    stringResource(R.string.language_catechism_intro),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 5.dp)
                )
            }
        }

        when (contentLanguage) {
            AppLanguage.ENGLISH -> PiusXSourceCard(
                language = stringResource(R.string.piox_english_language),
                title = stringResource(R.string.piox_english_title),
                description = stringResource(R.string.piox_english_summary),
                action = stringResource(R.string.piox_open_archive),
                onOpen = { openExternalSource(context, ENGLISH_SOURCE) },
                note = stringResource(R.string.piox_english_note)
            )
            AppLanguage.SPANISH -> PiusXSourceCard(
                language = stringResource(R.string.piox_spanish_language),
                title = stringResource(R.string.piox_spanish_title),
                description = stringResource(R.string.piox_spanish_summary),
                action = stringResource(R.string.piox_open_archive),
                onOpen = { openExternalSource(context, SPANISH_SOURCE) },
                note = stringResource(R.string.piox_spanish_note)
            )
            AppLanguage.FRENCH -> {
                PiusXSourceCard(
                    language = stringResource(R.string.piox_french_language),
                    title = stringResource(R.string.piox_french_full_title),
                    description = stringResource(R.string.piox_french_full_summary),
                    action = stringResource(R.string.piox_open_archive),
                    onOpen = { openExternalSource(context, FRENCH_FULL_SOURCE) }
                )
                PiusXSourceCard(
                    language = stringResource(R.string.piox_french_1912_language),
                    title = stringResource(R.string.piox_french_1912_title),
                    description = stringResource(R.string.piox_french_1912_summary),
                    action = stringResource(R.string.piox_open_archive),
                    onOpen = { openExternalSource(context, FRENCH_ABRIDGED_SOURCE) },
                    note = stringResource(R.string.piox_french_1912_note)
                )
            }
            else -> {
                PiusXSourceCard(
                    language = stringResource(R.string.language_piox_portuguese),
                    title = stringResource(R.string.language_piox_portuguese_title),
                    description = stringResource(R.string.language_piox_portuguese_summary),
                    action = stringResource(R.string.language_piox_montfort),
                    onOpen = { openExternalSource(context, PORTUGUESE_SOURCE) },
                    secondaryAction = stringResource(R.string.language_piox_facsimile),
                    onSecondaryOpen = { openExternalSource(context, PORTUGUESE_FACSIMILE) },
                    note = stringResource(R.string.language_piox_facsimile_note)
                )
                PiusXSourceCard(
                    language = stringResource(R.string.language_piox_italian),
                    title = stringResource(R.string.language_piox_italian_title),
                    description = stringResource(R.string.language_piox_italian_summary),
                    action = stringResource(R.string.language_piox_wikisource),
                    onOpen = { openExternalSource(context, ITALIAN_SOURCE) }
                )
            }
        }

        Text(
            stringResource(R.string.language_piox_offline_status),
            fontSize = 12.sp,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 4.dp)
        )
        Spacer(Modifier.height(8.dp))
    }
}

@Composable
private fun PiusXSourceCard(
    language: String,
    title: String,
    description: String,
    action: String,
    onOpen: () -> Unit,
    secondaryAction: String? = null,
    onSecondaryOpen: (() -> Unit)? = null,
    note: String? = null
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = paper),
        shape = RoundedCornerShape(20.dp)
    ) {
        Column(Modifier.padding(16.dp)) {
            Text(language, color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp, fontSize = 12.sp)
            Text(title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 19.sp, color = green, modifier = Modifier.padding(top = 7.dp))
            Text(description, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 13.sp, lineHeight = 18.sp, modifier = Modifier.padding(top = 7.dp, bottom = 10.dp))
            Button(onClick = onOpen, modifier = Modifier.fillMaxWidth()) { Text(action) }
            if (secondaryAction != null && onSecondaryOpen != null) {
                OutlinedButton(onClick = onSecondaryOpen, modifier = Modifier.fillMaxWidth()) { Text(secondaryAction) }
            }
            if (note != null) {
                Text(note, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 11.sp, lineHeight = 15.sp)
            }
        }
    }
}

private fun openExternalSource(context: Context, url: String) {
    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
}
