# NixOS 最新变动与迁移指南

> 对照时间：2026-10-27
> 仓库锁定：nixpkgs `55bfb4d7437bd4e09ab7cba58a43bd68eb310044`（2026-10-14，`nixos-unstable`）、Home Manager `640725978b99076e18e069f6e7d2959124584f8f`（2026-10-15）
> 当前稳定版：NixOS 26.05（2026-05-30 发布）；当前开发版：26.11（本文写作时尚未发布）
> 仓库中的 `system.stateVersion` / `home.stateVersion`：`26.05`
>
> 配套文档：[问题及修改建议.md](问题及修改建议.md)

本文回答两个问题：

1. 这份配置和“最新的 NixOS”之间有哪些**实际发生变化**、需要改的地方？
2. 哪些变化只是“新功能”，不改也能继续用；哪些是**必须迁移**的破坏性变更？

---

## 一、先给结论

### 1.1 真正需要动的

| 优先级 | 事项 | 原因 |
|---|---|---|
| P0 | 确认 Lix 版本 ≥ 2.95.4（或 2.94.3 / 2.96.0） | 2026-10-13 披露的本地提权漏洞影响 Lix ≤ 2.95.3 |
| P0 | 修 Limine 条目顺序/`default_entry` | 与“最新 NixOS”无关，但会直接导致启动到旧代；在升级前必须先修 |
| P1 | Noctalia 改为 `enable = true`，并按 v5 TOML 结构重写 | Home Manager 26.11 已内置 `programs.noctalia`；外部模块也已切到 TOML，旧字段不再保证生效 |
| P1 | Stylix 加 `stylix.enable = true` | 26.11 的默认值仍是 false；不加则所有 target 无效 |
| P1 | `fonts` 写法改为 `fonts.fontconfig.*` | Home Manager 26.11 的 option 树没有可赋值的父级 `fonts` |
| P1 | `programs.fish` 的函数可迁移到 `shellFunctions` | NixOS 26.11 新增结构化 fish 函数；非强制，但更干净 |
| P2 | NVIDIA 配置迁移到 `hardware.nvidia.branch` / `moduleParams` | 26.05 新增选项，旧的 `package` + kernelParams 仍可用但更笨重 |
| P2 | README 的 CLI 命令更新 | `nix flake lock --update-input` 已过时；`nix path-info --json` 需要 `--json-format` |

### 1.2 不需要动的

- **不要因为 26.11 就把 `system.stateVersion` 从 26.05 改成 26.11**。`stateVersion` 是“安装时兼容基线”，不是版本号；随意提升会改变默认数据库版本、目录布局等行为。现有系统应保持 26.05，除非你明确要做迁移。
- `services.journald.settings` 已经是新接口，不需要改回 `extraConfig`。
- `services.pipewire.wireplumber.enable` 仍然存在，不需要删。
- `services.resolved.settings` 已经是 26.05 的 RFC42 新接口，不需要改。
- `programs.git.settings` 已经是 HM 26.11 推荐接口，不需要改回 `userName`/`extraConfig`。
- `lib.nixosSystem` 的 `specialArgs` 没有受 26.11 移除 `extraArgs` 的影响；仓库用的正是 `specialArgs`。

---

## 二、基线：26.05、26.11 与 stateVersion

### 2.1 版本关系

| 项目 | 仓库当前 | 说明 |
|---|---|---|
| `flake.nix` 的 nixpkgs | `nixos-unstable` | 锁定在 2026-10-14，按时间属于 26.11 开发周期 |
| `system.stateVersion` | `26.05` | 说明系统最初按 26.05 的兼容基线安装 |
| `home.stateVersion` | `26.05` | 与系统一致 |
| 当前稳定版 | 26.05 | 2026-05-30 发布 |
| 当前开发版 | 26.11 | 本文写作时未发布，release notes 仍在变动 |

所以 README 里的“NixOS 26.05 (unstable)”是混在一起的：26.05 是稳定版，不是 unstable；unstable 现在是 26.11 开发线。`stateVersion = "26.05"` 本身没有错，它表示“这台机器从 26.05 基线开始”，并不要求 nixpkgs 必须是 26.05。

