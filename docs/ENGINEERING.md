# 太一学派 · 工程化说明

> 本文档说明太一学派的工程化设施：版本管理、静态测试、方法论增强的设计依据，以及未来 hooks 拦截的展望。
> 对标 superpowers 的 docs/testing.md，但适配太一的"文档接力 + 门禁可机检"哲学。

---

## 一、版本一致性管理

### 设计

太一的所有 manifest（plugin.json / marketplace.json）的 `version` 字段必须一致。为避免手动维护漏改，采用 **superpowers 的 `.version-bump.json` 模式**：

- `.version-bump.json` 是**单一真源**——声明基准版本 + 所有需要同步的字段（支持点号路径如 `plugins.0.version`）
- `scripts/bump-version.sh` 把基准版本写到所有声明的字段

### 用法

```bash
# 改版本（写所有 manifest）
bash scripts/bump-version.sh 1.1.0

# 只校验一致性，不改文件（CI 用）
bash scripts/bump-version.sh --check

# 无参数 = --check
bash scripts/bump-version.sh
```

### 依赖

- bash + python3（跨平台，Windows Git Bash 可跑）

---

## 二、静态测试套

### 设计

太一的测试分两类：
- **静态测试**（`tests/`）：纯文件校验，不依赖跑 LLM，CI 友好，秒级完成。本节范围。
- **集成测试**（未来）：headless 跑真实会话，验证星宿协作链路。延后。

静态测试借鉴 **pua 的 evals 模式**（test-yaml-frontmatter / test-release-consistency）和 **superpowers 的 test-helpers 模式**，但聚焦太一自身的承诺校验。

### 用法

```bash
# 跑全部
bash tests/run-all.sh

# 详细输出
bash tests/run-all.sh --verbose

# 只跑指定测试
bash tests/run-all.sh -t siheng-readonly
```

### 测试清单

| 测试 | 校验什么 | 为什么重要 |
|------|---------|-----------|
| `test-frontmatter.sh` | SKILL.md 的 name 匹配目录、description ≤60 字符、无营销词、含冒号加引号 | SKILL-AUTHORING 硬约束，防触发失效 |
| `test-references.sh` | SKILL 引用的 references/ 路径真实存在、共享模板被引用 | 防文档接力断裂 |
| `test-siheng-readonly.sh` | 司衡 SKILL 正文无写文件指令（Write/Edit/mkdir） | **兑现"司衡纯只读"宪法承诺**，核心守卫 |
| `test-version-consistency.sh` | 所有 manifest 版本一致 + plugin name 匹配目录 | 防发布漏改 |
| `test-methodology-terms.sh` | 复盘四步法/军令状/蓝军前置术语存在 + 军令状无羞辱措辞 | 防方法论增强被误删，守住反谄媚底线 |

### fail-pass 原则

测试用 **fail-pass**（非 fail-stop）：校验失败逐条报错、末尾汇总，不中途崩溃。CI 可根据退出码判断（0=全过，1=有失败）。

---

## 三、方法论增强（本轮新增）

本轮从大厂方法论汲取了三项增强，落地到对应 SKILL。设计依据是 pua 的大厂方法论库（阿里复盘/华为军令状/华为蓝军），但**严格剔除与太一冲突的部分**。

### 3.1 复盘四步法（阿里 + 华为）

**落点**：洞明归档 SOP（`skills/dongming/SKILL.md`）+ epic 模板（`skills/tianshu/references/epic-template.md` 与 `skills/tianxuan/references/epic-template.md`，技能自包含各存副本）

**汲取内容**：
- 阿里复盘四步：回顾目标 → 评估结果 → 分析原因 → 总结规律（沉淀 SOP）
- 华为流程固化："个人英雄不可规模化，流程能力可以。每次解决问题后必须固化为可复用 SOP"

**太一的改造**：把洞明归档的弱可选项"经验教训"升级为**强制四步复盘表**，第四步产物必须是可被未来同类 Epic grep 复用的规程（非感想）。这接住太一"文档接力、不靠记忆"的哲学。

**剔除的内容**：阿里"揪头发""三板斧"等话术（与太一诚实风格冲突）。

### 3.2 接单军令状（华为）

**落点**：天权（`skills/tianquan/SKILL.md`）+ 开阳（`skills/kaiyang/SKILL.md`），开工盘点前

**汲取内容**：华为军令状——"我对结果负责不对借口负责 / 不把未验证报成已完成 / 不把该自查的转嫁给用户 / 交付必须是证据化结果"

**太一的改造**：执行方（天权/开阳）在开工前自我承诺 4 条。太一的"契约"是天玑产出的（约束任务），执行方此前缺主体性表达，军令状补上这一层。

**关键底线**：**学华为"自我加压"，不学 pua 的"羞辱性施压"**。太一天枢明确反谄媚，军令状是责任承诺不是人格侮辱。`test-methodology-terms.sh` 会守这条底线（检测军令状不得含"毕业/3.25/羞辱/谩骂"等 pua 式措辞）。

