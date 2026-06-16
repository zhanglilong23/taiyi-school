---
name: setup
description: "初始化太一学派文档骨架。触发：/taiyi-school:setup。"
license: MIT
---

# 太一学派 · 项目初始化

你引导用户初始化太一学派文档骨架。一次性动作，后续不再调用。

## 何时用

- 新项目首次接入太一学派
- 旧项目想引入太一学派的文档体系

## 执行步骤

### 1. 创建文档骨架

```bash
mkdir -p docs/taiyi-school/requirements
mkdir -p docs/taiyi-school/_workspace
mkdir -p docs/taiyi-school/epics
mkdir -p docs/taiyi-school/diagnoses
mkdir -p docs/taiyi-school/misc/reviews
```

### 2. 初始化 _workspace 三个文件

参照 `docs/taiyi-school/_workspace/` 已存在的初始骨架（status.md / queue.md / interventions.md，本仓库已含）：
- `_workspace/status.md`：初始 current_requirement/epic/star/task 全 IDLE
- `_workspace/queue.md`：Ready/Running/Preempted 三区皆空
- `_workspace/interventions.md`：Open/Closed 皆空

### 3. 初始化顶层文件

- `INDEX.md`：需求索引/活跃Epic/已归档Epic/已归档需求 四区皆空
- `GUIDE.md`：（若用户需要）从模板拷贝

### 4. 配置 .gitignore

确保仓库根 `.gitignore` 含：
```
docs/taiyi-school/_workspace/
```

### 5. 验证

```bash
test -d docs/taiyi-school/requirements && \
test -d docs/taiyi-school/_workspace && \
test -f docs/taiyi-school/_workspace/status.md && \
test -f docs/taiyi-school/INDEX.md && \
grep -q "_workspace/" .gitignore && \
echo "太一学派骨架初始化完成"
```

## 完成后

告知用户：
- 文档骨架已就绪
- 下一步可 `@司衡 <需求>` 启动流水线，或 `@天枢 <混沌>` 单星直达判需求
- 详见 `docs/taiyi-school/GUIDE.md`

## 验证

```bash
ls docs/taiyi-school/ && echo "骨架存在"
```
