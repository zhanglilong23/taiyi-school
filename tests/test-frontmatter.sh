#!/usr/bin/env bash
# test-frontmatter.sh — 校验所有 SKILL.md 的 frontmatter
#
# 借鉴 pua/evals/test-yaml-frontmatter.sh
# 校验项：
#   1. frontmatter 合法（有 --- 包裹）
#   2. name 字段匹配目录名（skills/<name>/SKILL.md）
#   3. description ≤60 字符（SKILL-AUTHORING 硬约束）
#   4. description 不含营销词（powerful/comprehensive/seamless/强大/全面/强大）
#   5. description 含冒号时已加引号
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== frontmatter 校验 ==="

MARKETING_WORDS="powerful|comprehensive|seamless|advanced|强大|全面|极致|完美|领先"

while IFS= read -r file; do
  rel="${file#$PLUGIN_DIR/}"
  dir_name="$(basename "$(dirname "$file")")"

  # 1. frontmatter 存在
  fm="$(get_frontmatter "$file")"
  if [ -z "$fm" ]; then
    fail "$rel (无 frontmatter)"
    continue
  fi

  # 2. name 字段匹配目录名
  name_line="$(echo "$fm" | grep -E "^name:" || true)"
  if [ -z "$name_line" ]; then
    fail "$rel (缺 name 字段)"
    continue
  fi
  name_val="$(echo "$name_line" | sed -E "s/^name:[[:space:]]*//" | tr -d '"'\''')"
  if [ "$name_val" != "$dir_name" ]; then
    fail "$rel (name='$name_val' 与目录名 '$dir_name' 不一致)"
    continue
  fi

  # 3 + 5. description 校验
  desc_line="$(echo "$fm" | grep -E "^description:" || true)"
  if [ -z "$desc_line" ]; then
    fail "$rel (缺 description)"
    continue
  fi
  desc_val="$(echo "$desc_line" | sed -E "s/^description:[[:space:]]*//")"
  # 去掉外层引号后算长度
  desc_unquoted="$(echo "$desc_val" | sed -E "s/^\"(.*)\"\$/\1/" | sed -E "s/^'(.*)'\$/\1/")"
  desc_len=$(utf8_len "$desc_unquoted")

  # 4. 营销词
  if echo "$desc_unquoted" | grep -Eiq "$MARKETING_WORDS"; then
    fail "$rel (description 含营销词: $(echo "$desc_unquoted" | grep -Eio "$MARKETING_WORDS" | tr "\n" ","))"
    continue
  fi

  # 3. 长度（60 字符硬约束）
  if [ "$desc_len" -gt 60 ]; then
    fail "$rel (description $desc_len 字符（UTF-8）> 60: $desc_unquoted)"
    continue
  fi

  # 5. 冒号引号：含冒号但未引号（防 YAML 解析错误）
  if echo "$desc_val" | grep -q ":" && ! echo "$desc_val" | grep -qE "^\"|^'"; then
    fail "$rel (description 含冒号但未加引号: $desc_val)"
    continue
  fi

  pass "$rel ($desc_len 字符（UTF-8）)"
done < <(list_skills)

summary "frontmatter"
