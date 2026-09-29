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
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import br.com.catecismo.igreja.db.ChapterProgressEntity
import br.com.catecismo.igreja.db.WorkEntity

data class CharacterCard(val id: String, val name: String, val work: String, val summary: String, val story: String, val image: Int?, val workId: String)

@Composable
private fun topicCards() = listOf(
    CharacterCard("credo", stringResource(R.string.topic_creed), stringResource(R.string.topic_creed_work), stringResource(R.string.topic_creed_summary), stringResource(R.string.topic_creed_story), null, "credo-em-caminho"),
    CharacterCard("sacramentos", stringResource(R.string.topic_sacraments), stringResource(R.string.topic_sacraments_work), stringResource(R.string.topic_sacraments_summary), stringResource(R.string.topic_sacraments_story), null, "sinais-da-graca"),
    CharacterCard("oracao", stringResource(R.string.topic_prayer), stringResource(R.string.topic_prayer_work), stringResource(R.string.topic_prayer_summary), stringResource(R.string.topic_prayer_story), null, "escola-da-oracao"),
    CharacterCard("igreja", stringResource(R.string.topic_church), stringResource(R.string.topic_church_work), stringResource(R.string.topic_church_summary), stringResource(R.string.topic_church_story), null, "a-igreja-viva"),
    CharacterCard("maria", stringResource(R.string.topic_mary), stringResource(R.string.topic_mary_work), stringResource(R.string.topic_mary_summary), stringResource(R.string.topic_mary_story), null, "maria-e-o-sim")
)

