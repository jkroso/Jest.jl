
PREFIX?=/usr/local

dependencies: dependencies.json
	@packin install --folder $@ --meta $<
	@ln -s .. $@/jest

test: dependencies
	@bin/jest test.jl

install: dependencies
	mkdir -p $(PREFIX)/bin
	ln -sf $$PWD/bin/jest $(PREFIX)/bin/jest

uninstall:
	rm -f $(PREFIX)/bin/jest

.PHONY: test install uninstall
