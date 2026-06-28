# [eahenle.github.io](https://eahenle.github.io)

## Pull request previews

Every pull request that changes site content, templates, styles, assets, or the preview workflow runs the **Preview render** GitHub Actions workflow. The workflow builds the site with Jekyll in production mode to catch rendering failures before merge.

To read posts as they will appear before merging, ask Codex to use the repo-local `blog-preview` skill. The skill builds this branch, starts the Jekyll preview server inside Codex, and gives you a preview URL without requiring you to download artifacts, unpack archives, or run a local server manually.

Example prompt:

> Use the blog-preview skill to show me this PR's rendered site.
