# Burmalda.hook — рабочая область

Дата наведения порядка: **2026-10-25**.

## Что открывать

Активная новая разработка — **Burmalda Next** с собственным меню в стиле Vanish:

- **Запускаемый single-file:** `releases/burmalda-next/Burmalda.hook.lua`
- **Original Code:** `releases/burmalda-next/Burmalda.hook.original.lua`
- **Source:** `src/burmalda-next/`
- **Build:** `python3 src/burmalda-next/build.py`
- **Regression:** `python3 tests/burmalda-next/run.py`
- **Live diagnostic:** Settings → Repair + arm → один local shot; report сохраняется как `BurmaldaNext/diagnostics/00_OPEN_ME_latest.txt` в workspace Opiumware.
- **Функции, diagnostics и live-check:** [docs/BURMALDA_NEXT.md](docs/BURMALDA_NEXT.md)

Compile O0/O2 и три runtime mock-режима проходят. Это подтверждает кодовые пути и cleanup, но **не заменяет живой Silent test в rost alpha**.

Прежний **old-full** сохранён отдельно в `releases/old-full/`; earliest first release находится в `releases/old-full/first/`. Gun-only/F-menu, который пользователь отклонил как «новый чит», находится только в `archive/gun-only/` и не является активным релизом.

## Отдельная Vanish-линия

- **Точный rollback приложенного source:** `releases/vanish/Vanish.first.original.lua`
- **Отклонённая optimized-альтернатива:** `releases/vanish/Vanish.optimized.lua`
- **Оптимизации и ограничения:** `docs/VANISH.md`

Optimized Vanish не является основой Burmalda Next: пользователь отклонил её Silent. В новом проекте используется собственный projectile/stack/packet path, а не только target selector/FOV.

## Документация

- [Burmalda Next: release, модули и diagnostics](docs/BURMALDA_NEXT.md)
- [Разбор живых Silent reports](docs/LIVE_DIAGNOSTICS.md)
- [Как устроены функции](docs/FUNCTIONS.md)
- [Burmalda Next: детальный function deep-dive](docs/BURMALDA_FUNCTION_DEEP_DIVE.md)
- [Historical Rost schema: decoded Viewmodel/VFX, caller/stack/packet/ToolInfo](docs/BURMALDA_HISTORICAL_SCHEMA_ADDENDUM.md)
- [Vanish: оптимизация и статус функций](docs/VANISH.md)
- [Silent Aim: pipeline и диагностика](docs/SILENT_AIM.md)
- [Каталог всех literal UI flags](docs/FLAGS.md)
- [Runtime references без UI-регистрации](docs/RUNTIME_ONLY_FLAGS.md)
- [Сборка и тестирование](docs/BUILD_AND_TEST.md)
- [Роль исходников и attachments](docs/SOURCES.md)
- [Структура workspace](docs/WORKSPACE.md)
- [Manifest перемещения файлов](docs/WORKSPACE_MANIFEST.tsv)
- [Отчёт об уборке и проверках](docs/CLEANUP_REPORT.md)
- [Журнал изменений](docs/CHANGELOG.md)

## Структура

```text
/home/user/
├── README.md
├── releases/
│   ├── burmalda-next/      # новый модульный Burmalda Next
│   ├── old-full/           # сохранённый Burmalda old-full
│   └── vanish/             # отдельные Vanish releases
├── src/
│   ├── burmalda-next/      # canonical Next modules + сборка
│   ├── old-full/           # canonical Burmalda source + сборка
│   ├── vanish/             # canonical Vanish source + сборка
│   └── reference/          # Potato, JNKIE и исходники только для чтения/сравнения
├── tests/
│   ├── burmalda-next/      # Next integration/hookfunction/degraded regression
│   ├── old-full/           # тесты сохранённой Burmalda-версии
│   ├── vanish/             # Vanish UI/static/core regression
│   ├── gun-only/           # регрессии архивной версии
│   ├── legacy/             # старые harness-файлы
│   └── support/            # вспомогательные mocks
├── tools/
│   ├── luau/               # luau, luau-compile и остальные бинарники
│   └── generate_flag_docs.py
├── docs/                   # документация и машинный flag catalog
├── assets/logos/           # загруженные для идентификации логотипы
├── archive/                # отклонённые/исторические версии, compile output, research
└── uploads/                # пользовательские attachments, не изменялись
```

## Основные команды

```bash
cd /home/user
export PYTHONDONTWRITEBYTECODE=1
python3 src/burmalda-next/build.py
python3 tests/burmalda-next/run.py

python3 src/old-full/build.py
python3 tools/generate_flag_docs.py

chmod +x tools/luau/luau tools/luau/luau-compile
tools/luau/luau-compile -O2 releases/old-full/Burmalda.hook.old.lua
for test in tests/old-full/test_*.lua; do
    tools/luau/luau -O2 "$test"
done
```

## Правила дальнейшей работы

1. Не создавать новые рабочие файлы в корне.
2. Активный код каждой линии менять через `src/burmalda-next/`, `src/old-full/` или `src/vanish/`; затем запускать соответствующие build и тесты.
3. Не смешивать active source с `src/reference/` или `archive/`.
4. **Force Hit и MouseRaycast не возвращать.**
5. Не считать compile/mock подтверждением живого Silent.
6. После перемещений обновлять документацию и `docs/WORKSPACE_MANIFEST.tsv`.
