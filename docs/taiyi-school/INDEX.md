# 太一索引

> 项目顶层入口。轻量导航，不重复 git 已有信息。
> 由洞明在需求/Epic 归档时维护。

## 需求索引

> 天枢产出需求时追加。需求归档时更新状态。

| REQ-ID | 描述 | 状态 | 对应 Epic | 路径 |
| （无）|

## 活跃 Epic

| Epic | 所属需求 | 状态 | 创建时间 | 路径 |
| （无）|

## 已归档 Epic

| Epic | 完成时间 | Task 数 | 归档路径 |
| （无）|

## 已归档需求

| REQ-ID | 描述 | 完成时间 | Epic 数 | 路径 |
| （无）|

## 快速查询

| 想看什么 | 怎么查 |
|---------|--------|
| 某个需求详情 | `requirements/REQ-NNN-*.md` |
| 某个 Epic 详情 | `epics/{epic}/epic.md` |
| 某个 Task 的报告 | `epics/{epic}/reports/TASK-NNN/` |
| 未闭环问题 | `grep "## Open" epics/*/interventions.md` |
| 最近提交了什么 | `git log --oneline -20` |
| 当前工作状态 | `_workspace/status.md`（分支本地）|

## ADR 跨 Epic 索引

> 跨 Epic 复用的架构决策。Epic 内的 ADR 不在此列。

| ADR | 决策 | Epic | 路径 |
| （无）|

<!--
维护规则：
  - 天枢产需求时：追加"需求索引"一行
  - 天璇判 Epic 时：追加"活跃 Epic"一行（含所属需求）
  - Epic 归档时：洞明移入"已归档 Epic"
  - 需求归档时：洞明移入"已归档需求"
  - 跨 Epic ADR：洞明判断 ADR 被其他 Epic 复用时登记
-->
