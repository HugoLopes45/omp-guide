# Multi-agent

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). This is the leverage jump: one dev thinking in parallel ships like three. It is also where the sharpest traps live; read [Traps](traps.md) before your first fan-out. Official reference: [Subagents & Agent Hub](https://omp.sh/docs/subagents), [task tool](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/task.md).*

## Before anything: isolation

```sh
omp config set task.isolation.enabled true    # ships as false; backend defaults to auto
```

With isolation disabled (the default), parallel workers edit the same working tree and can clobber each other. Enable it to give each worker its own workspace (CoW clone, overlayfs, or a git worktree, whatever your filesystem supports) and return **patches** instead of raw edits. `isolation.backend` defaults to `auto` and selects the available backend. The `isolated` field only exists in the task schema when isolation is enabled and plan mode is off.

## The task tool: batch-shaped fan-out

One call, one shared `context`, one entry per worker:

```json
{
  "context": "Monorepo, Bun + TypeScript. Target: drop the legacy utils/date.ts helper.",
  "tasks": [
    { "name": "Callers",  "agent": "scout", "task": "List every import of utils/date.ts with file:line.",
      "solutionSpace": "lookup only, no design" },
    { "name": "Migrate",  "task": "Replace date.ts helpers with Temporal API in packages/api.",
      "solutionSpace": "mechanical: helper names and replacements given", "isolated": true },
    { "name": "Migrate2", "task": "Same migration in packages/web.",
      "solutionSpace": "mechanical: helper names and replacements given", "isolated": true }
  ]
}
```

`solutionSpace` is required: it tells the worker how open the problem is (fix given, or cause still unknown), not how much work it is. You rarely write this JSON yourself; the agent does. Your job is the vocabulary around it:

- **`orchestrate`**, standalone and lowercase in your prompt, tells the agent to delegate independent work to parallel subagents and verify each phase. **`workflowz`** asks for a deterministic multi-subagent workflow in the `eval` kernel. See [Magic keywords](https://github.com/can1357/oh-my-pi/blob/main/docs/magic-keywords.md).
- Results are usually paths, but workers can also return structured objects. Use `read agent://Callers` for a worker's output, `read agent://Callers/findings.0.path` for one field, or `read history://Migrate` for its transcript.
- `Alt+A` (or `/hub`) opens the Agent Hub: live roster, transcripts, steering, revive or kill a worker without aborting the parent. `/agents` is a different screen: it configures per-agent models, prewalk and advisor.
- Up to `task.maxConcurrency` run at once (default 32; cap your providers first, see [Traps](traps.md#autonomy-traps)).

Bundled agents: `scout`, `reviewer`, `security-reviewer`, `task`, `sonic`. `omp agents` manages them from the shell.

## Your own agent is a markdown file

`.omp/agents/dep-auditor.md`:

```md
---
name: dep-auditor
description: Audits one package's dependencies for unused and outdated entries.
model: "@smol"
tools: read, grep, glob, bash
thinkingLevel: low
output:
  type: object
  properties:
    unused:   { type: array, items: { type: string } }
    outdated: { type: array, items: { type: string } }
  required: [unused, outdated]
---
You audit dependencies for exactly one package directory.
Read its package.json, grep the source for each dependency, and run
`bun outdated` there. Report only what you verified. Never edit files.
```

The `output` schema is the point: the worker's result is validated against it, so the parent reads a real object instead of parsing text. A per-call `outputSchema` in the task item overrides it. `model: "@smol"` keeps a fleet of these cheap. Rules can target an agent with `agents` frontmatter; use `omp ttsr list` to enumerate rules and `omp ttsr test --agent <name>` to evaluate agent-scoped matches. Reference: [task agent discovery](https://github.com/can1357/oh-my-pi/blob/main/docs/task-agent-discovery.md).

## The advisor: a second model on every turn

```yaml
# ~/.omp/agent/config.yml
modelRoles:
  advisor: anthropic/claude-sonnet-5:medium
advisor:
  enabled: true
```

The advisor reads the primary agent's transcript after each turn, inspects the workspace with its own read-only tools, and injects a `nit` (batched quietly), a `concern`, or a `blocker` (both interrupt). Its own model, its own context: it catches what the doer rushed past. It advises; it cannot approve or change state. `/advisor` toggles it for a session; `--advisor` enables it at launch.

Dials:

| Key | Default | Effect |
|---|---|---|
| `advisor.reviewMode` | `turn` | `agent-end` reviews only final answers: far cheaper |
| `advisor.reviewInterval` | `1` | review every Nth eligible update |
| `advisor.maxNotesPerUpdate` | `4` | cap non-blocker notes per review |
| `advisor.syncBacklog` | `off` | make the primary wait when the advisor falls behind |
| `advisor.immuneTurns` | `3` | throttle repeat interruptions |

A `WATCHDOG.yml` defines a roster of named advisors with different lenses and models; a sibling `WATCHDOG.md` holds guidance only the advisors see. Reference: [Advisor and WATCHDOG](https://github.com/can1357/oh-my-pi/blob/main/docs/advisor-watchdog.md).

Cost honesty: the advisor is a second bill, roughly one review stream per turn. `omp stats -s` tells you the advisor:main request ratio; decide from that.

## Vibe: direct long-lived workers

`task` fires and forgets. `/vibe` keeps workers alive and makes you the director: your session drops to read-only plus five controls (`vibe_spawn`, `vibe_send`, `vibe_wait`, `vibe_kill`, `vibe_list`). `fast` workers (the `sonic` agent on `@smol`) grind mechanical volume, `good` workers (the `task` agent) handle the judgment, and `vibe_send` steers any of them mid-flight. Exclusive with plan and goal modes, even paused ones; leaving vibe cancels in-flight worker turns, so land the work first. Reference: [Vibe mode](https://github.com/can1357/oh-my-pi/blob/main/docs/vibe-mode.md).

## Background jobs and services: `wait` and `proc://`

The old `hub` tool is gone. Background work now has three surfaces:

- **Jobs.** Slow `bash` and `eval` calls move to the background on their own (`bash.autoBackground.enabled`, after `bash.autoBackground.thresholdMs`, default 60s). Results auto-deliver; the agent calls `wait` only when it has nothing else to do.
- **Services.** A `bash` call with a `name` runs a supervised service, and `ready` gates on a log regex or a port, so nobody races the server. Reusing a live name restarts it with the new spec.
- **Control.** Everything is a path: `read proc://` lists jobs and services, `read proc://dev` shows status and output, `write proc://dev/kill` stops it, `write agent://Migrate2` messages a live peer.

```
bash { "command": "bun run dev", "name": "dev", "ready": { "port": 3000, "timeout": 30 } }
read proc://dev
write agent://Migrate2  "api patch landed, rebase before you yield"
```

From outside the session, `omp ps` lists and controls supervised processes, and `/jobs` shows them in the TUI. Reference: [wait tool](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/wait.md), [bash tool](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/bash.md).

## Orchestration under real control flow

When "spawn some subagents" needs to be a loop with a budget instead of a vibe, the `eval` kernel calls back into the agent's own tools from a Python or JS cell. `agent()` returns a handle immediately; `wait()` collects them:

```python
import json
pkg = json.loads(read("package.json"))
handles = [agent(f"Audit {d} for CVEs", agent="dep-auditor", label=d)
           for d in pkg["dependencies"]]
results = wait(handles)    # blocks until every handle settles, input order
print([r for r in results if r["unused"]])
```

Prelude surface: `tool.<name>(args)`, `read`/`write`, `agent(...)` and `wait(...)`, `workpool(...)` (a pool of keep-alive workers bounded by `task.maxConcurrency`), `completion(...)` (one tool-free model call, optionally schema-typed), `judge(...)` (bulk classification, see the `jevify` keyword), `phase(...)`, `budget`. Recursion respects `task.maxRecursionDepth` (default 2). Reference: [eval tool](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/eval.md).
