#!/usr/bin/env python3
"""Guias autorais do Catecismo — 8 guias completos (6 seções cada).

Gera app/src/main/assets/texts/<id>.json (status "guia") e preserva no index.json
as quatro entradas do Catecismo integral (status "catecismo") geradas por
tools/fetch_catecismo.py. Copia os guias para iosApp/Resources/Texts.
"""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
OUT_ANDROID = ROOT / "app" / "src" / "main" / "assets" / "texts"
OUT_IOS = ROOT / "iosApp" / "Resources" / "Texts"
SOURCE_URL = "https://www.vatican.va/archive/cathechism_po/index_new/prima-pagina-cic_po.html"

CONTENT = json.loads((ROOT / "tools" / "guides_content.json").read_text(encoding="utf-8"))


def build():
    index_path = OUT_ANDROID / "index.json"
    existing = json.loads(index_path.read_text(encoding="utf-8"))
    cic = [item for item in existing if item.get("status") == "catecismo"]
    index_rows = []
    for gid, meta in CONTENT.items():
        doc = {
            "id": gid,
            "title": meta["title"],
            "author": "Equipe Catecismo",
            "year": 2026,
            "category": meta["category"],
            "status": "guia",
            "description": meta["description"],
            "context": meta["context"],
            "characters": meta["characters"],
            "sourceUrl": SOURCE_URL,
            "chapters": [
                {"title": chapter["title"], "paragraphs": chapter["paragraphs"]}
                for chapter in meta["chapters"]
            ],
        }
        OUT_IOS.mkdir(parents=True, exist_ok=True)
        (OUT_ANDROID / f"{gid}.json").write_text(json.dumps(doc, ensure_ascii=False), encoding="utf-8")
        (OUT_IOS / f"{gid}.json").write_text(json.dumps(doc, ensure_ascii=False), encoding="utf-8")
        words = sum(len(par.split()) for chapter in doc["chapters"] for par in chapter["paragraphs"])
        index_rows.append({
            "id": gid,
            "title": meta["title"],
            "year": 2026,
            "category": meta["category"],
            "chapters": len(doc["chapters"]),
            "words": words,
            "status": "guia",
        })
        print(f"{gid}: {len(doc['chapters'])}capitulos, {words} palavras")
    index_path.write_text(json.dumps(index_rows + cic, ensure_ascii=False, indent=1), encoding="utf-8")


if __name__ == "__main__":
    build()
