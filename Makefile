# input directory
SRC = src
POSTS = $(SRC)/posts
# output directories
TARGET = target
TMP = tmp
SITE = $(TARGET)/site
BLOG = $(SITE)/posts
PRODHOST = shanti.wtf

# probably don't change these
ERROR_PAGES = $(SITE)/40x.html $(SITE)/50x.html
BLOG_FILES=$(shell find $(POSTS) -type f -iregex '.*\..*' | sort)
BLOG_PAGES=$(shell find $(POSTS) -type f -iregex '.*\..*' | sort | sed -re 's:src/(.*)\.[^.]+:$(SITE)/\1.html:')

all: $(SITE)

# to make a directory, one must... mkdir
%/:
	mkdir -p $@

$(TMP)/%.html.fragment: $(SRC)/%.asciidoc
	asciidoctor --no-header-footer -v -o $@ $<

$(TMP)/%.html.fragment: $(SRC)/%.md
	pandoc -o $@ $<

$(TMP)/%.html.fragment: $(SRC)/%.markdown
	pandoc -o $@ $<

$(TMP)/%.titles:
	for i in $(BLOG_FILES) ; do echo $$i >>$@ ; done

$(TMP)/%.urls:
	for i in $(BLOG_PAGES) ; do echo $$i >>$@ ; done

$(TMP)/%.tocfile: $(TMP)/%.titles $(TMP)/%.urls
	echo '<ul>' >$@
	paste $+ | sed -Ee 's:(.*)\t$(SITE)/(.*):<li><a href="\2">\1\</a></li>:' >>$@
	echo '</ul>' >>$@

$(SITE)/index.html: $(SRC)/html.header $(TMP)/index.html.fragment $(TMP)/toc.tocfile $(SRC)/html.footer
	cat $+ >$@

$(BLOG)/%.html: $(SRC)/html.header $(TMP)/posts/%.html.fragment $(SRC)/html.footer
	cat $+ >$@

$(BLOG)/: $(TMP)/posts/

$(BLOG): $(BLOG)/ $(BLOG_PAGES)

$(ERROR_PAGES):
	cp $(SRC)/$(@F) $@

.PHONY: clean prod-server publish .publish-site

clean:
	- rm -rf $(TMP) $(TARGET) .publish-site .publish-config;

prod-server:
	- h2o -c config/h2o.prod.yaml

publish: .publish-config .publish-site

.publish-site: $(SITE)
	- rsync -avz --delete-after $(SITE) $(PRODHOST):slagathor
	- touch $@

.publish-config: config/h2o.prod.yaml
	- scp config/h2o.prod.yaml $(PRODHOST):/tmp/h2o.prod.conf
	- ssh -t $(PRODHOST) sudo install -bpT -m 0644 -o root -g root /tmp/h2o.prod.conf /etc/h2o/h2o.conf
	- ssh $(PRODHOST) rm /tmp/h2o.prod.conf
	- ssh -t $(PRODHOST) sudo systemctl restart h2o.service
	- touch $@

$(SITE): $(SITE)/ $(SITE)/index.html $(ERROR_PAGES) $(BLOG)

# Disable all the C-assuming nonsense in make
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
