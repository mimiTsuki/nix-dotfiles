//! keylog-report: turns a raw NeoVim keystroke JSONL log (written by
//! modules/nvim/lua/config/keylog.lua) into a compact, human-readable digest
//! of vim usage patterns.
//!
//! Design intent (see the project plan): this tool is the *only* thing that
//! is allowed to read the raw log in bulk. Everything downstream (in
//! particular, an LLM reviewing habits) should only ever see this digest,
//! never the raw JSONL. If a new kind of insight is needed, add a new
//! analysis pass here rather than reading the raw log elsewhere.
//!
//! Known quirk this tool compensates for: NeoVim's `vim.on_key()` fires not
//! only for keys the user actually pressed, but also for the *synthetic*
//! keys Nvim's internal "pseudo command" translation generates. E.g.
//! pressing `x` produces three on_key events: `x`, then `d`, then `l`
//! (because `x` is implemented internally as `dl`). Left alone, this would
//! make it look like the user types "dl" constantly, drowning out the
//! actual signal. `suppress_synthetic_echoes` strips those known synthetic
//! follow-ups before any frequency analysis runs.

use serde::Deserialize;
use std::collections::HashMap;
use std::env;
use std::fs::File;
use std::io::{BufRead, BufReader};
use std::process::ExitCode;

#[derive(Debug, Deserialize, Clone)]
struct Event {
    timestamp: String,
    delta_ms: i64,
    mode: String,
    key: String,
    filetype: String,
    #[serde(default)]
    count: Option<u64>,
}

impl Event {
    /// Number of physical keystrokes this event represents. Aggregated
    /// Insert-mode runs (key == "<insert-text>") carry a `count`; everything
    /// else is exactly one keystroke.
    fn keystrokes(&self) -> u64 {
        self.count.unwrap_or(1)
    }
}

/// Max gap (ms) between two synthetic-echo events for them to still be
/// considered part of the same internal command translation, not
/// independent user input.
const SYNTHETIC_ECHO_MAX_DELTA_MS: i64 = 5;

/// Max gap (ms) between adjacent Normal-mode keys for them to be counted
/// together in a bigram/trigram (avoids linking keys across an idle break).
const BIGRAM_MAX_GAP_MS: i64 = 30_000;

/// Minimum run length to report as a "repeated motion" habit.
const MIN_REPEAT_RUN: usize = 3;

/// True for any Normal-mode-family `mode()` string: plain Normal ("n") as
/// well as the operator-pending variants ("no", "nov", "noV", "no<C-v>")
/// that the *second and later* keys of a multi-key Normal command (e.g. the
/// second "d" in "dd", or "l" after "d") report. Analyses that want to treat
/// a whole Normal-mode command as one logical unit must use this instead of
/// a strict `mode == "n"` check, otherwise adjacency-based detection (runs,
/// bigrams, "dd" then paste, ...) silently drops the non-leading keys.
fn is_normal_family(mode: &str) -> bool {
    mode == "n" || mode.starts_with("no")
}

/// Keys that switch into cmdline mode (":" / "/" / "?"). After filtering a
/// sequence down to its Normal-mode-family events, several of these can end
/// up artificially adjacent (their cmdline-mode contents get filtered out),
/// which would misreport separate `:w`-style commands as a "repeated
/// motion". Command-line usage has its own dedicated analysis
/// (print_cmdline_commands), so these are excluded here.
fn is_cmdline_trigger(key: &str) -> bool {
    matches!(key, ":" | "/" | "?")
}

fn main() -> ExitCode {
    let args: Vec<String> = env::args().collect();
    let path = match args.get(1) {
        Some(p) => p,
        None => {
            eprintln!("usage: keylog-report <path-to-keylog.jsonl>");
            return ExitCode::FAILURE;
        }
    };

    let (events, malformed) = match read_events(path) {
        Ok(v) => v,
        Err(e) => {
            eprintln!("keylog-report: failed to read {path}: {e}");
            return ExitCode::FAILURE;
        }
    };

    if events.is_empty() {
        println!("No events found in {path} (malformed lines skipped: {malformed}).");
        return ExitCode::SUCCESS;
    }

    let suppressed = suppress_synthetic_echoes(&events);

    print_report(path, &events, &suppressed, malformed);

    ExitCode::SUCCESS
}

