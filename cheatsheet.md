# Cheat sheet

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt). Keybindings and slash commands come from omp's docs; run `/hotkeys` and `/settings` for the live truth on your install.*

## CLI subcommands

Verified against `omp help`; the live list is snapshotted in [`data/subcommands.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/subcommands.txt).

| Command | Effect |
|---|---|
| `omp` | the TUI (bare = launch) |
| `omp acp` | run as an ACP server over stdio (Zed) |
| `omp agents` | manage bundled task agents |
| `omp auth-broker` / `omp auth-gateway` | credential vault / forward proxy |
| `omp bench` | benchmark models: TTFT, tokens/s, cache workloads |
| `omp browser-relay` | local CDP relay so the browser tool drives your own Chrome tabs |
| `omp cleanse` | detect and fix project diagnostics with weighted parallel subagents |
| `omp commit` | generate a commit message and update changelogs |
| `omp completions <shell>` | print a completion script (bash, zsh, fish) |
| `omp compress` | rewrite a text file into the dense prompt register |
| `omp config <list\|get\|set\|reset\|path>` | manage settings |
| `omp gallery` | preview tool renderers |
| `omp gc` | storage garbage collection; dry run until `--apply` |
| `omp git` | fullscreen git UI: split diff, staging, commit composer |
| `omp grievances` | view/clean/push reported tool issues |
| `omp images` | inspect and purge image publication backends |
| `omp install` | install or link an extension package |
| `omp join "<link>"` | join a shared collab session |
| `omp models` | list, search, refresh available models |
| `omp plugin <...>` | install, uninstall, list, marketplace |
| `omp ps` | list and control daemon-supervised background processes |
| `omp read <path\|url>` | show what the `read` tool returns for a path or internal URI |
| `omp render` | replay a session through the transcript pipeline |
| `omp say` | local text-to-speech |
| `omp search` | test web-search providers |
| `omp setup` | onboarding; install optional dependencies |
| `omp share` | share a saved session as an encrypted link |
| `omp shell` | interactive shell console |
| `omp ssh` | manage SSH host configurations |
| `omp stats` | local usage dashboard over `~/.omp/stats.db` (`-s` summary, `-j` JSON) |
| `omp tiny-models` | download tiny local models (titles, memory) |
| `omp token` | get the API key or OAuth token for a provider |
| `omp ttsr` | inspect and test time-traveling stream rules |
| `omp update` | check for and install updates |
| `omp usage` | provider usage limits for every authed account |
| `omp worktree` / `omp wt` | list or clear agent-managed worktrees (`~/.omp/wt`) |

## Launch flags

The ones you will actually use. `omp --help` has the rest.

| Flag | Effect |
|---|---|
| `-p` / `--print` | non-interactive: answer one prompt and exit |
| `--mode <text\|json\|rpc\|rpc-ui>` | output mode; pair `json` with `-p` for scripting |
| `--model <selector>` | fuzzy: `opus`, `gpt-5.2`, `openai/gpt-5.2` |
| `--smol` / `--slow` / `--plan` | override that **role's model**. `--plan` is not plan mode |
| `--thinking <off..max\|auto>` | reasoning level for the session |
| `--approval-mode <always-ask\|write\|yolo>` | override `tools.approvalMode` for this session |
| `--auto-approve` | force yolo for this session |
| `--tools read,edit,bash` | pin the enabled tool set; unknown names hard-error |
| `-c` / `-r [id]` | continue latest in this cwd / resume by id or picker |
| `--from-claude` / `--from-codex` | import a Claude Code or Codex session, history intact |
| `--config <path>` | overlay an extra config file; repeatable |
| `--add-dir <dir>` | extra workspace root; repeatable |
| `--max-time <10m>` | hard stop after this duration |
| `--plan-yolo` / `--plan-yolo-into <sel>` | plan read-only, auto-approve, implement on another model |
| `--prewalk` / `--no-prewalk` | demote to a cheap model at first edit once a plan exists |
| `--profile <name>` | isolated profile for auth, sessions, settings, caches |
| `--no-session` / `--no-tools` / `--no-lsp` | ephemeral / no tools / no LSP |
| `@path` | attach a file to the first message: `omp @spec.md "do it"` |

## Slash commands

| Group | Commands |
|---|---|
| Model and effort | `/model` `/models` `/switch` `/fast` `/prewalk` |
| Modes | `/plan` `/plan-review` `/vibe` `/goal` `/guided-goal` `/loop` `/pause` `/force` |
| Review | `/review` `/advisor on\|off\|status\|dump\|configure` |
| Agents and jobs | `/agents` `/jobs` `/tan` `/btw` `/queue` |
| Context | `/context` `/compact` `/shake` `/handoff` `/memory view\|stats\|diagnose\|clear\|enqueue` |
| Session | `/new` `/clear` `/reset` `/fresh` `/drop` `/resume` `/fork` `/branch` `/tree` `/rename` `/retry` |
| Share | `/collab` `/join` `/leave` `/share` `/export` `/copy` |
| Rules and plugins | `/omfg` `/extensions` `/plugins` `/reload-plugins` `/marketplace` `/skill:<name>` |
| Integrations | `/mcp add\|list\|test\|reconnect\|reload` `/ssh` `/login` `/logout` `/browser` `/live` |
| Info | `/hotkeys` `/tools` `/settings` `/providers` `/usage` `/stats` `/changelog` `/todo` `/debug` `/exit` |

`/vibe`, `/goal` and `/loop` are session modes, not one-shot commands: they stay on until toggled off. `/tan` runs a full background agent on tangential work; `/btw` asks an ephemeral side question without polluting your context.

## Keybindings

Remaps live in `~/.omp/agent/keybindings.yml`, not in `config.yml`. `/hotkeys` shows the live list.

| Chord | Effect |
|---|---|
| `Ctrl+P` / `Shift+Ctrl+P` | cycle role models forward / back |
| `Alt+M` | model selector, assign roles |
| `Alt+P` | pick a model for this session only |
| `Alt+Shift+P` | toggle plan mode |
| `Shift+Tab` | cycle thinking level |
| `Ctrl+T` | show/hide thinking blocks |
| `Ctrl+O` | expand tool output |
| `Ctrl+G` | edit the draft in `$EDITOR` |
| `Ctrl+Q` / `Ctrl+Enter` | queue a follow-up |
| `Alt+Up` | pull a queued message back |
| `Alt+R` | retry the last failed turn |
| `Alt+A` | open the agent hub |
| `Ctrl+R` | search prompt history |
| `Ctrl+V` | paste image |
| `Esc` / `Ctrl+C` / `Ctrl+D` | interrupt / clear / exit |
| hold `Space` | push-to-talk speech-to-text |

## Internal URL schemes

Everything the agent touches is a path. `read` accepts all of these.

| Scheme | Example | Returns |
|---|---|---|
| `pr://` | `pr://1428`, `pr://owner/repo/1428/diff/all` | a PR as a path; `/diff` lists files |
| `issue://` | `issue://42`, `issue://?state=open&label=bug` | an issue, or a live list |
| `agent://` | `agent://Scout/findings.0.path` | a subagent's output; JSON path addressing |
| `history://` | `history://Scout` | that subagent's transcript |
| `local://` | `local://ctx.md` | session-local scratch; where plans live |
| `skill://` | `skill://pdf/references/tables.md` | a skill's files |
| `rule://` | `rule://no-box-leak` | a rule's body, on demand |
| `conflict://` | `write conflict://1` with `@theirs` | resolve one merge conflict |
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
| Extensions | `~/.omp/agent/extensions/` | `.omp/extensions/` |
| MCP | `~/.omp/agent/mcp.json` | `.omp/mcp.json` |
| Advisor roster | `~/.omp/agent/WATCHDOG.yml` | `WATCHDOG.yml` (every ancestor) |
| Keybindings | `~/.omp/agent/keybindings.yml` | |
| Sessions | `~/.omp/agent/sessions/` | |
| Worktrees | `~/.omp/wt` | |
