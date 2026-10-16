.PHONY: help install validate push-checks tap-syntax ci

help:
	@echo "  make install       install check tools and activate hooks"
	@echo "  make validate      run commit-stage checks"
	@echo "  make push-checks   run pre-push checks on commits not on origin/main"
	@echo "  make tap-syntax    run brew test-bot tap syntax in the CI Linux image"
	@echo "  make ci            run every CI check that works on this machine"

install:
	git config core.hooksPath .githooks
	chmod +x .githooks/pre-commit .githooks/pre-push .githooks/jj-push scripts/* 2>/dev/null || true
	@if [ -d .jj ] && command -v jj >/dev/null 2>&1; then \
	    jj config set --repo aliases.push '["util","exec","--","bash","-c","exec bash \"$$(jj workspace root)/.githooks/jj-push\" \"$$@\"","jj-push"]'; \
	    echo "jj detected: 'jj push' runs the pre-push checks, then 'jj git push'"; \
	elif [ -d .jj ]; then \
	    echo "warn: .jj/ present but jj not on PATH; 'jj push' checks are not wired"; \
	fi
	@bash scripts/install-tools

validate:
	@bash .githooks/pre-commit --all-files

# Checks the commits from the origin/main merge base to git HEAD. Under jj,
# git HEAD is @-, so describe the change and run jj new first.
push-checks:
	@bash .githooks/pre-push < /dev/null

tap-syntax:
	@bash scripts/check-tap-syntax

# REQUIRE_GATES fails on a missing linter, as the Quality workflow does.
ci: export REQUIRE_GATES = 1
ci: validate push-checks tap-syntax
