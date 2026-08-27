<p class="kicker">The missing manual</p>

# Drive <span class="accent">omp</span> like you built it.

The beginner guide to [oh-my-pi](https://github.com/can1357/oh-my-pi) (`omp`): cheat sheets, tips and tricks, sane configs, and the traps that cost you an afternoon.

`omp` is a terminal coding agent: one TUI (plus headless modes) that drives Claude, GPT, Gemini and local models against your codebase, with LSP, a debugger, subagents, and a Rust-fast tool layer built in. It is powerful and dense. This repo is the on-ramp.

> Not an official publication. omp moves fast and defaults change. Everything here was verified on a live install of the release recorded in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt); a weekly job re-checks every new release and files an issue when anything documented here drifts. Run `omp config list` to see what *your* install actually does.

## Start here

| You want | Read |
|---|---|
| Install and a first productive session | [Getting started](getting-started.md) |
| Every key, command, flag, and path on one page | [Cheat sheet](cheatsheet.md) |
| Understand and tune the config (and not get burned) | [Settings](settings.md) |
| Habits that make omp feel unfair | [Tips and tricks](tips.md) |
| Subagents, parallel work, the advisor | [Multi-agent](multi-agent.md) |
| The mistakes everyone makes once | [Traps](traps.md) |

## The 5-minute version

```sh
# install (macOS / Linux)
curl -fsSL https://omp.sh/install | sh

# first session, in a repo you know
cd your-repo
omp
```

Then, in order:

1. Run `omp config get tools.approvalMode`. It says `yolo`: every tool call auto-approves, shell included. Decide deliberately whether you want that on this machine (see [Settings](settings.md#approval-the-first-decision)).
2. Type `/plan` before your first non-trivial task. The agent goes read-only and writes a plan file; read it before approving.
3. When the agent does something annoying, type `/omfg`. It forges a permanent correction rule from your complaint.
4. Press `Shift+Tab` to change the thinking level, `Ctrl+P` to cycle models.
5. Read the diff it produced, not the conversation.

## Sources

- The [oh-my-pi repository](https://github.com/can1357/oh-my-pi): docs, settings schema, command registry.
- A live install: `omp --help`, `omp config list`, and real usage data.
- Automated drift tracking: a weekly CI job installs the latest omp, snapshots its settings schema and CLI surface into [`data/`](https://github.com/HugoLopes45/omp-guide/blob/main/data/), and opens an issue when anything documented here changes. See [How this stays current](#how-this-stays-current).

## How this stays current

omp ships fast, and stale guides are worse than no guides. This repo tracks upstream automatically:

- `data/` holds machine-readable snapshots of the omp surface: `version.txt`, `settings.json` (every key, type, default), `subcommands.txt`, `flags.txt`.
- A [weekly GitHub Action](https://github.com/HugoLopes45/omp-guide/blob/main/.github/workflows/watch-omp.yml) installs the latest omp in a clean environment, regenerates the snapshots, commits the diff, and **opens an issue listing exactly which settings, defaults, commands, or flags changed**. Each issue is the review queue for updating the prose.
- No version numbers are hardcoded in the prose. `data/version.txt` is the single source of truth for what the guide was last verified against, and the issue queue is the list of what moved since.

- The update itself is agent-driven: [`.omp/commands/update-docs.md`](https://github.com/HugoLopes45/omp-guide/blob/main/.omp/commands/update-docs.md) is a versioned brief that compares the guide against a live install and rewrites every drifted page. In omp, run `/update-docs` from the repo root; in any other coding agent, paste the file as the prompt.

Regenerate snapshots locally anytime: `sh scripts/snapshot.sh`.

## Contributing

PRs welcome. One rule: every stated default or behavior must be checkable against the omp source or a live install, and the version it was checked against stays in the text.

## License

[MIT](https://github.com/HugoLopes45/omp-guide/blob/main/LICENSE)