### 2.2 新装机怎么设

- 如果是**全新安装**，并且使用当前 unstable，建议 `system.stateVersion = "26.11"`、`home.stateVersion = "26.11"`，以采用 26.11 的新默认值。
- 如果是**已有系统升级**，保持 26.05；只有在你明确知道会改变哪些默认行为、并做好迁移时才提升。
- 不要为了“看起来最新”而改 `stateVersion`。它不会让系统更安全，也不会自动迁移数据。

---

## 三、NixOS 26.05 的变动

官方 release notes：<https://nixos.org/manual/nixos/stable/release-notes#sec-release-26.05>

### 3.1 与本仓库直接相关的

| 变动 | 内容 | 对仓库的影响 | 建议 |
|---|---|---|---|
| systemd stage 1 成为默认 | initrd 默认基于 systemd；旧的 scripted stage 1 被弃用，计划在 26.11 移除 | 仓库没有显式关掉它，所以 `boot.initrd.systemd.initrdBin` 现在会实际参与 initrd 构建 | 检查 `boot.initrd.systemd.initrdBin` 是否真的需要 `openssl`/`libbpf`/`libxcrypt`；不需要就删 |
| `services.openssh.generateHostKeys` | 可以在不启用 sshd 的情况下生成主机密钥 | 仓库用 sshd 提供 agenix 的主机密钥 | 若不需要远程 SSH，改成 `services.openssh.enable = false; services.openssh.generateHostKeys = true;`，缩小攻击面 |
| `services.resolved` 改为 RFC42 | DNS 配置移到 `services.resolved.settings.Resolve` | 仓库已经使用 `settings.Resolve.DNS` 等新接口 | 无需迁移；确认 `DNSOverTLS` 与 DNS 列表匹配即可 |
| `networking.resolvconf.enable` 默认 true | 不再根据 `environment.etc."resolv.conf"` 推断 | 仓库没有自定义 `/etc/resolv.conf` | 无需处理 |
| `services.xserver` 对未知驱动报错 | `videoDrivers` 里写了不存在的驱动会直接报错 | 仓库写的是 `nvidia` + `modesetting`，两者都存在；但 `services.xserver.enable = false` 时这段没有实际作用 | 可删除 `services.xserver.videoDrivers`，减少误导 |
| `hardware.nvidia.branch` | 新增驱动分支选择；`package` 仍可覆盖 | 仓库直接设置 `hardware.nvidia.package = ...latest` | 可改为 `hardware.nvidia.branch = "production"` 或保留 `package`，二选一，不要同时依赖 |
| `hardware.nvidia.moduleParams` | 新增 NVIDIA 内核模块参数接口，写入 modprobe 配置而不是全局 cmdline | 仓库仍在 `boot.kernelParams` 写 `nvidia_drm.modeset`/`fbdev` | 可迁移到 `hardware.nvidia.moduleParams`；不迁移也能工作 |
| `systemd.coredump.extraConfig` 移除 | 改用 `systemd.coredump.settings.Coredump` | 仓库没有使用 | 无需处理 |
| `nixos-rebuild-ng` 默认 | 25.11 起默认使用 Python 重写版 | README 的 `nixos-rebuild` 命令形式不变 | 如果遇到行为差异，可临时 `system.rebuild.enableNg = false`，但建议适应新版 |

### 3.2 其他值得知道但本仓库不涉及的

- 默认内核从 6.12 升到 6.18；仓库用 CachyOS 内核，不受影响。
- 默认 D-Bus 实现切换为 `dbus-broker`；仓库没有显式指定，默认会跟着变。若遇到 D-Bus 兼容问题，可临时 `services.dbus.implementation = "dbus";`，但不建议长期。
- `system.nix` 新入口；仓库继续用 `flake.nix`，不需要。
- `services.openssh.settings.AcceptEnv` 变为字符串列表；仓库没有设置。
- `fonts.fontconfig.useEmbeddedBitmaps` 默认改为 true；可能影响少量点阵字体渲染，仓库没有特殊需求，通常无需处理。
- Nextcloud/PostgreSQL 等默认版本变化只影响对应服务；仓库没有这些服务。

