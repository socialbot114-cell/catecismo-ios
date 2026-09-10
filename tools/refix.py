#!/usr/bin/env python3
"""Refaz apenas obras específicas do WORKS e atualiza index.json.gzdata."""
import json, sys, urllib.parse
sys.path.insert(0, "tools")
import fetch_machado as fm

ONLY = set(sys.argv[1:])
assert ONLY, "informe ids: python3 tools/refix.py ressurreicao mao-e-luva ..."

targets = [w for w in fm.WORKS if w[0] in ONLY]
assert len(targets) == len(ONLY), f"ids desconhecidos: {ONLY - {w[0] for w in targets}}"

index = json.loads(fm.gzip.open(fm.OUT / "index.json.gzdata", "rt", encoding="utf-8").read())
by_id = {m["id"]: m for m in index}

for (wid, title, year, cat, page, prefix, desc, ctx, chars) in targets:
    print(f"== {title}", file=sys.stderr, flush=True)
    if prefix:
        subs = fm.subpages(prefix)
        subs = [s for s in subs if not s.endswith(("/Índice", "/Capa", "/Nota"))]
        chapters = fm.fetch_chapters(subs)
    else:
        chapters = fm.fetch_single(page)
    if not chapters:
        print(f"  ERRO {title}: nenhum capítulo", file=sys.stderr)
        continue
    words = sum(len(p.split()) for c in chapters for p in c["paragraphs"])
    data = {"id": wid, "title": title, "author": "Machado de Assis", "year": year,
            "category": cat, "status": "integral", "sourceUrl": f"https://pt.wikisource.org/wiki/{urllib.parse.quote(page)}",
            "description": desc, "context": ctx, "characters": chars, "chapters": chapters}
    with fm.gzip.open(fm.OUT / f"{wid}.json.gzdata", "wt", encoding="utf-8", compresslevel=9) as f:
        json.dump(data, f, ensure_ascii=False, separators=(",", ":"))
    meta = {"id": wid, "title": title, "year": year, "category": cat, "description": desc,
            "context": ctx, "characters": chars, "status": "integral", "sourceUrl": data["sourceUrl"],
            "chapters": len(chapters), "words": words}
    if wid in by_id:
        index = [meta if m["id"] == wid else m for m in index]
    else:
        index.append(meta)
    print(f"  -> {wid}: {len(chapters)} caps, {words} palavras", file=sys.stderr, flush=True)

with fm.gzip.open(fm.OUT / "index.json.gzdata", "wt", encoding="utf-8", compresslevel=9) as f:
    json.dump(index, f, ensure_ascii=False, separators=(",", ":"))
print(f"index: {len(index)} obras", file=sys.stderr)
