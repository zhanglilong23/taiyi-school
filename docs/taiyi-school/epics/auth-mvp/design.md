---
type: design
epic: auth-mvp
star: tianxuan
status: done
revision: 1
created: 2026-06-16
last_modified: 2026-06-16
upstream:
  - requirements/REQ-001-用户登录.md
downstream: [天玑拆任务]
---

# 设计包

## 技术假设（已确认/已纠正）

1. 数据存储用关系型数据库（基于项目已有 PostgreSQL 依赖）
2. 密码用 bcrypt 加密存储（cost ≥ 10）
3. 凭证用 JWT（基于项目已有 jsonwebtoken 依赖）
→ 这些技术假设已与用户确认。

## 选定方案 + ADR

**选定**: JWT + bcrypt，单接口登录
**理由**: 项目已有 JWT 中间件，bcrypt 是密码哈希事实标准
**淘汰了什么**:
- 方案B（session + redis）—— 增加 redis 依赖，MVP 过重
- 方案C（OAuth proxy）—— 需求明确不要第三方

**ADR**: 本设计即决策记录，无需独立 ADR 文件（无技术选型争议）。

## 架构设计
- **模块划分**: `auth/login.ts`（登录逻辑）+ `auth/jwt.ts`（签发验证）+ `db/users.ts`（用户查询）
- **接口定义**:
  ```
  POST /api/auth/login
  body: { phone: string, password: string }
  200: { token: string, expiresIn: number }
  401: { error: "invalid_credentials" }
  422: { error: "validation_error", details: [...] }
  ```
- **约束清单**（给天玑做锁死项的依据）:
  - 不可变：密码 bcrypt cost ≥ 10；token 有效期 2h
  - 不变量：登录失败不泄露用户是否存在（统一返回 invalid_credentials）
  - 数据流：phone+password → 查 users → bcrypt.compare → 签 JWT → 返回
- **数据流**: 请求 → 参数校验 → 查用户 → 校验密码 → 签发 token → 返回

## 风险清单

| 风险 | 应对 |
|------|------|
| 暴力破解 | 登录失败计数（本 Epic 只埋点，限流后续 Epic） |
| 密码明文传输 | 假设上层有 HTTPS（部署层职责，非本 Epic） |

---

## 第四步半·蓝军前置（定设计后、交天玑前）

> 设计已含此步骤的示例产出，供新用户参考蓝军自检长什么样。

1. **这个设计最可能在哪里失败？** bcrypt.compare 的时序攻击（已通过统一错误响应缓解）
2. **哪个边界 case 会打脸？**
   - 用户不存在（phone 不在表里）→ 必须返回与"密码错"相同的错误，防枚举
   - 密码字段含特殊字符导致 SQL 注入风险 → 必须参数化查询
3. **天玑拆出来的 Task 里，哪个最可能让天权卡住？** 验收里的"3 次失败锁定"——本 Epic 只埋点不做，天玑别把锁定逻辑锁进 DONE

> 蓝军思维：方案输出前，先当自己的对手。不等洞明来教训。

---

## 变更记录

| 版本 | 时间 | 修改者 | 修改原因 | 来源 |
|------|------|--------|---------|------|
| v1 | 2026-06-16 | 天璇 | 初版 | @天璇 设计 |