---

## 四、NixOS 26.11 的变动

官方 unstable release notes：<https://nixos.org/manual/nixos/unstable/release-notes>
（26.11 尚未发布，以下内容按 2026-10-14 的 nixpkgs 树核对。）

### 4.1 与本仓库直接相关的

| 变动 | 内容 | 对仓库的影响 | 建议 |
|---|---|---|---|
| `programs.fish.shellFunctions` | 新增结构化 fish 函数，替代在 `interactiveShellInit` 里拼字符串 | 仓库的 `fish_greeting`、`reloadfish` 仍在 `interactiveShellInit`；`extract`/`mkcd` 等已在 `functions` | 非强制；可把 `fish_greeting`/`reloadfish` 迁到 `functions`，或继续用 HM 的 `programs.fish.functions`（等价） |
| `systemd.user.extraConfig` 移除 | 改用 `systemd.user.settings.Manager` | 仓库没有使用 | 无需处理 |
| `services.timesyncd.extraConfig` 移除 | 改用 `services.timesyncd.settings.Time` | 仓库用 `networking.timeServers`，没有用 `extraConfig` | 无需处理 |
| `security.polkit.enablePkexecWrapper` 变为 opt-in | `pkexec` 的 setuid wrapper 不再默认安装 | 仓库只用 `polkit_gnome` 认证代理，没有显式依赖 `pkexec` | 如果某个脚本用 `pkexec`，需要显式开启；否则无需处理 |
| `networking.firewall.checkReversePath` 默认改为 `"loose"` | 与上游 systemd 对齐 | 仓库没有设置 | 如果没有特殊反欺骗需求，保持默认；需要严格模式时显式 `"strict"` |
| `nix.daemon.enable = false` 支持 daemonless | Nix 可以在无 daemon 模式下运行 | 仓库仍用 daemon + `nix-daemon` 环境变量 | 不需要跟；daemonless 需要本地 store 权限，桌面多用户场景不划算 |
| `lib.nixosSystem` 移除 `extraArgs`/`check` | 旧参数成为 eval error | 仓库使用 `specialArgs`，没有用 `extraArgs` | 无需处理 |
| `boot.vesa` 移除 | 旧的 VESA 回退 | 仓库没有使用 | 无需处理 |
| `programs.fuse` 变为 opt-in | 不自动提供 `fusermount3`/`/etc/fuse.conf` | 仓库没有显式使用 FUSE；但 AppImage、sshfs、rclone 等消费者可能依赖 | 如果以后用 AppImage/rclone mount，显式 `programs.fuse.enable = true;` |
| `services.xserver.desktopManager.phosh` 改名 | 移到 `services.desktopManager.phosh` | 仓库不用 phosh | 无需处理 |
| `programs.regreet` 改名 | 移到 `services.displayManager.regreet` | 仓库用 greetd + tuigreet | 无需处理 |
| `services.journald.settings` | 继续是正确接口 | 仓库已使用 | 无需处理 |
| `services.pipewire.wireplumber.enable` | 仍然存在 | 仓库已使用 | 无需处理；可删掉显式 true，因为默认跟随 pipewire |
| `hardware.nvidia` 新选项 | `branch`、`moduleParams`、新的 EGL 外部平台库 | 仓库仍用手动 `package` + kernelParams | 可选迁移；升级后重点测试 Wayland/PRIME |

### 4.2 26.11 中“看起来相关、但其实不用改”的

- `boot.loader.systemd-boot.bootCounting`：仓库用 Limine，不涉及。
- `services.userborn` 的 legacy 导入：仓库没有启用 userborn；agenix 也兼容 sysusers/userborn，但没必要为了新选项切换。
- `security.polkit.settings`：仓库没有自定义 polkitd 配置。
- `services.harmonia.gc`、`services.netbox`、`services.gitlab` 等：仓库没有这些服务。
- `image/repart.nix` 需要 `image.repart.enable`：仓库没有用 systemd-repart。
- `services.nextcloud` 默认版本：仓库没有 Nextcloud。

