.PHONY: help install validate

help:
	@echo "  make install    install check tools and activate hooks"
	@echo "  make validate   run commit-stage checks"

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
