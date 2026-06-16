---
type: contract
task_id: TASK-001
epic: auth-mvp
star: tianji
status: done
revision: 1
created: 2026-06-16
last_modified: 2026-06-16
upstream:
  - epics/auth-mvp/design.md
  - requirements/REQ-001-用户登录.md
downstream: [天权编码 TASK-001, 洞明审查 TASK-001]
mode: tianquan
security: high
concurrency: none
resource: none
data: read
external: none
performance: normal
priority: normal
---

# 契约: TASK-001

## 元数据
- **TASK-ID**: TASK-001
- **EPIC**: auth-mvp
- **粒度判断**: 一个 AI 会话能独立完成（读 3 文件 / 改 3 文件 / DONE 可单条 curl 验证）
- **工时预算**: ≤4h
- **依赖**: 无

## WHY（业务目标）
作为终端用户，我希望用手机号和密码登录，以便获得访问受保护资源的身份凭证。

## §B 依赖盘点（硬门禁：任一未就绪拒签）
| # | 依赖类型 | 名称 | 本地可用？ | 接入方式 | 未就绪后果 |
|---|---------|------|----------|---------|-----------|
| 1 | 数据库 | PostgreSQL | ✅ | docker-compose up | 无法存储用户 |
| 2 | 依赖包 | jsonwebtoken | ✅ | package.json 已含 | 无法签 JWT |
| 3 | 依赖包 | bcrypt | ✅ | package.json 已含 | 无法哈希密码 |

## 🔒 锁死项（天权 0% 自主权，必须照做）

### 接口契约
```
POST /api/auth/login
body: { phone: string, password: string }
成功 200: { token: string, expiresIn: 7200 }
失败 401: { error: "invalid_credentials" }
参数错 422: { error: "validation_error", details: [...] }
```
错误响应格式遵循现有 ApiError 类型。

### 不变量
- 密码 bcrypt cost ≥ 10
- token 有效期 2h（7200 秒）
- 用户不存在与密码错误返回**相同**的 invalid_credentials（防用户枚举）

### DONE（验收标准 — 必含 E2E smoke）
- [ ] POST /api/auth/login 正确凭证返回 200 + JWT（解出 phone 字段）
- [ ] 错误密码返回 401 + invalid_credentials
- [ ] 不存在的手机号返回 401 + invalid_credentials（与密码错一致，非 404）
- [ ] 缺少字段返回 422 + validation_error
- [ ] E2E smoke: `启动服务 + curl 登录 + 解析 token` 贴真实输出

## 🔶 约束项（天权在约束内自选，模糊则打回天玑问）
- 路由注册方式遵循现有 Express router 模式
- bcrypt 调用方式自选（sync/async 均可，async 优先）

## 🔓 放权项（天权完全自主，契约不写）
- 内部辅助函数命名、是否抽 validatePhone 工具

## DON'T（约束边界）
- **文件白名单**:
  - 新建 `src/auth/login.ts`、`src/auth/jwt.ts`
  - 修改 `src/routes/index.ts`（挂载路由）、`src/db/users.ts`（新增 findByPhone）
  - 新建 `src/auth/__tests__/login.test.ts`
- **红线**: 不修改 users 表结构；不实现注册；不实现密码找回
- **Out of scope**: 登录限流、MFA、第三方登录

## §F 闸门构建 + 归档接力
- 构建命令: `npm run build`
- 测试基线: `npm test`

---

## 变更记录

| 版本 | 时间 | 修改者 | 修改原因 | 来源 |
|------|------|--------|---------|------|
| v1 | 2026-06-16 | 天玑 | 初版 | 天玑拆解 |
