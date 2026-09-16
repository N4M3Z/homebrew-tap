# Upstream ships prebuilt release binaries only; this formula pins the
# darwin/arm64 tarball by SHA-256. The binary resolves its data directory
# relative to argv[0] without resolving symlinks, so the real executable
# lives in libexec and bin carries a wrapper that invokes it through a
# symlink inside CPAMP_HOME.
class CpaManagerPlus < Formula
  desc "Self-hosted CPA management panel and AI gateway observability dashboard"
  homepage "https://github.com/seakee/CPA-Manager-Plus"
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Upstream also publishes Linux archives, but only macOS is supported here.
  # A formula still needs a url on every platform or brew rejects it as
  # malformed, so the Apple silicon archive is the default and depends_on
  # blocks a Linux install.
  url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.12.14/cpa-manager-plus_v1.12.14_darwin_arm64.tar.gz"
  sha256 "e64563114a033c48b2afad118f7c5b5ae55f09e570fc20e3f466c947fb5e0b8c"

  on_intel do
    url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.12.14/cpa-manager-plus_v1.12.14_darwin_amd64.tar.gz"
    sha256 "3791d86fa6d02702c37131034797296abd4ff538b54ea68102bcb65fa70878b7"
  end

  depends_on :macos

  service do
    run opt_bin/"cpa-manager-plus"
    keep_alive true
    log_path var/"log/cpa-manager-plus.log"
    error_log_path var/"log/cpa-manager-plus.err.log"
  end

  def install
    libexec.install "cpa-manager-plus"
    doc.install "README.md", "README_CN.md", "docs"

    (bin/"cpa-manager-plus").write <<~EOS
      #!/bin/bash
      set -euo pipefail
      CPAMP_HOME="${CPAMP_HOME:-$HOME/.cpa-manager-plus}"
      mkdir -p "$CPAMP_HOME"
      ln -sfn "#{opt_libexec}/cpa-manager-plus" "$CPAMP_HOME/cpa-manager-plus"
      cd "$CPAMP_HOME"
      exec ./cpa-manager-plus "$@"
    EOS
    chmod 0555, bin/"cpa-manager-plus"
  end

  def caveats
    <<~EOS
      Data and config live in $CPAMP_HOME (default ~/.cpa-manager-plus).
      The wrapper in #{opt_bin} refreshes a symlink there on every run so the
      server finds data/ and config.json beside the executable it was invoked as.
    EOS
  end

  test do
    assert_predicate libexec/"cpa-manager-plus", :executable?
    assert_match "#{opt_libexec}/cpa-manager-plus", (bin/"cpa-manager-plus").read
  end
end
