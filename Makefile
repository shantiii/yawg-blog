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
BLOG_FILES=$(shell find $(POSTS) -type f -iregex '.*\.markdown' | sort)
BLOG_PAGES=$(shell find $(POSTS) -type f -iregex '.*\.markdown' | sort | sed -re 's:src/(.*)\.[^.]+:$(SITE)/\1.html:')

all: $(SITE)

# to make a directory, one must... mkdir
%/:
	- test -d $@ || mkdir -p $@

$(TMP)/%.html.fragment: $(SRC)/%.asciidoc $(TMP)/
	asciidoctor --no-header-footer -v -o $@ $<

$(TMP)/%.html.fragment: $(SRC)/%.md $(TMP)/
	pandoc -o $@ $<

$(TMP)/%.html.fragment: $(SRC)/%.markdown $(TMP)/
	pandoc -o $@ $<

$(TMP)/%.dates: $(BLOG_FILES)
	for i in $(BLOG_FILES) ; do sed -nEe 's/^\[date\]: (.*)$$/\1/p' $$i >>$@ ; done

$(TMP)/%.titles: $(BLOG_FILES)
	for i in $(BLOG_FILES) ; do sed -nEe 's/^# (.*)$$/\1/p' $$i >>$@ ; done

$(TMP)/%.urls: $(BLOG_FILES)
	for i in $(BLOG_PAGES) ; do echo $$i >>$@ ; done

$(TMP)/%.tocfile: $(TMP)/%.dates $(TMP)/%.titles $(TMP)/%.urls
	echo '<ul>' >$@
	paste $+ | sort -r | sed -Ee 's:(.*)\t(.*)\t$(SITE)/([^\t]*):<li><i>\1</i> - <a href="\3">\2\</a></li>:' >>$@
	echo '</ul>' >>$@

$(SITE)/index.html: $(SRC)/html.header $(TMP)/index.html.fragment $(TMP)/toc.tocfile $(SRC)/html.footer
	cat $+ >$@

$(BLOG)/%.html: $(SRC)/html.header $(TMP)/posts/%.html.fragment $(SRC)/html.footer
	cat $+ >$@

$(BLOG)/: $(TMP)/posts/

$(BLOG): $(BLOG)/ $(BLOG_PAGES)

$(ERROR_PAGES):
	cp $(SRC)/$(@F) $@

.PHONY: clean clean-all clean-config local-server prod-server publish .publish-site

clean-all: clean clean-config

clean:
	- rm -rf $(TMP) $(TARGET)

clean-config:
	- rm -f .publish-site .publish-config

local-server: $(SITE)
	- h2o -c config/h2o.local.yaml

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
