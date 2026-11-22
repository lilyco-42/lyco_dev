---
name: lyco_dev
agent_created: true
description: "Production-grade Rust & full-stack engineering workflow (/dev) prioritizing Stability, Maintainability, Modularity, ROI, Security, and Ecosystem Reuse. Enforces Zero-Trust typed APIs (no type erasure, strict frontend-backend contracts), graceful fallback on power-loss/network-drop, the Rule of 4 (<=4 struct fields, <=4 function params, <=4 nesting depth, <=4 subdirs/folder, <=4 dir depth), externalized TOML config & i18n, backend-no-UI separation, lib.rs & no_std-first minimal crate reuse, and commercial-first MVP ROI. Trigger with /dev, lyco_dev, or when architecting, coding, or reviewing Rust/full-stack commercial software."
---

# lyco_dev (`/dev`) — 商业级稳健软件工程规范

## Scheduling

### Goal
以 **稳定性 · 可维护性 · 模块化 · ROI · 安全性 · 生态复用**（六大维度**并列同等重要**，而非前后次序关系）为最高准则，约束从架构设计、选型、编码到提交的每一步，打造**零信任类型安全、商业版权干净、极易维护、充分复用成熟生态、可快速迭代 MVP** 的生产级软件（核心优先 Rust + 现代组件化前端）。

> **起源教训**：曾因依赖外部 AGPL-3.0 协议且存在上游漏洞的中转项目（如 `new-api`），遭遇批量注册刷号与 Token 窃取及不可闭源商用的风险。自此确立：**核心商业系统必须自主可控、零信任强类型边界、可商用授权、最小攻击面**。

### Intent signature
- 用户输入 `/dev` 或提及 `lyco_dev`
- "按我们的工程规范开发 / 重构 / 评审 XXX"
- 搭建新的商业 Rust 后端 + 现代前端（shadcn/ui 等）项目
- 代码审查：检查类型安全、四原则复杂度、配置外置、防刷安全与异常处理

### When to use
- 需求与方向已确认（前置预研可先走 `/lyco`），正式进入**架构设计、脚手架搭建、编码实现、代码审查与重构**阶段。
- 构建商业级后端服务、AI 网关、支付/账本系统、跨端应用或桌面工具。

### When NOT to use
- 需求尚未澄清、还没决定是否自研 -> 先用 `/lyco` 做预研与 build-vs-buy 决策。
- 一次性 20 行临时脚本 -> 不必强制拆多 crate，但仍遵守不吞错与零信任输入。

---

## Six Pillars (六大工程铁律 — 严格执行)

### 1. 稳定性（Stability & Zero-Trust Type Safety）
- **零信任用户输入**：后端从开发第一天起**只接受明确强类型 DTO**（`newtype` / `enum` / 校验结构体），前端必须按后端 API 契约传入精确类型。
- **禁止类型擦除**：严禁在核心业务边界滥用 `serde_json::Value`、`HashMap<String, String>` 或 TypeScript `any` 来绕过类型检查；**用编译期类型验证挡住非法状态**，不靠运行时“猜字段”。
- **异常 Fallback 与结构化报错**：
  - 针对 **服务器断电**（WAL / 事务原子性 / 幂等恢复）、**用户断网**（SSE 断连按已用额度精确核销 / 断点续传）、**上游超时与限流**（熔断切换 / 失败回滚），必须提供明确 Fallback。
  - 所有错误使用结构化错误类型（如 `thiserror`），抛出**清晰错误码 + 上下文原因 + 修复提示**，严禁生产代码出现 `.unwrap()` / `.expect()` / `panic!()` 或吞错返回含糊信息。

