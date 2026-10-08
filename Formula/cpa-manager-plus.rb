# Upstream ships prebuilt release binaries only; this formula pins the
# darwin/arm64 tarball by SHA-256. The binary resolves its data directory
# relative to argv[0] without resolving symlinks, so the real executable
# lives in libexec and bin carries a wrapper that invokes it through a
# symlink inside CPAMP_HOME.
class CpaManagerPlus < Formula
  desc "Self-hosted CPA management panel and AI gateway observability dashboard"
  homepage "https://github.com/seakee/CPA-Manager-Plus"
  # Select a macOS archive on every host so Linux can parse the formula.
  # The macOS dependency below prevents installation on Linux.
  if Hardware::CPU.intel?
    url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.14.4/cpa-manager-plus_v1.14.4_darwin_amd64.tar.gz"
    sha256 "ea55a5e85ceeaf63f430d965727bff5de7c85c4305f6e4d3d1eb9c87af6410d1"
  else
    url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.14.4/cpa-manager-plus_v1.14.4_darwin_arm64.tar.gz"
    sha256 "1ae54030965ea850195d6e0c62a1f2a2e319b220524fbccb60de36cb046f5a14"
  end
  license "MIT"

  livecheck do
    url :stable
    strategy :github_latest
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
