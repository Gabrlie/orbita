# Project Directory Structure

> Status: active | Max lines: 140

## Flutter Source Tree

```
lib/
├── main.dart                      # Entry, SharedPreferences init, ProviderScope
├── app/
│   ├── app.dart                   # MaterialApp (theme, router, i18n, DynamicColor)
│   ├── router.dart                # go_router: ShellRoute + branches
│   └── theme.dart                 # MD3 theme builders (seed, light/dark)
├── l10n/
│   ├── app_zh.arb                 # Chinese (source of truth)
│   ├── app_en.arb                 # English
│   ├── app_localizations.dart     # Generated (do not edit)
│   ├── app_localizations_zh.dart  # Generated
│   └── app_localizations_en.dart  # Generated
├── models/
│   ├── app_theme_seed.dart        # Popular app theme seed colors
│   ├── command_snippet.dart       # User command snippet model
│   ├── docker_models.dart         # Docker availability, snapshot, and resources
│   ├── file_download_task.dart    # Persistent file download task model
│   ├── remote_file_entry.dart     # SFTP metadata + path/type helpers
│   ├── remote_script.dart         # Built-in remote script metadata
│   └── server_group.dart          # Flat group metadata + display buckets
├── providers/
│   ├── command_snippet_provider.dart # Snippet CRUD and search
│   ├── settings_provider.dart     # ThemeMode, dynamic color, metric settings
│   ├── server_group_provider.dart # Group persistence and list bucketing
│   ├── server_monitor_provider.dart # SSH status polling via pooled connections
│   ├── ssh_connection_provider.dart # Global SSH connection manager provider
│   ├── docker_provider.dart       # Docker service + snapshot refresh providers
│   ├── file_download_provider.dart  # Persistent SFTP download queue
│   ├── navigation_reset_provider.dart # Top-level branch reset epochs
│   ├── remote_script_provider.dart # Remote script execution provider
│   ├── sftp_file_provider.dart    # SFTP file service provider
│   ├── terminal_connection_preference_provider.dart # Last direct/tmux mode
│   └── terminal_metric_history_provider.dart # Terminal dashboard history
├── services/
│   ├── ssh_service.dart           # SSHClient wrapper + shell/SFTP adapters
│   ├── ssh_connection_manager.dart # Per-server SSH connection pool + leases
│   ├── docker_command_builder.dart # Docker CLI command builders and quoting
│   ├── docker_service.dart        # Docker CLI execution + JSON parsing
│   ├── remote_file_command_builder.dart # Archive/copy command helpers
│   ├── remote_script_service.dart # Built-in remote install scripts + streaming exec
│   ├── sftp_file_service.dart     # SFTP list/read/write/create/rename/delete
│   ├── sftp_file_service_archive_operations.dart # Archive tool commands
│   └── sftp_file_service_sftp_helpers.dart # Recursive SFTP helpers
├── pages/
│   ├── lock/
│   │   └── lock_page.dart         # Conditional: skip if no password
│   ├── home/
│   │   ├── home_page.dart         # Server list with rich ServerCards + more menu
│   │   ├── server_card_item.dart  # Home card status + context menu wrapper
│   │   └── server_search.dart     # Search predicate shared with tests
│   ├── server/
│   │   ├── server_detail_page.dart  # Metrics detail sections + tool dialogs
│   │   ├── server_metric_sections.dart # Reusable metrics detail sections
│   │   ├── server_connection_test_page.dart # SSH latency/log test page
│   │   ├── server_key_picker.dart   # SSH key selector for server form
│   │   ├── status/status_page.dart
│   │   ├── terminal/terminal_page.dart  # SSH terminal session lifecycle
│   │   ├── terminal/terminal_actions.dart # Dashboard/snippet/tmux actions
│   │   ├── terminal/terminal_body.dart  # xterm view + dashboard/keys
│   │   ├── terminal/terminal_dashboard.dart
│   │   ├── terminal/terminal_extra_keys_bar.dart
│   │   ├── terminal/terminal_extra_key_controller.dart
│   │   ├── terminal/terminal_input.dart # xterm input and modifier handling
│   │   ├── terminal/terminal_launch_mode.dart
│   │   ├── terminal/terminal_platform.dart
│   │   ├── terminal/terminal_snippet_button.dart
│   │   ├── files/files_tabs_page.dart
│   │   ├── files/files_page.dart
│   │   ├── files/archive_preview_page.dart
│   │   ├── files/download_center_page.dart
│   │   ├── files/file_archive_dialog.dart
│   │   ├── files/file_entry_actions_dialog.dart
│   │   ├── files/file_tool_install_dialog.dart
│   │   ├── files/files_page_conflict_dialog.dart
│   │   ├── files/file_text_editor_page.dart
│   │   ├── files/file_entry_tile.dart
│   │   ├── files/file_name_dialog.dart
│   │   ├── docker/docker_page.dart
│   │   ├── docker/docker_manager_page.dart
│   │   ├── docker/docker_logs_page.dart
│   │   └── scripts/scripts_page.dart
│   ├── scripts/
│   │   ├── scripts_library_page.dart  # Via /settings/scripts
│   │   └── script_editor_page.dart
│   ├── terminal/
│   │   ├── terminal_tabs_page.dart    # Browser-like terminal tabs
│   │   └── terminal_tabs_tmux.dart    # Terminal picker popup + tmux helper
│   ├── snippets/
│   │   └── snippets_page.dart         # Via /settings/snippets
│   └── settings/
│       ├── about_page.dart            # App about and tech stack
│       ├── server_groups_page.dart    # Drag servers into groups
│       ├── server_groups_widgets.dart # Group/server drag assignment widgets
│       ├── settings_page.dart         # Grouped sections
│       ├── keys/                      # SSH key list/import/generate
│       ├── security/
│       ├── metrics/
│       │   └── metric_settings_page.dart # Refresh/SSH timing settings
│       └── appearance/
│           ├── appearance_page.dart   # Theme + language (functional)
│           ├── theme_color_picker.dart # Dynamic/manual theme color picker
│           └── terminal_appearance_section.dart
└── widgets/
    ├── responsive_scaffold.dart   # Phone/tablet/desktop nav switching
    ├── server_card.dart           # Rich card: OS icon, uptime, metrics
    ├── circular_metric.dart       # Ring progress (CPU/Mem/Disk)
    ├── text_metric.dart           # Compact text metric for network/I/O
    ├── os_icon.dart               # OS brand icon (simple_icons) + picker
    ├── remote_script_output_dialog.dart # Shared live output dialog
    └── common.dart                # Compact AppBar, SectionHeader, EmptyState, dialogs
```

## Naming Conventions

- Pages: `<feature>_page.dart`
- Widgets: descriptive noun (e.g. `server_card.dart`)
- Services: `<domain>_service.dart`
- Providers: `<domain>_provider.dart`
- Models: singular noun (e.g. `server.dart`)

## Repo Tooling

- `.vscode/` is local-only editor configuration and is ignored in git.

## Changelog
- 2026-05-06: Add branch reset provider, grouped ordering widgets, compact AppBar, terminal history, and snippets
- 2026-05-05: Mark VS Code workspace settings as local-only and ignored
- 2026-05-04: Add remote script model, provider, service, and shared output dialog
- 2026-05-04: Add Docker models, provider, service, manager page, and logs page
- 2026-05-03: Add archive preview page, live tool install dialog, and keep-both naming helper
