#!/usr/bin/env python3
"""Walk blog/posts/, parse frontmatter, write blog/posts.json.

Triggered by the .github/workflows/blog-index.yml workflow on every push that
touches blog/posts/**. Local equivalent: python scripts/build_blog_index.py
"""
from __future__ import annotations

import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POSTS_DIR = ROOT / "blog" / "posts"
INDEX_FILE = ROOT / "blog" / "posts.json"


def parse_frontmatter(text: str) -> tuple[dict, str]:
    m = re.match(r"^---\n([\s\S]*?)\n---\n?", text)
    if not m:
        return {}, text
    data: dict = {}
    for line in m.group(1).splitlines():
        kv = re.match(r"^([A-Za-z0-9_-]+):\s*(.*)$", line)
        if not kv:
            continue
        k, v = kv.group(1), kv.group(2).strip()
        if v.startswith("[") and v.endswith("]"):
            v = [s.strip().strip("'\"") for s in v[1:-1].split(",") if s.strip()]
        elif (v.startswith('"') and v.endswith('"')) or (v.startswith("'") and v.endswith("'")):
            v = v[1:-1]
        data[k] = v
    return data, text[m.end():]


def excerpt_from(body: str, n: int = 240) -> str:
    text = re.sub(r"!\[[^\]]*\]\([^)]*\)", "", body)
    text = re.sub(r"\[\[([^\]|]+)(?:\|([^\]]+))?\]\]", lambda m: m.group(2) or m.group(1), text)
    text = re.sub(r"`[^`]*`", "", text)
    text = re.sub(r"[#*_>]+", "", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text[:n] + ("..." if len(text) > n else "")


def collect() -> list[dict]:
    if not POSTS_DIR.exists():
        return []
    posts: list[dict] = []
    # Two layouts supported:
    #   posts/<slug>/index.md         (preferred, allows colocated images)
    #   posts/<slug>.md               (also fine)
    for md in sorted(POSTS_DIR.rglob("*.md")):
        rel = md.relative_to(ROOT).as_posix()
        try:
            text = md.read_text(encoding="utf-8")
        except Exception:
            continue
        data, body = parse_frontmatter(text)
        if md.name == "index.md":
            slug = md.parent.name
        else:
            slug = md.stem
        title = data.get("title") or slug.replace("_", " ").replace("-", " ").title()
        date = data.get("date") or ""
        tags = data.get("tags") or []
        if isinstance(tags, str):
            tags = [t.strip() for t in tags.split(",") if t.strip()]
        excerpt = data.get("excerpt") or excerpt_from(body)
        posts.append(
            {
                "slug": slug,
                "title": title,
                "date": str(date),
                "tags": tags,
                "excerpt": excerpt,
                "path": rel.split("/", 1)[1] if rel.startswith("blog/") else rel,
            }
        )
    posts.sort(key=lambda p: p.get("date", ""), reverse=True)
    return posts


def main() -> None:
    posts = collect()
    INDEX_FILE.parent.mkdir(parents=True, exist_ok=True)
    INDEX_FILE.write_text(
        json.dumps({"posts": posts}, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {len(posts)} posts to {INDEX_FILE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
