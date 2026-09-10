package br.com.machadodeassis.biblioteca

import androidx.compose.foundation.Image
import androidx.compose.foundation.clickable
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Star
import androidx.compose.material.icons.filled.StarBorder
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.machadodeassis.biblioteca.db.ChapterProgressEntity
import br.com.machadodeassis.biblioteca.db.WorkEntity

data class CharacterCard(val id: String, val name: String, val work: String, val summary: String, val story: String, val image: Int?, val workId: String)
data class TimelineEvent(val year: Int, val title: String, val description: String, val kind: String)

private val characters = listOf(
    CharacterCard("capitu", "Capitu", "Dom Casmurro", "Olhos de ressaca, inteligência e uma presença impossível de reduzir à dúvida de Bentinho.", "Capitu cresce em uma sociedade que espera silêncio das mulheres. Sua história é também a disputa entre memória, ciúme e autonomia.", R.drawable.avatar_capitu, "dom"),
    CharacterCard("bentinho", "Bentinho", "Dom Casmurro", "O narrador que tenta reconstruir a própria vida para convencer o leitor e a si mesmo.", "Bentinho abandona o seminário, casa-se com Capitu e transforma a memória em tribunal. O que ele conta é inseparável do que escolhe omitir.", null, "dom"),
    CharacterCard("brascubas", "Brás Cubas", "Memórias Póstumas", "Um defunto-autor que narra a vida com humor, vaidade e uma liberdade que só a morte permite.", "Depois de morto, Brás Cubas revisita seus amores, ambições e fracassos. Sua trajetória desmonta a ideia de uma vida exemplar.", R.drawable.avatar_bras_cubas, "brascubas"),
    CharacterCard("rubiao", "Rubião", "Quincas Borba", "Professor que herda fortuna e filosofia, mas perde o chão entre o Humanitismo e a sociedade.", "Rubião sai de Barbacena rumo ao Rio de Janeiro. A riqueza abre portas, enquanto a ingenuidade o torna presa de relações interessadas.", R.drawable.avatar_rubiao, "quincas"),
    CharacterCard("bacamarte", "Simão Bacamarte", "O Alienista", "A ciência transformada em autoridade absoluta numa sátira sobre normalidade e poder.", "Bacamarte funda a Casa Verde em Itaguaí e passa a classificar a população. Sua busca pela razão revela a instabilidade de todo julgamento.", null, "alienista"),
    CharacterCard("aires", "Conselheiro Aires", "Memorial de Aires", "Diplomata aposentado que observa o mundo com ironia, delicadeza e distância.", "Aires registra a passagem do tempo e os afetos alheios em forma de diário. Sua aparente neutralidade nunca elimina a compaixão.", null, "memorial")
)

private val timeline = listOf(
    TimelineEvent(1839, "Nascimento", "Joaquim Maria Machado de Assis nasce no Rio de Janeiro, no Morro do Livramento.", "VIDA"),
    TimelineEvent(1855, "Primeiras publicações", "Ainda jovem, inicia colaboração na imprensa e se aproxima do ambiente literário da Corte.", "VIDA"),
    TimelineEvent(1864, "Crisálidas", "Publica seu primeiro livro de poesias, consolidando sua presença literária.", "OBRA"),
    TimelineEvent(1869, "Casamento com Carolina", "Casa-se com Carolina Augusta Xavier de Novais, sua companheira por toda a vida.", "VIDA"),
    TimelineEvent(1872, "Ressurreição", "Publica seu primeiro romance e começa a construir uma obra de observação psicológica.", "OBRA"),
    TimelineEvent(1881, "Memórias Póstumas", "A publicação do romance marca uma ruptura decisiva e inaugura uma nova fase estética.", "OBRA"),
    TimelineEvent(1891, "Quincas Borba", "A sátira do Humanitismo amplia o universo do Realismo machadiano.", "OBRA"),
    TimelineEvent(1897, "Academia Brasileira de Letras", "Machado participa da fundação da Academia e torna-se seu primeiro presidente.", "BRASIL"),
    TimelineEvent(1899, "Dom Casmurro", "Publica um dos romances mais discutidos da língua portuguesa.", "OBRA"),
    TimelineEvent(1908, "Memorial de Aires e morte", "Publica seu último romance e morre no Rio de Janeiro em 29 de setembro.", "VIDA")
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun UniverseScreen(onCharacter: (CharacterCard) -> Unit) {
    var tab by remember { mutableIntStateOf(0) }
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        Image(painterResource(R.drawable.hero_universo), "Universo Machado", Modifier.fillMaxWidth().height(190.dp), contentScale = ContentScale.Crop)
        Column(Modifier.padding(22.dp)) {
            Text("UNIVERSO MACHADO", color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            Text("Vidas, vozes e destinos", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green)
            Text("Entre nos livros por quem os habita e pelo tempo que formou seu autor.", color = Color(0xFF5a544a), modifier = Modifier.padding(top = 5.dp))
            Spacer(Modifier.height(18.dp))
            PrimaryTabRow(selectedTabIndex = tab) {
                Tab(tab == 0, { tab = 0 }, text = { Text("PERSONAGENS") })
                Tab(tab == 1, { tab = 1 }, text = { Text("LINHA DO TEMPO") })
            }
            Spacer(Modifier.height(14.dp))
            if (tab == 0) {
                LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp), contentPadding = PaddingValues(bottom = 8.dp)) {
                    items(characters) { c -> CharacterTile(c, { onCharacter(c) }) }
                }
                Spacer(Modifier.height(14.dp))
                Text("PERSONAGENS EM DESTAQUE", color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
                characters.forEach { c -> CharacterRow(c, { onCharacter(c) }) }
            } else {
                timeline.forEach { event -> TimelineRow(event) }
            }
        }
    }
}