fn read_events(path: &str) -> std::io::Result<(Vec<Event>, u64)> {
    let file = File::open(path)?;
    let reader = BufReader::new(file);
    let mut events = Vec::new();
    let mut malformed = 0u64;

    for line in reader.lines() {
        let line = line?;
        let trimmed = line.trim();
        if trimmed.is_empty() {
            continue;
        }
        match serde_json::from_str::<Event>(trimmed) {
            Ok(ev) => events.push(ev),
            Err(_) => malformed += 1,
        }
    }

    Ok((events, malformed))
}

/// Returns the known internal expansion for a Normal-mode "pseudo command"
/// key, i.e. the synthetic on_key events Nvim fires right after it,
/// empirically verified against Neovim 0.11 (see module doc comment).
fn pseudo_expansion(key: &str) -> Option<&'static [&'static str]> {
    match key {
        "x" => Some(&["d", "l"]),
        "X" => Some(&["d", "h"]),
        "D" => Some(&["d", "$"]),
        "C" => Some(&["c", "$", "<Esc>"]),
        "s" => Some(&["c", "l", "<Esc>"]),
        "S" => Some(&["c", "c", "<Esc>"]),
        _ => None,
    }
}

/// Marks events that are synthetic echoes of a preceding pseudo-command key,
/// so frequency/run analyses below can skip them.
fn suppress_synthetic_echoes(events: &[Event]) -> Vec<bool> {
    let mut suppressed = vec![false; events.len()];
    let mut i = 0;
    while i < events.len() {
        if let Some(expansion) = pseudo_expansion(&events[i].key) {
            let n = expansion.len();
            if i + n < events.len() {
                let all_match = (0..n).all(|k| {
                    let ev = &events[i + 1 + k];
                    ev.key == expansion[k] && ev.delta_ms <= SYNTHETIC_ECHO_MAX_DELTA_MS
                });
                if all_match {
                    for k in 0..n {
                        suppressed[i + 1 + k] = true;
                    }
                    i += 1 + n;
                    continue;
                }
            }
        }
        i += 1;
    }
    suppressed
}

fn print_report(path: &str, events: &[Event], suppressed: &[bool], malformed: u64) {
    let total_events = events.len();
    let total_keystrokes: u64 = events.iter().map(Event::keystrokes).sum();
    let elapsed_ms: i64 = events.iter().map(|e| e.delta_ms.max(0)).sum();

    println!("== keylog-report: {path} ==");
    println!(
        "events: {total_events} (malformed lines skipped: {malformed})  keystrokes: {total_keystrokes}"
    );
    println!(
        "span: {} .. {}  (~{} of active gaps between keys)",
        events.first().unwrap().timestamp,
        events.last().unwrap().timestamp,
        format_duration_ms(elapsed_ms)
    );
    println!();

    print_mode_distribution(events);
    print_filetype_breakdown(events);
    print_arrow_key_usage(events);
    print_repeated_runs(events, suppressed);
    print_bigrams(events, suppressed);
    print_dd_then_paste(events, suppressed);
    print_dot_repeat(events, suppressed);
    print_cmdline_commands(events);
}

fn format_duration_ms(ms: i64) -> String {
    let total_secs = ms / 1000;
    let h = total_secs / 3600;
    let m = (total_secs % 3600) / 60;
    let s = total_secs % 60;
    if h > 0 {
        format!("{h}h{m}m{s}s")
    } else if m > 0 {
        format!("{m}m{s}s")
    } else {
        format!("{s}s")
    }
}

fn print_mode_distribution(events: &[Event]) {
    let mut by_mode: HashMap<&str, u64> = HashMap::new();
    for e in events {
        *by_mode.entry(e.mode.as_str()).or_default() += e.keystrokes();
    }
    let mut rows: Vec<_> = by_mode.into_iter().collect();
    rows.sort_by_key(|b| std::cmp::Reverse(b.1));

    println!("-- mode distribution (keystrokes) --");
    for (mode, count) in rows {
        println!("  {mode:<4} {count}");
    }
    println!();
}

