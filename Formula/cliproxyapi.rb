# Tracks every upstream release instead of homebrew-core, whose livecheck is
# throttled to every fifth tag. Installs the prebuilt release archive pinned by
# the SHA-256 that upstream publishes in checksums.txt; there is no signature
# or build attestation upstream, so the source tarball would carry the same
# trust. The prebuilt binary defaults to ./config.yaml, so the service passes
# -config explicitly and the config lives at the same path homebrew-core used.
class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Upstream also publishes Linux archives, but the Linux lane uses upstream's
  # own installer with systemd, so this formula stays macOS-only. Brew parses
  # the formula on Linux too, so a macOS archive is selected on every host
  # and the macOS dependency below blocks a Linux install. A top-level url
  # with an on_intel override fails brew audit, which reads the override as
  # a second stable url.
  if Hardware::CPU.intel?
    url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.41/CLIProxyAPI_8.0.41_darwin_amd64.tar.gz"
    sha256 "82c791b7f67680b7bf14a3336fef1d13a48b7ff55fe67ff79cfa36f013eabfde"
  else
    url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.41/CLIProxyAPI_8.0.41_darwin_aarch64.tar.gz"
    sha256 "aa6f88d7e27bacea8250802bf44b22c2e33ecb6e2a8f2c7d94f0b383ba6958bc"
  end

  depends_on :macos

  conflicts_with "cliproxyapi", because: "homebrew-core ships the same binary and config path"

  service do
    run [opt_bin/"cliproxyapi", "-config", etc/"cliproxyapi.conf"]
    keep_alive true
  end

  def install
    bin.install "cli-proxy-api" => "cliproxyapi"
    etc.install "config.example.yaml" => "cliproxyapi.conf"
    doc.install "README.md", "README_CN.md"
  end

  def caveats
    <<~EOS
      Config: #{etc}/cliproxyapi.conf (kept across upgrades; the example is
      only installed when the file is absent). Auth files and logs stay in
      ~/.cli-proxy-api. Upstream ships no signatures; the SHA-256 above is
      copied from the release's checksums.txt.
    EOS
  end

  test do
    assert_predicate bin/"cliproxyapi", :executable?
  end
end
