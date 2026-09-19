#!/usr/bin/env python3
"""Validate the Catecismo offline guides and generate the content report."""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "app/src/main/assets/texts"
REPORT = ROOT / "RELATORIO_CONTEUDO.md"


def fail(message):
    raise AssertionError(message)


def main():
    index_path = OUT / "index.json"
    if not index_path.is_file():
        print("ERRO: texts/index.json ausente")
        return 1

    try:
        index = json.loads(index_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as error:
        print(f"ERRO: index inválido: {error}")
        return 1

    errors = []
    rows = []
    if not isinstance(index, list) or not index:
        errors.append("index deve ser uma lista não vazia")
        index = []

    seen_ids = set()
    for entry in index:
        try:
            work_id = entry["id"]
            if work_id in seen_ids:
                fail(f"id duplicado: {work_id}")
            seen_ids.add(work_id)
            path = OUT / f"{work_id}.json"
            if not path.is_file():
                fail(f"asset ausente: {path.name}")
            work = json.loads(path.read_text(encoding="utf-8"))
            chapters = work.get("chapters", [])
            words = sum(len(paragraph.split()) for chapter in chapters for paragraph in chapter.get("paragraphs", []))
            if work.get("id") != work_id:
                fail(f"{work_id}: id divergente")
            if work.get("author") != "Equipe Catecismo":
                fail(f"{work_id}: autor inválido")
            if work.get("status") != "guia":
                fail(f"{work_id}: status inválido")
            if not work.get("sourceUrl", "").startswith("https://"):
                fail(f"{work_id}: sourceUrl inválida")
            if not chapters or any(not chapter.get("title") or not chapter.get("paragraphs") for chapter in chapters):
                fail(f"{work_id}: capítulo vazio")
            if entry.get("chapters") != len(chapters):
                fail(f"{work_id}: contagem de capítulos divergente")
            if entry.get("words") != words:
                fail(f"{work_id}: contagem de palavras divergente")
            rows.append((work.get("category", ""), work.get("title", work_id), work_id, len(chapters), words))
        except (AssertionError, KeyError, json.JSONDecodeError) as error:
            errors.append(str(error))

    indexed = {entry.get("id") for entry in index if isinstance(entry, dict)}
    assets = {path.stem for path in OUT.glob("*.json") if path.name != "index.json"}
    for missing in sorted(indexed - assets):
        errors.append(f"asset não encontrado no diretório: {missing}")
    for extra in sorted(assets - indexed):
        errors.append(f"asset não listado no index: {extra}")

    rows.sort(key=lambda row: (row[0], row[1]))
    report = [
        "# Relatório de Conteúdo — Catecismo",
        "",
        "Gerado automaticamente por `tools/validate_assets.py`.",
        "",
        f"- **Guias:** {len(rows)}",
        f"- **Capítulos:** {sum(row[3] for row in rows)}",
        f"- **Palavras:** {sum(row[4] for row in rows)}",
        "- **Fonte:** conteúdo autoral com referências públicas documentadas",
        "",
        "| Guia | ID | Capítulos | Palavras |",
        "|---|---|---:|---:|",
    ]
    report.extend(f"| {title} | `{work_id}` | {chapters} | {words} |" for _, title, work_id, chapters, words in rows)
    report.extend(["", "## Validação", ""])
    report.append("Todas as verificações passaram." if not errors else "**FALHAS:**")
    report.extend(f"- {error}" for error in errors)
    REPORT.write_text("\n".join(report) + "\n", encoding="utf-8")

    if errors:
        for error in errors:
            print(f"ERRO: {error}")
        return 1
    print(f"Guias: {len(rows)} | Capítulos: {sum(row[3] for row in rows)} | Palavras: {sum(row[4] for row in rows)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
