---
title: LSN-001 Windows 编码暗礁
type: lesson-learned
project: taiyi-school
date: 2026-06-18
source: TSK-TY-POSTEPIC-001
---

# LSN-001：Windows Git Bash 编码暗礁

> 教训来源：TSK-TY-POSTEPIC-001（v1.4.0 Epic 复盘）
> 触发事件：`tests/test-frontmatter.sh` 在 Windows Git Bash 下把中文 description 按字节计数，导致 30 字符的中文被误计为 60 字节，触发假 FAIL。

## 暗礁清单

### 1. `${#var}` 在 Windows Git Bash 下按字节计数

**现象**：
```bash
# Linux (UTF-8 locale)
$ s="中文测试"
$ echo ${#s}
4          # 正确：4 个字符

# Windows Git Bash (MSYS2)
$ echo ${#s}
12         # 错误：按 UTF-8 字节计数
```

**根因**：MSYS2 bash 的 `LC_CTYPE` 默认不是 `UTF-8`，`${#var}` 底层调用 `strlen()` 而非 `mbrlen()`，导致多字节字符被拆算。

**修复方案**：
```bash
# 方案 A：python（跨平台、最稳）
utf8_len() {
  local s="$1"
  python -c "import sys; print(len(sys.argv[1]))" "$s"
}

# 方案 B：iconv + wc（依赖 locale，不推荐在 Windows 用）
# printf '%s' "$s" | iconv -f UTF-8 -t UTF-8 | wc -m
```

**落地建议**：
- 所有涉及“字符数”硬约束的测试脚本，统一用 `python` 做字符计数兜底；
- 在 `test-helpers.sh` 中集中封装 `utf8_len()`，避免各脚本各自为战；
- 注释中显式标注“UTF-8 字符计数”，提醒后续维护者不要改回 `${#var}`。

### 2. CRLF 行尾导致 `sed` 模式匹配失败

**现象**：Windows 编辑器保存的 `.md` 文件带 `\r\n` 行尾，`sed -n '/^---$/,/^---$/p'` 无法匹配 `---`（因为行尾多了 `\r`）。

**修复方案**：
```bash
# 在读取前统一转 LF
dos2unix "$file" 2>/dev/null || sed -i 's/\r$//' "$file"
```

**落地建议**：
- 项目根目录加 `.gitattributes`：
  ```
  *.md text eol=lf
  *.sh text eol=lf
  ```
- CI 中增加 `file -k` 或 `git diff --check` 拦截 CRLF。

### 3. `grep -P` 在 Windows Git Bash 下不可用

**现象**：`grep -P '(?<=foo)bar'` 在 MSYS2 中报错 `grep: support for PCRE is not compiled`。

**修复方案**：用 `perl` 或 `python` 替代 PCRE 需求；或在测试脚本中先探测 `grep -P` 可用性，不可用时优雅降级。

## 关联 TASK

- TSK-TY-POSTEPIC-001：本次修复 `test-frontmatter.sh` 的 description 长度计数
- TSK-TY-SHENG-001：司衡 SKILL 改造中曾遇到 `sed` 跨平台差异

## 可执行建议（Checklist）

- [ ] 测试脚本涉及字符计数时，用 `python` 或 `perl` 替代 bash 原生 `${#var}`
- [ ] 项目根目录配置 `.gitattributes` 强制 LF 行尾
- [ ] 测试脚本避免使用 `grep -P`，优先用 `grep -E` 或 `python` 正则
- [ ] 在 `test-helpers.sh` 中封装跨平台工具函数，统一调用
