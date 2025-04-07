# 🔐 GitHub SSH & Automation Tools

DevKit includes powerful GitHub utilities to manage SSH keys, simplify Git workflows, and automate branching, pushing, and tagging.

## 📑 Table of Contents

- [🔐 GitHub SSH & Automation Tools](#-github-ssh--automation-tools)
  - [🔑 SSH Key Utilities](#-ssh-key-utilities)
  - [🚀 Workflow Helpers](#-workflow-helpers)
  - [🌿 Branch Management](#-branch-management)
  - [📥 Pulling, Tagging & Sync](#-pulling-tagging--sync)
  - [📊 Git Info](#-git-info)

## 🔑 SSH Key Utilities

- `github-ssh-list` — List all SSH keys found in `~/.ssh/`
- `github-ssh-setup` — Generate and configure SSH key for GitHub access (port 443 fallback)
- `github-ssh-delete` — Interactively delete a selected SSH key
- `github-ssh-connection-test` - Test SSH connection to GitHub

## 🚀 Workflow Helpers

- `github-commit-and-push ["message"]` — Commit all changes and push (with confirmation)
- `github-clear-cache-and-recommit-all-files` — Reset Git cache and recommit everything
- `github-undo-last-commit` — Revert last commit from remote GitHub only

## 🌿 Branch Management

- `github-branch-rename <new>` — Rename current branch locally and on GitHub
- `github-branch-create <name>` — Create and switch to a new branch
- `github-branch-delete <name>` — Delete local and/or remote branch (with confirmation)
- `github-branch-list` — List all local and remote branches
- `github-branches-clean` — Delete all local branches merged into main
- `github-reset-to-remote` — Reset local branch to match remote HEAD (destructive)

## 📥 Pulling, Tagging & Sync

- `github-stash-and-pull` — Safely stash, pull, and reapply changes
- `github-push-tag <tag> [message]` — Create and push annotated Git tag
- `github-rebase-current [target]` — Rebase current branch onto another (default: main)
- `github-sync-fork` — Sync your fork’s main with upstream/main

## 📊 Git Info

- `github-status-short` — Show current branch and short status
