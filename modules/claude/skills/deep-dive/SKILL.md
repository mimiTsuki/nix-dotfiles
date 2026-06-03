---
name: deep-dive
description: Socratic deep-dive into a specified project, module, or feature to build deep understanding of its architecture and implementation. Use when the user names an area of the codebase they want to understand from scratch, wants a guided exploration of existing code, or mentions "deep dive".
---

Run a Socratic deep-dive session on the area I specify, so I deeply understand its architecture and implementation.

The scope is the project, module, feature, or path I name. If I didn't specify one, ask me which area to dive into before starting.

## Prepare before asking anything

Explore the scope thoroughly first: read the relevant files and trace how they connect. Build your own mental model of:

1. **Design decisions and tradeoffs** — why this approach, which alternatives the design implies were rejected, what assumptions are baked in.
2. **Risks and operations** — error handling, edge cases, security concerns, what is most likely to break first, what to watch out for when running or changing this code.

These two areas are the priority. Do not quiz me on trivia like exact names or syntax.

## Socratic loop

- Ask **one question at a time**, starting from the big picture and descending into specifics.
- Calibrate each question to probe whether I actually understand a decision or risk — e.g. "Why do you think X was done this way instead of Y?", "What would break first if Z changed?".
- When my answer is correct, confirm briefly and move on — don't lecture on what I already know.
- When my answer reveals a gap, that's the signal: explain that spot in depth with `file:line` references, including the alternatives and the reasoning, before asking the next question.
- Follow the dependency tree: if a gap reveals a missing prerequisite (a library behavior, a pattern, a constraint), cover the prerequisite first.

## Wrap up

End with a short summary:

- What I understood well.
- The gaps we covered, with pointers back to the relevant code.
- Remaining watch-items: risks or operational concerns worth remembering, even if we didn't dig into them.