---

## 五、Home Manager 26.11 的变动

官方 release notes：<https://nix-community.github.io/home-manager/release-notes-26.11.html>
（如果该页面尚未生成，可看仓库 `docs/release-notes/rl-2611.md`。）

### 5.1 Noctalia：最需要注意的一项

Home Manager 26.11 已经内置 `programs.noctalia` 模块（`modules/programs/noctalia/`），配置格式是 **TOML（v5）**：

```nix
programs.noctalia = {
  enable = true;
  settings = {
    shell = {
      font = "JetBrainsMono Nerd Font";
    };
    theme = {
      mode = "dark";
      source = "builtin";
      builtin = "Catppuccin";
    };
    bar.default = {
      position = "top";
    };
  };
};
```

修改版目前：

- 导入的是外部 `inputs.noctalia.homeModules.default`；
- 该外部模块通过 `disabledModules = [ "programs/noctalia.nix" "programs/noctalia" ]` 主动禁用 HM 内置模块，所以**不会有 option 冲突**；
- `programs.noctalia.enable = true` 已设置，`package = null`（系统层安装 Noctalia）；
- 配置已改为 v5 TOML：`bar.default.start/center/end`、`widget.weather`、`widget."control-center"`、`control_center`、`weather`、`location`、`wallpaper.automation`、`theme`；天气、壁纸轮播、控制中心已启用。

**迁移建议**：

1. `enable = true` 已完成；
2. 在目标机运行 `noctalia config export`，以导出的 TOML 为准继续补充设置；
3. 用 `noctalia config validate` 验证；
4. 决定继续用外部模块，还是切回 HM 26.11 内置模块。切回内置模块时可以删掉 `noctalia` 输入和 `homeModules.default` 导入，版本跟随 nixpkgs；
5. 避免系统包和 HM 包重复安装（见审计报告 4.2）。

### 5.2 Git：仓库已经用了新接口

HM 26.11 把：

- `programs.git.userName` → `programs.git.settings.user.name`
- `programs.git.userEmail` → `programs.git.settings.user.email`
- `programs.git.aliases` → `programs.git.settings.alias`
- `programs.git.extraConfig` → `programs.git.settings`
- `programs.git.signing.gpgPath` → `programs.git.signing.signer`

仓库的 `home/zero/git.nix` 已经使用 `settings`，所以**不需要迁移**。

另外，HM 26.11 把 `programs.git.delta` 等 diff 工具选项移到 `programs.delta`、`programs.difftastic` 等独立模块；仓库没有用 `programs.git.delta`，而是把 `[delta]` 段直接写进 `settings`，这仍然是合法的 Git 配置，不需要改。如果想让 HM 管理 delta 的启用/包，可以再迁到 `programs.delta`。

### 5.3 字体：`fonts` 的层级

HM 26.11 移除了 `fonts.fontconfig.enableProfileFonts`，并继续只提供 `fonts.fontconfig.*` 这一组选项。仓库的：

```nix
fonts = lib.mkForce {
  fontconfig = { ... };
};
```

应改成：

```nix
fonts.fontconfig = {
  enable = true;
  defaultFonts = { ... };
};
```

如果要强制覆盖 Stylix，把 `lib.mkForce` 放到叶子：

```nix
fonts.fontconfig.defaultFonts = lib.mkForce { ... };
```

### 5.4 其他 HM 变动

| 变动 | 对仓库的影响 |
|---|---|
| `programs.mako.settings` 结构化 | 仓库没有用 HM 的 mako 模块；`configs/mako` 也没被映射 |
| `wayland.windowManager.sway` 的 `fonts`/`bars.*.fonts` 必须是 attrset | 仓库不用 sway |
| `nix.gc.frequency` → `nix.gc.dates` | 仓库的 HM 没有配置 `nix.gc`；NixOS 层用的是 `nix.gc.dates` |
| `programs.gh` 的 `aliases`/`editor` 移到 `settings` | 仓库没有 `programs.gh` |
| `programs.ssh` 顶层选项移到 `settings` | 仓库没有 `programs.ssh` |
| `home.stateVersion = "26.11"` 才启用新默认值 | 仓库是 26.05，保持即可；新装机再考虑 26.11 |
| `lib.xdg.mimeAssociations` 移除 | 仓库没有用 |
| `specialization` → `specialisation` | 仓库没有用 |

