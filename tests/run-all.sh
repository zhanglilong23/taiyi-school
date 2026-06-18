#!/usr/bin/env bash
# run-all.sh — 太一学派静态测试套入口
#
# 借鉴 superpowers/tests/claude-code/run-skill-tests.sh 的测试运行器模式。
# 全部静态校验，不依赖跑 LLM，CI 友好。
#
# 用法：
#   bash tests/run-all.sh              # 跑全部
#   bash tests/run-all.sh --verbose    # 详细输出
#   bash tests/run-all.sh -t frontmatter  # 只跑指定测试
set -euo pipefail

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$TESTS_DIR/.." && pwd)"

echo "========================================"
echo " 太一学派静态测试套"
echo "========================================"
echo "项目: $PLUGIN_DIR"
echo "时间: $(date 2>/dev/null || echo '?')"
echo ""

# 解析参数
VERBOSE=false
SPECIFIC=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --verbose|-v) VERBOSE=true; shift ;;
    -t|--test) SPECIFIC="$2"; shift 2 ;;
    -h|--help)
      echo "用法: bash tests/run-all.sh [--verbose] [-t NAME]"
      echo ""
      echo "可用测试:"
      echo "  frontmatter         SKILL.md frontmatter 合法性（name/description）"
      echo "  references          references 路径存在性 + 共享模板引用"
      echo "  siheng-readonly     司衡纯只读宪法校验（核心）"
      echo "  version-consistency 版本字段一致性"
      echo "  methodology-terms   方法论增强术语守卫（复盘/军令状/蓝军）"
      echo "  sample-consistency  auth-mvp 演示样本状态机自洽性"
      echo "  skill-prompt        SKILL 完成后标准提示语格式校验"
      echo "  ai-employee-protocol AI 员工化协议校验（身份卡/next_action/PMO）"
      exit 0
      ;;
    *) echo "未知参数: $1" >&2; exit 2 ;;
  esac
done

# 测试清单
ALL_TESTS=(
  "frontmatter"
  "references"
  "siheng-readonly"
  "version-consistency"
  "methodology-terms"
  "sample-consistency"
  "skill-prompt"
  "ai-employee-protocol"
)

if [ -n "$SPECIFIC" ]; then
  TESTS=("$SPECIFIC")
else
  TESTS=("${ALL_TESTS[@]}")
fi

PASSED=0
FAILED=0
FAILED_NAMES=()

for test_name in "${TESTS[@]}"; do
  echo "----------------------------------------"
  echo "运行: $test_name"
  echo "----------------------------------------"
  test_path="$TESTS_DIR/test-$test_name.sh"

  if [ ! -f "$test_path" ]; then
    echo "  [SKIP] 测试不存在: $test_name"
    continue
  fi

  if [ "$VERBOSE" = true ]; then
    if bash "$test_path"; then
      echo "  [PASS] $test_name"
      PASSED=$((PASSED + 1))
    else
      echo "  [FAIL] $test_name"
      FAILED=$((FAILED + 1))
      FAILED_NAMES+=("$test_name")
    fi
  else
    # 静默模式：捕获输出，失败时打印
    if output=$(bash "$test_path" 2>&1); then
      echo "$output" | grep -E "^\s+\[(PASS|SKIP)\]" | tail -5 || true
      echo "  >>> [PASS] $test_name"
      PASSED=$((PASSED + 1))
    else
      echo "$output"
      echo "  >>> [FAIL] $test_name"
      FAILED=$((FAILED + 1))
      FAILED_NAMES+=("$test_name")
    fi
  fi
  echo ""
done

# 汇总
echo "========================================"
echo " 测试结果汇总"
echo "========================================"
echo "  通过: $PASSED"
echo "  失败: $FAILED"
if [ ${#FAILED_NAMES[@]} -gt 0 ]; then
  echo "  失败项: ${FAILED_NAMES[*]}"
fi
echo ""

if [ "$FAILED" -gt 0 ]; then
  echo "状态: FAILED"
  exit 1
else
  echo "状态: PASSED"
  exit 0
fi
