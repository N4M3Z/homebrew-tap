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
  # own installer with systemd, so this formula stays macOS-only. A formula
  # still needs a url on every platform or brew rejects it as malformed, so the
  # Apple silicon archive is the default and depends_on blocks a Linux install.
  url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.10/CLIProxyAPI_8.0.10_darwin_aarch64.tar.gz"
  sha256 "e2080f54ee4d7940c77345440956ce592eef34da2910bd865d4928b75accd122"

  on_intel do
    url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v8.0.10/CLIProxyAPI_8.0.10_darwin_amd64.tar.gz"
    sha256 "2d5af1cf19cc0d887b96fde809f78a999438a65564ce19de5966b7d5b6c451ca"
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