fn print_filetype_breakdown(events: &[Event]) {
    let mut by_ft: HashMap<&str, u64> = HashMap::new();
    for e in events {
        let ft = if e.filetype.is_empty() {
            "(none)"
        } else {
            e.filetype.as_str()
        };
        *by_ft.entry(ft).or_default() += e.keystrokes();
    }
    let mut rows: Vec<_> = by_ft.into_iter().collect();
    rows.sort_by_key(|b| std::cmp::Reverse(b.1));

    println!("-- filetype breakdown (keystrokes) --");
    for (ft, count) in rows.iter().take(10) {
        println!("  {ft:<16} {count}");
    }
    println!();
}

fn print_arrow_key_usage(events: &[Event]) {
    let arrows = ["<Up>", "<Down>", "<Left>", "<Right>"];
    let mut by_mode: HashMap<&str, u64> = HashMap::new();
    let mut total = 0u64;
    for e in events {
        if arrows.contains(&e.key.as_str()) {
            *by_mode.entry(e.mode.as_str()).or_default() += 1;
            total += 1;
        }
    }
    println!("-- arrow key usage --");
    if total == 0 {
        println!("  none (good — motions are being used instead)");
    } else {
        let mut rows: Vec<_> = by_mode.into_iter().collect();
        rows.sort_by_key(|b| std::cmp::Reverse(b.1));
        for (mode, count) in rows {
            println!("  mode={mode:<3} {count}");
        }
        println!("  total: {total}  (candidates for hjkl / ciw / etc. instead)");
    }
    println!();
}

/// Runs of the same key pressed back-to-back in Normal mode. Generic over
/// any key, so it naturally covers "jjjj", "wwww", "xxxx", etc. without
/// needing a hardcoded motion list.
fn print_repeated_runs(events: &[Event], suppressed: &[bool]) {
    let mut totals: HashMap<String, (u64, u64)> = HashMap::new(); // key -> (run_count, wasted_keystrokes)

    // Compact to the logical Normal-mode-family sequence first (dropping
    // suppressed synthetic echoes) so that e.g. "x" presses stay adjacent
    // to each other even though each is followed in the raw stream by its
    // own suppressed "d","l" echo. Run-length-encoding directly over the
    // raw indices would otherwise see every run as length 1.
    let filtered: Vec<&Event> = events
        .iter()
        .enumerate()
        .filter(|(i, e)| {
            !suppressed[*i] && is_normal_family(&e.mode) && !is_cmdline_trigger(&e.key)
        })
        .map(|(_, e)| e)
        .collect();

    let mut i = 0;
    while i < filtered.len() {
        let key = &filtered[i].key;
        let mut j = i + 1;
        while j < filtered.len() && filtered[j].key == *key {
            j += 1;
        }
        let run_len = j - i;
        if run_len >= MIN_REPEAT_RUN {
            let entry = totals.entry(key.clone()).or_insert((0, 0));
            entry.0 += 1;
            entry.1 += (run_len - 1) as u64; // keystrokes a count-prefix could have saved
        }
        i = j;
    }

    println!("-- repeated Normal-mode motions (run >= {MIN_REPEAT_RUN}) --");
    if totals.is_empty() {
        println!("  none found");
    } else {
        let mut rows: Vec<_> = totals.into_iter().collect();
        rows.sort_by_key(|b| std::cmp::Reverse(b.1 .1));
        for (key, (runs, wasted)) in rows.iter().take(10) {
            println!("  {key:<8} {runs} runs, ~{wasted} keystrokes could be replaced by a count/better motion");
        }
    }
    println!();
}

fn print_bigrams(events: &[Event], suppressed: &[bool]) {
    let mut bigrams: HashMap<(String, String), u64> = HashMap::new();

    let filtered: Vec<&Event> = events
        .iter()
        .enumerate()
        .filter(|(i, e)| {
            !suppressed[*i] && is_normal_family(&e.mode) && !is_cmdline_trigger(&e.key)
        })
        .map(|(_, e)| e)
        .collect();

    for w in filtered.windows(2) {
        let (a, b) = (w[0], w[1]);
        if b.delta_ms > BIGRAM_MAX_GAP_MS {
            continue;
        }
        *bigrams.entry((a.key.clone(), b.key.clone())).or_default() += 1;
    }

    println!("-- frequent Normal-mode key pairs --");
    let mut rows: Vec<_> = bigrams.into_iter().filter(|(_, c)| *c >= 3).collect();
    rows.sort_by_key(|b| std::cmp::Reverse(b.1));
    if rows.is_empty() {
        println!("  none found");
    } else {
        for ((a, b), count) in rows.iter().take(15) {
            println!("  {a} {b:<6} x{count}");
        }
    }
    println!();
}

