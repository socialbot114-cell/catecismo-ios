#!/usr/bin/env python3
"""Pipeline de importação dos textos integrais de Machado de Assis (Wikisource PT).

Gera app/src/main/assets/texts/<id>.json.gzdata + index.json.gzdata com metadados.
Textos originais em domínio público (autor falecido em 1908).
Transcrições: Wikisource (CC BY-SA dos colaboradores) — atribuição registrada.
"""
import gzip
import json
import re
import sys
import time
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path

API = "https://pt.wikisource.org/w/api.php"
UA = "MachadoBibliotecaImporter/1.0 (aplicativo educacional; contato: dev@local) python-urllib"
CACHE = Path(__file__).resolve().parent / "cache"
CACHE.mkdir(exist_ok=True)
OUT = Path(__file__).resolve().parent.parent / "app/src/main/assets/texts"
OUT.mkdir(parents=True, exist_ok=True)

SKIP_CLASSES = ("ws-noexport", "licensetpl", "navigationHeader", "noprint",
                "printfooter", "catlinks", "mw-editsection", "toc", "ws-summary",
                "headertemplate", "licenseContainer", "ws-export")
VOID = {"br", "img", "hr", "meta", "link", "input"}


class Extractor(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.stack = []
        self.paras, self.headings = [], []
        self.buf, self.in_p, self.in_h = [], 0, None

    def handle_starttag(self, tag, attrs):
        cls = dict(attrs).get("class", "")
        skipping = any(s in cls for s in SKIP_CLASSES)
        if self.stack and self.stack[-1][1]:
            skipping = True
        if tag not in VOID:
            self.stack.append((tag, skipping))
        if tag == "p" and not skipping:
            self.in_p += 1
            self.buf = []
        if tag in ("h1", "h2", "h3", "h4") and not skipping:
            self.in_h = tag
            self.buf = []

    def handle_endtag(self, tag):
        if tag in VOID:
            return
        for i in range(len(self.stack) - 1, -1, -1):
            if self.stack[i][0] == tag:
                skipping = self.stack[i][1]
                del self.stack[i:]
                if tag == "p" and not skipping and self.in_p:
                    txt = re.sub(r"\s+", " ", "".join(self.buf)).strip()
                    if txt:
                        self.paras.append(txt)
                    self.in_p -= 1
                if tag == self.in_h and not skipping:
                    txt = re.sub(r"\s+", " ", "".join(self.buf)).strip()
                    if txt:
                        self.headings.append(txt)
                    self.in_h = None
                break

    def handle_data(self, data):
        if self.stack and self.stack[-1][1]:
            return
        if self.in_p or self.in_h:
            self.buf.append(data)


def api(params: dict) -> dict:
    qs = urllib.parse.urlencode(params)
    url = f"{API}?{qs}"
    import hashlib
    cache_file = CACHE / (hashlib.md5(url.encode()).hexdigest() + ".json")
    if cache_file.exists():
        return json.loads(cache_file.read_text(encoding="utf-8"))
    for attempt in range(8):
        try:
            req = urllib.request.Request(url, headers={"User-Agent": UA, "Accept": "application/json"})
            with urllib.request.urlopen(req, timeout=45) as r:
                data = json.loads(r.read().decode("utf-8"))
            cache_file.write_text(json.dumps(data, ensure_ascii=False), encoding="utf-8")
            time.sleep(1.2)
            return data
        except Exception as e:
            wait = min(60, 3 * (2 ** attempt))
            print(f"  retry {attempt+1} ({e}) aguardando {wait}s", file=sys.stderr)
            time.sleep(wait)
    raise RuntimeError(f"API falhou: {url}")


def page_html(title: str) -> str:
    d = api({"action": "parse", "page": title, "prop": "text",
             "format": "json", "formatversion": "2", "redirects": 1})
    if "error" in d:
        raise RuntimeError(d["error"].get("info", "erro"))
    return d["parse"]["text"]


def extract(html: str):
    ex = Extractor()
    ex.feed(html)
    return ex.paras, ex.headings


def subpages(prefix: str) -> list[str]:
    d = api({"action": "query", "list": "allpages", "apprefix": prefix,
             "apnamespace": 0, "aplimit": "max", "format": "json", "formatversion": "2"})
    return [p["title"] for p in d["query"]["allpages"]]


ROMAN = {"I": 1, "II": 2, "III": 3, "IV": 4, "V": 5, "VI": 6, "VII": 7, "VIII": 8,
         "IX": 9, "X": 10, "XI": 11, "XII": 12, "XIII": 13, "XIV": 14, "XV": 15,
         "XVI": 16, "XVII": 17, "XVIII": 18, "XIX": 19, "XX": 20}


def roman_sort_key(title: str):
    suffix = title.split("/", 1)[1] if "/" in title else ""
    if suffix in ROMAN:
        return (0, ROMAN[suffix])
    if re.fullmatch(r"C+|[CD]X*[LV]*|C+[IVXLCDM]*", suffix) and suffix not in ("Casa",):
        try:
            from roman import fromRoman  # optional
            return (0, fromRoman(suffix))
        except Exception:
            pass
    return (1, suffix)


MODERN = [
    (r"\bideia\b", "ideia"), (r"\bIdéia\b", "Ideia"), (r"\bidéias\b", "ideias"),
    (r"\bIdéias\b", "Ideias"), (r"\bherva\b", "erva"), (r"\bHerva\b", "Erva"),
    (r"\bbello\b", "belo"), (r"\bBello\b", "Belo"), (r"\bella\b", "ela"),
    (r"\bElla\b", "Ela"), (r"\bellas\b", "elas"), (r"\bEllas\b", "Elas"),
    (r"\bd'ella\b", "dela"), (r"\bá\b", "a"), (r"\btrês\b", "três"),
    (r"\bfreqüente\b", "frequente"), (r"\bFreqüente\b", "Frequente"),
    (r"\bconseqüência\b", "consequência"), (r"\bqüinqüênio\b", "quinquênio"),
    (r"\bargüir\b", "arguir"), (r"\blingüiça\b", "linguiça"),
    (r"\btranqüillo\b", "tranquilo"), (r"\btranqüilo\b", "tranquilo"),
    (r"\bvôo\b", "voo"), (r"\bVôo\b", "Voo"), (r"\benjôo\b", "enjoo"),
    (r"\bcrêem\b", "creem"), (r"\blêem\b", "leem"), (r"\bvêem\b", "veem"),
    (r"\bdêem\b", "deem"), (r"\bpôde\b", "pôde"),
]


def modernize(text: str) -> str:
    for pattern, repl in MODERN:
        text = re.sub(pattern, repl, text)
    text = text.replace("—", "—")
    return text


def clean(paras: list[str]) -> list[str]:
    out = []
    for p in paras:
        p = p.replace("\xad", "")  # soft hyphen de paginação
        p = re.sub(r"\b-\s*\n\s*", "", p)  # hífen final de linha
        p = p.replace("\n", " ")
        p = re.sub(r"\[\d+\]|\[nota \d+\]", "", p)
        p = re.sub(r"\s+", " ", p).strip()
        p = re.sub(r"\s+([,.;:!?])", r"\1", p)
        if p and not re.fullmatch(r"[\W\d\s]+", p):
            out.append(modernize(p))
    return out


def fetch_chapters(titles: list[str]) -> list[dict]:
    chapters = []
    for i, t in enumerate(sorted(titles, key=roman_sort_key)):
        html = page_html(t)
        paras, headings = extract(html)
        paras = clean(paras)
        if not paras:
            print(f"  ! sem parágrafos: {t}", file=sys.stderr)
            continue
        suffix = t.split("/", 1)[1] if "/" in t else ""
        title = headings[0] if headings else f"Capítulo {suffix}"
        chapters.append({"title": title, "paragraphs": paras})
        print(f"  {i+1}/{len(titles)} {t}: {len(paras)} parágrafos", file=sys.stderr)
        time.sleep(1.0)
    return chapters


def fetch_single(title: str) -> list[dict]:
    html = page_html(title)
    paras, headings = extract(html)
    paras = clean(paras)
    if not paras:
        raise RuntimeError(f"sem texto em {title}")
    return [{"title": headings[0] if headings else title, "paragraphs": paras}]


WORKS = [
    # (id, título, ano, categoria, página principal, prefixo subpáginas ou None, descrição, contexto, personagens)
    ("dom", "Dom Casmurro", 1899, "Romance", "Dom Casmurro", "Dom Casmurro/",
     "A memória de Bentinho revisita amor, ciúme e as ambiguidades da lembrança.",
     "Rio de Janeiro do Segundo Reinado; narrador não confiável e dúvida eterna.",
     ["Bentinho", "Capitu", "Escobar", "Dona Glória", "José Dias"]),
    ("brascubas", "Memórias Póstumas de Brás Cubas", 1881, "Romance",
     "Memórias Póstumas de Brás Cubas", "Memórias Póstumas de Brás Cubas/",
     "Um defunto-autor narra sua vida com humor corrosivo e liberdade de espírito.",
     "Romance inaugural do realismo brasileiro; narrador morto e filosofia do pessimismo.",
     ["Brás Cubas", "Virgília", "Quincas Borba", "Marcela", "Eugênia"]),
    ("quincas", "Quincas Borba", 1891, "Romance", "Quincas Borba", "Quincas Borba/",
     "Rubião herda uma filosofia e uma fortuna, entrando num mundo de ilusões sociais.",
     "Sátira do Humanitismo e da sociedade carioca da virada do século.",
     ["Rubião", "Quincas Borba", "Sofia", "Palha", "Carlos Maria"]),
    ("helena", "Helena", 1876, "Romance", "Helena", "Helena/",
     "Uma jovem chega a uma família abastada e transforma suas certezas.",
     "Romance de costumes do Segundo Reinado; fazenda e cidade.",
     ["Helena", "Estácio", "Dona Úrsula", "Mendonga"]),
    ("iaia", "Iaiá Garcia", 1878, "Romance", "Iaiá Garcia", "Iaiá Garcia/",
     "Afetos, escolhas e as tensões da sociedade carioca do Segundo Reinado.",
     "Romance psicológico sobre classe, dever e afeto.",
     ["Iaiá Garcia", "Luís Garcia", "Estela", "Jorge"]),
    ("esau", "Esaú e Jacó", 1904, "Romance", "Esaú e Jacó", "Esaú e Jacó/",
     "Dois irmãos gêmeos atravessam mudanças políticas e afetivas do Brasil.",
     "Da Monarquia à República; gêmeos rivais e a mãe que prevê o futuro.",
     ["Paulo", "Pedro", "Flora", "Natividade", "Perpétua"]),
    ("memorial", "Memorial de Aires", 1908, "Romance", "Memorial de Aires", "Memorial de Aires/",
     "O diário de um diplomata aposentado contempla o tempo, a velhice e a amizade.",
     "Último romance de Machado, em forma de diário (1888–1889).",
     ["Conselheiro Aires", "Fidélia", "Tristão", "Dona Carmo"]),
    ("casa-velha", "Casa Velha", 1885, "Romance", "Casa Velha", "Casa Velha/",
     "Narrativa de seminário, vocação incerta e afetos discretos no interior.",
     "Publicada postumamente em livro (1885); ambientação religiosa e rural.",
     ["Nogueira", "Dona Carlota", "D. Eusébia", "Padre"]),
    ("ressurreicao", "Ressurreição", 1872, "Romance", "Ressurreição (Machado de Assis)", "Ressurreição (Machado de Assis)/",
     "O primeiro romance de Machado observa o amor com ironia e delicadeza.",
     "Rio de 1860; salões, leitura de romances e ceticismo amoroso.",
     ["Félix", "Lívia", "Viana"]),
    ("mao-e-luva", "A Mão e a Luva", 1874, "Romance", "A mão e a luva", "A mão e a luva/",
     "Uma comédia de costumes sobre casamento, interesse e afeto verdadeiro.",
     "Novela publicada em 1874; sociedade fluminense e seus casamentos.",
     ["Estêvão", "Guiomar", "Mariana", "Luís Alves"]),
    # Contos
    ("alienista", "O Alienista", 1882, "Conto", "O Alienista", "O Alienista/",
     "Em Itaguaí, a ciência de Simão Bacamarte vira uma sátira do poder e da normalidade.",
     "Conto de Papéis Avulsos; a Casa Verde como espelho da autoridade.",
     ["Simão Bacamarte", "Dona Evarista", "Crispim Soares", "Porfírio"]),
    ("cartomante", "A Cartomante", 1884, "Conto", "A Cartomante", None,
     "Amor, superstição e ironia se cruzam num dos contos mais conhecidos do autor.",
     "Publicado em Várias Histórias (1884); a promessa de certeza não vence a realidade.",
     ["Rita", "Camilo", "Vilela"]),
    ("espelho", "O Espelho", 1882, "Conto", "O Espelho", None,
     "Uma teoria sobre as duas almas e a identidade social de Jacobina.",
     "Esboço de uma nova teoria da alma humana; Papéis Avulsos.",
     ["Jacobina"]),
    ("pai-contra-mae", "Pai contra mãe", 1906, "Conto", "Pai contra mãe", None,
     "Um conto duro sobre escravidão, pobreza e escolhas impostas pela sobrevivência.",
     "Relíquias de Casa Velha (1906); a violência da escravidão não é romantizada.",
     ["Cândido Neves", "Arminda", "Clara"]),
    ("teoria-medalhao", "Teoria do Medalhão", 1881, "Conto", "Teoria do Medalhão", None,
     "Um pai oferece ao filho um manual irônico de conformismo e prestígio.",
     "Papéis Avulsos (1882); diálogo satírico sobre ideias próprias.",
     ["Pai", "Janjão"]),
    ("causa-secreta", "A Causa Secreta", 1896, "Conto", "A Causa Secreta", None,
     "Sobre o prazer oculto da crueldade e a amizade entre dois homens.",
     "Várias Histórias; o prazer de causar dor como causa secreta.",
     ["Fortunato", "Garcia", "Maria Luísa"]),
    ("homem-celebre", "Um Homem Célebre", 1896, "Conto", "Um Homem Célebre", None,
     "Pestana, o grande compositor, só é célebre pelas polcas que compõe.",
     "Várias Histórias; arte séria versus sucesso popular.",
     ["Pestana", "narrador"]),
    ("uns-bracos", "Uns Braços", 1884, "Conto", "Uns Braços", None,
     "Os braços de D. Severina e a obsessão silenciosa de Inácio.",
     "Histórias sem Data; desejo contido na casa de repouso.",
     ["Inácio", "D. Severina", "Dr. Abreu"]),
    ("igreja-do-diabo", "A Igreja do Diabo", 1881, "Conto", "A Igreja do Diabo", None,
     "O Diabo funda uma igreja para corromper o mundo por meios brandos.",
     "Papéis Avulsos; sátira sobre moral e hipocrisia.",
     ["Diabo", "narrador"]),
    ("noite-de-almirante", "Noite de Almirante", 1883, "Conto", "Noite de almirante", None,
     "A memória de uma noite festiva revive no velho almirante.",
     "Histórias sem Data; nostalgia e juventude.",
     ["Almirante", "narrador"]),
    ("enfermeiro", "O Enfermeiro", 1884, "Conto", "O Enfermeiro", None,
     "Um enfermeiro, um paciente tirânico e a culpa que não passa.",
     "Várias Histórias; moral ambígua e confissão.",
     ["narrador", "Coronel Felisberto", "Padre"]),
    ("miss-dollar", "Miss Dollar", 1870, "Conto", "Miss Dollar", "Miss Dollar/",
     "Uma cachorra chamada Miss Dollar cruza destinos no Rio de 1869.",
     "Contos Fluminenses; o Rio da corte e seus tipos.",
     ["Mendes", "Luísa", "Miss Dollar"]),
    ("capitulo-dos-chapeus", "Capítulo dos Chapéus", 1884, "Conto", "Capítulo dos chapéus", None,
     "Marido e mulher, um chapéu e o ciúme que nasce de um mal-entendido.",
     "Histórias sem Data; ironia conjugal.",
     ["Mariana", "Damião", "Sofia"]),
    ("segredo-do-bonzo", "O Segredo do Bonzo", 1884, "Conto", "O segredo do bonzo", None,
     "Um bonzo japonês guarda um segredo sobre a felicidade.",
     "Histórias sem Data; fábula oriental e sabedoria irônica.",
     ["Bonzo", "Fjodôr"]),
    ("serenissima-republica", "A Sereníssima República", 1884, "Conto", "A sereníssima República", None,
     "Um viajante descobre uma república onde a verdade é lei absoluta.",
     "Histórias sem Data; utopia satírica.",
     ["narrador", "presidente"]),
    ("conego", "O Cônego ou Metafísica do Estilo", 1885, "Conto", "O Cônego ou Metafísica do Estilo", None,
     "Um cônego, um estilo e a arte de dizer sem dizer.",
     "Várias Histórias; metalinguagem e ironia.",
     ["Cônego", "narrador"]),
    ("entre-santos", "Entre Santos", 1883, "Conto", "Entre Santos", None,
     "Dois santos conversam sobre a vida terrena e suas vaidades.",
     "Histórias sem Data; diálogo alegórico.",
     ["Santo", "Santo"]),
    ("dona-benedita", "Dona Benedita", 1885, "Conto", "D. Benedita", "D. Benedita/",
     "Uma viúva, um noivo e as convenções do casamento.",
     "Resíduos (contos); costumes e afetos.",
     ["Dona Benedita", "Floriano"]),
    ("o-lapso", "O Lapso", 1885, "Conto", "O Lapso", None,
     "Um homem esquece o nome da pessoa com quem acaba de conversar.",
     "Resíduos; pequena comédia da memória.",
     ["narrador", "Senior Neves"]),
    ("cantiga-de-esponsais", "Cantiga de Esponsais", 1883, "Conto", "Cantiga de esponsaes", None,
     "Um compositor, uma noiva e a música que não se completa.",
     "Histórias sem Data; arte e casamento.",
     ["Romeu", "Lívia", "pai"]),
]


def build():
    index = []
    report = []
    for (wid, title, year, cat, page, prefix, desc, ctx, chars) in WORKS:
        print(f"== {title}", file=sys.stderr)
        try:
            if prefix:
                subs = subpages(prefix)
                # remove páginas não-capítulo conhecidas
                subs = [s for s in subs if not s.endswith(("/Índice", "/Capa", "/Nota"))]
                chapters = fetch_chapters(subs)
            else:
                chapters = fetch_single(page)
        except Exception as e:
            print(f"  ERRO {title}: {e}", file=sys.stderr)
            report.append((title, "ERRO", 0, 0, str(e)))
            continue
        words = sum(len(p.split()) for c in chapters for p in c["paragraphs"])
        data = {"id": wid, "title": title, "author": "Machado de Assis", "year": year,
                "category": cat, "status": "integral", "sourceUrl": f"https://pt.wikisource.org/wiki/{urllib.parse.quote(page)}",
                "description": desc, "context": ctx, "characters": chars,
                "chapters": chapters}
        path = OUT / f"{wid}.json.gzdata"
        with gzip.open(path, "wt", encoding="utf-8", compresslevel=9) as f:
            json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
        index.append({"id": wid, "title": title, "year": year, "category": cat,
                      "description": desc, "context": ctx, "characters": chars,
                      "status": "integral", "sourceUrl": data["sourceUrl"],
                      "chapters": len(chapters), "words": words})
        report.append((title, "OK", len(chapters), words, ""))
        print(f"  -> {path.name}: {len(chapters)} capítulos, {words} palavras", file=sys.stderr)

    with gzip.open(OUT / "index.json.gzdata", "wt", encoding="utf-8", compresslevel=9) as f:
        json.dump(index, f, ensure_ascii=False, separators=(",", ":"))

    print("\n=== RELATÓRIO ===")
    for r in report:
        print(f"{r[0]:45s} {r[1]:5s} caps={r[2]:4d} palavras={r[3]:7d} {r[4]}")


if __name__ == "__main__":
    build()
