build: build-src minify
	
build-src:
	coffee -c -o lib src
	
minify:
	uglifyjs lib/miuri.js -cm > lib/miuri.min.js

watch:
	jitter src lib

clean:
	rm -rf lib/*
	rm test/test.js

test:
	coffee -c test/test.coffee

test-run: test
	qunit -c ./lib/miuri.js -t ./test/test.js

.PHONY: watch clean test
