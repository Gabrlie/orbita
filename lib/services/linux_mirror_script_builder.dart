const linuxMirrorScriptId = 'change-linux-mirror';

String buildLinuxMirrorCommand({
  required String selectTitle,
  required String tunaLabel,
  required String ustcLabel,
  required String aliyunLabel,
  required String tencentLabel,
  required String huaweiLabel,
}) {
  return _linuxMirrorScript
      .replaceAll('__ORBITA_MIRROR_SELECT_TITLE__', _escape(selectTitle))
      .replaceAll('__ORBITA_MIRROR_TUNA__', _escape(tunaLabel))
      .replaceAll('__ORBITA_MIRROR_USTC__', _escape(ustcLabel))
      .replaceAll('__ORBITA_MIRROR_ALIYUN__', _escape(aliyunLabel))
      .replaceAll('__ORBITA_MIRROR_TENCENT__', _escape(tencentLabel))
      .replaceAll('__ORBITA_MIRROR_HUAWEI__', _escape(huaweiLabel));
}

String _escape(String value) {
  return value.replaceAll('\\', r'\\').replaceAll('"', r'\"');
}

const _linuxMirrorScript = r'''
# orbita:select name=MIRROR title="__ORBITA_MIRROR_SELECT_TITLE__"
# orbita:option name=MIRROR label="__ORBITA_MIRROR_TUNA__" value="https://mirrors.tuna.tsinghua.edu.cn"
# orbita:option name=MIRROR label="__ORBITA_MIRROR_USTC__" value="https://mirrors.ustc.edu.cn"
# orbita:option name=MIRROR label="__ORBITA_MIRROR_ALIYUN__" value="https://mirrors.aliyun.com"
# orbita:option name=MIRROR label="__ORBITA_MIRROR_TENCENT__" value="https://mirrors.cloud.tencent.com"
# orbita:option name=MIRROR label="__ORBITA_MIRROR_HUAWEI__" value="https://repo.huaweicloud.com"
if [ "$(id -u)" = "0" ]; then SUDO=""; else SUDO="sudo"; fi
MIRROR={{MIRROR}}
if [ ! -r /etc/os-release ]; then
  printf 'Unsupported system: /etc/os-release not found\n'
  exit 127
fi
. /etc/os-release
ID_LIKE="${ID_LIKE:-}"
VERSION_MAJOR="${VERSION_ID%%.*}"
CODE="${VERSION_CODENAME:-${UBUNTU_CODENAME:-}}"
stamp="$(date +%Y%m%d%H%M%S)"
backup_file() {
  if [ -f "$1" ]; then $SUDO cp "$1" "$1.orbita.$stamp.bak"; fi
}
write_file() {
  path="$1"
  content="$2"
  printf '%s\n' "$content" | $SUDO tee "$path" >/dev/null
}
refresh_cache() {
  if command -v apt-get >/dev/null 2>&1; then $SUDO apt-get update
  elif command -v dnf >/dev/null 2>&1; then $SUDO dnf makecache
  elif command -v yum >/dev/null 2>&1; then $SUDO yum makecache
  elif command -v pacman >/dev/null 2>&1; then $SUDO pacman -Syy --noconfirm
  elif command -v apk >/dev/null 2>&1; then $SUDO apk update
  elif command -v zypper >/dev/null 2>&1; then $SUDO zypper --non-interactive refresh
  fi
}
case "$ID" in
  ubuntu)
    if [ -z "$CODE" ]; then printf 'Unsupported Ubuntu: codename missing\n'; exit 127; fi
    backup_file /etc/apt/sources.list
    write_file /etc/apt/sources.list "deb $MIRROR/ubuntu/ $CODE main restricted universe multiverse
deb $MIRROR/ubuntu/ $CODE-updates main restricted universe multiverse
deb $MIRROR/ubuntu/ $CODE-backports main restricted universe multiverse
deb $MIRROR/ubuntu/ $CODE-security main restricted universe multiverse"
    ;;
  debian)
    if [ -z "$CODE" ]; then
      case "$VERSION_MAJOR" in
        9) CODE=stretch ;; 10) CODE=buster ;; 11) CODE=bullseye ;;
        12) CODE=bookworm ;; 13) CODE=trixie ;;
      esac
    fi
    if [ -z "$CODE" ]; then printf 'Unsupported Debian: codename missing\n'; exit 127; fi
    if [ "${VERSION_MAJOR:-0}" -ge 12 ] 2>/dev/null; then
      components="main contrib non-free non-free-firmware"
      security_suite="$CODE-security"
    else
      components="main contrib non-free"
      security_suite="$CODE/updates"
    fi
    backup_file /etc/apt/sources.list
    write_file /etc/apt/sources.list "deb $MIRROR/debian/ $CODE $components
deb $MIRROR/debian/ $CODE-updates $components
deb $MIRROR/debian-security/ $security_suite $components"
    ;;
  centos)
    $SUDO mkdir -p /etc/yum.repos.d/orbita-backup-$stamp
    $SUDO sh -c 'mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/orbita-backup-'"$stamp"'/ 2>/dev/null || true'
    if printf '%s' "$PRETTY_NAME" | grep -qi stream; then
      base="$MIRROR/centos-stream/\$stream"
      write_file /etc/yum.repos.d/orbita-centos.repo "[BaseOS]
name=CentOS Stream BaseOS
baseurl=$base/BaseOS/\$basearch/os/
enabled=1
gpgcheck=0
[AppStream]
name=CentOS Stream AppStream
baseurl=$base/AppStream/\$basearch/os/
enabled=1
gpgcheck=0"
    elif [ "${VERSION_MAJOR:-0}" -ge 8 ] 2>/dev/null; then
      base="$MIRROR/centos-vault/\$releasever"
      write_file /etc/yum.repos.d/orbita-centos.repo "[BaseOS]
name=CentOS Vault BaseOS
baseurl=$base/BaseOS/\$basearch/os/
enabled=1
gpgcheck=0
[AppStream]
name=CentOS Vault AppStream
baseurl=$base/AppStream/\$basearch/os/
enabled=1
gpgcheck=0"
    else
      base="$MIRROR/centos/\$releasever"
      write_file /etc/yum.repos.d/orbita-centos.repo "[base]
name=CentOS Base
baseurl=$base/os/\$basearch/
enabled=1
gpgcheck=0
[updates]
name=CentOS Updates
baseurl=$base/updates/\$basearch/
enabled=1
gpgcheck=0"
    fi
    ;;
  rocky|almalinux|fedora|openEuler|openeuler)
    repo_id="$ID"
    [ "$ID" = "openEuler" ] && repo_id="openeuler"
    $SUDO mkdir -p /etc/yum.repos.d/orbita-backup-$stamp
    $SUDO sh -c 'mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/orbita-backup-'"$stamp"'/ 2>/dev/null || true'
    case "$repo_id" in
      rocky|almalinux)
        path="$MIRROR/$repo_id/\$releasever"
        write_file /etc/yum.repos.d/orbita-$repo_id.repo "[BaseOS]
name=$repo_id BaseOS
baseurl=$path/BaseOS/\$basearch/os/
enabled=1
gpgcheck=0
[AppStream]
name=$repo_id AppStream
baseurl=$path/AppStream/\$basearch/os/
enabled=1
gpgcheck=0"
        ;;
      fedora)
        write_file /etc/yum.repos.d/orbita-fedora.repo "[fedora]
name=Fedora
baseurl=$MIRROR/fedora/releases/\$releasever/Everything/\$basearch/os/
enabled=1
gpgcheck=0
[updates]
name=Fedora Updates
baseurl=$MIRROR/fedora/updates/\$releasever/Everything/\$basearch/
enabled=1
gpgcheck=0"
        ;;
      openeuler)
        write_file /etc/yum.repos.d/orbita-openeuler.repo "[OS]
name=openEuler OS
baseurl=$MIRROR/openeuler/openEuler-\$releasever/OS/\$basearch/
enabled=1
gpgcheck=0"
        ;;
    esac
    ;;
  alpine)
    branch="v$(printf '%s' "$VERSION_ID" | awk -F. '{print $1"."$2}')"
    backup_file /etc/apk/repositories
    write_file /etc/apk/repositories "$MIRROR/alpine/$branch/main
$MIRROR/alpine/$branch/community"
    ;;
  arch)
    backup_file /etc/pacman.d/mirrorlist
    write_file /etc/pacman.d/mirrorlist "Server = $MIRROR/archlinux/\$repo/os/\$arch"
    ;;
  opensuse-*|sles)
    $SUDO mkdir -p /etc/zypp/repos.d/orbita-backup-$stamp
    $SUDO sh -c 'mv /etc/zypp/repos.d/*.repo /etc/zypp/repos.d/orbita-backup-'"$stamp"'/ 2>/dev/null || true'
    if [ "$ID" = "opensuse-tumbleweed" ]; then
      base="$MIRROR/opensuse/tumbleweed/repo/oss/"
      update="$MIRROR/opensuse/update/tumbleweed/"
    else
      base="$MIRROR/opensuse/distribution/leap/$VERSION_ID/repo/oss/"
      update="$MIRROR/opensuse/update/leap/$VERSION_ID/oss/"
    fi
    write_file /etc/zypp/repos.d/orbita-opensuse.repo "[repo-oss]
name=openSUSE OSS
baseurl=$base
enabled=1
gpgcheck=0
[repo-update]
name=openSUSE Update
baseurl=$update
enabled=1
gpgcheck=0"
    ;;
  *)
    case " $ID_LIKE " in
      *" debian "*) printf 'Unsupported Debian-like ID: %s\n' "$ID"; exit 127 ;;
      *" rhel "*|*" fedora "*) printf 'Unsupported RHEL-like ID: %s\n' "$ID"; exit 127 ;;
      *) printf 'Unsupported system: %s\n' "$ID"; exit 127 ;;
    esac
    ;;
esac
refresh_cache
printf 'Mirror switched to %s for %s %s\n' "$MIRROR" "$ID" "${VERSION_ID:-}"
''';
