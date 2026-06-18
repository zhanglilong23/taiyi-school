#!/usr/bin/env bash
# test-helpers.sh — 静态测试公共工具
# 借鉴 superpowers/tests/claude-code/test-helpers.sh 与 pua/evals/test-helpers.sh
#
# 用法：在子测试脚本里 `source "$(dirname "$0")/test-helpers.sh"`
set -euo pipefail

# 解析项目根（tests/ 的上一级）
TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_DIR="$(cd "$TESTS_DIR/.." && pwd)"
export PLUGIN_DIR

# 计数器（子脚本通过这些函数上报）
TESTS_PASS=0
TESTS_FAIL=0
TESTS_SKIP=0

pass() {
  echo "  [PASS] $1"
  TESTS_PASS=$((TESTS_PASS + 1))
}

fail() {
  echo "  [FAIL] $1"
  TESTS_FAIL=$((TESTS_FAIL + 1))
}

skip() {
  echo "  [SKIP] $1"
  TESTS_SKIP=$((TESTS_SKIP + 1))
}

# fail-pass 模式：脚本末尾汇总，失败时退出非零（CI 可捕获）
summary() {
  local name="$1"
  echo ""
  echo "  $name: pass=$TESTS_PASS fail=$TESTS_FAIL skip=$TESTS_SKIP"
  if [ "$TESTS_FAIL" -gt 0 ]; then
    return 1
  fi
  return 0
}

# 列出所有 SKILL.md（排除 node_modules 等）
list_skills() {
  find "$PLUGIN_DIR/skills" -name "SKILL.md" -not -path "*/node_modules/*" 2>/dev/null
}

# 从 SKILL.md 提取 frontmatter（去掉首尾 ---）
get_frontmatter() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" | sed '1d;$d'
}

# UTF-8 字符计数（Windows Git Bash 下 ${#var} 按字节计数，故用 python 兜底）
utf8_len() {
  local s="$1"
  python -c "import sys; print(len(sys.argv[1]))" "$s"
}
