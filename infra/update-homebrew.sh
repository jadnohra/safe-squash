#!/bin/bash
#
# update-homebrew.sh - Manually update Homebrew tap
#
# Usage: ./infra/update-homebrew.sh v1.0.0
#

set -e

# Save original directory
ORIGINAL_DIR="$(pwd)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SAFE_SQUASH_DIR="$(dirname "$SCRIPT_DIR")"
HOMEBREW_TAP_DIR="$(dirname "$SAFE_SQUASH_DIR")/homebrew-tap"

if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

VERSION="${1#v}"  # Remove 'v' prefix if present
TARBALL_URL="https://github.com/jadnohra/safe-squash/archive/refs/tags/v${VERSION}.tar.gz"

echo "Calculating SHA256 for version ${VERSION}..."
SHA256=$(curl -fsSL "$TARBALL_URL" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$SHA256" ]; then
    echo "Error: Failed to calculate SHA256"
    exit 1
fi

echo "SHA256: $SHA256"
echo ""

# Check if tap directory exists
if [ ! -d "$HOMEBREW_TAP_DIR" ]; then
    echo "Cloning homebrew-tap repository to: $HOMEBREW_TAP_DIR"
    git clone https://github.com/jadnohra/homebrew-tap.git "$HOMEBREW_TAP_DIR"
fi

cd "$HOMEBREW_TAP_DIR" || exit 1

# Pull latest
git pull

# Create formula directory if it doesn't exist
mkdir -p Formula

# Write formula
cat > Formula/safe-squash.rb <<EOF
class SafeSquash < Formula
  desc "Simple, robust tool to squash all commits on your branch into one"
  homepage "https://github.com/jadnohra/safe-squash"
  url "${TARBALL_URL}"
  sha256 "${SHA256}"
  license "MIT"

  def install
    bin.install "safe-squash"
  end

  test do
    assert_match "safe-squash", shell_output("#{bin}/safe-squash --help")
  end
end
EOF

echo "Formula updated!"
echo ""
echo "Review changes:"
cat Formula/safe-squash.rb
echo ""
echo "Next steps:"
echo "  cd \"$HOMEBREW_TAP_DIR\""
echo "  git add Formula/safe-squash.rb"
echo "  git commit -m \"Update safe-squash to ${VERSION}\""
echo "  git push"
echo ""
echo "Current directory: $(pwd)"
