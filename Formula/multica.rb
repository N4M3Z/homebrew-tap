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
    url "https://github.com/multica-ai/multica/releases/download/v0.10.0/multica-cli-0.10.0-darwin-amd64.tar.gz"
    sha256 "e8eba90e295ab00ad8accd3cc4851a895335abe7e8846dfa8b9d7685f4ef00ab"
  else
    url "https://github.com/multica-ai/multica/releases/download/v0.10.0/multica-cli-0.10.0-darwin-arm64.tar.gz"
    sha256 "ddf7a6f7f59f90bf844edff92428e45affa0a80a40b93bed86ab9218d297c9f7"
  end

  depends_on :macos

  service do
    run [opt_bin/"multica", "daemon", "start", "--foreground", "--no-auto-update"]
    keep_alive true
    # Run workspaces default to ~/multica_workspaces, a visible folder in the
    # home directory. Keep them under the XDG data directory instead.
    environment_variables PATH:                    "#{Dir.home}/.local/bin:#{std_service_path_env}",
                          MULTICA_WORKSPACES_ROOT: "#{Dir.home}/.local/share/multica/workspaces"
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
