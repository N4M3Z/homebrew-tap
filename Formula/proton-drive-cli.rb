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
    on_intel do
      url "https://proton.me/download/drive/cli/#{version}/darwin-x64/proton-drive", using: :nounzip
      sha256 "647f56db3f0559b6ac8031a9fce95c46537827940d684a7524a90d4fcbb428ff"
    end
  end

  on_linux do
    on_arm do
      url "https://proton.me/download/drive/cli/#{version}/linux-arm64/proton-drive", using: :nounzip
      sha256 "722e36559102dfb28d1897bff891961ea77ae62d63eee327bc6d132d41a2c217"
    end
    on_intel do
      url "https://proton.me/download/drive/cli/#{version}/linux-x64/proton-drive", using: :nounzip
      sha256 "89a54131a0811e42ea18ec43073d6eb347d80f594ed0226009bb94118f4cda86"
    end
  end

  def install
    bin.install "proton-drive"
  end

  test do
    assert_predicate bin/"proton-drive", :executable?
  end
end