@Composable
fun UniverseScreen(onCharacter: (CharacterCard) -> Unit) {
    val topics = topicCards()
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState())) {
        androidx.compose.foundation.Image(painterResource(R.drawable.bg_church_community), stringResource(R.string.icon_community_description), Modifier.fillMaxWidth().height(190.dp), contentScale = androidx.compose.ui.layout.ContentScale.Crop)
        Column(Modifier.padding(22.dp)) {
            Text(stringResource(R.string.explore_catechism), color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            Text(stringResource(R.string.topics_walk_title), fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 29.sp, color = green)
            Text(stringResource(R.string.topics_walk_description), color = Color(0xFF5a544a), modifier = Modifier.padding(top = 5.dp))
            Spacer(Modifier.height(18.dp))
            LazyRow(horizontalArrangement = Arrangement.spacedBy(12.dp), contentPadding = PaddingValues(bottom = 8.dp)) { items(topics) { topic -> TopicTile(topic) { onCharacter(topic) } } }
            SectionTitle(stringResource(R.string.featured_topics))
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
    Scaffold(topBar = { TopAppBar(title = { Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold) }, navigationIcon = { IconButton(onBack) { Icon(Icons.AutoMirrored.Filled.ArrowBack, stringResource(R.string.back)) } }, actions = { IconButton(onToggle) { Icon(if (isFav) Icons.Filled.Star else Icons.Filled.StarBorder, stringResource(R.string.favorite), tint = if (isFav) gold else Color.Unspecified) } }) }) { pad ->
        Column(Modifier.padding(pad).verticalScroll(rememberScrollState()).padding(22.dp)) {
            TopicIcon(c, Modifier.fillMaxWidth().height(180.dp).clip(RoundedCornerShape(22.dp)))
            Text(c.name, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 32.sp, color = green, modifier = Modifier.padding(top = 18.dp))
            Text(c.work.uppercase(), color = gold, fontWeight = FontWeight.Bold, letterSpacing = 1.sp)
            SectionTitle(stringResource(R.string.about_this_topic)); Text(c.summary, fontFamily = FontFamily.Serif, fontSize = 18.sp, lineHeight = 26.sp)
            SectionTitle(stringResource(R.string.reflection)); Text(c.story, fontFamily = FontFamily.Serif, fontSize = 17.sp, lineHeight = 25.sp)
            Spacer(Modifier.height(14.dp)); OutlinedButton({ openWork(c.workId) }, Modifier.fillMaxWidth()) { Text(stringResource(R.string.open_guide)) }
        }
    }
}

@Composable
fun MyLibraryScreen(
    works: List<WorkEntity>,
    progress: List<ChapterProgressEntity>,
    favorites: List<String>,
    quotes: List<Quote>,
    openWork: (WorkEntity) -> Unit,
    onUniverse: () -> Unit,
    selectedLanguage: String,
    onLanguageChange: (String) -> Unit
) {
    val activeIds = progress.map { it.workId }.toSet()
    val completed = works.filter { work -> progress.count { it.workId == work.id && it.progress >= 100 } >= work.chapterCount }.map { it.id }.toSet()
    val active = works.filter { it.id in activeIds && it.id !in completed }; val fav = works.filter { it.id in favorites }
    val readingPercent = if (progress.isEmpty()) 0 else progress.map { it.progress }.average().toInt()
    Column(Modifier.fillMaxSize().verticalScroll(rememberScrollState()).padding(22.dp)) {
        Text(stringResource(R.string.my_library_title), fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 30.sp, color = green)
        Text(stringResource(R.string.my_library_subtitle), color = Color(0xFF5a544a)); Spacer(Modifier.height(18.dp))
        Row(Modifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(stringResource(R.string.language_setting), fontWeight = FontWeight.Bold, modifier = Modifier.weight(1f))
            var languageMenuOpen by remember { mutableStateOf(false) }
            Box {
                OutlinedButton(onClick = { languageMenuOpen = true }) {
                    Text(stringResource(AppLanguage.labelResource(selectedLanguage)))
                }
                DropdownMenu(expanded = languageMenuOpen, onDismissRequest = { languageMenuOpen = false }) {
                    AppLanguage.choices.forEach { language ->
                        DropdownMenuItem(
                            text = { Text(stringResource(AppLanguage.labelResource(language))) },
                            onClick = { languageMenuOpen = false; onLanguageChange(language) }
                        )
                    }
                }
            }
        }
        Spacer(Modifier.height(14.dp))
        Row(horizontalArrangement = Arrangement.spacedBy(8.dp), modifier = Modifier.fillMaxWidth()) { MetricCard("${completed.size}", stringResource(R.string.completed), Modifier.weight(1f)); MetricCard("${active.size}", stringResource(R.string.in_progress), Modifier.weight(1f)); MetricCard("$readingPercent%", stringResource(R.string.progress), Modifier.weight(1f)) }
        SectionTitle(stringResource(R.string.continue_studying))
        if (active.isEmpty()) Text(stringResource(R.string.no_guide_started), color = Color(0xFF5a544a)) else active.take(3).forEach { w -> LibraryWorkRow(w, progress.filter { it.workId == w.id }.maxOfOrNull { it.progress } ?: 0, openWork) }
        SectionTitle(stringResource(R.string.guide_favorites))
        if (fav.isEmpty()) Text(stringResource(R.string.empty_favorites), color = Color(0xFF5a544a)) else fav.forEach { w -> LibraryWorkRow(w, 0, openWork) }
        SectionTitle(stringResource(R.string.explore_topics)); OutlinedButton(onUniverse, Modifier.fillMaxWidth()) { Text(stringResource(R.string.learn_faith_topics)) }
        SectionTitle(stringResource(R.string.saved_quotes))
        if (quotes.isEmpty()) Text(stringResource(R.string.save_quote_hint), color = Color(0xFF5a544a)) else quotes.take(3).forEach { q -> Text("“${q.text}”", fontFamily = FontFamily.Serif, fontSize = 15.sp, modifier = Modifier.padding(vertical = 5.dp)); Text(q.workTitle, color = gold, fontSize = 12.sp) }
    }
}

@Composable private fun MetricCard(value: String, label: String, modifier: Modifier) { Surface(modifier, RoundedCornerShape(16.dp), color = paper) { Column(Modifier.padding(12.dp), horizontalAlignment = Alignment.CenterHorizontally) { Text(value, fontSize = 24.sp, fontWeight = FontWeight.Bold, color = green); Text(label, fontSize = 11.sp) } } }
@Composable private fun LibraryWorkRow(w: WorkEntity, pct: Int, open: (WorkEntity) -> Unit) { Row(Modifier.fillMaxWidth().clickable { open(w) }.padding(vertical = 7.dp), verticalAlignment = Alignment.CenterVertically) { Cover(w, Modifier.size(44.dp, 62.dp)); Spacer(Modifier.width(12.dp)); Column(Modifier.weight(1f)) { Text(w.title, fontFamily = FontFamily.Serif, fontWeight = FontWeight.Bold, fontSize = 17.sp); Text(w.category, fontSize = 12.sp); LinearProgressIndicator({ pct / 100f }, Modifier.fillMaxWidth().padding(top = 5.dp)) } } }
