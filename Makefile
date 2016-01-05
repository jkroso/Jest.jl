PREFIX?=/usr/local/bin

test:
	@bin/jest.jl test.jl --reporter dot

install:
	ln -sf $(PWD)/bin/jest.jl $(PREFIX)/jest

uninstall:
	rm -f $(PREFIX)/bin/jest

.PHONY: test install uninstall
