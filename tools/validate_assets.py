#!/usr/bin/env python3
"""Valida guias autorais e os assets do Catecismo, gera o relatório."""
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "app/src/main/assets/texts"
REPORT = ROOT / "RELATORIO_CONTEUDO.md"

EXPECTED_CATECHISM_SECTIONS = set(range(1, 2866))


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
    covered = set()
    if not isinstance(index, list) or not index:
        errors.append("index deve ser uma lista não vazia")
        index = []

    seen_ids = set()
    for entry in index:
        try:
            work_id = entry["id"]
            if work_id in seen_ids:
                raise AssertionError(f"id duplicado: {work_id}")
            seen_ids.add(work_id)
            path = OUT / f"{work_id}.json"
            if not path.is_file():
                raise AssertionError(f"asset ausente: {path.name}")
            work = json.loads(path.read_text(encoding="utf-8"))
            chapters = work.get("chapters", [])
            words = sum(len(paragraph.split()) for chapter in chapters for paragraph in chapter.get("paragraphs", []))
            if work.get("id") != work_id:
                raise AssertionError(f"{work_id}: id divergente")
            status = work.get("status")
            if status == "guia":
                if work.get("author") != "Equipe Catecismo":
                    raise AssertionError(f"{work_id}: autor inválido")
                if entry.get("year") != 2026:
                    raise AssertionError(f"{work_id}: ano inválido")
                if len(chapters) != 6:
                    raise AssertionError(f"{work_id}: esperado 6 capítulos autorais")
                if words < 350:
                    raise AssertionError(f"{work_id}: guia autoral não foi ampliado ({words} palavras)")
            elif status == "catecismo":
                if work.get("author") != "Catecismo da Igreja Católica":
                    raise AssertionError(f"{work_id}: autor inválido")
                if entry.get("year") != 1997:
                    raise AssertionError(f"{work_id}: ano inválido")
                if work.get("category") != "Catecismo":
                    raise AssertionError(f"{work_id}: categoria inválida")
            else:
                raise AssertionError(f"{work_id}: status inválido")
            if not work.get("sourceUrl", "").startswith("https://"):
                raise AssertionError(f"{work_id}: sourceUrl inválida")
            if not chapters or any(not chapter.get("title") or not chapter.get("paragraphs") for chapter in chapters):
                raise AssertionError(f"{work_id}: capítulo vazio")
            if entry.get("chapters") != len(chapters):
                raise AssertionError(f"{work_id}: contagem de capítulos divergente")
            if entry.get("words") != words:
                raise AssertionError(f"{work_id}: contagem de palavras divergente")
            for chapter in chapters:
                if status == "catecismo":
                    for paragraph in chapter["paragraphs"]:
                        match = re.match(r"^(\d{1,4})(?:\.|\s)", paragraph)
                        if not match:
                            raise AssertionError(f"{work_id}: parágrafo sem número §: {paragraph[:60]}")
                        number = int(match.group(1))
                        if number in covered:
                            raise AssertionError(f"§{number} duplicado no conteúdo embarcado")
                        covered.add(number)
            rows.append((work.get("category", ""), work.get("title", work_id), work_id, len(chapters), words))
        except (AssertionError, KeyError, json.JSONDecodeError) as error:
            errors.append(str(error))

    catechism_work_ids = {entry.get("id") for entry in index if entry.get("status") == "catecismo"}
    if catechism_work_ids != {f"catecismo-parte-{part}" for part in range(1, 5)}:
        errors.append("o catálogo deve conter as quatro partes do Catecismo")
    if covered:
        missing = sorted(EXPECTED_CATECHISM_SECTIONS - covered)
        if missing:
            errors.append(f"§§ ausentes nos assets do Catecismo: {missing[:12]}")
        unexpected = sorted(covered - EXPECTED_CATECHISM_SECTIONS)
        if unexpected:
            errors.append(f"numeração § fora do intervalo 1–2865: {unexpected[:12]}")
        if covered != EXPECTED_CATECHISM_SECTIONS:
            errors.append("a edição deve conter todos os parágrafos §§1–2865, sem duplicatas ou lacunas")

    indexed = {entry.get("id") for entry in index if isinstance(entry, dict)}
    assets = {path.stem for path in OUT.glob("*.json") if path.name != "index.json"}
    for missing_asset in sorted(indexed - assets):
        errors.append(f"asset não encontrado no diretório: {missing_asset}")
    for extra_asset in sorted(assets - indexed):
        errors.append(f"asset não listado no index: {extra_asset}")

    rows.sort(key=lambda row: (row[0], row[1]))
    report = [
        "# Relatório de Conteúdo — Catecismo",
        "",
        "Gerado automaticamente por `tools/validate_assets.py`.",
        "",
        f"- **Obras:** {len(rows)}",
        f"- **Seções:** {sum(row[3] for row in rows)}",
        f"- **Palavras:** {sum(row[4] for row in rows):,}".replace(",", "."),
        "- **Fontes:** guias autorais (Equipe Catecismo) + edição em português do Catecismo transcrita do PDF da Diocese de Miracema.",
        "- **Cobertura:** todos os 2.865 parágrafos (§§1–2865) estão incluídos, inclusive §§2217 e 2439.",
        "",
        "| Obra | ID | Seções | Palavras |",
        "|---|---|---:|---:|",
    ]
    report.extend(f"| {title} | `{work_id}` | {chapters} | {words:,} |".replace(",", ".") for _, title, work_id, chapters, words in rows)
    report.extend(["", "## Validação", ""])
    report.append("Todas as verificações passaram." if not errors else "**FALHAS:**")
    report.extend(f"- {error}" for error in errors)
    REPORT.write_text("\n".join(report) + "\n", encoding="utf-8")

    if errors:
        for error in errors:
            print(f"ERRO: {error}")
        return 1
    print(f"Obras: {len(rows)} | Seções: {sum(row[3] for row in rows)} | Palavras: {sum(row[4] for row in rows):,}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
