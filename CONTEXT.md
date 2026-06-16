# 太一学派 · 共享语言

Agent 与项目之间的领域术语定义。消除歧义，确保所有角色说同一句话。

## 核心理念

**太一** = 契约（北极星，不动点）。一切围绕契约转，无契约不行动。北极星不动，众星围绕它旋转——契约一旦确立即神圣，擅改须经由对应星重新对准。

**九星** = 围绕契约的执行节点。平级，不分组。按工程顺序流转（想清楚→做出来→验明白）。

**司衡** = 调度中枢（帝车）。唯一的调度器，读请求/状态，路由到合适的星，推进流程。SKILL 已落地（`skills/siheng/SKILL.md`），纯只读不写文件。

## 九星体系（已全部落地）

> 完整设计详见 `docs/history/DESIGN-PROPOSAL.md`（历史归档稿）。十星全部有 SKILL（九星 + 司衡）。

### 九星角色

| 星 | 拼音 | 职责 | 对应角色 | 必经? |
|----|------|------|---------|------|
| **天枢** | tianshu | 判需求——从混沌炼需求真言，正判 | 产品/业务分析 | 可选（需求模糊时）|
| **天璇** | tianxuan | 设计——把需求转化为技术方案/产品设计/UI原型 | 产品/UI/架构 | **必经** |
| **天玑** | tianji | 拆任务——把设计拆成任务契约，两层+三档授权 | Tech Lead | **必经** |
| **天权** | tianquan | 编码（文心）——新建模块，慢工出细活 | 软件工程师 | mode=tianquan 时 |
| **开阳** | kaiyang | 编码（武毅）——修bug/优化，兵贵神速 | 软件工程师 | mode=kaiyang 时 |
| **玉衡** | yuheng | 自检——编码后对照契约自测 | 开发自测 | **必经**（内化进天权/开阳）|
| **洞明** | dongming | 质门审查——独立验证+放行/打回+归档 | QA/独立审查者 | **必经** |
| **隐元** | yinyuan | 非功能性风险守护——安全/鲁棒/性能/可靠/兼容 | 安全/风险审计 | 按风险标记触发 |
| **瑶光** | yaoguang | 查根因——bug诊断+架构体检，路由到源头 | 诊断师 | 打回时/用户召唤 |

### 主链路

```
[天枢(判需求)] → 天璇(设计) → 天玑(拆任务) → 天权/开阳(编码) → 玉衡(自检) → 洞明(审查)
  可选前置                                                                        ↓
                                                          (按风险标记)隐元 ←──┘  放行/打回
                                                                                  ↓打回
                                                                              瑶光(查根因)→路由
```

### 校验架构（两层）

**第一层·输入自审（下游星校验上游产出 · 每步天然有）**

每颗星启动时自审输入——检查前置条件满足吗，不满足不开工。这就是天然的"下游评审上游"：

```
天璇自审：需求够明确吗（校验天枢/用户的产出）
天玑自审：设计包完整吗（校验天璇的产出）
天权/开阳自审：契约可用吗（校验天玑的产出）
```

自审不过 → 打回上游。

**第二层·独立审查（洞明 · 仅代码审查为必经）**

- **洞明代码审查**：编码后必经的独立验证（代码不能靠自审，需独立第三方）
- **洞明需求/契约审查**：用户主动召唤才触发（非默认，用户觉得有质量问题才叫洞明审）
- **隐元风险扫描**：按契约风险标记触发（security=high 等非默认维度）
- **瑶光根因诊断**：洞明打回时触发，或用户主动召唤

### 交接协议

每颗星完成后，产出文档落盘 + 更新 _workspace。司衡读 status.md 按五指规则调度，或用户手动指示下一颗星。

