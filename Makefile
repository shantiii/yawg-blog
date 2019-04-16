# output directories
TARGET = target
TMP = tmp
SITE = $(TARGET)/site
BLOG = $(SITE)/posts

# probably don't change these
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

$(TMP)/%.titles:
	for i in $(BLOG_FILES) ; do echo $$i >>$@ ; done

$(TMP)/%.urls:
	for i in $(BLOG_PAGES) ; do echo $$i >>$@ ; done

$(TMP)/%.tocfile: $(TMP)/%.titles $(TMP)/%.urls
	echo '<ul>' >$@
	paste $+ | sed -Ee 's:(.*)\t$(SITE)/(.*):<li><a href="\2">\1\</a></li>:' >>$@
	echo '</ul>' >>$@

$(SITE)/index.html: html.header $(TMP)/index.html.fragment $(TMP)/toc.tocfile html.footer
	cat $+ >$@

$(BLOG)/%.html: html.header $(TMP)/posts/%.html.fragment html.footer
	cat $+ >$@

$(BLOG)/: $(TMP)/posts/

$(BLOG): $(BLOG)/ $(BLOG_PAGES)

$(ERROR_PAGES):
	cp $(@F) $@

.PHONY: clean local-server

clean:
	- rm -rf $(TMP) $(TARGET);

local-server:
	- h2o -c h2o.yaml

$(SITE): $(SITE)/ $(SITE)/index.html $(ERROR_PAGES) $(BLOG)

# Disable all the C-assuming nonsense in make
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
