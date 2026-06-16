# 太一学派 · SKILL 写作规范

> 综合四家竞品精华（hermes-agent / agent-skills / superpowers / Matt Pocock skills），固化太一学派的 SKILL.md 写作标准。后续所有 SKILL 的编写和修订都以此为依据。
>
> 参考来源：hermes 的60字符截断+两阶段加载 / agent-skills 的 When NOT to use / superpowers 的 Iron Law+EXTREMELY-IMPORTANT / Matt Pocock 的 Core principle 定调句。

---

## 一、Frontmatter（强制）

```yaml
---
name: tianshu
description: 60字符内一句话，说能力不说实现
license: MIT
---
```

### name 字段
- 小写+连字符/数字，正则 `^[a-z0-9][a-z0-9._-]*$`
- ≤64 字符
- 必须匹配目录名（`skills/<name>/SKILL.md`）

### description 字段（最讲究的字段）

**四铁律**（汲取 hermes HARDLINE 第1条）：
1. **≤60 字符**（不是1024——60是调度者实际能看到的，超长被截断）
2. **说能力，不说实现**——"做什么"，不"怎么做"
3. **禁营销词**：powerful/comprehensive/seamless/advanced/强大/全面
4. **用通用词，不用自造术语**——description 是"广告位"，LLM 第一次看到时必须一眼懂。自造术语（混沌/需求真言/契约等）在正文第一次出现时解释，**不进 description**

**对 LLM 友好的三要素**：
1. **动词明确**（追问/拆成/写/审查）——LLM 一眼知道动作
2. **对象是通用词**（想法/需求文档/代码）——不用自造术语
3. **场景可推断**（模糊→明确/规格→代码/代码→放行）——LLM 知道输入输出

**写法**：
- 一句话，以句号结尾
- 不重复 skill 名（name 已经在索引里了）
- 可选以"Use when..."开头标明触发条件，也可直接陈述能力

**反例**：
```
❌ "一个强大的需求分析工具，能够全面地从混沌中提炼需求真言，支持正判和伪需求识别。"
   （营销词+超60字符+说实现+自造术语）

❌ "从混沌念头提炼出明确的需求真言。"
   （"混沌念头""需求真言"是自造术语，LLM 第一次看到不懂）
```

**正例**（中文，面向国内用户，通用词）：
```
✅ "通过追问把模糊想法变成明确需求。"
✅ "把需求文档拆成可执行的开发任务。"
✅ "按任务规格写代码并验证通过。"
✅ "审查代码是否合格，决定放行或打回。"
```

### 语言策略（默认中文）

**太一学派面向国内用户，除用户明确要求外，默认中文。** 各部分语言分工：

| 部分 | 语言 | 理由 |
|------|------|------|
| **description** | 中文（≤60字符）| 面向国内用户，中文语义匹配更自然；中文同样能压进60字符 |
| **核心准则** | 中文 | 给读 SKILL 的人和大模型看 |
| **HARD-GATE** | 中文 | 同上 |
| **正文全部**（方法论/门禁/流程）| 中文 | 同上 |
| **偷懒借口对照** | 中文 | 同上 |
| **验证命令** | bash | 可执行，不变 |
| **状态码**（DONE/BLOCKED 等）| 英文 | 机检字段，保留原词 |
| **术语**（epic/TASK-ID/DONE/DON'T）| 英文 | 行业通用术语，不翻译 |

### 选填字段
- `license: MIT`（建议加）
- 不需要 hermes 的 platforms/version/author/metadata（太一是角色体系，非工具封装）

---

## 二、正文结构（太一角色 SKILL 标准）

