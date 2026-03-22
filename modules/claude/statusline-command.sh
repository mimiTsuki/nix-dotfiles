#!/bin/sh
input=$(cat)

model=$(echo "$input" | jq -r '.model.display_name // "Unknown"')

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

if [ -n "$rate_str" ]; then
  printf "%s  %s  %s" "$model" "$ctx_bar" "$rate_str"
else
  printf "%s  %s" "$model" "$ctx_bar"
fi
