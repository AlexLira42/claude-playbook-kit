#!/usr/bin/env bash
# UserPromptSubmit hook: searches agent-playbook.md for relevant cards
# and injects matching context before Claude responds.
# Hook passes JSON via stdin: {"session_id":"...","prompt":"user message","transcript_path":"..."}
#
# CONFIG: set CLAUDE_PLAYBOOK to your playbook path (export it in your shell profile),
# or edit the default below.
PLAYBOOK="${CLAUDE_PLAYBOOK:-$HOME/.claude/agent-playbook.md}"

[ ! -f "$PLAYBOOK" ] && exit 0

# Read prompt from stdin JSON
HOOK_INPUT=$(cat)
PROMPT=$(echo "$HOOK_INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
print(d.get('prompt', ''))
" 2>/dev/null || echo "")

[ -z "$PROMPT" ] && exit 0

# Match cards by keywords from prompt against tags + problem lines
MATCHES=$(PROMPT="$PROMPT" PLAYBOOK="$PLAYBOOK" python3 -c "
import re, os

prompt = os.environ.get('PROMPT','').lower()
playbook_path = os.environ.get('PLAYBOOK','')

# Keywords to ignore (too generic)
STOPWORDS = {'и', 'в', 'на', 'по', 'с', 'не', 'что', 'как', 'для', 'это', 'из', 'к', 'или', 'за', 'от', 'при', 'до', 'то', 'же', 'но', 'а', 'the', 'is', 'to', 'in', 'and', 'of', 'for', 'that', 'are', 'with'}

words = set(w for w in re.findall(r'[а-яёa-z0-9]{3,}', prompt) if w not in STOPWORDS)

cards = []
current_card = None
current_lines = []

with open(playbook_path) as f:
    for line in f:
        m = re.match(r'^## (C\d+) — (.+)', line)
        if m:
            if current_card:
                cards.append((current_card[0], current_card[1], '\n'.join(current_lines)))
            current_card = (m.group(1), m.group(2))
            current_lines = [line.strip()]
        elif current_card:
            current_lines.append(line.strip())
    if current_card:
        cards.append((current_card[0], current_card[1], '\n'.join(current_lines)))

results = []
for card_id, card_title, card_body in cards:
    score = 0
    body_lower = card_body.lower()
    for word in words:
        if word in body_lower:
            score += 1
    if score >= 2:
        tags_m = re.search(r'Tags: (.+)', card_body)
        prob_m = re.search(r'- Problem: (.+)', card_body)
        fix_m = re.search(r'- Fix: (.+)', card_body)
        tags = tags_m.group(1) if tags_m else ''
        prob = prob_m.group(1)[:100] if prob_m else ''
        fix = fix_m.group(1)[:100] if fix_m else ''
        results.append((score, card_id, card_title, tags, prob, fix))

results.sort(reverse=True)
for score, card_id, title, tags, prob, fix in results[:3]:
    print(f'  {card_id} — {title} {tags}')
    if prob: print(f'    Problem: {prob}')
    if fix: print(f'    Fix: {fix}')
" 2>/dev/null)

if [ -n "$MATCHES" ]; then
  echo "=== Playbook: relevant cards ==="
  echo "$MATCHES"
  echo "================================"
fi

exit 0
