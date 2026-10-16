# Contributing

## Getting started

```sh
git clone https://github.com/N4M3Z/homebrew-tap.git
cd homebrew-tap
make install    # check tools and git hooks
```

## Adding a formula

1. Write `Formula/<name>.rb`. Pin release archives by the `sha256` upstream publishes.
2. `HOMEBREW_DEVELOPER=1 brew install --build-from-source ./Formula/<name>.rb`, then `brew test <name>`.
   Homebrew refuses a formula file path unless `HOMEBREW_DEVELOPER` is set.
   This installs into your real Homebrew, so `make ci` leaves it out.
3. Add the formula to `README.md`, and to the matrix in `.github/workflows/bump.yml` when upstream publishes a `checksums.txt`.
4. `make ci`, then open a pull request.

## Bumping a formula

The bump workflow does this every six hours. By hand:

```sh
bin/bump-release Formula/<name>.rb
```

It prints nothing when the formula is current.

## Git

Conventional Commits: `type: description`. Lowercase, no trailing period, no scope. Types: `feat`, `fix`, `docs`, `chore`.

The push hook runs gitleaks and the authorship check. Commits carry an author from `authors.yaml`.

## Pull requests

`brew test-bot` runs on every pull request. The body carries a `## Release Notes` section (`- N/A` when nothing is user-facing).
