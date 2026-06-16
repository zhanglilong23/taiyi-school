# 审查报告模板（洞明产出）

> 洞明审查后产出。放行/打回二选一，没有第三种结果。复制此模板填写。

```markdown
---
type: report
task_id: TASK-{序号}
epic: {继承}
star: dongming
status: done
created: YYYY-MM-DD
upstream:
  - epics/{epic}/tasks/TASK-{序号}.md
  - epics/{epic}/reports/TASK-{序号}/impl.md
downstream: [归档 / 瑶光诊断]
verdict: pass | reject
---

# 审查报告: TASK-{序号}

## 审查结论: [放行] / [打回]

## doubt-driven 对抗审查记录

### Step 1·CLAIM（天权声称）
{天权自检报告里声明的，如"线程安全/符合契约/边界覆盖"——记录但不采信}

### Step 2·EXTRACT（剥离推理，只取事实）
- artifact: {git diff 代码，不含天权推理}
- contract: {契约 TASK-ID 的锁死项}

### Step 3·DOUBT（对抗式审查）
对抗提示词："找出这个代码的问题。假设作者过度自信。找未声明假设/未处理边界/隐藏耦合/契约违反可能/意外输入失败模式。不要验证，找问题。"
{审查 findings}

### Step 4·RECONCILE（分类）
| finding | 分类 | 处理 |
|---------|------|------|
| {问题1} | 契约误读/可执行/权衡/噪声 | {处理} |

### Step 5·STOP（停止条件）
{trivial/3轮/用户override}

## 五张清单核查

| 清单 | 检查项 | 结论 |
|------|--------|------|
| 证据核对 | 独立重跑验证命令，贴真实输出 | PASS/FAIL |
| 边界核对 | ≥3场景：空输入/异常/依赖故障 | PASS/FAIL |
| 越权核对 | git diff 只在白名单内 | PASS/FAIL |
| Smoke凌驾 | 启动应用真实触发E2E，贴输出 | PASS/FAIL |
| task-queue一致性 | grep TASK-ID + git log SHA 比对 | PASS/FAIL |

## intervention.md 清点
- 本次产生的 open 条目: {数量}
- 去向: {升级Task/延后P2/用户确认}

## 如 [放行]
- push/merge: {分支/commit}
- _workspace/interventions.md 未闭环问题迁入 epics/{epic}/interventions.md（进 git）
- _workspace/status.md → IDLE（或指向下一个 Task）
- [Epic 全部完成] 执行归档：写 epics/{epic}/archive/summary.md + 更新 epic.md status: completed + 更新 INDEX.md

## 如 [打回]
- bug 清单:
  | # | 哪条DONE没过/哪个场景没覆盖/哪个约束违反 |
  |---|----------------------------------------|
- 根因分类: 实现偏差(→天权) / 契约歧义(→天玑) / 架构偏差(→天璇) / 需求问题(→天枢)
- 精确修复指引: {打回附的修复方向}
- _workspace/status.md → 指向瑶光诊断（中断态）
```

## 填写要点

- **不放水**：禁止信任天权单方声称，自己跑 git diff + 重跑验证
- **Smoke凌驾**：契约没写 E2E 也要审，任一 FAIL → 一票否决
- **打回必须附根因分类**：不是笼统打回，指明根因在哪颗星
- **intervention必清点**：放行前必须有明确去向，不能登记了就放
