# Rust 生态复用（`lib.rs` & `no_std` 优先）与极速增量编译指南

## 1. Crate 选型流程（先查 `https://lib.rs`，最小化引入）
引入任何依赖前，按以下 4 步核验：
1. **检索 `lib.rs`**：按领域关键词在 `https://lib.rs` 对比候选 crate 的**月下载量、最近维护时间、反向依赖数与代码体量**。
2. **`no_std` 优先**：纯算法、编解码、校验、协议解析类 crate 优先选择支持 `no_std`（关闭 `default-features`）的轻量化库，减少编译体积与隐式系统调用。
3. **许可证门禁**：商业项目只引入 **MIT / Apache-2.0 / BSD / ISC / Zlib**；**严禁**引入 AGPL / GPL 传染性依赖。
4. **最小化依赖树**：能用标准库或 1 个轻量 crate 解决的，绝不拉入带 80 个传递依赖的重型框架。

## 2. Cargo Workspace 极速增量编译（1–3 秒开发闭环）
把重型第三方依赖隔离在叶节点 crate，确保改业务逻辑时**绝不触发重依赖重编**：

```text
crates/
├── app-core/       # 零 IO 纯类型 + 业务公式（仅依赖 serde/thiserror，编译 < 1s）
├── app-protocol/   # 协议编解码与校验（优先 no_std crate）
├── app-storage/    # Turso / SQLite / PG 原子账本层
└── app-server/     # 薄 HTTP/Axum 组装层（不含重业务逻辑、不画 UI）
```

### 四级编译加速标准配置
1. **最新 `stable` `rustc` + 快速链接器**（Linux 推荐 `mold`，未安装时用默认链接器或 `lld`；`.cargo/config.toml`）：
   ```toml
   [target.x86_64-unknown-linux-gnu]
   linker = "clang"
   rustflags = ["-C", "link-arg=-fuse-ld=mold"]
   ```
2. **共享 `target-dir` + `sccache`**（本机多项目零重复编依赖）：
   - 全局配置 `target-dir` 与 `rustc-wrapper = "sccache"`，不同仓库复用同一份重依赖缓存。
3. **（可选）公共 `dylib` (`.so`) 加速 Debug 链接与测试**：
   - 将 `tokio`/`axum`/`reqwest`/`turso`/`ring` 等重依赖聚合为一个 `crate-type = ["dylib"]` 共享库，Debug 模式动态链接、热部署仅传业务主程序；**生产发布仍打静态 `musl` 单二进制**。
4. **（可选）冷启动缓存同步**：
   - 按 `os-arch-rustc-<ver>-<lock_hash>` 为 key 缓存 `dylib` + `sccache` 产物（GitHub Actions cache / `sccache` 远端存储等），新机与 CI 拉取即用。
   - lilyco 生态专用实现（`lilyco-dylib` + `kuake` 网盘缓存）见 `lilyco-stack.md`。

推荐 `Cargo.toml` 开发配置：
```toml
[profile.dev]
debug = 1              # 仅保留行号表，链接提速 2 倍

[profile.dev.package."*"]
opt-level = 2          # 第三方重依赖编译一次即缓存优化结果
```
- **开发期**：本机动态链接 + 快速链接器实现 1–3 秒热闭环。
- **发布期**：仅在部署 Linux 服务器时执行一次静态 `x86_64-unknown-linux-musl` 构建（配合 `zig` / `cargo-zigbuild`）。

## 3. 前端生态复用
- 组件库优先复用 **shadcn/ui**（源码可控、无黑盒升级风险、商业对齐度高）+ Tailwind CSS + TypeScript 强类型。
- 前后端通过统一 API 契约（OpenAPI / 强类型 DTO）对接，前端只做展示、基础消毒与按契约类型转换。
