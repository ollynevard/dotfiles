#!/usr/bin/env bash
# Claude Code status line — Catppuccin Mocha palette
# Elements: model · progress bar · percentage · tokens · git branch · project

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
# Anchor git operations to the project root, not the live cwd — so that an
# agent cd'ing into a subdir (or a sibling repo) doesn't change the branch shown.
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // empty')
repo_dir="${project_dir:-$cwd}"

# ---------------------------------------------------------------------------
# Catppuccin Mocha — truecolor (24-bit) for exact palette regardless of terminal theme
#   mauve    #cba6f7  (model name, git branch)
#   yellow   #f9e2af  (progress bar filled, percentage)
#   green    #a6e3a1  (git +added)
#   red      #f38ba8  (git [status flags], git -deleted)
#   blue     #89b4fa  (project name)
#   overlay0 #6c7086  (progress bar empty, token counts, separators)
# ---------------------------------------------------------------------------
RESET='\e[0m'
BOLD_MAUVE='\e[1;38;2;203;166;247m'
BOLD_YELLOW='\e[1;38;2;249;226;175m'
BOLD_GREEN='\e[1;38;2;166;227;161m'
BOLD_RED='\e[1;38;2;243;139;168m'
BOLD_BLUE='\e[1;38;2;137;180;250m'
DIM='\e[38;2;108;112;134m'

# ---------------------------------------------------------------------------
# 1. Model name
# ---------------------------------------------------------------------------
model_name=$(echo "$input" | jq -r '.model.display_name // empty')
if [ -n "$model_name" ]; then
  model_part="${BOLD_MAUVE}🤖 ${model_name}${RESET}"
else
  model_part=""
fi

# ---------------------------------------------------------------------------
# 2. Token formatting helper (e.g. "97k/1M") — used by the bar section below
# ---------------------------------------------------------------------------
fmt_tokens() {
  local n="$1"
  if [ "$n" -ge 1000000 ]; then
    awk -v n="$n" 'BEGIN { printf "%dM", int(n / 1000000 + 0.5) }'
  elif [ "$n" -ge 1000 ]; then
    awk -v n="$n" 'BEGIN { printf "%dk", int(n / 1000 + 0.5) }'
  else
    printf "%d" "$n"
  fi
}

