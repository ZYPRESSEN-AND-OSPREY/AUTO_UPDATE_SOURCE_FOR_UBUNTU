#!/bin/bash

# 检测发行版类型
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        case "$ID" in
            ubuntu)
                echo "ubuntu"
                ;;
            kali)
                echo "kali"
                ;;
            debian)
                echo "debian"
                ;;
            *)
                echo "unknown"
                ;;
        esac
    else
        echo "unknown"
    fi
}

backup_and_comment_sources() {
    local source_file="$1"
    if [ -f "$source_file" ]; then
        cp "$source_file" "$source_file.bak.$(date +%Y%m%d%H%M%S)"
        sed -i 's/^\([^#]\)/#\1/' "$source_file"
    fi
}

# 更新源
update_sources() {
    local distro="$1"
    local source_file="/etc/apt/sources.list"

    # 先备份并注释掉旧的源
    backup_and_comment_sources "$source_file"

    # 根据发行版添加阿里云源
    case "$distro" in
        ubuntu)
            cat <<EOF > "$source_file"
deb http://mirrors.aliyun.com/ubuntu/ focal main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-security main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-updates main restricted universe multiverse
deb http://mirrors.aliyun.com/ubuntu/ focal-backports main restricted universe multiverse
EOF
            ;;
        kali)
            cat <<EOF > "$source_file"
deb http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
deb-src http://mirrors.aliyun.com/kali kali-rolling main non-free contrib
EOF
            ;;
        debian)
            cat <<EOF > "$source_file"
deb http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster main non-free contrib
deb http://mirrors.aliyun.com/debian-security buster/updates main
deb-src http://mirrors.aliyun.com/debian-security buster/updates main
deb http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-updates main non-free contrib
deb http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
deb-src http://mirrors.aliyun.com/debian/ buster-backports main non-free contrib
EOF
            ;;
        *)
            echo "未知的发行版，无法更新源"
            return 1
            ;;
    esac
}

# 主程序
distro=$(detect_distro)
if [ "$distro" = "unknown" ]; then
    echo "无法检测系统的发行版，脚本退出"
    exit 1
fi

echo "检测到的发行版：$distro"
update_sources "$distro"
echo "源更新完成！"
