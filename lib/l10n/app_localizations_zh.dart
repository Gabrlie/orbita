// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appName => 'Orbita';

  @override
  String get commonOk => '确定';

  @override
  String get commonCancel => '取消';

  @override
  String get commonConfirm => '确认';

  @override
  String get commonDelete => '删除';

  @override
  String get commonSave => '保存';

  @override
  String get commonRefresh => '刷新';

  @override
  String get unlock => '解锁';

  @override
  String get password => '密码';

  @override
  String get useBiometrics => '使用生物识别';

  @override
  String get navHome => '主页';

  @override
  String get navFiles => '文件';

  @override
  String get navTerminal => '终端';

  @override
  String get navDocker => 'Docker';

  @override
  String get navSettings => '设置';

  @override
  String get servers => '服务器';

  @override
  String get all => '全部';

  @override
  String get production => '生产';

  @override
  String get test => '测试';

  @override
  String get noServersTitle => '暂无服务器';

  @override
  String get noServersSubtitle => '点击 + 添加';

  @override
  String get serverDetail => '服务器详情';

  @override
  String get offline => '离线';

  @override
  String get addServer => '添加服务器';

  @override
  String get editServer => '编辑服务器';

  @override
  String get serverName => '服务器名称';

  @override
  String get serverHost => '主机地址';

  @override
  String get serverPort => '端口';

  @override
  String get serverUsername => '用户名';

  @override
  String get serverOsType => '操作系统';

  @override
  String get serverAuthType => '认证方式';

  @override
  String get authPassword => '密码';

  @override
  String get authPrivateKey => '私钥';

  @override
  String get authPassphrase => '密钥口令';

  @override
  String get authSelectKey => '选择密钥';

  @override
  String get authNoKey => '未选择密钥';

  @override
  String get serverTags => '标签';

  @override
  String get serverTagsHint => '标签1, 标签2, ...';

  @override
  String get selectOsType => '选择操作系统';

  @override
  String get deleteServerTitle => '删除服务器';

  @override
  String deleteServerContent(String name) {
    return '确定要删除「$name」吗？此操作不可撤销。';
  }

  @override
  String get keyManagement => '密钥管理';

  @override
  String get keyManagementDesc => 'SSH 密钥的导入、生成与管理';

  @override
  String get keyListTitle => '密钥管理';

  @override
  String get addKey => '添加密钥';

  @override
  String get editKey => '编辑密钥';

  @override
  String get importKey => '导入密钥';

  @override
  String get generateKey => '生成密钥';

  @override
  String get keyName => '密钥名称';

  @override
  String get keyType => '密钥类型';

  @override
  String get keyPrivate => '私钥内容';

  @override
  String get keyPublic => '公钥';

  @override
  String get keyPassphrase => '密钥口令';

  @override
  String get keyCreatedAt => '创建时间';

  @override
  String get deleteKeyTitle => '删除密钥';

  @override
  String deleteKeyContent(String name) {
    return '确定要删除密钥「$name」吗？使用此密钥的服务器将受影响。';
  }

  @override
  String get keyGenerating => '正在生成密钥...';

  @override
  String get keyGenerated => '密钥已生成';

  @override
  String get keyCopied => '已复制到剪贴板';

  @override
  String get keyNoPublicKey => '导入的密钥无公钥';

  @override
  String get keyCopyPublicKey => '复制公钥';

  @override
  String get noKeys => '暂无密钥';

  @override
  String get noKeysSubtitle => '点击 + 添加或生成';

  @override
  String get selectKey => '选择密钥';

  @override
  String get validationRequired => '必填';

  @override
  String get validationInvalidPort => '端口范围 1-65535';

  @override
  String get validationInvalidHost => '主机地址无效';

  @override
  String get statusTab => '状态';

  @override
  String get terminalTab => '终端';

  @override
  String get filesTab => '文件';

  @override
  String get dockerTab => 'Docker';

  @override
  String get scriptsTab => '脚本';

  @override
  String get statusDev => '状态监控（开发中）';

  @override
  String get terminalDev => '终端（开发中）';

  @override
  String get filesDev => '文件管理（开发中）';

  @override
  String get dockerDev => 'Docker管理（开发中）';

  @override
  String get scriptsDev => '脚本执行（开发中）';

  @override
  String get settingsServerSection => '服务器管理';

  @override
  String get settingsGroups => '服务器分组';

  @override
  String get settingsGroupsDesc => '管理服务器标签与分组';

  @override
  String get settingsToolsSection => '工具';

  @override
  String get settingsScripts => '脚本管理';

  @override
  String get settingsScriptsDesc => '管理和执行远程脚本';

  @override
  String get settingsSnippets => '命令片段';

  @override
  String get settingsSnippetsDesc => '常用命令快捷收藏';

  @override
  String get scriptsTitle => '脚本';

  @override
  String get snippetsTitle => '片段';

  @override
  String get settingsSecuritySection => '安全与同步';

  @override
  String get settingsSecurity => '安全设置';

  @override
  String get settingsSecurityDesc => '密码与生物识别';

  @override
  String get settingsSync => 'WebDAV 同步';

  @override
  String get settingsSyncDesc => '备份与同步服务器配置';

  @override
  String get settingsAppSection => '应用';

  @override
  String get settingsAppearance => '外观与语言';

  @override
  String get settingsAppearanceDesc => '主题模式和显示语言';

  @override
  String get settingsNetwork => '网络与隧道';

  @override
  String get settingsNetworkDesc => 'Cloudflared / Tailscale';

  @override
  String get settingsAbout => '关于 Orbita';

  @override
  String get settingsAboutDesc => '版本信息与更新检查';

  @override
  String get comingSoon => '即将推出';

  @override
  String get inDevelopment => '开发中';

  @override
  String get securityTitle => '安全设置';

  @override
  String get securityCurrentTier => '当前保护';

  @override
  String get securityDeviceEncryption => '设备加密';

  @override
  String get securityDeviceEncryptionDesc => '服务器数据由系统钥匙串加密保护';

  @override
  String get securityAdditional => '额外保护';

  @override
  String get securityAppPassword => '应用密码';

  @override
  String get securityBiometric => '生物识别解锁';

  @override
  String get appearanceTitle => '外观与语言';

  @override
  String get themeMode => '主题模式';

  @override
  String get themeModeSystem => '跟随系统';

  @override
  String get themeModeLight => '浅色';

  @override
  String get themeModeDark => '深色';

  @override
  String get dynamicColor => '动态取色';

  @override
  String get themeColor => '主题色';

  @override
  String get themeColorIndigo => '靛蓝';

  @override
  String get themeColorBlue => '蓝色';

  @override
  String get themeColorViolet => '紫色';

  @override
  String get themeColorTeal => '青色';

  @override
  String get themeColorEmerald => '绿色';

  @override
  String get themeColorOrange => '橙色';

  @override
  String get themeColorRose => '玫红';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => 'English';

  @override
  String get serverActions => '服务器操作';

  @override
  String get actionRefresh => '刷新状态';

  @override
  String get actionLogs => '查看日志';

  @override
  String get actionConnect => '连接终端';

  @override
  String get actionFileManager => '文件管理';

  @override
  String get actionDocker => 'Docker 管理';

  @override
  String get actionScripts => '执行脚本';

  @override
  String get actionEdit => '编辑服务器';

  @override
  String get actionDelete => '删除服务器';

  @override
  String get sshConnecting => '正在连接...';

  @override
  String get sshConnectionFailed => '连接失败';

  @override
  String get sshDisconnected => '未连接';

  @override
  String get metricCpu => 'CPU';

  @override
  String get metricMemory => '内存';

  @override
  String get metricDisk => '磁盘';

  @override
  String get metricNetwork => '网络';

  @override
  String get metricIo => 'I/O';

  @override
  String get serverLogsTitle => '服务器日志';

  @override
  String get serverLogsEmpty => '暂无日志';

  @override
  String get serverLogsEmptySubtitle => '连接、状态请求和错误会显示在这里';

  @override
  String get serverLogLevelInfo => '信息';

  @override
  String get serverLogLevelError => '错误';

  @override
  String get serverLogLevelCommand => '命令';

  @override
  String get homeMoreActions => '更多操作';

  @override
  String get homeLayoutOptions => '调整布局';

  @override
  String get settingsServers => '服务器列表';

  @override
  String get settingsServersDesc => '添加、编辑和管理服务器';

  @override
  String serverCount(int count) {
    return '$count 台服务器';
  }
}
