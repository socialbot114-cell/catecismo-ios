#!/usr/bin/env python3
"""Build offline Catechism assets from the Diocese of Miracema PDF edition."""
import argparse
import json
import re
import subprocess
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_ANDROID = ROOT / "app" / "src" / "main" / "assets" / "texts"
OUT_IOS = ROOT / "iosApp" / "Resources" / "Texts"
SOURCE_URL = "https://diocesedemiracemato.org.br/upload/arquivos/214.pdf"
SOURCE_NAME = "Catecismo da Igreja Católica — edição portuguesa no PDF da Diocese de Miracema"

# Estrutura oficial do Catecismo: capítulos = um por artigo + introduções.
# (título da seção, § inicial), organizado em quatro partes.

WORKS = [
    {
        "id": "catecismo-parte-1",
        "title": "Parte I — A Profissão da Fé",
        "description": "Prólogo e Profissão da Fé no Catecismo da Igreja Católica (§§1–1065).",
        "context": f"Fonte: {SOURCE_NAME}. Texto e numeração reproduzidos da edição em português do PDF de origem.",
        "characters": ["Credo", "Criação", "Jesus Cristo", "Espírito Santo", "Igreja", "Vida eterna"],
        "sourceUrl": SOURCE_URL,
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
        "title": "Parte II — A Celebração do Mistério Cristão",
        "description": "Liturgia e sacramentos do Catecismo da Igreja Católica (§§1066–1690).",
        "context": f"Fonte: {SOURCE_NAME}. Texto e numeração reproduzidos da edição em português do PDF de origem.",
        "characters": ["Liturgia", "Batismo", "Confirmação", "Eucaristia", "Penitência", "Unção dos enfermos", "Ordem", "Matrimônio"],
        "sourceUrl": SOURCE_URL,
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
        "title": "Parte III — A Vida em Cristo",
        "description": "Dignidade humana, mandamentos e vida cristã (§§1691–2557).",
        "context": f"Fonte: {SOURCE_NAME}. Inclui os §§2217 e 2439 conforme a edição em português do PDF de origem.",
        "characters": ["Dignidade humana", "Bem-aventurança", "Liberdade", "Consciência moral", "Virtudes", "Lei e graça", "Dez Mandamentos"],
        "sourceUrl": SOURCE_URL,
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
        "title": "Parte IV — A Oração Cristã",
        "description": "Oração e Pai-Nosso no Catecismo da Igreja Católica (§§2558–2865).",
        "context": f"Fonte: {SOURCE_NAME}. Texto e numeração reproduzidos da edição em português do PDF de origem.",
        "characters": ["Oração", "Pai-Nosso", "Mariologia orante", "Tradição da oração"],
        "sourceUrl": SOURCE_URL,
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

EXPECTED_SECTIONS = set(range(1, 2866))


PARAGRAPH_MARKER = re.compile(r"^\s{0,5}(\d{1,4})\.\s*(.*\S.*)$")
ROMAN_HEADING = re.compile(r"^(?:[IVXLCDM]+\.?\s+)[A-ZÁÉÍÓÚÂÊÔÃÕÇ]", re.I)
NAMED_HEADING = re.compile(
    r"^(?:CAP[IÍ]TULO\b|ARTIGO\b|INTRODU[CÇ][AÃ]O\b|CONCLUS[AÃ]O\b|"
    r"(?:PRIMEIRA|SEGUNDA|TERCEIRA|QUARTA) PARTE\s*:)",
    re.I,
)


def run_pdftotext(pdf_path):
    try:
        result = subprocess.run(
            ["pdftotext", "-layout", "-enc", "UTF-8", str(pdf_path), "-"],
            check=True,
            capture_output=True,
            text=True,
            encoding="utf-8",
        )
    except FileNotFoundError as error:
        raise RuntimeError("pdftotext is required (install Poppler utils)") from error
    return result.stdout.split("\n")


def is_heading(line):
    line = line.strip()
    if not line:
        return True
    if re.fullmatch(r"\d{1,3}", line):
        return True
    if ROMAN_HEADING.match(line) or NAMED_HEADING.match(line):
        return True
    letters = re.sub(r"[^A-Za-zÀ-ÿ]", "", line)
    return len(letters) >= 4 and letters.isupper()


def clean_paragraph_lines(lines):
    cleaned = []
    for raw_line in lines:
        line = raw_line.replace("\f", " ").strip()
        if not is_heading(line):
            cleaned.append(line)

    # Short section headings are set as their own final line before the next
    # numbered paragraph in this edition; remove only title-like trailing lines.
    while len(cleaned) > 1:
        line = cleaned[-1]
        title_like = (
            len(line) <= 100
            and len(line.split()) <= 10
            and re.match(r"^[A-ZÁÉÍÓÚÂÊÔÃÕÇ]", line)
            and not re.search(r"[.!?;»”)]$", line)
            and not any(quote in line for quote in ('"', "“", "”", "«", "»"))
            and "Summa Theologica" not in line
        )
        if not title_like:
            break
        cleaned.pop()

    joined = ""
    for line in cleaned:
        if not joined:
            joined = line
        elif joined.endswith("-") and line[:1].islower():
            joined += line
        else:
            joined += " " + line
    joined = re.sub(r"\s+", " ", joined).strip()
    joined = re.sub(r"\s+([,.;:!?»])", r"\1", joined)
    joined = re.sub(r"([«(])\s+", r"\1", joined)
    return re.sub(r"\s+([)])", r"\1", joined)


def extract_paragraphs(pdf_path):
    lines = run_pdftotext(pdf_path)
    markers = []
    expected = 1
    started = False

    for index, raw_line in enumerate(lines):
        match = PARAGRAPH_MARKER.match(raw_line.replace("\f", " "))
        if not match:
            continue
        number = int(match.group(1))
        text = match.group(2).strip()
        if not started:
            if number == 1 and text.startswith("Deus, infinitamente"):
                started = True
            else:
                continue
        if number == expected:
            markers.append((number, index, text))
            expected += 1
            if number == 2865:
                break

    if expected != 2866 or len(markers) != 2865:
        raise RuntimeError(
            f"PDF coverage invalid: extracted {len(markers)} sequential paragraphs; "
            f"next expected §{expected}"
        )

    contents_start = next(
        (index for index in range(markers[-1][1] + 1, len(lines)) if "Índice Geral" in lines[index]),
        None,
    )
    if contents_start is None:
        raise RuntimeError("Could not locate the table of contents after §2865")

    paragraphs = {}
    for position, (number, index, initial_text) in enumerate(markers):
        end = markers[position + 1][1] if position + 1 < len(markers) else contents_start
        body = clean_paragraph_lines([initial_text, *lines[index + 1:end]])
        if not body:
            raise RuntimeError(f"Empty text in §{number}")
        paragraphs[number] = f"{number}. {body}"

    if set(paragraphs) != EXPECTED_SECTIONS:
        raise RuntimeError("PDF paragraph coverage is not exactly §§1–2865")
    return paragraphs


def build(pdf_path):
    paragraphs = extract_paragraphs(pdf_path)
    OUT_ANDROID.mkdir(parents=True, exist_ok=True)
    OUT_IOS.mkdir(parents=True, exist_ok=True)

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
            "category": "Catecismo",
            "status": "catecismo",
            "description": work["description"],
            "context": work["context"],
            "characters": work["characters"],
            "sourceUrl": work["sourceUrl"],
            "copyright": "Catecismo da Igreja Católica. Edição em português reproduzida no PDF da Diocese de Miracema.",
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
            "category": "Catecismo",
            "status": "catecismo",
            "description": work["description"],
            "context": work["context"],
            "characters": work["characters"],
            "chapters": len(chapters),
            "words": words,
            "sourceUrl": work["sourceUrl"],
        })
    index_path.write_text(json.dumps(guias + catalog, ensure_ascii=False, indent=1), encoding="utf-8")
    print(f"TOTAL palavras CIC (2.865 parágrafos): {total_words}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("pdf", type=Path, help="PDF português do Catecismo da Diocese de Miracema")
    args = parser.parse_args()
    if not args.pdf.is_file():
        parser.error(f"PDF not found: {args.pdf}")
    build(args.pdf)
