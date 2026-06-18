---
title: 太一学派教训文档索引
type: index
project: taiyi-school
date: 2026-06-18
---

# docs/lessons/README.md

> 太一学派 Epic 级教训沉淀索引。每篇 LSN 对应一次真实踩坑，含根因、修复方案、可执行 Checklist。

## 教训列表

| 编号 | 标题 | 创建日期 | 一句话摘要 |
|------|------|----------|-----------|
| LSN-001 | [Windows 编码暗礁](LSN-001-windows-encoding.md) | 2026-06-18 | Windows Git Bash 下 `${#var}` 按字节计数、CRLF 导致 sed 失效、grep -P 不可用 |
| LSN-002 | [SPEC 自洽性设计](LSN-002-spec-self-consistency.md) | 2026-06-18 | SPEC-1 与 SPEC-4 冲突案例、验证命令 mentally run 原则、限定范围 grep 建议 |

## 新增教训流程

1. 复盘 Epic 时识别“硬教训”（非一次性 bug，而是可复用的模式缺陷）；
2. 按 `LSN-NNN-{slug}.md` 命名新建文件；
3. 必须含：来源 TASK、触发事件、暗礁清单（现象/根因/修复/落地建议）、关联 TASK、可执行 Checklist；
4. 更新本 README 索引表；
5. 提交时引用对应 TASK-ID。
