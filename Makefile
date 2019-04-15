TARGET = target
TMP = tmp

all: site

%/:
	mkdir -p $@

$(TMP)/%.html.fragment: %.asciidoc
	asciidoctor --no-header-footer -v -o $@ $<

$(TARGET)/%.html: $(TMP)/%.html.fragment html.header html.footer
	cat html.header $< html.footer >$@

$(TARGET)/index.html: $(TARGET)/ index.asciidoc

clean:
	- rm -rf $(TMP) $(TARGET);

site: $(TARGET)/index.html
