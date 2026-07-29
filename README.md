# [eahenle.github.io](https://eahenle.github.io)

## Pull request previews

Every pull request that changes site content, templates, styles, assets, or the preview workflows runs the **CI render** GitHub Actions workflow. The workflow builds the site with Jekyll in production mode to catch rendering failures before merge.

The separate **Preview publish** workflow builds the same rendered site with a PR-specific `baseurl`, publishes it under `/pr-preview/pr-<number>/` on the configured GitHub Pages source branch for same-repository pull requests, and posts the preview link as a PR comment. When a pull request changes a Jekyll post, the comment links directly to the rendered post and also includes the site root preview; otherwise it links to the newest rendered post as a representative preview. Closed PRs remove both their published preview directory and preview comment.

To preview from Codex instead, ask Codex to use the repo-local `blog-preview` skill. The skill builds this branch, starts the Jekyll preview server inside Codex, and gives you a preview URL without requiring you to download artifacts, unpack archives, or run a local server manually.

Example prompt:

> Use the blog-preview skill to show me this PR's rendered site.

Codex will run `.agents/skills/blog-preview/scripts/preview.sh`, keep the Jekyll server alive in the session, and report the forwarded preview URL.

## Publication tooling

Build the production site with `JEKYLL_ENV=production bundle exec jekyll build`. Run
`python scripts/validate_site.py` afterward to check canonical metadata, absolute
social images, internal links, the sitemap, and publication exclusions.

Generate an editable, deterministic launch kit with:

```sh
python scripts/distribution_kit.py _posts/YYYY-MM-DD-slug.markdown
```

The output under `_distribution/` is intentionally excluded from Jekyll and Git.
See [`docs/PUBLISHING.md`](docs/PUBLISHING.md) for newsletter, privacy-respecting
analytics, webmaster verification, and the repeatable publishing checklist.
