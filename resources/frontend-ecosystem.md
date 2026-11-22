# 前端开发指南与成熟生态选型（Frontend Ecosystem Guide）

遵循 `lyco_dev` 核心准则：**优先参考商业化成熟方案实现，拒绝闭门造车手搓简陋 MVP**。凡新建商业 Web 控制台、AI 平台或工作台，按以下分层直接复用头部开源生态。

---

## 1. 宿主优先与官方模板起手（禁止从零手搓 CSS）

- **AI / Agent 工作台优先接入 DSH（DeepSeek 开源网页 UI & Harness）**：涉及 AI 多轮对话、Agent 工具调用与流式工作台时，优先将业务后端封装为 MCP 服务接入 DSH（`@deepseek-ai/dsh-mcp-client`），直接复用成熟响应式布局与插件体系。
- **独立商业 Web 控制台必须基于官方模板起步**：新建任何前端应用时，**禁止从零 `create-vite` 手写 CSS 骨架**，直接复制 **`/home/lilyco/code/lilyco-template/web/`**（已预装 `lycodl` 同款 `Tailwind v4 + shadcn oklch 令牌 + Geist 字体 + sonner + tw-animate-css` 与 `new-api` 同款 `@base-ui/react + @lobehub/icons + @tanstack/react-table + cmdk`），确保每个新项目一创建即保持一致的旗舰级视觉质感。

---

## 2. 独立商业 SaaS 前端推荐技术栈（对标 2026 商业标杆）

| 能力域 | 推荐生态库 | 选型理由与使用场景 |
|---|---|---|
| **无障碍基础组件** | **`@base-ui/react`** + **`shadcn/ui`** + `class-variance-authority` + `clsx` | 零样式强耦合、无障碍完备、商业 MIT 协议，支持高度定制企业级主题 |
| **图标体系** | **`@lobehub/icons`**（AI 厂商官方矢量图标）+ **`lucide-react`**（通用线性图标） | 覆盖 DeepSeek / OpenAI / Anthropic / Google / Kimi / GLM 等官方品牌矢量图标，视觉专业度一步到位 |
| **企业级数据表格** | **`@tanstack/react-table`**（大数据量配 `@tanstack/react-virtual`） | 支持排序、筛选、分页、列显隐与虚拟滚动，取代手写脆弱 HTML 表格 |
| **服务端状态与路由** | **`@tanstack/react-query`** + **`@tanstack/react-router`** | 自动缓存、失效刷新、乐观更新与强类型路由契约 |
| **全局命令面板** | **`cmdk`**（`Cmd+K` / `Ctrl+K`） | 秒级全局搜索模型、页面、令牌与快捷操作，显著提升效率感 |
| **流式对话与 Markdown** | **`react-markdown`** + **`remark-gfm`** + `ReadableStream` / `AbortController`（或 Vercel `ai` SDK） | 真逐字 SSE 流式输出、首字延迟（TTFT）显示、随时停止生成、完整代码块与 GFM 表格渲染 |
| **数据可视化图表** | **`recharts`** / **`@visactor/react-vchart`** | 仪表盘趋势图、Token/账单分布柱状图，响应式自适应明暗主题 |
| **国际化（i18n）** | **`i18next`** + 外置语言包 | 禁止在组件中硬编码不可切换文案 |

---

## 3. 布局与视觉验收铁律

1. **视觉验收必须实机截图 + 识图自查**：每次重大 UI 变更后，必须在真实浏览器（如 `ego-browser` / Chromium）对核心页面截图并识图检查，重点排查：
   - 按钮是否异常竖排折行（全局按钮统一 `white-space: nowrap; flex-shrink: 0;`）；
   - 双栏/工作台布局是否等高填满视口（如 `height: calc(100vh - <topbar>)`）且小屏自动折叠；
   - 明暗主题（Light / Dark）对比度、表格溢出滚动与空态引导是否清晰。
2. **前后端硬解耦**：后端严禁拼接大段 HTML/CSS；前端严格按后端强类型契约调用 API，杜绝 `any`。
3. **上线引导与权限可视化**：控制台默认具备清晰的新手上手引导与 RBAC 角色状态反馈（访客 / 普通用户 / VIP / 管理员），让首次打开的用户 30 秒内知道如何操作。