/// Detects "dd" immediately (within a few events) followed by a paste, which
/// often signals moving a line by hand instead of using a dedicated
/// line-move command/mapping.
fn print_dd_then_paste(events: &[Event], suppressed: &[bool]) {
    const LOOKAHEAD: usize = 8;
    let mut hits = 0u64;

    let mut i = 0;
    while i + 1 < events.len() {
        if !suppressed[i]
            && !suppressed[i + 1]
            && is_normal_family(&events[i].mode)
            && events[i].key == "d"
            && is_normal_family(&events[i + 1].mode)
            && events[i + 1].key == "d"
        {
            let window_end = (i + 2 + LOOKAHEAD).min(events.len());
            let found = events[i + 2..window_end]
                .iter()
                .enumerate()
                .any(|(off, e)| {
                    !suppressed[i + 2 + off]
                        && is_normal_family(&e.mode)
                        && (e.key == "p" || e.key == "P")
                });
            if found {
                hits += 1;
            }
            i += 2;
        } else {
            i += 1;
        }
    }

    println!("-- dd followed by paste (possible line-move-by-hand) --");
    println!("  {hits} occurrence(s)");
    println!();
}

fn print_dot_repeat(events: &[Event], suppressed: &[bool]) {
    let operator_keys = ["d", "c", "y", "x", "X", "s", "S", "C", "D"];
    let mut dot_count = 0u64;
    let mut operator_count = 0u64;
    for (i, e) in events.iter().enumerate() {
        if suppressed[i] || !is_normal_family(&e.mode) {
            continue;
        }
        if e.key == "." {
            dot_count += 1;
        } else if operator_keys.contains(&e.key.as_str()) {
            operator_count += 1;
        }
    }

    println!("-- dot-repeat (.) usage --");
    println!("  '.' presses: {dot_count}   edit-operator keypresses: {operator_count}");
    if operator_count > 0 {
        let ratio = dot_count as f64 / operator_count as f64;
        println!("  ratio: {ratio:.2} ('.' per edit operator; low ratio + many repeated edits below may mean '.' is underused)");
    }
    println!();
}

/// Reconstructs `:`-command-line strings from the raw event stream (cmdline
/// input is not affected by the pseudo-command translation, so this reads
/// the unfiltered event list rather than the suppressed one).
fn print_cmdline_commands(events: &[Event]) {
    let mut commands: HashMap<String, u64> = HashMap::new();
    let mut buffer: Option<String> = None;

    for e in events {
        if buffer.is_none() {
            if e.mode == "n" && e.key == ":" {
                buffer = Some(String::new());
            }
            continue;
        }

        if !e.mode.starts_with('c') {
            // Left cmdline mode without a clean <CR>/<Esc> (shouldn't
            // normally happen) — drop the in-progress buffer.
            buffer = None;
            continue;
        }

        match e.key.as_str() {
            "<CR>" => {
                if let Some(cmd) = buffer.take() {
                    if !cmd.is_empty() {
                        *commands.entry(cmd).or_default() += 1;
                    }
                }
            }
            "<Esc>" | "<C-c>" => {
                buffer = None;
            }
            "<BS>" => {
                if let Some(buf) = buffer.as_mut() {
                    buf.pop();
                }
            }
            k if k.chars().count() == 1 => {
                if let Some(buf) = buffer.as_mut() {
                    buf.push_str(k);
                }
            }
            _ => {
                // Ignore other special keys in the cmdline (<Tab> completion,
                // <C-r>, arrows, ...) — not worth modelling precisely here.
            }
        }
    }

    let save_count: u64 = commands
        .iter()
        .filter(|(cmd, _)| *cmd == "w" || cmd.starts_with("w "))
        .map(|(_, c)| *c)
        .sum();

    let mut rows: Vec<_> = commands.into_iter().collect();
    rows.sort_by_key(|b| std::cmp::Reverse(b.1));

    println!("-- command-line (`:`) usage --");
    println!("  `:w` (save) invocations: {save_count}");
    if rows.is_empty() {
        println!("  no other commands recorded");
    } else {
        println!("  top commands:");
        for (cmd, count) in rows.iter().take(10) {
            println!("    :{cmd:<20} x{count}");
        }
    }
    println!();
}