### 2. 可维护性（Maintainability — 「四原则」+ 配置外置 + 文档提交）
严格执行 **「四原则（Rule of 4）」**（详见 `resources/rule-of-four.md`）：
- **类型 ≤ 4 成员变量**：单个 `struct` / 类型不超过 **4 个字段**；超出时拆分为语义清晰的子值对象组合。
- **函数 ≤ 4 参数**：单个函数参数不超过 **4 个**；超出时封装为强类型 `Input` / `Context` 结构体。
- **逻辑 ≤ 4 层嵌套**：函数内控制流嵌套不超过 **4 层**；用 early return / `?` 卫语句展平。
- **禁止随意跳转分支**：除错误处理（`?` / 卫语句提前返回）外，禁止复杂多出口跳转与隐式控制流。
- **目录 ≤ 4×4**：单个文件夹下不超过 **4 个子文件夹**，目录总嵌套深度不超过 **4 层**；按多维视角（**前端 `web/`、后端 `server/`、数据库 `db/`、代理网关 `gateway/`**）清晰划分边界。
- **配置与文案彻底外置（TOML）**：业务参数、费率、限流阈值、**i18n 多语言词条** 必须抽离至 `.toml` 配置文件，**严禁写死在代码常量中**，确保外部维护者无需改代码即可运维与本地化。
- **及时 `git commit` + 原理文档**：每个原子功能/修复完成后及时提交，并在 Commit Message 与 `docs/` 中写明 **本次代码目标（Goal）** 与 **实现原理（Design & Why）**。

### 3. 模块化（Modularity & Hard Boundaries）
- **前后端职责硬隔离**：
  - **后端**：只负责数据处理、业务规则、持久化与强类型 API；**绝不在后端拼接或绘制 UI**。
  - **前端**：只负责数据展示、交互与基础输入消毒；严格按后端 OpenAPI/类型契约做类型转换与 XSS/注入防护，禁止向后端随意传非约定类型。
- **Cargo Workspace 细粒度拆分**：将纯领域核心（`*-core`）、协议适配、存储层、上游客户端与薄 HTTP 路由层分离，隔离重依赖，确保日常增量编译控制在 **2–5 秒**。
- **前端组件化与成熟宿主优先**：
  - **优先参考并复用商业化成熟方案实现，拒绝闭门造车手搓简陋 MVP**：动工前先对标同领域成熟商业产品的布局、信息架构、权限体系（如访客 / 普通用户 / VIP / 管理员分级）与完整交互体验，严禁用残缺的“玩具 Demo”或假交互（如非真流式、无引导页面）充当可用版本。
  - **成熟 UI 宿主与官方起手模板**：AI / Agent 类交互工作台优先接入 **DSH（DeepSeek 开源网页 UI & Harness）** 复用其成熟布局与插件体系；独立 Web 控制台必须基于 **`lilyco-template/web`** 官方融合模板起步（预装 `lycodl` 视觉底座 + `new-api` 前端生态：`Tailwind v4`、`shadcn` `oklch`、`Geist`、`@base-ui/react`、`@lobehub/icons`、`@tanstack/react-table`、`cmdk`、`sonner`），杜绝从零手搓粗糙布局。

### 4. ROI（Commercial-First Decision Order）
每次技术/产品决策按以下顺序权衡收益（详见 `resources/roi-and-security.md`）：
1. **商业价值（第一优先）**：直接服务营收闭环、防资金漏洞、商业协议干净（拒绝 AGPL/GPL 传染风险）。
2. **社会效益与贡献（第二优先）**：沉淀可复用开源组件/Skill/文档，形成长期复利。
3. **开发敏捷度（第三优先）**：**优先参考并复用商业化成熟方案实现**，直接对齐成熟产品的完整可用体验与工程水准，**不要自己从零闷头写残缺的简陋 MVP**。

### 5. 安全性（Security & Anti-Abuse）
- **最小攻击面**：后端仅接受强类型白名单输入，拒绝未声明字段（`#[serde(deny_unknown_fields)]`）。
- **防刷与账本风控**：高价值/不可复制资源（AI 算力、代理专线、VIP 订阅）实行**双钱包硬隔离**（实付余额 vs 赠送/签到积分），严防批量注册与免费积分套利；裂变返佣仅在实付订单结算后触发并支持退款冲正。

