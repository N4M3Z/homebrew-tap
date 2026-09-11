# Tracks every upstream release instead of homebrew-core, whose livecheck is
# throttled to every fifth tag. Installs the prebuilt release archive pinned by
# the SHA-256 that upstream publishes in checksums.txt; there is no signature
# or build attestation upstream, so the source tarball would carry the same
# trust. The prebuilt binary defaults to ./config.yaml, so the service passes
# -config explicitly and the config lives at the same path homebrew-core used.
class Cliproxyapi < Formula
  desc "Wrap Gemini CLI, Codex, Claude Code, Qwen Code as an API service"
  homepage "https://github.com/router-for-me/CLIProxyAPI"
  version "7.2.158"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_arm do
      url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v7.2.158/CLIProxyAPI_7.2.158_darwin_aarch64.tar.gz"
      sha256 "ac8b4cc36294a88fc1ef631de03b097bef6713d8172b66630ac2727e90faf58b"
    end
    on_intel do
      url "https://github.com/router-for-me/CLIProxyAPI/releases/download/v7.2.158/CLIProxyAPI_7.2.158_darwin_amd64.tar.gz"
      sha256 "e7648e73efcecd4eedb6f1dc45d777537594bc0ecece15dd49932b594593fca3"
    end
  end

  # Only the darwin archives are pinned below, so the formula has no url on
  # Linux and brew reads it as malformed there. This marks it macOS-only.
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
