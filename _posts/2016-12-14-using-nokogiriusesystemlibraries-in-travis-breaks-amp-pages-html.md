---
layout: post
title: Using NOKOGIRI_USE_SYSTEM_LIBRARIES in Travis CI breaks amp pages
category: gotcha
technology: travis-ci
genre: Continuous Integration
tags: travis jekyll bug
author: onnimonni
last_modified_at: 2016-12-15 00:39:29 +0200
---

Travis might break your [amp pages](https://www.ampproject.org/) when you're using `NOKOGIRI_USE_SYSTEM_LIBRARIES: true`.

Do you know the feeling when you have a bug which is just motherf* hard son of a bitch level bug to track. You spend hours or even days figuring it out persistantly closing different options out of the bigger picture. This just happened to me as well.

[Google AMP validator](https://search.google.com/search-console/amp) just outputted multiple errors even though my local development environment was just fine:

```
The tag 'script' is disallowed except in specific forms.
The mandatory tag 'amphtml engine v0.js script' is missing or incorrect. (see
```

## The context
I'm building and testing this site in [Travis CI](https://travis-ci.org/KeksiLabs/keksi.io). I had enabled `NOKOGIRI_USE_SYSTEM_LIBRARIES: true` in my `.travis.yml` because many developers have had good experience with that in order to speed up the builds.

Somehow the older version of nokogiri outputted the closing elements for my html head `</head><body>` too early.

**This was what I wanted to achieve:**

```html
<noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript> <script async src="https://cdn.ampproject.org/v0.js"></script><script async custom-element="amp-analytics" src="https://cdn.ampproject.org/v0/amp-analytics-0.1.js"></script></head><body>
```


**This was what happened in the build phase instead:**

```html
</head><body> <noscript><style amp-boilerplate>body{-webkit-animation:none;-moz-animation:none;-ms-animation:none;animation:none}</style></noscript> <script async src="https://cdn.ampproject.org/v0.js"></script><script async custom-element="amp-analytics" src="https://cdn.ampproject.org/v0/amp-analytics-0.1.js"></script>
```

As you can see the head element ends too soon.

## Conclusion
In the end it was super relieving after I figured this out. If you're having random html errors try to disable notorius `NOKOGIRI_USE_SYSTEM_LIBRARIES`.
