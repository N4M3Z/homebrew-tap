# Install

Trust the tap once, then install any formula from it.

```sh
brew trust N4M3Z/tap
brew tap N4M3Z/tap
brew install N4M3Z/tap/cliproxyapi
brew install N4M3Z/tap/cpa-manager-plus
```

Both are background services:

```sh
brew services start N4M3Z/tap/cliproxyapi
brew services start N4M3Z/tap/cpa-manager-plus
```

## Upgrade

```sh
brew update
brew services stop N4M3Z/tap/cpa-manager-plus
brew upgrade N4M3Z/tap/cliproxyapi N4M3Z/tap/cpa-manager-plus
brew services start N4M3Z/tap/cpa-manager-plus
```

Stop cpa-manager-plus first. It polls cliproxyapi twice a second, and a
cliproxyapi upgrade under that load times out on shutdown and comes back
stopped. If it does, run `brew services stop` then `start` for cliproxyapi.

## Brewfile

```ruby
tap "N4M3Z/tap"
brew "N4M3Z/tap/cliproxyapi"
brew "N4M3Z/tap/cpa-manager-plus"
```

## Develop

```sh
git clone https://github.com/N4M3Z/homebrew-tap.git
cd homebrew-tap
make install    # check tools and git hooks
make validate   # the commit-stage checks
```
