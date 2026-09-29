#!/usr/bin/env python3
"""Importação do texto integral do Catecismo da Igreja Católica (Vatican.va, edição pt).

Gera app/src/main/assets/texts/cic-*.json + index.json e cópia para iosApp/Resources/Texts.
Texto © Libreria Editrice Vaticana — atribuição registrada em cada asset (sourceUrl).
Sem ortografia reescrita: fidelidade completa ao texto publicado pela Santa Sé.
"""
import html as html_mod
import json
import re
import sys
import time
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
CACHE = ROOT / "tools" / "cache" / "catecismo"
OUT_ANDROID = ROOT / "app" / "src" / "main" / "assets" / "texts"
OUT_IOS = ROOT / "iosApp" / "Resources" / "Texts"
CACHE.mkdir(parents=True, exist_ok=True)
OUT_ANDROID.mkdir(parents=True, exist_ok=True)
OUT_IOS.mkdir(parents=True, exist_ok=True)

BASE = "https://www.vatican.va/archive/cathechism_po/index_new/"
USER_AGENT = ("CatecismoImporter/1.2 (aplicativo criativo offline, EUA; contato: suporte@catecismo.app) python-urllib")

# (arquivo no site, § inicial, § final)
PAGE_SPEC = [
    ("prologo%201-25_po.html", 1, 25),
    ("p1s1c1_26-49_po.html", 26, 49),
    ("p1s1c2_50-141_po.html", 50, 141),
    ("p1s1c3_142-184_po.html", 142, 184),
    ("p1s2_185-197_po.html", 185, 197),
    ("p1s2c1_198-421_po.html", 198, 421),
    ("p1s2cap2_422-682_po.html", 422, 682),
    ("p1s2cap3_683-1065_po.html", 683, 1065),
    ("p2s1cap1_1066-1075_po.html", 1066, 1075),
    ("p2s1cap1_1076-1134_po.html", 1076, 1134),
    ("p2s1cap2_1135-1209_po.html", 1135, 1209),
    ("p2s2cap1_1210-1419_po.html", 1210, 1419),
    ("p2s2cap1_1420-1532_po.html", 1420, 1532),
    ("p2s2cap3_1533-1666_po.html", 1533, 1666),
    ("p2s2cap4_1667-1690_po.html", 1667, 1690),
    ("p3-intr_1691-1698_po.html", 1691, 1698),
    ("p3s1cap1_1699-1876_po.html", 1699, 1876),
    ("p3s1cap2_1877-1948_po.html", 1877, 1948),
    ("p3s1cap3_1949-2051_po.html", 1949, 2051),
    ("p3s2-intr_2052-2082_po.html", 2052, 2082),
    ("p3s2cap1_2083-2195_po.html", 2083, 2195),
    ("p3s2cap2_2196-2557_po.html", 2196, 2557),
    ("p4-intr_2558-2565_po.html", 2558, 2565),
    ("p4s1cap1_2566-2649_po.html", 2566, 2649),
    ("p4s1cap2_2650-2696_po.html", 2650, 2696),
    ("p4s1cap3_2697-2758_po.html", 2697, 2758),
    ("p4s2_2759-2865_po.html", 2759, 2865),
]

# Estrutura oficial do Catecismo: capítulos = um por artigo + introduções.
# (título da seção, § inicial) — ver WORKS abaixo, validado contra as seções do Vaticano.

