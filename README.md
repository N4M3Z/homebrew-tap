# N4M3Z Homebrew Tap

Personal Homebrew tap for formulae that are not in homebrew-core, mainly
upstream tools distributed only as signed binaries.

## Formulae

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
brew tap N4M3Z/tap
brew install N4M3Z/tap/<formula>
```

Or in a `brew bundle` Brewfile:

```ruby
tap "N4M3Z/tap"
brew "N4M3Z/tap/proton-drive-cli"
```
