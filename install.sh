#!/usr/bin/env bash
# lyco_dev (/dev) skill 一键安装脚本
# 用法:
#   bash install.sh [dsh|opencode|claude]   # 单装（默认 all: 三个主环境）
#   bash install.sh --all-agents            # 全支持: 用 skills CLI 装到 60+ agent
set -euo pipefail

SKILL_NAME="lyco_dev"
REPO_URL="https://github.com/lilyco-42/lyco_dev.git"
TARBALL_URL="https://github.com/lilyco-42/lyco_dev/archive/refs/heads/main.tar.gz"

declare -A TARGETS=(
  [dsh]="$HOME/.agents/skills/$SKILL_NAME"
  [opencode]="$HOME/.config/opencode/skills/$SKILL_NAME"
  [claude]="$HOME/.claude/skills/$SKILL_NAME"
)

info() { printf '\033[32m[lyco_dev]\033[0m %s\n' "$*"; }
warn() { printf '\033[33m[lyco_dev]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[31m[lyco_dev] 失败: %s\033[0m\n' "$*" >&2; exit 1; }

fetch_src() {
    local src; src="$(mktemp -d)"
    if command -v git >/dev/null 2>&1; then
        git clone --depth 1 "$REPO_URL" "$src/repo" >/dev/null 2>&1 \
            || die "git clone 失败，请检查网络/代理"
        mv "$src/repo" "$src/skill"
    elif command -v curl >/dev/null 2>&1; then
        curl -fsSL "$TARBALL_URL" -o "$src/lyco_dev.tar.gz" || die "tarball 下载失败"
        tar -xzf "$src/lyco_dev.tar.gz" -C "$src"
        mv "$src/lyco_dev-main" "$src/skill"
    else
        die "既没有 git 也没有 curl，无法安装"
    fi
    mkdir -p "$src/body"
    cp -r "$src/skill/SKILL.md" "$src/body/"
    [[ -d "$src/skill/resources" ]] && cp -r "$src/skill/resources" "$src/body/"
    [[ -d "$src/skill/docs" ]] && cp -r "$src/skill/docs" "$src/body/"
    printf '%s' "$src/body"
}

install_one() {
    local agent="$1" target="$2" src="$3"
    mkdir -p "$(dirname "$target")"
    rm -rf "$target"
    cp -r "$src" "$target"
    if [[ -f "$target/SKILL.md" ]] && grep -q "^name: $SKILL_NAME$" "$target/SKILL.md"; then
        info "✓ $agent -> $target (校验通过)"
    else
        warn "✗ $agent -> $target (SKILL.md 校验失败)"
    fi
}

AGENT="${1:-all}"

if [[ "$AGENT" == "--all-agents" ]]; then
    if command -v skills >/dev/null 2>&1; then
        skills add lilyco-42/lyco_dev --global --agent '*' --yes
    elif command -v npx >/dev/null 2>&1; then
        info "未检测到 skills CLI，通过 npx 运行。"
        npx --yes skills add lilyco-42/lyco_dev --global --agent '*' --yes
    else
        die "全支持模式需要 skills CLI 或 Node.js/npx"
    fi
    info "已装到所有支持的 agent。"
    exit 0
fi

SRC="$(fetch_src)"

case "$AGENT" in
    dsh)      install_one dsh      "${TARGETS[dsh]}"      "$SRC" ;;
    opencode) install_one opencode "${TARGETS[opencode]}" "$SRC" ;;
    claude)   install_one claude   "${TARGETS[claude]}"   "$SRC" ;;
    all)
        for k in dsh opencode claude; do
            install_one "$k" "${TARGETS[$k]}" "$SRC"
        done
        ;;
    *) die "未知目标: $AGENT（可选: dsh | opencode | claude | all | --all-agents）" ;;
esac
