PREFIX ?= /usr/local
SHELLSPEC = vendor/shellspec-0.28.1/shellspec
SHELLCHECK = vendor/shellcheck

.PHONY: test check check-test check-vendor fmt build install bump-major bump-minor bump-patch tag

test:
	@echo "--- test: running shellspec ---"
	$(SHELLSPEC)
	@echo "--- test: done ---"

check:
	@echo "--- check: shellcheck src/ ---"
	find ./src -name '*.sh' -o -name 'semver' | xargs $(SHELLCHECK) -s sh -e SC1091
	@echo "--- check: done ---"

check-test:
	@echo "--- check-test: shellcheck spec/ ---"
	find ./spec -name '*.sh' | xargs $(SHELLCHECK) -s sh -e SC1091
	@echo "--- check-test: done ---"

check-vendor:
	@echo "--- check-vendor: shellcheck vendor/ ---"
	find ./vendor -name '*.sh' | xargs $(SHELLCHECK) -s sh -e SC1091
	@echo "--- check-vendor: shellcheck bin/build.sh bin/install.sh ---"
	$(SHELLCHECK) -s sh bin/build.sh bin/install.sh
	@echo "--- check-vendor: done ---"

fmt:
	@echo "--- fmt: prettier on markdown ---"
	npx prettier --write '**/*.md'
	@echo "--- fmt: done ---"

build: check test
	@echo "--- build: bundling bin/semver ---"
	sh bin/build.sh
	bin/semver --help
	@echo "--- build: shellcheck bin/semver ---"
	$(SHELLCHECK) -s sh bin/semver
	@echo "--- build: done ---"

bump-major bump-minor bump-patch:
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: uncommitted changes in repo" >&2; exit 1; fi
	@PART=$$(echo $@ | sed 's/bump-//'); \
	NEW=$$(sh ./src/semver bump $$PART $$(cat VERSION)); \
	echo "--- $@: $$PART $$(cat VERSION) -> $$NEW ---"; \
	printf '%s\n' "$$NEW" > VERSION; \
	git add VERSION; \
	git commit -m "v$$NEW"; \
	echo "--- $@: done ---"

tag:
	@if [ -n "$$(git status --porcelain)" ]; then echo "Error: uncommitted changes in repo" >&2; exit 1; fi
	@TAG="v$$(cat VERSION)"; \
	if git rev-parse "$$TAG" >/dev/null 2>&1; then echo "Error: tag $$TAG already exists" >&2; exit 1; fi; \
	echo "--- tag: $$TAG ---"; \
	git tag "Release $$TAG"; \
	echo "--- tag: done ---"

install: build
	@echo "--- install: installing to $(PREFIX)/bin/semver ---"
	install -m 0755 bin/semver $(PREFIX)/bin/semver
	@echo "--- install: done ($(PREFIX)/bin/semver) ---"
