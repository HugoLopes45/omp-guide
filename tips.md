# Tips and tricks

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). Ordered roughly by payoff.*

## Route by role, not by hope

The single highest-leverage habit. Assign a cheap model to `smol` (fan-out, titles, mechanical work), a strong one to `slow` and `plan`, and stop running everything on the biggest model "to be safe". `Alt+M` assigns roles; `Ctrl+P` cycles; `--smol/--slow/--plan` override at launch.

## `/omfg` turns annoyance into policy

The agent reaches for a banned API, ignores a convention, does the thing again. Type `/omfg` right after: omp forges a TTSR rule (time-traveling stream rule) from your complaint. The rule sleeps until a regex matches the live output stream, then aborts mid-token, injects the correction, and retries from that exact point. Zero context cost until it fires, permanent once written. Inspect with `omp ttsr`.

## Plan mode is the first big jump

`/plan` (or `Alt+Shift+P`) makes the agent hard read-only and produces an execution spec at `local://<slug>-plan.md`. The quality bar: a competent implementer who never saw your conversation could execute the file top to bottom with zero design decisions. Read the plan before approving. Trap: the `--plan` flag sets the plan role's *model*; it does not enter plan mode.

## `ultrathink` and `chillax`, one word, one turn

A bare, lowercase `ultrathink` in your prompt asks for careful reasoning on that turn. With `defaultThinkingLevel: auto` it also selects the model's highest effort. `chillax` is the opposite: brief reasoning, lowest effort. Both are cheaper than changing `defaultThinkingLevel` globally; `Shift+Tab` cycles the level live for a stretch. They are ignored inside code spans, fences and paths. Reference: [Magic keywords](https://github.com/can1357/oh-my-pi/blob/main/docs/magic-keywords.md).

## Know your context exits

They are not interchangeable:

| Command | What happens | Cost |
|---|---|---|
| `/compact` | an LLM summarizes older history | a summarization call |
| `/shake` | heavy tool results become recoverable `artifact://` refs | free; nothing lost, just parked |
| `/handoff` | fresh session carrying a handoff document | the live context is gone |
| `/fresh` | re-keys a wedged provider stream, context intact | free; use before reaching for `/clear` |
| `/context` | shows what is actually filling the window | free; run it before choosing |

## `/btw` and `/tan` protect your context

`/btw` asks a side question against the current context without polluting it. `/tan` spins a full background agent for tangential work. Both exist so your main thread stays on the main thing.

## Memory is off until you flip it

`memory.backend` ships `off`; nothing persists between sessions. `omp config set memory.backend mnemopi` gives you a local SQLite bank, project-scoped. Work a normal day, then `/memory stats` to see what it kept. `/memory enqueue` forces full retention now.

## Read the meter before tuning

```sh
omp stats -s          # where the model-minutes went
omp usage             # remaining quota on every authed account
omp bench             # race your models: TTFT, tokens/s
```

`~/.omp/stats.db` is plain SQLite (`messages`, `tool_calls`, `user_messages`). One query answers questions like "how many requests does my advisor fire per main turn". Set `advisor.syncBacklog`, compaction, and fallback chains from numbers, not vibes.

## Edits are anchored, not guessed

The default edit mode (`hashline`) anchors patches to a content hash of the file minted by the last `read`. A stale edit is recovered when the snapshot chain proves one safe result; otherwise it is *rejected with the current tag and context*, never misapplied. Edits anchored on lines the agent never displayed in full are refused too (`edit.enforceSeenLines`). A `stale_tag` or `unseen_lines` error means the guard worked. Reference: [edit tool](https://github.com/can1357/oh-my-pi/blob/main/docs/tools/edit.md).

## `eval` beats `bash: python -c`

The `eval` tool runs persistent Python and JS cells with shared state, structured display, and cancellation. It can call back into the agent's own tools (`tool.read(...)`, `agent(...)` with `wait(...)`, `workpool(...)`, `completion(...)`), which turns "spawn some subagents" into a loop with a budget. Shelling out to `python -c` loses all of that.

## Everything is a path

`read pr://1428` for a pull request, `read issue://42`, `read agent://Scout` for a subagent's output, `read ssh://prod/var/log/app.log` for a remote file, `read xd://` to list deferred tools. Stop pasting content into the prompt; point at it.

## Queue follow-ups instead of interrupting

`Ctrl+Q` queues your next message while the agent works; `Alt+Up` pulls it back. Steering messages interrupt by default (`interruptMode: immediate`); set `wait` if you prefer the agent to finish its thought.

## Pin secrets down

`secrets.enabled: true` obfuscates configured secrets and credential-shaped tokens before anything leaves for a provider. `/share` runs a redactor over session snapshots (`share.redactSecrets`, on by default), but review for plain confidential data yourself; redaction targets credentials, not client data.

## Let long commands background themselves

Auto-backgrounding (`bash.autoBackground.enabled`, on by default, after 60s) moves anything slow into a managed job instead of blocking the turn; the result auto-delivers. For dev servers and watchers, the agent starts a named service (`bash` with `name` and a `ready` port or log regex), then inspects it with `read proc://<name>` and stops it with `write proc://<name>/kill`. They stop being a reason the agent "hangs". Details in [Multi-agent](multi-agent.md#background-jobs-and-services-wait-and-proc).

## Import your history from other tools

`omp --from-claude` / `omp --from-codex` import a Claude Code or Codex session with history intact. omp also reads project files such as `CLAUDE.md`, `AGENTS.md`, Cursor MDC, `.clinerules` and Copilot instructions natively. Standalone `CLAUDE.md` files in the project or its ancestors load alongside `AGENTS.md`; user-level provider config sources are opt-in through `enabledProviders`. Switching costs nothing.

## `omp cleanse` for the diagnostics pile

Type errors and lint noise accumulated across a repo? `omp cleanse` fans out weighted parallel subagents to fix project diagnostics. Good Monday-morning command.

## `omp git` when you want hands on the wheel

A fullscreen git UI with split diffs, a staging sidebar, and a commit composer. `omp commit` writes the message and updates changelogs.