WORKS = [
    {
        "id": "catecismo-parte-1",
        "title": "Catecismo – Parte I: A Profissão da Fé",
        "description": "Texto integral da Primeira Parte do Catecismo da Igreja Católica (§§26–1065).",
        "context": "Texto oficial da Santa Sé, edição em português do Vaticano. Prólogo e Parte I, do desejo de Deus ao «Creio na vida eterna».",
        "characters": ["Credo", "Criação", "Jesus Cristo", "Espírito Santo", "Igreja", "Vida eterna"],
        "sourceUrl": "https://www.vatican.va/archive/cathechism_po/index_new/index-prima-parte_po.html",
        "sections": [
            ("Prólogo: a vida do homem é conhecer e amar a Deus", 1),
            ("O homem é «capaz» de Deus — o desejo de Deus", 27),
            ("Deus vem ao encontro do homem", 44),
            ("A resposta do homem a Deus", 142),
            ("O Credo — síntese da fé recebida dos apóstolos", 185),
            ("Creio em Deus Pai todo-poderoso, criador do céu e da terra", 198),
            ("A Boa-Nova: Deus enviou o seu Filho", 422),
            ("Creio em Jesus Cristo, Filho único de Deus", 430),
            ("Jesus Cristo foi concebido pelo poder do Espírito Santo", 456),
            ("Jesus Cristo padeceu sob Pôncio Pilatos, foi crucificado, morto e sepultado", 571),
            ("Jesus Cristo desceu aos infernos, ao terceiro dia ressuscitou dos mortos", 631),
            ("Jesus subiu aos céus, está sentado à direita de Deus Pai", 659),
            ("Donde virá julgar os vivos e os mortos", 668),
            ("Creio no Espírito Santo", 683),
            ("Creio na Santa Igreja Católica", 748),
            ("Creio no perdão dos pecados", 976),
            ("Creio na ressurreição da carne", 988),
            ("Creio na vida eterna", 1020),
        ],
        "end": 1065,
    },
    {
        "id": "catecismo-parte-2",
        "title": "Catecismo – Parte II: A Celebração do Mistério Cristão",
        "description": "Texto integral da Segunda Parte (§§1066–1690): a liturgia e os sete sacramentos.",
        "context": "Texto oficial da Santa Sé, edição em português do Vaticano. Por que a liturgia, o Mistério Pascal nos sacramentos e as celebrações.",
        "characters": ["Liturgia", "Batismo", "Confirmação", "Eucaristia", "Penitência", "Unção dos enfermos", "Ordem", "Matrimônio"],
        "sourceUrl": "https://www.vatican.va/archive/cathechism_po/index_new/index-seconda-parte_po.html",
        "sections": [
            ("Introdução: por que a liturgia?", 1066),
            ("O mistério pascal no tempo da Igreja", 1076),
            ("Celebrar a liturgia da Igreja", 1136),
            ("Diversidade litúrgica e unidade do mistério", 1200),
            ("Os sacramentos da Igreja", 1210),
            ("O sacramento do Batismo", 1212),
            ("O sacramento da Confirmação", 1285),
            ("O sacramento da Eucaristia", 1322),
            ("O sacramento da Penitência e da Reconciliação", 1420),
            ("A unção dos enfermos", 1499),
            ("O sacramento da Ordem", 1536),
            ("O sacramento do Matrimônio", 1601),
            ("Os funerais cristãos", 1680),
        ],
        "end": 1690,
    },
    {
        "id": "catecismo-parte-3",
        "title": "Catecismo – Parte III: A Vida em Cristo",
        "description": "Texto integral da Terceira Parte (§§1691–2557): dignidade humana, mandamentos e graça.",
        "context": "Texto oficial da Santa Sé, edição em português do Vaticano. Dignidade humana, comunidade, lei e graça e os Dez Mandamentos.",
        "characters": ["Dignidade humana", "Bem-aventurança", "Liberdade", "Consciência moral", "Virtudes", "Lei e graça", "Dez Mandamentos"],
        "sourceUrl": "https://www.vatican.va/archive/cathechism_po/index_new/index-terza-parte_po.html",
        "sections": [
            ("Introdução: a vida em Cristo", 1691),
            ("A dignidade da pessoa humana", 1699),
            ("Nossa vocação à bem-aventurança", 1716),
            ("A liberdade do homem", 1730),
            ("A moralidade dos atos humanos", 1749),
            ("A moralidade das paixões", 1762),
            ("A consciência moral", 1776),
            ("As virtudes", 1803),
            ("O pecado", 1846),
            ("A comunidade humana", 1877),
            ("A participação na vida social", 1897),
            ("A justiça social", 1928),
            ("A lei moral e a graça", 1949),
            ("Graça e justificação", 1987),
            ("A Igreja, mãe e educadora", 2030),
            ("Os Dez Mandamentos", 2052),
            ("O primeiro mandamento", 2083),
            ("O segundo mandamento", 2142),
            ("O terceiro mandamento", 2168),
            ("O quarto mandamento", 2197),
            ("O quinto mandamento", 2258),
            ("O sexto mandamento", 2331),
            ("O sétimo mandamento", 2401),
            ("O oitavo mandamento", 2464),
            ("O nono mandamento", 2514),
            ("O décimo mandamento", 2534),
        ],
        "end": 2557,
    },
    {
        "id": "catecismo-parte-4",
        "title": "Catecismo – Parte IV: A Oração Cristã",
        "description": "Texto integral da Quarta Parte (§§2558–2865): oração, tradição e Pai-Nosso.",
        "context": "Texto oficial da Santa Sé, edição em português do Vaticano. Revelação da oração, tradição, vida de oração e os sete pedidos do Pai-Nosso.",
        "characters": ["Oração", "Pai-Nosso", "Mariologia orante", "Tradição da oração"],
        "sourceUrl": "https://www.vatican.va/archive/cathechism_po/index_new/index-quarta-parte_po.html",
        "sections": [
            ("Introdução: a oração na vida cristã", 2558),
            ("A revelação da oração", 2566),
            ("A tradição da oração", 2650),
            ("A vida de oração", 2697),
            ("As expressões da oração", 2700),
            ("O combate da oração", 2725),
            ("O Pai-Nosso, resumo de todo o Evangelho", 2759),
            ("Pai nosso que estais no céu", 2777),
            ("Os sete pedidos", 2803),
        ],
        "end": 2865,
    },
]

