#!/usr/bin/env bash
# test-references.sh — 校验 SKILL 引用的 references 路径真实存在 + 术语一致
#
# 校验项：
#   1. 每个 SKILL 引用的 references/xxx-template.md 真实存在
#   2. _shared/references/ 下的模板被正确引用
#   3. CONTEXT.md 里写的"专属 vs 共享"归属与实际文件匹配
set -euo pipefail
TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$TESTS_DIR/test-helpers.sh"

echo "=== references 路径一致性 ==="

while IFS= read -r file; do
  rel="${file#$PLUGIN_DIR/}"
  star_dir="$(dirname "$file")"

  # 提取所有 `references/xxx-template.md` 引用
  refs="$(grep -oE "references/[A-Za-z0-9_-]+\.md" "$file" 2>/dev/null | sort -u || true)"
  if [ -z "$refs" ]; then
    # 无引用不报错（setup SKILL 可能不引用模板）
    continue
  fi

  while IFS= read -r ref; do
    ref="${ref#references/}"
    # 路径可能是相对本星，也可能是 _shared
    local_path="$star_dir/references/$ref"
    shared_path="$PLUGIN_DIR/skills/_shared/references/$ref"

    if [ -f "$local_path" ]; then
      pass "$rel → references/$ref (专属)"
    elif [ -f "$shared_path" ]; then
      pass "$rel → references/$ref (共享 _shared)"
    else
      fail "$rel → references/$ref (找不到，本地与 _shared 都没有)"
    fi
  done <<< "$refs"
done < <(list_skills)

# 校验多星共用模板的副本一致性（技能自包含原则：各星各存一份，内容必须相同）
# impl-template: 天权 + 开阳 各一份；epic-template: 天枢 + 天璇 各一份
echo ""
echo "=== 多星共用模板副本一致性 ==="

check_replica_consistency() {
  local tmpl="$1"
  shift
  local files=("$@")
  if [ "${#files[@]}" -lt 2 ]; then
    return
  fi
  local first="${files[0]}"
  if [ ! -f "$first" ]; then
    fail "$tmpl 副本缺失: $first"
    return
  fi
  local all_same=1
  for f in "${files[@]:1}"; do
    if [ ! -f "$f" ]; then
      fail "$tmpl 副本缺失: $f"
      all_same=0
      continue
    fi
    if ! diff -q "$first" "$f" >/dev/null 2>&1; then
      fail "$tmpl 副本不一致: $first vs $f（改模板时漏同步副本）"
      all_same=0
    fi
  done
  if [ "$all_same" -eq 1 ]; then
    local n="${#files[@]}"
    local rels=""
    for f in "${files[@]}"; do rels="$rels ${f#$PLUGIN_DIR/skills/}"; done
    pass "$tmpl $n 份副本一致:$rels"
  fi
}

check_replica_consistency "impl-template" \
  "$PLUGIN_DIR/skills/tianquan/references/impl-template.md" \
  "$PLUGIN_DIR/skills/kaiyang/references/impl-template.md"

check_replica_consistency "epic-template" \
  "$PLUGIN_DIR/skills/tianshu/references/epic-template.md" \
  "$PLUGIN_DIR/skills/tianxuan/references/epic-template.md"

# 校验九星邻接表副本一致性（技能自包含：9 颗执行星各存一份，内容须逐字一致）
# 司衡不含邻接表（它有自己的路由表），不参与本校验
echo ""
echo "=== 九星邻接表副本一致性（9 执行星，不含司衡）==="

# 9 颗执行星 SKILL.md（司衡 siheng 不含邻接表）
ADJACENCY_STARS=(
  tianshu tianxuan tianji tianquan kaiyang
  yuheng dongming yinyuan yaoguang
)

# 从 SKILL.md 提取 "## 九星邻接表" 节（到下一个 ## 标题为止）
extract_adjacency() {
  local file="$1"
  awk '/^## 九星邻接表/{flag=1;next} /^## /{if(flag)exit} flag' "$file"
}

adj_first=""
adj_all_same=1
adj_missing=()

for star in "${ADJACENCY_STARS[@]}"; do
  skill_file="$PLUGIN_DIR/skills/$star/SKILL.md"
  section="$(extract_adjacency "$skill_file" || true)"
  if [ -z "$section" ]; then
    adj_missing+=("$star")
    continue
  fi
  if [ -z "$adj_first" ]; then
    adj_first="$section"
  elif [ "$section" != "$adj_first" ]; then
    fail "九星邻接表不一致: $(basename "$(dirname "$skill_file")") 与首个副本不同"
    adj_all_same=0
  fi
done

if [ "${#adj_missing[@]}" -gt 0 ]; then
  fail "九星邻接表缺失（星尚未复制，待 TASK-006）: ${adj_missing[*]}"
elif [ "$adj_all_same" -eq 1 ] && [ -n "$adj_first" ]; then
  pass "九星邻接表 9 份副本一致（天枢/天璇/天玑/天权/开阳/玉衡/洞明/隐元/瑶光）"
fi

# 司衡不应含邻接表（它有自己的路由表）
siheng_section="$(extract_adjacency "$PLUGIN_DIR/skills/siheng/SKILL.md" || true)"
if [ -n "$siheng_section" ]; then
  fail "司衡 SKILL 不应含九星邻接表（它有自己的路由表）"
else
  pass "司衡 SKILL 不含邻接表（保留自己的路由表）"
fi

# 校验 _shared 目录已废弃（技能自包含原则）
if [ -d "$PLUGIN_DIR/skills/_shared" ]; then
  fail "skills/_shared 目录仍存在（技能自包含原则要求删除）"
else
  pass "skills/_shared 已删除（技能自包含）"
fi

summary "references"
