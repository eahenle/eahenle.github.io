#!/usr/bin/env python3
"""Generate a deterministic, editable distribution kit from a Jekyll post."""
from __future__ import annotations

import argparse
import html
import re
import sys
import textwrap
import urllib.parse
import urllib.request
from pathlib import Path

SITE_URL = "https://henletech.net"
CHANNELS = {"LinkedIn": "linkedin", "Hacker News": "hackernews", "Lobsters": "lobsters", "DEV": "devto", "Reddit": "reddit", "Direct outreach": "direct"}


def parse_front_matter(source: str) -> tuple[dict[str, object], str]:
    match = re.match(r"\A---\s*\n(.*?)\n---\s*\n", source, re.S)
    if not match:
        raise ValueError("Missing YAML front matter delimited by --- lines")
    metadata: dict[str, object] = {}
    for number, line in enumerate(match.group(1).splitlines(), 1):
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        field = re.match(r"^([A-Za-z_][\w-]*):\s*(.*)$", line)
        if not field:
            raise ValueError(f"Unsupported or malformed front matter on line {number}: {line}")
        key, value = field.groups()
        value = value.strip().strip('"\'')
        if value.startswith("[") and value.endswith("]"):
            metadata[key] = [item.strip().strip('"\'') for item in value[1:-1].split(",") if item.strip()]
        else:
            metadata[key] = value
    return metadata, source[match.end():]


def strip_markdown(source: str) -> str:
    source = re.sub(r"```.*?```|\{%\s*highlight.*?%\}.*?\{%\s*endhighlight\s*%\}", " ", source, flags=re.S)
    source = re.sub(r"<!--.*?-->|<[^>]+>", " ", source, flags=re.S)
    source = re.sub(r"!\[[^]]*\]\([^)]*\)", " ", source)
    source = re.sub(r"\[([^]]+)\]\([^)]*\)", r"\1", source)
    source = re.sub(r"^\s{0,3}(?:#{1,6}|[-*+]>?)\s+", "", source, flags=re.M)
    source = re.sub(r"[`*_~]", "", source)
    source = re.sub(r"\[[^]]+\]:\s*\S+.*$", "", source, flags=re.M)
    return html.unescape(re.sub(r"\s+", " ", source)).strip()


def sentences(text: str) -> list[str]:
    return [part.strip() for part in re.split(r"(?<=[.!?])\s+", text) if len(part.split()) >= 5]


def canonical_url(path: Path, metadata: dict[str, object]) -> str:
    if metadata.get("permalink"):
        return SITE_URL + "/" + str(metadata["permalink"]).strip("/") + "/"
    match = re.match(r"(\d{4})-(\d{2})-(\d{2})-(.+)\.(?:md|markdown|html)$", path.name)
    if not match:
        raise ValueError("Post filename must use YYYY-MM-DD-slug.md, or front matter must define permalink")
    year, month, day, slug = match.groups()
    return f"{SITE_URL}/{year}/{month}/{day}/{slug}.html"


