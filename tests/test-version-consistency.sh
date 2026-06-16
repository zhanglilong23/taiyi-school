#!/usr/bin/env bash
# test-version-consistency.sh — 版本一致性校验
#
# 借鉴 pua/evals/test-release-consistency.sh 的"多 manifest 版本一致"思路。
# 复用 scripts/bump-version.sh 的 --check 模式（单一真源原则）。
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== 版本一致性校验 ==="

# 1. .version-bump.json 存在
if [ -f "$PLUGIN_DIR/.version-bump.json" ]; then
  pass ".version-bump.json 存在"
else
  fail ".version-bump.json 不存在"
fi

# 2. bump-version.sh 存在且可执行
if [ -f "$PLUGIN_DIR/scripts/bump-version.sh" ]; then
  pass "scripts/bump-version.sh 存在"
else
  fail "scripts/bump-version.sh 不存在"
fi

# 3. 跑 bump-version --check（核心校验，复用其逻辑）
echo ""
echo "  --- 调用 bump-version.sh --check ---"
if bash "$PLUGIN_DIR/scripts/bump-version.sh" --check >/tmp/taiyi-version-check.out 2>&1; then
  pass "bump-version --check 通过（所有声明字段一致）"
  # 显示简短摘要
  grep "结果:" /tmp/taiyi-version-check.out | sed 's/^/    /'
else
  fail "bump-version --check 失败"
  cat /tmp/taiyi-version-check.out | sed 's/^/    /'
fi
rm -f /tmp/taiyi-version-check.out

# 4. plugin.json name 字段 = 项目目录名
if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  plugin_name="$(python3 -c "import json;print(json.load(open('.claude-plugin/plugin.json'))['name'])" 2>/dev/null || true)"
  dir_name="$(basename "$PLUGIN_DIR")"
  if [ "$plugin_name" = "$dir_name" ]; then
    pass "plugin.json name='$plugin_name' 与目录名一致"
  else
    fail "plugin.json name='$plugin_name' 与目录名 '$dir_name' 不一致"
  fi
fi

summary "version-consistency"
