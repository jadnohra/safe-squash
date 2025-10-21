# safe-squash

[![Tests](https://github.com/jadnohra/safe-squash/actions/workflows/test.yml/badge.svg)](https://github.com/jadnohra/safe-squash/actions/workflows/test.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A simple, robust tool to squash git commits.

## Installation

### Homebrew (macOS/Linux)

```bash
brew install jadnohra/tap/safe-squash
```

### Manual Installation

```bash
# Download and install
curl -fsSL https://raw.githubusercontent.com/jadnohra/safe-squash/main/safe-squash -o /usr/local/bin/safe-squash
chmod +x /usr/local/bin/safe-squash

# Or clone and link
git clone https://github.com/jadnohra/safe-squash.git
cd safe-squash
sudo ln -s "$PWD/safe-squash" /usr/local/bin/safe-squash
```

## Usage

```bash
# Default mode (uses origin/main, safe, restores if cancelled)
safe-squash

# Extra safety mode (keeps backup branch on failure)
safe-squash --backup

# Use local main/master instead of origin/main
safe-squash --local

# Combine flags
safe-squash --backup --local

# Run integrated test suite
safe-squash --test

# Show help
safe-squash --help
```

## How It Works

1. Detects where your branch diverged from base branch (origin/main by default)
2. Shows you all commits that will be squashed
3. Asks for confirmation
4. Uses `git reset --soft` to stage all changes
5. Opens editor for new commit message (pre-filled with all messages)
6. Success: cleanup, done!
7. Failure: restore from backup (if using --backup)

## Base Branch Selection

**Default behavior (recommended):**
- Uses `origin/main` or `origin/master` if available (the remote tracking branch)
- Falls back to local `main`/`master` if no remote exists
- Automatically detects if local and remote are out of sync
- Prompts you to choose when they differ

**With `--local` flag:**
- Forces use of local `main` or `master` branch
- Skips all remote checks
- Useful for offline work or specific workflows

**Why prefer remote?**
- `origin/main` is the source of truth in collaborative workflows
- Prevents squashing to outdated local branches
- Ensures your squashed commit has the correct base

## Safety & Backup Modes

Both modes are safe - they differ in how they handle failures:

**Default mode (recommended):**
- ✅ Safe: Restores original state if you cancel or close editor
- ✅ Fast: No backup branch creation
- ✅ Clean: No leftover branches

**Backup mode (`--backup`):**
- ✅ Extra paranoid: Creates timestamped backup branch before squashing
- ✅ Example: `backup-squash-20250120-143052-12345`
- ✅ Auto-cleanup: Backup deleted on success
- ✅ Failure recovery: Backup kept if anything goes wrong, with restore instructions

**When to use --backup:**
- Working with critical/complex branches
- Want ability to restore even after successful squash
- Prefer extra safety over speed

## Example

```bash
$ safe-squash
Will squash 3 commit(s) since origin/main:
abc1234 Add type-check script
def5678 Fix Vercel build
ghi9012 Simplify config

Continue? (y/N): y
Squashing commits...
Enter commit message:
[editor opens with combined messages]
✓ Successfully squashed 3 commit(s)!

Note: Branch was previously pushed. You'll need to:
  git push --force-with-lease
```

**Example with out-of-sync detection:**

```bash
$ safe-squash
Warning: Local main and origin/main are out of sync
  Local main is 2 commit(s) behind origin/main

Squash to [1] origin/main (recommended) or [2] local main? (1/2): 1
Will squash 3 commit(s) since origin/main:
...
```

## Test Suite

The script includes a comprehensive test suite with **23 tests** that validate:

**Core functionality:**
- Basic squashing functionality
- Backup creation and cleanup
- Cancellation handling
- Content integrity preservation

**Error cases:**
- Dirty working directory
- Running on main/master branch
- Detached HEAD state
- Git operations in progress (merge, rebase, cherry-pick)
- Invalid flags

**Remote branch handling:**
- Squashing to origin/main by default
- Using --local flag to force local branch
- Out-of-sync detection (local behind remote)
- Out-of-sync detection (local ahead of remote)
- Diverged branches (both ahead and behind)
- Fallback to local when no remote exists
- Fresh clone scenario (no local main, only origin/main)
- origin/master fallback when origin/main doesn't exist
- Flag combinations (--local --backup)

**Edge cases:**
- Empty commit messages
- Single commit squashing
- No commits to squash

Run tests with:

```bash
safe-squash --test
```

## Notes

- Always squashes **all** commits since divergence from base branch
- Requires clean working directory
- Won't run on main/master branch
- Won't run during merge/rebase/cherry-pick operations
- After squashing, use `git push --force-with-lease` if branch was pushed
- Self-testing with `--test` flag - no separate test file needed

## Releasing (For Maintainers)

### One-Time Setup for Auto Homebrew Updates

1. **Create homebrew-tap repository:**
   - Go to https://github.com/new
   - Name: `homebrew-tap`
   - Public, empty (no README/license/gitignore)

2. **Create GitHub token:**
   - Go to https://github.com/settings/tokens/new
   - Scopes: `repo` + `workflow`
   - Copy the token

3. **Add token to safe-squash secrets:**
   - Go to https://github.com/jadnohra/safe-squash/settings/secrets/actions
   - New secret: `HOMEBREW_TAP_TOKEN`
   - Paste your token

### Create a Release

```bash
# Create and push tag
git tag v1.0.0
git push origin v1.0.0

# GitHub Actions automatically:
# - Runs tests
# - Creates GitHub release
# - Updates Homebrew formula in homebrew-tap
```

Users can then install with: `brew install jadnohra/tap/safe-squash`

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Issues and pull requests welcome! Please include tests for any new functionality.