def word_window(parts: list[str], minimum: int, maximum: int) -> str:
    chosen: list[str] = []
    for sentence in parts:
        projected = len((" ".join(chosen + [sentence])).split())
        if projected > maximum:
            if len(" ".join(chosen).split()) < minimum:
                needed = minimum - len(" ".join(chosen).split())
                chosen.append(" ".join(sentence.split()[:needed]))
            break
        chosen.append(sentence)
        if len(" ".join(chosen).split()) >= minimum:
            break
    if len(" ".join(chosen).split()) < minimum:
        bridge = "This draft is a starting point: retain the source's qualifications, add audience-specific context, and invite readers to test the argument against their own experience. The useful question is not whether the claim sounds persuasive, but which observation would confirm or falsify it in practice."
        needed = minimum - len(" ".join(chosen).split())
        bridge_words = bridge.split()
        chosen.append(" ".join((bridge_words * (needed // len(bridge_words) + 1))[:needed]))
    return " ".join(chosen)


def extract_entities(markdown: str) -> list[str]:
    links = re.findall(r"\[([^]]+)\]\((?:https?://)[^)]+\)", markdown)
    bold = re.findall(r"\*\*([^*]+)\*\*", markdown)
    values = [strip_markdown(value) for value in links + bold]
    return list(dict.fromkeys(value for value in values if 1 <= len(value.split()) <= 8))[:12]


def load_input(value: str) -> tuple[dict[str, object], str, str, Path | None]:
    if value.startswith(("http://", "https://")):
        with urllib.request.urlopen(value, timeout=15) as response:  # nosec: user-selected URL
            page = response.read().decode("utf-8", "replace")
        title = re.search(r"<title>(.*?)</title>", page, re.S | re.I)
        description = re.search(r'<meta\s+name=["\']description["\']\s+content=["\'](.*?)["\']', page, re.I)
        body = strip_markdown(page)
        return {"title": html.unescape(title.group(1)).split("|")[0].strip() if title else "", "description": html.unescape(description.group(1)) if description else ""}, body, value, None
    path = Path(value)
    if not path.is_file():
        raise ValueError(f"Post does not exist: {path}")
    metadata, markdown = parse_front_matter(path.read_text(encoding="utf-8"))
    return metadata, markdown, canonical_url(path, metadata), path


def build_kit(metadata: dict[str, object], markdown: str, url: str) -> str:
    title = str(metadata.get("title", "")).strip()
    if not title:
        raise ValueError("Front matter is missing a non-empty title")
    plain = strip_markdown(markdown)
    parts = sentences(plain)
    if not parts:
        raise ValueError("Post has no usable prose after Markdown cleanup")
    thesis = str(metadata.get("description") or parts[0]).strip()
    linkedin = word_window([thesis, "The essay follows that claim through its practical consequences rather than treating it as a slogan."] + parts[1:] + ["I would be interested to hear where this model holds up—and where it breaks in your own work.", f"Read it here: {url}"], 100, 180)
    newsletter_parts = [f"# {title}", thesis, "## The problem", *parts[:5], "## The argument", *parts[5:12], "## What to take away", *parts[-4:], f"The full essay, including its original links and examples, is at {url}."]
    newsletter = word_window(newsletter_parts, 300, 600)
    opener = word_window([f"I wrote about this question: {thesis}"] + parts[1:6] + ["I am sharing it here because the underlying tradeoff seems broader than this one example. What assumptions would you challenge, and what evidence would change your mind?"], 100, 200)
    quotes = (parts + [thesis] * 3)[:3]
    tags = metadata.get("tags") or ["engineering", "systems", "technology"]
    if isinstance(tags, str): tags = [tags]
    entities = extract_entities(markdown)
    campaign = []
    for label, source in CHANNELS.items():
        query = urllib.parse.urlencode({"utm_source": source, "utm_medium": "social" if source != "direct" else "outreach", "utm_campaign": "post_launch"})
        campaign.append(f"- **{label}:** {url}?{query}")
    return f"""# Distribution Kit: {title}

> Generated deterministically. Edit for voice, context, and each community before using. Nothing is posted automatically.

## Article
- **Title:** {title}
- **Canonical URL:** {url}
- **One-sentence thesis:** {thesis}

## LinkedIn post (100–180 words)
{linkedin}

## LinkedIn newsletter draft (300–600 words)
{newsletter}

## Hacker News title
{title}

## Community discussion opener (100–200 words)
{opener}

## Quotable excerpts
""" + "\n".join(f"- “{quote}”" for quote in quotes) + f"""

## Discussion questions
- Which assumption in the thesis is most fragile?
- Where have you seen the same pattern in practice?
- What experiment or evidence would best test this argument?

## Suggested communities or channel types
- Practitioner communities directly related to the post's subject
- Engineering leadership or architecture forums
- Project-specific communities for tools explicitly discussed

## Explicitly referenced entities, people, projects, or papers
{chr(10).join(f'- {entity}' for entity in entities) if entities else '- None detected; review the source manually.'}

## Suggested tags
{', '.join('#' + str(tag).replace(' ', '-') for tag in tags)}

## Open Graph suggestions
- **Title:** {title}
- **Image concept:** A restrained Henle Tech systems diagram illustrating the essay's central tension; keep the title legible at thumbnail size.

## Campaign URLs
{chr(10).join(campaign)}
"""


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("post", help="Local Jekyll post path or published URL")
    parser.add_argument("--output-dir", default="_distribution", type=Path)
    args = parser.parse_args(argv)
    try:
        metadata, markdown, url, path = load_input(args.post)
        output = args.output_dir / ((path.stem if path else urllib.parse.urlparse(url).path.strip("/").replace("/", "-") or "index") + ".md")
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(build_kit(metadata, markdown, url), encoding="utf-8")
        print(output)
        return 0
    except (OSError, ValueError, urllib.error.URLError) as error:
        print(f"error: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    raise SystemExit(main())
