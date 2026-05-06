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
  String get commonEdit => '编辑';

  @override
  String get commonSave => '保存';

  @override
  String get commonRefresh => '刷新';

  @override
  String get commonTest => '测试';

  @override
  String get commonActionDone => '操作完成';

  @override
  String get commonActionFailed => '操作失败';

  @override
  String get newTab => '新标签页';

  @override
  String get openNewTab => '新建标签页';

  @override
  String get closeTab => '关闭标签页';

  @override
  String get unlock => '解锁';

  @override
  String get password => '密码';

  @override
  String get useBiometrics => '使用生物识别';

  @override
  String get navHome => '指标';

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
  String get keyImportLocal => '导入本地密钥';

  @override
  String get keyImportLocalNone => '没有发现可导入的本地密钥';

  @override
  String keyImportLocalResult(int count) {
    return '已导入 $count 个本地密钥';
  }

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
  String get deleteKeyInUseTitle => '无法删除密钥';

  @override
  String deleteKeyInUseContent(String key, String servers) {
    return '「$key」正在被以下服务器使用：\n$servers';
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
  String keyUsedByServerCount(int count) {
    return '$count 台服务器使用';
  }

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
  String get dockerOverview => '概览';

  @override
  String get dockerContainers => '容器';

  @override
  String get dockerCompose => '编排';

  @override
  String get dockerImages => '镜像';

  @override
  String get dockerVolumes => '卷';

  @override
  String get dockerUnavailable => 'Docker 不可用';

  @override
  String get dockerMissing => '服务器未安装 Docker';

  @override
  String get dockerPermissionDenied => '当前用户无 Docker 权限';

  @override
  String get dockerLoadFailed => 'Docker 加载失败';

  @override
  String get dockerVersion => 'Docker 版本';

  @override
  String get dockerComposeVersion => 'Compose 版本';

  @override
  String get dockerStorageDriver => '存储驱动';

  @override
  String get dockerRootDir => 'Docker 根目录';

  @override
  String get dockerArchitecture => '系统架构';

  @override
  String get dockerCpuMemory => 'CPU / 内存';

  @override
  String get dockerTotalContainers => '容器总数';

  @override
  String get dockerRunningContainers => '运行中';

  @override
  String get dockerStoppedContainers => '已停止';

  @override
  String get dockerComposeProjects => '编排项目';

  @override
  String get dockerImageCount => '镜像数量';

  @override
  String get dockerVolumeCount => '卷数量';

  @override
  String get dockerStart => '启动';

  @override
  String get dockerStop => '停止';

  @override
  String get dockerRestart => '重启';

  @override
  String get dockerDetails => '详情';

  @override
  String get dockerLogs => '运行日志';

  @override
  String get dockerExec => '进入终端';

  @override
  String get dockerExecShell => '选择 Shell';

  @override
  String get dockerDeleteContainerTitle => '删除容器';

  @override
  String dockerDeleteContainerContent(String name) {
    return '确定删除容器「$name」吗？';
  }

  @override
  String get dockerDown => '清理';

  @override
  String get dockerCreateCompose => '创建编排';

  @override
  String get dockerProjectName => '项目名称';

  @override
  String get dockerRemoteDirectory => '远程目录';

  @override
  String get dockerComposeYaml => 'Compose YAML';

  @override
  String get dockerDeployNow => '保存后立即部署';

  @override
  String get dockerEditYaml => '编辑 YAML';

  @override
  String get dockerDeleteComposeTitle => '删除编排';

  @override
  String dockerDeleteComposeContent(String name) {
    return '确定删除编排「$name」的 compose 文件吗？';
  }

  @override
  String get dockerPull => '拉取/更新';

  @override
  String get dockerUpdateImage => '更新镜像';

  @override
  String get dockerDeleteImageTitle => '删除镜像';

  @override
  String dockerDeleteImageContent(String image) {
    return '确定删除镜像「$image」吗？';
  }

  @override
  String dockerRunningContainersWarning(int count) {
    return '有 $count 个运行中的关联容器。更新只会拉取新镜像，不会自动重建或替换运行中的容器。';
  }

  @override
  String get dockerDeleteVolumeTitle => '删除卷';

  @override
  String dockerDeleteVolumeContent(String name) {
    return '确定删除卷「$name」吗？';
  }

  @override
  String get dockerVolumeInUse => '卷正在被运行中的容器使用';

  @override
  String get dockerNoContainers => '暂无容器';

  @override
  String get dockerNoComposeProjects => '暂无编排项目';

  @override
  String get dockerNoImages => '暂无镜像';

  @override
  String get dockerNoVolumes => '暂无卷';

  @override
  String get dockerRunning => '运行中';

  @override
  String get dockerStopped => '已停止';

  @override
  String get dockerMixed => '部分运行';

  @override
  String get dockerUnknown => '未知';

  @override
  String get dockerCopyOutput => '复制输出';

  @override
  String get dockerStopStream => '停止流';

  @override
  String get dockerActionDone => '操作完成';

  @override
  String get dockerActionFailed => '操作失败';

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
  String get serverGroupUnnamed => '未命名分组';

  @override
  String get serverGroupAdd => '新增分组';

  @override
  String get serverGroupEdit => '编辑分组';

  @override
  String get serverGroupName => '分组名称';

  @override
  String serverGroupCount(int count) {
    return '$count 台服务器';
  }

  @override
  String get serverGroupDropHint => '将服务器拖到这里';

  @override
  String get serverGroupDeleteTitle => '删除分组';

  @override
  String serverGroupDeleteContent(String name) {
    return '确定要删除分组「$name」吗？服务器会移动到未命名分组。';
  }

  @override
  String get commandSnippetAdd => '新增片段';

  @override
  String get commandSnippetEdit => '编辑片段';

  @override
  String get commandSnippetName => '片段名称';

  @override
  String get commandSnippetCommand => '命令内容';

  @override
  String get commandSnippetSearchHint => '搜索片段或命令';

  @override
  String get commandSnippetEmpty => '暂无命令片段';

  @override
  String get commandSnippetDeleteTitle => '删除片段';

  @override
  String commandSnippetDeleteContent(String name) {
    return '确定要删除片段「$name」吗？';
  }

  @override
  String get scriptInstallArchiveTools => '安装压缩工具';

  @override
  String get scriptInstallArchiveToolsDesc =>
      '安装 zip、unzip 与 7z，用于压缩、解压和压缩包预览。';

  @override
  String get scriptInstallDocker => '安装 Docker';

  @override
  String get scriptInstallDockerDesc => '安装 Docker 与 Compose，并尝试启用 Docker 服务。';

  @override
  String get scriptInstallTmux => '安装 tmux';

  @override
  String get scriptInstallTmuxDesc => '安装 tmux，用于终端会话复用。';

  @override
  String get scriptChangeMirror => '一键换源';

  @override
  String get scriptChangeMirrorDesc => '为系统更换软件源。';

  @override
  String get scriptSystemSection => '系统脚本';

  @override
  String get scriptUserSection => '用户脚本';

  @override
  String get scriptUserEmpty => '暂无用户脚本，点击 + 添加。';

  @override
  String get scriptAdd => '新增脚本';

  @override
  String get scriptRun => '运行';

  @override
  String get scriptNewTitle => '新增脚本';

  @override
  String get scriptViewTitle => '查看脚本';

  @override
  String get scriptEditTitle => '编辑脚本';

  @override
  String get scriptName => '脚本名称';

  @override
  String get scriptDescription => '脚本说明';

  @override
  String get scriptContent => '脚本内容';

  @override
  String get scriptSystemReadOnly => '系统默认脚本仅允许查看，不能编辑。';

  @override
  String get scriptNotFound => '脚本不存在';

  @override
  String get scriptDeleteTitle => '删除脚本';

  @override
  String scriptDeleteContent(String name) {
    return '确定要删除「$name」吗？此操作不可撤销。';
  }

  @override
  String get scriptSelectMirror => '选择镜像源';

  @override
  String scriptChangeMirrorWithSource(String mirror) {
    return '一键换源（$mirror）';
  }

  @override
  String get scriptMirrorTuna => '清华大学 TUNA';

  @override
  String get scriptMirrorUstc => '中国科学技术大学 USTC';

  @override
  String get scriptMirrorAliyun => '阿里云';

  @override
  String get scriptMirrorTencent => '腾讯云';

  @override
  String get scriptMirrorHuawei => '华为云';

  @override
  String get scriptSelectServer => '选择服务器';

  @override
  String scriptRunningOn(String script, String server) {
    return '正在执行「$script」@ $server';
  }

  @override
  String get scriptRunSucceeded => '执行完成';

  @override
  String get scriptRunFailed => '执行失败';

  @override
  String get scriptInstallTmuxPrompt => '服务器未安装 tmux，是否现在安装？安装完成后会继续打开复用终端。';

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
  String aboutVersion(String version) {
    return '版本 $version';
  }

  @override
  String get aboutOverview => '概览';

  @override
  String get aboutPrivacyTitle => '隐私优先';

  @override
  String get aboutPrivacyDesc => '服务器配置保存在本地，敏感数据由系统安全存储保护。';

  @override
  String get aboutCrossPlatformTitle => '跨平台';

  @override
  String get aboutCrossPlatformDesc => '以 Flutter 构建，面向 Android 优先并兼顾桌面平台。';

  @override
  String get aboutNoAgentTitle => '无需服务端代理';

  @override
  String get aboutNoAgentDesc => '通过 SSH/SFTP 和 Linux 原生命令完成服务器管理。';

  @override
  String get aboutTechStack => '技术栈';

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
  String get terminalAppearance => '终端外观';

  @override
  String get terminalFontFamily => '终端字体';

  @override
  String get terminalFontJetBrainsMono => 'JetBrains Mono';

  @override
  String get terminalFontSystem => '系统默认';

  @override
  String get terminalFontMonospace => '等宽字体';

  @override
  String get terminalFontCustom => '自定义字体';

  @override
  String get terminalCustomFontFamily => '字体族名称';

  @override
  String get terminalFontSize => '字体大小';

  @override
  String get terminalForegroundColor => '字体颜色';

  @override
  String get terminalBackgroundColor => '背景颜色';

  @override
  String get terminalColorPicker => '选择颜色';

  @override
  String get terminalDashboard => '指标仪表盘';

  @override
  String get terminalConnectOptions => '终端连接';

  @override
  String get terminalConnectDirect => '连接终端';

  @override
  String get terminalConnectTmux => '复用 tmux 会话';

  @override
  String get terminalReuseTmuxShort => '复用 tmux';

  @override
  String get terminalTmuxUnavailable => '服务器未安装 tmux';

  @override
  String terminalTmuxAttaching(String session) {
    return '正在连接 tmux 会话：$session';
  }

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
  String get metricOverview => '概览';

  @override
  String get metricUptime => '开机时长';

  @override
  String get metricLoad1 => '1分钟';

  @override
  String get metricLoad5 => '5分钟';

  @override
  String get metricLoad15 => '15分钟';

  @override
  String get metricUsed => '已用';

  @override
  String get metricCached => '缓存';

  @override
  String get metricFree => '空闲';

  @override
  String get metricTotal => '总计';

  @override
  String get metricApp => 'APP';

  @override
  String get metricBufferCache => 'BUF';

  @override
  String get metricCpuUser => '用户';

  @override
  String get metricCpuNice => 'Nice';

  @override
  String get metricCpuSystem => '系统';

  @override
  String get metricCpuIoWait => 'I/O 等待';

  @override
  String get metricCpuIrq => 'IRQ';

  @override
  String get metricCpuSoftIrq => '软中断';

  @override
  String get metricCpuSteal => '窃取';

  @override
  String get metricCpuIdle => '空闲';

  @override
  String get metricUsageTrend => '使用率';

  @override
  String get metricRealtimeRateTrend => '实时速率趋势';

  @override
  String get metricUploadDownload => '上传 / 下载';

  @override
  String get metricUpload => '上传';

  @override
  String get metricDownload => '下载';

  @override
  String get metricSettingsTitle => '连接配置';

  @override
  String get metricSettingsDesc => '刷新间隔、SSH 超时、Keep-Alive 与重连';

  @override
  String get metricPollingSection => '轮询';

  @override
  String get metricConnectionSection => '连接';

  @override
  String get metricRefreshInterval => '刷新间隔';

  @override
  String get metricSshConnectTimeout => 'SSH 连接超时';

  @override
  String get metricKeepAliveInterval => 'Keep-Alive 间隔';

  @override
  String get metricAutoReconnect => '自动重连';

  @override
  String get metricAutoReconnectDesc => '指标连接断开后自动重新连接';

  @override
  String metricSecondsValue(int seconds) {
    return '$seconds 秒';
  }

  @override
  String get serverScriptsSection => '脚本';

  @override
  String get serverToolsSection => '工具';

  @override
  String get serverToolProcesses => '进程列表';

  @override
  String get serverToolIpAddress => 'IP 地址';

  @override
  String get serverToolTraffic => '流量统计';

  @override
  String get serverToolDocker => 'Docker';

  @override
  String get serverLogsShort => '日志';

  @override
  String get serverReboot => '重启';

  @override
  String get serverShutdown => '关机';

  @override
  String get serverRebootConfirmTitle => '重启服务器';

  @override
  String serverRebootConfirmContent(String name) {
    return '确定要重启「$name」吗？';
  }

  @override
  String get serverShutdownConfirmTitle => '关闭服务器';

  @override
  String serverShutdownConfirmContent(String name) {
    return '确定要关闭「$name」吗？';
  }

  @override
  String get serverConnectionTestTitle => '连接测试';

  @override
  String get serverConnectionLogs => '连接日志';

  @override
  String get serverConnectionTesting => '正在测试连接...';

  @override
  String serverConnectionLatency(int ms) {
    return '延迟 $ms ms';
  }

  @override
  String get serverConnectionLogResolving => '正在读取服务器与密钥配置';

  @override
  String serverConnectionLogConnecting(String host, int port) {
    return '正在连接 $host:$port';
  }

  @override
  String get serverConnectionLogSucceeded => '连接成功，SSH 响应正常';

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
  String get serverSearchTitle => '搜索服务器';

  @override
  String get serverSearchHint => '名称、IP、用户、标签';

  @override
  String get serverSearchNoResults => '没有匹配的服务器';

  @override
  String get serverSearchNoResultsSubtitle => '换个关键词试试';

  @override
  String get homeMoreActions => '更多操作';

  @override
  String get homeLayoutOptions => '调整布局';

  @override
  String get fileServerMissing => '服务器不存在';

  @override
  String get fileServerMissingSubtitle => '返回文件列表后重新选择一台服务器。';

  @override
  String get fileLoadingDirectory => '正在加载目录...';

  @override
  String get fileLoadingFile => '正在加载文件...';

  @override
  String get fileLoadFailed => '文件加载失败';

  @override
  String get fileEmptyDirectory => '当前目录为空';

  @override
  String get fileNewFile => '新建文件';

  @override
  String get fileNewFolder => '新建文件夹';

  @override
  String get fileName => '名称';

  @override
  String get fileGoRoot => '回到根目录';

  @override
  String get fileEdit => '编辑';

  @override
  String get fileRename => '重命名';

  @override
  String get fileDeleteTitle => '确认删除';

  @override
  String get fileDeleteFailed => '删除失败，请检查目录权限后重试。';

  @override
  String fileDeleteFileContent(String name) {
    return '确定删除「$name」吗？此操作不可撤销。';
  }

  @override
  String fileDeleteDirectoryContent(String name) {
    return '确定删除文件夹「$name」及其中的所有内容吗？此操作不可撤销。';
  }

  @override
  String get fileOpenUnsupportedTitle => '暂不支持打开';

  @override
  String get fileOpenUnsupportedContent =>
      '当前版本优先支持文本文件编辑和压缩包预览，图片和二进制文件预览会在后续版本完善。';

  @override
  String get fileTooLarge => '文件超过 1 MB，暂不支持在应用内编辑。';

  @override
  String get fileBinaryUnsupported => '检测到二进制内容，暂不支持在应用内编辑。';

  @override
  String get fileInvalidTarget => '不能操作根目录或父目录占位项。';

  @override
  String get fileInvalidName => '名称不能为空，且不能包含 /、. 或 ..。';

  @override
  String get fileSaveSuccess => '已保存';

  @override
  String get fileSaveFailed => '保存失败';

  @override
  String get fileDiscardTitle => '放弃修改';

  @override
  String get fileDiscardContent => '当前文件还有未保存的修改，确定直接返回吗？';

  @override
  String get fileDiscardConfirm => '放弃';

  @override
  String get fileCopy => '复制';

  @override
  String get fileMove => '移动';

  @override
  String get filePaste => '粘贴';

  @override
  String get fileTools => '工具';

  @override
  String get fileProperties => '属性';

  @override
  String get fileCompress => '压缩';

  @override
  String get fileExtract => '解压';

  @override
  String get fileDownload => '下载';

  @override
  String get fileDownloadCenter => '下载中心';

  @override
  String get fileNoDownloads => '暂无下载记录';

  @override
  String fileCopyPending(String name) {
    return '复制：$name';
  }

  @override
  String fileMovePending(String name) {
    return '移动：$name';
  }

  @override
  String get fileOverwriteTitle => '覆盖已有项目';

  @override
  String fileOverwriteContent(String name) {
    return '当前目录已存在「$name」，是否覆盖？';
  }

  @override
  String get fileOverwrite => '覆盖';

  @override
  String get fileKeepBoth => '保留两者';

  @override
  String get fileArchiveFormat => '压缩格式';

  @override
  String get fileUsePassword => '使用密码';

  @override
  String get filePasswordWarning => '密码会交给远程系统工具处理，请确认服务器可信。';

  @override
  String get fileMissingToolsTitle => '缺少远程工具';

  @override
  String fileMissingToolsContent(String tools) {
    return '服务器缺少以下工具：$tools。是否自动安装？';
  }

  @override
  String get fileInstallTools => '安装工具';

  @override
  String fileInstallingTools(String tools) {
    return '正在安装：$tools';
  }

  @override
  String get fileInstallWaiting => '等待远程服务器输出...';

  @override
  String get fileInstallSucceeded => '安装完成';

  @override
  String get fileInstallFailed => '安装失败';

  @override
  String get fileCommandFailed => '远程命令执行失败';

  @override
  String get fileArchivePreview => '压缩包预览';

  @override
  String get fileArchivePreviewEmpty => '压缩包为空';

  @override
  String get fileArchivePreviewFailed => '压缩包预览失败';

  @override
  String get fileDownloadAdded => '已添加到下载中心';

  @override
  String get fileDownloadDirectoryUnsupported => '当前版本暂不支持直接下载文件夹，请先压缩后下载。';

  @override
  String get fileDownloadQueued => '等待中';

  @override
  String get fileDownloading => '下载中';

  @override
  String get fileDownloadPaused => '已暂停';

  @override
  String get fileDownloadCompleted => '已完成';

  @override
  String get fileDownloadFailed => '下载失败';

  @override
  String get fileDownloadCanceled => '已取消';

  @override
  String get filePause => '暂停';

  @override
  String get fileResume => '继续';

  @override
  String get fileDeleteLocalTitle => '删除本地文件';

  @override
  String fileDeleteLocalContent(String name) {
    return '确定删除本地文件「$name」吗？此操作不可撤销。';
  }

  @override
  String get filePath => '路径';

  @override
  String get fileType => '类型';

  @override
  String get fileSize => '大小';

  @override
  String get fileMode => '权限';

  @override
  String get fileModified => '修改时间';

  @override
  String get settingsServers => '服务器列表';

  @override
  String get settingsServersDesc => '添加、编辑和管理服务器';

  @override
  String serverCount(int count) {
    return '$count 台服务器';
  }
}
