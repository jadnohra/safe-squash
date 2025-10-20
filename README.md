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
# Default mode (safe, restores if cancelled)
safe-squash

# Extra safety mode (keeps backup branch on failure)
safe-squash --backup

# Run integrated test suite
safe-squash --test

# Show help
safe-squash --help
```

## How It Works

1. Detects where your branch diverged from main/master/parent
2. Shows you all commits that will be squashed
3. Asks for confirmation
4. Uses `git reset --soft` to stage all changes
5. Opens editor for new commit message (pre-filled with all messages)
6. Success: cleanup, done!
7. Failure: restore from backup (if using --backup)

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
Will squash 3 commit(s) since main:
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

## Test Suite

The script includes a comprehensive test suite that validates:

- Basic squashing functionality
- Backup creation and cleanup
- Cancellation handling
- Error cases (dirty working dir, main branch, detached HEAD, etc.)
- Git operations in progress (merge, rebase, cherry-pick)
- Content integrity preservation
- Edge cases (empty messages, single commits)

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

## Quick Start (For Maintainers)

First-time setup - run this once to publish everything:

```bash
cd ~/github/jadnohra/safe-squash
./setup.sh
```

This will:
- Create and push the homebrew-tap repository
- Commit and push safe-squash
- Create the v1.0.0 release tag
- Trigger GitHub Actions to run tests and publish

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Issues and pull requests welcome! Please include tests for any new functionality.

## Author

Jad Nohra