```
# {星名} · {一句话职责}

{2-3句 intro：做什么 + 不做什么}

**Core principle**: {加粗一句话，不可妥协的核心原则}

## 输入
{读什么文档/从哪来}

## 输出
{产什么文档/落到哪}

## {方法论主体}
{编号步骤/流程}

<HARD-GATE>
{绝对不可跳过的门禁，用XML标签包裹}
</HARD-GATE>

## When NOT to use（counter-triggers）
{显式列"什么时候不该用这颗星"——比 When to 更重要}

## 完成后
{产出落盘+告知下游}

## Rationalization（偷懒借口表）
| 借口 | 反驳 |

## Verification（单条验证命令）
{一条命令证明 SKILL 可用}
```

### 各章节的写法要点

**Core principle（汲取 Matt Pocock + hermes）**：
- 每星开头一句加粗不可妥协原则
- 一句话点明本质，不是长篇解释
- 例：天枢"不能一句话说清的需求，就不算明确"；洞明"禁止信任写码者单方声称"

**HARD-GATE 标签（汲取 superpowers EXTREMELY-IMPORTANT + 鲁班 HARD-GATE）**：
- 只包裹**绝对不可跳过**的门禁（不是所有规则都包）
- 用 XML 标签：`<HARD-GATE>...</HARD-GATE>`
- 语气绝对化：不可协商/不可跳过
- 例：天权"无契约不行动"、洞明"独立重跑验证，禁止信任单方声称"

**When NOT to use（汲取 agent-skills + hermes counter-triggers）**：
- 显式列"绝不做"——比"做什么"更能约束 LLM
- LLM 的倾向是"什么都管"，告诉它"什么时候别管"更有效
- 例：天枢"不做技术决策/不写代码/不替用户决定"

**Rationalization 表（四家标配）**：
- 每条都是 LLM **真实的偷懒借口** + 精确反驳
- 不是泛泛的"要努力"，是具体的"我会想X，但X是错的因为Y"
- 每星3-6条

**Verification（汲取 hermes 单条命令）**：
- 一条命令/一个检查，证明 SKILL 产出有效
- 不是叙述，是可执行的验证
- 例：`ls docs/taiyi-school/requirements/REQ-*.md && grep "所求之道" 该文件`

---

## 三、约束力分层（汲取 hermes 实例对比）

**不是所有 SKILL 都用强语气**——按角色类型分层：

| 角色类型 | 语气强度 | 技巧 | 太一对应 |
|---------|---------|------|---------|
| **纪律型**（防偷懒/防跳步）| 强 | Iron Law + HARD-GATE + Red Flags + Rationalization | 天权（编码纪律）、洞明（审查纪律）、天玑（拆解纪律）|
| **交互型**（创造性对话）| 中 | Core principle 定调 + When NOT to 边界 + 降级信号 | 天枢（需求对话）、天璇（设计对话）|
| **工具型**（纯执行）| 弱 | 速查表 + 可复制命令 + Pitfalls | （太一暂无纯工具型角色）|

**强语气的具体手法**（汲取 superpowers/hermes）：
- "Iron Law" 用代码块：`NO FIXES WITHOUT ROOT CAUSE`
- "Violating the letter is violating the spirit"——堵"我遵循精神"的狡辩
- "You MUST / NOT negotiable / NOT optional"
- Red Flags 列偷懒念头 + "ALL of these mean: STOP"

**强语气不滥用**（汲取 hermes arxiv 实例）：
- 工具型 skill 零强语气——靠精确命令取胜
- 强语气只在"需要对抗模型偷懒倾向"时用

---

## 四、LLM 友好四原则（汲取 agent-skills context-engineering）

| 原则 | 怎么做 |
|------|--------|
| **结构化** | Markdown 表格 + 编号步骤 + 代码块（LLM解析表格远好于自然语言段落）|
| **机检字段** | 产出文档用 YAML frontmatter（status/type/star/upstream/downstream），可 grep |
| **显式引用** | 星之间用文档路径引用（`读 contracts/契约-{TASK-ID}.md`），不靠对话记忆 |
| **状态自描述** | 每个产出文档 frontmatter 标 status（draft/done/approved），LLM 一眼知道该不该处理 |

---

