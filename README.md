# N4M3Z Homebrew Tap

Personal Homebrew tap for formulae that are not in homebrew-core — upstream
tools distributed only as signed binaries, or forked for a stable build.

> Recent Homebrew refuses to load formulae from an untrusted third-party tap.
> Trust this tap once before installing:
>
> ```sh
> brew trust N4M3Z/tap
> ```

## Formulae

### otel-tui

Terminal OpenTelemetry viewer. A verbatim rebuild of upstream
[ymtdzzz/otel-tui](https://github.com/ymtdzzz/otel-tui) (Apache-2.0) at a stable
commit past the `0.7.3` release, which crashes under a sustained multi-harness
OTLP stream. No code changes — the fix is upstream dependency bumps that never
shipped in a release.

```sh
brew install N4M3Z/tap/otel-tui
otel-tui --disable-internal-metrics
```

Fork and releases: [N4M3Z/otel-tui](https://github.com/N4M3Z/otel-tui).

### proton-drive-cli

The official Proton Drive command-line client (binary `proton-drive`). Proton
ships it only as a per-platform notarized binary (no source tarball, no GitHub
release asset), so this formula pins the signed download by SHA-256. The binary
is code-signed and notarized by Proton AG (Team ID `2SB5Z68H26`).

```sh
brew install N4M3Z/tap/proton-drive-cli
proton-drive auth login
```

Not to be confused with the `proton-drive` Homebrew cask, which is the GUI app.

## Install

```sh
brew trust N4M3Z/tap
brew tap N4M3Z/tap
brew install N4M3Z/tap/<formula>
```

Or in a `brew bundle` Brewfile (run `brew trust N4M3Z/tap` first):

```ruby
tap "N4M3Z/tap"
brew "N4M3Z/tap/otel-tui"
brew "N4M3Z/tap/proton-drive-cli"
```
