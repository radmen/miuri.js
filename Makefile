COFFEE = node_modules/coffee-script/bin/coffee
QUNIT = node_modules/qunit/bin/cli.js
UGLIFYJS = node_modules/uglify-js/bin/uglifyjs
JITTER = node_modules/jitter/bin/jitter

build: build-src minify
	
build-src:
	$(COFFEE) -c -o lib src
	
minify:
	$(UGLIFYJS) lib/miuri.js -cm > lib/miuri.min.js

watch:
	$(JITTER) src lib

clean:
	rm -rf lib/*
	rm test/test.js

test: build-src
	$(COFFEE) -c test/test.coffee

test-run: test
	$(QUNIT) -c ./lib/miuri.js -t ./test/test.js

.PHONY: watch clean test
