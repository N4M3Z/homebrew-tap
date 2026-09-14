---
title: Ceremony Conventions
model: claude-opus-5
input: full_diff
tools:
    - browse_code
    - git_tools
    - github_api_read_only
include:
    - ".github/workflows/**"
    - ".githooks/*"
    - ".gitleaks.toml"
    - "templates/base/.github/workflows/**"
    - "templates/base/.githooks/*"
    - "templates/base/.gitleaks.toml"
    - "**/*.sh"
conclusion: failure
showToolCalls: true
---

# Workflow and hook review

Review changed GitHub Actions workflows, git hooks, and shell scripts for
the conventions below. Flag violations in touched code only; do not demand
unrelated repository-wide cleanup.

## Trust boundaries

- Untrusted pull request code never meets secrets: jobs that check out and
  execute head code trigger on pull_request, and pull_request_target jobs
  are API-only and never check out the head.
- Checkouts that execute head code set persist-credentials: false.
- workflow_call secrets are declared required: true; fork handling lives in
  job guards and in GitHub stripping fork secrets, not in the secret
  contract.
- Third-party actions pin a full commit SHA with a version comment.
- Input that reaches a reviewing model is filtered to known bot authors
  before the model sees it.

## Event semantics

- Concurrency cancel expressions scope to the exact label namespace: the
  label name equals the entry label or starts with its namespaced prefix,
  never a bare startsWith on the shared prefix.
- Review labels request one round and are consumed when the round ends,
  including failed rounds, and deleted with the workflow token so the
  deletion event triggers nothing.
- Verdict gates validate the full tuple: verdict value, zero count, empty
  findings, and a head SHA matched against the live pull request head.

## Runner and shell

- Paginate gh output with per-page --jq arrays merged through jq -s 'add';
  the hosted runner's gh predates --slurp.
- GraphQL bot logins are bare (cursor, macroscopeapp), never the
  REST-style [bot] suffix.
- Hooks preserve their stdin protocol: extensions run with stdin
  redirected from /dev/null and only when the hook received arguments.
- Regexes that gate security decisions anchor their match; gitleaks
  allowlist paths start with ^.
- Four-space indentation, no tab characters outside Makefile recipes, and
  every text file ends with a newline.
