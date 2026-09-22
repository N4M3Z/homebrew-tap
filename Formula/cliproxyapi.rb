# Tracks every upstream release instead of homebrew-core, whose livecheck is
# throttled to every fifth tag. Installs the prebuilt release archive pinned by
# the SHA-256 that upstream publishes in checksums.txt; there is no signature
# or build attestation upstream, so the source tarball would carry the same
# trust. The prebuilt binary defaults to ./config.yaml, so the service passes
# -config explicitly and the config lives at the same path homebrew-core used.
class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  version "7.3.14"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Upstream also publishes Linux archives, but the Linux lane uses upstream's
  # own installer with systemd, so this formula stays macOS-only. A formula
  # still needs a url on every platform or brew rejects it as malformed, so the
  # Apple silicon archive is the default and depends_on blocks a Linux install.
  url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v7.3.14/CLIProxyAPI_7.3.14_darwin_aarch64.tar.gz"
  sha256 "ec45cffb882ef94f2c80b897767b376fea57e025ff28cef118453d58d4c83964"

  on_intel do
    url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v7.3.14/CLIProxyAPI_7.3.14_darwin_amd64.tar.gz"
    sha256 "b26eab8b7877a10e8a24e4ddcc136a3ea842914da7822985b2d36a9639a39e8b"
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
