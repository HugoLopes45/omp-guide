# Cheat sheet

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). Run `/hotkeys` and `/settings` for the live truth on your install. Official references: [CLI](https://omp.sh/docs/cli), [Slash commands](https://omp.sh/docs/slash), [Keybindings](https://omp.sh/docs/keybindings).*

## CLI subcommands

Verified against `omp help`; the live list is snapshotted in [`data/subcommands.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/subcommands.txt).

| Command | Effect |
|---|---|
| `omp` | the TUI (bare = launch) |
| `omp login` | log in to a provider from the shell (same as `/login`) |
| `omp setup` | onboarding; install optional dependencies |
| `omp update` | check for and install updates |
| `omp config <list/get/set/reset/path>` | manage settings |
| `omp models` | list, search, refresh available models |
| `omp usage` | provider usage limits for every authed account |
| `omp stats` | local usage dashboard (`-s` summary, `-j` JSON) |
| `omp find "<behavior>"` | semantic search: files and line ranges that implement a behavior |
| `omp read <path/url>[:selector]` | show what the `read` tool returns for a path, URL, or internal URI |
| `omp git` | fullscreen git UI: split diff, staging, commit composer |
| `omp commit` | generate a commit message and update changelogs |
| `omp cleanse` | detect and fix project diagnostics with weighted parallel subagents |
| `omp worktree` | add, list, or clear git worktrees (clone-first when enabled) |
| `omp ps` | list and control daemon-supervised background processes |
| `omp agents` | manage bundled task agents |
| `omp ttsr` | inspect and test time-traveling stream rules |
| `omp skill` | install, search, publish skills on the registry (skills.omp.sh) |
| `omp plugin <...>` / `omp install` | manage plugins; install or link an extension package |
| `omp ssh` | manage SSH host configurations |
| `omp share` / `omp anonymize` | encrypted share link / redacted, shareable copy of a session |
| `omp session` | hand a session to another machine (pack, unpack, moved), or check leases |
| `omp join "<link>"` / `omp collab` | join a collab session / list local collab hosts |
| `omp auth` | export or import stored provider credentials as JSON |
| `omp auth-broker` / `omp auth-gateway` | credential vault / forward proxy |
| `omp token` | print the API key or OAuth token for a provider |
| `omp acp` | run as an ACP server over stdio (Zed and other ACP clients) |
| `omp completions <shell>` | print a completion script (bash, zsh, fish) |
| `omp gc` | storage garbage collection; dry run until `--apply` |
| `omp bench` / `omp if-bench` | benchmark models: speed / instruction following |
| `omp toks` | count tokens with every embedded offline tokenizer |
| `omp compress` | rewrite a text file into the dense prompt register |
| `omp bash` / `omp sh` / `omp zsh` / `omp shell` | run the built-in pi-shell engine / interactive shell console |
| `omp browser-relay` | local CDP relay so the browser drives your own Chrome tabs |
| `omp play` / `omp clip` / `omp stream` | replay a `/record` file / upload it as a public clip / broadcast live |
| `omp render` / `omp gallery` | replay a session through the transcript pipeline / renderer gallery |
| `omp say` / `omp tiny-models` | local text-to-speech / download tiny local models |
| `omp search` / `omp grep` / `omp predict` | test web search / grep tool / word-completion engines |
| `omp images` / `omp grievances` / `omp dry-balance` | image backends / reported tool issues / OAuth balancing dry run |

## Launch flags

The ones you will actually use. `omp --help` has the rest; the snapshot is in [`data/flags.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/flags.txt).

| Flag | Effect |
|---|---|
| `-p` / `--print` | non-interactive: answer one prompt and exit |
| `--mode <text/json/rpc/rpc-ui>` | output mode; pair `json` with `-p` for scripting |
| `--model <selector>` | fuzzy: `opus`, `gpt-5.2`; exact with a provider: `openai/gpt-5.2` |
| `--smol` / `--slow` / `--plan` | override that **role's model**. `--plan` is not plan mode |
| `--thinking <off..max/auto>` | reasoning level for the session |
| `--approval-mode <mode>` | `always-ask`, `always-ask-cached`, `write`, or `yolo` for this session |
| `--auto-approve` | force yolo for this session (the [approvals doc](https://omp.sh/docs/approvals) also lists `--yolo`) |
| `--tools read,edit,bash` | pin the enabled tool set |
| `-c` / `-r [id]` | continue latest in this cwd / resume by id or picker |
| `--restore <id>` | resume, then finish what the last process left unfinished (turn and subagents) |
| `--goal "<objective>"` | start fresh in goal mode (interactive only) |
| `--from-claude` / `--from-codex` | import a Claude Code or Codex session, history intact |
| `--config <path>` | overlay an extra config file; repeatable |
| `--add-dir <dir>` | extra workspace root; repeatable |
| `--max-time <10m>` | hard stop after this duration |
| `--warn-cost <usd>` / `--max-cost <usd>` | warn once / stop new requests at this session spend, subagents included |
| `--plan-yolo` / `--plan-yolo-into <sel>` | plan read-only, auto-approve, implement on another model |
| `--prewalk` / `--no-prewalk` | demote to a cheap model at first edit once a plan exists |
| `--profile <name>` | isolated profile for auth, sessions, settings, caches |
| `--no-session` / `--no-tools` / `--no-lsp` / `--no-context-files` | ephemeral / no tools / no LSP / skip AGENTS.md, CLAUDE.md, ... |
| `--wait-async` | print mode: wait for background jobs before exiting |
| `@path` | attach a file to the first message: `omp @spec.md "do it"` |

## Slash commands

Built-in names come from the command registry of the installed binary. `/` autocomplete is the live list; there is no `/help`.

| Group | Commands |
|---|---|
| Model and effort | `/model` (`/models`) `/switch` `/modelpreset` `/fast` `/slow` `/extended-context` `/prewalk` |
| Modes | `/plan` `/plan-review` `/vibe` `/goal` `/guided-goal` `/loop` `/pause` `/force` |
| Review | `/review` `/annotate` `/green` `/advisor on/off/status/dump/configure` `/security` |
| Agents and jobs | `/hub` (`/subagents`) `/agents` `/jobs` `/tan` `/btw` `/queue` |
| Context | `/context` `/compact` `/shake` `/handoff` `/memory view/stats/diagnose/clear/enqueue` `/skillful` |
| Session | `/new` `/clear` `/fresh` `/delete` `/resume` `/fork` `/branch` (`/rewind`) `/tree` `/wt` (`/worktree`) `/move` `/add-dir` `/rename` `/pin` `/retry` `/session` |
| Share | `/collab` `/join` `/leave` `/share` `/export` `/dump` `/copy` `/open` `/record` |
| Rules and plugins | `/omfg` `/extensions` (`/status`) `/plugins` `/reload-plugins` `/marketplace` `/skills` `/skill:<name>` `/init` |
| Integrations | `/mcp` `/ssh` `/login` `/logout` `/setup` (`/providers`) `/browser` `/computer` `/live` `/git` `/local` |
| Info | `/hotkeys` `/tools` `/settings` `/usage` `/stats` `/trace` `/changelog` `/todo` `/debug` `/forget-approvals` `/exit` `/quit` |

`/branch` (`/rewind`) rewinds to an earlier message and keeps the old path as a branch in the same session file; `/fork` makes a separate session file; `/tree` switches between branches. `/vibe`, `/goal` and `/loop` are session modes, not one-shot commands: they stay on until toggled off. `/tan` runs a full background agent on tangential work; `/btw` asks an ephemeral side question without polluting your context. `/review`, `/green` and `/init` are bundled workflow commands, so a project command with the same name replaces them.

## Keybindings

Remaps live in `~/.omp/agent/keybindings.yml`, not in `config.yml`, and need a restart. A remap replaces that action's whole default list. `/hotkeys` shows the live list.

| Chord | Effect |
|---|---|
| `Enter` | send; while the agent works, steer the current turn |
| `Ctrl+Q` / `Ctrl+Enter` | queue a follow-up for after the turn |
| `Shift+Enter` / `Ctrl+J` / `Alt+Enter` | newline |
| `Escape` | interrupt the active turn |
| `Ctrl+P` / `Shift+Ctrl+P` | cycle role models forward / back |
| `Alt+M` | model selector, assign roles |
| `Alt+P` | pick a model for this session only |
| `Alt+Shift+P` | toggle plan mode |
| `Shift+Tab` | cycle thinking level |
| `Ctrl+T` | show/hide thinking blocks |
| `Ctrl+O` | expand tool output |
| `Ctrl+G` | edit the draft in `$VISUAL` / `$EDITOR` |
| `Alt+Up` / `Shift+Up` | pull a queued message back |
| `Alt+R` | retry the last failed turn |
| `Alt+A` | open the Agent Hub |
| `Ctrl+R` | search prompt history |
| `Ctrl+V` | paste image |
| `Ctrl+L` | live voice mode (`/live`) |
| `Ctrl+C` / `Ctrl+D` | clear the editor (twice to exit) / exit, saving the prompt as a draft |

## Internal URL schemes

Everything the agent touches is a path. `read` accepts all of these, plus selectors such as `:-N` for the last N lines, `:raw:-60` for raw output, and frame/time selectors for video.

| Scheme | Example | Returns |
|---|---|---|
| `pr://` | `pr://1428`, `pr://owner/repo/1428/diff/all` | a PR as a path; `/diff` lists files |
| `issue://` | `issue://42`, `issue://?state=open&label=bug` | an issue, or a live list |
| `agent://` | `agent://Scout/findings.0.path` | a subagent's output; JSON path addressing. `write` sends a message |
| `history://` | `history://Scout` | that subagent's transcript |
| `proc://` | `read proc://`, `write proc://dev/kill` | background jobs and services: list, inspect, stop |
| `local://` | `local://ctx.md` | session-local scratch; where plans live |
| `artifact://` | `artifact://<id>` | full output of a truncated tool result |
| `skill://` | `skill://pdf/references/tables.md` | a skill's files |
| `rule://` | `rule://no-box-leak` | a rule's body, on demand |
| `conflict://` | `write conflict://1` with `@theirs` | resolve one merge conflict (`conflict://*` for all) |
| `xd://` | `read xd://` | the device shelf: list deferred tools |
| `ssh://` | `read ssh://prod/var/log/app.log` | a file on a configured SSH host |

## Where files live

| What | User | Project |
|---|---|---|
| Settings | `~/.omp/agent/config.yml` | `<cwd>/.omp/config.yml` (**cwd only, no walk-up**) |
| Context | `~/.omp/agent/AGENTS.md` | `.omp/AGENTS.md` (nearest ancestor) |
| Sticky rules | `~/.omp/agent/RULES.md` | `.omp/RULES.md` (nearest ancestor) |
| TTSR / rulebook | | `.omp/rules/*.md` |
| Agents | `~/.omp/agent/agents/*.md` | `.omp/agents/*.md` |
| Skills | `~/.omp/agent/skills/<n>/SKILL.md` | `.omp/skills/<n>/SKILL.md` |
| Commands | `~/.omp/agent/commands/*.md` | `.omp/commands/*.md` |
| Prompt templates | `~/.omp/agent/prompts/**/*.md` | `.omp/prompts/**/*.md` |
| Extensions | `~/.omp/agent/extensions/` | `.omp/extensions/` |
| MCP | `~/.omp/agent/mcp.json` | `.omp/mcp.json` |
| Custom models | `~/.omp/agent/models.yml` | |
| Advisor roster | `~/.omp/agent/WATCHDOG.yml` | `WATCHDOG.yml` (every ancestor) |
| Keybindings | `~/.omp/agent/keybindings.yml` | |
| Sessions | `~/.omp/agent/sessions/` | |
| Named profiles | `~/.omp/profiles/<name>/agent/` | |
| Worktrees | `~/.omp/wt` | |
