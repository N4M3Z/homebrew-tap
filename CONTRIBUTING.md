# Contributing

## Getting Started

```sh
git clone https://github.com/N4M3Z/homebrew-tap.git
cd homebrew-tap
make install    # activates the git hooks and the jj push alias
```

## Conventions

See [README.md](README.md) for project-specific conventions.

## Git

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope.

Types: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`.

## Pull Requests

1. Fork and create a branch
2. Make changes following the conventions above
3. `make validate`
4. Open a PR against `main` **as a draft**, and mark it ready when the tree is stable

CI runs validation on every PR. The `main` branch requires passing CI before merge. The body carries a `## Release Notes` section (`- N/A` when nothing is user-facing). Write PR text the way a diff summarizer would: verb-first, factual, file-anchored bullets, claims the diff upholds, no narrative. Do not append a generation footer, a tool badge, or a session link to the body or to a commit message. Attribution lives in the author line and the `authors.yaml` trailers.

## Review etiquette

Iterate in draft, collect fixes locally, push them as one batch, and request a fresh review round only when the tree is stable. A fix commit may name the review thread it answers with a `Resolves-Thread: <value>` trailer, where the value is the finding comment's URL, its numeric comment id, or the thread's GraphQL node id; the thread resolves automatically on push. Only threads on the same pull request resolve.

## Review bots

No bot reviews without a request: every lane starts only when a maintainer applies a review label. Bare `review` runs the full ordered sequence, cursor, then macroscope, then the adjudicating correctness lane, while `review:runeseer`, `review:macroscope`, and `review:autofix` summon a single lane. Each request runs one round, and the review labels are consumed when it ends. Settled stages record `stage:` labels and are skipped on later rounds until a maintainer removes them. Every requested round is visible in the pull request timeline.
