# 🔐 GitHub SSH & Automation Tools

DevKit includes GitHub utilities to manage SSH keys, automate Git workflows, and streamline branching, pushing, and tagging.

## 📑 Table of Contents

- [🔑 SSH Key Utilities](#-ssh-key-utilities)
- [🚀 Workflow Helpers](#-workflow-helpers)
- [🌿 Branch Management](#-branch-management)
- [📥 Pulling, Tagging & Sync](#-pulling-tagging--sync)
- [📊 Git Info](#-git-info)

---

## 🔑 SSH Key Utilities

- **`github-ssh-list`** — List SSH keys in `~/.ssh/`.
- **`github-ssh-setup`** — Generate and configure SSH key for GitHub (port 443).
- **`github-ssh-delete`** — Interactively delete SSH keys.
- **`github-ssh-connection-test`** — Test SSH connection to GitHub.

---

## 🚀 Workflow Helpers

- **`github-commit-and-push ["message"]`** — Commit all changes and push.
- **`github-clear-cache-and-recommit-all-files`** — Reset Git cache and recommit.
- **`github-undo-last-commit`** — Revert last commit from remote only.
- **`github-version-bump`** — Create and push a new version tag (major, minor, patch, or custom). Shows the latest version and ensures a clean working state before tagging.

---

## 🌿 Branch Management

- **`github-branch-rename <new>`** — Rename current branch locally and remotely.
- **`github-branch-create <name>`** — Create and switch to a new branch.
- **`github-branch-delete <name>`** — Delete local and/or remote branch.
- **`github-branch-list`** — List local and remote branches.
- **`github-branches-clean`** — Delete local branches merged into `main`.
- **`github-reset-to-remote`** — Reset local branch to match remote (destructive).

---

## 📥 Pulling, Tagging & Sync

- **`github-stash-and-pull`** — Stash, pull, and reapply changes.
- **`github-push-tag <tag> [message]`** — Create and push annotated tag.
- **`github-rebase-current [target]`** — Rebase current branch (default: main).
- **`github-sync-fork`** — Sync fork with upstream main branch.

---

## 📊 Git Info

- **`github-status-short`** — Show current branch and short status.
- **`github-open`** — Open GitHub repository in browser.

---

> 🚀 Pro tip: Automate common workflows like branch cleanup and sync for faster daily GitOps.
