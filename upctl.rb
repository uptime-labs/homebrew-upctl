class Upctl < Formula
  desc "CLI tool for setting up local development environments using Kubernetes or Docker Compose"
  homepage "https://github.com/uptime-labs/upctl"
  license "MIT"  # Update this based on your actual license

  version "0.5.0"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_arm64"
      sha256 "0d241ef892ff78280525d97b10ed5b96edd654207e1131f1f2d16aa72c6e3891"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_amd64"
      sha256 "06f8b0d18333665a7ff0afeb6be665280888cc778162a8c7ab584f4a968f6bc9"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_arm64"
      sha256 "4c57cab38994232b16e97922892ef4dda85c812a4912eaab4cfeb97216bf8935"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_amd64"
      sha256 "fe50959edf5f445c7789bd108dc355b68ec74ec2713ab750d70afc9ed651fc3a"
    end
  end

  depends_on "kubectl" => :recommended
  depends_on "mysql-client" => :recommended
  depends_on "awscli" => :recommended
  depends_on "docker" => :recommended
  depends_on "helm" => :recommended

  def install
    bin.install Dir["*"].first => "upctl"
  end

  def post_install
    (buildpath/"upctl.yaml").write <<~EOS
      repositories:
        - name: example
          url: https://example.com/charts
      
      packages:
        - name: example
          chart: example/example
          version: 1.0.0
      
      docker_compose:
        version: '3.8'
        services:
          example:
            image: example/example:latest
            ports:
              - "8080:8080"
            restart: unless-stopped
    EOS

    mkdir_p "\#{Dir.home}/.upctl"
    cp "upctl.yaml", "\#{Dir.home}/.upctl.yaml" unless File.exist?("\#{Dir.home}/.upctl.yaml")
  end

  test do
    assert_match "upctl version", shell_output("\#{bin}/upctl version")
  end
end
