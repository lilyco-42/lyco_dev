# 可选：lilyco 生态专用栈（存在时优先使用）

> [!NOTE]
> 本文件是 **可选扩展**，不是 `lyco_dev` 通用规则。仅当当前环境/团队已具备下列 lilyco 生态组件时才优先使用；
> 不存在时一律回退到 `SKILL.md` 与其他 `resources/*.md` 中的通用、可移植做法，**不得因缺少这些私有组件而阻塞开发**。

## 1. 前端起手模板与 UI 宿主
- **`lilyco-template/web`（本机路径如 `~/code/lilyco-template/web/`）**：新建独立 Web 控制台时直接复制该模板起步，已预装：
  - `lycodl` 视觉底座：`Tailwind v4` + `shadcn` `oklch` 令牌 + `Geist` 字体 + `sonner` + `tw-animate-css`；
  - `new-api` 前端生态：`@base-ui/react` + `@lobehub/icons` + `@tanstack/react-table` + `cmdk`。
- **DSH（DeepSeek 开源网页 UI & Harness）**：AI 多轮对话 / Agent 工具调用 / 流式工作台类需求，优先把业务后端封装为 MCP 服务接入 DSH（`@deepseek-ai/dsh-mcp-client`），复用其布局与插件体系。
- **视觉验收浏览器**：可用 `ego-browser` 实机截图 + 识图自查。

## 2. Rust 编译加速专用件
- **`lilyco-dylib`**：将 `tokio` / `axum` / `reqwest` / `turso` / `ring` 等重依赖聚合为 `crate-type = ["dylib"]` 共享库（`liblilyco_dylib.so`），Debug 期动态链接；生产发布仍打静态 `musl` 单二进制。
- **`kuake` CLI 冷启动缓存**：按 `os-arch-rustc-<ver>-<lock_hash>` 将 `liblilyco_dylib.so` + `sccache` 打包为 `.tar.zst`，上传夸克网盘 `/lilyco-rust-cache/`；新机 / 空闲机 / CI 拉取解压，冷启动从分钟级降到秒级。
- **`mold` + `clang` 链接**：lilyco 开发机默认已装，`.cargo/config.toml` 直接启用（通用写法见 `rust-ecosystem-reuse.md`）。

## 3. 回退对照表
| lilyco 专用件 | 不存在时的通用回退 |
| --- | --- |
| `lilyco-template/web` | 任一成熟开源 starter（Vite/Next + Tailwind + `shadcn/ui`），按 `frontend-ecosystem.md` 选型补齐 |
| DSH | 成熟开源 Chat/Agent UI 宿主，或基于 `frontend-ecosystem.md` 流式对话栈自建 |
| `lilyco-dylib` | 自建 workspace 级 `dylib` crate，或仅用共享 `target-dir` + `sccache` |
| `kuake` 缓存 | GitHub Actions cache / `sccache` 远端存储（S3/GCS 等） |
