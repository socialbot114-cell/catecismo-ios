package br.com.machadodeassis.biblioteca

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.pager.HorizontalPager
import androidx.compose.foundation.pager.rememberPagerState
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.machadodeassis.biblioteca.data.LibraryRepository
import br.com.machadodeassis.biblioteca.db.SearchHit
import br.com.machadodeassis.biblioteca.db.WorkEntity
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

@Composable
fun HomeScreen(works: List<WorkEntity>, open: (WorkEntity) -> Unit, query: String, setQuery: (String) -> Unit, onSearch: () -> Unit, onUniverse: () -> Unit, onMyLibrary: () -> Unit) {
    Column(Modifier.fillMaxSize().padding(horizontal = 22.dp).verticalScroll(rememberScrollState())) {
        Spacer(Modifier.height(22.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            androidx.compose.foundation.Image(painterResource(R.drawable.logo_machado), "Machado de Assis", Modifier.size(48.dp), contentScale = ContentScale.Crop)
            Spacer(Modifier.width(12.dp))
            Column { Text("Machado de Assis", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green); Text("Biblioteca, voz e universo", fontSize = 13.sp, color = Color(0xFF5a544a)) }
        }
        Spacer(Modifier.height(16.dp))
        HeroCarousel(works, open)
        Spacer(Modifier.height(18.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(10.dp), modifier = Modifier.fillMaxWidth()) {
            HomeAction("Universo", "Personagens e histórias", onUniverse, Modifier.weight(1f))
            HomeAction("Minha biblioteca", "Seu percurso", onMyLibrary, Modifier.weight(1f))
        }
        Spacer(Modifier.height(20.dp))
        OutlinedTextField(query, setQuery, Modifier.fillMaxWidth(), placeholder = { Text("Buscar obra, personagem ou trecho…") }, leadingIcon = { Icon(Icons.Filled.Search, null) }, singleLine = true, trailingIcon = {
            IconButton(onSearch) { Icon(Icons.AutoMirrored.Filled.ArrowForward, "Ir para busca") }
        }, shape = RoundedCornerShape(16.dp))
        Spacer(Modifier.height(20.dp))
        Text("OBRAS INTEGRAIS", color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
        Text("${works.size} obras • leitura offline", fontSize = 13.sp)
        Spacer(Modifier.height(6.dp))
        works.forEach { w ->
            Surface(Modifier.fillMaxWidth().padding(vertical = 5.dp).clickable { open(w) }, RoundedCornerShape(16.dp), color = paper) {
                Row(Modifier.padding(14.dp), verticalAlignment = Alignment.CenterVertically) {
                    Cover(w, Modifier.size(54.dp, 78.dp))
                    Spacer(Modifier.width(14.dp))
                    Column(Modifier.weight(1f)) {
                        Text(w.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 19.sp)
                        Text("${w.year} • ${w.category} • ${w.chapterCount} capítulos")
                        Text("${w.wordCount / 1000}k palavras", fontSize = 12.sp, color = Color(0xFF5a544a))
                    }
                }
            }
        }
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun HeroCarousel(works: List<WorkEntity>, open: (WorkEntity) -> Unit) {
    val heroes = listOf(
        Triple(R.drawable.hero_dom, "dom", "A dúvida que nunca termina"),
        Triple(R.drawable.hero_quincas, "quincas", "A filosofia dos vencedores"),
        Triple(R.drawable.hero_bras_cubas, "brascubas", "Memórias de além-túmulo"),
        Triple(R.drawable.hero_literatura, "", "Entre na literatura de Machado")
    )
    val pager = rememberPagerState(pageCount = { heroes.size })
    Column {
        HorizontalPager(state = pager, pageSpacing = 12.dp, contentPadding = PaddingValues(end = 28.dp), modifier = Modifier.fillMaxWidth()) { page ->
            val hero = heroes[page]
            Card(Modifier.fillMaxWidth().aspectRatio(16f / 9f).clickable { works.firstOrNull { it.id == hero.second }?.let(open) }, shape = RoundedCornerShape(22.dp)) {
                androidx.compose.foundation.Image(painterResource(hero.first), hero.third, Modifier.fillMaxSize(), contentScale = ContentScale.Crop)
            }
        }
        Spacer(Modifier.height(8.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(5.dp), modifier = Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            repeat(heroes.size) { i -> Box(Modifier.size(if (pager.currentPage == i) 20.dp else 6.dp, 6.dp).background(if (pager.currentPage == i) gold else Color(0xFFD0C6B5), RoundedCornerShape(3.dp))) }
        }
    }
}

@Composable
private fun HomeAction(title: String, subtitle: String, action: () -> Unit, modifier: Modifier) {
    Surface(modifier.clickable { action() }, RoundedCornerShape(16.dp), color = paper) {
        Column(Modifier.padding(14.dp)) { Text(title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 17.sp, color = green); Text(subtitle, fontSize = 12.sp, color = Color(0xFF5a544a)) }
    }
}

@Composable
fun LibraryScreen(works: List<WorkEntity>, query: String, setQuery: (String) -> Unit, open: (WorkEntity) -> Unit) {
    var category by remember { mutableStateOf("Todos") }
    val cats = listOf("Todos") + works.map { it.category }.distinct()
    val filtered = works.filter {
        (category == "Todos" || it.category == category) &&
            (query.isBlank() || it.title.contains(query, true) || it.description.contains(query, true) || it.characters.lowercase().contains(query.lowercase()))
    }
    Column(Modifier.fillMaxSize().padding(horizontal = 22.dp)) {
        Spacer(Modifier.height(20.dp))
        Text("Biblioteca", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 28.sp)
        OutlinedTextField(query, setQuery, Modifier.fillMaxWidth().padding(top = 10.dp), placeholder = { Text("Filtrar obras") }, singleLine = true, shape = RoundedCornerShape(14.dp))
        Spacer(Modifier.height(8.dp))
        LazyRow(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
            items(cats) { c -> FilterChip(selected = category == c, onClick = { category = c }, label = { Text(c) }) }
        }
        LazyColumn(verticalArrangement = Arrangement.spacedBy(10.dp), contentPadding = PaddingValues(bottom = 24.dp, top = 6.dp)) {
            items(filtered) { w ->
                Surface(Modifier.fillMaxWidth().clickable { open(w) }, RoundedCornerShape(16.dp), color = paper) {
                    Row(Modifier.padding(12.dp), verticalAlignment = Alignment.CenterVertically) {
                        Cover(w, Modifier.size(50.dp, 72.dp))
                        Spacer(Modifier.width(12.dp))
                        Column { Text(w.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 18.sp); Text("${w.year} • ${w.category}"); Text(w.description, maxLines = 2, fontSize = 13.sp) }
                    }
                }
            }
        }
    }
}

@Composable
fun SearchScreen(repo: LibraryRepository, open: (WorkEntity) -> Unit) {
    var q by remember { mutableStateOf("") }
    var hits by remember { mutableStateOf<List<SearchHit>>(emptyList()) }
    var searching by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()
    LaunchedEffect(q) {
        val term = q.trim()
        if (term.length >= 3) {
            searching = true
            delay(300)
            hits = repo.search(term)
            searching = false
        } else {
            hits = emptyList()
            searching = false
        }
    }
    Column(Modifier.fillMaxSize().padding(horizontal = 22.dp)) {
        Spacer(Modifier.height(20.dp))
        Text("Busca no texto integral", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 26.sp)
        OutlinedTextField(q, { q = it }, Modifier.fillMaxWidth().padding(top = 10.dp), placeholder = { Text("Buscar palavra ou trecho…") }, singleLine = true, shape = RoundedCornerShape(14.dp))
        Spacer(Modifier.height(8.dp))
        when {
            q.trim().length < 3 -> Text("Digite ao menos 3 letras para pesquisar em toda a obra.", color = Color(0xFF5a544a))
            searching -> LinearProgressIndicator(Modifier.fillMaxWidth())
            hits.isEmpty() -> Text("Nenhum trecho encontrado.")
            else -> {
                Text("${hits.size} ocorrências")
                LazyColumn(verticalArrangement = Arrangement.spacedBy(8.dp), contentPadding = PaddingValues(bottom = 24.dp)) {
                    items(hits) { h ->
                        Surface(Modifier.fillMaxWidth().clickable { scope.launch { repo.work(h.workId)?.let(open) } }, RoundedCornerShape(12.dp), color = paper) {
                            Column(Modifier.padding(12.dp)) {
                                Text(h.workTitle, fontWeight = FontWeight.Bold)
                                Text(h.chapterTitle, color = green, fontSize = 13.sp)
                                Text(h.snippet, fontSize = 14.sp, maxLines = 3)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FavoritesScreen(works: List<WorkEntity>, favorites: List<String>, open: (WorkEntity) -> Unit) {
    val fav = works.filter { it.id in favorites }
    Column(Modifier.fillMaxSize().padding(horizontal = 22.dp)) {
        Spacer(Modifier.height(20.dp))
        Text("Favoritos", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 28.sp)
        if (fav.isEmpty()) Text("Marque obras como favoritas na leitura.", color = Color(0xFF5a544a))
        LazyColumn { items(fav) { w -> Surface(Modifier.fillMaxWidth().padding(vertical = 4.dp).clickable { open(w) }, RoundedCornerShape(14.dp), color = paper) { Row(Modifier.padding(12.dp)) { Cover(w, Modifier.size(46.dp, 66.dp)); Spacer(Modifier.width(12.dp)); Column { Text(w.title, fontWeight = FontWeight.Bold, fontSize = 18.sp); Text(w.category) } } } } }
    }
}

@Composable
fun ProfileScreen(quotes: List<Quote>, favoriteCount: Int, theme: String, setTheme: (String) -> Unit, onRemoveQuote: (String) -> Unit) {
    Column(Modifier.fillMaxSize().padding(22.dp).verticalScroll(rememberScrollState())) {
        Spacer(Modifier.height(20.dp))
        Text("Seu perfil", fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 28.sp)
        Spacer(Modifier.height(16.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(20.dp)) { StatCard("$favoriteCount", "favoritos"); StatCard("${quotes.size}", "citações"); StatCard("3", "temas") }
        Spacer(Modifier.height(24.dp))
        Text("Tema do leitor", fontWeight = FontWeight.Bold)
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
            listOf("Claro", "Sépia", "Escuro").forEach { t -> FilterChip(selected = theme == t, onClick = { setTheme(t) }, label = { Text(t) }) }
        }
        Spacer(Modifier.height(24.dp))
        Text("Citações", fontWeight = FontWeight.Bold)
        if (quotes.isEmpty()) {
            Text("Toque e segure um parágrafo no leitor para salvar uma citação.", fontSize = 13.sp, color = Color(0xFF5a544a))
        } else {
            quotes.forEach { quote ->
                Surface(Modifier.fillMaxWidth().padding(vertical = 5.dp), RoundedCornerShape(12.dp), color = paper) {
                    Column(Modifier.padding(12.dp)) {
                        Text("“${quote.text}”", fontFamily = FontFamily.Serif, fontSize = 15.sp, lineHeight = 21.sp)
                        Spacer(Modifier.height(6.dp))
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Column(Modifier.weight(1f)) {
                                Text(quote.workTitle.ifBlank { "Origem não registrada" }, fontSize = 12.sp, color = green, fontWeight = FontWeight.Bold)
                                if (quote.chapterTitle.isNotBlank()) Text(quote.chapterTitle, fontSize = 11.sp, color = Color(0xFF5a544a))
                            }
                            IconButton({ onRemoveQuote(quote.id) }) {
                                Icon(Icons.Filled.Delete, "Remover citação", tint = Color(0xFF5a544a))
                            }
                        }
                    }
                }
            }
        }
        Spacer(Modifier.height(24.dp))
        Text("Sobre", fontWeight = FontWeight.Bold)
        Text("Obras integrais de Machado de Assis (1839–1908), em domínio público. Transcrições do Wikisource com adaptação ortográfica. App offline, sem anúncios.", fontSize = 14.sp, color = Color(0xFF5a544a))
        Spacer(Modifier.height(16.dp))
        Text("Licenças e fontes: ver tela de detalhe da obra e documentação do projeto.", fontSize = 12.sp, color = Color(0xFF5a544a))
        Spacer(Modifier.height(24.dp))
    }
}

@Composable
private fun StatCard(value: String, label: String) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) { Text(value, fontSize = 28.sp, fontWeight = FontWeight.Bold, color = green); Text(label, fontSize = 12.sp) }
}

@Composable
internal fun SectionTitle(title: String) {
    Text(title, color = gold, fontWeight = FontWeight.Bold, modifier = Modifier.padding(top = 20.dp, bottom = 6.dp), letterSpacing = 1.sp)
}

val gold = Color(0xFFB39255)
val green = Color(0xFF173B32)
val paper = Color(0xFFEFE6D5)
val ivory = Color(0xFFF7F2E8)

@Composable
fun Cover(work: WorkEntity, modifier: Modifier) {
    val base = if (work.id.hashCode() % 2 == 0) green else Color(0xFF3A2921)
    Box(modifier.background(base, RoundedCornerShape(6.dp)), contentAlignment = Alignment.Center) {
        Text(work.title.take(2).uppercase(), color = Color(0xFFF7F2E8), fontFamily = FontFamily.Serif, fontSize = 20.sp)
    }
}
