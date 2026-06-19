# Claude Playbook Kit

Самообучающийся «playbook» для [Claude Code](https://claude.com/claude-code).

- **До задачи** Claude видит самые релевантные карточки из твоего прошлого опыта.
- **После задачи** сессия логируется в очередь на разбор, чтобы playbook со временем рос.

Механизм — это два небольших хука + одно правило поведения + файл playbook, который ты наполняешь своими карточками.

> 🇬🇧 English version: [README.md](README.md)

## Как это работает

1. **Хук `UserPromptSubmit`** (`scripts/playbook-lookup.sh`) — на каждый промпт сканирует playbook и подставляет до 3 подходящих карточек как контекст. Поиск по ключевым словам в заголовке карточки, строках `Tags:` и `Problem:`.
2. **Хук `Stop`** (`scripts/log-session-for-playbook.sh`) — по завершении сессии дописывает её в `~/.claude/pending-playbook-updates.md` (очередь на разбор).
3. **Правило поведения** (`rules/agent-session-ritual.md`) — говорит Claude сверяться с карточками до задачи и логировать сессию после.
4. **Твой playbook** (`agent-playbook.template.md` → `~/.claude/agent-playbook.md`) — где ты пишешь переиспользуемые карточки: `Problem → Root cause → Fix → Verify → Anti-pattern → Prompt template → Session refs`.

Без зависимостей, кроме `bash` и стандартной библиотеки Python 3.

> **Хуки и правило подключаются по-разному.** Два `scripts/*.sh` — это *хуки* (код), их запускает Claude Code на событиях `UserPromptSubmit` / `Stop` по записи в `settings.json`. А `rules/agent-session-ritual.md` — это *правило* (текст), Claude Code **автозагружает его в контекст** из `~/.claude/rules/*.md` при старте сессии — `CLAUDE.md` не нужен, «запускать» нечего. Просто положи файл в `~/.claude/rules/` и перезапусти.

## Установка

Подробно — в [INSTALL.md](INSTALL.md) (4 шага). Кратко:

```bash
mkdir -p ~/.claude/scripts ~/.claude/rules
cp scripts/*.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/*.sh
cp rules/agent-session-ritual.md ~/.claude/rules/
cp agent-playbook.template.md ~/.claude/agent-playbook.md
```

Затем пропиши хуки в `~/.claude/settings.json`, задай `CLAUDE_PLAYBOOK` (опционально), замени `<PLAYBOOK_PATH>` в правиле и перезапусти Claude Code.

## Формат карточки

```markdown
## C1 — Короткий заголовок по симптому
Tags: `keyword1` `keyword2` `tool-name` `domain`

- Problem: Что пошло не так / что просил пользователь.
- Root cause: Почему это произошло.
- Fix: Проверенные шаги, которые решили проблему.
- Verify: Как ты убедился, что работает.
- Anti-pattern: Чего НЕ делать.
- Prompt template: Переиспользуемая формулировка промпта.
- Session refs: [короткая-метка](session-uuid)
```

Чем богаче `Tags:` и `Problem:` — тем точнее срабатывает поиск.

## Приватность

Делись **этим kit'ом (механизмом) + пустым шаблоном** — но НЕ своим заполненным `agent-playbook.md`, в нём могут быть внутренние детали.

## Лицензия

[MIT](LICENSE)
