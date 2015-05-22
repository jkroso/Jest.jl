PREFIX?=/usr/local
REPORTER?=dot

dependencies: dependencies.json
	@packin install --folder $@ --meta $<
	@ln -fsn .. $@/jest

test: dependencies
	@bin/jest test.jl --reporter $(REPORTER)

install: dependencies
	mkdir -p $(PREFIX)/bin
	ln -sf $$PWD/bin/jest $(PREFIX)/bin/jest

uninstall:
	rm -f $(PREFIX)/bin/jest

.PHONY: test install uninstall
