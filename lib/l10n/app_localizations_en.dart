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
  String get commonSave => 'Save';

  @override
  String get commonRefresh => 'Refresh';

  @override
  String get unlock => 'Unlock';

  @override
  String get password => 'Password';

  @override
  String get useBiometrics => 'Use Biometrics';

  @override
  String get navHome => 'Home';

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
  String get settingsSecuritySection => 'Security & Sync';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsSecurityDesc => 'Password & biometrics';

  @override
  String get settingsSync => 'WebDAV Sync';

  @override
  String get settingsSyncDesc => 'Backup and sync server configs';

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
  String get dynamicColorDesc =>
      'Use system wallpaper colors; when enabled, the theme color below will not affect the app';

  @override
  String get themeColor => 'Theme Color';

  @override
  String get themeColorDesc =>
      'Choose a popular theme color to use after dynamic color is turned off';

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
  String get homeMoreActions => 'More actions';

  @override
  String get homeLayoutOptions => 'Layout Options';

  @override
  String get settingsServers => 'Server List';

  @override
  String get settingsServersDesc => 'Add, edit, and manage servers';

  @override
  String serverCount(int count) {
    return '$count servers';
  }
}
