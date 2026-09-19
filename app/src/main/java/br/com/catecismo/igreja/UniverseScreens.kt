package br.com.catecismo.igreja

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.catecismo.igreja.db.ChapterProgressEntity
import br.com.catecismo.igreja.db.WorkEntity

data class CharacterCard(val id: String, val name: String, val work: String, val summary: String, val story: String, val image: Int?, val workId: String)

private val topics = listOf(
    CharacterCard("credo", "Credo", "A profissão da fé", "As palavras que reúnem a comunidade cristã em uma mesma esperança.", "Percorra os fundamentos da fé cristã com linguagem clara, perguntas para reflexão e referências para aprofundar.", null, "credo-em-caminho"),
    CharacterCard("sacramentos", "Sacramentos", "A vida da graça", "Sinais celebrados que tornam visível a proximidade de Deus.", "Conheça o sentido dos sacramentos e descubra como a celebração continua em escolhas de cuidado, serviço e comunhão.", null, "sinais-da-graca"),
    CharacterCard("oracao", "Oração", "O encontro com Deus", "Silêncio, gratidão e pedido como caminhos de presença.", "Uma escola prática para criar momentos de oração e escuta no ritmo possível de cada dia.", null, "escola-da-oracao"),
    CharacterCard("igreja", "Igreja", "Povo em caminho", "Uma comunidade diversa, reunida para celebrar e servir.", "Reflita sobre pertença, dons, missão e cuidado com os mais frágeis.", null, "a-igreja-viva"),
    CharacterCard("maria", "Maria", "Um sim de confiança", "Disponibilidade, coragem e cuidado com a vida.", "Uma meditação sobre Maria como mulher de fé e presença fiel no caminho de Cristo.", null, "maria-e-o-sim")
)

@Composable
fun UniverseScreen(onCharacter: (CharacterCard) -> Unit) {
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        androidx.compose.foundation.Image(painterResource(R.drawable.bg_church_community), "Comunidade reunida", Modifier.fillMaxWidth().height(190.dp), contentScale = androidx.compose.ui.layout.ContentScale.Crop)
        Column(Modifier.padding(22.dp)) {
            Text("EXPLORE O CATECISMO", color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            Text("Temas para a caminhada", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green)
            Text("Descubra, aprenda e aprofunde a fé com guias curtos e autorais.", color = Color(0xFF5a544a), modifier = Modifier.padding(top = 5.dp))
            Spacer(Modifier.height(18.dp))
            LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp), contentPadding = PaddingValues(bottom = 8.dp)) { items(topics) { topic -> TopicTile(topic) { onCharacter(topic) } } }
            SectionTitle("TEMAS EM DESTAQUE")
            topics.forEach { topic -> TopicRow(topic) { onCharacter(topic) } }
        }
    }
}

@Composable private fun TopicTile(topic: CharacterCard, open: () -> Unit) {
    Column(Modifier.width(124.dp).clickable { open() }) {
        TopicIcon(topic, Modifier.size(124.dp).clip(CircleShape))
        Text(topic.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 16.sp, modifier = Modifier.padding(top = 7.dp))
        Text(topic.work, fontSize = 11.sp, color = Color(0xFF5a544a), maxLines = 1)
    }
}

@Composable private fun TopicRow(topic: CharacterCard, open: () -> Unit) {
    Row(Modifier.fillMaxWidth().clickable { open() }.padding(vertical = 9.dp), verticalAlignment = Alignment.CenterVertically) {
        TopicIcon(topic, Modifier.size(60.dp).clip(CircleShape))
        Spacer(Modifier.width(13.dp))
        Column(Modifier.weight(1f)) { Text(topic.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 18.sp); Text(topic.summary, fontSize = 13.sp, maxLines = 2, color = Color(0xFF5a544a)) }
    }
}

