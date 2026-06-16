# 任务契约模板（天玑产出）

> 天玑拆任务后产出，每个 Task 一份契约。复制此模板填写。

```markdown
---
type: contract
task_id: TASK-{序号}
epic: {继承天璇命名的epic}
star: tianji
status: done
revision: 1
created: YYYY-MM-DD
last_modified: YYYY-MM-DD
upstream:
  - epics/{epic}/design.md
  - requirements/REQ-{NNN}.md          # 如需引用需求
downstream: [天权编码 TASK-{序号}, 洞明审查 TASK-{序号}]
mode: tianquan | kaiyang
security: normal | high
concurrency: none | involved
resource: none | managed
data: read | mutated
external: none | depended
performance: normal | critical
priority: urgent | normal | low
---

# 契约: TASK-{序号}

## 元数据
- **TASK-ID**: TASK-{序号}
- **EPIC**: {epic名}
- **粒度判断**: 一个 AI 会话能独立完成（读<10文件/改<5文件/DONE可单条命令验证）
- **工时预算**: ≤Nh
- **依赖**: {哪些TASK必须先完成，或"无"}

## WHY（业务目标）
作为{角色}，我希望{行为}，以便{价值}

## §B 依赖盘点（硬门禁：任一未就绪拒签）
| # | 依赖类型 | 名称 | 本地可用？ | 接入方式 | 未就绪后果 |
|---|---------|------|----------|---------|-----------|
| 1 | {类型} | {名称} | ✅/❌/❓ | {接入方式} | {后果} |

任一 ❌ → 拒签。任一 ❓ → 强制 escalation，不许猜。

## 🔒 锁死项（天权 0% 自主权，必须照做）

### 接口契约
{API签名/数据格式/错误模式。行为描述，不引用文件路径行号}
例：POST /api/login，body {email, password}，返回 {token, expiresIn}

### 不变量
{业务规则/状态机/数据一致性约束}
例：密码 bcrypt cost≥10；失败3次锁定15min

### DONE（验收标准 — 必含 E2E smoke）
- [ ] {业务可观察行为1}
- [ ] {业务可观察行为2}
- [ ] 异常场景覆盖 ≥3
- [ ] E2E smoke: {启动应用+触发场景+看到结果，贴真实输出}

## 🔶 约束项（天权在约束内自选，模糊则打回天玑问）
- {约束1，如"JWT库自选但必须支持refresh"}
- {约束2，如"错误响应格式遵循现有ApiError类型"}

## 🔓 放权项（天权完全自主，契约不写）
- 内部函数组织、命名、是否抽 utils

## DON'T（约束边界）
- **文件白名单**: {仅允许修改的路径，行为描述}
- **红线**: {全局不变量/禁止项}
- **Out of scope**: {明确不做的}

## §F 闸门构建 + 归档接力
- 构建命令: {}
- 测试基线: {}

---

## 变更记录

| 版本 | 时间 | 修改者 | 修改原因 | 来源 |
|------|------|--------|---------|------|
| v1 | YYYY-MM-DD | 天玑 | 初版 | 天玑拆解 |

> DONE 快照规则：若天权已依据本契约编码，事后 DONE 被修改（洞明打回→天玑补清），
> 必须保留一份 `tasks/TASK-{序号}.done-v1.snapshot.md`，记录天权当时的依据。
> 仅 DONE 变更时才保留快照，其余字段变更不用。
```

## 耐久契约四纪律（天玑落契时必守）

1. **耐久优于精确**：描述接口/类型/行为，不引用文件路径行号（会失效）
2. **行为描述非过程描述**：写"做什么"不写"怎么做"
3. **验收完整且独立可验证**：每条 DONE 能 grep/test/curl 判定
4. **显式声明边界**：Out of scope 必须写

## 反模式（天玑禁忌）

```
❌ "修改 src/auth/login.ts 第42行"        → 引用路径行号（会失效）
✅ "LoginRequest 类型应增加 mfaCode 可选字段"

❌ "在 handleSubmit 里加个 if 判断"        → 过程描述
✅ "提交时若 mfaRequired 为真，必须校验 mfaCode"

❌ "登录功能正常工作"                       → 模糊验收
✅ "POST /api/login 返回 200 + JWT；3次失败锁定"

❌ （不写 Out of scope）                    → 无边界声明
✅ "Out of scope: 不改 user 表结构；不做第三方登录"
```
