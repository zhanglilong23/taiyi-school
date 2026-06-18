# AI 员工化操作手册

> 定义九星在 `ai_employee_mode` 下的主动行为协议、岗位映射与 `next_action.md` 标准格式。

---

## 一、九星 + 司衡岗位映射表

| 星 | 岗位名称 | 汇报对象 | 核心目标 |
|----|---------|---------|---------|
| 天枢 | 产品经理/业务分析师 | 用户 | 把混沌变成可写进 Issue 的需求真言 |
| 天璇 | 架构师/产品设计师 | 用户 | 把需求变成可执行的设计包 + Epic 边界 |
| 天玑 | Tech Lead | 用户 | 把设计包拆成可独立执行的任务契约 |
| 天权 | 工程师（质量/文心） | Tech Lead | 按契约写出可验证、可维护的代码 |
| 开阳 | 工程师（效率/武毅） | Tech Lead | 按契约快速修复 bug/优化/攻坚 |
| 玉衡 | 开发自测 | Tech Lead | 编码后对照契约逐项自检，通过才放行 |
| 洞明 | QA/质门守门人 | 用户 | 独立审查代码，只认证据，一票否决 |
| 隐元 | 安全/风险审计 | 洞明 | 扫描非功能性风险，只报实证 |
| 瑶光 | 诊断师 | 用户 | 定位 bug 根因并精准路由到源头星 |
| 司衡 | PMO/项目协调员 | 用户 | 读状态、读 next_action，发推进指令，不写文件 |

---

## 二、`ai_employee_mode` 开关定义

```yaml
# 写在 .taiyi/_workspace/status.md 或全局配置中
ai_employee_mode: active | manual
```

| 模式 | 含义 | 各星行为差异 |
|------|------|-------------|
| `active` | AI 员工模式开启 | 每颗星完成后自动写 `next_action.md`，司衡读取并输出推进指令 |
| `manual` | 手动模式（默认） | 每颗星完成后只更新 `status.md`，用户手动 `@` 召唤下一颗星 |

### 各星如何检查

每颗星在"完成后"阶段执行：

```bash
# 伪代码（各星 SKILL 中已写为具体步骤）
if grep -q "ai_employee_mode=active" .taiyi/_workspace/status.md; then
  write .taiyi/_workspace/next_action.md  # 按下方 schema
fi
```

> **司衡例外**：司衡只读不写，即使 `ai_employee_mode=active`，司衡也不写 `next_action.md`——它只读取其他星写入的 `next_action.md`。

---

## 三、`next_action.md` YAML frontmatter schema

```yaml
---
star: "天权"          # 当前完成星
action: "自检"        # 下一步动作（编码/自检/审查/诊断/观势/归档...）
reason: "编码完成，需玉衡自检通过后交洞明审查"  # 推进理由
manual_invoke: "@玉衡"  # 手动召唤提示
mode: "active"        # active | manual（与 status.md 一致）
---
```

### 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `star` | 是 | 刚刚完成工作的星（写 next_action.md 的星） |
| `action` | 是 | 下一步要执行的动作 |
| `reason` | 是 | 为什么下一步是这个动作（简短） |
| `manual_invoke` | 是 | 若环境不支持自动调度，提示用户手动召唤什么 |
| `mode` | 是 | 当前模式，与 status.md 保持一致 |

### 示例

```yaml
---
star: "玉衡"
action: "审查"
reason: "自检已通过，代码已 commit，需洞明独立审查"
manual_invoke: "@洞明"
mode: "active"
---
```

---

## 四、主动行为协议

### 协议一：确认输入

每颗星开工前执行输入自审（HARD-GATE），缺前置不开工。

### 协议二：更新状态

每颗星完成后更新 `.taiyi/_workspace/status.md`：
- `current_star=XX(done)`
- `next_star=YY`
- `next_action=ZZZ`
- `manual_invoke=@YY`

### 协议三：写 next_action

`ai_employee_mode=active` 时，每颗星（除司衡外）完成后写 `.taiyi/_workspace/next_action.md`，供司衡读取推进。

---

## 五、司衡 PMO 仪式模板

### 项目启动单

```
【项目启动单】
需求：REQ-NNN-{slug}
Epic：{epic-name}
首星：{首星名}（{理由}）
风险点：
  1. {风险描述}
  2. {风险描述}
```

### 推进指令

```
下一步：{manual_invoke}，理由：{reason}
```

### 项目结案单

```
【项目结案单】
Epic：{epic-name}
完成 Task：
  - TASK-XXX {描述}（commit: {sha}）
intervention 去向：
  - INT-XXX {描述} → {去向}
观势结论：{引用瑶光 assessment.md 结论}
```

---

## 六、commit 死锁修复说明（P0 修复）

| 星 | 修复前 | 修复后 |
|----|--------|--------|
| 天权/开阳 | 编码五步第二步含 `→ commit` | 移除 commit，改为"测 → 验证 → 下一片" |
| 天权/开阳 | 输出"已 commit 的代码" | 输出"已编码、尚未 commit 的代码" |
| 天权/开阳 | 完成后 step1 "代码 commit" | 移除 commit，改为"产出实现报告（暂不含玉衡摘要）" |
| 玉衡 | 输出"自检通过 → 天权/开阳 commit" | 输出"自检通过 → 追加玉衡自检摘要到 impl.md 并 commit" |
| 玉衡 | 完成后只输出摘要 | 完成后：追加摘要 + commit + 更新 status + 写 next_action |
| 洞明 | 输入"代码已 commit" | 输入"代码已 commit + impl.md 含玉衡自检摘要" |

**关键变更**：天权/开阳编码后不 commit；玉衡自检通过后由玉衡（或天权/开阳按玉衡摘要）追加摘要到 impl.md 并 commit。

---

*本手册由 TSK-TY-AIEMP-TRANSFORM-001 任务创建，与 `skills/*/SKILL.md` 同步生效。*
