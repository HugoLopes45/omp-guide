# Settings

*Verified with `omp config list` against the release in [`data/version.txt`](data/version.txt). 350+ keys exist; this page covers the model of how config works, the decisions that matter, and a sane starter file. The full machine-readable list lives in [`data/settings.json`](data/settings.json), regenerated automatically from each omp release.*

## How config resolves

Precedence, lowest to highest:

```
defaults  <  ~/.omp/agent/config.yml  <  <cwd>/.omp/config.yml  <  --config overlays  <  CLI flags
   (global)                              (project, cwd ONLY)       (also PI_CONFIG_FILES)
```

Three facts people learn the hard way:

1. **Project settings do not walk up ancestors.** Only context files (`AGENTS.md`, `RULES.md`) do. A `.omp/config.yml` in a parent directory of where you launched is silently ignored.
2. **Arrays replace wholesale, per layer.** They do not merge. If a project `.omp/config.yml` defines `bash.patterns`, it deletes every global pattern for that project. If you keep global guardrails in an array, either never define that array at project level, or load the global version as a `--config` overlay (via `PI_CONFIG_FILES` in your shell profile) so it resolves after project config. Caveat: GUI-spawned omp (ACP, launchd) never sources your shell profile, so an env-based overlay does not reach it.
3. **`omp config get <key>` shows the merged, effective value** from wherever your shell runs it, overlays included. When a change seems to have no effect, ask which layer you edited and which layer wins.

Useful commands:

```sh
omp config list --json   # every key with its effective value
omp config get <key>
omp config set <key> <value>
omp config path          # which directory the global config lives in
/settings                # same thing with a UI
```

## Approval: the first decision

**The default is `yolo`: reads, writes, and shell commands all auto-approve.** That is a deliberate default for a tool built to run fast, and it is your call to keep or narrow. Three layers, each beating the one before:

```yaml
tools:
  approvalMode: yolo        # baseline: always-ask | write | yolo
  approval:
    bash: prompt            # per-tool policy: beats the mode, in every mode
bash:
  patterns:                 # per-command rules: beat the tool policy; first match wins
    - { match: "git status*",       approval: allow }
    - { match: "rm -r*",            approval: deny }
    - { match: "git push --force*", approval: deny }
```

Facts that shape a good ruleset:

- Under `yolo`, `allow` rules are inert (everything is allowed anyway). Only `deny` and `prompt` rules matter. Keep the allow-list anyway if you might ever switch to `write` or `always-ask`.
- `deny` blocks outright; `prompt` requires your explicit approval. For a command that is legitimate somewhere ("cargo run", "terraform apply"), `prompt` beats `deny`.
- Deny and prompt rules inspect the segments of compound commands; allow rules must match the whole command.
- The `eval` tool (Python/JS cells) can spawn shells at the exec tier. Under `yolo`, bash patterns do not gate it; use `tools.approval.eval` if that matters to you.

## Defaults worth knowing

