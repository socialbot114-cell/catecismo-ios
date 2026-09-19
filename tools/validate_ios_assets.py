#!/usr/bin/env python3
import json
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "iosApp"
catalog = json.loads((root / "Resources/catalog.json").read_text(encoding="utf-8"))
assert len(catalog) == 8 and len({item["id"] for item in catalog}) == 8
assert {item["id"] for item in catalog} == {path.stem for path in (root / "Resources/Texts").glob("*.json")}
for item in catalog:
    document = json.loads((root / "Resources/Texts" / f"{item['id']}.json").read_text(encoding="utf-8"))
    assert document["id"] == item["id"] and len(document["chapters"]) == item["chapters"]
    assert all(chapter["title"].strip() and chapter["paragraphs"] for chapter in document["chapters"])
for path in [root / "Info.plist", root / "ExportOptions.plist", root / "Resources/PrivacyInfo.xcprivacy"]:
    assert path.is_file(), path
assert "br.com.CATECISMO.DAIGREJACAToLICA" in (root / "project.yml").read_text()
print("iOS resources OK: eight local Catecismo guides and plist files")
