#!/bin/bash
#
# setup.sh - Automated setup for safe-squash repository
#
# This script:
# 1. Creates and pushes the homebrew-tap repository
# 2. Commits and pushes the safe-squash repository
# 3. Creates the first release tag
#

set -e

# Save original directory
ORIGINAL_DIR="$(pwd)"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "safe-squash setup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check we're in the right directory
if [ ! -f "safe-squash" ]; then
    echo "Error: Must run from safe-squash repository root"
    exit 1
fi

# Step 1: Create homebrew-tap repository
echo "Step 1: Setting up homebrew-tap repository"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

HOMEBREW_TAP_DIR="../homebrew-tap"

if [ -d "$HOMEBREW_TAP_DIR" ]; then
    echo "✓ homebrew-tap directory already exists"
else
    echo "Creating homebrew-tap repository..."
    mkdir -p "$HOMEBREW_TAP_DIR"
    cd "$HOMEBREW_TAP_DIR" || exit 1

    git init -b main
    mkdir -p Formula

    cat > README.md <<'EOF'
# Homebrew Tap for Jad Nohra's Tools

## Installation

```bash
brew install jadnohra/tap/safe-squash
```

## Available Formulae

- **safe-squash** - Simple, robust tool to squash all commits on your branch into one

EOF

    git add .
    git commit -m "Initial commit"

    # Check if remote exists
    if ! git remote | grep -q origin; then
        git remote add origin git@github.com:jadnohra/homebrew-tap.git
    fi

    echo ""
    echo "Pushing homebrew-tap to GitHub..."
    echo ""
    echo "⚠ IMPORTANT: Create the repository on GitHub first!"
    echo "  Go to: https://github.com/new"
    echo "  Repository name: homebrew-tap"
    echo "  Visibility: Public"
    echo "  DO NOT initialize with README, .gitignore, or license"
    echo ""
    echo -n "Press Enter when you've created the repository..."
    read -r
    echo ""

    # Try to push
    if git push -u origin main; then
        echo "✓ Successfully pushed homebrew-tap"
    else
        echo "✗ Failed to push homebrew-tap"
        echo ""
        echo "Troubleshooting:"
        echo "  - Did you create the repository at: https://github.com/jadnohra/homebrew-tap"
        echo "  - Is it set to Public?"
        echo "  - Did you leave it empty (no README, .gitignore, or license)?"
        echo "  - Do you have push access?"
        cd "$ORIGINAL_DIR" || exit 1
        exit 1
    fi

    cd "$ORIGINAL_DIR" || exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 2: Committing safe-squash repository"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Add all files
git add .

# Check if there are changes to commit
if git diff --staged --quiet; then
    echo "✓ No changes to commit"
else
    echo "Committing changes..."
    git commit -m "Initial release: safe-squash v1.0.0

Features:
- Simple git squash using reset --soft (no rebase)
- Auto-detects base branch (main/master/parent)
- Optional backup mode with auto-cleanup
- Interactive commit message editor
- Integrated test suite (13 comprehensive tests)
- Professional terminal UI (Terminus style)
- Safety checks for git state (merge/rebase/cherry-pick in progress)

Installation:
- Homebrew: brew install jadnohra/tap/safe-squash
- Manual: curl -fsSL https://raw.githubusercontent.com/jadnohra/safe-squash/main/safe-squash -o /usr/local/bin/safe-squash
"
    echo "✓ Changes committed"
fi

echo ""
echo "Pushing to GitHub..."
if git push origin main; then
    echo "✓ Pushed to GitHub"
else
    echo "✗ Failed to push to GitHub"
    echo ""
    echo "Make sure the repository exists at:"
    echo "  https://github.com/jadnohra/safe-squash"
    exit 1
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 3: Creating release tag v1.0.0"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if tag already exists
if git rev-parse v1.0.0 >/dev/null 2>&1; then
    echo "⚠ Tag v1.0.0 already exists, skipping"
else
    git tag -a v1.0.0 -m "Release v1.0.0

First stable release of safe-squash.

Features:
- Simple git squash using reset --soft
- Auto-detect base branch
- Optional backup mode
- Integrated test suite
- Professional terminal UI
"
    git push origin v1.0.0
    echo "✓ Created and pushed tag v1.0.0"
    echo ""
    echo "GitHub Actions will now:"
    echo "  1. Run the test suite"
    echo "  2. Create a GitHub release"
    echo "  3. Update the Homebrew formula"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Step 4: Setting up GitHub token for Homebrew automation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "To enable automatic Homebrew formula updates on releases,"
