---
description: Compare the guide against the omp install on this machine and update every drifted page
---
You are updating omp-guide, a documentation repo about the oh-my-pi (omp) coding agent.
The contract of this repo: every stated default, command, flag, or behavior is checkable
against a live omp install, and no version number is hardcoded in prose.
Work from the repo root. $ARGUMENTS

## Ground truth, in order

1. The omp binary on this machine: `omp --version`, `omp --help`, `omp help`, `omp config list --json` (use `omp --profile guide-snapshot` so values are pure defaults).
2. The upstream repo and release notes: https://github.com/can1357/oh-my-pi (docs/, releases).
3. This repo's snapshots in `data/` (they define what the guide was last verified against).

Never state a fact you did not verify against 1 or 2 this run. If a claim cannot be verified, remove or rephrase it as unverified rather than guessing.

## Process

1. Run `sh scripts/snapshot.sh`, then `git diff -- data`. This diff is your work list. Also read any open issues labeled `omp-release`; they may contain diffs from CI runs on other platforms.
2. If the diff is empty and no `omp-release` issue is open: report "no drift" and stop.
3. For each changed key, default, subcommand, or flag:
   - Find every mention across `*.md` with grep (search the key name AND its old value).
   - Re-verify the new behavior against the binary (`omp config get <key>`, help output), not just the snapshot.
   - Update the prose. If a documented recommendation no longer makes sense under the new default, rework the recommendation, do not just swap the number.
4. Check the traps page specifically: a trap that upstream fixed must be moved to a "fixed in <version>" note or deleted, not left to rot.
5. New surface (new settings, subcommands, tools) is only added to the guide if it is beginner-relevant. A new key nobody should touch stays in `data/settings.json` only.

## Style contract

- No em dashes, no curly quotes. Plain hyphens and straight quotes.
- No hardcoded omp version numbers in prose; pages point at `data/version.txt`. Historical facts ("v17.2.2 replaced SWAP/INS/DEL") are allowed.
- Sentence-case headings. Short sentences. Every claim carries a way to check it.
- Keep each page's scope: getting-started (first hour), cheatsheet (tables only), settings (config model + decisions), tips (habits), multi-agent (fan-out), traps (mistakes).

## Verify before you finish

1. `sh scripts/snapshot.sh` again: `git diff -- data` must be empty (idempotent).
2. `grep -rnE "1[0-9]\.[0-9]+\.[0-9]+" *.md` returns only historical-fact mentions.
3. Every relative link in the pages resolves to a file in the repo.

## Deliverable

- One commit per concern (data snapshot, page updates), subjects describing behavior after the change.
- If an `omp-release` issue drove this run, comment on it with a list of pages changed and one line per fact updated, then close it.
- Report: what drifted, what you changed, what you removed because it could not be verified.