### 5.5 Fish：结构化函数

NixOS 26.11 新增 `programs.fish.shellFunctions`（NixOS 模块层）；HM 仍然用 `programs.fish.functions`。仓库的 fish 配置在 HM 中：

```nix
programs.fish.functions = {
  extract = ''...'';
  mkcd = ''...'';
  ports = ''...'';
  myip = ''...'';
};
```

这部分已经是结构化的，不需要跟 NixOS 的新选项。只有 `fish_greeting` 和 `reloadfish` 还在 `interactiveShellInit` 里；可以迁到 `functions`，但不是必须。

---

## 六、Nix 语言与 CLI 的变动

这一节区分“NixOS 模块语言”和“Nix 表达式语言/CLI”。仓库的 Nix 表达式没有使用被移除的语法，所以**没有必须改写的语言语法**；主要影响在 CLI 和 lint。

### 6.1 Nix 2.34：URL literal 与 lint

- `no-url-literals` 实验特性在 Nix 2.34 稳定，改为 `lint-url-literals` 设置，可取值 `ignore`/`warn`/`fatal`。
- `warn-short-path-literals` 被 `lint-short-path-literals` 取代。
- 新增 `lint-absolute-path-literals`，用于控制绝对路径/`~/` 路径字面量。

仓库没有裸 URL literal（`flake.nix` 里的 URL 都是字符串），也没有开启这些 lint；不需要改。若以后开启 `lint-url-literals = "fatal"`，检查 `flake.nix` 的 `url = "github:..."` 是否仍是字符串（是，没问题）。

参考：<https://nix.dev/manual/nix/2.35/release-notes/rl-2.34>

### 6.2 Nix 2.35：性能与 CLI

Nix 2.35 的主要变化是性能/存储层，不是语法：

- flake 源树更懒地复制到 store，减少大型仓库的磁盘占用；
- `builtins.getFlake` 接受 path 值；
- `nix flake check` 支持 `--print-out-paths`/`--out-link`；
- `nix store delete` 新增 `--skip-alive`；
- `nix realisation` 改名 `nix store build-trace`。

仓库没有用这些命令，不需要迁移。

参考：<https://nix.dev/manual/nix/2.35/release-notes/rl-2.35>

### 6.3 CLI 旧写法

| 旧写法 | 新写法 | 仓库位置 |
|---|---|---|
| `nix flake lock --update-input nixpkgs` | `nix flake update nixpkgs` | `README.md:324` |
| `nix path-info --json`（不带 `--json-format`） | `nix path-info --json --json-format 2` | 仓库没有直接用；如果脚本/工具用了要注意 |
| `nix derivation show` 的 JSON v3 | v4（`version` + `derivations`） | 仓库没有直接用 |

### 6.4 Lix 安全版本

2026-10-13 的联合安全公告：

- CVE-2026-110449：list 分配的整数溢出，可导致堆越界写；
- CVE-2026-110450：未授权的 `repair` 可破坏/替换 store path，导致本地提权；
- CVE-2026-110451：macOS Seatbelt 沙箱逃逸。

影响 Lix ≤ 2.95.3 / ≤ 2.94.2；修复版本是 2.95.4 / 2.94.3 / 2.96.0。仓库 `nix.package = pkgs.lix`，所以必须在目标机确认：

```bash
nix --version
# 期望：lix 2.95.4 或更高
```

仓库 pin 的时间在修复 PR 之后，但 `flake.lock` 只锁 nixpkgs，不直接显示 Lix 版本；不要假设它一定已经修好。若低于 2.95.4：

```bash
nix flake update
sudo nixos-rebuild switch --flake .#NCastleSurvivor
```

参考：<https://lix.systems/blog/2026-10-13-lix-cves/>、<https://discourse.nixos.org/t/security-advisory-for-nix-and-lix-october-2026/80547>

