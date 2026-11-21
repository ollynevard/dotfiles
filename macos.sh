#!/bin/sh
# One-off macOS preferences. Re-run after a fresh install; not sourced by the shell.
set -eu

defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder 2>/dev/null || true
