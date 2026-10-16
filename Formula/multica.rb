# Shadows multica-ai/tap/multica, whose GoReleaser formula ships no service
# block, so the local agent runtime daemon has to be started by hand after
# every login. This formula installs the same prebuilt release archive pinned
# by upstream's published SHA-256 and adds a brew service that runs the daemon
# in the foreground under launchd. The daemon only registers coding tools it
# finds on PATH at startup, and a launchd job gets a minimal PATH, so the
# service prepends ~/.local/bin where claude, codex, opencode, cursor-agent and
# grok are installed. --no-auto-update stops the daemon replacing its own
# binary inside the Cellar; its auto-reload still restarts it after a brew
# upgrade changes the version on disk. Install with the qualified name after
# uninstalling the upstream formula, because both link the same bin/multica.
class Multica < Formula
  desc "CLI and local agent runtime daemon for the Multica platform"
  homepage "https://github.com/multica-ai/multica"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  # Upstream also publishes Linux archives, but the daemon here runs on this
  # Mac only. Brew parses the formula on Linux too, so a macOS archive is
  # selected on every host and the macOS dependency below blocks a Linux
  # install. A top-level url with an on_intel override fails brew audit,
  # which reads the override as a second stable url.
  if Hardware::CPU.intel?
    url "https://github.com/multica-ai/multica/releases/download/v0.6.3/multica-cli-0.6.3-darwin-amd64.tar.gz"
    sha256 "b83b689517364d6f1b09634cdd17aa0cac4cd8628085c05d46bc519084df60eb"
  else
    url "https://github.com/multica-ai/multica/releases/download/v0.6.3/multica-cli-0.6.3-darwin-arm64.tar.gz"
    sha256 "c0124613b6727e8db6f21dbcac460d1dc3a54b6b8b6203177074a8fcea898e18"
  end

  depends_on :macos

  service do
    run [opt_bin/"multica", "daemon", "start", "--foreground", "--no-auto-update"]
    keep_alive true
    environment_variables PATH: "#{Dir.home}/.local/bin:#{std_service_path_env}"
    log_path var/"log/multica-daemon.log"
    error_log_path var/"log/multica-daemon.err.log"
  end

  def install
    bin.install "multica"
  end

  def caveats
    <<~EOS
      The daemon reads its server URL and login token from ~/.multica/config.json.
      Configure and log in once before starting the service:
        multica setup self-host --server-url <url> --app-url <url>
      Then:
        brew services start n4m3z/tap/multica
    EOS
  end

  test do
    assert_match "multica", shell_output("#{bin}/multica version")
  end
end