### 6.5 Nix 2.35.3 安全修复（不使用 Nix 的话可跳过）

Nix 2.35.2 及更早也受同一组问题影响，修复版是 2.35.3/2.34.9/2.31.6/2.30.6/2.28.8。仓库用的是 Lix，不是 Nix，所以重点看 6.4；如果某台机器改回了 `pkgs.nix`，再按 Nix 的版本检查。

---

## 七、本仓库的逐项迁移清单

| 文件/位置 | 当前写法 | 最新建议 | 是否必须 |
|---|---|---|---|
| `modules/system/boot.nix` | Limine `extraConfig` + `default_entry: 3` | Windows 用 `extraEntries`，让 NixOS 条目在前；不手写 `default_entry` | 是（否则启动旧代） |
| `modules/system/boot.nix` | `efiInstallAsRemovable = true` + `canTouchEfiVariables = true` | 二选一 | 建议 |
| `modules/system/boot.nix` | `initrdBin = [ openssl libbpf libxcrypt ]` | 只保留 initrd 真正执行的工具 | 建议 |
| `modules/system/security/ssh.nix` | sshd 开启 + 防火墙不放行 22 | 只给 agenix 用：`generateHostKeys = true` + `enable = false` | 建议 |
| `modules/system/hardware.nix` | `hardware.nvidia.package = ...latest` | 可用 `hardware.nvidia.branch`；`moduleParams` 替代部分 kernelParams | 可选 |
| `modules/system/hardware.nix` | `services.xserver.videoDrivers` | 在 `services.xserver.enable = false` 下删除 | 建议 |
| `modules/system/lix.nix` | `nix.package = pkgs.lix` | 确认 ≥ 2.95.4；删掉 mimalloc overlay；GC 改 14d | 是（安全）/建议 |
| `home/zero/desktop/noctalia.nix` | 只有 `settings`，无 `enable` | `enable = true`；按 v5 TOML 重写 | 是 |
| `home/zero/desktop/zen-browser.nix` | `SearchEngines_Default` | `SearchEngines = { Default = "Bing"; };` | 是 |
| `home/zero/desktop/zen-browser.nix` | 只写 `stylix.targets` | `stylix.enable = true` | 是 |
| `home/zero/fonts.nix` | `fonts = lib.mkForce {...}` | `fonts.fontconfig.*` | 是 |
| `home/zero/rime.nix` | `fcitx5/rime` 递归 + 子文件 | 拆分映射；修 `wanxiang` 拼写 | 是 |
| `home/zero/shell.nix` | `fish_greeting` 在 `interactiveShellInit` | 可迁到 `programs.fish.functions` | 可选 |
| `modules/system/packages/apps.nix` | unfree 白名单混入自由软件 | 清理名单；统一包边界 | 建议 |
| `README.md` | 旧 CLI/不存在的文件 | 更新命令、删除死引用 | 是 |
| `configs/nvim` | 无 lock，`mkdp_open_to_the_world` | 提交 `lazy-lock.json`；关闭公网监听 | 是（安全） |
| `configs/niri` | `chromium` 绑定、硬编码输出位置 | 改用已安装浏览器；输出自适应 | 建议 |
| `modules/desktop/wayland/xdg-portal.nix` | 只有 gtk | 加 ScreenCast/Screenshot 后端 | 建议 |
| `modules/desktop/xwayland-satellite.nix` | 与 niri 重复启动 | 只保留一个 owner | 建议 |

---

## 八、建议的迁移顺序

