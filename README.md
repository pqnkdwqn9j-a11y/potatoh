# Burmalda.hook — GitHub + JNKIE deploy

Готовый пакет для репозитория **`pqnkdwqn9j-a11y/potatoh`**, ветка **`main`**. Поддерживаются rost alpha, Lone Survival и Trident Survival.

## 1. Загрузка в GitHub

Открой репозиторий → **Add file → Upload files** и загрузи **содержимое этой папки**, а не саму папку `github-ready`.

Обязательные файлы — эти три, строго в **корень `main`**, без переименования и без дополнительной подпапки:

| Игра | Файл в корне репозитория |
|---|---|
| rost alpha (`PlaceId 13769775130`) | `Potato.hook.min.lua` |
| Lone Survival | `LoneSurvival.burmalda.lua` |
| Trident Survival (`PlaceId 8130299583`) | `TridentSurvival.burmalda.lua` |

Папки `jnkie/`, `previews/`, `docs/`, `verification/` и этот README можно загрузить по желанию — runtime их не запрашивает.

**Важно:** если payloads окажутся, например, в `github-ready/Potato.hook.min.lua`, готовые raw-URL не совпадут. Файлы должны быть именно в корне ветки.

## 2. Настройка JNKIE

В JNKIE dashboard:

1. Открой `jnkie/Burmalda.hook.jnkie.lua`, скопируй всё содержимое и установи как **UI Source**.
2. Открой `jnkie/Burmalda.hook.original.lua`, скопируй всё содержимое и установи как **Original Code**.
3. Не вставляй большие payloads в Original Code. Правильный Original Code — короткий GitHub-loader размером **722 bytes**.
4. Создай/выдай приватные ключи в JNKIE dashboard. Общий `BETA` закрыт и отклоняется.

Схема запуска: пользователь выбирает игру → вводит свой ключ → JNKIE подтверждает доступ → Original Code загружает только payload выбранной игры.

## 3. Raw URL, уже записанные в Original Code

- rost alpha: https://raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/Potato.hook.min.lua
- Lone Survival: https://raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/LoneSurvival.burmalda.lua
- Trident Survival: https://raw.githubusercontent.com/pqnkdwqn9j-a11y/potatoh/refs/heads/main/TridentSurvival.burmalda.lua

После commit проверь, что каждый URL открывается и отдаёт новый файл. GitHub raw может некоторое время отдавать кэшированную ревизию.

## 4. Previews

- `previews/Burmalda.hook.ui-preview.html` — общий preview loader и всех трёх меню. Нажми **SKIP TO MENU**.
- `previews/Burmalda.hook.lone-preview.html` — расширенный Lone preview с ESP/FOV/resource mocks и hotkeys.

Это интерактивные HTML-демонстрации, не Roblox runtime и не доказательство live-совместимости.

## 5. Проверка целостности

Из корня распакованного пакета на Linux/macOS:

```bash
sha256sum -c SHA256SUMS.txt
```

На Windows можно сверить отдельный файл:

```powershell
certutil -hashfile Potato.hook.min.lua SHA256
```

Хэши должны совпасть с `SHA256SUMS.txt`. После загрузки в GitHub можно скачать raw-файлы и повторить сверку.

## Что специально не включено

- development direct builds с внутренним запуском;
- старые `old-full`, `burmalda-next`, beta/bypass-файлы;
- чужие UI/ESP libraries, analytics и reference payloads;
- исходники и test bridges — они находятся в отдельном **Source + Tests** архиве для приватной разработки.

## Статус проверок

- Rost/three-game, Lone и Trident offline suites: **PASS**.
- HTML custom dropdown DOM interactions: **PASS**.
- Финальные логи: `verification/`.
- Live Roblox, hit registration, executor compatibility, server-side JNKIE validation и отсутствие бана: **UNTESTED / не гарантируются**.
