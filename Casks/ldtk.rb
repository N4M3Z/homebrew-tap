cask "ldtk" do
  version "1.5.3"
  sha256 "d8f8ab8f7e2001a64d7db04eac8d68ec305fd21d3404a2d40d9e0377aa5dac62"

  url "https://github.com/deepnight/ldtk/releases/download/v#{version}/mac-distribution.zip",
      verified: "github.com/deepnight/ldtk/"
  name "LDtk"
  desc "Level editor for 2D side-view and top-down games"
  homepage "https://ldtk.io/"

  livecheck do
    url :url
    strategy :github_latest
  end

  # Universal build (x86_64 and arm64), so no architecture restriction.
  depends_on :macos
  # Upstream publishes no checksums.txt, so the sha256 is taken from the
  # downloaded release asset. The zip holds one installer image per version.
  container nested: "LDtk #{version} installer.dmg"

  app "LDtk.app"

  caveats <<~EOS
    LDtk is not signed or notarized, so macOS quarantines it and blocks the
    first launch. Clear the attribute once:

      xattr -dr com.apple.quarantine "#{appdir}/LDtk.app"
  EOS
end