echo "we need to add a GitHub token to this repository's secrets."
echo ""
echo -n "Set up GitHub token now? (y/N): "
read -r setup_token

if [[ "$setup_token" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Step 4a: Creating GitHub Personal Access Token"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Opening GitHub token creation page..."
    echo ""

    # Try to open in browser
    if command -v xdg-open > /dev/null; then
        xdg-open "https://github.com/settings/tokens/new?description=safe-squash%20Homebrew%20automation&scopes=repo,workflow" 2>/dev/null
    elif command -v open > /dev/null; then
        open "https://github.com/settings/tokens/new?description=safe-squash%20Homebrew%20automation&scopes=repo,workflow"
    else
        echo "Please open this URL in your browser:"
        echo "https://github.com/settings/tokens/new?description=safe-squash%20Homebrew%20automation&scopes=repo,workflow"
    fi

    echo ""
    echo "Instructions:"
    echo "  1. In the opened page, verify these scopes are selected:"
    echo "     ✓ repo (Full control of private repositories)"
    echo "     ✓ workflow (Update GitHub Action workflows)"
    echo "  2. Click 'Generate token' at the bottom"
    echo "  3. Copy the generated token (starts with 'ghp_' or 'github_pat_')"
    echo ""
    echo -n "Press Enter when you have copied the token..."
    read -r

    echo ""
    echo -n "Paste your GitHub token: "
    read -r -s github_token
    echo ""

    if [ -z "$github_token" ]; then
        echo "⚠ No token provided, skipping"
    else
        echo ""
        echo "Step 4b: Adding token to repository secrets"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Try to use GitHub CLI if available
        if command -v gh > /dev/null 2>&1; then
            echo "Using GitHub CLI to add secret..."
            if echo "$github_token" | gh secret set HOMEBREW_TAP_TOKEN --repo jadnohra/safe-squash; then
                echo "✓ Successfully added HOMEBREW_TAP_TOKEN secret"
            else
                echo "⚠ Failed to add secret via gh CLI"
                echo ""
                echo "Please add manually:"
                echo "  1. Go to: https://github.com/jadnohra/safe-squash/settings/secrets/actions"
                echo "  2. Click 'New repository secret'"
                echo "  3. Name: HOMEBREW_TAP_TOKEN"
                echo "  4. Value: [paste your token]"
            fi
        else
            echo "GitHub CLI (gh) not found. Add secret manually:"
            echo ""
            echo "  1. Opening secrets page..."

            if command -v xdg-open > /dev/null; then
                xdg-open "https://github.com/jadnohra/safe-squash/settings/secrets/actions/new" 2>/dev/null
            elif command -v open > /dev/null; then
                open "https://github.com/jadnohra/safe-squash/settings/secrets/actions/new"
            else
                echo "     Go to: https://github.com/jadnohra/safe-squash/settings/secrets/actions/new"
            fi

            echo ""
            echo "  2. Name: HOMEBREW_TAP_TOKEN"
            echo "  3. Value: [paste your token]"
            echo "  4. Click 'Add secret'"
            echo ""
            echo -n "Press Enter when done..."
            read -r
            echo "✓ Token setup complete"
        fi
    fi
else
    echo ""
    echo "⚠ Skipping token setup"
    echo ""
    echo "To enable auto Homebrew updates later:"
    echo "  1. Create token: https://github.com/settings/tokens (needs 'repo' + 'workflow')"
    echo "  2. Add secret: https://github.com/jadnohra/safe-squash/settings/secrets/actions"
    echo "     Name: HOMEBREW_TAP_TOKEN"
    echo "     Value: [your token]"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✓ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "What happens next:"
echo ""
echo "  1. GitHub Actions is running tests now:"
echo "     https://github.com/jadnohra/safe-squash/actions"
echo ""
echo "  2. A release will be created at:"
echo "     https://github.com/jadnohra/safe-squash/releases"
echo ""
echo "  3. Homebrew formula will be updated (if token is configured)"
echo ""
echo "Users can now install with:"
echo "  brew install jadnohra/tap/safe-squash"
echo ""
echo "To create future releases:"
echo "  git tag v1.1.0"
echo "  git push origin v1.1.0"
echo ""
