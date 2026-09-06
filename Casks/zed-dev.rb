cask "zed-dev" do
  version "1.15.0-personal.1"
  sha256 "c03b3f5f74cd7dd6c6aa01cef9b8a59d25419555dabc7957a1a20111b2cca57d"

  url "https://github.com/N4M3Z/zed/releases/download/v#{version}/Zed-aarch64.dmg"
  name "Zed Dev"
  desc "Personal Zed build with review annotations and terminal patches"
  homepage "https://github.com/N4M3Z/zed"

  livecheck do
    url :url
    strategy :github_latest
  end

  # The dev channel never self-updates from this fork, so every upgrade is a
  # new cask version. Built only for Apple silicon.
  auto_updates false
  depends_on arch: :arm64
  depends_on macos: :catalina

  app "Zed Dev.app"

  # Installs as its own app and bundle id (dev.zed.Zed-Dev), so it sits beside
  # the official Zed cask rather than replacing it. Config in ~/.config/zed is
  # shared with the other channels; only the workspace database is separate,
  # which is why the zap below touches nothing else.
  zap trash: [
    "~/Library/Application Support/Zed/db/0-dev",
    "~/Library/Caches/dev.zed.Zed-Dev",
    "~/Library/Saved Application State/dev.zed.Zed-Dev.savedState",
  ]

  caveats <<~EOS
    This build is ad-hoc signed, not notarized, so macOS quarantines it and
    first launch fails with a damaged-app warning. Clear the attribute once:

      xattr -dr com.apple.quarantine "#{appdir}/Zed Dev.app"

    Stable and preview read the same ~/.config/zed/keymap.json, so any binding
    for this build's actions is reported as unknown there. That is expected.
  EOS
end
