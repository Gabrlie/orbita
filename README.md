# Orbita

Orbita 是一款基于 Flutter 和 Material Design 3 构建的跨平台服务器管理应用。它通过 SSH/SFTP 直接连接服务器，不需要安装服务端 Agent，默认本地优先、隐私优先，并面向 Android 优先发布。

## 功能概览

- 服务器管理：保存服务器、SSH 密钥、分组与标签，支持连接测试和日志查看。
- 状态监控：展示 CPU、内存、磁盘、网络、I/O、负载与系统信息。
- 终端：支持普通 SSH 终端和 tmux 会话复用。
- 文件管理：支持远程目录浏览、文本编辑、复制/移动/删除、压缩包预览与下载中心。
- Docker 管理：查看 Docker 概览、容器、Compose 项目、镜像和卷，并执行常用操作。
- 脚本与片段：内置系统脚本，支持用户自定义远程脚本与常用命令片段。
- 安全与备份：应用密码、生物识别解锁、三种锁定策略、本地/WebDAV 加密备份与恢复。
- 在线更新：检查 GitHub Release，下载匹配 Android ABI 的 APK 并校验 SHA256。

## 安全模型

- 服务器配置和敏感数据保存在本机，不上传到 Orbita 自有服务。
- 远程管理只通过 SSH/SFTP 和 Linux 原生命令完成。
- 备份文件在写入本地文件夹或 WebDAV 前加密，远端只保存密文。
- 恢复备份必须输入应用密码，生物识别只用于解锁应用。
- 锁定策略支持永不锁定、退出应用时锁定、空闲一段时间后锁定。

## 技术栈

| 层级 | 技术 |
|------|------|
| 应用框架 | Flutter 3.41 / Dart 3.11 |
| UI | Material Design 3, dynamic color |
| 状态管理 | Riverpod 3.x |
| 路由 | go_router |
| SSH/SFTP | dartssh2 |
| 终端 | xterm |
| 本地存储 | drift, shared_preferences, flutter_secure_storage |
| 加密 | AES-256-GCM, Argon2id, pointycastle |
| 备份同步 | Local folder, WebDAV |
| 国际化 | flutter_localizations, intl, ARB |
| 更新 | GitHub Release API, ota_update |

## 开发环境

```powershell
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
```

## Android 构建

调试包：

```powershell
flutter build apk --debug
```

发布包需要配置 `android/key.properties` 和对应 keystore，然后按 ABI 拆分：

```powershell
flutter build apk --release --split-per-abi
```

发布资产命名遵循：

```text
orbita-{version}-android-{abi}.apk
orbita-{version}-android-{abi}.apk.sha256
```

例如 `orbita-1.0.3-android-arm64-v8a.apk`。

## 当前版本

`1.0.3+4`
