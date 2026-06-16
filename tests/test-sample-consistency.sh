#!/usr/bin/env bash
# test-sample-consistency.sh — 校验 auth-mvp 演示样本状态机自洽
#
# 演示样本是"门禁可机检"承诺的活样本，自身必须过门禁。
# 校验项：
#   1. auth-mvp/epic.md frontmatter status 与 review verdict 一致（completed ↔ pass）
#   2. INDEX.md 已归档区登记了该 Epic
#   3. Task 列表所有 Task 状态 = done
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

EPIC_DIR="$PLUGIN_DIR/.taiyi/epics/auth-mvp"
EPIC_MD="$EPIC_DIR/epic.md"
REVIEW_MD="$EPIC_DIR/reports/TASK-001/review.md"
INDEX_MD="$PLUGIN_DIR/.taiyi/INDEX.md"

echo "=== auth-mvp 演示样本状态机自洽 ==="

# 校验1：epic.md frontmatter status = completed
if grep -q "^status: completed" "$EPIC_MD" 2>/dev/null; then
  pass "epic.md frontmatter status=completed"
else
  fail "epic.md frontmatter status 应为 completed（演示样本已归档）"
fi

# 校验2：review.md verdict = pass，与 epic status 一致
if grep -q "^verdict: pass" "$REVIEW_MD" 2>/dev/null; then
  pass "review.md verdict=pass（与 epic completed 一致）"
else
  fail "review.md verdict 应为 pass（与 epic completed 一致）"
fi

# 校验3：INDEX.md 已归档 Epic 区登记 auth-mvp
if grep -q "^| auth-mvp |" "$INDEX_MD" 2>/dev/null; then
  # 确认在"已归档 Epic"区（非活跃区）—— 检查 auth-mvp 行后是否在已归档标题之后
  archive_line=$(grep -n "^## 已归档 Epic" "$INDEX_MD" | head -1 | cut -d: -f1)
  auth_line=$(grep -n "^| auth-mvp |" "$INDEX_MD" | head -1 | cut -d: -f1)
  if [ -n "$archive_line" ] && [ -n "$auth_line" ] && [ "$auth_line" -gt "$archive_line" ]; then
    pass "INDEX.md 已归档 Epic 区登记 auth-mvp"
  else
    fail "auth-mvp 应在 INDEX.md '已归档 Epic' 区（当前可能在活跃区或未登记）"
  fi
else
  fail "INDEX.md 应在已归档 Epic 区登记 auth-mvp"
fi

# 校验4：INDEX.md 已归档需求区登记 REQ-001
# 注意：需求索引区也可能有 REQ-001 行，须确认在"已归档需求"标题之后
if grep -q "^| REQ-001 |" "$INDEX_MD" 2>/dev/null; then
  req_archive_line=$(grep -n "^## 已归档需求" "$INDEX_MD" | head -1 | cut -d: -f1)
  # 取最后一个 REQ-001 行（已归档需求区在文件后部，该区内的行行号最大）
  req_line=$(grep -n "^| REQ-001 |" "$INDEX_MD" | tail -1 | cut -d: -f1)
  if [ -n "$req_archive_line" ] && [ -n "$req_line" ] && [ "$req_line" -gt "$req_archive_line" ]; then
    pass "INDEX.md 已归档需求区登记 REQ-001"
  else
    fail "REQ-001 应在 INDEX.md '已归档需求' 区（当前 REQ-001 仅在需求索引区）"
  fi
else
  fail "INDEX.md 应在已归档需求区登记 REQ-001"
fi

# 校验5：epic.md Task 列表所有 Task 状态 = done
if grep -qE "^\| TASK-001 \|.*✅ done" "$EPIC_MD" 2>/dev/null; then
  pass "epic.md Task 列表 TASK-001 状态=done"
else
  fail "epic.md Task 列表 TASK-001 应为 done"
fi

summary "sample-consistency"