### 6. 生态复用（Ecosystem Reuse — 与稳定/安全并列的一等原则，`lib.rs` & `no_std` 优先）
- **禁止重造已有成熟轮子，优先对标成熟开源实现**：动工前先调研同领域高星开源项目架构与 **`https://lib.rs` / npm 头部成熟生态库**（如 `tower` / `tower_governor` / `tower-http`、标准流式解析与可视化组件库等），直接借鉴并复用成熟工程范式，杜绝手写简陋替代品。
- **选型标准**：综合 **下载量 + 维护活跃度 + 需求匹配度 + 许可证（MIT/Apache-2.0 优先）** 最小化引入；**优先选择 `no_std` 友好、零重依赖的 crate**。

### 7. 跨平台运维与测试铁律（Cross-Platform Ops & Testing Integrity）
- **跨平台全端构建**（详见 `resources/cross-platform-and-testing.md`）：
  - 本地交叉编译优先使用 **`zig` + `cargo-zigbuild`**。
  - 使用 **GitHub Actions** 自动化构建全平台产物：**Windows / Linux / macOS / Android / iOS / HarmonyOS / Web (WASM) / `no_std` MCU**。
- **测试铁律（绝不造假过测）**：
  - 先评估并确定需求与预期效果，再写充分覆盖正常与异常边界的测试。
  - **严禁通过修改测试、削弱断言来绕过失败**；仅在**确认需求变更**后才允许同步修改测试。
  - 上线前**先备份真实环境数据**，尽量在贴近生产的真实环境中完成端到端实测验证，不停留在纯 Mock。

---

## Structural Flow (开发执行闭环)

1. **SCOPE & ROI**：用一句话确认本次 MVP 目标，按「商业 > 社会 > 敏捷」核对 ROI；检查是否已有 `lib.rs` / 前端生态组件可直接复用。
2. **ARCHITECT**：按「前端 / 后端 / 数据库 / 代理端」视角设计 ≤4×4 目录结构与 TOML 外部配置 Schema；在 `core` 层先定义强类型 API 契约。
3. **IMPLEMENT**：严格遵守四原则（≤4 字段/参数/嵌套）与零信任类型校验；后端不画 UI；为断电/断网/上游异常编写显式 Fallback 与结构化报错。
4. **VERIFY**：跑通强类型单元测试、异常边界测试（含断连/非法输入/防刷）与最小可运行 Demo。
5. **COMMIT & DOC**：及时 `git commit`，同步更新 `docs/` 说明本次代码目标与实现原理。

---

## Guardrails
1. **零容忍 `.unwrap()` / `any`**：核心链路禁止未受控 panic 与类型擦除。
2. **超 4 即拆**：发现结构体 >4 字段、函数 >4 参数或 >4 层嵌套、目录 >4 子目录，必须立即重构拆分。
3. **配置零硬编码**：发现写死在代码中的业务阈值、密钥或 i18n 文案，立即抽离到 `.toml`。
4. **后端零 UI**：严禁在 Rust 后端代码中硬拼大段 HTML/CSS 页面作为长期方案（前后端必须解耦）。
5. **许可证红线**：商业闭源项目引入任何 crate 或上游组件前必须核验协议，拒绝 AGPL/GPL 传染。
6. **测试零妥协**：严禁修改测试来绕过失败（除非需求经明确确认变更）；发布前必须备份真实数据并在真实/准生产环境实测。

## References
- 四原则与目录/配置/Git 检查清单：`resources/rule-of-four.md`
- `lib.rs` 与 `no_std` 生态选型及 Cargo 极速编译指南：`resources/rust-ecosystem-reuse.md`
- 前端开发指南与成熟生态选型（`@base-ui/react`、`@lobehub/icons`、`@tanstack/react-table`、`cmdk`、DSH）：`resources/frontend-ecosystem.md`
- ROI 评估矩阵、零信任边界与异常 Fallback 规范：`resources/roi-and-security.md`
- 跨平台 `zig`/`cargo-zigbuild`、GitHub Actions 全平台矩阵与测试铁律：`resources/cross-platform-and-testing.md`
- 背景与设计哲学：`docs/principles.md`
