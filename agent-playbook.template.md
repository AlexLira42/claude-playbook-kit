# Agent Playbook

Reusable execution patterns from past Claude Code sessions.
Each card = one symptom class + its proven fix. The `playbook-lookup.sh` hook
matches cards to your prompt by keywords in the title, `Tags:`, and `Problem:` lines,
so write those richly.

Card format (the hook keys off `## C<N> — <title>` and `Tags:` / `- Problem:` / `- Fix:`):

## C1 — Short symptom-based title here
Tags: `keyword1` `keyword2` `tool-name` `domain`

- Problem: What went wrong / what the user asked. Be specific about the symptom.
- Root cause: Why it happened (the real underlying reason).
- Fix: The proven steps that resolved it.
- Verify: How you confirmed it worked.
- Anti-pattern: What NOT to do (mistakes to avoid next time).
- Prompt template: A reusable prompt phrasing for this class of task.
- Session refs: [short-label](session-uuid)

---

<!-- Add new cards below as C2, C3, ... -->
