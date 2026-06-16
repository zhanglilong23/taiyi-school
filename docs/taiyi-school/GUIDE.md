# 太一指南

> 太一学派文档体系使用说明。

## 目录结构

```
docs/taiyi-school/
│
├── requirements/              需求层（★ 进 git，天枢产出）
│   └── REQ-{NNN}-{slug}.md    需求真言（独立于 Epic）
│
├── _workspace/                工作层（★ .gitignore，分支本地）
│   ├── status.md              当前态（含 current_requirement/epic/task）
│   ├── queue.md               当前执行队列
│   └── interventions.md       当前发现的契约外问题
│
├── epics/                     Epic 层（进 git，天璇判定 + 命名）
│   └── {epic}/
│       ├── epic.md            Epic 门牌号（frontmatter 引用 requirement + depends_on）
│       ├── design.md          设计包（天璇）
│       ├── adr/               架构决策记录（天璇）
│       ├── interventions.md   本 Epic 未闭环问题（进 git）
│       ├── tasks/
│       │   └── TASK-{NNN}.md  任务契约（天玑）
│       └── reports/
│           └── TASK-{NNN}/    按 Task 分组的报告
│               ├── impl.md        实现报告（天权/开阳）
│               ├── review.md      审查报告（洞明）
│               ├── risk.md        风险报告（隐元）
│               └── diagnosis.md   诊断报告（瑶光）
│
├── diagnoses/                 瑶光独立诊断（不归属任何 Epic，进 git）
├── misc/                      不归属任何 Epic 的独立产出 + 杂项
│   └── reviews/               洞明独立审查（如审查外部 PR）
├── INDEX.md                   顶层导航（洞明维护）
└── GUIDE.md                   本文件
```

## 三层职责链（核心设计）

| 层 | 角色 | 产出 | 位置 |
|----|------|------|------|
| **需求层** | 天枢 | 需求真言（判需求真伪/边界/价值）| `requirements/REQ-NNN.md` |
| **Epic 层** | 天璇 | Epic 判定 + 设计包（按价值流拆 Epic）| `epics/{epic}/` |
| **Task 层** | 天玑 | 任务契约（Epic 内拆 Task）| `epics/{epic}/tasks/` |

**三层完全解耦**：
- 天枢不碰 Epic（需求语义层）
- 天璇判 Epic 边界（工程结构层）
- 天玑只拆 Task（不碰 Epic 边界）

**一个需求 → 多个 Epic**：
```
requirements/REQ-001-商城系统.md（一份需求真言）
  ├ epics/mall-mvp/      ← frontmatter requirement: REQ-001
  ├ epics/mall-payment/  ← frontmatter requirement: REQ-001, depends_on: [mall-mvp]
  └ epics/mall-management/ ← frontmatter requirement: REQ-001, depends_on: [mall-mvp]
```

## 两层语义（核心设计）

**Epic 是可选的组织工具，不是强制容器。** 两类可召唤角色权限不同：

| 角色类型 | 角色 | 能创建 Epic 吗 | 无 Epic 时产出放哪 |
|---------|------|---------------|------------------|
| **流程起点** | 天枢、天璇 | ✅ 能 | （流程起点必建 Epic）|
| **工具入口** | 洞明、瑶光 | ❌ 不能 | `misc/reviews/`（洞明）/ `diagnoses/`（瑶光）|

### 三种工作模式

| 模式 | 触发 | 产物位置 |
|------|------|---------|
| **Epic 模式** | 流程起点开启需求（@天枢/@天璇/@司衡 路由）| `epics/{epic}/...` |
| **无 Epic 模式** | @瑶光 查 bug、@洞明 审查外部 PR | `diagnoses/` 或 `misc/` |
| **维护项目模式** | 全程工具入口，零散任务 | `diagnoses/` + `misc/`，可完全不建 Epic |

### 归属判断（每个可召唤角色开工第一步）

```
1. 读 _workspace/status.md → 有 current_epic 吗？
2. 用户明确说归属某 Epic 吗？
3. 判断：
   - 有归属 → Epic 模式，产出进 epics/{epic}/
   - 无归属 + 流程起点（天枢/天璇）+ 新需求 → 创建新 Epic
   - 无归属 + 工具入口（洞明/瑶光）→ 无 Epic 模式，进 diagnoses/ 或 misc/
   - 不确定 → 问用户"这归属某 Epic 吗？还是独立任务？"
```

## 两层语义（工作层 vs 产物层）

| 层 | 文件夹 | 语义 | 进 git | 在哪有意义 |
|----|--------|------|--------|-----------|
| **工作层** | `_workspace/` | 动态当前态 | ❌ | 任何正在开发的分支 |
| **产物层** | `epics/` | 永久工作记录 | ✅ | 所有分支 |