### 3.3 蓝军前置（华为）

**落点**：天璇（`skills/tianxuan/SKILL.md`）定设计后 + 天权开工盘点第 6 问

**汲取内容**：华为蓝军思维——"方案输出前，强制从反方视角攻击自己的方案：最可能在哪里失败？哪个边界 case 会打脸？"

**太一的改造**：太一原本**有蓝军但只在编码后**（洞明对抗式审查）。本轮把蓝军前移到设计阶段（天璇"第四步半"）和编码开工前（天权第 6 问），把洞明打回的概率前移，降低返工成本。

### 明确不汲取的

| pua 的东西 | 为什么太一不汲取 |
|-----------|-----------------|
| 压力等级 L0-L4 / 失败施压 / 揶揄话术 | 违反太一反谄媚底线 |
| 赛马机制 / A-B Test / 10-100-1000 用户法则 | 偏 toC 产品运营，太一是 toDev 工程方法论 |
| OKR / IPD-DCP / 铁三角团队管理 | 与太一九星分工冗余 |

---

## 四、hooks 拦截（当前状态：观望）

### 现状

太一当前仅有一个 `SessionStart` hook（`hooks/hooks.json`），用于会话启动时打印斜杠命令提示。**无 PreToolUse / PostToolUse 等运行时门禁 hook**。

### 为什么暂不做

经评估，运行时门禁 hook（如"天权无契约拒绝 Write""司衡激活时拒绝写文件"）存在技术约束：
- 司衡是纯只读路由器，设计上不写 `status.md` 的 `current_star`，hook 难以可靠判断"当前哪个星在活跃"
- 契约的文件白名单是 DON'T 区块的散文（非结构化 frontmatter），hook 精确匹配容错要求高

用户决策：**先完善 SKILL 体系 + 工程化基建，hooks 拦截先观望**。当前门禁由两层守：
1. SKILL 的 HARD-GATE（LLM 读到就遵守，第一道）
2. 静态测试（`test-siheng-readonly.sh` 等校验 SKILL 内容合规，第二道）

### 未来若启用的设计原则

若后续决定启用 hooks 拦截，须遵守：

1. **fail-open 铁律**：hook 脚本出错（异常/依赖缺失）时必须放行（exit 0），绝不误杀正常工作流。宁可放过（退回 SKILL 自觉），不可误杀。
2. **平台无关逻辑**：门禁逻辑写成平台无关脚本（`hooks/_lib/*.sh`），各平台只配入口（Claude 的 hooks.json / Codex 的 config.toml / Gemini 的 settings.json）。
3. **双保险**：hooks 是 SKILL HARD-GATE 的机械兜底，不是替代。hooks 全失效时太一仍能靠 SKILL 正常运转。

> hooks 的跨平台可行性已网搜确认：Claude Code（PreToolUse deny）、Codex CLI（v0.122.0+ PermissionRequest）、Gemini CLI（BeforeTool deny）均支持工具级拦截。

---

## 五、发布流程

```
1. 改代码/SKILL
2. 跑静态测试：bash tests/run-all.sh  （必须全绿）
3. 改版本：bash scripts/bump-version.sh <新版本>
4. （未来）打 tag：git tag v<新版本>
5. （未来）CI 自动跑测试 + 发 release
```

静态测试是发布的硬门禁——测试不通过不许发版。

---

## 六、与竞品的工程化对比

| 维度 | superpowers | pua | **太一（本轮后）** |
|------|-------------|-----|------------------|
| 版本管理 | ✅ .version-bump.json + bump.sh | ✅ test-release-consistency | ✅ .version-bump.json + bump-version.sh |
| 静态测试 | ✅ tests/（含集成）| ✅ evals/（15 脚本）| ✅ tests/（5 静态测试）|
| 门禁 hooks | 弱（仅 SessionStart）| ✅ 7 类 11 个（含防作弊）| ⏳ 观望（SKILL HARD-GATE + 静态测试双守）|
| 方法论增强 | 无（纯 skill）| ✅ 大厂风味（含施压）| ✅ 复盘/军令状/蓝军（剔除施压）|
| 多平台 | ✅ 5 平台 + sync 脚本 | ✅ 11 平台深度适配 | ⏳ 仅 Claude（延后）|

**太一的定位**：方法论深度对标竞品顶级，工程化从"原型级"升到"可发布级"，多平台与运行时 hook 留作后续演进。

---

## 关联文件

- `.version-bump.json` — 版本字段声明
- `scripts/bump-version.sh` — 版本管理脚本
- `tests/run-all.sh` — 测试套入口
- `tests/test-*.sh` — 各静态测试
- `skills/dongming/SKILL.md` — 复盘四步法落点
- `skills/tianquan/SKILL.md` / `skills/kaiyang/SKILL.md` — 军令状落点
- `skills/tianxuan/SKILL.md` — 蓝军前置落点
- `CONTEXT.md` — 偏离说明（方法论增强是对 DESIGN-PROPOSAL 的有意改进）
