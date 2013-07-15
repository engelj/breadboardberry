# -*- mode:GNUmakefile; coding: utf-8 -*-
##############################################################################
# Copyright (C) 2013 Jörg Engelhart

compile: *.coffee
	coffee -c htp.coffee
	coffee -o static -c ac.coffee
	touch $@

compileAll: npm compile
	touch $@

npm:
	npm install
	npm update
	touch $@

stylus: *.styl
	stylus -o static style.styl

jade: *.jade
	jade layout.jade
	jade index.jade

# uncomment the right one, for Raspberry you need sudo
run: compileAll
#       sudo bash -c "export PATH=$$PATH;node htp.js"
	PATH=$$PATH node htp.js

.PHONY: clean
clean:
	-rm compile > /dev/null 2>&1
	-rm htp.js > /dev/null 2>&1

.PHONY: distclean
distclean:
	- \rm -rf node_modules
	-rm npm compile

