package br.com.catecismo.igreja

import android.content.Context
import android.content.Intent
import android.net.Uri
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
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp

private const val PORTUGUESE_SOURCE = "https://www.montfort.org.br/bra/documentos/catecismo/catecismo_s_pio_x/"
private const val PORTUGUESE_FACSIMILE = "https://archive.org/details/catecismo-maior-de-sc3a3o-pio-x"
private const val ITALIAN_SOURCE = "https://it.wikisource.org/wiki/Compendio_della_dottrina_cristiana/Catechismo_maggiore"

@Composable
fun PiusXScreen() {
    val context = LocalContext.current

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
                Text("CATECISMO MAIOR · 1905", color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                Text("São Pio X", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green, modifier = Modifier.padding(top = 7.dp))
                Text(
                    "Encontre edições em português e italiano do clássico catecismo em perguntas e respostas.",
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.padding(top = 5.dp)
                )
            }
        }

        PiusXSourceCard(
            language = "PORTUGUÊS (BRASIL)",
            title = "Catecismo de São Pio X",
            description = "Texto integral publicado on-line pela Associação Cultural MONTFORT. O Internet Archive também disponibiliza uma edição digital com OCR; o próprio arquivo informa tradução não oficial e atualizações da edição de 1976.",
            action = "Ler no MONTFORT",
            onOpen = { openExternalSource(context, PORTUGUESE_SOURCE) },
            secondaryAction = "Consultar edição digital no Internet Archive",
            onSecondaryOpen = { openExternalSource(context, PORTUGUESE_FACSIMILE) }
        )

        PiusXSourceCard(
            language = "ITALIANO",
            title = "Compendio della dottrina cristiana · Catechismo maggiore",
            description = "Transcrição italiana da edição de Roma, Tipografia Vaticana, 1905, organizada por partes e capítulos na Wikisource.",
            action = "Leggi su Wikisource",
            onOpen = { openExternalSource(context, ITALIAN_SOURCE) }
        )

        Text(
            "As fontes abrem no navegador e precisam de conexão. O original de 1905 está em domínio público; os direitos de traduções e transcrições devem ser avaliados conforme cada edição.",
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
    onSecondaryOpen: (() -> Unit)? = null
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = paper),
        shape = RoundedCornerShape(20.dp)
    ) {
        Column(Modifier.padding(18.dp)) {
            Text(language, color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp, fontSize = 12.sp)
            Text(title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 21.sp, color = green, modifier = Modifier.padding(top = 8.dp))
            Text(description, color = MaterialTheme.colorScheme.onSurfaceVariant, fontSize = 14.sp, lineHeight = 20.sp, modifier = Modifier.padding(top = 8.dp, bottom = 12.dp))
            Button(onClick = onOpen, modifier = Modifier.fillMaxWidth()) { Text(action) }
            if (secondaryAction != null && onSecondaryOpen != null) {
                OutlinedButton(onClick = onSecondaryOpen, modifier = Modifier.fillMaxWidth()) { Text(secondaryAction) }
            }
        }
    }
}

private fun openExternalSource(context: Context, url: String) {
    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(url)))
}