KNOWN_MISSING = {2217, 2439}


def fetch(name):
    dest = CACHE / name
    if dest.exists():
        return dest.read_text(encoding="latin-1")
    url = BASE + name
    req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
    with urllib.request.urlopen(req, timeout=60) as r:
        raw = r.read()
    try:
        data = raw.decode("utf-8")
    except UnicodeDecodeError:
        data = raw.decode("latin-1")
    dest.write_text(data, encoding="latin-1")
    time.sleep(1.5)
    return data


def page_segments(raw):
    body = re.sub(r"<(script|style)[^>]*>.*?</\1>", " ", raw, flags=re.S | re.I)
    body = re.sub(r"<[pP][^>]*>", "\u2402", body)
    body = re.sub(r"<b[uBb]?\s*>", "\u2402", body)
    body = re.sub(r"</[bB]>", "", body)
    plain = re.sub(r"<[^>]+>", "", body)
    plain = html_mod.unescape(plain).replace("\xa0", " ")
    out = []
    for chunk in re.split("\u2402", plain):
        s = re.sub(r"\s+", " ", chunk).strip()
        if s:
            out.append(s)
    return out


def clean_paragraph(text):
    text = re.sub(r"^\s*(\d{1,4})\.\s*", lambda m: m.group(1) + ". ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return re.sub(r"\s+([,.;:!?»])", r"\1", text)


def build():
    paragraphs = {}
    for name, lo, hi in PAGE_SPEC:
        raw = fetch(name)
        for seg in page_segments(raw):
            match = re.match(r"^(\d{1,4})[\.\s]?[\s.]*", seg)
            if not match:
                continue
            n = int(match.group(1))
            if lo <= n <= hi and n not in paragraphs:
                paragraphs[n] = clean_paragraph(seg)

    gaps = [n for n in range(1, 2866) if n not in paragraphs]
    if gaps != sorted(KNOWN_MISSING):
        raise RuntimeError(f"Cobertura inválida do Catecismo: faltando {gaps}")

    index_entries = []
    total_words = 0
    for work in WORKS:
        sections = work["sections"]
        ends = [sec[1] for sec in sections[1:]] + [work["end"] + 1]
        chapters = []
        words = 0
        for (title, start), end in zip(sections, ends):
            numbers = [n for n in range(start, min(end, work["end"] + 1)) if n in paragraphs]
            if not numbers:
                raise RuntimeError(f"{work['id']}: seção vazia em §{start}-{end}")
            text_list = [paragraphs[n] for n in numbers]
            chapter_words = sum(len(t.split()) for t in text_list)
            chapters.append({"title": title, "paragraphs": text_list, "start": numbers[0], "end_range": numbers[-1], "words": chapter_words})
            words += chapter_words
        total_words += words
        asset = {
            "id": work["id"],
            "title": work["title"],
            "author": "Catecismo da Igreja Católica",
            "year": 1997,
            "category": "Catecismo integral",
            "status": "catecismo",
            "description": work["description"],
            "context": work["context"],
            "characters": work["characters"],
            "sourceUrl": work["sourceUrl"],
            "copyright": "Texto © Libreria Editrice Vaticana, distribuído pelo Vaticano em português (vatican.va).",
            "chapters": chapters,
        }
        path_android = OUT_ANDROID / f"{work['id']}.json"
        path_android.write_text(json.dumps(asset, ensure_ascii=False, indent=None), encoding="utf-8")
        (OUT_IOS / f"{work['id']}.json").write_text(json.dumps(asset, ensure_ascii=False, indent=None), encoding="utf-8")
        section_count = len(sections)
        print(f"{work['id']}: {section_count} seções, {words} palavras → {path_android.name}")

    # Atualiza index.json preservando as oito guias autorais
    index_path = OUT_ANDROID / "index.json"
    existing = json.loads(index_path.read_text(encoding="utf-8"))
    guias = [item for item in existing if item.get("status") == "guia"]
    catalog = []
    for work in WORKS:
        chapters = json.loads((OUT_ANDROID / f"{work['id']}.json").read_text(encoding="utf-8"))["chapters"]
        words = sum(chap["words"] for chap in chapters)
        catalog.append({
            "id": work["id"],
            "title": work["title"],
            "author": "Catecismo da Igreja Católica",
            "year": 1997,
            "category": "Catecismo integral",
            "status": "catecismo",
            "description": work["description"],
            "context": work["context"],
            "characters": work["characters"],
            "chapters": len(chapters),
            "words": words,
            "sourceUrl": work["sourceUrl"],
        })
    index_path.write_text(json.dumps(guias + catalog, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"TOTAL palavras CIC (sem 2 §§ ausentes {sorted(KNOWN_MISSING)}): {total_words}")


if __name__ == "__main__":
    build()
