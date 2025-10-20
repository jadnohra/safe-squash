#!/bin/bash
#
# test-homebrew.sh - Test Homebrew formula before releasing
#
# This validates the formula will work before pushing to production
#

set -e

# Save original directory
ORIGINAL_DIR="$(pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Homebrew Formula Test"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get version
if [ -z "$1" ]; then
    echo "Usage: $0 <version>"
    echo "Example: $0 v1.0.0"
    exit 1
fi

VERSION="${1#v}"
TARBALL_URL="https://github.com/jadnohra/safe-squash/archive/refs/tags/v${VERSION}.tar.gz"

echo "Testing formula for version: ${VERSION}"
echo ""

# Step 1: Check if tag exists
echo "Step 1: Checking if tag exists..."
if git ls-remote --tags origin | grep -q "refs/tags/v${VERSION}"; then
    echo "✓ Tag v${VERSION} exists"
else
    echo "✗ Tag v${VERSION} not found on GitHub"
    echo "  Create it with:"
    echo "    git tag v${VERSION}"
    echo "    git push origin v${VERSION}"
    exit 1
fi

# Step 2: Download tarball and calculate SHA256
echo ""
echo "Step 2: Calculating SHA256..."
SHA256=$(curl -fsSL "$TARBALL_URL" | shasum -a 256 | cut -d' ' -f1)

if [ -z "$SHA256" ]; then
    echo "✗ Failed to download tarball or calculate SHA256"
    exit 1
fi

echo "✓ SHA256: $SHA256"

# Step 3: Create test formula
echo ""
echo "Step 3: Creating test formula..."
TEST_DIR=$(mktemp -d)
mkdir -p "$TEST_DIR/Formula"

cat > "$TEST_DIR/Formula/safe-squash.rb" <<EOF
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

echo "✓ Formula created"

# Step 4: Validate Ruby syntax
echo ""
echo "Step 4: Validating Ruby syntax..."
if ruby -c "$TEST_DIR/Formula/safe-squash.rb" > /dev/null 2>&1; then
    echo "✓ Ruby syntax valid"
else
    echo "✗ Ruby syntax error in formula"
    cat "$TEST_DIR/Formula/safe-squash.rb"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Step 5: Test with Homebrew (if available)
echo ""
echo "Step 5: Testing with Homebrew..."
if command -v brew > /dev/null 2>&1; then
    echo "Installing from test formula..."

    # Try to install
    if brew install --formula "$TEST_DIR/Formula/safe-squash.rb" 2>&1 | tee /tmp/brew-test.log; then
        echo "✓ Installation successful"

        # Test the installed binary
        echo ""
        echo "Testing installed binary..."
        if safe-squash --help > /dev/null 2>&1; then
            echo "✓ Binary works"
        else
            echo "⚠ Binary installed but --help failed"
        fi

        # Uninstall
        echo ""
        echo "Cleaning up test installation..."
        brew uninstall safe-squash
        echo "✓ Cleanup complete"
    else
        echo "✗ Installation failed"
        echo "See /tmp/brew-test.log for details"
        rm -rf "$TEST_DIR"
        exit 1
    fi
else
    echo "⚠ Homebrew not installed, skipping installation test"
fi

# Step 6: Verify tarball contains safe-squash script
echo ""
echo "Step 6: Verifying tarball contents..."
TEMP_EXTRACT=$(mktemp -d)

# Add cleanup trap
cleanup() {
    cd "$ORIGINAL_DIR" 2>/dev/null || true
    rm -rf "$TEMP_EXTRACT" "$TEST_DIR"
}
trap cleanup EXIT

cd "$TEMP_EXTRACT" || exit 1
curl -fsSL "$TARBALL_URL" | tar -xz

if [ -f "safe-squash-${VERSION}/safe-squash" ]; then
    echo "✓ Tarball contains safe-squash script"

    # Check if executable
    if [ -x "safe-squash-${VERSION}/safe-squash" ]; then
        echo "✓ Script is executable"
    else
        echo "⚠ Script is not executable (Homebrew will handle this)"
    fi
else
    echo "✗ Tarball does not contain safe-squash script"
    echo "Contents:"
    find . -type f
    exit 1
fi

cd "$ORIGINAL_DIR" || exit 1

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ All tests passed!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Formula is ready for release:"
echo ""
cat <<EOF
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
echo ""
echo "To update the tap manually:"
echo "  ./infra/update-homebrew.sh v${VERSION}"
echo ""
