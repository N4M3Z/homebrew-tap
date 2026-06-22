# Official Proton Drive command-line client (notarized binary from Proton AG).
# Distributed by Proton only as a per-platform binary, no source tarball or
# GitHub release asset, so this formula pins the signed download by SHA-256.
class ProtonDriveCli < Formula
  desc "Official command-line client for Proton Drive"
  homepage "https://proton.me/drive"
  version "0.4.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://proton.me/download/drive/cli/#{version}/darwin-arm64/proton-drive", using: :nounzip
      sha256 "7f579ff56aa57657f68f27ff70e322388874f57a52df6396524b14de763ce33c"
    end
  end

  def install
    bin.install "proton-drive"
  end

  test do
    assert_predicate bin/"proton-drive", :executable?
  end
end
