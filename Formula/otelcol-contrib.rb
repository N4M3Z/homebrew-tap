# frozen_string_literal: true

# The OpenTelemetry Collector Contrib distribution: the collector with the
# ClickHouse exporter, the filelog receiver and the file_storage extension,
# which the cortex machine needs (runedeck/provision PROV-0027). homebrew-core
# carries no collector. Installs the prebuilt release archive pinned by the
# SHA-256 that upstream publishes beside each archive (<asset>.sha256).
# Upstream also publishes Sigstore bundles; this formula checks the hash only.
class OtelcolContrib < Formula
  desc "OpenTelemetry Collector Contrib distribution"
  homepage "https://github.com/open-telemetry/opentelemetry-collector-releases"
  version "0.164.0"
  license "Apache-2.0"

  livecheck do
    url :homepage
    strategy :github_latest
  end

  # A top-level url with an on_intel override fails brew audit, which reads
  # the override as a second stable url (see cliproxyapi.rb).
  if Hardware::CPU.intel?
    url "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.164.0/otelcol-contrib_0.164.0_darwin_amd64.tar.gz"
    sha256 "b53ab416e9a90625c1453692f1d3a3c4eba72904424e31516866f73064b65d4f"
  else
    url "https://github.com/open-telemetry/opentelemetry-collector-releases/releases/download/v0.164.0/otelcol-contrib_0.164.0_darwin_arm64.tar.gz"
    sha256 "af6a0c56886e3cc36ccebe849fa167bad2bc47a97a48fd8497a0d6f93d0cf73a"
  end

  depends_on :macos

  def install
    bin.install "otelcol-contrib"
    doc.install "README.md"
  end

  def caveats
    <<~EOS
      No service block: the agents machine runs the collector as a root-owned
      LaunchDaemon under its own role account, with its own config file.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/otelcol-contrib --version")
  end
end
