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
- A formula that pins only macOS archives selects them with `if Hardware::CPU.intel?` and `else`,
  then adds `depends_on :macos`. Brew parses formulae on Linux too, so a `url` must exist there.
  `brew style` rejects a `url` inside `on_intel`. `bin/bump-release` rewrites the `if` layout.
- No `version` stanza when the version is readable from the URL. `brew audit` rejects it.
- Start no comment line with `depends_on`. `brew style` reads it as a commented-out dependency.
- Before a push, run `brew style n4m3z/tap` and `brew audit --tap=n4m3z/tap`, with output
  redirected to a file. test-bot runs both. Never pipe brew output.
- Pin every third-party action to a full commit SHA with a version comment.
- Commit format: `type: description` (feat, fix, docs, chore), lowercase, no scope.
- `make install` once after cloning, `make validate` before a commit.
