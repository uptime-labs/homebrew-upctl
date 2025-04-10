class Upctl < Formula
  desc "CLI tool for setting up local development environments using Kubernetes or Docker Compose"
  homepage "https://github.com/uptime-labs/upctl"
  license "MIT"  # Update this based on your actual license

  version "0.3.2"

  if OS.mac?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_arm64"
      sha256 "bbe3ca993f42df4d152226188ef88f23c281d8ae580af939f08464d62de807ea"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_darwin_amd64"
      sha256 "e9b29ca5fe15633cc85fae0ecc8ebb8453990419abc56fa79bfd63823950948e"
    end
  elsif OS.linux?
    if Hardware::CPU.arm?
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_arm64"
      sha256 "35306f689b17484124793b1cc4fc4eda7f2e2c4a42085625f426f4b37140be52"
    else
      url "https://github.com/uptime-labs/upctl/releases/download/v#{version}/upctl_#{version}_linux_amd64"
      sha256 "d94bf0240ff7ee1dc4ac702d6c7f148f80a1ce58ecb56133b5f8306d7a53e6d3"
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
