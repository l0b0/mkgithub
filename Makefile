PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
SHARE_DIR = $(PREFIX)/share

CURL = /usr/bin/curl
INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed
TRAVIS_LINT = /usr/bin/travis-lint

SHUNIT2_VERSION = 2.1.6

name = $(notdir $(CURDIR))
script = $(name).sh
installed_script = $(BIN_DIR)/$(name)

shunit2_dir = shunit2-source
shunit2 = $(shunit2_dir)/$(SHUNIT2_VERSION)/src/shunit2
export shunit2

include_path = $(SHARE_DIR)/$(name)

.PHONY: test
test: $(shunit2)
	$(CURDIR)/test.sh

.PHONY: lint
lint:
	$(TRAVIS_LINT) .travis.yml

.PHONY: install
install: $(include_path)
	$(INSTALL) $(script) $(installed_script)
	$(SED) -i -e 's#\(\./\)\?$(script)#$(name)#g' $(installed_script)
	$(INSTALL) --mode 644 shell-includes/error.sh shell-includes/usage.sh shell-includes/variables.sh shell-includes/verbose_print_line.sh $(include_path)
	$(SED) -i -e 's#^\(includes=\).*#\1"$(include_path)"#g' $(installed_script)

$(shunit2):
	$(CURL) --location "https://github.com/kward/shunit2/archive/source.tar.gz" | tar zx

$(include_path):
	$(MKDIR) $(include_path)

clean:
	$(RM) -r $(shunit2_dir)

include make-includes/variables.mk
