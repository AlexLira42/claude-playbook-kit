#!/usr/bin/env bash
# Logs completed Claude Code session to pending-playbook-updates.md
# Runs via Stop hook in settings.json
# Hook passes JSON via stdin: {"session_id": "...", "transcript_path": "...", ...}

QUEUE="$HOME/.claude/pending-playbook-updates.md"
TIMESTAMP=$(date "+%Y-%m-%d %H:%M")

# Read session_id and transcript_path from stdin JSON
HOOK_INPUT=$(cat)
SESSION_ID=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('session_id','unknown'))" 2>/dev/null || echo "unknown")
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('transcript_path',''))" 2>/dev/null || echo "")

# Find session JSONL (prefer transcript_path, fallback to search)
SESSION_FILE=""
if [ -n "$TRANSCRIPT_PATH" ] && [ -f "$TRANSCRIPT_PATH" ]; then
  SESSION_FILE="$TRANSCRIPT_PATH"
elif [ "$SESSION_ID" != "unknown" ]; then
  SESSION_FILE=$(find "$HOME/.claude/projects" -name "${SESSION_ID}.jsonl" 2>/dev/null | head -1)
fi

# Extract first meaningful user message (skip skill prompts, system reminders, hook output)
FIRST_MSG=""
if [ -n "$SESSION_FILE" ]; then
  FIRST_MSG=$(SESSION_FILE="$SESSION_FILE" python3 -c "
import sys, json, re, os
SKIP_PATTERNS = [
    r'^Base directory for this skill',
    r'^ARGUMENTS:',
    r'SKILL\.md',
    r'hook success',
]
skip_re = re.compile('|'.join(SKIP_PATTERNS), re.IGNORECASE)

def clean(t):
    t = re.sub(r'<[^>]+>.*?</[^>]+>', '', t, flags=re.DOTALL)
    t = re.sub(r'<[^>]+/?>', '', t)
    t = t.strip()
    if skip_re.search(t):
        return ''
    return t[:150]

for line in open(os.environ['SESSION_FILE']):
    try:
        d = json.loads(line)
        if d.get('type') == 'user':
            for m in d.get('message',{}).get('content',[]):
                if isinstance(m, dict) and m.get('type') == 'text':
                    t = clean(m['text'])
                    if len(t) > 10:
                        print(t)
                        sys.exit()
    except: pass
" 2>/dev/null)
fi

# Skip logging if no meaningful message found
if [ -z "$FIRST_MSG" ]; then
  exit 0
fi

# Initialize queue file if missing
if [ ! -f "$QUEUE" ]; then
  echo "# Pending Playbook Updates" > "$QUEUE"
  echo "" >> "$QUEUE"
  echo "Sessions logged here need to be reviewed and added to agent-playbook.md" >> "$QUEUE"
  echo "" >> "$QUEUE"
fi

# Append entry
echo "- [$TIMESTAMP] \`$SESSION_ID\` — $FIRST_MSG" >> "$QUEUE"