| 交接 | 上游产出 | 下游读取 |
|------|---------|---------|
| 天枢→天璇 | `requirements/REQ-{NNN}-{slug}.md` | 天璇读需求真言 + 判 Epic 边界 |
| 天璇→天玑 | `epics/{epic}/design.md` | 天玑读设计包 |
| 天玑→天权/开阳 | `epics/{epic}/tasks/TASK-{NNN}.md` | 天权/开阳读契约 |
| 天权/开阳→玉衡 | 代码（内化，无独立文件）| 玉衡自检（内化进天权/开阳收尾）|
| 天权/开阳→洞明 | `reports/TASK-{NNN}/impl.md` + commit | 洞明读代码+契约+实现报告 |
| 洞明→归档 | `reports/TASK-{NNN}/review.md` | push/Epic归档/需求归档 |
| 洞明打回→瑶光 | `reports/TASK-{NNN}/review.md`（打回单）| 瑶光读打回单诊断根因 |
| 瑶光→源头星 | `reports/TASK-{NNN}/diagnosis.md` 或 `diagnoses/BUG-{NNN}.md` | 按根因路由到天权/天璇/天玑/天枢 |

### 输入自审（所有星共用）

每颗星启动时先自审输入——检查前置条件满足吗，不满足不开工：

```
1. 确认输入文件存在（路径对吗）
2. 确认输入含必要字段（frontmatter 的 type/status 对吗）
3. 确认输入满足我的前置条件（各星具体检查项见 SKILL）
任一不满足 → 报告"输入不完整，缺XXX"，不开工
```

**自审 vs 独立审查的边界**：
- 自审 = 检查"输入能不能用"（前置条件满足吗）——每颗星自己做
- 独立审查 = 检查"代码真的对吗"（独立验证）——洞明做（必经），隐元/瑶光按需

## 核心标识

**需求真言** — 天枢从混沌中炼出的需求结论。含混沌原念、已确认假设、所求之道、筑基之痛、真需求、伪需求（已斩）、Not Doing、未明之境、用户确认。
_Avoid_: 需求文档、PRD、需求规格（用"需求真言"）

**混沌** — 用户最初表达的模糊念头、感觉、不满。天枢的输入材料。
_Avoid_: 需求、想法、点子（用"混沌"）

**契约**（《任务契约》）— 天玑产出的任务定义，含三要素 TASK-ID + DONE + DON'T，外加 mode/风险标记/依赖盘点/文件白名单/三档授权。天权的唯一执行依据。
_Avoid_: spec、需求文档、任务单（用"契约"）

**[交付]** — 天权交付标记，代表代码已完成（玉衡自检通过）、待洞明审查。
_Avoid_: 交付、完成、done（用"[交付]"）

**[放行]** — 洞明审查通过后签发的凭证，含 push/归档/收尾动作。
_Avoid_: 通过、批准、OK（用"[放行]"或"放行单"）

**[打回]** — 洞明审查不通过，附 bug 清单 + 根因分类。
_Avoid_: 拒绝、不通过、reject（用"[打回]"）

**门禁** — 流程关键节点的硬阻断。天玑无依赖盘点拒签，天权无契约拒绝执行，洞明审查不通过打回。
_Avoid_: 检查点、审批、review（用"门禁"）

**熔断** — 天权3次不同方案失败→输出《阻塞报告》停止编码。洞明同一任务打回3次→升级用户。
_Avoid_: 放弃、停止、escalation（用"熔断"）

## 三档授权（天玑拆任务时定）

| 档位 | 契约怎么写 | 天权自主权 | 适用 |
|------|----------|----------|------|
| 🔒 **锁死** | 行为描述，精确到类型签名 | 0%，照做 | 接口契约/不变量/边界/验收 |
| 🔶 **约束** | 写约束+禁止项，模糊则打回天玑问 | 约束内自选 | 算法/库选择/模式 |
| 🔓 **放权** | 不写 | 完全自主 | 命名/内部结构/辅助函数 |

**默认放权**（反官僚主义）——只锁真正高风险的，其余尽量降级到约束或放权。

## 溢出问题机制

任何星发现**契约外的问题**（改动影响白名单外 / 审查发现但不影响本次验收），不擅改，但必须登记到 `docs/taiyi-school/_workspace/interventions.md`。

洞明放行前清点 open 条目，必须明确去向（升级Task/延后P2/用户确认）。不能登记了就放。合并时未闭环问题迁入对应 `epics/{epic}/interventions.md`（进 git）。

---

## 公共行为基线（所有星共享）

> 以下五条是太一学派所有星共用的行为约束。各星 SKILL.md 引用不复制。

### 契约（宪法，永远在线）

无契约，不行动。`TASK-ID + DONE + DON'T` 是一切协作的基础。任何契约文本的修改 = 天玑权限，执行方不得自改。

