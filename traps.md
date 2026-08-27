# Traps

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). Every entry here has cost someone real time. Several were discovered the hard way on a live install.*

## Config traps

**Project settings do not walk up.** `<cwd>/.omp/config.yml` is read from the directory you launch in, and only there. A config in a parent directory is silently ignored. Context files (`AGENTS.md`, `RULES.md`) do walk up; settings do not.

**Arrays replace wholesale, per layer.** Config arrays (`bash.patterns`, `compaction.methodOrder`, ...) never merge across layers. A project file that defines `bash.patterns` deletes every global guard for that project. If you rely on global guardrail arrays, load them as a `--config` overlay (resolves after project config) and know that GUI-spawned omp never sources your shell profile, so env-driven overlays do not reach it.

**Your edit did nothing? Ask which layer wins.** `omp config get <key>` prints the merged effective value. If it does not show your change, a higher layer (project file, overlay, CLI flag) is shadowing you.

**`allow` rules are inert under `yolo`.** The default approval mode auto-approves everything, so only `deny` and `prompt` entries in `bash.patterns` do anything. The allow-list matters the day you switch to `write` or `always-ask`.

**`eval` is not gated by `bash.patterns`.** Python/JS cells can spawn shells at the exec tier. A bash deny does not cover it; use `tools.approval.eval` if you need that boundary.

## Autonomy traps

**`yolo` is the default.** Fresh install, zero prompts: reads, writes, and shell all auto-approve. Decide your posture on purpose. See [Settings](settings.md#approval-the-first-decision).

**Unlimited provider concurrency meets 32 subagents.** `providers.maxInFlightRequests` defaults to unlimited and `task.maxConcurrency` to 32. One enthusiastic fan-out can 429-storm a provider and burn a rate-limit window in minutes. Cap every provider you pay for.

**`tools.maxTimeout` defaults to 0 (no limit).** A subagent in a goal loop can request a two-hour wait on a hung command. A finite cap (600-900s) plus auto-backgrounding covers real builds without the pathology.

## Mode traps

**`--plan` is not plan mode.** The flag sets which model the `plan` *role* uses. Plan mode is `/plan` or `Alt+Shift+P`. The launch flag that does start a session planning is `--plan-yolo`.

**`isolated: true` silently does not exist until you enable isolation.** The field appears on task spawns only once `task.isolation.mode` is set (ships as `none`). It also needs a git repo and plan mode off. Fanning out writers without it means siblings clobber each other.

**`/vibe`, `/goal`, `/loop` are modes, not commands.** They stay on until toggled off, and vibe is exclusive with plan and goal, even paused ones. Leaving vibe kills every worker.

## Expectation traps

**"It'll remember" - no.** `memory.backend` ships `off`. Nothing persists between sessions until you turn it on.

**`alwaysApply: true` on every rule eats your window.** A rule with `alwaysApply` injects its full body into every system prompt. Use it for the two lines that are non-negotiable; give everything else a `description` (fetched on demand) or a `condition` (a TTSR rule, free until it fires).

**Old hashline tutorials teach dead syntax.** v17.2.2 (2026-07) replaced `SWAP`/`INS`/`DEL` with `PUT`/`CUT`. The old op names no longer parse.

**`includeWorkspaceTree` breaks prompt caching.** A workspace tree in the system prompt changes on every file modification, which busts the provider prefix cache across sessions. Keep it off; the agent has glob and grep.

**Sampling knobs are not free tuning.** `temperature`, `topP` and friends default to -1 (provider default). Changing them globally without a controlled eval makes quality regressions impossible to attribute.

## Cost traps

**The advisor is a second bill.** Its own model, its own transcript, its own compactions, roughly one extra review stream per turn. Turn it on deliberately and read `omp stats -s`.

**Compaction strategies have different bills.** `shake` parks tool results as recoverable refs (free). `snapcompact` renders history to images (needs a vision model). A full LLM summary costs a model call every time. `/context` shows what is filling the window before you pick.

**A wedged stream does not need `/clear`.** `/fresh` re-keys the provider stream and keeps your context. `/clear` throws your context away.
