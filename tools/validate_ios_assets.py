#!/usr/bin/env python3
import json
import re
from pathlib import Path

root = Path(__file__).resolve().parents[1] / "iosApp"
catalog = json.loads((root / "Resources/catalog.json").read_text(encoding="utf-8"))
ids = {item["id"] for item in catalog}
assert len(catalog) == 12 and len(ids) == 12
catechism_ids = {"catecismo-parte-1", "catecismo-parte-2", "catecismo-parte-3", "catecismo-parte-4"}
assert {item["id"] for item in catalog if item.get("status") == "catecismo"} == catechism_ids
assert {path.stem for path in (root / "Resources/Texts").glob("*.json")} == ids
catechism_sections = []
for item in catalog:
    document = json.loads((root / "Resources/Texts" / f"{item['id']}.json").read_text(encoding="utf-8"))
    assert document["id"] == item["id"] and len(document["chapters"]) == item["chapters"]
    assert all(chapter["title"].strip() and chapter["paragraphs"] for chapter in document["chapters"])
    android_copy = root.parent / "app/src/main/assets/texts" / f"{item['id']}.json"
    assert json.loads(android_copy.read_text(encoding="utf-8")) == document, f"asset drift: {item['id']}"
    if item.get("status") == "guia":
        assert len(document["chapters"]) == 6
        assert sum(len(p.split()) for c in document["chapters"] for p in c["paragraphs"]) >= 350
    if item.get("status") == "catecismo":
        assert document["category"] == "Catecismo"
        assert "diocesedemiracemato.org.br/upload/arquivos/214.pdf" in document["sourceUrl"]
        for chapter in document["chapters"]:
            for paragraph in chapter["paragraphs"]:
                match = re.match(r"^(\d{1,4})\.", paragraph)
                assert match, f"unnumbered Catechism paragraph: {item['id']}"
                catechism_sections.append(int(match.group(1)))
assert catechism_sections == list(range(1, 2866))
document = json.loads((root / "Resources/Texts/catecismo-parte-1.json").read_text(encoding="utf-8"))
assert document["status"] == "catecismo" and document["author"] == "Catecismo da Igreja Católica"
assert document["chapters"][0]["paragraphs"][0].startswith("1. Deus")
for language in ("en", "es", "fr"):
    localized = json.loads((root.parent / "app/src/main/assets/texts/locales" / f"{language}.json").read_text(encoding="utf-8"))
    assert len(localized) == 8 and len({item["id"] for item in localized}) == 8
project = (root / "project.yml").read_text(encoding="utf-8")
for resource in ("Localizable.xcstrings", "catecismo-parte-1.json", "catecismo-parte-2.json", "catecismo-parte-3.json", "catecismo-parte-4.json"):
    assert resource in project, f"resource missing from project.yml: {resource}"
for language in ("en", "es", "fr"):
    assert f"locales/{language}.json" in project
for path in [root / "Info.plist", root / "ExportOptions.plist", root / "Resources/PrivacyInfo.xcprivacy"]:
    assert path.is_file(), path
json.loads((root / "Resources/Localizable.xcstrings").read_text(encoding="utf-8"))
for language in ("en", "es", "fr"):
    assert (root.parent / "app/src/main/assets/texts/locales" / f"{language}.json").is_file()
assert "br.com.CATECISMO.DAIGREJACAToLICA" in (root / "project.yml").read_text()
project = (root / "project.yml").read_text(encoding="utf-8")
assert project.count("developmentLanguage:") == 1
assert 'MARKETING_VERSION: "1.2.2"' in project
for resource in ("catecismo-parte-1.json", "catecismo-parte-2.json", "catecismo-parte-3.json", "catecismo-parte-4.json"):
    assert resource in project
for item_id in ids:
    assert f"Resources/Texts/{item_id}.json" in project, f"resource not bundled by XcodeGen: {item_id}"
for source in (root / "Sources").glob("*.swift"):
    text = source.read_text(encoding="utf-8")
    assert "Link(destination:" not in text, f"runtime external link found: {source.name}"
    assert "UIApplication.shared.open" not in text, f"runtime URL launch found: {source.name}"
print("iOS resources OK: 12 obras locais (4 partes do Catecismo + 8 guias)")
