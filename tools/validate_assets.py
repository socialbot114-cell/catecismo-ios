#!/usr/bin/env python3
"""Validador dos assets de texto e gerador de RELATORIO_CONTEUDO.md."""
import gzip
import json
import sys
from pathlib import Path

OUT = Path(__file__).resolve().parent.parent / "app/src/main/assets/texts"
EXPECTED = {
    "dom", "brascubas", "quincas", "helena", "iaia", "esau", "memorial",
    "casa-velha", "ressurreicao", "mao-e-luva",
    "alienista", "cartomante", "espelho", "pai-contra-mae", "teoria-medalhao",
    "causa-secreta", "homem-celebre", "uns-bracos", "igreja-do-diabo",
    "noite-de-almirante", "enfermeiro", "miss-dollar", "capitulo-dos-chapeus",
    "segredo-do-bonzo", "serenissima-republica", "conego", "entre-santos",
    "dona-benedita", "o-lapso", "cantiga-de-esponsais",
}

def load(path: Path) -> str:
    with gzip.open(path, "rt", encoding="utf-8") as f:
        return f.read()

def main() -> int:
    errors, rows = [], []
    files = {p.name.removesuffix(".json.gzdata"): p for p in OUT.glob("*.json.gzdata")}
    if "index" not in files:
        print("ERRO: index.json.gzdata ausente"); return 1
    try:
        index = json.loads(load(files["index"]))
    except Exception as e:
        print(f"ERRO: index corrompido: {e}"); return 1

    ids = [m["id"] for m in index]
    id_set = set(ids)
    if len(ids) != len(id_set):
        dupes = sorted({i for i in ids if ids.count(i) > 1})
        errors.append(f"ids duplicados no index: {dupes}")
    missing_assets = id_set - set(files)
    extra_assets = set(files) - id_set - {"index"}
    if missing_assets: errors.append(f"index sem asset: {sorted(missing_assets)}")
    if extra_assets: errors.append(f"asset sem entrada no index: {sorted(extra_assets)}")
    if id_set != EXPECTED:
        missing_expected = EXPECTED - id_set
        unexpected = id_set - EXPECTED
        if missing_expected: errors.append(f"obras esperadas ausentes: {sorted(missing_expected)}")
        if unexpected: errors.append(f"obras inesperadas no index: {sorted(unexpected)}")
    if len(index) != 30:
        errors.append(f"index tem {len(index)} obras, esperado 30")

    total_words = 0
    for meta in index:
        wid = meta["id"]
        try:
            work = json.loads(load(files[wid]))
        except Exception as e:
            errors.append(f"{wid}: JSON corrompido: {e}"); continue
        chapters = work.get("chapters", [])
        words = sum(len(p.split()) for c in chapters for p in c["paragraphs"])
        total_words += words
        if not work.get("title"): errors.append(f"{wid}: sem título")
        if work.get("author") != "Machado de Assis": errors.append(f"{wid}: autor inválido")
        if not (1839 <= work.get("year", 0) <= 1908): errors.append(f"{wid}: ano inválido")
        if work.get("category") not in ("Romance", "Conto"): errors.append(f"{wid}: categoria inválida")
        if not work.get("sourceUrl", "").startswith("https://pt.wikisource.org/"): errors.append(f"{wid}: fonte inválida")
        if work.get("status") != "integral": errors.append(f"{wid}: status != integral")
        if not chapters: errors.append(f"{wid}: sem capítulos")
        if meta.get("chapters") != len(chapters): errors.append(f"{wid}: contagem de capítulos divergente do index")
        if meta.get("words") != words: errors.append(f"{wid}: contagem de palavras divergente do index")
        empty = [ci for ci, c in enumerate(chapters) if not c["paragraphs"] or not c["title"].strip()]
        if empty: errors.append(f"{wid}: capítulos vazios {empty[:5]}")
        html = [ci for ci, c in enumerate(chapters) for p in c["paragraphs"] if "<p>" in p or "</div>" in p or "mw-" in p]
        if html: errors.append(f"{wid}: HTML residual nos capítulos {html[:5]}")
        rows.append((work.get("category", "?"), work.get("title", wid), wid, len(chapters), words))

    rows.sort(key=lambda r: (r[0], r[1]))
    romances = [r for r in rows if r[0] == "Romance"]
    contos = [r for r in rows if r[0] == "Conto"]

    lines = [
        "# Relatório de Conteúdo — Machado de Assis | Biblioteca",
        "",
        f"Gerado automaticamente por `tools/validate_assets.py`.",
        "",
        f"- **Obras:** {len(rows)} ({len(romances)} romances, {len(contos)} contos)",
        f"- **Palavras totais:** {total_words:,}".replace(",", "."),
        f"- **Fonte:** Wikisource PT (domínio público; transcrições CC BY-SA)",
        f"- **Adaptação:** modernização ortográfica conservadora declarada",
        "",
        "## Romances", "",
        "| Obra | ID | Capítulos | Palavras |", "|---|---|---|---|",
    ]
    for cat, title, wid, ch, words in romances:
        lines.append(f"| {title} | `{wid}` | {ch} | {words:,} |".replace(",", "."))
    lines += ["", "## Contos", "", "| Conto | ID | Capítulos | Palavras |", "|---|---|---|---|"]
    for cat, title, wid, ch, words in contos:
        lines.append(f"| {title} | `{wid}` | {ch} | {words:,} |".replace(",", "."))

    lines += ["", "## Validação", ""]
    if errors:
        lines.append("**FALHAS:**")
        lines += [f"- {e}" for e in errors]
    else:
        lines.append("Todas as verificações passaram: 30 obras, assets íntegros, sem HTML residual, contagens consistentes.")
    lines.append("")

    report = Path(__file__).resolve().parent.parent / "RELATORIO_CONTEUDO.md"
    report.write_text("\n".join(lines), encoding="utf-8")

    print(f"Obras: {len(rows)} | Palavras: {total_words}")
    for e in errors: print(f"ERRO: {e}")
    return 1 if errors else 0

if __name__ == "__main__":
    sys.exit(main())
