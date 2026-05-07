// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Orbita';

  @override
  String get commonOk => 'OK';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonConfirm => 'Confirm';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonSave => 'Save';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get commonTest => 'Test';

  @override
  String get commonActionDone => 'Action completed';

  @override
  String get commonActionFailed => 'Action failed';

  @override
  String get newTab => 'New Tab';

  @override
  String get openNewTab => 'Open New Tab';

  @override
  String get closeTab => 'Close Tab';

  @override
  String get unlock => 'Unlock';

  @override
  String get password => 'Password';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get navHome => 'Metrics';

  @override
  String get navFiles => 'Files';

  @override
  String get navTerminal => 'Terminal';

  @override
  String get navDocker => 'Docker';

  @override
  String get navSettings => 'Settings';

  @override
  String get servers => 'Servers';

  @override
  String get all => 'All';

  @override
  String get production => 'Production';

  @override
  String get test => 'Test';

  @override
  String get noServersTitle => 'No Servers';

  @override
  String get noServersSubtitle => 'Tap + to add';

  @override
  String get serverDetail => 'Server Details';

  @override
  String get offline => 'Offline';

  @override
  String get addServer => 'Add Server';

  @override
  String get editServer => 'Edit Server';

  @override
  String get serverName => 'Server Name';

  @override
  String get serverHost => 'Host';

  @override
  String get serverPort => 'Port';

  @override
  String get serverUsername => 'Username';

  @override
  String get serverOsType => 'OS Type';

  @override
  String get serverAuthType => 'Auth Method';

  @override
  String get authPassword => 'Password';

  @override
  String get authPrivateKey => 'Private Key';

  @override
  String get authPassphrase => 'Passphrase';

  @override
  String get authSelectKey => 'Select Key';

  @override
  String get authNoKey => 'No key selected';

  @override
  String get serverTags => 'Tags';

  @override
  String get serverTagsHint => 'tag1, tag2, ...';

  @override
  String get selectOsType => 'Select OS Type';

  @override
  String get deleteServerTitle => 'Delete Server';

  @override
  String deleteServerContent(String name) {
    return 'Are you sure you want to delete \"$name\"? This cannot be undone.';
  }

  @override
  String get keyManagement => 'Key Management';

  @override
  String get keyManagementDesc => 'Import, generate, and manage SSH keys';

  @override
  String get keyListTitle => 'Key Management';

  @override
  String get addKey => 'Add Key';

  @override
  String get editKey => 'Edit Key';

  @override
  String get importKey => 'Import Key';

  @override
  String get keyImportLocal => 'Import Local Keys';

  @override
  String get keyImportLocalNone => 'No local keys found to import';

  @override
  String keyImportLocalResult(int count) {
    return 'Imported $count local keys';
  }

  @override
  String get generateKey => 'Generate Key';

  @override
  String get keyName => 'Key Name';

  @override
  String get keyType => 'Key Type';

  @override
  String get keyPrivate => 'Private Key Content';

  @override
  String get keyPublic => 'Public Key';

  @override
  String get keyPassphrase => 'Passphrase';

  @override
  String get keyCreatedAt => 'Created';

  @override
  String get deleteKeyTitle => 'Delete Key';

  @override
  String deleteKeyContent(String name) {
    return 'Are you sure you want to delete key \"$name\"? Servers using this key will be affected.';
  }

  @override
  String get deleteKeyInUseTitle => 'Cannot Delete Key';

  @override
  String deleteKeyInUseContent(String key, String servers) {
    return '\"$key\" is used by these servers:\n$servers';
  }

  @override
  String get keyGenerating => 'Generating key...';

  @override
  String get keyGenerated => 'Key generated';

  @override
  String get keyCopied => 'Copied to clipboard';

  @override
  String get keyNoPublicKey => 'No public key for imported key';

  @override
  String get keyCopyPublicKey => 'Copy Public Key';

  @override
  String keyUsedByServerCount(int count) {
    return '$count servers using this key';
  }

  @override
  String get noKeys => 'No Keys';

  @override
  String get noKeysSubtitle => 'Tap + to add or generate';

  @override
  String get selectKey => 'Select Key';

  @override
  String get validationRequired => 'Required';

  @override
  String get validationInvalidPort => 'Port must be 1-65535';

  @override
  String get validationInvalidHost => 'Invalid host';

  @override
  String get statusTab => 'Status';

  @override
  String get terminalTab => 'Terminal';

  @override
  String get filesTab => 'Files';

  @override
  String get dockerTab => 'Docker';

  @override
  String get scriptsTab => 'Scripts';

  @override
  String get statusDev => 'Status Monitoring (WIP)';

  @override
  String get terminalDev => 'Terminal (WIP)';

  @override
  String get filesDev => 'File Manager (WIP)';

  @override
  String get dockerDev => 'Docker Manager (WIP)';

  @override
  String get dockerOverview => 'Overview';

  @override
  String get dockerContainers => 'Containers';

  @override
  String get dockerCompose => 'Compose';

  @override
  String get dockerImages => 'Images';

  @override
  String get dockerVolumes => 'Volumes';

  @override
  String get dockerUnavailable => 'Docker unavailable';

  @override
  String get dockerMissing => 'Docker is not installed';

  @override
  String get dockerPermissionDenied => 'Current user has no Docker permission';

  @override
  String get dockerLoadFailed => 'Docker load failed';

  @override
  String get dockerVersion => 'Docker Version';

  @override
  String get dockerComposeVersion => 'Compose Version';

  @override
  String get dockerStorageDriver => 'Storage Driver';

  @override
  String get dockerRootDir => 'Docker Root Dir';

  @override
  String get dockerArchitecture => 'Architecture';

  @override
  String get dockerCpuMemory => 'CPU / Memory';

  @override
  String get dockerTotalContainers => 'Containers';

  @override
  String get dockerRunningContainers => 'Running';

  @override
  String get dockerStoppedContainers => 'Stopped';

  @override
  String get dockerComposeProjects => 'Compose Projects';

  @override
  String get dockerImageCount => 'Images';

  @override
  String get dockerVolumeCount => 'Volumes';

  @override
  String get dockerStart => 'Start';

  @override
  String get dockerStop => 'Stop';

  @override
  String get dockerRestart => 'Restart';

  @override
  String get dockerDetails => 'Details';

  @override
  String get dockerLogs => 'Logs';

  @override
  String get dockerExec => 'Exec Terminal';

  @override
  String get dockerExecShell => 'Choose Shell';

  @override
  String get dockerDeleteContainerTitle => 'Delete Container';

  @override
  String dockerDeleteContainerContent(String name) {
    return 'Delete container \"$name\"?';
  }

  @override
  String get dockerDown => 'Down';

  @override
  String get dockerCreateCompose => 'Create Compose';

  @override
  String get dockerProjectName => 'Project Name';

  @override
  String get dockerRemoteDirectory => 'Remote Directory';

  @override
  String get dockerComposeYaml => 'Compose YAML';

  @override
  String get dockerDeployNow => 'Deploy after saving';

  @override
  String get dockerEditYaml => 'Edit YAML';

  @override
  String get dockerDeleteComposeTitle => 'Delete Compose';

  @override
  String dockerDeleteComposeContent(String name) {
    return 'Delete the compose file for \"$name\"?';
  }

  @override
  String get dockerPull => 'Pull / Update';

  @override
  String get dockerUpdateImage => 'Update Image';

  @override
  String get dockerDeleteImageTitle => 'Delete Image';

  @override
  String dockerDeleteImageContent(String image) {
    return 'Delete image \"$image\"?';
  }

  @override
  String dockerRunningContainersWarning(int count) {
    return '$count linked running containers were found. Updating only pulls the new image and will not rebuild or replace running containers.';
  }

  @override
  String get dockerDeleteVolumeTitle => 'Delete Volume';

  @override
  String dockerDeleteVolumeContent(String name) {
    return 'Delete volume \"$name\"?';
  }

  @override
  String get dockerVolumeInUse => 'Volume is used by running containers';

  @override
  String get dockerNoContainers => 'No containers';

  @override
  String get dockerNoComposeProjects => 'No compose projects';

  @override
  String get dockerNoImages => 'No images';

  @override
  String get dockerNoVolumes => 'No volumes';

  @override
  String get dockerRunning => 'Running';

  @override
  String get dockerStopped => 'Stopped';

  @override
  String get dockerMixed => 'Partially running';

  @override
  String get dockerUnknown => 'Unknown';

  @override
  String get dockerCopyOutput => 'Copy Output';

  @override
  String get dockerStopStream => 'Stop Stream';

  @override
  String get dockerActionDone => 'Action completed';

  @override
  String get dockerActionFailed => 'Action failed';

  @override
  String get scriptsDev => 'Script Runner (WIP)';

  @override
  String get settingsServerSection => 'Server Management';

  @override
  String get settingsGroups => 'Server Groups';

  @override
  String get settingsGroupsDesc => 'Manage server tags and groups';

  @override
  String get settingsToolsSection => 'Tools';

  @override
  String get settingsScripts => 'Scripts';

  @override
  String get settingsScriptsDesc => 'Manage and run remote scripts';

  @override
  String get settingsSnippets => 'Snippets';

  @override
  String get settingsSnippetsDesc => 'Quick-access command bookmarks';

  @override
  String get scriptsTitle => 'Scripts';

  @override
  String get snippetsTitle => 'Snippets';

  @override
  String get serverGroupUnnamed => 'Unnamed Group';

  @override
  String get serverGroupAdd => 'New Group';

  @override
  String get serverGroupEdit => 'Edit Group';

  @override
  String get serverGroupName => 'Group Name';

  @override
  String serverGroupCount(int count) {
    return '$count servers';
  }

  @override
  String get serverGroupDropHint => 'Drag servers here';

  @override
  String get serverGroupDeleteTitle => 'Delete Group';

  @override
  String serverGroupDeleteContent(String name) {
    return 'Delete group \"$name\"? Servers will move to the unnamed group.';
  }

  @override
  String get commandSnippetAdd => 'New Snippet';

  @override
  String get commandSnippetEdit => 'Edit Snippet';

  @override
  String get commandSnippetName => 'Snippet Name';

  @override
  String get commandSnippetCommand => 'Command';

  @override
  String get commandSnippetSearchHint => 'Search snippets or commands';

  @override
  String get commandSnippetEmpty => 'No command snippets';

  @override
  String get commandSnippetDeleteTitle => 'Delete Snippet';

  @override
  String commandSnippetDeleteContent(String name) {
    return 'Delete snippet \"$name\"?';
  }

  @override
  String get scriptInstallArchiveTools => 'Install Archive Tools';

  @override
  String get scriptInstallArchiveToolsDesc =>
      'Install zip, unzip, and 7z for compression, extraction, and archive previews.';

  @override
  String get scriptInstallDocker => 'Install Docker';

  @override
  String get scriptInstallDockerDesc =>
      'Install Docker and Compose, then try to enable the Docker service.';

  @override
  String get scriptInstallTmux => 'Install tmux';

  @override
  String get scriptInstallTmuxDesc =>
      'Install tmux for terminal session reuse.';

  @override
  String get scriptChangeMirror => 'Change Package Mirror';

  @override
  String get scriptChangeMirrorDesc => 'Switch the system package mirror.';

  @override
  String get scriptSystemSection => 'System Scripts';

  @override
  String get scriptUserSection => 'User Scripts';

  @override
  String get scriptUserEmpty => 'No user scripts yet. Tap + to add one.';

  @override
  String get scriptAdd => 'New Script';

  @override
  String get scriptRun => 'Run';

  @override
  String get scriptNewTitle => 'New Script';

  @override
  String get scriptViewTitle => 'View Script';

  @override
  String get scriptEditTitle => 'Edit Script';

  @override
  String get scriptName => 'Script Name';

  @override
  String get scriptDescription => 'Description';

  @override
  String get scriptContent => 'Script Content';

  @override
  String get scriptSystemReadOnly => 'System scripts are read-only.';

  @override
  String get scriptNotFound => 'Script not found';

  @override
  String get scriptDeleteTitle => 'Delete Script';

  @override
  String scriptDeleteContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String get scriptSelectMirror => 'Select Mirror';

  @override
  String scriptChangeMirrorWithSource(String mirror) {
    return 'Change Package Mirror ($mirror)';
  }

  @override
  String get scriptMirrorTuna => 'Tsinghua TUNA';

  @override
  String get scriptMirrorUstc => 'USTC';

  @override
  String get scriptMirrorAliyun => 'Alibaba Cloud';

  @override
  String get scriptMirrorTencent => 'Tencent Cloud';

  @override
  String get scriptMirrorHuawei => 'Huawei Cloud';

  @override
  String get scriptSelectServer => 'Select Server';

  @override
  String scriptRunningOn(String script, String server) {
    return 'Running \"$script\" @ $server';
  }

  @override
  String get scriptRunSucceeded => 'Execution completed';

  @override
  String get scriptRunFailed => 'Execution failed';

  @override
  String get scriptInstallTmuxPrompt =>
      'tmux is not installed on this server. Install it now? The reused terminal will open after installation.';

  @override
  String get settingsSecuritySection => 'Security & Sync';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSecurityDesc => 'Password & biometrics';

  @override
  String get settingsSync => 'Backup & Sync';

  @override
  String get settingsSyncDesc => 'Encrypted local folder and WebDAV backups';

  @override
  String get settingsAppSection => 'Application';

  @override
  String get settingsAppearance => 'Appearance & Language';

  @override
  String get settingsAppearanceDesc => 'Theme mode and display language';

  @override
  String get settingsNetwork => 'Network & Tunnels';

  @override
  String get settingsNetworkDesc => 'Cloudflared / Tailscale';

  @override
  String get settingsAbout => 'About Orbita';

  @override
  String get settingsAboutDesc => 'Version info and update check';

  @override
  String aboutVersion(String version) {
    return 'Version $version';
  }

  @override
  String get aboutOverview => 'Overview';

  @override
  String get aboutPrivacyTitle => 'Privacy-first';

  @override
  String get aboutPrivacyDesc =>
      'Server configuration stays local and sensitive data is protected by secure storage.';

  @override
  String get aboutCrossPlatformTitle => 'Cross-platform';

  @override
  String get aboutCrossPlatformDesc =>
      'Built with Flutter, Android-first with desktop support.';

  @override
  String get aboutNoAgentTitle => 'No server agent';

  @override
  String get aboutNoAgentDesc =>
      'Uses SSH/SFTP and native Linux commands for server management.';

  @override
  String get aboutTechStack => 'Tech Stack';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get inDevelopment => 'In Development';

  @override
  String get securityTitle => 'Security';

  @override
  String get securityCurrentTier => 'Current Protection';

  @override
  String get securityDeviceEncryption => 'Device Encryption';

  @override
  String get securityDeviceEncryptionDesc =>
      'Server data is encrypted by the OS keychain';

  @override
  String get securityAdditional => 'Additional Protection';

  @override
  String get securityAppPassword => 'App Password';

  @override
  String get securityBiometric => 'Biometric Unlock';

  @override
  String get securityAppPasswordEnabled =>
      'Enabled for app unlock and encrypted backups.';

  @override
  String get securityAppPasswordDisabled =>
      'Not enabled. Backup and restore require an app password.';

  @override
  String get securitySetPassword => 'Set App Password';

  @override
  String get securityChangePassword => 'Change App Password';

  @override
  String get securityRemovePassword => 'Remove App Password';

  @override
  String get securityUnlockSection => 'Unlock Method';

  @override
  String get securityBiometricDesc =>
      'Only unlocks the app. Backup encryption still requires the app password.';

  @override
  String get securityLockPolicy => 'Lock Policy';

  @override
  String get securityLockNever => 'Never Lock';

  @override
  String get securityLockOnExit => 'Lock When Leaving App';

  @override
  String get securityLockAfterTitle => 'Lock After Time';

  @override
  String securityLockAfterMinutes(int minutes) {
    return 'Lock after $minutes min';
  }

  @override
  String get securityLockMinutes => 'Minutes';

  @override
  String get securitySaved => 'Security settings saved';

  @override
  String get securityConfirmPassword => 'Confirm Password';

  @override
  String get securityPasswordTooShort => 'Use at least 6 characters';

  @override
  String get securityPasswordMismatch => 'Passwords do not match';

  @override
  String get securityChecking => 'Checking security settings...';

  @override
  String get securityInvalidPassword => 'Incorrect password';

  @override
  String get securityBiometricReason => 'Unlock Orbita with biometrics';

  @override
  String get securityBiometricFailed => 'Biometric authentication failed';

  @override
  String get backupSyncTitle => 'Backup & Sync';

  @override
  String get backupLocalFolder => 'Local Folder Backup';

  @override
  String get backupLocalFolderUnset => 'No local backup folder selected';

  @override
  String get backupChooseFolder => 'Choose Local Folder';

  @override
  String get backupRemoteSection => 'Remote Backup';

  @override
  String get backupWebDav => 'WebDAV Remote Backup';

  @override
  String get backupWebDavUnset => 'WebDAV is not configured';

  @override
  String get backupWebDavConfig => 'Configure WebDAV';

  @override
  String get backupTestWebDav => 'Test WebDAV Connection';

  @override
  String get backupOperations => 'Operations';

  @override
  String get backupAuto => 'Automatic Background Backup';

  @override
  String get backupAutoDesc =>
      'After setup, changed data is debounced and written to enabled targets.';

  @override
  String get backupPasswordRequired =>
      'Requires the app password. Biometrics cannot replace it.';

  @override
  String get backupManual => 'Manual Backup';

  @override
  String get backupRestoreLocal => 'Restore from Local File';

  @override
  String get backupRestoreWebDav => 'Restore from WebDAV';

  @override
  String backupLastAt(String time) {
    return 'Last backup: $time';
  }

  @override
  String get backupOperationDone => 'Backup and sync completed';

  @override
  String get backupWebDavUrl => 'WebDAV URL';

  @override
  String get backupWebDavUsername => 'Username';

  @override
  String get backupWebDavPath => 'Remote File Path';

  @override
  String get updateTitle => 'Online Update';

  @override
  String get updateAutoCheck => 'Automatically Check for Updates';

  @override
  String get updateCheck => 'Check';

  @override
  String get updateCheckNow => 'Check GitHub Release Updates';

  @override
  String get updateChecking => 'Checking for updates...';

  @override
  String updateAvailable(String version) {
    return 'New version $version available';
  }

  @override
  String get updateLatest => 'You are up to date';

  @override
  String updateSkipped(String version) {
    return 'Skipped version $version';
  }

  @override
  String get updateDownload => 'Download and Install';

  @override
  String get updateSkip => 'Skip Version';

  @override
  String get updateNoAsset => 'No installer matches this device';

  @override
  String updateAsset(String architecture) {
    return 'Matched package: $architecture';
  }

  @override
  String updateDownloadProgress(int progress) {
    return 'Download progress: $progress%';
  }

  @override
  String get updateInstalling => 'Opening installer...';

  @override
  String get updateCompleted => 'Update file is ready';

  @override
  String updateFailed(String message) {
    return 'Update failed: $message';
  }

  @override
  String get appearanceTitle => 'Appearance & Language';

  @override
  String get themeMode => 'Theme Mode';

  @override
  String get themeModeSystem => 'Follow System';

  @override
  String get themeModeLight => 'Light';

  @override
  String get themeModeDark => 'Dark';

  @override
  String get dynamicColor => 'Dynamic Color';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get themeColorIndigo => 'Indigo';

  @override
  String get themeColorBlue => 'Blue';

  @override
  String get themeColorViolet => 'Violet';

  @override
  String get themeColorTeal => 'Teal';

  @override
  String get themeColorEmerald => 'Emerald';

  @override
  String get themeColorOrange => 'Orange';

  @override
  String get themeColorRose => 'Rose';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'Follow System';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => 'English';

  @override
  String get terminalAppearance => 'Terminal Appearance';

  @override
  String get terminalFontFamily => 'Terminal Font';

  @override
  String get terminalFontJetBrainsMono => 'JetBrains Mono';

  @override
  String get terminalFontSystem => 'System Default';

  @override
  String get terminalFontMonospace => 'Monospace';

  @override
  String get terminalFontCustom => 'Custom Font';

  @override
  String get terminalCustomFontFamily => 'Font Family Name';

  @override
  String get terminalFontSize => 'Font Size';

  @override
  String get terminalForegroundColor => 'Text Color';

  @override
  String get terminalBackgroundColor => 'Background Color';

  @override
  String get terminalColorPicker => 'Choose Color';

  @override
  String get terminalDashboard => 'Metrics Dashboard';

  @override
  String get terminalConnectOptions => 'Terminal Connection';

  @override
  String get terminalConnectDirect => 'Connect Terminal';

  @override
  String get terminalConnectTmux => 'Reuse tmux Session';

  @override
  String get terminalReuseTmuxShort => 'Reuse tmux';

  @override
  String get terminalTmuxUnavailable => 'tmux is not installed on this server';

  @override
  String terminalTmuxAttaching(String session) {
    return 'Attaching tmux session: $session';
  }

  @override
  String get serverActions => 'Server Actions';

  @override
  String get actionRefresh => 'Refresh Status';

  @override
  String get actionLogs => 'View Logs';

  @override
  String get actionConnect => 'Connect Terminal';

  @override
  String get actionFileManager => 'File Manager';

  @override
  String get actionDocker => 'Docker Manager';

  @override
  String get actionScripts => 'Run Scripts';

  @override
  String get actionEdit => 'Edit Server';

  @override
  String get actionDelete => 'Delete Server';

  @override
  String get sshConnecting => 'Connecting...';

  @override
  String get sshConnectionFailed => 'Connection failed';

  @override
  String get sshDisconnected => 'Not connected';

  @override
  String get metricCpu => 'CPU';

  @override
  String get metricMemory => 'Mem';

  @override
  String get metricDisk => 'Disk';

  @override
  String get metricNetwork => 'Network';

  @override
  String get metricIo => 'I/O';

  @override
  String get metricOverview => 'Overview';

  @override
  String get metricUptime => 'Uptime';

  @override
  String get metricLoad1 => '1 min';

  @override
  String get metricLoad5 => '5 min';

  @override
  String get metricLoad15 => '15 min';

  @override
  String get metricUsed => 'Used';

  @override
  String get metricCached => 'Cached';

  @override
  String get metricFree => 'Free';

  @override
  String get metricTotal => 'Total';

  @override
  String get metricApp => 'APP';

  @override
  String get metricBufferCache => 'BUF';

  @override
  String get metricCpuUser => 'User';

  @override
  String get metricCpuNice => 'Nice';

  @override
  String get metricCpuSystem => 'System';

  @override
  String get metricCpuIoWait => 'I/O wait';

  @override
  String get metricCpuIrq => 'IRQ';

  @override
  String get metricCpuSoftIrq => 'Soft IRQ';

  @override
  String get metricCpuSteal => 'Steal';

  @override
  String get metricCpuIdle => 'Idle';

  @override
  String get metricUsageTrend => 'Usage';

  @override
  String get metricRealtimeRateTrend => 'Realtime rate trend';

  @override
  String get metricUploadDownload => 'Upload / Download';

  @override
  String get metricUpload => 'Upload';

  @override
  String get metricDownload => 'Download';

  @override
  String get metricSettingsTitle => 'Connection Config';

  @override
  String get metricSettingsDesc =>
      'Refresh interval, SSH timeout, keep-alive, and reconnect';

  @override
  String get metricPollingSection => 'Polling';

  @override
  String get metricConnectionSection => 'Connection';

  @override
  String get metricRefreshInterval => 'Refresh Interval';

  @override
  String get metricSshConnectTimeout => 'SSH Connect Timeout';

  @override
  String get metricKeepAliveInterval => 'Keep-Alive Interval';

  @override
  String get metricAutoReconnect => 'Auto Reconnect';

  @override
  String get metricAutoReconnectDesc =>
      'Reconnect automatically after a metric connection drops';

  @override
  String metricSecondsValue(int seconds) {
    return '${seconds}s';
  }

  @override
  String get serverScriptsSection => 'Scripts';

  @override
  String get serverToolsSection => 'Tools';

  @override
  String get serverToolProcesses => 'Processes';

  @override
  String get serverToolIpAddress => 'IP Address';

  @override
  String get serverToolTraffic => 'Traffic';

  @override
  String get serverToolDocker => 'Docker';

  @override
  String get serverLogsShort => 'Logs';

  @override
  String get serverReboot => 'Reboot';

  @override
  String get serverShutdown => 'Shutdown';

  @override
  String get serverRebootConfirmTitle => 'Reboot Server';

  @override
  String serverRebootConfirmContent(String name) {
    return 'Reboot \"$name\"?';
  }

  @override
  String get serverShutdownConfirmTitle => 'Shutdown Server';

  @override
  String serverShutdownConfirmContent(String name) {
    return 'Shutdown \"$name\"?';
  }

  @override
  String get serverConnectionTestTitle => 'Connection Test';

  @override
  String get serverConnectionLogs => 'Connection Logs';

  @override
  String get serverConnectionTesting => 'Testing connection...';

  @override
  String serverConnectionLatency(int ms) {
    return 'Latency $ms ms';
  }

  @override
  String get serverConnectionLogResolving =>
      'Reading server and key configuration';

  @override
  String serverConnectionLogConnecting(String host, int port) {
    return 'Connecting to $host:$port';
  }

  @override
  String get serverConnectionLogSucceeded =>
      'Connected successfully; SSH responded';

  @override
  String get serverLogsTitle => 'Server Logs';

  @override
  String get serverLogsEmpty => 'No logs yet';

  @override
  String get serverLogsEmptySubtitle =>
      'Connections, status requests, and errors appear here';

  @override
  String get serverLogLevelInfo => 'Info';

  @override
  String get serverLogLevelError => 'Error';

  @override
  String get serverLogLevelCommand => 'Command';

  @override
  String get serverSearchTitle => 'Search Servers';

  @override
  String get serverSearchHint => 'Name, IP, user, tags';

  @override
  String get serverSearchNoResults => 'No matching servers';

  @override
  String get serverSearchNoResultsSubtitle => 'Try another keyword';

  @override
  String get homeMoreActions => 'More actions';

  @override
  String get homeLayoutOptions => 'Layout Options';

  @override
  String get fileServerMissing => 'Server not found';

  @override
  String get fileServerMissingSubtitle =>
      'Return to the files list and choose another server.';

  @override
  String get fileLoadingDirectory => 'Loading directory...';

  @override
  String get fileLoadingFile => 'Loading file...';

  @override
  String get fileLoadFailed => 'File load failed';

  @override
  String get fileEmptyDirectory => 'This directory is empty';

  @override
  String get fileNewFile => 'New File';

  @override
  String get fileNewFolder => 'New Folder';

  @override
  String get fileName => 'Name';

  @override
  String get fileGoRoot => 'Go to Root';

  @override
  String get fileEdit => 'Edit';

  @override
  String get fileRename => 'Rename';

  @override
  String get fileDeleteTitle => 'Confirm Delete';

  @override
  String get fileDeleteFailed =>
      'Delete failed. Check directory permissions and try again.';

  @override
  String fileDeleteFileContent(String name) {
    return 'Delete \"$name\"? This cannot be undone.';
  }

  @override
  String fileDeleteDirectoryContent(String name) {
    return 'Delete folder \"$name\" and all of its contents? This cannot be undone.';
  }

  @override
  String get fileOpenUnsupportedTitle => 'Cannot Open Yet';

  @override
  String get fileOpenUnsupportedContent =>
      'This version focuses on text editing and archive previews. Image and binary previews will be added later.';

  @override
  String get fileTooLarge =>
      'Files larger than 1 MB cannot be edited in the app yet.';

  @override
  String get fileBinaryUnsupported =>
      'Binary content was detected and cannot be edited in the app yet.';

  @override
  String get fileInvalidTarget =>
      'Cannot operate on the root directory or parent placeholder.';

  @override
  String get fileInvalidName =>
      'The name cannot be empty or contain /, ., or ..';

  @override
  String get fileSaveSuccess => 'Saved';

  @override
  String get fileSaveFailed => 'Save failed';

  @override
  String get fileDiscardTitle => 'Discard Changes';

  @override
  String get fileDiscardContent =>
      'This file has unsaved changes. Leave without saving?';

  @override
  String get fileDiscardConfirm => 'Discard';

  @override
  String get fileCopy => 'Copy';

  @override
  String get fileMove => 'Move';

  @override
  String get filePaste => 'Paste';

  @override
  String get fileTools => 'Tools';

  @override
  String get fileProperties => 'Properties';

  @override
  String get fileCompress => 'Compress';

  @override
  String get fileExtract => 'Extract';

  @override
  String get fileDownload => 'Download';

  @override
  String get fileDownloadCenter => 'Download Center';

  @override
  String get fileNoDownloads => 'No downloads yet';

  @override
  String fileCopyPending(String name) {
    return 'Copy: $name';
  }

  @override
  String fileMovePending(String name) {
    return 'Move: $name';
  }

  @override
  String get fileOverwriteTitle => 'Overwrite Existing Item';

  @override
  String fileOverwriteContent(String name) {
    return '\"$name\" already exists in this directory. Overwrite it?';
  }

  @override
  String get fileOverwrite => 'Overwrite';

  @override
  String get fileKeepBoth => 'Keep Both';

  @override
  String get fileArchiveFormat => 'Archive Format';

  @override
  String get fileUsePassword => 'Use Password';

  @override
  String get filePasswordWarning =>
      'The password is passed to the remote system tool. Only continue on trusted servers.';

  @override
  String get fileMissingToolsTitle => 'Missing Remote Tools';

  @override
  String fileMissingToolsContent(String tools) {
    return 'This server is missing: $tools. Install automatically?';
  }

  @override
  String get fileInstallTools => 'Install Tools';

  @override
  String fileInstallingTools(String tools) {
    return 'Installing: $tools';
  }

  @override
  String get fileInstallWaiting => 'Waiting for remote output...';

  @override
  String get fileInstallSucceeded => 'Installation completed';

  @override
  String get fileInstallFailed => 'Installation failed';

  @override
  String get fileCommandFailed => 'Remote command failed';

  @override
  String get fileArchivePreview => 'Archive Preview';

  @override
  String get fileArchivePreviewEmpty => 'Archive is empty';

  @override
  String get fileArchivePreviewFailed => 'Archive preview failed';

  @override
  String get fileDownloadAdded => 'Added to Download Center';

  @override
  String get fileDownloadDirectoryUnsupported =>
      'Folder download is not supported yet. Compress it first, then download.';

  @override
  String get fileDownloadQueued => 'Queued';

  @override
  String get fileDownloading => 'Downloading';

  @override
  String get fileDownloadPaused => 'Paused';

  @override
  String get fileDownloadCompleted => 'Completed';

  @override
  String get fileDownloadFailed => 'Download failed';

  @override
  String get fileDownloadCanceled => 'Canceled';

  @override
  String get filePause => 'Pause';

  @override
  String get fileResume => 'Resume';

  @override
  String get fileDeleteLocalTitle => 'Delete Local File';

  @override
  String fileDeleteLocalContent(String name) {
    return 'Delete local file \"$name\"? This cannot be undone.';
  }

  @override
  String get filePath => 'Path';

  @override
  String get fileType => 'Type';

  @override
  String get fileSize => 'Size';

  @override
  String get fileMode => 'Mode';

  @override
  String get fileModified => 'Modified';

  @override
  String get settingsServers => 'Server List';

  @override
  String get settingsServersDesc => 'Add, edit, and manage servers';

  @override
  String serverCount(int count) {
    return '$count servers';
  }
}
