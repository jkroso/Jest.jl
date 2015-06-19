
PREFIX?=/usr/local

dependencies: dependencies.json
	@packin install --folder $@ --meta $<
	@ln -sfn .. $@/jest

test: dependencies
	@bin/jest test.jl --reporter dot

install: dependencies
	mkdir -p $(PREFIX)/bin
	ln -sf $$PWD/bin/jest $(PREFIX)/bin/jest

uninstall:
	rm -f $(PREFIX)/bin/jest

.PHONY: test install uninstall