## 五、渐进式披露（汲取 hermes 两阶段加载）

**核心**：description 是唯一常驻系统提示词的部分（60字符截断），正文按需加载。

**对写作的影响**：
- description 必须自含触发条件（让调度者60字符内判断"该不该加载这颗星"）
- 正文可以详细（按需加载时不占常驻 token）
- 重内容拆 references/（引用只深一层，防递归迷宫）

**太一的应用**：
- 当前 SKILL 不算长（<300行），暂不拆 references
- 若某星 SKILL 超 300 行，把详细方法论拆到 `references/<方法论>.md`
- SKILL.md 主体保持精简，references 按需加载

**references/ 的两种用途**：
1. **方法论拆分**：SKILL 超 300 行时，把详细规程拆到 references/（如 `active-recon-5min.md`、`smoke-test-checklist.md`）
2. **产出模板**：星的产出文档模板放 references/（如 `contract-template.md`）

**模板放置规则（技能自包含原则 · 硬约束）**：

> **技能必须自包含**——agent 加载某个 SKILL 时，只会自动发现该 SKILL 自己目录下的文件。`_shared/` 这类平级目录 agent 读不到。因此**任何被某星使用的模板，都必须物理存在于该星的 `references/` 下**，绝不靠跨目录引用。

| 模板类型 | 放哪 | 理由 |
|---------|------|------|
| **专属模板**（单星使用）| `skills/{星}/references/{模板}.md` | 跟着星走，Agent 加载 SKILL 时自然发现 |
| **多星共用模板** | **复制到每个使用的星的 `references/`**（各存一份，不共享文件）| 技能自包含的硬要求。代价是改一处要同步多份——用静态测试守一致性 |

> ❌ **禁用 `skills/_shared/`**：平级目录，agent 加载 SKILL 时读不到。曾作为"共享模板"设计，已废弃删除。

**关键：模板放进去 ≠ 会被读**。哪怕模板已在星自己的 references/，如果 SKILL 正文没显式要求读，偷懒的 LLM 也不会去看。

