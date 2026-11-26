#!/bin/sh
# One-off macOS preferences. Re-run after a fresh install; not sourced by the shell.
set -eu

defaults write com.apple.finder DisableAllAnimations -bool true
killall Finder 2>/dev/null || true

# Rex: the Settings window's choices, which live only in this plist (init.lua
# can't set them yet). Restart Rex to pick them up. Move them to rex.set in
# ~/.config/rex/init.lua once Rex supports general settings there.
defaults write com.superlogical.rex Workspace.activityGrouping -string 'priority'
defaults write com.superlogical.rex Workspace.cursorShader -string 'warp'
defaults write com.superlogical.rex Workspace.cursorShadersEnabled -bool true
defaults write com.superlogical.rex Workspace.darkThemeID -string 'abyssal-trench'
defaults write com.superlogical.rex Workspace.lightThemeID -string 'merino-light'
defaults write com.superlogical.rex Workspace.inactivePaneFadeMode -string 'both'
defaults write com.superlogical.rex Workspace.interfaceStyle -string 'blendTheme'
defaults write com.superlogical.rex Workspace.sidebarPosition -string 'left'
defaults write com.superlogical.rex Workspace.sidebarWidth -float 301
defaults write com.superlogical.rex Workspace.tabBarEdge -string 'top'
defaults write com.superlogical.rex Workspace.tabIconTintMode -string 'off'
defaults write com.superlogical.rex Workspace.tabStyle -string 'vertical'
defaults write com.superlogical.rex Workspace.terminalCellHeightPercent -float 10
defaults write com.superlogical.rex Workspace.terminalCopyOnSelect -bool true
defaults write com.superlogical.rex Workspace.terminalCursorStyle -string 'block'
defaults write com.superlogical.rex Workspace.terminalFontName -string 'JetBrainsMono Nerd Font Mono'
defaults write com.superlogical.rex Workspace.terminalFontPointSize -float 16
defaults write com.superlogical.rex Workspace.terminalSelectionBackground -string 'theme'
defaults write com.superlogical.rex Workspace.terminalSelectionForeground -string 'theme'
defaults write com.superlogical.rex Workspace.terminalSmoothScrolling -bool true
defaults write com.superlogical.rex Workspace.usesStandardInactiveWindowPaneStyles -bool true
defaults write com.superlogical.rex rex.agents.names-sessions -bool false
