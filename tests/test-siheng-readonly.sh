#!/usr/bin/env bash
# test-siheng-readonly.sh — 司衡纯只读宪法校验（核心守卫）
#
# 司衡 SKILL 第 13/32 行声明"不写任何文件"是宪法级约束。
# 本测试是这承诺的静态守卫：扫描司衡 SKILL 正文，确保不含写文件的指令性措辞。
#
# 例外：## 验证 段落下的 bash 命令允许只读操作（cat/ls/test -f 等）。
# 但即便在验证段，也不应出现 Write/Edit/mkdir 等写动作。
#
# 借鉴 pua evals 的"文件存在性 + 关键术语存在/缺失"双校验模式。
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== 司衡纯只读宪法校验 ==="

SIHENG="$PLUGIN_DIR/skills/siheng/SKILL.md"

if [ ! -f "$SIHENG" ]; then
  fail "找不到 $SIHENG"
  summary "siheng-readonly"
  exit 1
fi

content="$(cat "$SIHENG")"

# 写动作关键词（出现在正文 = 违宪）
WRITE_ACTIONS="Write|MultiEdit|mkdir -p|touch |tee >>|git push|git commit|git add"

# 第一步过滤：剔除验证段（## 验证 到文件尾）——那里描述"如何验证司衡只读"，
# 会出现"确认 siheng SKILL 不含 Write/Edit/mkdir"这种元描述，是合法的反例。
content_no_verify="$(echo "$content" | sed '/^## 验证/,$d' || true)"

# 第二步过滤：剔除"反例行"——司衡明确声明"不做"的动作（含 ❌ 或 不X）。
# 如"❌ 不写代码""不承诺及时发现僵尸""不学羞辱性施压"都是合规的反例。
ALLOWED_NEGATIVE="❌|不写|不做|不创建|不审查|不诊断|不设计|不拆解|不判需求|不仲裁|不承诺|不含|不学"
content_filtered="$(echo "$content_no_verify" | grep -vE "$ALLOWED_NEGATIVE" || true)"

# 扫描写动作
violations="$(echo "$content_filtered" | grep -nE "$WRITE_ACTIONS" || true)"

if [ -n "$violations" ]; then
  while IFS= read -r line; do
    fail "违宪行: $line"
  done <<< "$violations"
else
  pass "司衡 SKILL 正文无写文件指令（宪法承诺成立）"
fi

# 正向校验：必须含"不写任何文件"或"纯只读"承诺
if echo "$content" | grep -qE "不写任何文件|纯只读"; then
  pass "司衡 SKILL 含'不写任何文件/纯只读'承诺声明"
else
  fail "司衡 SKILL 缺'不写任何文件/纯只读'承诺声明"
fi

summary "siheng-readonly"
