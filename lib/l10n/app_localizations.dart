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

  /// No description provided for @commonEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get commonEdit;

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

  /// No description provided for @commonTest.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get commonTest;

  /// No description provided for @commonActionDone.
  ///
  /// In zh, this message translates to:
  /// **'操作完成'**
  String get commonActionDone;

  /// No description provided for @commonActionFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get commonActionFailed;

  /// No description provided for @newTab.
  ///
  /// In zh, this message translates to:
  /// **'新标签页'**
  String get newTab;

  /// No description provided for @openNewTab.
  ///
  /// In zh, this message translates to:
  /// **'新建标签页'**
  String get openNewTab;

  /// No description provided for @closeTab.
  ///
  /// In zh, this message translates to:
  /// **'关闭标签页'**
  String get closeTab;

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
  /// **'指标'**
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

  /// No description provided for @serverNetworkSection.
  ///
  /// In zh, this message translates to:
  /// **'网络与隧道'**
  String get serverNetworkSection;

  /// No description provided for @serverConnectionMode.
  ///
  /// In zh, this message translates to:
  /// **'连接方式'**
  String get serverConnectionMode;

  /// No description provided for @connectionModeDirect.
  ///
  /// In zh, this message translates to:
  /// **'直连'**
  String get connectionModeDirect;

  /// No description provided for @connectionModeTailscale.
  ///
  /// In zh, this message translates to:
  /// **'Tailscale'**
  String get connectionModeTailscale;

  /// No description provided for @tailnetEmbeddedService.
  ///
  /// In zh, this message translates to:
  /// **'内置 Tailnet 节点'**
  String get tailnetEmbeddedService;

  /// No description provided for @tailnetBackendState.
  ///
  /// In zh, this message translates to:
  /// **'状态：{state}'**
  String tailnetBackendState(String state);

  /// No description provided for @tailnetLogin.
  ///
  /// In zh, this message translates to:
  /// **'登录 Tailnet'**
  String get tailnetLogin;

  /// No description provided for @tailnetAuthUrlUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'当前没有可用的登录链接，请刷新 Tailnet 状态后重试。'**
  String get tailnetAuthUrlUnavailable;

  /// No description provided for @tailnetAuthUrlCopied.
  ///
  /// In zh, this message translates to:
  /// **'登录链接已复制：\n{url}'**
  String tailnetAuthUrlCopied(String url);

  /// No description provided for @tailnetAuthOpenFailed.
  ///
  /// In zh, this message translates to:
  /// **'打开登录链接失败：{message}'**
  String tailnetAuthOpenFailed(String message);

  /// No description provided for @tailnetSelectPeer.
  ///
  /// In zh, this message translates to:
  /// **'选择 Tailnet 设备'**
  String get tailnetSelectPeer;

  /// No description provided for @tailnetPeerRequired.
  ///
  /// In zh, this message translates to:
  /// **'请选择一个 Tailnet 设备'**
  String get tailnetPeerRequired;

  /// No description provided for @tailnetPeerPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择 Tailnet 设备'**
  String get tailnetPeerPickerTitle;

  /// No description provided for @tailnetNoPeers.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可绑定的 Tailnet 设备。'**
  String get tailnetNoPeers;

  /// No description provided for @tailnetPeerLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet 检测失败：{message}'**
  String tailnetPeerLoadFailed(String message);

  /// No description provided for @tailnetPeerNoIp.
  ///
  /// In zh, this message translates to:
  /// **'无 Tailscale IP'**
  String get tailnetPeerNoIp;

  /// No description provided for @tailnetPeerOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get tailnetPeerOnline;

  /// No description provided for @tailnetStarting.
  ///
  /// In zh, this message translates to:
  /// **'启动 Tailnet 中...'**
  String get tailnetStarting;

  /// No description provided for @tailscaleDetectPeers.
  ///
  /// In zh, this message translates to:
  /// **'检测 Tailnet 设备'**
  String get tailscaleDetectPeers;

  /// No description provided for @tailscalePeerPickerTitle.
  ///
  /// In zh, this message translates to:
  /// **'选择 Tailnet 设备'**
  String get tailscalePeerPickerTitle;

  /// No description provided for @tailscaleNoPeers.
  ///
  /// In zh, this message translates to:
  /// **'没有检测到可绑定的 Tailnet 设备。'**
  String get tailscaleNoPeers;

  /// No description provided for @tailscalePeerLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet 检测失败：{message}'**
  String tailscalePeerLoadFailed(String message);

  /// No description provided for @tailscalePeerNoIp.
  ///
  /// In zh, this message translates to:
  /// **'无 Tailscale IP'**
  String get tailscalePeerNoIp;

  /// No description provided for @tailscalePeerOnline.
  ///
  /// In zh, this message translates to:
  /// **'在线'**
  String get tailscalePeerOnline;

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

  /// No description provided for @keyImportLocal.
  ///
  /// In zh, this message translates to:
  /// **'导入本地密钥'**
  String get keyImportLocal;

  /// No description provided for @keyImportLocalNone.
  ///
  /// In zh, this message translates to:
  /// **'没有发现可导入的本地密钥'**
  String get keyImportLocalNone;

  /// No description provided for @keyImportLocalResult.
  ///
  /// In zh, this message translates to:
  /// **'已导入 {count} 个本地密钥'**
  String keyImportLocalResult(int count);

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

  /// No description provided for @deleteKeyInUseTitle.
  ///
  /// In zh, this message translates to:
  /// **'无法删除密钥'**
  String get deleteKeyInUseTitle;

  /// No description provided for @deleteKeyInUseContent.
  ///
  /// In zh, this message translates to:
  /// **'「{key}」正在被以下服务器使用：\n{servers}'**
  String deleteKeyInUseContent(String key, String servers);

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

  /// No description provided for @keyUsedByServerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 台服务器使用'**
  String keyUsedByServerCount(int count);

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

  /// No description provided for @dockerOverview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get dockerOverview;

  /// No description provided for @dockerContainers.
  ///
  /// In zh, this message translates to:
  /// **'容器'**
  String get dockerContainers;

  /// No description provided for @dockerCompose.
  ///
  /// In zh, this message translates to:
  /// **'编排'**
  String get dockerCompose;

  /// No description provided for @dockerImages.
  ///
  /// In zh, this message translates to:
  /// **'镜像'**
  String get dockerImages;

  /// No description provided for @dockerVolumes.
  ///
  /// In zh, this message translates to:
  /// **'卷'**
  String get dockerVolumes;

  /// No description provided for @dockerUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Docker 不可用'**
  String get dockerUnavailable;

  /// No description provided for @dockerMissing.
  ///
  /// In zh, this message translates to:
  /// **'服务器未安装 Docker'**
  String get dockerMissing;

  /// No description provided for @dockerPermissionDenied.
  ///
  /// In zh, this message translates to:
  /// **'当前用户无 Docker 权限'**
  String get dockerPermissionDenied;

  /// No description provided for @dockerLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'Docker 加载失败'**
  String get dockerLoadFailed;

  /// No description provided for @dockerVersion.
  ///
  /// In zh, this message translates to:
  /// **'Docker 版本'**
  String get dockerVersion;

  /// No description provided for @dockerComposeVersion.
  ///
  /// In zh, this message translates to:
  /// **'Compose 版本'**
  String get dockerComposeVersion;

  /// No description provided for @dockerStorageDriver.
  ///
  /// In zh, this message translates to:
  /// **'存储驱动'**
  String get dockerStorageDriver;

  /// No description provided for @dockerRootDir.
  ///
  /// In zh, this message translates to:
  /// **'Docker 根目录'**
  String get dockerRootDir;

  /// No description provided for @dockerArchitecture.
  ///
  /// In zh, this message translates to:
  /// **'系统架构'**
  String get dockerArchitecture;

  /// No description provided for @dockerCpuMemory.
  ///
  /// In zh, this message translates to:
  /// **'CPU / 内存'**
  String get dockerCpuMemory;

  /// No description provided for @dockerTotalContainers.
  ///
  /// In zh, this message translates to:
  /// **'容器总数'**
  String get dockerTotalContainers;

  /// No description provided for @dockerRunningContainers.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get dockerRunningContainers;

  /// No description provided for @dockerStoppedContainers.
  ///
  /// In zh, this message translates to:
  /// **'已停止'**
  String get dockerStoppedContainers;

  /// No description provided for @dockerComposeProjects.
  ///
  /// In zh, this message translates to:
  /// **'编排项目'**
  String get dockerComposeProjects;

  /// No description provided for @dockerImageCount.
  ///
  /// In zh, this message translates to:
  /// **'镜像数量'**
  String get dockerImageCount;

  /// No description provided for @dockerVolumeCount.
  ///
  /// In zh, this message translates to:
  /// **'卷数量'**
  String get dockerVolumeCount;

  /// No description provided for @dockerStart.
  ///
  /// In zh, this message translates to:
  /// **'启动'**
  String get dockerStart;

  /// No description provided for @dockerStop.
  ///
  /// In zh, this message translates to:
  /// **'停止'**
  String get dockerStop;

  /// No description provided for @dockerRestart.
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get dockerRestart;

  /// No description provided for @dockerDetails.
  ///
  /// In zh, this message translates to:
  /// **'详情'**
  String get dockerDetails;

  /// No description provided for @dockerLogs.
  ///
  /// In zh, this message translates to:
  /// **'运行日志'**
  String get dockerLogs;

  /// No description provided for @dockerExec.
  ///
  /// In zh, this message translates to:
  /// **'进入终端'**
  String get dockerExec;

  /// No description provided for @dockerExecShell.
  ///
  /// In zh, this message translates to:
  /// **'选择 Shell'**
  String get dockerExecShell;

  /// No description provided for @dockerDeleteContainerTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除容器'**
  String get dockerDeleteContainerTitle;

  /// No description provided for @dockerDeleteContainerContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除容器「{name}」吗？'**
  String dockerDeleteContainerContent(String name);

  /// No description provided for @dockerDown.
  ///
  /// In zh, this message translates to:
  /// **'清理'**
  String get dockerDown;

  /// No description provided for @dockerCreateCompose.
  ///
  /// In zh, this message translates to:
  /// **'创建编排'**
  String get dockerCreateCompose;

  /// No description provided for @dockerProjectName.
  ///
  /// In zh, this message translates to:
  /// **'项目名称'**
  String get dockerProjectName;

  /// No description provided for @dockerRemoteDirectory.
  ///
  /// In zh, this message translates to:
  /// **'远程目录'**
  String get dockerRemoteDirectory;

  /// No description provided for @dockerComposeYaml.
  ///
  /// In zh, this message translates to:
  /// **'Compose YAML'**
  String get dockerComposeYaml;

  /// No description provided for @dockerDeployNow.
  ///
  /// In zh, this message translates to:
  /// **'保存后立即部署'**
  String get dockerDeployNow;

  /// No description provided for @dockerEditYaml.
  ///
  /// In zh, this message translates to:
  /// **'编辑 YAML'**
  String get dockerEditYaml;

  /// No description provided for @dockerDeleteComposeTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除编排'**
  String get dockerDeleteComposeTitle;

  /// No description provided for @dockerDeleteComposeContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除编排「{name}」的 compose 文件吗？'**
  String dockerDeleteComposeContent(String name);

  /// No description provided for @dockerPull.
  ///
  /// In zh, this message translates to:
  /// **'拉取/更新'**
  String get dockerPull;

  /// No description provided for @dockerUpdateImage.
  ///
  /// In zh, this message translates to:
  /// **'更新镜像'**
  String get dockerUpdateImage;

  /// No description provided for @dockerDeleteImageTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除镜像'**
  String get dockerDeleteImageTitle;

  /// No description provided for @dockerDeleteImageContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除镜像「{image}」吗？'**
  String dockerDeleteImageContent(String image);

  /// No description provided for @dockerRunningContainersWarning.
  ///
  /// In zh, this message translates to:
  /// **'有 {count} 个运行中的关联容器。更新只会拉取新镜像，不会自动重建或替换运行中的容器。'**
  String dockerRunningContainersWarning(int count);

  /// No description provided for @dockerDeleteVolumeTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除卷'**
  String get dockerDeleteVolumeTitle;

  /// No description provided for @dockerDeleteVolumeContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除卷「{name}」吗？'**
  String dockerDeleteVolumeContent(String name);

  /// No description provided for @dockerVolumeInUse.
  ///
  /// In zh, this message translates to:
  /// **'卷正在被运行中的容器使用'**
  String get dockerVolumeInUse;

  /// No description provided for @dockerNoContainers.
  ///
  /// In zh, this message translates to:
  /// **'暂无容器'**
  String get dockerNoContainers;

  /// No description provided for @dockerNoComposeProjects.
  ///
  /// In zh, this message translates to:
  /// **'暂无编排项目'**
  String get dockerNoComposeProjects;

  /// No description provided for @dockerNoImages.
  ///
  /// In zh, this message translates to:
  /// **'暂无镜像'**
  String get dockerNoImages;

  /// No description provided for @dockerNoVolumes.
  ///
  /// In zh, this message translates to:
  /// **'暂无卷'**
  String get dockerNoVolumes;

  /// No description provided for @dockerRunning.
  ///
  /// In zh, this message translates to:
  /// **'运行中'**
  String get dockerRunning;

  /// No description provided for @dockerStopped.
  ///
  /// In zh, this message translates to:
  /// **'已停止'**
  String get dockerStopped;

  /// No description provided for @dockerMixed.
  ///
  /// In zh, this message translates to:
  /// **'部分运行'**
  String get dockerMixed;

  /// No description provided for @dockerUnknown.
  ///
  /// In zh, this message translates to:
  /// **'未知'**
  String get dockerUnknown;

  /// No description provided for @dockerCopyOutput.
  ///
  /// In zh, this message translates to:
  /// **'复制输出'**
  String get dockerCopyOutput;

  /// No description provided for @dockerStopStream.
  ///
  /// In zh, this message translates to:
  /// **'停止流'**
  String get dockerStopStream;

  /// No description provided for @dockerActionDone.
  ///
  /// In zh, this message translates to:
  /// **'操作完成'**
  String get dockerActionDone;

  /// No description provided for @dockerActionFailed.
  ///
  /// In zh, this message translates to:
  /// **'操作失败'**
  String get dockerActionFailed;

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

  /// No description provided for @settingsTransfer.
  ///
  /// In zh, this message translates to:
  /// **'传输'**
  String get settingsTransfer;

  /// No description provided for @settingsTransferDesc.
  ///
  /// In zh, this message translates to:
  /// **'工具、同名处理与下载位置'**
  String get settingsTransferDesc;

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

  /// No description provided for @serverGroupUnnamed.
  ///
  /// In zh, this message translates to:
  /// **'未命名分组'**
  String get serverGroupUnnamed;

  /// No description provided for @serverGroupAdd.
  ///
  /// In zh, this message translates to:
  /// **'新增分组'**
  String get serverGroupAdd;

  /// No description provided for @serverGroupEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑分组'**
  String get serverGroupEdit;

  /// No description provided for @serverGroupName.
  ///
  /// In zh, this message translates to:
  /// **'分组名称'**
  String get serverGroupName;

  /// No description provided for @serverGroupCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 台服务器'**
  String serverGroupCount(int count);

  /// No description provided for @serverGroupDropHint.
  ///
  /// In zh, this message translates to:
  /// **'将服务器拖到这里'**
  String get serverGroupDropHint;

  /// No description provided for @serverGroupDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除分组'**
  String get serverGroupDeleteTitle;

  /// No description provided for @serverGroupDeleteContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除分组「{name}」吗？服务器会移动到未命名分组。'**
  String serverGroupDeleteContent(String name);

  /// No description provided for @commandSnippetAdd.
  ///
  /// In zh, this message translates to:
  /// **'新增片段'**
  String get commandSnippetAdd;

  /// No description provided for @commandSnippetEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑片段'**
  String get commandSnippetEdit;

  /// No description provided for @commandSnippetName.
  ///
  /// In zh, this message translates to:
  /// **'片段名称'**
  String get commandSnippetName;

  /// No description provided for @commandSnippetCommand.
  ///
  /// In zh, this message translates to:
  /// **'命令内容'**
  String get commandSnippetCommand;

  /// No description provided for @commandSnippetSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'搜索片段或命令'**
  String get commandSnippetSearchHint;

  /// No description provided for @commandSnippetEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无命令片段'**
  String get commandSnippetEmpty;

  /// No description provided for @commandSnippetDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除片段'**
  String get commandSnippetDeleteTitle;

  /// No description provided for @commandSnippetDeleteContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除片段「{name}」吗？'**
  String commandSnippetDeleteContent(String name);

  /// No description provided for @scriptInstallArchiveTools.
  ///
  /// In zh, this message translates to:
  /// **'安装压缩工具'**
  String get scriptInstallArchiveTools;

  /// No description provided for @scriptInstallArchiveToolsDesc.
  ///
  /// In zh, this message translates to:
  /// **'安装 zip、unzip 与 7z，用于压缩、解压和压缩包预览。'**
  String get scriptInstallArchiveToolsDesc;

  /// No description provided for @scriptInstallDocker.
  ///
  /// In zh, this message translates to:
  /// **'安装 Docker'**
  String get scriptInstallDocker;

  /// No description provided for @scriptInstallDockerDesc.
  ///
  /// In zh, this message translates to:
  /// **'安装 Docker 与 Compose，并尝试启用 Docker 服务。'**
  String get scriptInstallDockerDesc;

  /// No description provided for @scriptInstallTmux.
  ///
  /// In zh, this message translates to:
  /// **'安装 tmux'**
  String get scriptInstallTmux;

  /// No description provided for @scriptInstallTmuxDesc.
  ///
  /// In zh, this message translates to:
  /// **'安装 tmux，用于终端会话复用。'**
  String get scriptInstallTmuxDesc;

  /// No description provided for @scriptChangeMirror.
  ///
  /// In zh, this message translates to:
  /// **'一键换源'**
  String get scriptChangeMirror;

  /// No description provided for @scriptChangeMirrorDesc.
  ///
  /// In zh, this message translates to:
  /// **'为系统更换软件源。'**
  String get scriptChangeMirrorDesc;

  /// No description provided for @scriptSystemSection.
  ///
  /// In zh, this message translates to:
  /// **'系统脚本'**
  String get scriptSystemSection;

  /// No description provided for @scriptUserSection.
  ///
  /// In zh, this message translates to:
  /// **'用户脚本'**
  String get scriptUserSection;

  /// No description provided for @scriptUserEmpty.
  ///
  /// In zh, this message translates to:
  /// **'暂无用户脚本，点击 + 添加。'**
  String get scriptUserEmpty;

  /// No description provided for @scriptAdd.
  ///
  /// In zh, this message translates to:
  /// **'新增脚本'**
  String get scriptAdd;

  /// No description provided for @scriptRun.
  ///
  /// In zh, this message translates to:
  /// **'运行'**
  String get scriptRun;

  /// No description provided for @scriptNewTitle.
  ///
  /// In zh, this message translates to:
  /// **'新增脚本'**
  String get scriptNewTitle;

  /// No description provided for @scriptViewTitle.
  ///
  /// In zh, this message translates to:
  /// **'查看脚本'**
  String get scriptViewTitle;

  /// No description provided for @scriptEditTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑脚本'**
  String get scriptEditTitle;

  /// No description provided for @scriptName.
  ///
  /// In zh, this message translates to:
  /// **'脚本名称'**
  String get scriptName;

  /// No description provided for @scriptDescription.
  ///
  /// In zh, this message translates to:
  /// **'脚本说明'**
  String get scriptDescription;

  /// No description provided for @scriptContent.
  ///
  /// In zh, this message translates to:
  /// **'脚本内容'**
  String get scriptContent;

  /// No description provided for @scriptSystemReadOnly.
  ///
  /// In zh, this message translates to:
  /// **'系统默认脚本仅允许查看，不能编辑。'**
  String get scriptSystemReadOnly;

  /// No description provided for @scriptNotFound.
  ///
  /// In zh, this message translates to:
  /// **'脚本不存在'**
  String get scriptNotFound;

  /// No description provided for @scriptDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除脚本'**
  String get scriptDeleteTitle;

  /// No description provided for @scriptDeleteContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要删除「{name}」吗？此操作不可撤销。'**
  String scriptDeleteContent(String name);

  /// No description provided for @scriptSelectMirror.
  ///
  /// In zh, this message translates to:
  /// **'选择镜像源'**
  String get scriptSelectMirror;

  /// No description provided for @scriptChangeMirrorWithSource.
  ///
  /// In zh, this message translates to:
  /// **'一键换源（{mirror}）'**
  String scriptChangeMirrorWithSource(String mirror);

  /// No description provided for @scriptMirrorTuna.
  ///
  /// In zh, this message translates to:
  /// **'清华大学 TUNA'**
  String get scriptMirrorTuna;

  /// No description provided for @scriptMirrorUstc.
  ///
  /// In zh, this message translates to:
  /// **'中国科学技术大学 USTC'**
  String get scriptMirrorUstc;

  /// No description provided for @scriptMirrorAliyun.
  ///
  /// In zh, this message translates to:
  /// **'阿里云'**
  String get scriptMirrorAliyun;

  /// No description provided for @scriptMirrorTencent.
  ///
  /// In zh, this message translates to:
  /// **'腾讯云'**
  String get scriptMirrorTencent;

  /// No description provided for @scriptMirrorHuawei.
  ///
  /// In zh, this message translates to:
  /// **'华为云'**
  String get scriptMirrorHuawei;

  /// No description provided for @scriptSelectServer.
  ///
  /// In zh, this message translates to:
  /// **'选择服务器'**
  String get scriptSelectServer;

  /// No description provided for @scriptRunningOn.
  ///
  /// In zh, this message translates to:
  /// **'正在执行「{script}」@ {server}'**
  String scriptRunningOn(String script, String server);

  /// No description provided for @scriptRunSucceeded.
  ///
  /// In zh, this message translates to:
  /// **'执行完成'**
  String get scriptRunSucceeded;

  /// No description provided for @scriptRunFailed.
  ///
  /// In zh, this message translates to:
  /// **'执行失败'**
  String get scriptRunFailed;

  /// No description provided for @scriptInstallTmuxPrompt.
  ///
  /// In zh, this message translates to:
  /// **'服务器未安装 tmux，是否现在安装？安装完成后会继续打开复用终端。'**
  String get scriptInstallTmuxPrompt;

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
  /// **'备份与同步'**
  String get settingsSync;

  /// No description provided for @settingsSyncDesc.
  ///
  /// In zh, this message translates to:
  /// **'本地文件夹与 WebDAV 加密备份'**
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
  /// **'内置 Tailnet 代理'**
  String get settingsNetworkDesc;

  /// No description provided for @tailnetSection.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet'**
  String get tailnetSection;

  /// No description provided for @tailnetRefreshStatus.
  ///
  /// In zh, this message translates to:
  /// **'刷新 Tailnet 状态'**
  String get tailnetRefreshStatus;

  /// No description provided for @tailnetPeers.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet 设备'**
  String get tailnetPeers;

  /// No description provided for @tailnetPeerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 台设备'**
  String tailnetPeerCount(int count);

  /// No description provided for @tailnetUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet 不可用'**
  String get tailnetUnavailable;

  /// No description provided for @tailnetClearState.
  ///
  /// In zh, this message translates to:
  /// **'清除登录状态'**
  String get tailnetClearState;

  /// No description provided for @tailscaleSection.
  ///
  /// In zh, this message translates to:
  /// **'Tailscale'**
  String get tailscaleSection;

  /// No description provided for @tailscaleRefreshStatus.
  ///
  /// In zh, this message translates to:
  /// **'刷新 Tailscale 状态'**
  String get tailscaleRefreshStatus;

  /// No description provided for @tailscaleStatus.
  ///
  /// In zh, this message translates to:
  /// **'本机服务'**
  String get tailscaleStatus;

  /// No description provided for @tailscaleBackendState.
  ///
  /// In zh, this message translates to:
  /// **'状态：{state}'**
  String tailscaleBackendState(String state);

  /// No description provided for @tailscalePeers.
  ///
  /// In zh, this message translates to:
  /// **'Tailnet 设备'**
  String get tailscalePeers;

  /// No description provided for @tailscalePeerCount.
  ///
  /// In zh, this message translates to:
  /// **'{count} 台设备'**
  String tailscalePeerCount(int count);

  /// No description provided for @tailscaleUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'Tailscale 不可用'**
  String get tailscaleUnavailable;

  /// No description provided for @tailscaleInstallHint.
  ///
  /// In zh, this message translates to:
  /// **'Orbita 不会内置安装 Tailscale，请先自行安装并登录。本次检测结果：{message}'**
  String tailscaleInstallHint(String message);

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

  /// No description provided for @aboutVersion.
  ///
  /// In zh, this message translates to:
  /// **'版本 {version}'**
  String aboutVersion(String version);

  /// No description provided for @aboutOverview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get aboutOverview;

  /// No description provided for @aboutPrivacyTitle.
  ///
  /// In zh, this message translates to:
  /// **'隐私优先'**
  String get aboutPrivacyTitle;

  /// No description provided for @aboutPrivacyDesc.
  ///
  /// In zh, this message translates to:
  /// **'服务器配置保存在本地，敏感数据由系统安全存储保护。'**
  String get aboutPrivacyDesc;

  /// No description provided for @aboutCrossPlatformTitle.
  ///
  /// In zh, this message translates to:
  /// **'跨平台'**
  String get aboutCrossPlatformTitle;

  /// No description provided for @aboutCrossPlatformDesc.
  ///
  /// In zh, this message translates to:
  /// **'以 Flutter 构建，面向 Android 优先并兼顾桌面平台。'**
  String get aboutCrossPlatformDesc;

  /// No description provided for @aboutNoAgentTitle.
  ///
  /// In zh, this message translates to:
  /// **'无需服务端代理'**
  String get aboutNoAgentTitle;

  /// No description provided for @aboutNoAgentDesc.
  ///
  /// In zh, this message translates to:
  /// **'通过 SSH/SFTP 和 Linux 原生命令完成服务器管理。'**
  String get aboutNoAgentDesc;

  /// No description provided for @aboutTechStack.
  ///
  /// In zh, this message translates to:
  /// **'技术栈'**
  String get aboutTechStack;

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

  /// No description provided for @securityAppPasswordEnabled.
  ///
  /// In zh, this message translates to:
  /// **'已启用，可用于解锁应用与加密备份。'**
  String get securityAppPasswordEnabled;

  /// No description provided for @securityAppPasswordDisabled.
  ///
  /// In zh, this message translates to:
  /// **'未启用，备份与恢复功能需要先设置应用密码。'**
  String get securityAppPasswordDisabled;

  /// No description provided for @securitySetPassword.
  ///
  /// In zh, this message translates to:
  /// **'设置应用密码'**
  String get securitySetPassword;

  /// No description provided for @securityChangePassword.
  ///
  /// In zh, this message translates to:
  /// **'修改应用密码'**
  String get securityChangePassword;

  /// No description provided for @securityRemovePassword.
  ///
  /// In zh, this message translates to:
  /// **'移除应用密码'**
  String get securityRemovePassword;

  /// No description provided for @securityUnlockSection.
  ///
  /// In zh, this message translates to:
  /// **'解锁方式'**
  String get securityUnlockSection;

  /// No description provided for @securityBiometricDesc.
  ///
  /// In zh, this message translates to:
  /// **'仅用于解锁应用；恢复会先尝试本机备份密钥，其它设备备份可能需要应用密码。'**
  String get securityBiometricDesc;

  /// No description provided for @securityLockPolicy.
  ///
  /// In zh, this message translates to:
  /// **'锁定策略'**
  String get securityLockPolicy;

  /// No description provided for @securityLockNever.
  ///
  /// In zh, this message translates to:
  /// **'永不锁定'**
  String get securityLockNever;

  /// No description provided for @securityLockOnExit.
  ///
  /// In zh, this message translates to:
  /// **'退出应用时锁定'**
  String get securityLockOnExit;

  /// No description provided for @securityLockAfterTitle.
  ///
  /// In zh, this message translates to:
  /// **'空闲一定时间后锁定'**
  String get securityLockAfterTitle;

  /// No description provided for @securityLockAfterMinutes.
  ///
  /// In zh, this message translates to:
  /// **'空闲 {minutes} 分钟后锁定'**
  String securityLockAfterMinutes(int minutes);

  /// No description provided for @securityLockMinutes.
  ///
  /// In zh, this message translates to:
  /// **'空闲分钟数'**
  String get securityLockMinutes;

  /// No description provided for @securitySaved.
  ///
  /// In zh, this message translates to:
  /// **'安全设置已保存'**
  String get securitySaved;

  /// No description provided for @securityConfirmPassword.
  ///
  /// In zh, this message translates to:
  /// **'确认密码'**
  String get securityConfirmPassword;

  /// No description provided for @securityPasswordTooShort.
  ///
  /// In zh, this message translates to:
  /// **'密码至少 6 位'**
  String get securityPasswordTooShort;

  /// No description provided for @securityPasswordMismatch.
  ///
  /// In zh, this message translates to:
  /// **'两次密码不一致'**
  String get securityPasswordMismatch;

  /// No description provided for @securityChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在校验安全设置...'**
  String get securityChecking;

  /// No description provided for @securityInvalidPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码不正确'**
  String get securityInvalidPassword;

  /// No description provided for @securityBiometricReason.
  ///
  /// In zh, this message translates to:
  /// **'使用生物识别解锁 Orbita'**
  String get securityBiometricReason;

  /// No description provided for @securityBiometricFailed.
  ///
  /// In zh, this message translates to:
  /// **'生物识别验证失败'**
  String get securityBiometricFailed;

  /// No description provided for @backupSyncTitle.
  ///
  /// In zh, this message translates to:
  /// **'备份与同步'**
  String get backupSyncTitle;

  /// No description provided for @backupLocalFolder.
  ///
  /// In zh, this message translates to:
  /// **'本地文件夹备份'**
  String get backupLocalFolder;

  /// No description provided for @backupLocalFolderUnset.
  ///
  /// In zh, this message translates to:
  /// **'尚未选择本地备份目录'**
  String get backupLocalFolderUnset;

  /// No description provided for @backupChooseFolder.
  ///
  /// In zh, this message translates to:
  /// **'选择本地文件夹'**
  String get backupChooseFolder;

  /// No description provided for @backupRemoteSection.
  ///
  /// In zh, this message translates to:
  /// **'远程备份'**
  String get backupRemoteSection;

  /// No description provided for @backupWebDav.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 远程备份'**
  String get backupWebDav;

  /// No description provided for @backupWebDavUnset.
  ///
  /// In zh, this message translates to:
  /// **'尚未配置 WebDAV'**
  String get backupWebDavUnset;

  /// No description provided for @backupWebDavConfig.
  ///
  /// In zh, this message translates to:
  /// **'配置 WebDAV'**
  String get backupWebDavConfig;

  /// No description provided for @backupTestWebDav.
  ///
  /// In zh, this message translates to:
  /// **'测试 WebDAV 连接'**
  String get backupTestWebDav;

  /// No description provided for @backupOperations.
  ///
  /// In zh, this message translates to:
  /// **'操作'**
  String get backupOperations;

  /// No description provided for @backupAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动备份'**
  String get backupAuto;

  /// No description provided for @backupAutoDesc.
  ///
  /// In zh, this message translates to:
  /// **'服务器、密钥、分组、脚本或片段变化后自动写入一份加密备份。'**
  String get backupAutoDesc;

  /// No description provided for @backupAutoTime.
  ///
  /// In zh, this message translates to:
  /// **'自动备份时间'**
  String get backupAutoTime;

  /// No description provided for @backupAutoTimeDesc.
  ///
  /// In zh, this message translates to:
  /// **'每天 {time} 自动备份一次'**
  String backupAutoTimeDesc(String time);

  /// No description provided for @backupPasswordRequired.
  ///
  /// In zh, this message translates to:
  /// **'使用本设备已保存的备份密钥加密'**
  String get backupPasswordRequired;

  /// No description provided for @backupManual.
  ///
  /// In zh, this message translates to:
  /// **'手动备份'**
  String get backupManual;

  /// No description provided for @backupRestoreLocal.
  ///
  /// In zh, this message translates to:
  /// **'从本地恢复'**
  String get backupRestoreLocal;

  /// No description provided for @backupRestoreWebDav.
  ///
  /// In zh, this message translates to:
  /// **'从 WebDAV 恢复'**
  String get backupRestoreWebDav;

  /// No description provided for @backupLastAt.
  ///
  /// In zh, this message translates to:
  /// **'上次备份：{time}'**
  String backupLastAt(String time);

  /// No description provided for @backupOperationDone.
  ///
  /// In zh, this message translates to:
  /// **'备份与同步操作完成'**
  String get backupOperationDone;

  /// No description provided for @backupRestoreDone.
  ///
  /// In zh, this message translates to:
  /// **'备份恢复完成'**
  String get backupRestoreDone;

  /// No description provided for @backupRestoreFailed.
  ///
  /// In zh, this message translates to:
  /// **'备份恢复失败：{message}'**
  String backupRestoreFailed(String message);

  /// No description provided for @backupWebDavConnected.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 连接成功'**
  String get backupWebDavConnected;

  /// No description provided for @backupWebDavFailed.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 连接失败：{message}'**
  String backupWebDavFailed(String message);

  /// No description provided for @backupPasswordSetupRequired.
  ///
  /// In zh, this message translates to:
  /// **'请先配置应用密码'**
  String get backupPasswordSetupRequired;

  /// No description provided for @backupPasswordSetupDesc.
  ///
  /// In zh, this message translates to:
  /// **'备份、恢复和自动备份的密钥托管都依赖应用密码，生物识别不能替代。'**
  String get backupPasswordSetupDesc;

  /// No description provided for @backupNoTarget.
  ///
  /// In zh, this message translates to:
  /// **'请先启用本地文件夹或 WebDAV 备份目标'**
  String get backupNoTarget;

  /// No description provided for @backupNoBackups.
  ///
  /// In zh, this message translates to:
  /// **'当前目标中暂无可恢复的备份'**
  String get backupNoBackups;

  /// No description provided for @backupSelectBackup.
  ///
  /// In zh, this message translates to:
  /// **'选择要恢复的备份'**
  String get backupSelectBackup;

  /// No description provided for @backupRestoreOverwriteNotice.
  ///
  /// In zh, this message translates to:
  /// **'恢复会覆盖本地服务器、密钥、分组、脚本和片段；也可以导入其它设备的备份。'**
  String get backupRestoreOverwriteNotice;

  /// No description provided for @backupRestorePasswordPrompt.
  ///
  /// In zh, this message translates to:
  /// **'输入备份密码'**
  String get backupRestorePasswordPrompt;

  /// No description provided for @backupInvalidPassword.
  ///
  /// In zh, this message translates to:
  /// **'密码不正确，无法恢复备份'**
  String get backupInvalidPassword;

  /// No description provided for @backupInvalidSnapshot.
  ///
  /// In zh, this message translates to:
  /// **'备份文件无效或已损坏，无法恢复'**
  String get backupInvalidSnapshot;

  /// No description provided for @backupRetentionCount.
  ///
  /// In zh, this message translates to:
  /// **'备份保留数量'**
  String get backupRetentionCount;

  /// No description provided for @backupRetentionDesc.
  ///
  /// In zh, this message translates to:
  /// **'每个目标最多保留本设备最近 {count} 份备份；不会清理其它设备备份'**
  String backupRetentionDesc(int count);

  /// No description provided for @backupRetentionTitle.
  ///
  /// In zh, this message translates to:
  /// **'设置备份保留数量'**
  String get backupRetentionTitle;

  /// No description provided for @backupRetentionHelp.
  ///
  /// In zh, this message translates to:
  /// **'默认 3 份，可设置 1-100 之间的数量。'**
  String get backupRetentionHelp;

  /// No description provided for @backupWebDavUrl.
  ///
  /// In zh, this message translates to:
  /// **'WebDAV 地址'**
  String get backupWebDavUrl;

  /// No description provided for @backupWebDavUsername.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get backupWebDavUsername;

  /// No description provided for @backupWebDavFolder.
  ///
  /// In zh, this message translates to:
  /// **'远端文件夹'**
  String get backupWebDavFolder;

  /// No description provided for @updateTitle.
  ///
  /// In zh, this message translates to:
  /// **'在线更新'**
  String get updateTitle;

  /// No description provided for @updateAutoCheck.
  ///
  /// In zh, this message translates to:
  /// **'自动检查更新'**
  String get updateAutoCheck;

  /// No description provided for @updateCheck.
  ///
  /// In zh, this message translates to:
  /// **'检查'**
  String get updateCheck;

  /// No description provided for @updateCheckNow.
  ///
  /// In zh, this message translates to:
  /// **'检查 GitHub Release 更新'**
  String get updateCheckNow;

  /// No description provided for @updateChecking.
  ///
  /// In zh, this message translates to:
  /// **'正在检查更新...'**
  String get updateChecking;

  /// No description provided for @updateAvailable.
  ///
  /// In zh, this message translates to:
  /// **'发现新版本 {version}'**
  String updateAvailable(String version);

  /// No description provided for @updateLatest.
  ///
  /// In zh, this message translates to:
  /// **'已是最新版本'**
  String get updateLatest;

  /// No description provided for @updateSkipped.
  ///
  /// In zh, this message translates to:
  /// **'已跳过版本 {version}'**
  String updateSkipped(String version);

  /// No description provided for @updateDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载并安装'**
  String get updateDownload;

  /// No description provided for @updateLater.
  ///
  /// In zh, this message translates to:
  /// **'稍后提醒'**
  String get updateLater;

  /// No description provided for @updateSkip.
  ///
  /// In zh, this message translates to:
  /// **'跳过版本'**
  String get updateSkip;

  /// No description provided for @updateNoAsset.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配当前设备的安装包'**
  String get updateNoAsset;

  /// No description provided for @updateNoReleaseNotes.
  ///
  /// In zh, this message translates to:
  /// **'本次发布未填写更新内容。'**
  String get updateNoReleaseNotes;

  /// No description provided for @updateAsset.
  ///
  /// In zh, this message translates to:
  /// **'匹配安装包：{architecture}'**
  String updateAsset(String architecture);

  /// No description provided for @updateDownloadProgress.
  ///
  /// In zh, this message translates to:
  /// **'下载进度：{progress}%'**
  String updateDownloadProgress(int progress);

  /// No description provided for @updateInstalling.
  ///
  /// In zh, this message translates to:
  /// **'正在打开安装器...'**
  String get updateInstalling;

  /// No description provided for @updateCompleted.
  ///
  /// In zh, this message translates to:
  /// **'更新文件已就绪'**
  String get updateCompleted;

  /// No description provided for @updateFailed.
  ///
  /// In zh, this message translates to:
  /// **'更新失败：{message}'**
  String updateFailed(String message);

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

  /// No description provided for @themeColor.
  ///
  /// In zh, this message translates to:
  /// **'主题色'**
  String get themeColor;

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

  /// No description provided for @terminalAppearance.
  ///
  /// In zh, this message translates to:
  /// **'终端外观'**
  String get terminalAppearance;

  /// No description provided for @terminalFontFamily.
  ///
  /// In zh, this message translates to:
  /// **'终端字体'**
  String get terminalFontFamily;

  /// No description provided for @terminalFontJetBrainsMono.
  ///
  /// In zh, this message translates to:
  /// **'JetBrains Mono'**
  String get terminalFontJetBrainsMono;

  /// No description provided for @terminalFontSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统默认'**
  String get terminalFontSystem;

  /// No description provided for @terminalFontMonospace.
  ///
  /// In zh, this message translates to:
  /// **'等宽字体'**
  String get terminalFontMonospace;

  /// No description provided for @terminalFontCustom.
  ///
  /// In zh, this message translates to:
  /// **'自定义字体'**
  String get terminalFontCustom;

  /// No description provided for @terminalCustomFontFamily.
  ///
  /// In zh, this message translates to:
  /// **'字体族名称'**
  String get terminalCustomFontFamily;

  /// No description provided for @terminalFontSize.
  ///
  /// In zh, this message translates to:
  /// **'字体大小'**
  String get terminalFontSize;

  /// No description provided for @terminalForegroundColor.
  ///
  /// In zh, this message translates to:
  /// **'字体颜色'**
  String get terminalForegroundColor;

  /// No description provided for @terminalBackgroundColor.
  ///
  /// In zh, this message translates to:
  /// **'背景颜色'**
  String get terminalBackgroundColor;

  /// No description provided for @terminalColorPicker.
  ///
  /// In zh, this message translates to:
  /// **'选择颜色'**
  String get terminalColorPicker;

  /// No description provided for @terminalDashboard.
  ///
  /// In zh, this message translates to:
  /// **'指标仪表盘'**
  String get terminalDashboard;

  /// No description provided for @terminalConnectOptions.
  ///
  /// In zh, this message translates to:
  /// **'终端连接'**
  String get terminalConnectOptions;

  /// No description provided for @terminalConnectDirect.
  ///
  /// In zh, this message translates to:
  /// **'连接终端'**
  String get terminalConnectDirect;

  /// No description provided for @terminalConnectTmux.
  ///
  /// In zh, this message translates to:
  /// **'复用 tmux 会话'**
  String get terminalConnectTmux;

  /// No description provided for @terminalReuseTmuxShort.
  ///
  /// In zh, this message translates to:
  /// **'复用 tmux'**
  String get terminalReuseTmuxShort;

  /// No description provided for @terminalTmuxUnavailable.
  ///
  /// In zh, this message translates to:
  /// **'服务器未安装 tmux'**
  String get terminalTmuxUnavailable;

  /// No description provided for @terminalTmuxAttaching.
  ///
  /// In zh, this message translates to:
  /// **'正在连接 tmux 会话：{session}'**
  String terminalTmuxAttaching(String session);

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

  /// No description provided for @metricOverview.
  ///
  /// In zh, this message translates to:
  /// **'概览'**
  String get metricOverview;

  /// No description provided for @metricUptime.
  ///
  /// In zh, this message translates to:
  /// **'开机时长'**
  String get metricUptime;

  /// No description provided for @metricLoad1.
  ///
  /// In zh, this message translates to:
  /// **'1分钟'**
  String get metricLoad1;

  /// No description provided for @metricLoad5.
  ///
  /// In zh, this message translates to:
  /// **'5分钟'**
  String get metricLoad5;

  /// No description provided for @metricLoad15.
  ///
  /// In zh, this message translates to:
  /// **'15分钟'**
  String get metricLoad15;

  /// No description provided for @metricUsed.
  ///
  /// In zh, this message translates to:
  /// **'已用'**
  String get metricUsed;

  /// No description provided for @metricCached.
  ///
  /// In zh, this message translates to:
  /// **'缓存'**
  String get metricCached;

  /// No description provided for @metricFree.
  ///
  /// In zh, this message translates to:
  /// **'空闲'**
  String get metricFree;

  /// No description provided for @metricTotal.
  ///
  /// In zh, this message translates to:
  /// **'总计'**
  String get metricTotal;

  /// No description provided for @metricApp.
  ///
  /// In zh, this message translates to:
  /// **'APP'**
  String get metricApp;

  /// No description provided for @metricBufferCache.
  ///
  /// In zh, this message translates to:
  /// **'BUF'**
  String get metricBufferCache;

  /// No description provided for @metricCpuUser.
  ///
  /// In zh, this message translates to:
  /// **'用户'**
  String get metricCpuUser;

  /// No description provided for @metricCpuNice.
  ///
  /// In zh, this message translates to:
  /// **'Nice'**
  String get metricCpuNice;

  /// No description provided for @metricCpuSystem.
  ///
  /// In zh, this message translates to:
  /// **'系统'**
  String get metricCpuSystem;

  /// No description provided for @metricCpuIoWait.
  ///
  /// In zh, this message translates to:
  /// **'I/O 等待'**
  String get metricCpuIoWait;

  /// No description provided for @metricCpuIrq.
  ///
  /// In zh, this message translates to:
  /// **'IRQ'**
  String get metricCpuIrq;

  /// No description provided for @metricCpuSoftIrq.
  ///
  /// In zh, this message translates to:
  /// **'软中断'**
  String get metricCpuSoftIrq;

  /// No description provided for @metricCpuSteal.
  ///
  /// In zh, this message translates to:
  /// **'窃取'**
  String get metricCpuSteal;

  /// No description provided for @metricCpuIdle.
  ///
  /// In zh, this message translates to:
  /// **'空闲'**
  String get metricCpuIdle;

  /// No description provided for @metricUsageTrend.
  ///
  /// In zh, this message translates to:
  /// **'使用率'**
  String get metricUsageTrend;

  /// No description provided for @metricRealtimeRateTrend.
  ///
  /// In zh, this message translates to:
  /// **'实时速率趋势'**
  String get metricRealtimeRateTrend;

  /// No description provided for @metricUploadDownload.
  ///
  /// In zh, this message translates to:
  /// **'上传 / 下载'**
  String get metricUploadDownload;

  /// No description provided for @metricUpload.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get metricUpload;

  /// No description provided for @metricDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get metricDownload;

  /// No description provided for @metricSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'连接配置'**
  String get metricSettingsTitle;

  /// No description provided for @metricSettingsDesc.
  ///
  /// In zh, this message translates to:
  /// **'刷新间隔、SSH 超时、Keep-Alive 与重连'**
  String get metricSettingsDesc;

  /// No description provided for @metricPollingSection.
  ///
  /// In zh, this message translates to:
  /// **'轮询'**
  String get metricPollingSection;

  /// No description provided for @metricConnectionSection.
  ///
  /// In zh, this message translates to:
  /// **'连接'**
  String get metricConnectionSection;

  /// No description provided for @metricRefreshInterval.
  ///
  /// In zh, this message translates to:
  /// **'刷新间隔'**
  String get metricRefreshInterval;

  /// No description provided for @metricSshConnectTimeout.
  ///
  /// In zh, this message translates to:
  /// **'SSH 连接超时'**
  String get metricSshConnectTimeout;

  /// No description provided for @metricKeepAliveInterval.
  ///
  /// In zh, this message translates to:
  /// **'Keep-Alive 间隔'**
  String get metricKeepAliveInterval;

  /// No description provided for @metricAutoReconnect.
  ///
  /// In zh, this message translates to:
  /// **'自动重连'**
  String get metricAutoReconnect;

  /// No description provided for @metricAutoReconnectDesc.
  ///
  /// In zh, this message translates to:
  /// **'指标连接断开后自动重新连接'**
  String get metricAutoReconnectDesc;

  /// No description provided for @metricSecondsValue.
  ///
  /// In zh, this message translates to:
  /// **'{seconds} 秒'**
  String metricSecondsValue(int seconds);

  /// No description provided for @serverScriptsSection.
  ///
  /// In zh, this message translates to:
  /// **'脚本'**
  String get serverScriptsSection;

  /// No description provided for @serverToolsSection.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get serverToolsSection;

  /// No description provided for @serverToolProcesses.
  ///
  /// In zh, this message translates to:
  /// **'进程列表'**
  String get serverToolProcesses;

  /// No description provided for @serverToolIpAddress.
  ///
  /// In zh, this message translates to:
  /// **'IP 地址'**
  String get serverToolIpAddress;

  /// No description provided for @serverToolTraffic.
  ///
  /// In zh, this message translates to:
  /// **'流量统计'**
  String get serverToolTraffic;

  /// No description provided for @serverToolDocker.
  ///
  /// In zh, this message translates to:
  /// **'Docker'**
  String get serverToolDocker;

  /// No description provided for @serverLogsShort.
  ///
  /// In zh, this message translates to:
  /// **'日志'**
  String get serverLogsShort;

  /// No description provided for @serverReboot.
  ///
  /// In zh, this message translates to:
  /// **'重启'**
  String get serverReboot;

  /// No description provided for @serverShutdown.
  ///
  /// In zh, this message translates to:
  /// **'关机'**
  String get serverShutdown;

  /// No description provided for @serverRebootConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'重启服务器'**
  String get serverRebootConfirmTitle;

  /// No description provided for @serverRebootConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要重启「{name}」吗？'**
  String serverRebootConfirmContent(String name);

  /// No description provided for @serverShutdownConfirmTitle.
  ///
  /// In zh, this message translates to:
  /// **'关闭服务器'**
  String get serverShutdownConfirmTitle;

  /// No description provided for @serverShutdownConfirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确定要关闭「{name}」吗？'**
  String serverShutdownConfirmContent(String name);

  /// No description provided for @serverConnectionTestTitle.
  ///
  /// In zh, this message translates to:
  /// **'连接测试'**
  String get serverConnectionTestTitle;

  /// No description provided for @serverConnectionLogs.
  ///
  /// In zh, this message translates to:
  /// **'连接日志'**
  String get serverConnectionLogs;

  /// No description provided for @serverConnectionTesting.
  ///
  /// In zh, this message translates to:
  /// **'正在测试连接...'**
  String get serverConnectionTesting;

  /// No description provided for @serverConnectionLatency.
  ///
  /// In zh, this message translates to:
  /// **'延迟 {ms} ms'**
  String serverConnectionLatency(int ms);

  /// No description provided for @serverConnectionLogResolving.
  ///
  /// In zh, this message translates to:
  /// **'正在读取服务器与密钥配置'**
  String get serverConnectionLogResolving;

  /// No description provided for @serverConnectionLogConnecting.
  ///
  /// In zh, this message translates to:
  /// **'正在连接 {host}:{port}'**
  String serverConnectionLogConnecting(String host, int port);

  /// No description provided for @serverConnectionLogSucceeded.
  ///
  /// In zh, this message translates to:
  /// **'连接成功，SSH 响应正常'**
  String get serverConnectionLogSucceeded;

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

  /// No description provided for @serverSearchTitle.
  ///
  /// In zh, this message translates to:
  /// **'搜索服务器'**
  String get serverSearchTitle;

  /// No description provided for @serverSearchHint.
  ///
  /// In zh, this message translates to:
  /// **'名称、IP、用户、标签'**
  String get serverSearchHint;

  /// No description provided for @serverSearchNoResults.
  ///
  /// In zh, this message translates to:
  /// **'没有匹配的服务器'**
  String get serverSearchNoResults;

  /// No description provided for @serverSearchNoResultsSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'换个关键词试试'**
  String get serverSearchNoResultsSubtitle;

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

  /// No description provided for @fileServerMissing.
  ///
  /// In zh, this message translates to:
  /// **'服务器不存在'**
  String get fileServerMissing;

  /// No description provided for @fileServerMissingSubtitle.
  ///
  /// In zh, this message translates to:
  /// **'返回文件列表后重新选择一台服务器。'**
  String get fileServerMissingSubtitle;

  /// No description provided for @fileLoadingDirectory.
  ///
  /// In zh, this message translates to:
  /// **'正在加载目录...'**
  String get fileLoadingDirectory;

  /// No description provided for @fileLoadingFile.
  ///
  /// In zh, this message translates to:
  /// **'正在加载文件...'**
  String get fileLoadingFile;

  /// No description provided for @fileLoadFailed.
  ///
  /// In zh, this message translates to:
  /// **'文件加载失败'**
  String get fileLoadFailed;

  /// No description provided for @fileEmptyDirectory.
  ///
  /// In zh, this message translates to:
  /// **'当前目录为空'**
  String get fileEmptyDirectory;

  /// No description provided for @fileNewFile.
  ///
  /// In zh, this message translates to:
  /// **'新建文件'**
  String get fileNewFile;

  /// No description provided for @fileNewFolder.
  ///
  /// In zh, this message translates to:
  /// **'新建文件夹'**
  String get fileNewFolder;

  /// No description provided for @fileName.
  ///
  /// In zh, this message translates to:
  /// **'名称'**
  String get fileName;

  /// No description provided for @fileGoRoot.
  ///
  /// In zh, this message translates to:
  /// **'回到根目录'**
  String get fileGoRoot;

  /// No description provided for @fileEdit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get fileEdit;

  /// No description provided for @fileRename.
  ///
  /// In zh, this message translates to:
  /// **'重命名'**
  String get fileRename;

  /// No description provided for @fileDeleteTitle.
  ///
  /// In zh, this message translates to:
  /// **'确认删除'**
  String get fileDeleteTitle;

  /// No description provided for @fileDeleteFailed.
  ///
  /// In zh, this message translates to:
  /// **'删除失败，请检查目录权限后重试。'**
  String get fileDeleteFailed;

  /// No description provided for @fileDeleteFileContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除「{name}」吗？此操作不可撤销。'**
  String fileDeleteFileContent(String name);

  /// No description provided for @fileDeleteDirectoryContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除文件夹「{name}」及其中的所有内容吗？此操作不可撤销。'**
  String fileDeleteDirectoryContent(String name);

  /// No description provided for @fileOpenUnsupportedTitle.
  ///
  /// In zh, this message translates to:
  /// **'暂不支持打开'**
  String get fileOpenUnsupportedTitle;

  /// No description provided for @fileOpenUnsupportedContent.
  ///
  /// In zh, this message translates to:
  /// **'当前版本优先支持文本文件编辑和压缩包预览，图片和二进制文件预览会在后续版本完善。'**
  String get fileOpenUnsupportedContent;

  /// No description provided for @fileTooLarge.
  ///
  /// In zh, this message translates to:
  /// **'文件超过 1 MB，暂不支持在应用内编辑。'**
  String get fileTooLarge;

  /// No description provided for @fileBinaryUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'检测到二进制内容，暂不支持在应用内编辑。'**
  String get fileBinaryUnsupported;

  /// No description provided for @fileInvalidTarget.
  ///
  /// In zh, this message translates to:
  /// **'不能操作根目录或父目录占位项。'**
  String get fileInvalidTarget;

  /// No description provided for @fileInvalidName.
  ///
  /// In zh, this message translates to:
  /// **'名称不能为空，且不能包含 /、. 或 ..。'**
  String get fileInvalidName;

  /// No description provided for @fileSaveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'已保存'**
  String get fileSaveSuccess;

  /// No description provided for @fileSaveFailed.
  ///
  /// In zh, this message translates to:
  /// **'保存失败'**
  String get fileSaveFailed;

  /// No description provided for @fileDiscardTitle.
  ///
  /// In zh, this message translates to:
  /// **'放弃修改'**
  String get fileDiscardTitle;

  /// No description provided for @fileDiscardContent.
  ///
  /// In zh, this message translates to:
  /// **'当前文件还有未保存的修改，确定直接返回吗？'**
  String get fileDiscardContent;

  /// No description provided for @fileDiscardConfirm.
  ///
  /// In zh, this message translates to:
  /// **'放弃'**
  String get fileDiscardConfirm;

  /// No description provided for @fileCopy.
  ///
  /// In zh, this message translates to:
  /// **'复制'**
  String get fileCopy;

  /// No description provided for @fileMove.
  ///
  /// In zh, this message translates to:
  /// **'移动'**
  String get fileMove;

  /// No description provided for @filePaste.
  ///
  /// In zh, this message translates to:
  /// **'粘贴'**
  String get filePaste;

  /// No description provided for @fileTools.
  ///
  /// In zh, this message translates to:
  /// **'工具'**
  String get fileTools;

  /// No description provided for @fileProperties.
  ///
  /// In zh, this message translates to:
  /// **'属性'**
  String get fileProperties;

  /// No description provided for @fileCompress.
  ///
  /// In zh, this message translates to:
  /// **'压缩'**
  String get fileCompress;

  /// No description provided for @fileExtract.
  ///
  /// In zh, this message translates to:
  /// **'解压'**
  String get fileExtract;

  /// No description provided for @fileDownload.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get fileDownload;

  /// No description provided for @fileUpload.
  ///
  /// In zh, this message translates to:
  /// **'上传'**
  String get fileUpload;

  /// No description provided for @fileUploadFile.
  ///
  /// In zh, this message translates to:
  /// **'上传文件'**
  String get fileUploadFile;

  /// No description provided for @fileUploadDirectory.
  ///
  /// In zh, this message translates to:
  /// **'上传目录'**
  String get fileUploadDirectory;

  /// No description provided for @fileDownloadCenter.
  ///
  /// In zh, this message translates to:
  /// **'下载中心'**
  String get fileDownloadCenter;

  /// No description provided for @fileTransferCenter.
  ///
  /// In zh, this message translates to:
  /// **'传输'**
  String get fileTransferCenter;

  /// No description provided for @fileNoDownloads.
  ///
  /// In zh, this message translates to:
  /// **'暂无下载记录'**
  String get fileNoDownloads;

  /// No description provided for @fileNoTransfers.
  ///
  /// In zh, this message translates to:
  /// **'暂无传输记录'**
  String get fileNoTransfers;

  /// No description provided for @fileActiveTransfers.
  ///
  /// In zh, this message translates to:
  /// **'进行中'**
  String get fileActiveTransfers;

  /// No description provided for @fileCopyPending.
  ///
  /// In zh, this message translates to:
  /// **'复制：{name}'**
  String fileCopyPending(String name);

  /// No description provided for @fileMovePending.
  ///
  /// In zh, this message translates to:
  /// **'移动：{name}'**
  String fileMovePending(String name);

  /// No description provided for @fileMoveAcrossServersUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'服务器间传输使用只读临时授权，不能删除源文件。请使用复制完成互传。'**
  String get fileMoveAcrossServersUnsupported;

  /// No description provided for @fileOverwriteTitle.
  ///
  /// In zh, this message translates to:
  /// **'覆盖已有项目'**
  String get fileOverwriteTitle;

  /// No description provided for @fileOverwriteContent.
  ///
  /// In zh, this message translates to:
  /// **'当前目录已存在「{name}」，是否覆盖？'**
  String fileOverwriteContent(String name);

  /// No description provided for @fileOverwrite.
  ///
  /// In zh, this message translates to:
  /// **'覆盖'**
  String get fileOverwrite;

  /// No description provided for @fileKeepBoth.
  ///
  /// In zh, this message translates to:
  /// **'保留两者'**
  String get fileKeepBoth;

  /// No description provided for @fileArchiveFormat.
  ///
  /// In zh, this message translates to:
  /// **'压缩格式'**
  String get fileArchiveFormat;

  /// No description provided for @fileUsePassword.
  ///
  /// In zh, this message translates to:
  /// **'使用密码'**
  String get fileUsePassword;

  /// No description provided for @filePasswordWarning.
  ///
  /// In zh, this message translates to:
  /// **'密码会交给远程系统工具处理，请确认服务器可信。'**
  String get filePasswordWarning;

  /// No description provided for @fileMissingToolsTitle.
  ///
  /// In zh, this message translates to:
  /// **'缺少远程工具'**
  String get fileMissingToolsTitle;

  /// No description provided for @fileMissingToolsContent.
  ///
  /// In zh, this message translates to:
  /// **'服务器缺少以下工具：{tools}。是否自动安装？'**
  String fileMissingToolsContent(String tools);

  /// No description provided for @fileInstallTools.
  ///
  /// In zh, this message translates to:
  /// **'安装工具'**
  String get fileInstallTools;

  /// No description provided for @fileInstallingTools.
  ///
  /// In zh, this message translates to:
  /// **'正在安装：{tools}'**
  String fileInstallingTools(String tools);

  /// No description provided for @fileInstallWaiting.
  ///
  /// In zh, this message translates to:
  /// **'等待远程服务器输出...'**
  String get fileInstallWaiting;

  /// No description provided for @fileInstallSucceeded.
  ///
  /// In zh, this message translates to:
  /// **'安装完成'**
  String get fileInstallSucceeded;

  /// No description provided for @fileInstallFailed.
  ///
  /// In zh, this message translates to:
  /// **'安装失败'**
  String get fileInstallFailed;

  /// No description provided for @fileCommandFailed.
  ///
  /// In zh, this message translates to:
  /// **'远程命令执行失败'**
  String get fileCommandFailed;

  /// No description provided for @fileArchivePreview.
  ///
  /// In zh, this message translates to:
  /// **'压缩包预览'**
  String get fileArchivePreview;

  /// No description provided for @fileArchivePreviewEmpty.
  ///
  /// In zh, this message translates to:
  /// **'压缩包为空'**
  String get fileArchivePreviewEmpty;

  /// No description provided for @fileArchivePreviewFailed.
  ///
  /// In zh, this message translates to:
  /// **'压缩包预览失败'**
  String get fileArchivePreviewFailed;

  /// No description provided for @fileDownloadAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加到下载中心'**
  String get fileDownloadAdded;

  /// No description provided for @fileTransferAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加到传输'**
  String get fileTransferAdded;

  /// No description provided for @fileUploadAdded.
  ///
  /// In zh, this message translates to:
  /// **'已添加到传输'**
  String get fileUploadAdded;

  /// No description provided for @fileDownloadDirectoryUnsupported.
  ///
  /// In zh, this message translates to:
  /// **'当前版本暂不支持直接下载文件夹，请先压缩后下载。'**
  String get fileDownloadDirectoryUnsupported;

  /// No description provided for @fileDownloadQueued.
  ///
  /// In zh, this message translates to:
  /// **'等待中'**
  String get fileDownloadQueued;

  /// No description provided for @fileDownloading.
  ///
  /// In zh, this message translates to:
  /// **'下载中'**
  String get fileDownloading;

  /// No description provided for @fileUploading.
  ///
  /// In zh, this message translates to:
  /// **'上传中'**
  String get fileUploading;

  /// No description provided for @fileTransferQueued.
  ///
  /// In zh, this message translates to:
  /// **'等待中'**
  String get fileTransferQueued;

  /// No description provided for @fileTransferCompressing.
  ///
  /// In zh, this message translates to:
  /// **'压缩中'**
  String get fileTransferCompressing;

  /// No description provided for @fileTransferVerifying.
  ///
  /// In zh, this message translates to:
  /// **'校验中'**
  String get fileTransferVerifying;

  /// No description provided for @fileTransferExtracting.
  ///
  /// In zh, this message translates to:
  /// **'解压中'**
  String get fileTransferExtracting;

  /// No description provided for @fileTransferCleaning.
  ///
  /// In zh, this message translates to:
  /// **'清理中'**
  String get fileTransferCleaning;

  /// No description provided for @fileDownloadPaused.
  ///
  /// In zh, this message translates to:
  /// **'已暂停'**
  String get fileDownloadPaused;

  /// No description provided for @fileDownloadCompleted.
  ///
  /// In zh, this message translates to:
  /// **'已完成'**
  String get fileDownloadCompleted;

  /// No description provided for @fileDownloadFailed.
  ///
  /// In zh, this message translates to:
  /// **'下载失败'**
  String get fileDownloadFailed;

  /// No description provided for @fileDownloadCanceled.
  ///
  /// In zh, this message translates to:
  /// **'已取消'**
  String get fileDownloadCanceled;

  /// No description provided for @filePause.
  ///
  /// In zh, this message translates to:
  /// **'暂停'**
  String get filePause;

  /// No description provided for @fileResume.
  ///
  /// In zh, this message translates to:
  /// **'继续'**
  String get fileResume;

  /// No description provided for @fileServerTransferFallbackTitle.
  ///
  /// In zh, this message translates to:
  /// **'回退到本地中转？'**
  String get fileServerTransferFallbackTitle;

  /// No description provided for @fileServerTransferFallbackContent.
  ///
  /// In zh, this message translates to:
  /// **'服务器直传失败。是否通过本机临时文件中转继续传输？传输完成后会自动清理临时文件。'**
  String get fileServerTransferFallbackContent;

  /// No description provided for @fileServerTransferFallbackConfirm.
  ///
  /// In zh, this message translates to:
  /// **'本地中转'**
  String get fileServerTransferFallbackConfirm;

  /// No description provided for @transferSettingsTitle.
  ///
  /// In zh, this message translates to:
  /// **'传输设置'**
  String get transferSettingsTitle;

  /// No description provided for @transferToolSection.
  ///
  /// In zh, this message translates to:
  /// **'传输工具'**
  String get transferToolSection;

  /// No description provided for @transferDefaultTool.
  ///
  /// In zh, this message translates to:
  /// **'默认工具'**
  String get transferDefaultTool;

  /// No description provided for @transferToolAuto.
  ///
  /// In zh, this message translates to:
  /// **'自动'**
  String get transferToolAuto;

  /// No description provided for @transferToolAutoDesc.
  ///
  /// In zh, this message translates to:
  /// **'优先使用 rsync，不可用时使用本地中转'**
  String get transferToolAutoDesc;

  /// No description provided for @transferToolRsync.
  ///
  /// In zh, this message translates to:
  /// **'rsync'**
  String get transferToolRsync;

  /// No description provided for @transferToolRsyncDesc.
  ///
  /// In zh, this message translates to:
  /// **'目标服务器使用短期只读密钥从源服务器拉取'**
  String get transferToolRsyncDesc;

  /// No description provided for @transferToolLocalRelay.
  ///
  /// In zh, this message translates to:
  /// **'本地中转'**
  String get transferToolLocalRelay;

  /// No description provided for @transferToolLocalRelayDesc.
  ///
  /// In zh, this message translates to:
  /// **'先下载到本机临时文件，再上传到目标服务器'**
  String get transferToolLocalRelayDesc;

  /// No description provided for @transferDuplicateSection.
  ///
  /// In zh, this message translates to:
  /// **'同名文件'**
  String get transferDuplicateSection;

  /// No description provided for @transferDuplicateAction.
  ///
  /// In zh, this message translates to:
  /// **'默认操作'**
  String get transferDuplicateAction;

  /// No description provided for @transferDuplicateAsk.
  ///
  /// In zh, this message translates to:
  /// **'每次询问'**
  String get transferDuplicateAsk;

  /// No description provided for @transferDownloadSection.
  ///
  /// In zh, this message translates to:
  /// **'下载'**
  String get transferDownloadSection;

  /// No description provided for @transferDownloadDirectory.
  ///
  /// In zh, this message translates to:
  /// **'下载目录'**
  String get transferDownloadDirectory;

  /// No description provided for @transferDownloadDefaultDirectory.
  ///
  /// In zh, this message translates to:
  /// **'系统下载目录 / Orbite / 服务器名'**
  String get transferDownloadDefaultDirectory;

  /// No description provided for @transferDownloadChooseDirectory.
  ///
  /// In zh, this message translates to:
  /// **'选择目录'**
  String get transferDownloadChooseDirectory;

  /// No description provided for @transferDownloadClearDirectory.
  ///
  /// In zh, this message translates to:
  /// **'使用默认'**
  String get transferDownloadClearDirectory;

  /// No description provided for @transferAskDownloadLocation.
  ///
  /// In zh, this message translates to:
  /// **'每次下载询问保存位置'**
  String get transferAskDownloadLocation;

  /// No description provided for @transferAskDownloadLocationDesc.
  ///
  /// In zh, this message translates to:
  /// **'创建下载任务前显示原生保存对话框'**
  String get transferAskDownloadLocationDesc;

  /// No description provided for @transferDownloadSaveAs.
  ///
  /// In zh, this message translates to:
  /// **'保存下载为'**
  String get transferDownloadSaveAs;

  /// No description provided for @fileDeleteLocalTitle.
  ///
  /// In zh, this message translates to:
  /// **'删除本地文件'**
  String get fileDeleteLocalTitle;

  /// No description provided for @fileDeleteLocalContent.
  ///
  /// In zh, this message translates to:
  /// **'确定删除本地文件「{name}」吗？此操作不可撤销。'**
  String fileDeleteLocalContent(String name);

  /// No description provided for @filePath.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get filePath;

  /// No description provided for @fileType.
  ///
  /// In zh, this message translates to:
  /// **'类型'**
  String get fileType;

  /// No description provided for @fileSize.
  ///
  /// In zh, this message translates to:
  /// **'大小'**
  String get fileSize;

  /// No description provided for @fileMode.
  ///
  /// In zh, this message translates to:
  /// **'权限'**
  String get fileMode;

  /// No description provided for @fileModified.
  ///
  /// In zh, this message translates to:
  /// **'修改时间'**
  String get fileModified;

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
