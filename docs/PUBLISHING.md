# Publishing checklist

## Before publishing

- [ ] Set a clear `title` and one-sentence `description` in front matter.
- [ ] Add only justified `tags` or `categories`; confirm the canonical slug/URL.
- [ ] Optionally set `image` to a repository-relative social image (the site default is otherwise used).
- [ ] Proofread the rendered page, including code, alt text, and mobile layout.
- [ ] Add useful internal links and validate external links.

## After publishing

- [ ] Open the production page and confirm its canonical URL, description, and social preview metadata.
- [ ] Run `python scripts/distribution_kit.py _posts/YYYY-MM-DD-slug.markdown`, then edit the generated kit for each audience.
- [ ] Send the newsletter after a provider is configured.
- [ ] Submit selectively to relevant communities; do not paste the same pitch everywhere simultaneously.
- [ ] Record and use the kit's channel-specific campaign URLs.

## One-time external setup

- [ ] Choose a newsletter provider, create a form, and configure `newsletter` as shown below.
- [ ] Choose privacy-respecting analytics. For Plausible, use its hosted script URL and the domain as `site_id`; enable only after reviewing its current documentation and consent requirements.
- [ ] Verify `https://henletech.net` in Google Search Console and Bing Webmaster Tools using the optional config hooks.
- [ ] Submit `https://henletech.net/sitemap.xml` to both services; confirm indexing and canonical-host selection.

```yaml
newsletter:
  enabled: true
  action_url: https://provider.example/forms/your-real-form
  email_field: email
  method: post
  title: Get new essays by email
  description: No content sludge. Only things worth thinking through.
  hidden_fields:
    source: henletech

analytics:
  enabled: true
  provider: plausible
  site_id: henletech.net
  script_url: https://your-analytics-host.example/js/script.js

webmaster_verification:
  google: your-real-token
  bing: your-real-token
```

Never commit provider secrets. Tokens shown above are documentation labels, not active configuration; put real verification values into deployment-specific configuration if the repository should remain public.