@Composable private fun CharacterTile(c: CharacterCard, open: () -> Unit) {
    Column(Modifier.width(124.dp).clickable { open() }) {
        CharacterImage(c, Modifier.size(124.dp).clip(CircleShape))
        Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 16.sp, modifier = Modifier.padding(top = 7.dp))
        Text(c.work, fontSize = 11.sp, color = Color(0xFF5a544a), maxLines = 1)
    }
}

@Composable private fun CharacterRow(c: CharacterCard, open: () -> Unit) {
    Row(Modifier.fillMaxWidth().clickable { open() }.padding(vertical = 9.dp), verticalAlignment = Alignment.CenterVertically) {
        CharacterImage(c, Modifier.size(60.dp).clip(CircleShape))
        Spacer(Modifier.width(13.dp))
        Column(Modifier.weight(1f)) { Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 18.sp); Text(c.summary, fontSize = 13.sp, maxLines = 2, color = Color(0xFF5a544a)) }
    }
}

@Composable private fun CharacterImage(c: CharacterCard, modifier: Modifier) {
    if (c.image != null) Image(painterResource(c.image), c.name, modifier, contentScale = ContentScale.Crop)
    else Surface(modifier, shape = CircleShape, color = green) { Box(contentAlignment = Alignment.Center) { Text(c.name.take(1), color = Color(0xFFF7F2E8), fontFamily = FontFamily.Serif, fontSize = 28.sp) } }
}

@Composable private fun TimelineRow(event: TimelineEvent) {
    Row(Modifier.fillMaxWidth().padding(vertical = 7.dp)) {
        Column(horizontalAlignment = Alignment.CenterHorizontally, modifier = Modifier.width(58.dp)) { Text(event.year.toString(), color = gold, fontWeight = FontWeight.Bold); Box(Modifier.padding(top = 5.dp).size(9.dp).clip(CircleShape).background(green)) }
        Column(Modifier.padding(start = 12.dp, bottom = 8.dp)) { Text(event.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 18.sp); Text(event.description, fontSize = 14.sp, lineHeight = 20.sp, color = Color(0xFF5a544a)); Text(event.kind, fontSize = 10.sp, color = gold, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 4.dp)) }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CharacterDetailScreen(c: CharacterCard, isFav: Boolean, onToggle: () -> Unit, onBack: () -> Unit, openWork: (String) -> Unit) {
    Scaffold(topBar = { TopAppBar(title = { Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onBack) { Icon(Icons.Filled.ArrowBack, "Voltar") } }, actions = { IconButton(onToggle) { Icon(if (isFav) Icons.Filled.Star else Icons.Filled.StarBorder, "Favorito", tint = if (isFav) gold else Color.Unspecified) } }) }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(22.dp)) {
            CharacterImage(c, Modifier.fillMaxWidth().height(260.dp).clip(RoundedCornerShape(22.dp)))
            Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 32.sp, color = green, modifier = Modifier.padding(top = 18.dp))
            Text(c.work.uppercase(), color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            SectionTitle("RESUMO")
            Text(c.summary, fontFamily = FontFamily.Serif, fontSize = 18.sp, lineHeight = 26.sp)
            SectionTitle("HISTÓRIA COMPLETA")
            Text("Contém revelações da obra", fontSize = 11.sp, color = Color(0xFF8b5e3c), fontWeight = FontWeight.Bold)
            Text(c.story, fontFamily = FontFamily.Serif, fontSize = 17.sp, lineHeight = 25.sp, modifier = Modifier.padding(top = 5.dp))
            Spacer(Modifier.height(14.dp))
            OutlinedButton({ openWork(c.workId) }, Modifier.fillMaxWidth()) { Text("LER OBRA RELACIONADA") }
        }
    }
}

