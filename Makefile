# output directories
TARGET = target
TMP = tmp
SITE = $(TARGET)/site
BLOG = $(SITE)/posts

# probably don't change these
scripts = scripts
ERROR_PAGES = $(SITE)/40x.html $(SITE)/50x.html
BLOG_FILES=$(shell find posts -type f -iregex '.*\..*' | sort)
BLOG_PAGES=$(shell find posts -type f -iregex '.*\..*' | sort | sed -re 's:(.*)\.[^.]+:$(SITE)/\1.html:')

all: $(SITE)

# to make a directory, one must... mkdir
%/:
	mkdir -p $@

$(TMP)/%.html.fragment: %.asciidoc
	asciidoctor --no-header-footer -v -o $@ $<

$(TMP)/%.html.fragment: %.md
	pandoc -o $@ $<

$(TMP)/%.html.fragment: %.markdown
	pandoc -o $@ $<

$(TMP)/toc.titles:
	for i in $(BLOG_FILES) ; do echo $$i >>$@ ; done

$(TMP)/toc.urls:
	for i in $(BLOG_PAGES) ; do echo $$i >>$@ ; done

$(TMP)/toc.fragment: $(TMP)/toc.titles $(TMP)/toc.urls
	paste $+ | sed -Ee 's:(.*)\t$(SITE)/(.*):<a href="\2">\1\</a>:' >$@

$(SITE)/index.html: html.header $(TMP)/index.html.fragment $(TMP)/toc.fragment html.footer
	cat $+ >$@

$(BLOG)/%.html: html.header $(TMP)/posts/%.html.fragment html.footer
	cat $+ >$@

$(BLOG)/: $(TMP)/posts/

$(BLOG): $(BLOG)/ $(BLOG_PAGES)

$(ERROR_PAGES):
	cp $(@F) $@

.PHONY: site clean

clean:
	- rm -rf $(TMP) $(TARGET);

$(SITE): $(SITE)/ $(SITE)/index.html $(ERROR_PAGES) $(BLOG)

# Disable all the C-assuming nonsense in make
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
