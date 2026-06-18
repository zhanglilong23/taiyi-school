#!/usr/bin/env bash
# test-skill-prompt.sh — 校验所有 SKILL.md 的“完成后”章节是否含标准提示语
#
# 标准格式：[太一流转] ... 已...
# 未命中的 SKILL 列入偏离清单，不强制修改正文。
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== SKILL 完成后标准提示语校验 ==="

# 偏离清单（未命中 SKILL）
DEVIATIONS=()

# 先收集所有 SKILL 文件，避免进程替换在命令替换中死锁
SKILL_FILES=$(list_skills)

while IFS= read -r file; do
  [ -z "$file" ] && continue
  rel="${file#$PLUGIN_DIR/}"
  dir_name="$(basename "$(dirname "$file")")"

  # 提取 "## 完成后" 章节：从该标题到下一个 ## 标题或文件末尾
  section=$(sed -n '/^## 完成后/,/^## /p' "$file" | sed '1d;$d')

  if [ -z "$section" ]; then
    fail "$rel (无 '## 完成后' 章节)"
    DEVIATIONS+=("$dir_name: 缺少 '## 完成后' 章节")
    continue
  fi

  # 检查是否含 [太一流转] 格式标准提示语
  if echo "$section" | grep -q '\[太一流转\]'; then
    pass "$rel (标准提示语已命中)"
  else
    fail "$rel (完成后章节未命中 [太一流转] 标准提示语)"
    DEVIATIONS+=("$dir_name: 完成后章节未命中 [太一流转] 标准提示语")
  fi
done <<< "$SKILL_FILES"

# 避免 summary 的 return 1 触发 set -e 提前退出
set +e
summary "skill-prompt"
set -e

# 输出偏离清单（如有）
if [ ${#DEVIATIONS[@]} -gt 0 ]; then
  echo ""
  echo "=== 偏离清单（未命中 SKILL，待后续 TASK 处理）==="
  for d in "${DEVIATIONS[@]}"; do
    echo "  - $d"
  done
fi

# 本次契约允许偏离（不修改 SKILL 正文），故脚本返回 0
exit 0
