import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appName.
  ///
  /// In zh, this message translates to:
  /// **'Orbita'**
  String get appName;

  /// No description provided for @commonOk.
  ///
  /// In zh, this message translates to:
  /// **'确定'**
  String get commonOk;

  /// No description provided for @commonCancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get commonCancel;

  /// No description provided for @commonConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get commonConfirm;

  /// No description provided for @commonDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get commonDelete;

  /// No description provided for @commonSave.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get commonSave;

  /// No description provided for @commonRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新'**
  String get commonRefresh;

  /// No description provided for @unlock.
  ///
  /// In zh, this message translates to:
  /// **'解锁'**
  String get unlock;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @useBiometrics.
  ///
  /// In zh, this message translates to:
  /// **'使用生物识别'**
  String get useBiometrics;

  /// No description provided for @navHome.
  ///
  /// In zh, this message translates to:
  /// **'主页'**
  String get navHome;

  /// No description provided for @navFiles.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get navFiles;

  /// No description provided for @navTerminal.
  ///
  /// In zh, this message translates to:
  /// **'终端'**
  String get navTerminal;

  /// No description provided for @navDocker.
  ///
  /// In zh, this message translates to:
  /// **'Docker'**
  String get navDocker;

  /// No description provided for @navSettings.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get navSettings;

  /// No description provided for @servers.
  ///
  /// In zh, this message translates to:
  /// **'服务器'**
  String get servers;

  /// No description provided for @all.
  ///
  /// In zh, this message translates to:
  /// **'全部'**
  String get all;

  /// No description provided for @production.
  ///
  /// In zh, this message translates to:
  /// **'生产'**
  String get production;

  /// No description provided for @test.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get test;

  /// No description provided for @noServersTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂无服务器'**
  String get noServersTitle;

  /// No description provided for @noServersSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击 + 添加'**
  String get noServersSubtitle;

  /// No description provided for @serverDetail.
  ///
  /// In zh, this message translates to:
  /// **'服务器详情'**
  String get serverDetail;

  /// No description provided for @offline.
  ///
  /// In zh, this message translates to:
  /// **'离线'**
  String get offline;

  /// No description provided for @addServer.
  ///
  /// In zh, this message translates to:
  /// **'添加服务器'**
  String get addServer;

  /// No description provided for @editServer.
  ///
  /// In zh, this message translates to:
  /// **'编辑服务器'**
  String get editServer;

  /// No description provided for @serverName.
  ///
  /// In zh, this message translates to:
  /// **'服务器名称'**
  String get serverName;

  /// No description provided for @serverHost.
  ///
  /// In zh, this message translates to:
  /// **'主机地址'**
  String get serverHost;

  /// No description provided for @serverPort.
  ///
  /// In zh, this message translates to:
  /// **'端口'**
  String get serverPort;

  /// No description provided for @serverUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get serverUsername;

  /// No description provided for @serverOsType.
  ///
  /// In zh, this message translates to:
  /// **'操作系统'**
  String get serverOsType;

  /// No description provided for @serverAuthType.
  ///
  /// In zh, this message translates to:
  /// **'认证方式'**
  String get serverAuthType;

  /// No description provided for @authPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get authPassword;

  /// No description provided for @authPrivateKey.
  ///
  /// In zh, this message translates to:
  /// **'私钥'**
  String get authPrivateKey;

  /// No description provided for @authPassphrase.
  ///
  /// In zh, this message translates to:
  /// **'密钥口令'**
  String get authPassphrase;

  /// No description provided for @authSelectKey.
  ///
  /// In zh, this message translates to:
  /// **'选择密钥'**
  String get authSelectKey;

  /// No description provided for @authNoKey.
  ///
  /// In zh, this message translates to:
  /// **'未选择密钥'**
  String get authNoKey;

  /// No description provided for @serverTags.
  ///
  /// In zh, this message translates to:
  /// **'标签'**
  String get serverTags;

  /// No description provided for @serverTagsHint.
  ///
  /// In zh, this message translates to:
  /// **'标签1, 标签2, ...'**
  String get serverTagsHint;

  /// No description provided for @selectOsType.
  ///
  /// In zh, this message translates to:
  /// **'选择操作系统'**
  String get selectOsType;

  /// No description provided for @deleteServerTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除服务器'**
  String get deleteServerTitle;

  /// No description provided for @deleteServerContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？此操作不可撤销。'**
  String deleteServerContent(String name);

  /// No description provided for @keyManagement.
  ///
  /// In zh, this message translates to:
  /// **'密钥管理'**
  String get keyManagement;

  /// No description provided for @keyManagementDesc.
  ///
  /// In zh, this message translates to:
  /// **'SSH 密钥的导入、生成与管理'**
  String get keyManagementDesc;

  /// No description provided for @keyListTitle.
  ///
  /// In zh, this message translates to:
  /// **'密钥管理'**
  String get keyListTitle;

  /// No description provided for @addKey.
  ///
  /// In zh, this message translates to:
  /// **'添加密钥'**
  String get addKey;

  /// No description provided for @editKey.
  ///
  /// In zh, this message translates to:
  /// **'编辑密钥'**
  String get editKey;

  /// No description provided for @importKey.
  ///
  /// In zh, this message translates to:
  /// **'导入密钥'**
  String get importKey;

  /// No description provided for @generateKey.
  ///
  /// In zh, this message translates to:
  /// **'生成密钥'**
  String get generateKey;

  /// No description provided for @keyName.
  ///
  /// In zh, this message translates to:
  /// **'密钥名称'**
  String get keyName;

  /// No description provided for @keyType.
  ///
  /// In zh, this message translates to:
  /// **'密钥类型'**
  String get keyType;

  /// No description provided for @keyPrivate.
  ///
  /// In zh, this message translates to:
  /// **'私钥内容'**
  String get keyPrivate;

  /// No description provided for @keyPublic.
  ///
  /// In zh, this message translates to:
  /// **'公钥'**
  String get keyPublic;

  /// No description provided for @keyPassphrase.
  ///
  /// In zh, this message translates to:
  /// **'密钥口令'**
  String get keyPassphrase;

  /// No description provided for @keyCreatedAt.
  ///
  /// In zh, this message translates to:
  /// **'创建时间'**
  String get keyCreatedAt;

  /// No description provided for @deleteKeyTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除密钥'**
  String get deleteKeyTitle;

  /// No description provided for @deleteKeyContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除密钥「{name}」吗？使用此密钥的服务器将受影响。'**
  String deleteKeyContent(String name);

  /// No description provided for @keyGenerating.
  ///
  /// In zh, this message translates to:
  /// **'正在生成密钥...'**
  String get keyGenerating;

  /// No description provided for @keyGenerated.
  ///
  /// In zh, this message translates to:
  /// **'密钥已生成'**
  String get keyGenerated;

  /// No description provided for @keyCopied.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get keyCopied;

  /// No description provided for @keyNoPublicKey.
  ///
  /// In zh, this message translates to:
  /// **'导入的密钥无公钥'**
  String get keyNoPublicKey;

  /// No description provided for @keyCopyPublicKey.
  ///
  /// In zh, this message translates to:
  /// **'复制公钥'**
  String get keyCopyPublicKey;

  /// No description provided for @noKeys.
  ///
  /// In zh, this message translates to:
  /// **'暂无密钥'**
  String get noKeys;

  /// No description provided for @noKeysSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'点击 + 添加或生成'**
  String get noKeysSubtitle;

  /// No description provided for @selectKey.
  ///
  /// In zh, this message translates to:
  /// **'选择密钥'**
  String get selectKey;

  /// No description provided for @validationRequired.
  ///
  /// In zh, this message translates to:
  /// **'必填'**
  String get validationRequired;

  /// No description provided for @validationInvalidPort.
  ///
  /// In zh, this message translates to:
  /// **'端口范围 1-65535'**
  String get validationInvalidPort;

  /// No description provided for @validationInvalidHost.
  ///
  /// In zh, this message translates to:
  /// **'主机地址无效'**
  String get validationInvalidHost;

  /// No description provided for @statusTab.
  ///
  /// In zh, this message translates to:
  /// **'状态'**
  String get statusTab;

  /// No description provided for @terminalTab.
  ///
  /// In zh, this message translates to:
  /// **'终端'**
  String get terminalTab;

  /// No description provided for @filesTab.
  ///
  /// In zh, this message translates to:
  /// **'文件'**
  String get filesTab;

  /// No description provided for @dockerTab.
  ///
  /// In zh, this message translates to:
  /// **'Docker'**
  String get dockerTab;

  /// No description provided for @scriptsTab.
  ///
  /// In zh, this message translates to:
  /// **'脚本'**
  String get scriptsTab;

  /// No description provided for @statusDev.
  ///
  /// In zh, this message translates to:
  /// **'状态监控（开发中）'**
  String get statusDev;

  /// No description provided for @terminalDev.
  ///
  /// In zh, this message translates to:
  /// **'终端（开发中）'**
  String get terminalDev;

  /// No description provided for @filesDev.
  ///
  /// In zh, this message translates to:
  /// **'文件管理（开发中）'**
  String get filesDev;

  /// No description provided for @dockerDev.
  ///
  /// In zh, this message translates to:
  /// **'Docker管理（开发中）'**
  String get dockerDev;

  /// No description provided for @scriptsDev.
  ///
  /// In zh, this message translates to:
  /// **'脚本执行（开发中）'**
  String get scriptsDev;

  /// No description provided for @settingsServerSection.
  ///
  /// In zh, this message translates to:
  /// **'服务器管理'**
  String get settingsServerSection;

  /// No description provided for @settingsGroups.
  ///
  /// In zh, this message translates to:
  /// **'服务器分组'**
  String get settingsGroups;

  /// No description provided for @settingsGroupsDesc.
  ///
  /// In zh, this message translates to:
  /// **'管理服务器标签与分组'**
  String get settingsGroupsDesc;

  /// No description provided for @settingsToolsSection.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get settingsToolsSection;

  /// No description provided for @settingsScripts.
  ///
  /// In zh, this message translates to:
  /// **'脚本管理'**
  String get settingsScripts;

  /// No description provided for @settingsScriptsDesc.
  ///
  /// In zh, this message translates to:
  /// **'管理和执行远程脚本'**
  String get settingsScriptsDesc;

  /// No description provided for @settingsSnippets.
  ///
  /// In zh, this message translates to:
  /// **'命令片段'**
  String get settingsSnippets;

  /// No description provided for @settingsSnippetsDesc.
  ///
  /// In zh, this message translates to:
  /// **'常用命令快捷收藏'**
  String get settingsSnippetsDesc;

  /// No description provided for @scriptsTitle.
  ///
  /// In zh, this message translates to:
  /// **'脚本'**
  String get scriptsTitle;

  /// No description provided for @snippetsTitle.
  ///
  /// In zh, this message translates to:
  /// **'片段'**
  String get snippetsTitle;

  /// No description provided for @settingsSecuritySection.
  ///
  /// In zh, this message translates to:
  /// **'安全与同步'**
  String get settingsSecuritySection;

  /// No description provided for @settingsSecurity.
  ///
  /// In zh, this message translates to:
  /// **'安全设置'**
  String get settingsSecurity;

  /// No description provided for @settingsSecurityDesc.
  ///
  /// In zh, this message translates to:
  /// **'密码与生物识别'**
  String get settingsSecurityDesc;

  /// No description provided for @settingsSync.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 同步'**
  String get settingsSync;

  /// No description provided for @settingsSyncDesc.
  ///
  /// In zh, this message translates to:
  /// **'备份与同步服务器配置'**
  String get settingsSyncDesc;

  /// No description provided for @settingsAppSection.
  ///
  /// In zh, this message translates to:
  /// **'应用'**
  String get settingsAppSection;

  /// No description provided for @settingsAppearance.
  ///
  /// In zh, this message translates to:
  /// **'外观与语言'**
  String get settingsAppearance;

  /// No description provided for @settingsAppearanceDesc.
  ///
  /// In zh, this message translates to:
  /// **'主题模式和显示语言'**
  String get settingsAppearanceDesc;

  /// No description provided for @settingsNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络与隧道'**
  String get settingsNetwork;

  /// No description provided for @settingsNetworkDesc.
  ///
  /// In zh, this message translates to:
  /// **'Cloudflared / Tailscale'**
  String get settingsNetworkDesc;

  /// No description provided for @settingsAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于 Orbita'**
  String get settingsAbout;

  /// No description provided for @settingsAboutDesc.
  ///
  /// In zh, this message translates to:
  /// **'版本信息与更新检查'**
  String get settingsAboutDesc;

  /// No description provided for @comingSoon.
  ///
  /// In zh, this message translates to:
  /// **'即将推出'**
  String get comingSoon;

  /// No description provided for @inDevelopment.
  ///
  /// In zh, this message translates to:
  /// **'开发中'**
  String get inDevelopment;

  /// No description provided for @securityTitle.
  ///
  /// In zh, this message translates to:
  /// **'安全设置'**
  String get securityTitle;

  /// No description provided for @securityCurrentTier.
  ///
  /// In zh, this message translates to:
  /// **'当前保护'**
  String get securityCurrentTier;

  /// No description provided for @securityDeviceEncryption.
  ///
  /// In zh, this message translates to:
  /// **'设备加密'**
  String get securityDeviceEncryption;

  /// No description provided for @securityDeviceEncryptionDesc.
  ///
  /// In zh, this message translates to:
  /// **'服务器数据由系统钥匙串加密保护'**
  String get securityDeviceEncryptionDesc;

  /// No description provided for @securityAdditional.
  ///
  /// In zh, this message translates to:
  /// **'额外保护'**
  String get securityAdditional;

  /// No description provided for @securityAppPassword.
  ///
  /// In zh, this message translates to:
  /// **'应用密码'**
  String get securityAppPassword;

  /// No description provided for @securityBiometric.
  ///
  /// In zh, this message translates to:
  /// **'生物识别解锁'**
  String get securityBiometric;

  /// No description provided for @appearanceTitle.
  ///
  /// In zh, this message translates to:
  /// **'外观与语言'**
  String get appearanceTitle;

  /// No description provided for @themeMode.
  ///
  /// In zh, this message translates to:
  /// **'主题模式'**
  String get themeMode;

  /// No description provided for @themeModeSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get themeModeSystem;

  /// No description provided for @themeModeLight.
  ///
  /// In zh, this message translates to:
  /// **'浅色'**
  String get themeModeLight;

  /// No description provided for @themeModeDark.
  ///
  /// In zh, this message translates to:
  /// **'深色'**
  String get themeModeDark;

  /// No description provided for @dynamicColor.
  ///
  /// In zh, this message translates to:
  /// **'动态取色'**
  String get dynamicColor;

  /// No description provided for @dynamicColorDesc.
  ///
  /// In zh, this message translates to:
  /// **'根据系统壁纸自动生成主题色，开启后不受下方主题色影响'**
  String get dynamicColorDesc;

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get themeColor;

  /// No description provided for @themeColorDesc.
  ///
  /// In zh, this message translates to:
  /// **'选择一个常用主题色，关闭动态取色后生效'**
  String get themeColorDesc;

  /// No description provided for @themeColorIndigo.
  ///
  /// In zh, this message translates to:
  /// **'靛蓝'**
  String get themeColorIndigo;

  /// No description provided for @themeColorBlue.
  ///
  /// In zh, this message translates to:
  /// **'蓝色'**
  String get themeColorBlue;

  /// No description provided for @themeColorViolet.
  ///
  /// In zh, this message translates to:
  /// **'紫色'**
  String get themeColorViolet;

  /// No description provided for @themeColorTeal.
  ///
  /// In zh, this message translates to:
  /// **'青色'**
  String get themeColorTeal;

  /// No description provided for @themeColorEmerald.
  ///
  /// In zh, this message translates to:
  /// **'绿色'**
  String get themeColorEmerald;

  /// No description provided for @themeColorOrange.
  ///
  /// In zh, this message translates to:
  /// **'橙色'**
  String get themeColorOrange;

  /// No description provided for @themeColorRose.
  ///
  /// In zh, this message translates to:
  /// **'玫红'**
  String get themeColorRose;

  /// No description provided for @language.
  ///
  /// In zh, this message translates to:
  /// **'语言'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In zh, this message translates to:
  /// **'跟随系统'**
  String get languageSystem;

  /// No description provided for @languageZh.
  ///
  /// In zh, this message translates to:
  /// **'中文'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In zh, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @serverActions.
  ///
  /// In zh, this message translates to:
  /// **'服务器操作'**
  String get serverActions;

  /// No description provided for @actionRefresh.
  ///
  /// In zh, this message translates to:
  /// **'刷新状态'**
  String get actionRefresh;

  /// No description provided for @actionLogs.
  ///
  /// In zh, this message translates to:
  /// **'查看日志'**
  String get actionLogs;

  /// No description provided for @actionConnect.
  ///
  /// In zh, this message translates to:
  /// **'连接终端'**
  String get actionConnect;

  /// No description provided for @actionFileManager.
  ///
  /// In zh, this message translates to:
  /// **'文件管理'**
  String get actionFileManager;

  /// No description provided for @actionDocker.
  ///
  /// In zh, this message translates to:
  /// **'Docker 管理'**
  String get actionDocker;

  /// No description provided for @actionScripts.
  ///
  /// In zh, this message translates to:
  /// **'执行脚本'**
  String get actionScripts;

  /// No description provided for @actionEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑服务器'**
  String get actionEdit;

  /// No description provided for @actionDelete.
  ///
  /// In zh, this message translates to:
  /// **'删除服务器'**
  String get actionDelete;

  /// No description provided for @sshConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接...'**
  String get sshConnecting;

  /// No description provided for @sshConnectionFailed.
  ///
  /// In zh, this message translates to:
  /// **'连接失败'**
  String get sshConnectionFailed;

  /// No description provided for @sshDisconnected.
  ///
  /// In zh, this message translates to:
  /// **'未连接'**
  String get sshDisconnected;

  /// No description provided for @metricCpu.
  ///
  /// In zh, this message translates to:
  /// **'CPU'**
  String get metricCpu;

  /// No description provided for @metricMemory.
  ///
  /// In zh, this message translates to:
  /// **'内存'**
  String get metricMemory;

  /// No description provided for @metricDisk.
  ///
  /// In zh, this message translates to:
  /// **'磁盘'**
  String get metricDisk;

  /// No description provided for @metricNetwork.
  ///
  /// In zh, this message translates to:
  /// **'网络'**
  String get metricNetwork;

  /// No description provided for @metricIo.
  ///
  /// In zh, this message translates to:
  /// **'I/O'**
  String get metricIo;

  /// No description provided for @serverLogsTitle.
  ///
  /// In zh, this message translates to:
  /// **'服务器日志'**
  String get serverLogsTitle;

  /// No description provided for @serverLogsEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无日志'**
  String get serverLogsEmpty;

  /// No description provided for @serverLogsEmptySubtitle.
  ///
  /// In zh, this message translates to:
  /// **'连接、状态请求和错误会显示在这里'**
  String get serverLogsEmptySubtitle;

  /// No description provided for @serverLogLevelInfo.
  ///
  /// In zh, this message translates to:
  /// **'信息'**
  String get serverLogLevelInfo;

  /// No description provided for @serverLogLevelError.
  ///
  /// In zh, this message translates to:
  /// **'错误'**
  String get serverLogLevelError;

  /// No description provided for @serverLogLevelCommand.
  ///
  /// In zh, this message translates to:
  /// **'命令'**
  String get serverLogLevelCommand;

  /// No description provided for @homeMoreActions.
  ///
  /// In zh, this message translates to:
  /// **'更多操作'**
  String get homeMoreActions;

  /// No description provided for @homeLayoutOptions.
  ///
  /// In zh, this message translates to:
  /// **'调整布局'**
  String get homeLayoutOptions;

  /// No description provided for @settingsServers.
  ///
  /// In zh, this message translates to:
  /// **'服务器列表'**
  String get settingsServers;

  /// No description provided for @settingsServersDesc.
  ///
  /// In zh, this message translates to:
  /// **'添加、编辑和管理服务器'**
  String get settingsServersDesc;

  /// No description provided for @serverCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 台服务器'**
  String serverCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