| Key | Default | Why you would touch it |
|---|---|---|
| `tools.approvalMode` | `yolo` | the autonomy dial; decide it on purpose |
| `defaultThinkingLevel` | `high` | `auto` lets a classifier pick per turn; `ultrathink` escalates one turn |
| `task.maxConcurrency` | `32` | how many subagents run at once |
| `providers.maxInFlightRequests` | `{}` = **unlimited** | per-provider cap on concurrent LLM requests, shared across local omp processes. Unlimited + 32 subagents = 429 storms; cap your paid providers |
| `task.isolation.mode` | `none` | set `auto` before fanning out workers that write |
| `memory.backend` | `off` | `mnemopi` = local SQLite memory; nothing persists until you turn this on |
| `advisor.enabled` | `false` | second model reviewing every turn; needs `modelRoles.advisor` too |
| `secrets.enabled` | `false` | redacts credential-shaped tokens before text reaches providers; cheap defense, turn it on |
| `lsp.diagnosticsOnWrite` | `true` | the agent sees type errors as it writes |
| `lsp.formatOnWrite` | `false` | only enable in repos with deterministic formatting |
| `edit.mode` | `hashline` | content-hash anchored edits; rejected, never misapplied |
| `edit.enforceSeenLines` | `false` | reject edits to lines never displayed by a read; read-before-write discipline |
| `tools.intentTracing` | `true` | agent states intent before each call; observability, at a token cost |
| `tools.maxTimeout` | `0` = unlimited | a finite cap (600-900s) stops a subagent from requesting a 2h wait on a hung command |
| `tools.abortOnFabricatedResult` | `true` | stop the model the moment it hallucinates a tool result; keep it |
| `retry.fallbackChains` | `{}` | where to go on a 429, per role or `provider/*` |
| `retry.usageAwareFallback` | `false` | route around near-exhausted coding-plan accounts before they hard-fail |
| `includeWorkspaceTree` | `false` | keep it off: tree churn busts prompt caching every session |
| `temperature`, `topP`, ... | `-1` = provider default | do not tune sampling globally without a controlled eval |

## A sane starter config

Global (`~/.omp/agent/config.yml`), provider-agnostic. Adjust models to what you have.

```yaml
modelRoles:
  default: anthropic/claude-sonnet-5      # the daily driver
  smol: anthropic/claude-haiku-4-5        # fan-out, titles, cheap grunt work
  slow: anthropic/claude-opus-5:high      # the hard calls
  plan: anthropic/claude-opus-5

defaultThinkingLevel: auto

retry:
  fallbackChains:
    default: [openai/gpt-5.2]             # a 429 degrades instead of stopping you

providers:
  maxInFlightRequests:                    # cap every provider you pay for
    anthropic: 4
    openai: 4

task:
  isolation:
    mode: auto                            # parallel writers stop colliding
  maxConcurrency: 8                       # raise once you know your rate limits

secrets:
  enabled: true

tools:
  maxTimeout: 900

bash:
  patterns:
    - { match: "sudo *",            approval: deny }
    - { match: "rm -r*",            approval: deny }
    - { match: "rm -f*",            approval: deny }
    - { match: "git push --force*", approval: deny }
    - { match: "git push -f*",      approval: deny }
    - { match: "git reset --hard*", approval: deny }
    - { match: "git clean*",        approval: deny }
    - { match: "dd *",              approval: deny }
    - { match: "npm publish*",      approval: deny }
    - { match: "cargo publish*",    approval: deny }
    - { match: "terraform destroy*", approval: deny }
    - { match: "terraform apply*",  approval: prompt }
    - { match: "kubectl delete*",   approval: prompt }
```

Why these:

- **Fallback chain**: one entry turns a hard stop into a degrade.
- **`maxInFlightRequests`**: the single most-missed setting. The default is unlimited, `task.maxConcurrency` defaults to 32, and the caps are shared across all local omp processes. Without caps, one fan-out can burn a rate-limit window in minutes.
- **Isolation `auto`**: picks the fastest backend for your filesystem (CoW clones, overlayfs, worktree fallback). Without it, parallel writers clobber each other.
- **The deny list**: destructive, irreversible, or publishing. Everything else stays fast.

## Growing past the starter

When you want more, in rough order of payoff:

1. `memory.backend: mnemopi`, then `/memory stats` after a day. The agent opens tomorrow knowing your repo.
2. `advisor.enabled: true` plus `modelRoles.advisor`: a second model reviewing every turn. Real quality lift, real second bill; measure with `omp stats -s`.
3. `edit.enforceSeenLines: true`: read-before-write discipline, more tool calls, fewer blind edits.
4. `retry.usageAwareFallback: true` if you run multiple coding-plan accounts.
5. Per-project `.omp/config.yml` for repo-specific overrides (remember: cwd only, arrays replace).

The full key list with types and defaults lives in [`data/settings.json`](data/settings.json), and `omp config list --json` prints the same thing for your install, your values included.
