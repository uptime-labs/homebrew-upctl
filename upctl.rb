class Upctl < Formula
  desc "CLI tool for setting up local development environments using Kubernetes or Docker Compose"
  homepage "https://github.com/uptime-labs/upctl"
  license "MIT"  # Update this based on your actual license

  version "0.4.0"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_arm64"
      sha256 "2701ea4e51a59c852164ed41966e48b38ff59473de9fc4769e23358fd61a9cde"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_amd64"
      sha256 "f81e32b8d436c5e91e973ef1353f632f171a40ef3b7149debc4efc62bfb24e64"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_arm64"
      sha256 "60444774560dc01a747d0ad0ffb17302c3a1e3bdcdfc66a911fbeb3d807b3d34"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_amd64"
      sha256 "da1d6960dc33a5e66b7ea8cee1c5c16e70a05ef3d0f8e576ab3f8f586cfe1891"
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
