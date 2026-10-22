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
  # Brew parses the formula on Linux too, so a macOS archive is selected on
  # every host and the macOS dependency below blocks a Linux install. A
  # top-level url with an on_intel override fails brew audit, which reads
  # the override as a second stable url.
  if Hardware::CPU.intel?
    url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.14.9/cpa-manager-plus_v1.14.9_darwin_amd64.tar.gz"
    sha256 "8ecd8a1bd0d0879d3838ed0f489db57c6473ace73cc01d9e879a8b440e4da919"
  else
    url "https://github.com/seakee/CPA-Manager-Plus/releases/download/v1.14.9/cpa-manager-plus_v1.14.9_darwin_arm64.tar.gz"
    sha256 "1dd9dbeadbf00ea5509dbfba196f633e60480229ce1a5cd554c85649e42a0410"
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
