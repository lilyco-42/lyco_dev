# 跨平台全端构建运维与测试铁律

## 1. 跨平台交叉编译：`zig` + `cargo-zigbuild` 是好伙伴
- **本地交叉编译首选**：使用 `zig` + `cargo-zigbuild` 替代手配繁杂的 C/musl/glibc 交叉工具链，一键锁定目标 glibc/musl 版本（例如在最新 Linux 开发机上直接编译兼容 Ubuntu 22.04/24.04 的静态 `x86_64-unknown-linux-musl` 或指定 `glibc.2.31` 二进制）。
  ```bash
  # 示例：静态 musl 发布包或指定低版本 glibc
  cargo zigbuild --release --target x86_64-unknown-linux-musl
  cargo zigbuild --release --target aarch64-unknown-linux-gnu.2.31
  ```

## 2. GitHub Actions 全平台矩阵构建
通过 `.github/workflows/release.yml` 自动化构建并校验全平台产物，确保「一套 Rust 核心 (`no_std` 优先)，全端原生运行」：

| 平台类别 | 目标 Target 示例 | 工具链 / 备注 |
| --- | --- | --- |
| **Desktop** | `x86_64-pc-windows-msvc`, `x86_64-unknown-linux-musl`, `aarch64-apple-darwin` | `cargo-zigbuild` + GitHub 官方 runners |
| **Mobile** | `aarch64-linux-android`, `aarch64-apple-ios`, `aarch64-unknown-linux-ohos` | Android NDK / Xcode / **HarmonyOS (OpenHarmony)** SDK |
| **Web** | `wasm32-unknown-unknown`, `wasm32-wasip2` | `wasm-pack` / `wasm-bindgen` + 前端打包 |
| **Embedded / MCU** | `thumbv7em-none-eabihf`, `riscv32imac-unknown-none-elf` | 纯 `no_std` core crate 零依赖直编验证 |

- 每次 PR / Tag 自动跑 `cargo clippy -- -D warnings`、`cargo test` 与核心目标交叉编译检查，确保主分支随时可发布。

## 3. 测试铁律（Testing Integrity）
1. **需求先行，锚定预期**：先与用户评估并确认真实需求与预期效果，再据此编写测试用例。
2. **严禁修改测试绕过失败**：
   - 测试失败时必须排查并修复真实代码或架构缺陷，**绝对禁止**通过删除断言、放宽阈值或篡改测试预期来“刷绿”。
   - **唯一例外**：仅当**需求本身经过明确确认发生变更**时，才允许同步更新对应测试，并在 Commit 中说明需求变更原因。
3. **充分覆盖**：
   - 单元测试覆盖强类型校验、边界值、计费/账本公式、异常 Fallback（断电/断网/超时/非法输入）。
   - 集成测试覆盖 API 契约、鉴权、并发竞态与防刷策略。
4. **真实环境备份后生产级实测**：
   - 禁止仅凭 Mock 通过就宣称上线就绪。
   - 发布前必须**先备份真实环境数据**（数据库快照 / 配置备份），在贴近生产环境（真实操作系统、真实网络/HTTPS、真实依赖服务）中完成端到端实测验证，保留可回滚路径。