@Composable private fun TopicIcon(topic: CharacterCard, modifier: Modifier) {
    Surface(modifier, shape = CircleShape, color = when (topic.id) { "oracao" -> Color(0xFFE5C982); "igreja" -> Color(0xFF8D2430); else -> green }) { Box(contentAlignment = Alignment.Center) { Text(topic.name.take(1), color = Color(0xFFF7F2E8), fontFamily = FontFamily.Serif, fontSize = 28.sp, fontWeight = FontWeight.Bold) } }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CharacterDetailScreen(c: CharacterCard, isFav: Boolean, onToggle: () -> Unit, onBack: () -> Unit, openWork: (String) -> Unit) {
    Scaffold(topBar = { TopAppBar(title = { Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, "Voltar") } }, actions = { IconButton(onToggle) { Icon(if (isFav) Icons.Filled.Star else Icons.Filled.StarBorder, "Favorito", tint = if (isFav) gold else Color.Unspecified) } }) }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(22.dp)) {
            TopicIcon(c, Modifier.fillMaxWidth().height(180.dp).clip(RoundedCornerShape(22.dp)))
            Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 32.sp, color = green, modifier = Modifier.padding(top = 18.dp))
            Text(c.work.uppercase(), color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            SectionTitle("SOBRE ESTE TEMA"); Text(c.summary, fontFamily = FontFamily.Serif, fontSize = 18.sp, lineHeight = 26.sp)
            SectionTitle("REFLEXÃO"); Text(c.story, fontFamily = FontFamily.Serif, fontSize = 17.sp, lineHeight = 25.sp)
            Spacer(Modifier.height(14.dp)); OutlinedButton({ openWork(c.workId) }, Modifier.fillMaxWidth()) { Text("ABRIR GUIA") }
        }
    }
}

@Composable
fun MyLibraryScreen(works: List<WorkEntity>, progress: List<ChapterProgressEntity>, favorites: List<String>, quotes: List<Quote>, openWork: (WorkEntity) -> Unit, onUniverse: () -> Unit) {
    val activeIds = progress.map { it.workId }.toSet()
    val completed = works.filter { work -> progress.count { it.workId == work.id && it.progress >= 100 } >= work.chapterCount }.map { it.id }.toSet()
    val active = works.filter { it.id in activeIds && it.id !in completed }; val fav = works.filter { it.id in favorites }
    val readingPercent = if (progress.isEmpty()) 0 else progress.map { it.progress }.average().toInt()
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(22.dp)) {
        Text("Minha biblioteca", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 30.sp, color = green)
        Text("Seu percurso pelos temas, perguntas e práticas da fé.", color = Color(0xFF5a544a)); Spacer(Modifier.height(18.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) { MetricCard("${completed.size}", "concluídos", Modifier.weight(1f)); MetricCard("${active.size}", "em andamento", Modifier.weight(1f)); MetricCard("$readingPercent%", "progresso", Modifier.weight(1f)) }
        SectionTitle("CONTINUAR ESTUDANDO")
        if (active.isEmpty()) Text("Você ainda não iniciou um guia.", color = Color(0xFF5a544a)) else active.take(3).forEach { w -> LibraryWorkRow(w, progress.filter { it.workId == w.id }.maxOfOrNull { it.progress } ?: 0, openWork) }
        SectionTitle("GUIAS FAVORITOS")
        if (fav.isEmpty()) Text("Seus favoritos aparecerão aqui.", color = Color(0xFF5a544a)) else fav.forEach { w -> LibraryWorkRow(w, 0, openWork) }
        SectionTitle("EXPLORAR TEMAS"); OutlinedButton(onUniverse, Modifier.fillMaxWidth()) { Text("Conhecer os temas da fé") }
        SectionTitle("CITAÇÕES SALVAS")
        if (quotes.isEmpty()) Text("Toque e segure um parágrafo para guardar uma citação.", color = Color(0xFF5a544a)) else quotes.take(3).forEach { q -> Text("“${q.text}”", fontFamily = FontFamily.Serif, fontSize = 15.sp, modifier = Modifier.padding(vertical = 5.dp)); Text(q.workTitle, color = gold, fontSize = 12.sp) }
    }
}

@Composable private fun MetricCard(value: String, label: String, modifier: Modifier) { Surface(modifier, RoundedCornerShape(16.dp), color = paper) { Column(Modifier.padding(12.dp), horizontalAlignment = Alignment.CenterHorizontally) { Text(value, fontSize = 24.sp, fontWeight = FontWeight.Bold, color = green); Text(label, fontSize = 11.sp) } } }
@Composable private fun LibraryWorkRow(w: WorkEntity, pct: Int, open: (WorkEntity) -> Unit) { Row(Modifier.fillMaxWidth().clickable { open(w) }.padding(vertical = 7.dp), verticalAlignment = Alignment.CenterVertically) { Cover(w, Modifier.size(44.dp, 62.dp)); Spacer(Modifier.width(12.dp)); Column(Modifier.weight(1f)) { Text(w.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 17.sp); Text(w.category, fontSize = 12.sp); LinearProgressIndicator({ pct / 100f }, Modifier.fillMaxWidth().padding(top = 5.dp)) } } }
