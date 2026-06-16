# Epic 门牌号模板（首角色创建）

> 天枢/天璇首次接手需求时创建。是进入该 Epic 的第一份读物。

```markdown
---
type: epic-meta
epic: {小写中划线，天璇判定时命名}
status: planning           # planning / in-progress / completed / abandoned
created: YYYY-MM-DD
entry_star: tianxuan       # Epic 由天璇判定（即使入口是天枢，Epic 边界也归天璇）
requirement: REQ-NNN       # 引用天枢的需求（requirements/REQ-NNN-slug.md）
depends_on: []             # 依赖的其他 Epic（如 mall-payment depends_on [mall-mvp]；无依赖则空）
---

# Epic: {epic名}（{中文描述}）

## 元信息
- 创建者: 天璇
- 所属需求: REQ-NNN（{一句话价值}）
- 依赖 Epic: {无 / 列出 depends_on}
- 入口: {@天枢 探索 → @天璇 判 Epic / @天璇 直达 / @司衡 路由}
- 当前阶段: {Epic判定 / 设计中 / 拆解中 / 编码中 / 审查中 / 归档}

## 文档清单
> 各星产出时追加。洞明归档时核对完整性。

| 文档 | 状态 | 产出星 | 路径 |
|------|------|--------|------|
| requirement.md | ⬜ 待产 / ✅ done | 天枢（或绕过）| requirement.md |
| design.md | ⬜ / ✅ | 天璇 | design.md |
| tasks/ | ⬜ / ✅ | 天玑 | tasks/ |
| reports/ | ⬜ / ✅ | 天权/洞明/隐元/瑶光 | reports/ |
| interventions.md | ⬜ / ✅ | 洞明 | interventions.md |

## Task 列表
> 天玑拆解后维护。每完成一个 Task 更新状态。

| TASK-ID | 描述 | 状态 | commit |
| （天玑拆解后填）|

## 归档摘要（Epic 完成时洞明填写）

### 概览
（Epic 完成时填：入口/完成时间/Task 总数/最终审查）

### Task 完成清单
（归档时填）

### 遗留问题
（归档时填：未闭环 interventions 去向）

### 经验教训（强制四步复盘）

**目标回顾**：（引用 REQ-NNN 的所求之道）
**结果评估**：（实际交付 vs 目标的差距）
**根因分析**：（主观失误 / 客观限制）
**可复用 SOP**：（一段可被未来同类 Epic grep 复用的规程）

> "下次注意"式空洞总结不合格——必须落到可执行动作或可复用规程。

### 瑶光观势结论（Epic 完成架构体检）
（Epic 完成时瑶光填：模块边界/接口偏离/复杂度热点/结论）
```

## 填写要点

- **首角色创建**：天枢或天璇首次接手时创建，命名 epic（小写中划线）
- **追加式维护**：各星产出时追加"文档清单"和"Task 列表"对应行
- **归档时洞明填**：Epic 完成时洞明填写"归档摘要"
- **frontmatter status**：planning（新建）→ in-progress（拆解/编码中）→ completed（归档）/ abandoned（中止）
