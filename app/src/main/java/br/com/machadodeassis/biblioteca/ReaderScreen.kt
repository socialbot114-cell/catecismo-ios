package br.com.machadodeassis.biblioteca

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material.icons.filled.VolumeUp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.machadodeassis.biblioteca.db.ChapterEntity
import br.com.machadodeassis.biblioteca.db.WorkEntity
import br.com.machadodeassis.biblioteca.tts.TtsPlaybackService
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

private const val PARAGRAPHS_PER_PAGE = 4

@OptIn(ExperimentalMaterial3Api::class, ExperimentalFoundationApi::class)
@Composable
fun ReaderScreen(
    work: WorkEntity, chapters: List<ChapterEntity>, chapter: ChapterEntity, paragraphs: List<String>,
    progress: Int, fontSize: Float, setFontSize: (Float) -> Unit,
    onToggleFav: () -> Unit, isFav: Boolean, onQuote: (Quote) -> Unit,
    onBack: () -> Unit, onChooseChapter: (ChapterEntity) -> Unit, onProgress: (Int) -> Unit,
    onReadingTime: (Long) -> Unit
) {
    val context = LocalContext.current
    var showToc by remember { mutableStateOf(false) }
    var size by remember(chapter.id) { mutableFloatStateOf(fontSize) }
    val pages = remember(paragraphs) { paragraphs.chunked(PARAGRAPHS_PER_PAGE) }
    val pager = rememberPagerState(pageCount = { pages.size.coerceAtLeast(1) })
    val scope = rememberCoroutineScope()
    var lastReported by remember(chapter.id) { mutableIntStateOf(-1) }

    LaunchedEffect(chapter.id, pages.size) {
        if (pages.isNotEmpty() && progress in 1..99) {
            pager.scrollToPage(((progress * pages.size) / 100).coerceIn(0, pages.lastIndex))
        }
    }
    LaunchedEffect(pager.currentPage, pages.size) {
        if (pages.isNotEmpty()) {
            val pct = ((pager.currentPage + 1) * 100 / pages.size).coerceIn(0, 100)
            if (pct != lastReported) { lastReported = pct; onProgress(pct) }
        }
    }
    LaunchedEffect(chapter.id) {
        while (true) { delay(15_000); onReadingTime(15_000) }
    }

    fun goToChapter(next: ChapterEntity?) {
        if (next != null) { onProgress(((pager.currentPage + 1) * 100 / pages.size.coerceAtLeast(1)).coerceIn(0, 100)); onChooseChapter(next) }
    }

    Scaffold(topBar = {
        TopAppBar(
            title = { Column { Text(work.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 19.sp, maxLines = 1); Text(chapter.title, fontSize = 12.sp, color = gold) } },
            navigationIcon = { IconButton(onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Voltar") } },
            actions = {
                IconButton({
                    if (Build.VERSION.SDK_INT >= 33 && context is Activity && context.checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) context.requestPermissions(arrayOf(Manifest.permission.POST_NOTIFICATIONS), 700)
                    context.startForegroundService(Intent(context, TtsPlaybackService::class.java).apply { action = TtsPlaybackService.ACTION_PLAY; putExtra(TtsPlaybackService.EXTRA_CHAPTER_ID, chapter.id) })
                }) { Icon(Icons.Filled.VolumeUp, "Ouvir capítulo") }
                IconButton(onToggleFav) { Icon(if (isFav) Icons.Filled.Star else Icons.Filled.StarBorder, if (isFav) "Remover favorito" else "Adicionar favorito", tint = if (isFav) gold else Color.Unspecified) }
                IconButton({ showToc = true }) { Icon(Icons.Filled.Menu, "Capítulos") }
            }
        )
    }, bottomBar = {
        Surface(tonalElevation = 3.dp) {
            Column(Modifier.padding(horizontal = 12.dp, vertical = 6.dp)) {
                LinearProgressIndicator(progress = { if (pages.isEmpty()) 0f else (pager.currentPage + 1).toFloat() / pages.size }, modifier = Modifier.fillMaxWidth())
                Row(verticalAlignment = Alignment.CenterVertically, horizontalArrangement = Arrangement.SpaceBetween, modifier = Modifier.fillMaxWidth()) {
                    Text(if (pages.isEmpty()) "0 / 0" else "Página ${pager.currentPage + 1} de ${pages.size}", fontSize = 12.sp)
                    Row {
                        TextButton({ if (pager.currentPage > 0) scope.launch { pager.animateScrollToPage(pager.currentPage - 1) } }) { Text("‹") }
                        TextButton({ if (pager.currentPage < pages.lastIndex) scope.launch { pager.animateScrollToPage(pager.currentPage + 1) } }) { Text("›") }
                        IconButton({ if (size > 15f) { size -= 1f; setFontSize(size) } }) { Text("A-", fontWeight = FontWeight.Bold) }
                        IconButton({ if (size < 28f) { size += 1f; setFontSize(size) } }) { Text("A+", fontWeight = FontWeight.Bold) }
                    }
                }
            }
        }
    }) { pad ->
        if (pages.isEmpty()) {
            Box(Modifier.padding(pad).fillMaxSize(), contentAlignment = Alignment.Center) { Text("Texto indisponível.") }
        } else {
            HorizontalPager(state = pager, modifier = Modifier.padding(pad).fillMaxSize(), contentPadding = PaddingValues(horizontal = 12.dp), pageSpacing = 12.dp) { page ->
                LazyColumn(Modifier.fillMaxSize(), contentPadding = PaddingValues(horizontal = 10.dp, vertical = 18.dp)) {
                    item { Text(chapter.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = (size * 1.15f).sp, modifier = Modifier.padding(bottom = 12.dp)) }
                    items(pages[page], key = { it.hashCode() }) { text ->
                        val index = paragraphs.indexOf(text)
                        Text(text, fontFamily = FontFamily.Serif, fontSize = size.sp, lineHeight = (size * 1.55f).sp, modifier = Modifier.fillMaxWidth().padding(vertical = 9.dp).combinedClickable(onClick = {}, onLongClick = { onQuote(Quote("${chapter.id}:$index", work.id, work.title, chapter.title, index, text)) }))
                    }
                    item { Row(Modifier.fillMaxWidth().padding(top = 14.dp), horizontalArrangement = Arrangement.SpaceBetween) { TextButton({ goToChapter(prevChapter(chapters, chapter)) }) { Text("‹ Capítulo anterior") }; TextButton({ goToChapter(nextChapter(chapters, chapter)) }) { Text("Próximo capítulo ›") } } }
                }
            }
        }
    }

    if (showToc) AlertDialog(onDismissRequest = { showToc = false }, title = { Text("Capítulos • ${work.title}") }, text = { LazyColumn(Modifier.heightIn(max = 420.dp)) { items(chapters) { c -> Text(c.title, fontFamily = FontFamily.Serif, modifier = Modifier.fillMaxWidth().clickable { showToc = false; onChooseChapter(c) }.padding(10.dp)) } } }, confirmButton = { TextButton({ showToc = false }) { Text("Fechar") } })
}

internal fun prevChapter(chapters: List<ChapterEntity>, chapter: ChapterEntity): ChapterEntity? = chapters.firstOrNull { it.order == chapter.order - 1 }
internal fun nextChapter(chapters: List<ChapterEntity>, chapter: ChapterEntity): ChapterEntity? = chapters.firstOrNull { it.order == chapter.order + 1 }
