#!/usr/bin/env python3
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "iosApp"
catalog = json.loads((root / "Resources/catalog.json").read_text(encoding="utf-8"))
ids = {item["id"] for item in catalog}
assert len(catalog) == 12 and len(ids) == 12
assert {path.stem for path in (root / "Resources/Texts").glob("*.json")} == ids
for item in catalog:
    document = json.loads((root / "Resources/Texts" / f"{item['id']}.json").read_text(encoding="utf-8"))
    assert document["id"] == item["id"] and len(document["chapters"]) == item["chapters"]
    assert all(chapter["title"].strip() and chapter["paragraphs"] for chapter in document["chapters"])
document = json.loads((root / "Resources/Texts/catecismo-parte-1.json").read_text(encoding="utf-8"))
assert document["status"] == "catecismo" and document["author"] == "Catecismo da Igreja Católica"
assert document["chapters"][0]["paragraphs"][0].startswith("1. Deus")
for path in [root / "Info.plist", root / "ExportOptions.plist", root / "Resources/PrivacyInfo.xcprivacy"]:
    assert path.is_file(), path
assert "br.com.CATECISMO.DAIGREJACAToLICA" in (root / "project.yml").read_text()
print("iOS resources OK: 12 obras locais (4 partes do Catecismo + 8 guias)")
