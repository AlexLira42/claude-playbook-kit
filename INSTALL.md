# Playbook Engine — установка (Claude Code)

Самообучающийся «playbook»: до задачи Claude видит релевантные карточки прошлого опыта,
после задачи сессия логируется в очередь на добавление новой карточки.

## Что в комплекте
- `scripts/playbook-lookup.sh` — хук `UserPromptSubmit`: ищет карточки по ключевым словам промпта.
- `scripts/log-session-for-playbook.sh` — хук `Stop`: пишет завершённую сессию в очередь.
- `rules/agent-session-ritual.md` — правило поведения для Claude (ритуал до/после задачи).
- `agent-playbook.template.md` — пустой шаблон твоего личного playbook (карточки наполняешь сам).

## Установка (4 шага)

### 1. Скопировать файлы
```bash
mkdir -p ~/.claude/scripts ~/.claude/rules
cp scripts/playbook-lookup.sh ~/.claude/scripts/
cp scripts/log-session-for-playbook.sh ~/.claude/scripts/
chmod +x ~/.claude/scripts/playbook-lookup.sh ~/.claude/scripts/log-session-for-playbook.sh
cp rules/agent-session-ritual.md ~/.claude/rules/
cp agent-playbook.template.md ~/.claude/agent-playbook.md   # это твой рабочий playbook
```

### 2. Указать путь к playbook
Скрипт `playbook-lookup.sh` читает путь из переменной `CLAUDE_PLAYBOOK`
(по умолчанию `~/.claude/agent-playbook.md`). Если положил в другое место —
добавь в `~/.zshrc` или `~/.bashrc`:
```bash
export CLAUDE_PLAYBOOK="/полный/путь/к/agent-playbook.md"
```
И в `~/.claude/rules/agent-session-ritual.md` заменить `<PLAYBOOK_PATH>` на тот же путь.

### 3. Прописать хуки в settings.json
Добавить блок `hooks` в `~/.claude/settings.json` (слить с существующим, если он есть):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      { "matcher": "", "hooks": [
        { "type": "command", "command": "bash ~/.claude/scripts/playbook-lookup.sh" }
      ]}
    ],
    "Stop": [
      { "matcher": "", "hooks": [
        { "type": "command", "command": "bash ~/.claude/scripts/log-session-for-playbook.sh" }
      ]}
    ]
  }
}
```

### 4. Перезапустить Claude Code
Хуки подхватываются при старте сессии.

## Проверка
```bash
# lookup-хук: должен молча выйти, если playbook пуст/нет совпадений
echo '{"prompt":"тест"}' | bash ~/.claude/scripts/playbook-lookup.sh
# log-хук: создаст очередь при первой реальной сессии
ls ~/.claude/pending-playbook-updates.md
```

## Как этим пользоваться
1. Работаешь как обычно. Перед ответом Claude видит до 3 релевантных карточек (если найдены).
2. После каждой нетривиальной задачи сессия падает в `~/.claude/pending-playbook-updates.md`.
3. Периодически разбираешь очередь: новую находку → новая карточка `C<N>` в `agent-playbook.md`;
   повтор известного паттерна → дописать `Session refs` в существующую карточку.
4. Чем богаче `Tags:` и `Problem:` в карточке — тем точнее срабатывает поиск.

## Замечания
- Свой `agent-playbook.md` с реальными карточками НЕ передавай — там могут быть внутренние детали.
  Делись только этим kit'ом (механизм) + пустым шаблоном.
- Скрипты на чистом Python3 stdlib + bash, без зависимостей.
