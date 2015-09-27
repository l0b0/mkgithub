PREFIX = /usr/local
BIN_DIR = $(PREFIX)/bin
SHARE_DIR = $(PREFIX)/share

INSTALL = /usr/bin/install
MKDIR = /usr/bin/mkdir
SED = /usr/bin/sed
TRAVIS_LINT = /usr/bin/travis-lint

name = $(notdir $(CURDIR))
script = $(name).sh
installed_script = $(BIN_DIR)/$(name)

include_path = $(SHARE_DIR)/$(name)

.PHONY: test
test:
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

$(include_path):
	$(MKDIR) $(include_path)

include make-includes/variables.mk
