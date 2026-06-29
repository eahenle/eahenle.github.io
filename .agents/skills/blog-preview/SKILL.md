---
name: blog-preview
description: Build and serve this Jekyll/GitHub Pages blog inside Codex so the user can preview posts and pages with zero manual artifact download, unpacking, or local server setup. Use when the user asks to preview, render, inspect, or read blog posts/pages as they will appear on the site before merging a PR.
---

# Blog Preview

Use this skill to make the current branch's Jekyll site immediately viewable in the Codex app.

## Workflow

1. From the repository root, run `scripts/preview.sh` from this skill in a PTY so the server stays alive:
   ```bash
   .agents/skills/blog-preview/scripts/preview.sh
   ```
2. Wait until the script reports the server URL.
3. Tell the user the preview URL. Prefer `http://localhost:4000/` unless the script was run with a different `PORT`.
4. If the request names or changes a specific post, also provide the expected post URL. Convert Jekyll post files named `_posts/YYYY-MM-DD-slug.markdown` to `/YYYY/MM/DD/slug.html`.
5. Leave the PTY session running while the user reviews the preview. Stop it only when the user asks or when the task is complete.

## Notes

- The script installs bundled gems when needed, sets `PAGES_REPO_NWO=eahenle/eahenle.github.io` when absent, builds with `JEKYLL_ENV=production`, and serves with `bundle exec jekyll serve` on `0.0.0.0` for Codex port forwarding.
- If port `4000` is busy, rerun with another port, for example `PORT=4001 .agents/skills/blog-preview/scripts/preview.sh`, and share that URL.
- Document any build warnings in the final response.
