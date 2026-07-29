---
layout: page
title: Archive
permalink: /archive/
description: The complete Henle Tech essay and project archive.
---

{% assign posts_by_year = site.posts | group_by_exp: "post", "post.date | date: '%Y'" %}
{% for year in posts_by_year %}
## {{ year.name }}

{% for post in year.items %}- {{ post.date | date: "%B %-d" }} — [{{ post.title }}]({{ post.url | relative_url }}){% if post.tags.size > 0 %} · {% for tag in post.tags %}<span id="tag-{{ tag | slugify }}">#{{ tag }}</span>{% unless forloop.last %}, {% endunless %}{% endfor %}{% endif %}
{% endfor %}
{% endfor %}
