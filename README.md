# lyco_dev (`/dev`) — 商业级稳健软件工程技能

以 **稳定性 · 可维护性 · 模块化 · ROI · 安全性 · 生态复用**（六大维度**并列同等重要**）为核心准则的全栈 / Rust 软件工程 Agent Skill（触发词：`/dev` 或 `lyco_dev`）。

符合 [Agent Skills](https://agentskills.io) 开放标准（`SKILL.md` + frontmatter），与 [lyco-skill](https://github.com/lilyco-42/lyco-skill) 互补：**`/lyco` 负责开工前预研与决策，`/dev` (`lyco_dev`) 负责开工后的稳健工程落地**。

## 六大工程铁律

1. **稳定性（零信任强类型 + 异常 Fallback）**：后端只接收强类型 DTO、禁止类型擦除；面对服务器断电、用户断网、上游异常提供显式 Fallback 与结构化详细报错，绝不随意崩溃。
2. **可维护性（四原则 + TOML 配置外置 + 及时提交文档）**：
   - 单类型 ≤ **4** 成员变量、单函数 ≤ **4** 参数、控制流 ≤ **4** 层嵌套（除错误处理禁止随意跳转）。
   - 单目录 ≤ **4** 子目录、目录嵌套 ≤ **4** 层；按前端 / 后端 / 数据库 / 代理端多维视角分类。
   - 业务配置与 i18n 全部抽离为 `.toml` 文件，不写死常量；每次原子变更及时 `git commit` 并沉淀目标与实现原理文档。
3. **模块化（前后端硬边界）**：后端只处理数据与强类型 API，不绘制 UI；前端负责展示、简单消毒与按契约类型转换，复用 `shadcn/ui` 等成熟生态组件。
4. **ROI（收益优先排序）**：① 商业价值 > ② 社会效益与贡献 > ③ 开发敏捷度；**优先交付 MVP Demo 校对需求**。
5. **安全性（最小攻击面）**：零信任校验、`deny_unknown_fields`、防批量刷号与双钱包硬隔离，规避 AGPL/GPL 商业协议风险。
6. **生态复用（`lib.rs` & `no_std` 优先）**：优先检索 [lib.rs](https://lib.rs)，按下载量、匹配度与许可证最小化引入 crate，`no_std` 优先。
7. **跨平台运维与测试铁律**：本地交叉编译用 `zig` + `cargo-zigbuild`，GitHub Actions 全平台矩阵覆盖 Windows / Linux / macOS / Android / iOS / HarmonyOS / Web (WASM) / `no_std` MCU；测试锚定预期需求，严禁篡改测试绕过失败，备份真实数据后在生产级环境充分实测。

## 一键安装

### Linux / macOS（Bash / Zsh / fish）

```bash
curl -fsSL https://raw.githubusercontent.com/lilyco-42/lyco_dev/main/install.sh | bash

# 安装到所有支持的 Agent（60+）
curl -fsSL https://raw.githubusercontent.com/lilyco-42/lyco_dev/main/install.sh | bash -s -- --all-agents
```

### Windows（PowerShell）

```powershell
iex (irm https://raw.githubusercontent.com/lilyco-42/lyco_dev/main/install.ps1)
```

## 目录结构（以身作则遵守 ≤4×4 原则）

```text
lyco_dev/
├── SKILL.md                         # 技能主体（/dev 触发词与六大铁律）
├── README.md                        # 项目说明与安装指南
├── LICENSE                          # MIT License
├── install.sh / install.ps1         # 跨平台一键安装脚本
├── docs/
│   └── principles.md                # 工程哲学与商业化实战教训
└── resources/
    ├── rule-of-four.md              # 四原则检查清单与 TOML 外置规范
    ├── rust-ecosystem-reuse.md      # lib.rs / no_std 选型与极速增量编译指南
    ├── roi-and-security.md          # ROI 决策矩阵、零信任边界与异常 Fallback
    └── cross-platform-and-testing.md # zig/cargo-zigbuild、GitHub Actions 全平台构建与测试铁律
```
