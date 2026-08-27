# Multi-agent

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). This is the leverage jump: one dev thinking in parallel ships like three. It is also where the sharpest traps live; read [Traps](traps.md) before your first fan-out.*

## Before anything: isolation

```sh
omp config set task.isolation.mode auto    # ships as "none"
```

With isolation `none` (the default), parallel workers edit the same working tree and clobber each other. `auto` gives each isolated worker its own workspace (CoW clone, overlayfs, or a git worktree, whatever your filesystem supports) and returns **patches** instead of raw edits. Requirements: a git repo, and plan mode off.

## The task tool: batch-shaped fan-out

One call, one shared `context`, one entry per worker:

```json
{
  "context": "Monorepo, Bun + TypeScript. Target: drop the legacy utils/date.ts helper.",
  "tasks": [
    { "name": "Callers",  "agent": "scout", "task": "List every import of utils/date.ts with file:line." },
    { "name": "Migrate",  "task": "Replace date.ts helpers with Temporal API in packages/api.", "isolated": true },
    { "name": "Migrate2", "task": "Same migration in packages/web.", "isolated": true }
  ]
}
```

You rarely write this JSON yourself; the agent does. Your job is the vocabulary around it:

- **`orchestrate`**, standalone and lowercase in your prompt, tells the agent to delegate independent work to parallel subagents and verify each phase. **`workflowz`** asks for a deterministic multi-subagent workflow.
- Results are paths, not prose: `read agent://Callers` for a worker's output, `read agent://Callers/findings.0.path` for one field, `read history://Migrate` for its transcript.
- `/agents` (or `Alt+A`) is the control center; watch the fleet run.
- Up to `task.maxConcurrency` run at once (default 32; cap your providers first, see [Settings](settings.md#defaults-worth-knowing-18x)).

Bundled agents: `scout`, `reviewer`, `security-reviewer`, `designer`, `librarian`, `sonic`, `task`.

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

The `output` schema is the point: the worker's result is validated against it, so the parent reads a real object instead of parsing text. `model: "@smol"` keeps a fleet of these cheap.

## The advisor: a second model on every turn

```yaml
# ~/.omp/agent/config.yml
modelRoles:
  advisor: anthropic/claude-sonnet-5:medium
advisor:
  enabled: true
```

The advisor reads the primary agent's transcript after each turn, inspects the workspace with its own read-only tools, and injects a `nit` (batched quietly), a `concern`, or a `blocker` (both interrupt). Its own model, its own context: it catches what the doer rushed past. It advises; it cannot approve or change state.

Dials: `advisor.syncBacklog` (off by default) makes the primary wait up to 30s when the advisor falls behind; `advisor.immuneTurns` (3) throttles repeat interruptions. A `WATCHDOG.yml` defines a roster of named advisors with different lenses and models; a sibling `WATCHDOG.md` holds guidance only the advisors see.

Cost honesty: the advisor is a second bill, roughly one review stream per turn. `omp stats -s` tells you the advisor:main request ratio; decide from that.

## Vibe: direct long-lived workers

`task` fires and forgets. `/vibe` keeps workers alive and makes you the director: your session drops to read-only plus five `vibe_*` controls, `fast` workers (the `sonic` agent on `@smol`) grind mechanical volume, a `good` worker (the `task` agent) reviews what they produce, and `vibe_send` steers any of them mid-flight. Exclusive with plan and goal modes; leaving vibe kills every worker, so land the work first.

## Hub: switchboard and process supervisor

One tool does both peer messaging between live agents and real process supervision:

```
hub { "op": "start", "name": "dev", "application": "bun", "args": ["run", "dev"],
      "ready": { "port": 3000, "timeout": 30 }, "restart": "on-failure" }
hub { "op": "logs", "name": "dev", "grep": "error|warn", "follow": true }
hub { "op": "send", "to": "Migrate2", "message": "api patch landed, rebase before you yield" }
```

Launch with a readiness gate so nobody races the server; grep logs instead of tailing; send keys or signals when it wedges. `omp ps` lists supervised processes from outside the session.

## Orchestration under real control flow

When "spawn some subagents" needs to be a loop with a budget instead of a vibe, the `eval` tool's bridge calls back into the agent's own tools from a Python or JS cell:

```python
import json
pkg = json.loads(read("package.json"))
results = parallel([
    lambda d=d: agent(f"Audit {d} for CVEs", agent="dep-auditor", label=d)
    for d in pkg["dependencies"]
])
display([r for r in results if r["unused"]])
```

Bridge surface: `tool.<name>(args)`, `read`/`write`, `agent(...)`, `parallel(...)`, `pipeline(...)`, `completion(...)`, `budget.remaining()`. Recursion respects `task.maxRecursionDepth` (default 2).
