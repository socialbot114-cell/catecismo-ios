#!/usr/bin/env python3
import json
import struct
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
spec = (root / "project.yml").read_text()
assert "br.com.CATECISMO.DAIGREJACAToLICA" in spec
assert 'MARKETING_VERSION: "1.1"' in spec
assert 'CURRENT_PROJECT_VERSION: "14"' in spec

icons = root / "Resources/Assets.xcassets/AppIcon.appiconset"
icon_catalog = json.loads((icons / "Contents.json").read_text(encoding="utf-8"))
for entry in icon_catalog["images"]:
    icon = icons / entry["filename"]
    assert icon.is_file(), icon
    with icon.open("rb") as image:
        header = image.read(24)
    assert header[:8] == b"\x89PNG\r\n\x1a\n", icon
    width, height = struct.unpack(">II", header[16:24])
    expected_size = entry["size"].split("x")
    scale = int(entry["scale"].removesuffix("x"))
    assert (width, height) == (round(float(expected_size[0]) * scale), round(float(expected_size[1]) * scale)), icon

images = root / "Resources/Images"
expected_images = {
    "component-book.png",
    "component-library.png",
    "component-cross.png",
    "component-rosary.png",
    "component-dove.png",
    "component-church.png",
}
image_files = {path.name: path for path in images.glob("*.png")}
assert set(image_files) == expected_images, set(image_files)
assert all(path.stat().st_size < 250_000 for path in image_files.values())
assert sum(path.stat().st_size for path in image_files.values()) < 1_000_000

print(f"iOS resources OK: eight guides, version 1.1 (14), AppIcon catalog, {sum(path.stat().st_size for path in image_files.values()):,} optimized illustration bytes")
