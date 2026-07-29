import tempfile
import unittest
from pathlib import Path
from scripts.distribution_kit import build_kit, canonical_url, parse_front_matter, strip_markdown

FIXTURE = Path(__file__).parent / "fixtures/2026-07-25-representative.md"

class DistributionKitTests(unittest.TestCase):
    def setUp(self):
        self.metadata, self.body = parse_front_matter(FIXTURE.read_text())

    def test_metadata_and_canonical_url(self):
        self.assertEqual(self.metadata["tags"], ["systems", "testing"])
        self.assertEqual(canonical_url(FIXTURE, self.metadata), "https://henletech.net/2026/07/25/representative.html")

    def test_markdown_cleanup_removes_code_and_preserves_link_label(self):
        plain = strip_markdown(self.body)
        self.assertIn("Example Project", plain)
        self.assertNotIn("print(", plain)

    def test_kit_has_all_campaigns_and_sections(self):
        kit = build_kit(self.metadata, self.body, canonical_url(FIXTURE, self.metadata))
        for channel in ("LinkedIn", "Hacker News", "Lobsters", "DEV", "Reddit", "Direct outreach"):
            self.assertIn(channel, kit)
        self.assertIn("Explicitly referenced entities", kit)
        self.assertIn("utm_campaign=post_launch", kit)
        linkedin = kit.split("## LinkedIn post (100–180 words)\n", 1)[1].split("\n\n## LinkedIn newsletter", 1)[0]
        newsletter = kit.split("## LinkedIn newsletter draft (300–600 words)\n", 1)[1].split("\n\n## Hacker News title", 1)[0]
        opener = kit.split("## Community discussion opener (100–200 words)\n", 1)[1].split("\n\n## Quotable excerpts", 1)[0]
        self.assertTrue(100 <= len(linkedin.split()) <= 180)
        self.assertTrue(300 <= len(newsletter.split()) <= 600)
        self.assertTrue(100 <= len(opener.split()) <= 200)

    def test_missing_front_matter_is_clear(self):
        with self.assertRaisesRegex(ValueError, "Missing YAML front matter"):
            parse_front_matter("# no metadata")

if __name__ == "__main__": unittest.main()
