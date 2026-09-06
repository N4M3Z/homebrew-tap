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

### cliproxyapi

[CLIProxyAPI](https://github.com/router-for-me/CLIProxyAPI), the local AI
gateway. homebrew-core carries it too, but its livecheck is throttled to every
fifth tag while upstream ships several releases a day. This formula tracks
every release from the prebuilt archives and their published `checksums.txt`.
It conflicts with the core formula; uninstall that one first.

```sh
brew install N4M3Z/tap/cliproxyapi
brew services start N4M3Z/tap/cliproxyapi
```

Config stays at `$(brew --prefix)/etc/cliproxyapi.conf`; the service passes
`-config` because the prebuilt binary otherwise reads `./config.yaml`.

### cpa-manager-plus

[CPA-Manager-Plus](https://github.com/seakee/CPA-Manager-Plus), the usage
dashboard beside CLIProxyAPI. Upstream ships binaries only, no Homebrew
formula. Data lives in `~/.cpa-manager-plus`.

```sh
brew install N4M3Z/tap/cpa-manager-plus
brew services start N4M3Z/tap/cpa-manager-plus
```

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

## Release bumps

`bin/bump-release Formula/<name>.rb` rewrites a binary-release formula to the
latest GitHub release, taking every `sha256` from the release's
`checksums.txt`. The `bump releases` workflow runs it every six hours and
opens a pull request per bumped formula, so `brew test-bot` runs before the
change reaches `main`. Merge the pull request, then `brew update` and
`brew upgrade` as usual.

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