@Composable
fun MyLibraryScreen(works: List<WorkEntity>, progress: List<ChapterProgressEntity>, favorites: List<String>, quotes: List<Quote>, openWork: (WorkEntity) -> Unit, onUniverse: () -> Unit) {
    val activeIds = progress.map { it.workId }.toSet()
    val completed = works.filter { work -> progress.count { it.workId == work.id && it.progress >= 100 } >= work.chapterCount }.map { it.id }.toSet()
    val active = works.filter { it.id in activeIds && it.id !in completed }
    val fav = works.filter { it.id in favorites }
    val readingPercent = if (progress.isEmpty()) 0 else progress.map { it.progress }.average().toInt()
    val readingMs = progress.sumOf { it.readingTimeMs }
    val listeningMs = progress.sumOf { it.listeningTimeMs }
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(22.dp)) {
        Text("Minha biblioteca", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 30.sp, color = green)
        Text("Seu percurso pelos livros e pelas vozes de Machado.", color = Color(0xFF5a544a))
        Spacer(Modifier.height(18.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) { MetricCard("${completed.size}", "concluídas", Modifier.weight(1f)); MetricCard("${active.size}", "em andamento", Modifier.weight(1f)); MetricCard("$readingPercent%", "progresso", Modifier.weight(1f)) }
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth().padding(top = 8.dp)) { MetricCard(formatDuration(readingMs), "lendo", Modifier.weight(1f)); MetricCard(formatDuration(listeningMs), "ouvindo", Modifier.weight(1f)) }
        SectionTitle("CONTINUAR LENDO")
        if (active.isEmpty()) Text("Você ainda não iniciou uma obra.", color = Color(0xFF5a544a)) else active.take(3).forEach { w -> LibraryWorkRow(w, progress.filter { it.workId == w.id }.maxOfOrNull { it.progress } ?: 0, openWork) }
        SectionTitle("OBRAS FAVORITAS")
        if (fav.isEmpty()) Text("Seus favoritos aparecerão aqui.", color = Color(0xFF5a544a)) else fav.forEach { w -> LibraryWorkRow(w, 0, openWork) }
        SectionTitle("UNIVERSO FAVORITO")
        OutlinedButton(onUniverse, Modifier.fillMaxWidth()) { Text("Explorar personagens e relações") }
        SectionTitle("CITAÇÕES SALVAS")
        if (quotes.isEmpty()) Text("Toque e segure um parágrafo para guardar uma citação.", color = Color(0xFF5a544a)) else quotes.take(3).forEach { q -> Text("“${q.text}”", fontFamily = FontFamily.Serif, fontSize = 15.sp, modifier = Modifier.padding(vertical = 5.dp)); Text(q.workTitle, color = gold, fontSize = 12.sp) }
    }
}

@Composable private fun MetricCard(value: String, label: String, modifier: Modifier) { Surface(modifier, RoundedCornerShape(16.dp), color = paper) { Column(Modifier.padding(12.dp), horizontalAlignment = Alignment.CenterHorizontally) { Text(value, fontSize = 24.sp, fontWeight = FontWeight.Bold, color = green); Text(label, fontSize = 11.sp) } } }
@Composable private fun LibraryWorkRow(w: WorkEntity, pct: Int, open: (WorkEntity) -> Unit) { Row(Modifier.fillMaxWidth().clickable { open(w) }.padding(vertical = 7.dp), verticalAlignment = Alignment.CenterVertically) { Cover(w, Modifier.size(44.dp, 62.dp)); Spacer(Modifier.width(12.dp)); Column(Modifier.weight(1f)) { Text(w.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 17.sp); Text("${w.year} • ${w.category}", fontSize = 12.sp); LinearProgressIndicator(pct / 100f, Modifier.fillMaxWidth().padding(top = 5.dp)) } } }

private fun formatDuration(ms: Long): String {
    val minutes = ms / 60_000
    return if (minutes < 60) "${minutes}min" else "${minutes / 60}h ${minutes % 60}min"
}
