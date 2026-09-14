#!/usr/bin/env python3
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "iosApp" / "Resources"
catalog_path = root / "catalog.json"
entries = json.loads(catalog_path.read_text(encoding="utf-8"))
assert isinstance(entries, list) and len(entries) == 30, "catalog.json deve conter exatamente 30 obras"
ids = [entry["id"] for entry in entries]
assert len(set(ids)) == 30, "IDs duplicados no catalog.json"
for entry in entries:
    for key in ("id", "title", "description", "sourceUrl", "chapters", "words"):
        assert entry.get(key), f"campo ausente em {entry.get('id', '<sem id>')}: {key}"
    path = root / "Texts" / f"{entry['id']}.json"
    assert path.is_file(), f"texto ausente: {path.name}"
    document = json.loads(path.read_text(encoding="utf-8"))
    chapters = document.get("chapters")
    assert isinstance(chapters, list) and chapters, f"capítulos inválidos: {path.name}"
    assert len(chapters) == entry["chapters"], f"contagem de capítulos divergente: {path.name}"
    for chapter in chapters:
        assert isinstance(chapter.get("title"), str) and chapter["title"].strip()
        assert isinstance(chapter.get("paragraphs"), list) and chapter["paragraphs"]
        assert all(isinstance(text, str) and text.strip() for text in chapter["paragraphs"])
text_files = {path.stem for path in (root / "Texts").glob("*.json") if path.name != "index.json"}
assert text_files == set(ids), "arquivos de texto não correspondem ao catálogo"
print(f"iOS assets OK: {len(entries)} obras, {len(text_files)} textos decodificados")
