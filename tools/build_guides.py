#!/usr/bin/env python3
"""Build expanded authored guides from the 1.1.1 baseline and reviewed additions."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
IOS_TEXTS = ROOT / "iosApp/Resources/Texts"
ANDROID_TEXTS = ROOT / "app/src/main/assets/texts"
BASE_TEXTS = ROOT / "tools/authorial_base"
SOURCE = ROOT / "tools/guides_content.json"


def build():
    additions = json.loads(SOURCE.read_text(encoding="utf-8"))
    BASE_TEXTS.mkdir(parents=True, exist_ok=True)

    # Freeze the source guide shape once, before replacing any bundled assets.
    for guide_id in additions:
        base = BASE_TEXTS / f"{guide_id}.json"
        if not base.exists():
            source = IOS_TEXTS / f"{guide_id}.json"
            if not source.is_file():
                raise FileNotFoundError(source)
            base.write_text(source.read_text(encoding="utf-8"), encoding="utf-8")

    index_rows = []
    for guide_id, chapters_to_add in additions.items():
        document = json.loads((BASE_TEXTS / f"{guide_id}.json").read_text(encoding="utf-8"))
        if len(document["chapters"]) != 2:
            raise ValueError(f"{guide_id}: base asset should have its original two chapters")
        document["chapters"].extend(chapters_to_add)
        if len(document["chapters"]) != 6:
            raise ValueError(f"{guide_id}: expected six chapters after expansion")
        for chapter in document["chapters"]:
            if not chapter["title"].strip() or len(chapter["paragraphs"]) < 3:
                raise ValueError(f"{guide_id}: incomplete chapter {chapter['title']}")

        encoded = json.dumps(document, ensure_ascii=False, separators=(",", ":"))
        (IOS_TEXTS / f"{guide_id}.json").write_text(encoded, encoding="utf-8")
        (ANDROID_TEXTS / f"{guide_id}.json").write_text(encoded, encoding="utf-8")
        word_count = sum(len(paragraph.split()) for chapter in document["chapters"] for paragraph in chapter["paragraphs"])
        index_rows.append({
            "id": guide_id,
            "title": document["title"],
            "author": document["author"],
            "year": document["year"],
            "category": document["category"],
            "description": document["description"],
            "context": document["context"],
            "characters": document.get("characters", []),
            "sourceUrl": document["sourceUrl"],
            "chapters": len(document["chapters"]),
            "words": word_count,
            "status": "guia",
        })
        print(f"{guide_id}: {len(document['chapters'])} seções, {word_count} palavras")

    index_path = ANDROID_TEXTS / "index.json"
    existing = json.loads(index_path.read_text(encoding="utf-8"))
    catecismo = [item for item in existing if item.get("status") == "catecismo"]
    complete_index = index_rows + catecismo
    index_path.write_text(json.dumps(complete_index, ensure_ascii=False, indent=1), encoding="utf-8")

    catalog = []
    for item in complete_index:
        catalog.append({
            "id": item["id"],
            "title": item["title"],
            "category": item["category"],
            "description": item.get("description", ""),
            "chapters": item["chapters"],
            "status": item.get("status", "guia"),
        })
    (ROOT / "iosApp/Resources/catalog.json").write_text(
        json.dumps(catalog, ensure_ascii=False, indent=2), encoding="utf-8"
    )


if __name__ == "__main__":
    build()
