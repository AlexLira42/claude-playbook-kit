# Agent Session Ritual

## Purpose

Turn past agent sessions into reusable execution patterns.

> CONFIG: replace `<PLAYBOOK_PATH>` below with the absolute path to your own
> `agent-playbook.md` (the same value you set in `CLAUDE_PLAYBOOK`).

## Before Task

1. Open `<PLAYBOOK_PATH>`.
2. Find 2-3 closest cards by symptom (not by project name).
3. Reuse from cards:
   - checks to run first
   - proven fix steps
   - verification criteria
4. Tell the user which cards were used.

## During Task

1. Keep notes in this structure:
   - problem
   - root cause
   - fix
   - verify
2. If a known card fits, follow it first; only then try a new path.

## After Task (MANDATORY)

After completing any non-trivial task, append the session to the pending queue so the playbook stays current:

```bash
~/.claude/scripts/log-session-for-playbook.sh
```

Then, if the task matches an existing card — add the session UUID to that card's `Session refs`.
If it's a genuinely new pattern — create a new card in the playbook (C-next).

Rules for new cards:
- Problem
- Root cause
- Fix
- Verify
- Anti-pattern
- Prompt template
- Session refs

## Merge Rule For Similar Sessions

- Merge sessions into one card when: same symptom class + same root cause + same fix
- Split into separate cards when one of those changes.

## Skip Conditions

Skip the ritual for trivial one-step tasks (current time, single command, simple lookup).
