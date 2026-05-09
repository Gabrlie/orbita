<h1 align="center">
  🚀 Orbita
</h1>

<p align="center">
  <b>An SSH-powered mobile server management app — monitoring, terminal access,
  file operations and Docker control.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/flutter-3.41-02569B?style=flat-square&logo=flutter&logoColor=white" alt="Flutter" />
  <img src="https://img.shields.io/badge/dart-3.11-0175C2?style=flat-square&logo=dart&logoColor=white" alt="Dart" />
  <img src="https://img.shields.io/badge/license-MIT-yellow?style=flat-square" alt="License" />
  <img src="https://img.shields.io/badge/platform-Android%20First-3DDC84?style=flat-square&logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/version-1.1.0%2B5-6C63FF?style=flat-square" alt="Version" />
  <br />
  <a href="https://github.com/Gabrlie/orbita/releases/latest">
    <img src="https://img.shields.io/github/v/release/Gabrlie/orbita?style=flat-square&label=release&color=blue" alt="Release" />
  </a>
  <a href="https://linux.do">
    <img src="https://img.shields.io/badge/Linux-DO-ffb003?style=flat-square&logo=linux&logoColor=white" alt="linux.do" />
  </a>
</p>

---

## 特性

* **零 Agent，纯天然**：仅依赖 SSH/SFTP 和 Linux 原生命令，不在服务器上安装任何额外进程。
* **本地优先，隐私至上**：所有凭据和配置仅存储在设备本地；备份支持 AES-256-GCM 端到端加密。
* **Material You 设计**：基于 Material Design 3，支持动态取色与深色模式。
* **多平台支持**：保留 iOS / 桌面端构建能力，不过暂时只有 Android 版本支持。

## 核心功能

| 模块 | 说明 |
|---|---|
| 🖥️ 服务器管理 | 保存服务器、SSH 密钥、分组与标签，支持连接测试与操作日志。 |
| 📊 状态监控 | CPU、内存、磁盘、网络、I/O、负载实时展示（环形仪表盘）。 |
| 💻 终端 | 全功能 SSH 终端 + tmux 会话复用，基于 xterm。 |
| 📁 文件管理 | 远程浏览、文本编辑、复制/移动/删除、压缩包预览与下载中心。 |
| 🐳 Docker 控制 | 概览、容器、Compose、镜像、卷管理，常用操作一键直达。 |
| 📜 脚本与片段 | 内置系统脚本，自定义远程脚本，命令片段收藏。 |
| 🌐 网络与隧道 | Android 内置 Tailnet 节点，基于 Tailscale `tsnet` 的应用内代理连接。 |
| 🔐 安全与备份 | 应用密码、生物识别解锁、三种锁定策略；本地 / WebDAV 加密备份。 |
| 🔄 在线更新 | 自动拉取 GitHub Release，按 ABI 下载 APK 并校验 SHA256。 |

## 技术栈

| 层级 | 方案 |
|---|---|
| 框架 | Flutter 3.41 / Dart 3.11 |
| UI | Material Design 3, dynamic_color |
| 状态管理 | Riverpod 3.x |
| 路由 | go_router |
| SSH/SFTP | dartssh2 |
| 终端 | xterm |
| 本地存储 | drift, shared_preferences, flutter_secure_storage |
| 加密 | AES-256-GCM, Argon2id, pointycastle |
| 网络隧道 | Tailscale tsnet, gomobile AAR |
| 备份同步 | 本地文件夹 / WebDAV |
| 国际化 | flutter_localizations, intl, ARB |
| 更新分发 | GitHub Release API, ota_update |

## 项目结构

```
lib/
├── app/                  # 应用入口、路由、主题
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── l10n/                 # 国际化 (ARB + 生成代码)
├── models/               # 数据模型
├── pages/                # 页面层（按功能模块划分）
│   ├── home/
│   ├── server/
│   ├── terminal/
│   ├── lock/
│   ├── settings/
│   ├── scripts/
│   └── snippets/
├── providers/            # 状态管理 (Riverpod)
├── services/             # 业务逻辑层
├── utils/                # 工具函数
├── widgets/              # 可复用组件库
└── main.dart             # 应用入口
```

## 快速开始

### 前置要求

* Flutter SDK >= 3.41.0
* Dart SDK >= 3.11.0

### 安装步骤

```bash
# 1. 克隆仓库
git clone https://github.com/Gabrlie/orbita.git
cd orbita

# 2. 安装依赖
flutter pub get

# 3. 生成国际化文件
flutter gen-l10n

# 4. 静态分析
flutter analyze
```

### Android 构建

**调试包：**

```bash
flutter build apk --debug
```

**发布包（需配置 keystore）：**

```bash
flutter build apk --release --split-per-abi
```

发布资产命名规范：

```
orbita-{version}-android-{abi}.apk
orbita-{version}-android-{abi}.apk.sha256
```

示例：`orbita-1.1.0-android-arm64-v8a.apk`

## 架构选型

* **SSH/SFTP 层**：dartssh2，纯 Dart 实现，支持密钥认证与代理。
* **状态管理**：Riverpod 3.x，提供编译时安全与细粒度刷新。
* **本地加密**：Argon2id 派生密钥 + AES-256-GCM，备份落盘前即完成加密。
* **在线更新**：通过 GitHub Release API 检测新版本，匹配 ABI 后下载 APK 并校验 SHA256。

## 友链
* [LinuxDO](https://linuxdo.com/) - 是一个真诚、友善、团结、专业的技术社区，汇聚了众多热爱技术、乐于分享的开发者。

## 许可证

本项目基于 MIT 许可证开源，详见 [LICENSE](./LICENSE)。
