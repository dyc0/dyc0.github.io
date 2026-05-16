POSTS_SRC  := $(sort $(wildcard posts/*.md))
POSTS_HTML := $(patsubst posts/%.md,public/%.html,$(POSTS_SRC))
PANDOC     := pandoc
TEMPLATE   := template.html
SITE_TITLE := Stultifera Navis

define SIDEBAR
<aside id="sidebar">\
<h2>Навигација</h2>\
<nav><ul>\
<li><a href="index.html">Почетак</a></li>\
<li><a href="about.html">Детаљи</a></li>\
<li><a href="posts.html">Све објаве</a></li>\
</ul></nav>\
</aside>
endef
export SIDEBAR

.PHONY: all clean deploy

all: public/style.css public/about.html $(POSTS_HTML) public/index.html public/posts.html

public/:
	mkdir -p public

public/style.css: style.css | public/
	cp style.css public/style.css

public/about.html: about.md $(TEMPLATE) | public/
	$(PANDOC) --template=$(TEMPLATE) -o $@ $<

public/%.html: posts/%.md $(TEMPLATE) | public/
	$(PANDOC) --template=$(TEMPLATE) -o $@ $<

public/index.html: $(POSTS_SRC) | public/
	@{ \
	  printf '<!DOCTYPE html>\n<html lang="sr"><head><meta charset="UTF-8"/><title>%s</title><link rel="stylesheet" href="style.css"/></head>\n<body>\n<div id="layout">\n%s\n<main id="content">\n<h1>%s</h1>\n<p>Транзистором против транзистора.</p>\n<ul class="post-list">\n' \
	    "$(SITE_TITLE)" "$$SIDEBAR" "$(SITE_TITLE)"; \
	  for f in $$(echo "$(POSTS_SRC)" | tr ' ' '\n' | sort -r | head -5); do \
	    title=$$(grep '^title:' "$$f" | head -1 | sed 's/^title:[[:space:]]*//'); \
	    date=$$(grep '^date:' "$$f" | head -1 | sed 's/^date:[[:space:]]*//'); \
	    excerpt=$$(grep '^excerpt:' "$$f" | head -1 | sed 's/^excerpt:[[:space:]]*//'); \
	    base=$$(basename "$$f" .md); \
	    printf '<li><p class="post-date">%s</p><p class="post-title"><a href="%s.html">%s</a></p><p class="post-excerpt">%s</p></li>\n' \
	      "$$date" "$$base" "$$title" "$$excerpt"; \
	  done; \
	  printf '</ul>\n</main>\n</div>\n</body>\n</html>\n'; \
	} > $@

public/posts.html: $(POSTS_SRC) | public/
	@{ \
	  printf '<!DOCTYPE html>\n<html lang="sr"><head><meta charset="UTF-8"/><title>All Posts — %s</title><link rel="stylesheet" href="style.css"/></head>\n<body>\n<div id="layout">\n%s\n<main id="content">\n<h1>Све објаве</h1>\n<ul class="post-list">\n' \
	    "$(SITE_TITLE)" "$$SIDEBAR"; \
	  for f in $$(echo "$(POSTS_SRC)" | tr ' ' '\n' | sort -r); do \
	    title=$$(grep '^title:' "$$f" | head -1 | sed 's/^title:[[:space:]]*//'); \
	    date=$$(grep '^date:' "$$f" | head -1 | sed 's/^date:[[:space:]]*//'); \
	    base=$$(basename "$$f" .md); \
	    printf '<li><p class="post-date">%s</p><p class="post-title"><a href="%s.html">%s</a></p></li>\n' \
	      "$$date" "$$base" "$$title"; \
	  done; \
	  printf '</ul>\n</main>\n</div>\n</body>\n</html>\n'; \
	} > $@

clean:
	rm -f public/*.html public/style.css

deploy: all
	cd public && git add -A && git commit -m "deploy: $$(date +%Y-%m-%d)" && git push origin public
