# 太一九星 · 上下文（CONTEXT）

## 定位

太一学派是一套**角色化 AI 协作流程**。九颗星各司其职，通过 `.taiyi/_workspace/status.md` 和 `.taiyi/_workspace/queue.md` 两个状态文件流转。

**核心原则**：
1. **手动模式为默认**：每颗星都可以被用户独立召唤（`@天枢`、`@天璇` …），完成自己的职责后更新状态文件并给出明确的下一步手动召唤指令。
2. **司衡是可选自动路由增强层**：在支持 skill 间互调的运行环境中，司衡可代替用户自动唤醒 `next_star`；在不支持的环境中，司衡只给出手动召唤建议。司衡是否存在，不影响九星独立完成自己的流程。
3. **状态文件是九星与司衡之间的唯一接口**。

## 九星角色速查

| 星 | 职责 | 输入 | 输出 | next_star（单点出口）|
|---|---|---|---|---|
| 天枢 | 判需求 | 混沌 | 需求真言 REQ | 天璇 |
| 天璇 | 设计 + 判 Epic | 需求真言 | 设计包 design.md | 天玑 |
| 天玑 | 拆任务 | 设计包 | 任务契约 TASK | 天权/开阳（按 mode）|
| 天权 | 文心编码 | 契约(mode=tianquan) | 代码 + impl.md | 玉衡 |
| 开阳 | 武毅攻坚 | 契约(mode=kaiyang) | 代码 + impl.md | 玉衡 |
| 玉衡 | 编码后自检 | 代码 | 自检摘要 | （天权/开阳追加摘要后）洞明 |
| 洞明 | 独立审查/归档 | 代码+契约+impl | review.md / 归档 | 天权/开阳 / 瑶光 / IDLE |
| 隐元 | 非功能性风险扫描 | 代码（洞明触发）| risk.md | 洞明 |
| 瑶光 | 诊断根因 / 架构体检 | 症状/打回单 | diagnosis.md / assessment.md | IDLE（手动建议路由）|

## 主链路

```
天枢(判需求)
  → 天璇(设计+判Epic)
    → 天玑(拆任务)
      → 天权/开阳(编码)
        → 玉衡(自检)
          → 洞明(审查)
            → [有ready Task] 天权/开阳
            → [无ready Task, Epic未归档] 瑶光(观势)
            → [Epic已归档] IDLE
```

**异常/分支**：
- 洞明打回 → 瑶光查根因 → 按根因路由回天权/天璇/天玑/天枢
- 隐元发现 P0/P1 风险 → 洞明打回
- 隐元发现 P2 风险 → 登记 intervention，洞明可放行但需跟踪

## `_workspace/status.md` 字段标准

| 字段 | 含义 | 必填 |
|------|------|------|
| `current_star` | 当前完成或正在执行的星 | 是 |
| `current_star_status` | 当前星状态：IDLE/RUNNING/DONE/REJECTED/BLOCKED/WAITING_USER | 是 |
| `next_star` | 默认下一步星（单点出口） | 是 |
| `next_action` | 下一步动作的人类可读描述 | 是 |
| `manual_invoke` | 手动模式下用户应输入的召唤指令 | 是 |
| `block_reason` | REJECTED/BLOCKED/WAITING_USER 时必填 | 条件必填 |

## 拒绝机制

任何星在 R1（输入不符）/ R2（错误@使用）/ R3（能力边界）时：
1. 说清拒绝原因
2. 更新 `status.md`：`current_star_status=REJECTED/BLOCKED/WAITING_USER`，`block_reason` 写明根因与建议路由
3. 给出 `manual_invoke`

## 手动模式 vs 司衡自动模式

### 手动模式（默认）

用户按每颗星完成后的提示语手动召唤下一颗星：

```markdown
【太一流转】
- 当前完成：{星名} 已完成 {产出物/动作}
- 下一步：{next_action} → 请手动 {manual_invoke}
- 前置状态：{ready / blocked / 等待用户输入}
- （可选）环境支持自动流转时：也可 @司衡 继续
```

### 司衡自动模式（可选）

在支持 skill 间互调的环境中：

```
用户 @司衡 → 司衡读 status.md → 按 next_star 尝试自动唤醒 → 目标星执行 → 目标星更新 status.md → 循环
```

自动唤醒失败时，司衡一次性降级为手动提示，不重试、不空转。

## 玉衡-洞明过渡保障

1. 天权/开阳编码完成 → 手动 @玉衡 自检
2. 玉衡自检通过 → 天权/开阳在 `impl.md` 末尾追加【玉衡自检摘要】
3. 天权/开阳更新 `status.md`：`current_star=玉衡(done)`, `next_star=洞明`
4. 洞明开工前自审：`grep -q '^## 玉衡自检摘要$' reports/TASK-*/impl.md`
   - 命中 → 进入审查
   - 无命中 → R1 拒绝："缺玉衡自检摘要，请先 @玉衡 自检"

## 司衡行为约束

1. 司衡只读状态文件，不写任何文件
2. 司衡自动唤醒失败后一次性降级，不重试、不空转
3. 司衡在手动模式下只输出"请手动 {manual_invoke}"，不替用户决定
4. 司衡读到 `current_star_status=REJECTED/BLOCKED` 时，按 `block_reason` 中的建议路由回溯或升级用户
