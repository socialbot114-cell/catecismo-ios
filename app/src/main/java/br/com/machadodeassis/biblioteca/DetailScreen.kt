package br.com.machadodeassis.biblioteca

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.machadodeassis.biblioteca.data.LibraryRepository
import br.com.machadodeassis.biblioteca.db.ChapterEntity
import br.com.machadodeassis.biblioteca.db.WorkEntity

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DetailScreen(work: WorkEntity, openChapter: (ChapterEntity) -> Unit, repo: LibraryRepository, onToggleFav: () -> Unit, isFav: Boolean, onBack: () -> Unit) {
    var chapters by remember { mutableStateOf<List<ChapterEntity>>(emptyList()) }
    var latestIndex by remember { mutableIntStateOf(0) }
    LaunchedEffect(work.id) {
        val ch = repo.chapters(work.id)
        chapters = ch
        val latest = repo.latestChapter(work.id)
        latestIndex = ch.indexOfFirst { it.id == latest?.chapterId }.takeIf { it >= 0 } ?: 0
    }
    Scaffold(topBar = {
        TopAppBar(title = { Text(work.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 20.sp) },
            navigationIcon = { IconButton(onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Voltar") } },
            actions = { IconButton(onToggleFav) { Icon(if (isFav) Icons.Filled.Star else Icons.Filled.StarBorder, "Favorito", tint = if (isFav) gold else Color.Unspecified) } })
    }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(22.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Cover(work, Modifier.size(100.dp, 146.dp))
                Spacer(Modifier.width(16.dp))
                Column(Modifier.weight(1f)) {
                    Text("Machado de Assis", color = green, fontWeight = FontWeight.Bold)
                    Text("${work.year}", fontFamily = FontFamily.Serif, fontSize = 18.sp)
                    Text("${work.category.uppercase()} • ${work.chapterCount} capítulos", color = Color(0xFF5a544a))
                    Text("${work.wordCount / 1000}k palavras • ${work.status}", color = Color(0xFF5a544a), fontSize = 13.sp)
                }
            }
            Spacer(Modifier.height(18.dp))
            Button({ if (chapters.isNotEmpty()) openChapter(chapters[latestIndex]) }, Modifier.fillMaxWidth().height(52.dp), shape = RoundedCornerShape(14.dp)) {
                Icon(Icons.Filled.PlayArrow, null); Spacer(Modifier.width(6.dp)); Text(if (latestIndex > 0) "CONTINUAR LEITURA" else "COMEÇAR A LER")
            }
            Spacer(Modifier.height(18.dp))
            SectionTitle("SOBRE A OBRA"); Text(work.description, fontFamily = FontFamily.Serif, fontSize = 17.sp, lineHeight = 25.sp)
            SectionTitle("CONTEXTO"); Text(work.context, fontFamily = FontFamily.Serif, fontSize = 16.sp, lineHeight = 24.sp)
            SectionTitle("PERSONAGENS"); Text(work.characterList.joinToString(" • "))
            SectionTitle("CAPÍTULOS • ${chapters.size}")
            chapters.forEachIndexed { i, c ->
                Row(Modifier.fillMaxWidth().clickable { openChapter(c) }.padding(vertical = 7.dp)) {
                    Text("${i + 1}. ", color = gold); Text(c.title, fontFamily = FontFamily.Serif, fontSize = 16.sp, modifier = Modifier.weight(1f))
                    Icon(Icons.AutoMirrored.Filled.ArrowForward, null, tint = Color(0xFF5a544a))
                }
            }
            SectionTitle("FONTE")
            Text("Domínio público • Transcrição Wikisource (CC BY-SA) dos colaboradores. Ver DATA_SOURCES.md.", fontSize = 12.sp, color = Color(0xFF5a544a))
            Spacer(Modifier.height(24.dp))
        }
    }
}
