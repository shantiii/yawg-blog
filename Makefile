TARGET = target
TMP = tmp
SITE = $(TARGET)/site
ERROR_PAGES = $(SITE)/40x.html $(SITE)/50x.html
BLOG_FILES=$(shell find posts -type f -iregex '.*\..*' | sort)
BLOG_PAGES=$(shell find posts -type f -iregex '.*\..*' | sort | sed -re 's:(.*)\.[^.]+:$(SITE)/\1.html:')

all: site

%/:
	mkdir -p $@

$(TMP)/%.html.fragment: %.asciidoc
	asciidoctor --no-header-footer -v -o $@ $<

$(TMP)/%.html.fragment: %.md
	pandoc -o $@ $<

$(TMP)/%.html.fragment: %.markdown
	mkdir -p $(@D)
	pandoc -o $@ $<

$(SITE)/%.html: $(TMP)/%.html.fragment html.header html.footer $(@D)/
	mkdir -p $(@D)
	cat html.header $< html.footer >$@

$(SITE)/%.html: %.html $(SITE)/
	cp $< $@

$(SITE)/posts/%.html: $(TMP)/posts/%.html.fragment

#// $(SITE)/index.html: $(SITE)/ index.asciidoc

.PHONY: site clean

clean:
	- rm -rf $(TMP) $(TARGET);

site: $(SITE)/ $(SITE)/index.html $(ERROR_PAGES) $(BLOG_PAGES)