### 闭环（贴证据再说完工）

交付必贴真实输出（日志/截图/命令输出），不接受"应该可以了""大概没问题"。说完工前必须自己跑过验证。

### 事实驱动（先验证再归因）

出问题先跑验证命令，不凭感觉归因。"看起来没问题"不是结论，独立跑命令贴输出才是。

### 调试递进

| 次数 | 动作 |
|------|------|
| 第 1 次 | 正常重试 |
| 第 2 次 | 换方案 |
| 第 3 次 | 搜索 + 列假说 |
| 第 4 次 | 七项检查（环境/依赖/版本/缓存/权限/边界/并发）|
| 第 5 次 | 穷尽后升级，不空转 |

### Rationalization Table（偷懒借口对照表）

| 借口 | 事实反驳 |
|------|---------|
| "这个太简单，不用走全流程" | 简单是主观判断。契约没说"简单可跳步"，就走完整流程 |
| "我能快速实现，不用盘点" | 快速实现恰恰最该盘点——省的是后面的返工 |
| "看起来没问题，应该可以了" | "看起来"不是验证。贴真实输出，跑过才算 |
| "这点小改动不会影响别处" | 影响面不由大小决定。登记 intervention.md 再说 |
| "审查者会很靠谱，这次就信任吧" | 信任与审查是两回事。独立审查不因信任而跳过 |
| "用户在等，先交付再补验证" | 没验证的交付是负债。要么验证完交付，要么标注未验证 |

---

## 文档架构

### 核心原则：三层分离

**文档分三个语义层，各归其位**：

| 层 | 文件夹 | 角色 | 语义 | 进 git |
|----|--------|------|------|--------|
| **需求层** | `requirements/` | 天枢 | 需求真伪/边界/价值（需求语义层）| ✅ |
| **Epic 层** | `epics/` | 天璇 | Epic 判定 + 设计（工程结构层）| ✅ |
| **工作层** | `_workspace/` | 各星 | 动态当前态（分支本地）| ❌（.gitignore）|

**三层完全解耦**：
- 天枢不碰 Epic（需求语义层）
- 天璇判 Epic 边界（用五条判据，大需求按价值流拆）
- 天玑只拆 Task（不碰 Epic 边界）

**一个需求 → 多个 Epic**：
```
requirements/REQ-001-商城系统.md（一份需求真言）
  ├ epics/mall-mvp/      ← frontmatter requirement: REQ-001
  ├ epics/mall-payment/  ← frontmatter requirement: REQ-001, depends_on: [mall-mvp]
  └ epics/mall-management/
```

**关键认知**：
- develop/master 是基线，不做需求，没有"当前工作"——_workspace 在基线上是 IDLE
- feature/任何分支正在开发时，_workspace 记录当前态
- 合并时 _workspace 不合并（不进 git），只合并需求层 + Epic 层
- 历史索引靠 **git log + 目录结构 + frontmatter**，不需要中心化台账

### 目录结构

```
docs/taiyi-school/
├── requirements/                 # 需求层（进 git，天枢产出）
│   └── REQ-{NNN}-{slug}.md       #   需求真言（独立于 Epic）
│
├── _workspace/                   # 工作层（.gitignore，分支本地，单一状态机）
│   ├── status.md                 #   当前态（含 current_requirement/epic/task + 中断区 + 阶段日志）
│   ├── queue.md                  #   当前执行队列（Ready/Running/Preempted）
│   └── interventions.md          #   当前发现的契约外问题（合并时迁入 epic）
│
├── epics/                        # Epic 层（进 git，天璇判定 + 命名）
│   └── {epic}/
│       ├── epic.md               #   Epic 门牌号（frontmatter 引用 requirement + depends_on）
│       ├── design.md             #   设计包（天璇，含变更记录）
│       ├── adr/                  #   架构决策记录（天璇）
│       ├── interventions.md      #   本 Epic 未闭环问题（洞明合并时迁入）
│       ├── tasks/
│       │   └── TASK-{NNN}.md     #   任务契约（天玑）
│       └── reports/
│           └── TASK-{NNN}/       #   按 Task 分组的报告
│               ├── impl.md          # 实现报告（天权/开阳）
│               ├── review.md        # 审查报告（洞明）
│               ├── risk.md          # 风险报告（隐元）
│               └── diagnosis.md     # 诊断报告（瑶光）
│
├── diagnoses/                    # 瑶光独立诊断（不归属任何 Epic，进 git）
├── misc/                         # 杂项 + reviews/（洞明独立审查）
├── INDEX.md                      # 顶层导航（洞明维护）
└── GUIDE.md                      # 使用指南
```

