class SafeSquash < Formula
  desc "Simple, robust tool to squash all commits on your branch into one"
  homepage "https://github.com/jadnohra/safe-squash"
  url "https://github.com/jadnohra/safe-squash/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_SHA256"
  license "MIT"

  def install
    bin.install "safe-squash"
  end

  test do
    assert_match "safe-squash", shell_output("#{bin}/safe-squash --help")
  end
end
