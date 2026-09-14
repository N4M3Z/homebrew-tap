.PHONY: help install validate worktree worktree-done

help:
	@echo "  make install    install check tools and activate hooks"
	@echo "  make validate   run commit-stage checks"
	@echo "  make worktree   create an agent worktree: make worktree BRANCH=change/x IDENTITY=<model-id> [HARNESS=<harness>]"
	@echo "  make worktree-done   remove a merged worktree or jj workspace: make worktree-done BRANCH=change/x"

install:
	git config core.hooksPath .githooks
	chmod +x .githooks/* scripts/* 2>/dev/null || true
	@if [ -d .jj ] && command -v jj >/dev/null 2>&1; then \
	    jj config set --repo aliases.push "[\"util\",\"exec\",\"--\",\"bash\",\"$$(git rev-parse --show-toplevel)/.githooks/jj-push\"]"; \
	    echo "jj detected: 'jj push' runs the pre-push checks, then 'jj git push'"; \
	elif [ -d .jj ]; then \
	    echo "warn: .jj/ present but jj not on PATH; 'jj push' checks are not wired"; \
	fi
	@bash scripts/install-tools

validate:
	@bash .githooks/pre-commit --all-files

# Create a worktree whose commits satisfy the model identity policy.
# HARNESS selects an approved domain for a new model.
worktree:
	@[ -n "$(BRANCH)" ] && [ -n "$(IDENTITY)" ] \
	    || { echo "usage: make worktree BRANCH=change/x IDENTITY=<model-id> [HARNESS=<harness>]"; exit 2; }
	@set -e; \
	identity=$$(python3 scripts/author-identity.py resolve --policy authors.yaml \
	    --model '$(IDENTITY)' --harness '$(HARNESS)'); \
	name=$$(printf '%s' "$(BRANCH)" | tr '/' '-'); \
	author=$${identity% <*}; \
	address=$${identity##*<}; address=$${address%>}; \
	if [ -d .jj ]; then \
	    mkdir -p .workspaces; \
	    jj workspace add --name "$$name" ".workspaces/$$name"; \
	    echo "jj workspace .workspaces/$$name for $(BRANCH)"; \
	    echo "author with: export JJ_USER='$$author' JJ_EMAIL='$$address'"; \
	    echo "push with the jj push alias after: jj bookmark create $(BRANCH)"; \
	else \
	    git config extensions.worktreeConfig true; \
	    git worktree add ".worktrees/$$name" -b "$(BRANCH)"; \
	    git -C ".worktrees/$$name" config --worktree user.name "$$author"; \
	    git -C ".worktrees/$$name" config --worktree user.email "$$address"; \
	    echo "worktree .worktrees/$$name on $(BRANCH) authors as $$identity"; \
	fi

# Remove a worktree whose branch holds no unmerged commits, then
# delete the branch. Landing the work includes this step.
worktree-done:
	@[ -n "$(BRANCH)" ] || { echo "usage: make worktree-done BRANCH=change/x"; exit 2; }
	@set -e; \
	name=$$(printf '%s' "$(BRANCH)" | tr '/' '-'); \
	if [ -d .jj ]; then \
	    path=".workspaces/$$name"; \
	    [ -d "$$path" ] || { echo "no workspace at $$path"; exit 1; }; \
	    target_commit=$$(jj -R "$$path" log --no-graph -T 'commit_id' -r @); \
	    unmerged=$$(jj -R "$$path" log --no-graph -T 'change_id.short() ++ " "' -r 'mutable() & ::@ & ~empty() & ~::trunk()' 2>/dev/null); \
	    [ -z "$$unmerged" ] || { echo "workspace $$name holds unmerged changes: $$unmerged"; exit 1; }; \
	    git_directory=$$(git rev-parse --git-dir); \
	    target_index=$$(mktemp); \
	    rm -f "$$target_index"; \
	    trap 'rm -f "$$target_index"' 0 HUP INT TERM; \
	    GIT_INDEX_FILE="$$target_index" git --git-dir="$$git_directory" read-tree "$$target_commit"; \
	    ignored=$$(GIT_INDEX_FILE="$$target_index" git --git-dir="$$git_directory" --work-tree="$$path" ls-files --others -i --exclude-standard -- ':(top,exclude).jj/**'); \
	    rm -f "$$target_index"; \
	    trap - 0 HUP INT TERM; \
	    [ -z "$$ignored" ] || { echo "Workspace $$name contains ignored files. Preserve or remove them first."; exit 1; }; \
	    bookmarks=$$(jj -R "$$path" bookmark list -T 'if(remote, "", name ++ "\n")'); \
	    bookmark_exists=false; \
	    if printf '%s\n' "$$bookmarks" | grep -Fqx "$(BRANCH)"; then \
	        bookmark_exists=true; \
	    fi; \
	    if [ "$$bookmark_exists" = true ]; then \
	        bookmark_targets=$$(jj -R "$$path" bookmark list "exact:$(BRANCH)" -T 'if(remote, "", added_targets.map(|commit| commit.commit_id()).join("\n") ++ "\n")'); \
	        bookmark_unmerged=""; \
	        for bookmark_target in $$bookmark_targets; do \
	            target_unmerged=$$(jj -R "$$path" log --no-graph -T 'commit_id ++ "\n"' -r "::$$bookmark_target & ~empty() & ~::trunk()"); \
	            bookmark_unmerged="$$bookmark_unmerged$$target_unmerged"; \
	        done; \
	        [ -z "$$bookmark_unmerged" ] \
	            || { echo "Bookmark $(BRANCH) has commits that are not on trunk: $$bookmark_unmerged"; exit 1; }; \
	    fi; \
	    (command -v trash >/dev/null 2>&1 && trash "$$path") || rm -rf "$$path"; \
	    [ ! -e "$$path" ] || { echo "Could not remove workspace $$path."; exit 1; }; \
	    jj --ignore-working-copy workspace forget "$$name"; \
	    if [ "$$bookmark_exists" = true ]; then \
	        jj --ignore-working-copy bookmark forget "exact:$(BRANCH)"; \
	    fi; \
	    echo "removed workspace $$path"; \
	else \
	    path=".worktrees/$$name"; \
	    [ -d "$$path" ] || { echo "no worktree at $$path"; exit 1; }; \
	    dirty=$$(git -C "$$path" status --porcelain --ignored); \
	    [ -z "$$dirty" ] || { echo "The worktree at $$path has tracked, untracked, or ignored changes. Preserve them first."; exit 1; }; \
	    worktree_branch=$$(git -C "$$path" branch --show-current); \
	    [ -z "$$worktree_branch" ] || [ "$$worktree_branch" = "$(BRANCH)" ] \
	        || { echo "The worktree at $$path uses branch $$worktree_branch, not $(BRANCH)."; exit 1; }; \
	    git fetch origin; \
	    default=$$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null || echo origin/main); \
	    worktree_head=$$(git -C "$$path" rev-parse HEAD); \
	    branch_head=$$(git rev-parse "$(BRANCH)"); \
	    worktree_count=$$(git rev-list --count "$$default..$$worktree_head"); \
	    branch_count=$$(git rev-list --count "$$default..$(BRANCH)"); \
	    if [ "$$worktree_count" -ne 0 ] || [ "$$branch_count" -ne 0 ]; then \
	        [ "$$worktree_head" = "$$branch_head" ] \
	            || { echo "The detached worktree and $(BRANCH) have different unmerged heads."; exit 1; }; \
	        command -v gh >/dev/null 2>&1 \
	            || { echo "GitHub CLI is required to verify a possible squash merge."; exit 1; }; \
	        pr_records=$$(gh pr list --head "$(BRANCH)" --state all --limit 100 \
	            --json headRefOid,state --jq '.[] | "\(.headRefOid) \(.state)"') \
	            || { echo "Could not read pull requests for $(BRANCH)."; exit 1; }; \
	        matching_states=$$(printf '%s\n' "$$pr_records" \
	            | awk -v head="$$branch_head" '$$1 == head { print $$2 }'); \
	        if printf '%s\n' "$$matching_states" | grep -Fqx OPEN; then \
	            echo "$(BRANCH) still has an open pull request for $$branch_head."; \
	            exit 1; \
	        fi; \
	        printf '%s\n' "$$matching_states" | grep -Fqx MERGED \
	            || { echo "$(BRANCH) is not merged at $$branch_head."; exit 1; }; \
	    fi; \
	    git worktree remove "$$path"; \
	    git branch -D "$(BRANCH)"; \
	    echo "removed $$path and deleted $(BRANCH)"; \
	fi