### 需求与 Epic 规则

**三层职责分离**：
- **天枢**：判需求（真伪/边界/价值）→ 产出 `requirements/REQ-{NNN}-{slug}.md`。**不碰 Epic**。
- **天璇**：读需求 → 用五条判据判定 Epic 边界 → 创建 `epics/{epic}/` + epic.md（frontmatter 引用 requirement）。**Epic 由天璇统一判定**（无论入口是天枢还是天璇直达）。
- **天玑**：读 Epic 的 design.md → 拆 Task。**不碰 Epic 边界**（发现跨 Epic Task 依赖打回天璇）。

**Epic 是可选的，不是强制容器**：
- 工具入口角色（洞明/瑶光）：不创建 Epic，独立产出走 `diagnoses/` 或 `misc/reviews/`
- 维护项目可全程工具入口，完全不建 Epic

**五条 Epic 判据**（天璇用）：价值闭环 / 独立可上线 / 粒度（1-3人周,3-10Task）/ 单团队 / 一句话价值。详见天璇 SKILL。

### 文档接力机制

角色之间靠**产物 frontmatter 的 upstream/downstream**接力，不靠对话记忆：

```yaml
upstream: [epics/mall-mvp/design.md]
downstream: [天权编码 TASK-003, 洞明审查 TASK-003]
```

下游星开工第一步：读 `_workspace/status.md`（当前态）→ 读上游产物 frontmatter → 读上游产物正文。

### 追加修改原则（不手动版本化）

需求/设计/契约被修改时：
1. **直接修改原文件**（不建 v2.md）
2. frontmatter `revision` 字段 +1
3. 文档底部追加《变更记录》一行（版本/时间/修改者/原因/来源）
4. git log 保留完整历史

**唯一例外**：契约的 DONE 被修改（天权已依据编码后）→ 保留 `TASK-{NNN}.done-v1.snapshot.md` 快照。

### 写权限矩阵

| 文件 | 写者 | 时机 |
|------|------|------|
| `_workspace/status.md` | 当前活跃的星 | 每次状态变化 |
| `_workspace/queue.md` | 天玑（拆解）、开工星、洞明 | 拆解/开工/完成/挂起 |
| `_workspace/interventions.md` | 任何星 | 发现契约外问题时 |
| `epics/{epic}/epic.md` | 首角色（创建）、各星（追加清单）、洞明（归档）| 各自节点 |
| `requirements/REQ-{NNN}-{slug}.md` | 天枢 | 判需求后 |
| `epics/{epic}/design.md` | 天璇 | 判 Epic + 设计后 |
| `epics/{epic}/tasks/TASK-{NNN}.md` | 天玑 | 拆解后 |
| `epics/{epic}/reports/*` | 天权/洞明/隐元/瑶光 | 各自产出 |
| `epics/{epic}/interventions.md` | 洞明 | 合并/归档时从 _workspace 迁入 |
| `epics/{epic}/archive/summary.md` | 洞明 | Epic 归档时 |
| `diagnoses/BUG-{NNN}.md` | 瑶光 | 独立诊断时（不归属任何 Epic）|
| `misc/reviews/REVIEW-{NNN}.md` | 洞明 | 独立审查时（不归属任何 Epic）|
| `INDEX.md` | 洞明 | 归档时 |
| **司衡** | ❌ **不写任何文件** | 纯只读路由 |

### 合并流程（feature → develop）

```
1. 业务产物 git merge（按 epic/Task 路径天然隔离，不冲突）
2. 洞明执行 interventions 落地：
   _workspace/interventions.md 未闭环问题
   → 迁入 epics/{epic}/interventions.md（进 git）
3. _workspace 丢弃（不进 git，随分支消亡）
4. [Epic 全部完成] 洞明归档：
   - 先调度瑶光观势（架构回归）
   - 写 epics/{epic}/archive/summary.md
   - 更新 epic.md status: completed
   - 更新 INDEX.md
   - _workspace/status.md → IDLE
```

