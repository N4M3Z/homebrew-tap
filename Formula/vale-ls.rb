# The Vale language server. Upstream publishes prebuilt archives per target
# and no checksums file; the SHA-256 values below match the digest GitHub
# records for each release asset. There is no Homebrew formula upstream and
# none in homebrew-core.
class ValeLs < Formula
  desc "Language Server Protocol implementation for the Vale prose linter"
  homepage "https://github.com/vale-cli/vale-ls"
  # Select a macOS archive on every host so Linux can parse the formula.
  # The macOS dependency below prevents installation on Linux.
  if Hardware::CPU.intel?
    url "https://github.com/vale-cli/vale-ls/releases/download/v0.6.0/vale-ls-x86_64-apple-darwin.zip"
    sha256 "af4885d9d844b327a2fdc42a1bae899a84fb51b5ac8b59081d00ad1eb418015a"
  else
    url "https://github.com/vale-cli/vale-ls/releases/download/v0.6.0/vale-ls-aarch64-apple-darwin.zip"
    sha256 "ff0ffde21a5f5505aa1fc5eeb31accc4b3867c4968df5ff1d8e7d86d970c754e"
  end
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on :macos
  depends_on "vale"

  def install
    bin.install "vale-ls"
  end

  test do
    assert_match "vale-ls #{version}", shell_output("#{bin}/vale-ls --version")
  end
end
