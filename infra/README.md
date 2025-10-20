# Infrastructure

This directory contains automation for releasing and distributing safe-squash.

## Homebrew Distribution

### Automatic (Recommended)

When you push a version tag (e.g., `v1.0.0`), GitHub Actions automatically:

1. Creates a GitHub release
2. Updates the Homebrew tap at `github.com/jadnohra/homebrew-tap`
3. Users can install with: `brew install jadnohra/tap/safe-squash`

**To create a release:**

```bash
# Tag and push
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions does the rest!
```

### Manual Update

If you need to manually update the Homebrew formula:

```bash
./infra/update-homebrew.sh v1.0.0
```

This will:
- Calculate SHA256 of the release tarball
- Clone/update the homebrew-tap repository
- Generate the formula
- Show you the next steps to commit and push

## Setup Requirements

### For Automatic Releases

1. Create the homebrew tap repository:
   ```bash
   # On GitHub, create: github.com/jadnohra/homebrew-tap
   mkdir homebrew-tap
   cd homebrew-tap
   git init
   mkdir Formula
   git add .
   git commit -m "Initial commit"
   git remote add origin git@github.com:jadnohra/homebrew-tap.git
   git push -u origin main
   ```

2. Create a GitHub Personal Access Token:
   - Go to GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Generate new token with `repo` and `workflow` scopes
   - Copy the token

3. Add the token to this repository's secrets:
   - Go to safe-squash repository → Settings → Secrets and variables → Actions
   - Create secret: `HOMEBREW_TAP_TOKEN` with your token value

### For Manual Updates

Just run `./infra/update-homebrew.sh <version>` - it will clone the tap repo if needed.

## Files

- `homebrew-formula.rb` - Template formula (reference only)
- `update-homebrew.sh` - Manual update script
- `README.md` - This file

## Workflow Files

The GitHub Actions workflows in `.github/workflows/`:

- `test.yml` - Runs tests on every push/PR
- `release.yml` - Auto-updates Homebrew on version tags
