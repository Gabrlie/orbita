# Rules and Conventions

> Status: active | Max lines: 200

All AI agents and developers MUST follow these rules.

## Document Format Standard

Every `.ai/` markdown file MUST:
- Start with `# Title` and a `> Status: draft|active|final | Max lines: N` blockquote
- Use `##` for sections, `###` for subsections (no deeper)
- Use `-` bullet lists, not numbered lists for specs (numbered only for sequential steps)
- Keep code blocks under 30 lines each
- Include `## Changelog` as the last section (most recent first, max 5 entries)
- NEVER exceed the max line limit declared in the file header

File naming: `kebab-case.md`, all lowercase.

## Document Sync Rule

When code changes affect any design decision, the developer MUST:
1. Update the relevant `.ai/` doc in the SAME commit
2. Add a changelog entry to the doc
3. If the change conflicts with existing spec, update the spec first, then code

## Git Commit Format

```
type(scope): english title under 72 chars

English summary sentence ending with colon:
- English bullet describing one concrete change
- English bullet describing another concrete change

中文概述句，以中文冒号结尾：
- 中文无序列表说明一个具体改动
- 中文无序列表说明另一个具体改动
```

**Rules**:
- Title: lowercase, imperative mood, no period
- Types: `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `build`
- Scopes: `ssh`, `sftp`, `terminal`, `docker`, `scripts`, `crypto`, `webdav`, `ui`, `core`, `sync`, `net`, `update`, `i18n`, `snippets`
- Body MUST use an English summary + English unordered list, then a Chinese summary + Chinese unordered list
- Do NOT add language labels such as `English:`, `中文说明：`, or `中文正文：`
- Body: MUST use real line breaks (heredoc), NEVER `\n` escape sequences
- Each logical change = one commit (no mega-commits)

## Versioning and Release

- App version MUST use `MAJOR.MINOR.PATCH+BUILD`
- GitHub release tags MUST use `vMAJOR.MINOR.PATCH`
- Android `BUILD` maps to `versionCode` and MUST increase every release
- Release APK assets MUST use `orbita-{version}-android-{abi}.apk`
- Each APK asset MUST have a matching `.sha256` file

## Code Style

- Follow official Dart style guide and `flutter_lints`
- File naming: `snake_case.dart`
- Class naming: `PascalCase`
- Max file length: 300 lines (split if larger)
- One widget per file for page-level widgets
- Prefer composition over inheritance
- All user-facing strings MUST use `l10n` — NEVER hardcoded text
- Default locale: `zh` (Chinese), supported: `en` (English)
- No hardcoded colors — use `Theme.of(context).colorScheme`
- No hardcoded dimensions for layout — use `MediaQuery` or `LayoutBuilder`

## Architecture Rules

- Follow feature-first directory structure (see [architecture/directory.md](architecture/directory.md))
- State management: Riverpod only, no mixing with other solutions
- All SSH operations go through `SshService`, never call dartssh2 directly from UI
- All crypto operations go through `EncryptionService`
- Models are immutable (use `freezed` or manual `copyWith`)
- Repository pattern for data access

## Changelog
- 2026-05-06: Add release versioning and APK asset naming rules
- 2026-04-19: Clarify bilingual commit body format with unordered lists
- 2026-04-15: Add i18n rules, default locale zh, add new scopes
- 2026-04-15: Initial creation
