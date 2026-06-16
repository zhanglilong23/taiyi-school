#!/usr/bin/env bash
# test-methodology-terms.sh — 方法论增强术语校验（防误删守卫）
#
# 本轮工程化新增的三项方法论增强，必须留在对应 SKILL 里。
# 本测试是它们的静态守卫——被误删时立即报警。
#
# 增强项 → 落点 → 关键术语：
#   复盘四步法 → dongming + epic-template → "强制四步复盘" + "可复用 SOP"
#   接单军令状 → tianquan + kaiyang       → "接单军令状" + "自我加压"
#   蓝军前置   → tianxuan                 → "蓝军前置"
#   蓝军前置   → tianquan（开工盘点第6问） → "返工"
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== 方法论增强术语校验 ==="

check_term() {
  local file="$1" term="$2" desc="$3"
  local rel="${file#$PLUGIN_DIR/}"
  if grep -qF "$term" "$file" 2>/dev/null; then
    pass "$rel 含 '$term' ($desc)"
  else
    fail "$rel 缺 '$term' ($desc 被误删?)"
  fi
}

# --- 复盘四步法 ---
echo "  -- 复盘四步法 --"
check_term "$PLUGIN_DIR/skills/dongming/SKILL.md" "强制四步复盘" "洞明归档 SOP"
check_term "$PLUGIN_DIR/skills/dongming/SKILL.md" "可复用 SOP" "复盘产物要求"
# epic-template 现在自包含在 tianshu 和 tianxuan 各一份，校验任一副本（一致性由 test-references.sh 守）
check_term "$PLUGIN_DIR/skills/tianxuan/references/epic-template.md" "目标回顾" "epic 模板复盘表"
check_term "$PLUGIN_DIR/skills/tianxuan/references/epic-template.md" "可复用 SOP" "epic 模板复盘表"

# --- 接单军令状 ---
echo "  -- 接单军令状 --"
check_term "$PLUGIN_DIR/skills/tianquan/SKILL.md" "接单军令状" "天权开工承诺"
check_term "$PLUGIN_DIR/skills/tianquan/SKILL.md" "自我加压" "军令状措辞底线"
check_term "$PLUGIN_DIR/skills/kaiyang/SKILL.md" "接单军令状" "开阳开工承诺"
check_term "$PLUGIN_DIR/skills/kaiyang/SKILL.md" "自我加压" "军令状措辞底线"

# --- 蓝军前置 ---
echo "  -- 蓝军前置 --"
check_term "$PLUGIN_DIR/skills/tianxuan/SKILL.md" "蓝军前置" "天璇定设计后自攻"
check_term "$PLUGIN_DIR/skills/tianquan/SKILL.md" "返工" "天权开工盘点第6问"

# --- 措辞底线：军令状不得含羞辱性施压 ---
# 例外："不学羞辱性施压"是军令状的反例声明（合规），需排除"不X羞辱"模式。
echo "  -- 军令状措辞底线 --"
# 先剔除反例行（含 不学/不含/拒绝 + 羞辱），再扫描剩余正文
TQ_FILTERED="$(grep -vE "不学|不含|拒绝.*羞辱" "$PLUGIN_DIR/skills/tianquan/SKILL.md" 2>/dev/null || true)"
KY_FILTERED="$(grep -vE "不学|不含|拒绝.*羞辱" "$PLUGIN_DIR/skills/kaiyang/SKILL.md" 2>/dev/null || true)"
if echo "$TQ_FILTERED $KY_FILTERED" | grep -qE "毕业|3\.25|羞辱|谩骂"; then
  fail "军令状含 pua 式羞辱性施压措辞（违反太一反谄媚底线）"
else
  pass "军令状无羞辱性施压措辞（守住反谄媚底线）"
fi

summary "methodology-terms"
