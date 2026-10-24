# Prunes cargo build folders every night. macOS debug builds keep the object
# files of every compile for debug info, and from Rust 1.88 each compile names
# them anew, so build folders grow without bound and cargo-sweep cannot remove
# them. rust-cache deletes the objects no binary uses, then runs cargo-sweep
# by age and by installed rustc. The service runs it at 04:00, and launchd
# runs a missed time once after the Mac wakes. The release archive is pinned
# by the SHA-256 in the release's checksums.txt.
class RustCache < Formula
  desc "Prune stale cargo build output, including leftover macOS debug objects"
  homepage "https://github.com/N4M3Z/rust-cache"
  url "https://github.com/N4M3Z/rust-cache/releases/download/v0.1.0/rust-cache-0.1.0.tar.gz"
  sha256 "cab0cc03f73b7e8bdf8433343589b9ec5844754e8d446fc15d6f9e5ac54b7d78"
  license "EUPL-1.2"

  livecheck do
    url :stable
    strategy :github_latest
  end

  depends_on "cargo-sweep"
  depends_on "fd"
  depends_on "jq"
  depends_on :macos

  def install
    bin.install "bin/rust-cache"
  end

  service do
    run opt_bin/"rust-cache"
    run_type :cron
    cron "0 4 * * *"
    process_type :background
    log_path var/"log/rust-cache.log"
    error_log_path var/"log/rust-cache.log"
  end

  test do
    assert_match "Usage: rust-cache", shell_output("#{bin}/rust-cache --help")
  end
end
