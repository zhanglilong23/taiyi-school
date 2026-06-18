---
title: LSN-002 SPEC 自洽性设计
type: lesson-learned
project: taiyi-school
date: 2026-06-18
source: TSK-TY-POSTEPIC-001
---

# LSN-002：SPEC 自洽与验证命令 mentally run 原则

> 教训来源：TSK-TY-POSTEPIC-001（v1.4.0 Epic 复盘）
> 触发事件：父契约 v1.4.0 中 SPEC-1 与 SPEC-4 的验证命令存在逻辑冲突，导致狄公审查时同一测试脚本需同时满足互斥条件。

## 暗礁清单

### 1. SPEC 之间互相冲突（SPEC-1 vs SPEC-4）

**现象**：
- SPEC-1 要求 `test-frontmatter.sh` 校验 description 长度 ≤60 字符；
- SPEC-4 要求同一脚本同时支持“按字节计数”以兼容旧数据。
- 结果：脚本实现者陷入两难，改字符计数则 SPEC-4 挂，保字节计数则 SPEC-1 挂。

**根因**：司南签发契约时，各 SPEC 独立编写，未做交叉验证（cross-spec review）。

**修复方案**：
1. 契约中增加“SPEC 一致性”显式检查项；
2. 所有 SPEC 的验证命令在签发前由签发人 mentally run 一遍；
3. 冲突 SPEC 合并或标注优先级（如“以 SPEC-1 为准，SPEC-4 废弃”）。

**落地建议**：
```markdown
## SPEC 一致性声明
- SPEC-1 与 SPEC-3 共享同一验证脚本，修改时需同时保证两者通过。
- 若 SPEC 冲突，以编号较小者为准，并在 DON'T 中显式禁止反向操作。
```

### 2. 验证命令未“mentally run”

**现象**：契约中写的验证命令：
```bash
grep -E "SPEC-1|SPEC-4|自动唤醒|限定范围|mentally run" docs/lessons/LSN-002.md
```
签发人未实际执行，导致关键词拼写错误（如 `mentally` 写成 `mental`），交付时 FAIL。

**根因**：验证命令是“写给审查者看的”，签发人假设审查者会自己调整，而非作为硬约束。

**修复方案**：
1. 验证命令必须能在交付者本地直接复现；
2. 签发契约前，签发人亲自执行一遍所有 SPEC 验证命令；
3. 复杂验证命令拆成“预置条件 + 核心断言”，降低执行门槛。

**落地建议**：
```markdown
### SPEC-X：xxx
- 预置：
  ```bash
  bash tests/test-frontmatter.sh
  ```
- 断言：
  - 退出码 0
  - 输出中 `fail=0`
```

### 3. 限定范围 grep 误伤

**现象**：验证命令用 `grep -E "foo|bar" file.md` 检查关键词存在性，但 `file.md` 中 `foo` 出现在注释或反例中，并非正面陈述，导致“命中即通过”的逻辑产生假 PASS。

**根因**：验证命令过于宽泛，未限定上下文（如只检查标题行、只检查正文）。

**修复方案**：
1. 用 `grep -n` 输出命中行号，审查时人工确认上下文；
2. 对结构化文档（如 Markdown），用 `sed` 提取特定章节后再 grep；
3. 关键词加锚定（如 `^## `、`^\s*[-*]`）缩小匹配范围。

**落地建议**：
```bash
# 不好：可能误伤
grep -E "自动唤醒" docs/lessons/LSN-002.md

# 好：限定在标题或列表项
grep -E "^## .*自动唤醒|^\s*[-*].*自动唤醒" docs/lessons/LSN-002.md
```

## 关联 TASK

- TSK-TY-POSTEPIC-001：本次新增 `test-skill-prompt.sh` 时， SPEC-2 要求“脚本存在、可执行、有汇总输出”，验证命令设计时即做了 mentally run
- TSK-TY-SHENG-001：司衡 SKILL 改造中，SPEC-1 与 SPEC-4 的冲突由狄公第四次审查发现并修正

## 可执行建议（Checklist）

- [ ] 签发契约前，所有 SPEC 验证命令由签发人本地执行一遍
- [ ] 多 SPEC 共享同一脚本时，在契约中显式标注依赖关系
- [ ] grep 验证命令加锚定或章节限定，避免假 PASS
- [ ] 验证命令拆成“预置 + 断言”，降低复现门槛
- [ ] 契约 DON'T 中显式禁止“为通过测试而修改被测对象本质语义”
