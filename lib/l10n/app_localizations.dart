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