# Single jq call — pulls all context-window values in one pass
read -r in_tok win_size <<< "$(echo "$input" | jq -r '
  [
    (.context_window.total_input_tokens // 0),
    (.context_window.context_window_size // 0)
  ] | @tsv')"

# ---------------------------------------------------------------------------
# 3. Bar + percentage — measured against the 100k "dumb zone" threshold
#    (model quality degrades noticeably past 100k tokens of context)
# ---------------------------------------------------------------------------
DUMB_ZONE=100000
# 20-stop truecolor gradient: Catppuccin green → yellow → red, used per-block on the bar
# and to color the percentage figure at the rightmost filled position.
GRAD=(
  '166;227;161' '175;227;162' '183;227;164' '192;227;165' '201;227;167'
  '210;226;168' '218;226;170' '227;226;171' '236;226;173' '245;226;174'
  '249;221;175' '248;212;174' '247;203;173' '247;194;172' '246;185;172'
  '246;176;171' '245;166;170' '244;157;169' '244;148;169' '243;139;168'
)
if [ -n "$in_tok" ] && [ "$in_tok" -gt 0 ]; then
  dz_pct=$(( in_tok * 100 / DUMB_ZONE ))
  filled=$(( in_tok * 20 / DUMB_ZONE ))
  [ "$filled" -gt 20 ] && filled=20
  empty=$(( 20 - filled ))
  pct_idx=$(( filled - 1 ))
  [ "$pct_idx" -lt 0 ] && pct_idx=0
  [ "$pct_idx" -gt 19 ] && pct_idx=19
  bar=""
  pct_color="\e[1;38;2;${GRAD[$pct_idx]}m"
  for (( i = 0; i < filled; i++ )); do
    bar="${bar}\e[1;38;2;${GRAD[$i]}m▓"
  done
  bar="${bar}${DIM}"
  for (( i = 0; i < empty; i++ )); do bar="${bar}░"; done
  bar="${bar}${RESET} ${pct_color}${dz_pct}%${RESET}"
  if [ "$in_tok" -gt 0 ] && [ "$win_size" -gt 0 ]; then
    bar="${bar} ${DIM}($(fmt_tokens "$in_tok")/$(fmt_tokens "$win_size"))${RESET}"
  fi
else
  bar="${DIM}░░░░░░░░░░░░░░░░░░░░${RESET}"
fi

# ---------------------------------------------------------------------------
# 4. Git: branch icon + name, [status flags], +added -deleted lines
#    Status flags mirror Starship defaults:
#      = conflicted   ✘ deleted    » renamed    ! modified   ? untracked
#      ⇡N ahead       ⇣N behind    ⇕N⇣N diverged
#    Staged ($+) is omitted — the green +N already indicates pending changes.
# ---------------------------------------------------------------------------
git_part=""
if [ -n "$repo_dir" ] && git -C "$repo_dir" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$repo_dir" symbolic-ref --short HEAD 2>/dev/null \
        || git -C "$repo_dir" rev-parse --short HEAD 2>/dev/null)
  if [ -n "$branch" ]; then
    git_part="${BOLD_MAUVE} ${branch}${RESET}"

    # Status flags from porcelain output (XY two-letter codes per line)
    porcelain=$(git -C "$repo_dir" status --porcelain 2>/dev/null)
    status_flags=""
    if [ -n "$porcelain" ]; then
      echo "$porcelain" | grep -qE '^(UU|AA|DD|U.|.U)'   && status_flags="${status_flags}="
      echo "$porcelain" | grep -qE '^(D.|.D)'            && status_flags="${status_flags}✘"
      echo "$porcelain" | grep -qE '^R'                  && status_flags="${status_flags}»"
      echo "$porcelain" | grep -qE '^.M'                 && status_flags="${status_flags}!"
      echo "$porcelain" | grep -qE '^\?\?'               && status_flags="${status_flags}?"
    fi

    # Ahead / behind / diverged
    if git -C "$repo_dir" rev-parse --abbrev-ref '@{upstream}' > /dev/null 2>&1; then
      ahead=$(git -C "$repo_dir" rev-list --count '@{upstream}..HEAD' 2>/dev/null || echo 0)
      behind=$(git -C "$repo_dir" rev-list --count 'HEAD..@{upstream}' 2>/dev/null || echo 0)
      if [ "$ahead" -gt 0 ] && [ "$behind" -gt 0 ]; then
        status_flags="${status_flags}⇕${ahead}⇣${behind}"
      elif [ "$ahead" -gt 0 ]; then
        status_flags="${status_flags}⇡${ahead}"
      elif [ "$behind" -gt 0 ]; then
        status_flags="${status_flags}⇣${behind}"
      fi
    fi

    if [ -n "$status_flags" ]; then
      git_part="${git_part} ${BOLD_RED}[${status_flags}]${RESET}"
    fi

    # Line metrics — +added (green) -deleted (red), unstaged worktree changes only
    # (--numstat without --cached intentionally excludes staged changes)
    metrics=$(git -C "$repo_dir" diff --numstat 2>/dev/null \
      | awk '{a+=$1; d+=$2} END {printf "%d %d", a+0, d+0}')
    if [ -n "$metrics" ]; then
      read added deleted <<< "$metrics"
      metrics_part=""
      [ "${added:-0}" -gt 0 ]   && metrics_part="${BOLD_GREEN}+${added}${RESET}"
      if [ "${deleted:-0}" -gt 0 ]; then
        [ -n "$metrics_part" ] && metrics_part="${metrics_part} "
        metrics_part="${metrics_part}${BOLD_RED}-${deleted}${RESET}"
      fi
      [ -n "$metrics_part" ] && git_part="${git_part} ${metrics_part}"
    fi
  fi
fi

# ---------------------------------------------------------------------------
# 5. Project name — basename of repo_dir (project_dir, or cwd fallback)
# ---------------------------------------------------------------------------
if [ -n "$repo_dir" ]; then
  project_name=$(basename "$repo_dir")
  project_part="${BOLD_BLUE} ${project_name}${RESET}"
else
  project_part=""
fi

# ---------------------------------------------------------------------------
# Assemble — sections separated by a dim pipe
# ---------------------------------------------------------------------------
SEP=" ${DIM}|${RESET} "

parts=()
[ -n "$project_part" ] && parts+=("$project_part")
[ -n "$git_part" ]     && parts+=("$git_part")
parts+=("$bar")                          # bar + dumb-zone % (always shown)
[ -n "$model_part" ]   && parts+=("$model_part")

result=""
for part in "${parts[@]}"; do
  if [ -z "$result" ]; then
    result="$part"
  else
    result="${result}${SEP}${part}"
  fi
done

printf "%b\n" "$result"
