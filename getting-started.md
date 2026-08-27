# Getting started

*Verified against the omp release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt); drift from newer releases is tracked automatically in the issues.*

## Install

```sh
curl -fsSL https://omp.sh/install | sh          # macOS / Linux
brew install can1357/tap/omp                    # Homebrew
bun install -g @oh-my-pi/pi-coding-agent        # Bun >= 1.3.14
irm https://omp.sh/install.ps1 | iex            # Windows PowerShell, native
mise use -g github:can1357/oh-my-pi             # pinned versions
```

Add completions: `eval "$(omp completions zsh)"` (also `bash`, `fish`).

## First session

```sh
cd your-repo
omp
```

`omp setup` runs onboarding and installs optional dependencies. `omp update` keeps you current.

Log in to a provider with `/login` inside the TUI. omp routes across providers by **role** (default, smol, slow, plan, advisor, ...), so you can mix a strong model for planning with a cheap one for grunt work. `/models` shows what is available; `Alt+M` opens the selector and assigns roles.

## The four inputs that matter on day one

| Input | What it does |
|---|---|
| `/plan` | Read-only planning mode. The agent writes an execution spec to `local://<slug>-plan.md` and hands you the approval. Read the file. |
| `Shift+Tab` | Cycle the thinking (reasoning) level live. A bare `ultrathink` in your prompt buys one maximum-depth turn. |
| `Ctrl+P` | Cycle role models forward (`Shift+Ctrl+P` back, `Alt+P` temporary pick). |
| `/omfg` | The agent just did the annoying thing? This forges a permanent stream rule from your complaint. Free until it fires. |

## Give it context, once

Two files, two jobs, both discovered from the nearest ancestor of your cwd:

- `.omp/AGENTS.md`: project context. Conventions, gotchas, architecture notes.
- `.omp/RULES.md`: sticky rules, re-attached near the current turn so they still bite 200 messages in. Keep it short and non-negotiable:

```md
Never commit or push unless I explicitly ask.
Do not edit generated files.
```

Already have `CLAUDE.md`, `AGENTS.md`, Cursor rules, or `.clinerules`? omp reads them natively. Nothing to migrate; native `.omp` files win on collision.

## Attach things

```sh
omp @spec.md @screenshot.png "implement this"
```

`@path` attaches files to the first message. Inside the TUI, paste images with `Ctrl+V`.

## Headless, when you are ready

```sh
omp -p "summarize the changes in this diff" --mode json --tools read,grep,glob --max-time 5m --no-session
```

Same engine, no TUI. See the [cheat sheet](cheatsheet.md#launch-flags) for the full flag list.

## Where to go next

- [Cheat sheet](cheatsheet.md): the whole surface on one page.
- [Settings](settings.md): the config model, and the decision you must make about approvals.
- [Traps](traps.md): read this before your first fan-out.
