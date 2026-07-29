#!/usr/bin/env python3
"""Validate production metadata and local links in a built Jekyll site."""
from html.parser import HTMLParser
from pathlib import Path
import sys
from urllib.parse import urlparse

ROOT = Path("_site")
HOST = "henletech.net"

class PageParser(HTMLParser):
    def __init__(self):
        super().__init__(); self.links=[]; self.canonicals=[]; self.og_images=[]
    def handle_starttag(self, tag, attrs):
        data=dict(attrs)
        if tag == "a" and data.get("href"): self.links.append(data["href"])
        if tag == "link" and data.get("rel") == "canonical": self.canonicals.append(data.get("href", ""))
        if tag == "meta" and data.get("property") == "og:image": self.og_images.append(data.get("content", ""))

def target_exists(url: str) -> bool:
    path=urlparse(url).path
    candidate=ROOT / path.lstrip("/")
    return candidate.is_file() or (candidate / "index.html").is_file() or candidate.with_suffix(".html").is_file()

def main():
    errors=[]
    for file in ROOT.rglob("*.html"):
        if "assets" in file.relative_to(ROOT).parts:
            continue
        parser=PageParser(); parser.feed(file.read_text(encoding="utf-8"))
        if len(parser.canonicals) != 1: errors.append(f"{file}: expected one canonical, found {len(parser.canonicals)}")
        elif urlparse(parser.canonicals[0]).netloc != HOST: errors.append(f"{file}: wrong canonical host: {parser.canonicals[0]}")
        for image in parser.og_images:
            if not image.startswith(f"https://{HOST}/"): errors.append(f"{file}: non-production og:image: {image}")
        for link in parser.links:
            parsed=urlparse(link)
            if not parsed.scheme and not parsed.netloc and link.startswith("/") and not target_exists(link): errors.append(f"{file}: broken internal link: {link}")
    if (ROOT / "_distribution").exists(): errors.append("_distribution was published")
    if not (ROOT / "sitemap.xml").is_file(): errors.append("sitemap.xml is missing")
    if errors:
        print("\n".join(errors), file=sys.stderr); return 1
    print("Production metadata, internal links, sitemap, and exclusions are valid."); return 0
if __name__ == "__main__": raise SystemExit(main())
