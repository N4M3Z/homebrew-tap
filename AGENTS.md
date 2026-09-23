# N4M3Z Homebrew Tap

> Brief: Personal Homebrew tap for formulae that are not in homebrew-core.

## Layout

- `Formula/*.rb` and `Casks/*.rb` are the product. Everything else keeps them correct.
- `bin/bump-release Formula/<name>.rb` moves a binary-release formula to the latest
  GitHub release, taking every `sha256` from the release's `checksums.txt`.
- `.github/workflows/bump.yml` runs that script every six hours and opens one pull
  request per bumped formula as `runewright[bot]`.
- `.github/workflows/tests.yml` runs `brew test-bot` on every push and pull request.

## Rules

- Never edit a `sha256` by hand. Run `bin/bump-release` or copy from upstream `checksums.txt`.
- A formula that pins only macOS archives keeps a top-level `url` and `depends_on :macos`.
  Without a top-level `url`, brew rejects the formula on Linux.
- No `version` stanza when the version is readable from the URL. `brew audit` rejects it.
- Pin every third-party action to a full commit SHA with a version comment.
- Commit format: `type: description` (feat, fix, docs, chore), lowercase, no scope.
- `make install` once after cloning, `make validate` before a commit.