**关键原则**：
- develop/master 不做需求，它没有"当前工作"——_workspace 在基线分支上是 IDLE
- feature/任何分支正在开发时，_workspace 记录当前态
- 合并时 _workspace 不合并（不进 git），只合并产物态

## 文档接力机制

角色之间靠**产物 frontmatter 的 upstream/downstream**接力，不靠对话记忆：

```yaml
---
type: contract                          # requirement|design|contract|report|diagnosis|assessment|epic-meta
epic: mall-mvp                          # 归属 Epic（独立产出时 null）
task_id: TASK-003                       # 归属 Task（Epic 级文档无此字段）
star: tianji                            # 产出星
status: done                            # draft|done|approved
revision: 1                             # 修订版本（追加修改时 +1）
created: YYYY-MM-DD
upstream: [epics/mall-mvp/design.md]    ← 我读了什么
downstream: [天权编码, 洞明审查]          ← 谁会读我
---
```

<HARD-GATE>
所有产物文档必须有完整 frontmatter。缺 frontmatter = 下游星无法 grep/接力 = 文档链断裂。
各星产出时**用 Read 读本星 `references/` 下的对应模板**（技能自包含，模板物理存在于每个使用它的星目录下，多星共用的模板各存副本）。模板已含标准 frontmatter。
</HARD-GATE>

下游星开工第一步：读 status.md（当前态）→ 读上游产物的 frontmatter → 读上游产物正文。

## 写权限矩阵

| 文件 | 写者 | 时机 |
|------|------|------|
| `_workspace/status.md` | 当前活跃的星 | 每次状态变化 |
| `_workspace/queue.md` | 天玑（拆解）、开工星、洞明 | 拆解/开工/完成/挂起 |
| `_workspace/interventions.md` | 任何星 | 发现契约外问题时 |
| `epics/{epic}/epic.md` | 天璇（创建）、各星（追加清单）、洞明（归档）| 各自节点 |
| `requirements/REQ-{NNN}-{slug}.md` | 天枢 | 判需求后 |
| `epics/{epic}/design.md` | 天璇 | 判 Epic + 设计后 |
| `epics/{epic}/tasks/TASK-NNN.md` | 天玑 | 拆解后 |
| `epics/{epic}/reports/*` | 天权/洞明/隐元/瑶光 | 各自产出 |
| `epics/{epic}/interventions.md` | 洞明 | 合并/归档时从 _workspace 迁入 |
| `epics/{epic}/archive/summary.md` | 洞明 | Epic 归档时 |
| `diagnoses/BUG-{NNN}.md` | 瑶光 | 独立诊断时（不归属任何 Epic）|
| `misc/reviews/REVIEW-{NNN}.md` | 洞明 | 独立审查时（不归属任何 Epic）|
| `INDEX.md` | 洞明 | 归档时 |
| **司衡** | ❌ 不写任何文件 | 纯只读路由 |

## 合并流程（feature → develop）

```
1. 业务产物 git merge（按 epic/Task 路径天然隔离，不冲突）
2. 洞明执行 interventions 落地：
   _workspace/interventions.md 未闭环问题
   → 迁入 epics/{epic}/interventions.md（进 git）
3. _workspace 丢弃（不进 git，随分支消亡）
4. [Epic 完成] 洞明 Epic 归档：
   - 调度瑶光观势（Epic 级架构体检）
   - 归档 SOP 逐项打勾（见洞明 SKILL）
   - 写 epics/{epic}/archive/summary.md
   - 更新 epic.md status: completed
   - 更新 INDEX.md（活跃→已归档）
5. [需求的所有 Epic 都归档] 洞明需求归档：
   - 更新 requirements/REQ-NNN.md status: completed
   - 更新 INDEX.md（需求索引→已归档需求）
```

**两层归档**：Epic 归档 = 单价值切片完成；需求归档 = 所有 Epic 归档后触发。

## 职责边界：部署不在太一范围内

太一学派覆盖"需求 → 设计 → 拆解 → 编码 → 审查 → 归档（push/merge）"。**部署不归太一**：
- **生产环境**：归运维/CI-CD，太一不越权
- **开发环境**：由人工部署（语言/依赖差异大，自动化反而添乱）

洞明归档后代码已 push/merge 到主分支，主分支之后的发布/部署是外部流程。

## 文档命名规范

| 类型 | 命名 | 示例 |
|------|------|------|
| 需求文件 | `REQ-序号-slug.md` | `REQ-001-商城系统.md` |
| Epic 目录 | 小写中划线 | `mall-mvp` |
| Task 契约 | `TASK-序号.md` | `TASK-001.md` |
| 报告目录 | `TASK-序号/` | `reports/TASK-001/` |
| ADR | `ADR-序号-slug.md` | `ADR-001-redis选型.md` |
| 诊断报告 | `BUG-序号.md` | `BUG-007.md` |
| 溢出登记 | `INT-序号` | `INT-001` |
