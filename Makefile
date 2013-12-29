REPORTER = spec

test:
	@NODE_ENV=test/backend/ ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script

test-backend:
	./node_modules/.bin/mocha test/backend/ \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER)

test-frontend:
	./node_modules/.bin/mocha test/frontend/ \
		--compilers coffee:coffee-script \
		--reporter $(REPORTER)

test-w:
	@NODE_ENV=test ./node_modules/.bin/mocha \
		--reporter $(REPORTER) \
		--compilers coffee:coffee-script \
		--growl \
		--watch

.PHONY: test test-w
