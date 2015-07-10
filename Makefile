PREFIX?=/usr/local/bin

dependencies: bin/jest.jl
	@kip $<

test: dependencies
	@bin/jest.jl test.jl --reporter dot

install: dependencies
	ln -sf $(PWD)/bin/jest.jl $(PREFIX)/jest

uninstall:
	rm -f $(PREFIX)/bin/jest

.PHONY: test install uninstall
