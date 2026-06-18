#!/usr/bin/env bash
# test-ai-employee-protocol.sh — AI 员工化协议静态校验
#
# 检查项：
#   1. 每颗星的 SKILL.md 都包含 "## AI 员工身份卡"
#   2. 每颗星（除司衡）的 SKILL.md 都包含 "next_action.md"
#   3. 司衡 SKILL.md 包含 "PMO" 或 "项目协调员" 且包含 "next_action.md"
#   4. docs/AI-EMPLOYEE-PLAYBOOK.md 存在且包含 "ai_employee_mode"
#
# 返回：0 全通过，1 有失败

set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$TESTS_DIR/.." && pwd)"

PASS=0
FAIL=0
ERRORS=()

report() {
  if [ "$1" -eq 0 ]; then
    echo "  [PASS] $2"
    PASS=$((PASS + 1))
  else
    echo "  [FAIL] $2"
    FAIL=$((FAIL + 1))
    ERRORS+=("$2")
  fi
}

echo "----------------------------------------"
echo "AI 员工化协议校验"
echo "----------------------------------------"

# 1. 每颗星 SKILL.md 含 "## AI 员工身份卡"
STARS=(tianshu tianxuan tianji tianquan kaiyang yuheng dongming yinyuan yaoguang siheng)
for star in "${STARS[@]}"; do
  skill_file="$PLUGIN_DIR/skills/$star/SKILL.md"
  if grep -q "## AI 员工身份卡" "$skill_file" 2>/dev/null; then
    report 0 "$star/SKILL.md 含 AI 员工身份卡"
  else
    report 1 "$star/SKILL.md 缺 AI 员工身份卡"
  fi
done

# 2. 每颗星（除司衡）含 "next_action.md"
for star in tianshu tianxuan tianji tianquan kaiyang yuheng dongming yinyuan yaoguang; do
  skill_file="$PLUGIN_DIR/skills/$star/SKILL.md"
  if grep -q "next_action.md" "$skill_file" 2>/dev/null; then
    report 0 "$star/SKILL.md 含 next_action.md 步骤"
  else
    report 1 "$star/SKILL.md 缺 next_action.md 步骤"
  fi
done

# 3. 司衡含 PMO/项目协调员 + next_action.md
siheng_file="$PLUGIN_DIR/skills/siheng/SKILL.md"
if grep -qE "PMO|项目协调员" "$siheng_file" 2>/dev/null; then
  report 0 "siheng/SKILL.md 含 PMO/项目协调员"
else
  report 1 "siheng/SKILL.md 缺 PMO/项目协调员"
fi

if grep -q "next_action.md" "$siheng_file" 2>/dev/null; then
  report 0 "siheng/SKILL.md 含 next_action.md"
else
  report 1 "siheng/SKILL.md 缺 next_action.md"
fi

# 4. playbook 存在且含 ai_employee_mode
playbook="$PLUGIN_DIR/docs/AI-EMPLOYEE-PLAYBOOK.md"
if [ -f "$playbook" ]; then
  report 0 "docs/AI-EMPLOYEE-PLAYBOOK.md 存在"
  if grep -q "ai_employee_mode" "$playbook" 2>/dev/null; then
    report 0 "playbook 含 ai_employee_mode"
  else
    report 1 "playbook 缺 ai_employee_mode"
  fi
else
  report 1 "docs/AI-EMPLOYEE-PLAYBOOK.md 不存在"
  report 1 "playbook 缺 ai_employee_mode（文件不存在）"
fi

echo ""
echo "========================================"
echo "AI 员工化协议校验汇总"
echo "========================================"
echo "  通过: $PASS"
echo "  失败: $FAIL"
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "  失败项:"
  for e in "${ERRORS[@]}"; do
    echo "    - $e"
  done
fi
echo ""

if [ "$FAIL" -gt 0 ]; then
  echo "状态: FAILED"
  exit 1
else
  echo "状态: PASSED"
  exit 0
fi