1. **先修不依赖版本的东西**：Limine 顺序、Noctalia `enable`、Stylix `enable`、字体、Rime 路径、sudo wrapper。否则升级后很难判断是新版问题还是旧配置问题。
2. **确认 Lix 版本**：`nix --version`；低于 2.95.4 先更新，再继续。
3. **在旧 generation 上做一次 `nix flake update`**：只更新锁文件，不立即 switch；用 `nvd diff` 看变化。
4. **构建不切换**：`sudo nixos-rebuild build --flake .#NCastleSurvivor`；先看 eval 错误（字体/Noctalia/option 重命名）。
5. **迁移 Noctalia 配置**：用 `noctalia config export` 生成 v5 TOML，再翻译成 Nix；`noctalia config validate` 通过后再 switch。
6. **测试会话**：greetd 登录、niri、fcitx5、Noctalia 配置、Stylix 颜色、屏幕共享、Xwayland。
7. **测试回滚**：`nixos-rebuild switch --rollback` 或从 Limine 选旧代；确认能回到旧系统。
8. **最后清理仓库**：Rime 大数据移出、死文件删除、README 更新。

---

## 九、验证命令

```bash
# 版本
nix --version
nix flake metadata

# 纯 eval，先抓 option/type 错误
nix flake check --no-build
nix eval .#nixosConfigurations.NCastleSurvivor.config.system.build.toplevel.drvPath

# 构建（不切换）
sudo nixos-rebuild build --flake .#NCastleSurvivor

# 对比两个代
nvd diff /run/current-system ./result

# 查看生成的 greetd 配置
cat result/etc/greetd/config.toml 2>/dev/null || true

# 查看 Limine 配置（switch 后）
sudo cat /boot/limine.conf

# 查看 Lix 安全版本
nix --version | grep -E '2\.(94|95|96)'

# 会话内
niri msg outputs
systemctl --user status xwayland-satellite
fcitx5-diagnose
noctalia config validate
```

---

## 十、参考

### NixOS

- NixOS 26.05 release notes：<https://nixos.org/manual/nixos/stable/release-notes#sec-release-26.05>
- NixOS unstable release notes（26.11）：<https://nixos.org/manual/nixos/unstable/release-notes>
- `services.openssh.generateHostKeys`（26.05）：<https://nixos.org/manual/nixos/stable/options#opt-services.openssh.generateHostKeys>
- `hardware.nvidia.branch`（26.05）：<https://nixos.org/manual/nixos/stable/options#opt-hardware.nvidia.branch>
- `hardware.nvidia.moduleParams`（26.05）：<https://nixos.org/manual/nixos/stable/options#opt-hardware.nvidia.moduleParams>

### Home Manager

- Home Manager 26.11 release notes：<https://nix-community.github.io/home-manager/release-notes-26.11.html>；源码版：<https://github.com/nix-community/home-manager/blob/master/docs/release-notes/rl-2611.md>
- Noctalia 配置说明：<https://docs.noctalia.dev/noctalia/configuration/>
- Home Manager Noctalia 模块（源码）：<https://github.com/nix-community/home-manager/tree/master/modules/programs/noctalia>
- Home Manager 字体选项：<https://home-manager.dev/manual/unstable/options/home-manager/fonts.fontconfig.html>

### Stylix

- NixOS 选项（`stylix.enable` 默认 false）：<https://nix-community.github.io/stylix/options/platforms/nixos.html#stylixenabled>
- Home Manager 选项：<https://nix-community.github.io/stylix/options/platforms/home_manager.html>

### Nix / Lix

- Nix 2.34 release notes：<https://nix.dev/manual/nix/2.35/release-notes/rl-2.34>
- Nix 2.35 release notes：<https://nix.dev/manual/nix/2.35/release-notes/rl-2.35>
- Nix 2.33 release notes：<https://releases.nixos.org/nix/nix-2.34.8/manual/release-notes/rl-2.33.html>
- Lix CVE 公告：<https://lix.systems/blog/2026-10-13-lix-cves/>
- NixOS Discourse 安全公告：<https://discourse.nixos.org/t/security-advisory-for-nix-and-lix-october-2026/80547>

### 本仓库相关文件

- `flake.nix`、`flake.lock`
- `modules/system/boot.nix`
- `modules/system/hardware.nix`
- `modules/system/power.nix`
- `modules/system/security/ssh.nix`
- `modules/system/lix.nix`
- `home/zero/desktop/noctalia.nix`
- `home/zero/desktop/zen-browser.nix`
- `home/zero/fonts.nix`
- `home/zero/rime.nix`
- `configs/nvim/`
- `configs/rime/`
