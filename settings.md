<div class="settings-hero">

# Settings, demystified

This page answers four first questions: where a value comes from, which approval mode to choose, what to put in a first config, and what to add later. *Verified against the release in [`data/version.txt`](https://github.com/HugoLopes45/omp-guide/blob/main/data/version.txt).*

<dl class="settings-stats">
  <div><dt>480+</dt><dd>settings</dd></div>
  <div><dt>5</dt><dd>resolution layers</dd></div>
  <div><dt>3</dt><dd>first decisions</dd></div>
</dl>

</div>

<nav class="settings-path" aria-label="Settings onboarding">
  <a href="#1-where-does-a-value-come-from">Where values come from</a>
  <a href="#2-which-approval-mode-should-i-choose">Choose an approval mode</a>
  <a href="#3-what-belongs-in-my-first-config">Copy a small baseline</a>
  <a href="#4-what-should-i-add-later">Add power when needed</a>
</nav>

## 1. Where does a value come from?

Values resolve from lowest to highest priority:

<ol class="resolution-ladder">
  <li><strong>Schema default</strong></li>
  <li><strong>Global config</strong>, <code>~/.omp/agent/config.yml</code></li>
  <li><strong>Project config</strong>, <code>&lt;cwd&gt;/.omp/config.yml</code></li>
  <li><strong>Ordered <code>--config</code> overlays</strong>, including <code>PI_CONFIG_FILES</code></li>
  <li><strong>CLI and runtime overrides</strong></li>
</ol>

Three facts people learn the hard way:

1. **Project settings do not walk up ancestors.** Context files (`AGENTS.md`, `RULES.md`, and standalone `CLAUDE.md`) do. A `.omp/config.yml` in a parent directory of where you launched is silently ignored.
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

## 2. Which approval mode should I choose?

Fresh installs default to `yolo`. Start with `write`: read and workspace-write tools stay automatic, while exec-tier actions still require approval.

<div class="approval-options">
  <section>
    <h3><code>always-ask</code></h3>
    <p>Approve each tool action yourself.</p>
  </section>
  <section>
    <h3><code>write</code> recommended</h3>
    <p>Keep reads and workspace writes automatic. Approve exec-tier actions.</p>
  </section>
  <section>
    <h3><code>yolo</code></h3>
    <p>Auto-approve reads, writes, and shell commands.</p>
  </section>
</div>

The mode is the baseline. `tools.approval` overrides it per tool, and the first matching `bash.patterns` rule overrides the bash policy:

```yaml
tools:
  approvalMode: write
  approval:
    bash: prompt
bash:
  patterns:
    - { match: "git status*", approval: allow }
    - { match: "rm -r*", approval: deny }
```

Under `yolo`, only `deny` and `prompt` rules change bash behavior. `deny` blocks, `prompt` asks, and allow rules must match the full command while deny and prompt inspect compound-command segments. **`eval` needs its own approval policy:** Python and JavaScript cells can spawn exec-tier shells, so use `tools.approval.eval` when that boundary matters.

## 3. What belongs in my first config?

| Key | Shipped default | Start here because |
|---|---|---|
| `tools.approvalMode` | `yolo` | `write` keeps routine reads and workspace writes fast while asking before exec-tier actions. |
| `defaultThinkingLevel` | `high` | `auto` chooses a level per turn instead of fixing every task at `high`. |
| `secrets.enabled` | `false` | `true` redacts credential-shaped tokens before they reach providers. |

```yaml
defaultThinkingLevel: auto
secrets:
  enabled: true
tools:
  approvalMode: write
```

## 4. What should I add later?

<div class="later-grid">
  <section>
    <h3>Cross-session recall</h3>
    <p><code>memory.backend</code> ships <code>off</code>. Enable it when you want recall across sessions. Read <a href="tips.md#memory-is-off-until-you-flip-it">memory tips</a> first.</p>
  </section>
  <section>
    <h3>Parallel writers</h3>
    <p><code>task.isolation.enabled</code> ships <code>false</code>. Set it to <code>true</code> before parallel agents edit. <code>isolation.backend</code> ships <code>auto</code> and selects the available backend. Read <a href="multi-agent.md#before-anything-isolation">isolation guidance</a>.</p>
  </section>
  <section>
    <h3>Rate-limit control</h3>
    <p><code>task.maxConcurrency</code> ships <code>32</code>; <code>providers.maxInFlightRequests</code> is unlimited. Cap both before broad fan-out. Read <a href="traps.md#autonomy-traps">autonomy traps</a>.</p>
  </section>
  <section>
    <h3>Provider fallback</h3>
    <p><code>retry.fallbackChains</code> ships empty. Add it after choosing a real backup provider.</p>
  </section>
</div>

## Full reference

The full key catalog stays sourced from [`data/settings.json`](https://github.com/HugoLopes45/omp-guide/blob/main/data/settings.json). Search the list below for your install's shipped defaults, or run `omp config list --json` for your effective values.

<div class="settings-reference" data-settings-reference data-settings-count="{{ site.data.settings.size }}">
  <label for="settings-search">Search settings</label>
  <input id="settings-search" type="search" placeholder="approvalMode, memory, concurrency..." autocomplete="off">
  <p class="settings-reference-count" role="status" aria-live="polite" data-settings-reference-count></p>
  <details>
    <summary>Browse all {{ site.data.settings.size }} settings</summary>
    <div class="settings-reference-scroll">
      <table>
        <thead>
          <tr><th scope="col">Key</th><th scope="col">Shipped default</th><th scope="col">Description</th></tr>
        </thead>
        <tbody>
          {% assign settings = site.data.settings | sort %}
          {% for setting in settings %}
          <tr data-settings-reference-row>
            <th scope="row"><code>{{ setting[0] | escape }}</code></th>
            <td data-label="Shipped default">{% if setting[1].value == nil %}<span class="settings-reference-none">No shipped default</span>{% elsif setting[1].type == "string" or setting[1].type == "enum" %}<code>{{ setting[1].value | escape }}</code>{% else %}<code>{{ setting[1].value | jsonify | escape }}</code>{% endif %}</td>
            <td data-label="Description">{{ setting[1].description | default: "No description provided." | escape }}</td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    </div>
  </details>
</div>

<script>
(() => {
  const reference = document.querySelector("[data-settings-reference]");
  const input = reference.querySelector("input");
  const details = reference.querySelector("details");
  const rows = Array.from(reference.querySelectorAll("[data-settings-reference-row]"));
  const total = Number(reference.dataset.settingsCount);
  const count = reference.querySelector("[data-settings-reference-count]");

  const filterRows = () => {
    const query = input.value.trim().toLowerCase();
    let matches = 0;

    for (const row of rows) {
      const matchesQuery = row.textContent.toLowerCase().includes(query);
      row.hidden = !matchesQuery;
      matches += Number(matchesQuery);
    }

    count.textContent = query
      ? `${matches} settings match "${input.value.trim()}".`
      : `${total} settings available.`;
    if (query) details.open = true;
  };

  input.addEventListener("input", filterRows);
  filterRows();
})();
</script>
