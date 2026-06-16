#!/usr/bin/env bash
# bump-version.sh — 把 .version-bump.json 声明的所有 version 字段同步到目标版本
#
# 用法：
#   bash scripts/bump-version.sh 1.2.0        # 改为 1.2.0
#   bash scripts/bump-version.sh --check      # 只校验一致性，不改文件（CI 用）
#   bash scripts/bump-version.sh              # 不带参数 = --check
#
# 设计：单一真源是 .version-bump.json 的 version 字段。
# scripts/bump-version.sh 把这个版本写到所有声明的 manifest 字段。
# 借鉴 superpowers 的 .version-bump.json + bump-version.sh 模式。
#
# 依赖：bash + python3（跨平台，Windows Git Bash 可跑）
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CONFIG="$ROOT/.version-bump.json"

# ---------- 参数 ----------
CHECK_ONLY=0
TARGET_VERSION=""

usage() {
  cat <<'EOF'
用法:
  bash scripts/bump-version.sh 1.2.0      改为指定版本（写所有 manifest）
  bash scripts/bump-version.sh --check    只校验一致性（不改文件，CI 友好）
  bash scripts/bump-version.sh            无参数 = --check
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --check)  CHECK_ONLY=1; shift ;;
    -h|--help) usage; exit 0 ;;
    -*) echo "未知参数: $1" >&2; usage; exit 2 ;;
    *) TARGET_VERSION="$1"; shift ;;
  esac
done

# 无参数默认 check 模式
if [[ -z "$TARGET_VERSION" && $CHECK_ONLY -eq 0 ]]; then
  CHECK_ONLY=1
fi

[[ -f "$CONFIG" ]] || { echo "ERROR: 找不到 $CONFIG" >&2; exit 1; }
command -v python3 >/dev/null || { echo "ERROR: 需要 python3" >&2; exit 1; }

# ---------- 核心逻辑（python 实现，处理 JSON + 点号路径）----------
python3 - "$CONFIG" "$ROOT" "$TARGET_VERSION" "$CHECK_ONLY" <<'PY'
import json
import sys
import re
from pathlib import Path

config_path, root, target_version, check_only = sys.argv[1:5]
check_only = check_only == "1"
root = Path(root)
config = json.loads(Path(config_path).read_text(encoding="utf-8"))

# 声明的基准版本（.version-bump.json 的 version 字段）
declared_version = config.get("version")
if not declared_version:
    print("ERROR: .version-bump.json 缺 version 字段", file=sys.stderr)
    sys.exit(1)

# bump 模式下，目标版本覆盖基准；check 模式下，以声明的基准为期望值
expected = target_version if target_version else declared_version

# 简单 semver 校验（x.y.z 或 x.y.z-pre）
if not re.match(r"^\d+\.\d+\.\d+([-\w.]+)?$", expected):
    print(f"ERROR: 版本号格式非法: {expected}（应为 x.y.z）", file=sys.stderr)
    sys.exit(1)

def get_by_path(obj, dotted):
    """支持点号路径，数字段当作数组下标：plugins.0.version → obj['plugins'][0]['version']"""
    cur = obj
    for seg in dotted.split("."):
        if seg.isdigit() and isinstance(cur, list):
            cur = cur[int(seg)]
        else:
            cur = cur[seg]
    return cur

def set_by_path(obj, dotted, value):
    cur = obj
    segs = dotted.split(".")
    for seg in segs[:-1]:
        if seg.isdigit() and isinstance(cur, list):
            cur = cur[int(seg)]
        else:
            cur = cur[seg]
    last = segs[-1]
    if last.isdigit() and isinstance(cur, list):
        cur[int(last)] = value
    else:
        cur[last] = value

changed = []
mismatches = []

for entry in config.get("files", []):
    rel = entry["path"]
    field = entry["field"]
    fpath = root / rel
    if not fpath.exists():
        mismatches.append(f"  文件不存在: {rel}")
        continue
    try:
        data = json.loads(fpath.read_text(encoding="utf-8"))
    except Exception as e:
        mismatches.append(f"  JSON 解析失败 {rel}: {e}")
        continue
    try:
        current = get_by_path(data, field)
    except (KeyError, IndexError, TypeError):
        mismatches.append(f"  字段不存在 {rel}:{field}")
        continue

    if current != expected:
        if check_only:
            mismatches.append(f"  {rel}:{field} = {current}（期望 {expected}）")
        else:
            set_by_path(data, field, expected)
            fpath.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
            changed.append(f"  {rel}:{field}  {current} → {expected}")

# ---------- 输出 ----------
mode = "CHECK" if check_only else "BUMP"
print(f"=== bump-version ({mode}) ===")
print(f"基准版本 (.version-bump.json): {declared_version}")
print(f"目标版本: {expected}")
print()

if changed:
    print("已修改：")
    for c in changed:
        print(c)
    print()

if mismatches:
    print("不一致：")
    for m in mismatches:
        print(m)
    print()
    print(f"结果: FAIL（{len(mismatches)} 处不一致）")
    sys.exit(1)

if not changed and not mismatches:
    print("所有声明的 version 字段一致，无需改动。")

print("结果: OK")
PY