> **实证依据**（Claude Code 官方文档 + 独立来源确认的三层渐进式加载模型）：
>
> | 层 | 加载行为 | 对写作的要求 |
> |---|---|---|
> | YAML frontmatter（name/description）| **始终加载**，用于 skill 匹配 | description 必须 ≤60 字符自含触发条件 |
> | SKILL.md 正文 | **仅在被调用时加载**，不常驻 | 正文可详细，但避免过长（见下方过载警示）|
> | `references/` 下的文件 | **不自动加载**——必须正文显式指令让 agent 读 | 产出模板/方法论拆分都要写"用 Read 读 X" |
>
> 即"把文件放进 references/"只是让它**可被发现**，不等于会被读。**只有 SKILL 正文里写"用 Read 读 references/X.md"才会真正触发加载。** 光写"参照 X"这种描述性提及，agent 会跳过。
>
> **反向警示（勿滥用显式读）**：arXiv 评估（2602.11988）发现 context files 信息过载时反而**降低任务成功率**。因此显式 Read 指令要克制——只在"需要产出/需要方法论"的那一步触发，不要每步都读一堆 references。
>
> 来源：[Claude Code skills 官方文档](https://code.claude.com/docs/en/skills) · [Norsica: LLM doesn't load unless explicitly referenced](https://www.norsica.jp/blog/stop-putting-everything-in-agents-md) · [arXiv 2602.11988 评估](https://arxiv.org/html/2602.11988v1)因此：

<HARD-GATE>
SKILL 在产出文档的步骤里，必须把模板引用写成**显式读指令**，不能只写"参照"。
</HARD-GATE>

- ❌ `参照 skills/{星}/references/xxx-template.md`（描述性提及，LLM 可能跳过）
- ✅ `**产出前用 Read 读 `references/xxx-template.md` 按其结构填**`（显式动作指令）

当前模板归属（自包含，多星共用 = 各存副本）：

| 模板 | 使用方 | 归属 |
|------|--------|------|
| requirement-template | 天枢 | `tianshu/references/` |
| design-template | 天璇 | `tianxuan/references/` |
| contract-template | 天玑 | `tianji/references/` |
| review-template | 洞明 | `dongming/references/` |
| risk-template | 隐元 | `yinyuan/references/` |
| diagnosis-template | 瑶光 | `yaoguang/references/` |
| impl-template | 天权 + 开阳 | `tianquan/references/` **和** `kaiyang/references/`（各一份副本）|
| epic-template | 天枢 + 天璇 | `tianshu/references/` **和** `tianxuan/references/`（各一份副本）|

> 多星共用模板的副本一致性由 `tests/test-references.sh` 守护（校验各副本内容一致）。改模板时务必同步所有副本。

---

## 六、写作纪律（汲取 hermes HARDLINE + agent-skills）

1. **description ≤60字符**（硬约束，超长被截断）
2. **说能力不说实现**（description 层）
3. **禁营销词**（powerful/comprehensive/seamless）
4. **命令可复制**（贴命令必须带预期输出）
5. **正反对比**（给好例子+坏例子，比纯描述有效）
6. **counter-triggers 必有**（When NOT to use）
7. **不裸用 shell 工具名**（太一暂无此问题，但若涉及 shell，指向封装工具）
8. **Verification 单条命令**（不是叙述）
9. **references 必须显式触发读**（不写"参照 X"，写"用 Read 读 X"——references 不自动加载，仅描述性提及会被 agent 跳过。但克制使用，避免过载降效）
10. **技能自包含**（任何被本星使用的模板，物理存在于本星 references/，不跨目录引用，不用 `_shared`）

---

## 七、自查清单（写完每个 SKILL 后过一遍）

- [ ] description ≤60 字符？说能力不说实现？无营销词？
- [ ] Core principle 一句话定调？
- [ ] HARD-GATE 只包绝对不可跳的门禁？
- [ ] When NOT to use 有 counter-triggers？
- [ ] Rationalization 表是真实的偷懒借口+精确反驳？
- [ ] 产出文档用 YAML frontmatter（机检字段）？
- [ ] 星之间引用用文档路径（不靠对话记忆）？
- [ ] references 的引用是显式 Read 指令（不是"参照 X"）？且克制使用（避免过载降效）？
- [ ] 技能自包含——本星用的模板都在本星 references/，无跨目录引用？
- [ ] Verification 是一条可执行命令？
- [ ] 语气强度匹配角色类型（纪律型强/交互型中/工具型弱）？

---

## 附：四家竞品技巧归属

| 技巧 | 来源 | 太一怎么用 |
|------|------|----------|
| 60字符 description 截断 | hermes（prompt_builder.py）| description 硬约束60字符 |
| 两阶段加载 | hermes | description 自含触发条件，正文按需加载 |
| 反营销话术 | hermes HARDLINE 第1条 | description 说能力不说实现 |
| When NOT to use | agent-skills + hermes | 每星显式 counter-triggers |
| EXTREMELY-IMPORTANT 标签 | superpowers | 太一用 `<HARD-GATE>` 包裹关键门禁 |
| Iron Law 绝对化 | superpowers + hermes | "不可协商/不可跳过"语气 |
| Red Flags + Rationalization | 四家标配 | 每星偷懒借口表 |
| Core principle 定调 | Matt Pocock + hermes | 每星开头一句加粗原则 |
| Verification 单条命令 | hermes | 每星结尾一条验证 |
| related_skills 组网 | hermes | 星之间文档路径引用（太一用文档路径替代）|
| 渐进式披露 | hermes + agent-skills | 重内容拆 references/，SKILL 主体精简 |
| 正反对比 | hermes writing-plans | 给好例+坏例 |
| 语气分层（纪律强/工具弱）| hermes 实例对比 | 按角色类型定语气强度 |
