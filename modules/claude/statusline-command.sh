#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')
effort=$(echo "$input" | jq -r '.effort.level // empty')

make_bar() {
  pct="$1"
  filled=$(awk "BEGIN {printf \"%.0f\", $pct * 10 / 100}")
  bar=""
  i=0
  while [ "$i" -lt 10 ]; do
    if [ "$i" -lt "$filled" ]; then
      bar="${bar}█"
    else
      bar="${bar}░"
    fi
    i=$((i + 1))
  done
  printf "%s" "$bar"
}

used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
if [ -n "$used_pct" ]; then
  ctx_bar_inner=$(make_bar "$used_pct")
  ctx_bar="ctx[${ctx_bar_inner}$(printf "%.0f" "$used_pct")%]"
else
  ctx_bar="ctx[-]"
fi

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_resets=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_resets=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

format_reset() {
  epoch="$1"
  if [ -z "$epoch" ]; then return; fi
  now=$(date +%s)
  diff=$((epoch - now))
  if [ "$diff" -le 0 ]; then
    printf "now"
  elif [ "$diff" -lt 3600 ]; then
    printf "%dm" $((diff / 60))
  elif [ "$diff" -lt 86400 ]; then
    h=$((diff / 3600))
    m=$(((diff % 3600) / 60))
    printf "%dh%dm" "$h" "$m"
  else
    d=$((diff / 86400))
    h=$(((diff % 86400) / 3600))
    printf "%dd%dh" "$d" "$h"
  fi
}

rate_str=""
if [ -n "$five_pct" ]; then
  five_bar=$(make_bar "$five_pct")
  five_reset_str=$(format_reset "$five_resets")
  if [ -n "$five_reset_str" ]; then
    rate_str="5h[${five_bar}$(printf "%.0f" "$five_pct")% / ${five_reset_str}]"
  else
    rate_str="5h[${five_bar}$(printf "%.0f" "$five_pct")%]"
  fi
fi
if [ -n "$week_pct" ]; then
  week_bar=$(make_bar "$week_pct")
  week_reset_str=$(format_reset "$week_resets")
  if [ -n "$week_reset_str" ]; then
    week_entry="7d[${week_bar}$(printf "%.0f" "$week_pct")% / ${week_reset_str}]"
  else
    week_entry="7d[${week_bar}$(printf "%.0f" "$week_pct")%]"
  fi
  if [ -n "$rate_str" ]; then
    rate_str="${rate_str} ${week_entry}"
  else
    rate_str="$week_entry"
  fi
fi

git_segment() {
  dir="$1"
  status=$(git -C "$dir" --no-optional-locks status --porcelain=v2 --branch 2>/dev/null) || return
  branch=$(printf "%s\n" "$status" | awk '/^# branch.head /{print $3}')
  [ "$branch" = "(detached)" ] && branch="detached@$(printf "%s\n" "$status" | awk '/^# branch.oid /{print substr($3,1,7)}')"
  changed=$(printf "%s\n" "$status" | grep -cv '^#')

  if [ "$changed" -gt 0 ]; then
    worktree="● ${changed}"
  else
    worktree="✓"
  fi

  ab=$(printf "%s\n" "$status" | awk '/^# branch.ab /{print $3, $4}')
  if [ -z "$ab" ]; then
    remote="no-upstream"
  else
    ahead=${ab%% *}; ahead=${ahead#+}
    behind=${ab##* }; behind=${behind#-}
    if [ "$ahead" -eq 0 ] && [ "$behind" -eq 0 ]; then
      remote="="
    else
      remote=""
      [ "$ahead" -gt 0 ] && remote="↑ ${ahead}"
      [ "$behind" -gt 0 ] && remote="${remote:+${remote} }↓ ${behind}"
    fi
  fi

  printf "git[%s %s %s]" "$branch" "$worktree" "$remote"
}

current_dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
git_str=""
[ -n "$current_dir" ] && git_str=$(git_segment "$current_dir")

segments="$model"
if [ -n "$effort" ]; then
  segments="${segments}  effort[${effort}]"
fi
if [ -n "$git_str" ]; then
  segments="${segments}  ${git_str}"
fi
segments="${segments}  ${ctx_bar}"
if [ -n "$rate_str" ]; then
  segments="${segments}  ${rate_str}"
fi
printf "%s" "$segments"
