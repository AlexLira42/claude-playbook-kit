# Авто-установка через Claude Code

Скопируй промпт ниже и вставь в Claude Code. Агент изучит репозиторий и установит kit за тебя.

> ⚠️ Перед запуском убедись, что у Claude Code есть доступ в интернет (для чтения репо).
> Если доступа нет — скачай репозиторий как ZIP и попроси установить из локальной папки.

---

## Промпт (копировать целиком)

```
Установи мне "Claude Playbook Kit" из репозитория
https://github.com/AlexLira42/claude-playbook-kit

Действуй строго по INSTALL.md, но с такими правилами безопасности:

1. Сначала прочитай README.md и INSTALL.md из репо, перескажи мне в 3-4
   строках что будешь делать, и только потом приступай.

2. Скопируй файлы:
   - scripts/playbook-lookup.sh и scripts/log-session-for-playbook.sh
     -> ~/.claude/scripts/ (chmod +x на оба)
   - rules/agent-session-ritual.md -> ~/.claude/rules/
   - agent-playbook.template.md -> ~/.claude/agent-playbook.md
     (НЕ перезаписывай, если ~/.claude/agent-playbook.md уже существует —
      спроси меня)

3. В ~/.claude/rules/agent-session-ritual.md замени плейсхолдер
   <PLAYBOOK_PATH> на абсолютный путь ~/.claude/agent-playbook.md.

4. Хуки в ~/.claude/settings.json:
   - ВАЖНО: settings.json у меня может быть НЕ пустой. НЕ перезатирай файл.
     Прочитай текущий, аккуратно СЛЕЙ блок hooks (UserPromptSubmit + Stop),
     сохрани все мои существующие настройки. Покажи мне diff перед записью.
   - Блок hooks возьми из INSTALL.md (шаг 3).

5. Проверь установку командами из раздела "Проверка" в INSTALL.md
   и покажи результат.

6. В конце НАПОМНИ мне, что нужно вручную перезапустить Claude Code —
   сам ты этого сделать не можешь.

Не трогай мой заполненный playbook и не выкладывай его никуда.
```

---

## Что останется сделать руками

- **Перезапустить Claude Code** — агент сам себя перезапустить не может.
- (опционально) если кладёшь playbook не в дефолтный путь — добавить
  `export CLAUDE_PLAYBOOK="/полный/путь/agent-playbook.md"` в `~/.zshrc` / `~/.bashrc`.