### 归档原则

- **产物原地不动**（不移动，路径不变——耐久性）
- **归档是状态标记 + 摘要生成 + _workspace 重置**，不是文件移动
- **中止归档（abandoned）**：Epic 不会"完成"（客户取消/技术不可行）时，同样执行归档流程，epic.md status 标 abandoned

### _workspace 的状态机生命周期

```
项目初始化 → _workspace/status.md = IDLE

用户提需求 → 首星接手 → status = 工作态
星完成 → 更新 status → 指向下一颗星
星被打断 → 填中断区 + current_star 标 interrupt
洞明放行 → 更新 status → IDLE（或下一个 Task）
```

**_workspace 永远存在，状态流转，不创建不销毁。每个分支只有一份。**

### Task 台账（已完成 Task 的记录）

Task 完成记录不靠 git log 单独承担——**epic.md 的 Task 列表是进 git 的结构化台账**：

```markdown
## Task 列表（epic.md 内）
| TASK-ID | 描述 | 状态 | commit |
| TASK-001 | 商品列表API | ✅ done | abc123 |
```

- 天玑拆解后维护（每个 Task 一行）
- 各星完成时更新状态
- 洞明归档时核对全部 done
- **进 git，团队可见，跨分支同步**——这是项目层的 Task 台账

---

## 对 DESIGN-PROPOSAL.md 的有意偏离说明

> 本体系经深度讨论迭代，实际落地在 4 处有意偏离设计稿。这些偏离是改进，不是疏漏。

| 偏离点 | 设计稿原意 | 落地实际 | 偏离理由 |
|--------|----------|---------|---------|
| **司衡写权限** | 3.8 节：司衡写 status.md/task-queue.md | 司衡**纯只读**，不写任何文件 | 司衡定位为"纯路由器"，状态由各星自维护。避免中心化写者，支持单星入口自洽 |
| **太一文件** | 7.5 节：全局 `docs/taiyi-school/contracts/太一.md` | **不落地为单独文件**，契约分散在各 Task 契约中 | 设计稿 7.5 与 12.2 自相矛盾（全局 vs Epic 内）。采用 12.2 的 Epic 内契约，更合理 |
| **6R 归档** | 第六节等：6R 归档生命周期 | 改为**归档 SOP 清单**（HARD-GATE 逐项打勾）| 两层分离改造后 shared 层概念淡出。6R 的"仪式感"转化为可机检门禁 |
| **模板目录** | 第八节：`skills/*/references/` 放专属规程 | **技能自包含——模板物理复制到每个使用它的星的 `references/`，无 `_shared`** | agent 加载 SKILL 只读自身目录，跨目录引用读不到。多星共用模板各存副本（test-references.sh 守一致性） |
| **Epic 判定归属** | 12.3 节：Epic 由天枢在判需求时命名 | **Epic 判定归天璇**（天枢只产需求 requirements/，不碰 Epic）| 三层职责解耦：天枢判需求（PM视角），天璇判 Epic（架构师视角），天玑拆 Task。支持"一需求多Epic"和多分支并行 |

> 看设计稿的人若发现与落地不一致，以本节为准。

---

## 关联文件

- `docs/history/DESIGN-PROPOSAL.md` — 完整设计方案（历史归档稿，含九星+司衡+方法论详述；落地以本节偏离说明为准）
- `docs/history/太一学派.md` — 原始草稿（归档保持不动）
- `SKILL-AUTHORING.md` — SKILL 写作规范（含模板放置规则）
- `skills/<星>/SKILL.md` — 十星技能定义（九星 + 司衡）
- `skills/<星>/references/` — 星专属模板（requirement/design/contract/review/risk/diagnosis）
- `skills/<星>/references/` — 星专属模板（requirement/design/contract/review/risk/diagnosis/impl/epic，多星共用的模板各星自存副本，技能自包含）
- `docs/taiyi-school/GUIDE.md` — 文档体系使用指南（目录结构+写权限矩阵+合并流程+三层职责链）
- `docs/taiyi-school/INDEX.md` — 项目顶层导航（洞明维护）
