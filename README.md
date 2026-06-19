# Claude Playbook Kit

A self-improving "playbook" for [Claude Code](https://claude.com/claude-code).

- **Before a task**, Claude is shown the most relevant cards from your past experience.
- **After a task**, the session is logged to a review queue so you can grow the playbook over time.

The mechanism is two small hooks + one behavior rule + a playbook file you fill with your own cards.

> 🇷🇺 Версия на русском: [README.ru.md](README.ru.md)

## How it works

1. **`UserPromptSubmit` hook** (`scripts/playbook-lookup.sh`) — on every prompt, scans your playbook and injects up to 3 matching cards as context. Matching is keyword-based against each card's title, `Tags:`, and `Problem:` lines.
2. **`Stop` hook** (`scripts/log-session-for-playbook.sh`) — when a session ends, appends it to `~/.claude/pending-playbook-updates.md` (a review queue).
3. **Behavior rule** (`rules/agent-session-ritual.md`) — tells Claude to consult cards before a task and log the session after.
4. **Your playbook** (`agent-playbook.template.md` → `~/.claude/agent-playbook.md`) — where you write reusable cards: `Problem → Root cause → Fix → Verify → Anti-pattern → Prompt template → Session refs`.

No dependencies beyond `bash` and Python 3 stdlib.

> **Hooks vs rule — they load differently.** The two `scripts/*.sh` are *hooks* (code) that Claude Code runs on `UserPromptSubmit` / `Stop` events, wired via `settings.json`. The `rules/agent-session-ritual.md` is a *rule* (text) that Claude Code **auto-loads into context** from `~/.claude/rules/*.md` at session start — no `CLAUDE.md` needed, nothing to "run". Just drop the file in `~/.claude/rules/` and restart.

## Install

See [INSTALL.md](INSTALL.md) (4 steps, in Russian). In short:

```bash
mkdir -p ~/.claude/scripts ~/.claude/rules
cp scripts/*.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh
cp rules/agent-session-ritual.md ~/.claude/rules/
cp agent-playbook.template.md ~/.claude/agent-playbook.md
```

Then register the hooks in `~/.claude/settings.json`, set `CLAUDE_PLAYBOOK` (optional), replace `<PLAYBOOK_PATH>` in the rule, and restart Claude Code.

## Card format

```markdown
## C1 — Short symptom-based title
Tags: `keyword1` `keyword2` `tool-name` `domain`

- Problem: What went wrong / what the user asked.
- Root cause: Why it happened.
- Fix: The proven steps that resolved it.
- Verify: How you confirmed it worked.
- Anti-pattern: What NOT to do.
- Prompt template: A reusable prompt phrasing.
- Session refs: [short-label](session-uuid)
```

Richer `Tags:` and `Problem:` lines = better matches.

## Privacy

Share **this kit (the mechanism) + the empty template** — not your own filled `agent-playbook.md`, which may contain internal details.

## License

[MIT](LICENSE)
