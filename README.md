# NCastleSurvivor — NixOS 配置（修改版）

> Lix + NixOS 26.05 兼容基线（flake 跟随 `nixos-unstable`）+ Limine + niri + Noctalia + Home Manager + agenix + Flake
>

## 系统概览

| 项目 | 配置 |
|---|---|
| 主机名 | `NCastleSurvivor` |
| 用户名 | `zero` |
| CPU | AMD Ryzen 7 4800H |
| 显卡 | NVIDIA RTX 2060 + AMD Radeon（PRIME offload） |
| 网卡 | Intel AX210（Wi-Fi 6E + BT 5.3） |
| 内核 | CachyOS Latest（`nix-cachyos-kernel` pinned overlay） |
| 引导 | Limine（UEFI；**按用户要求保持原配置不变**） |
| 桌面 | niri（Wayland）+ xwayland-satellite |
| 登录 | greetd + tuigreet |
| 状态栏/通知 | Noctalia（v5 TOML 配置） |
| 终端 | Kitty + Fish |
| 浏览器 | Zen Browser（twilight） |
| 编辑器 | Neovim（lazy.nvim） |
| 输入法 | Fcitx5 + Rime |
| 音频 | PipeWire + WirePlumber |
| 网络 | NetworkManager + iwd + systemd-resolved |
| 特权 | doas 日常使用；保留 sudo 以兼容构建工具 |
| 密码管理 | agenix（age + SSH 主机密钥） |
| 包管理 | Lix + Flake |

---

## 目录结构

```text
nixos-dotfiles-修改版/
├── .gitignore                   # 构建产物/明文秘密忽略
├── flake.nix                    # Flake 入口
├── configuration.nix            # 系统主配置 + Stylix
├── hardware-configuration.nix   # 硬件配置（nixos-generate-config 生成）
├── secrets/
│   ├── README.md                # 密钥目录说明
│   ├── secrets.nix              # agenix 加密规则（主机公钥模板）
│   └── zero_password.age        # 加密的用户密码哈希
├── modules/
│   ├── system/
│   │   ├── boot.nix             # 引导/内核（Limine 条目按要求未改）
│   │   ├── hardware.nix         # NVIDIA/蓝牙/显卡
│   │   ├── power.nix            # TLP/zram/电源管理
│   │   ├── networking.nix       # NetworkManager/DNS/防火墙
│   │   ├── audio.nix            # PipeWire
│   │   ├── lix.nix              # Lix / GC / 清理脚本
│   │   ├── environment.nix      # 全局环境变量
│   │   ├── i18n.nix             # 时区/locale/NTP
│   │   ├── packages/            # 系统软件包
│   │   │   ├── base.nix         # 基础工具
│   │   │   ├── apps.nix         # 应用/unfree/包装脚本
│   │   │   ├── fonts.nix        # 系统字体
│   │   │   └── default.nix
│   │   ├── security/            # 账户与密钥
│   │   │   ├── age.nix
│   │   │   ├── doas.nix
│   │   │   ├── ssh.nix
│   │   │   ├── users.nix
│   │   │   └── default.nix
│   │   ├── services/            # 系统服务
│   │   │   ├── desktop-services.nix  # polkit/udisks2/upower/udiskie
│   │   │   ├── logging.nix      # journald
│   │   │   └── default.nix
│   │   └── default.nix
│   └── desktop/
│       ├── display-manager/greetd.nix
│       ├── wayland/niri.nix
│       ├── wayland/xdg-portal.nix
│       ├── input/fcitx.nix
│       └── default.nix
├── home/zero/                   # Home Manager 用户配置
│   ├── default.nix
│   ├── git.nix                  # Git
│   ├── shell.nix                # Fish
│   ├── xdg.nix                  # XDG configFile 映射
│   ├── fonts.nix                # HM 字体
│   ├── rime.nix                 # Rime dataFile 映射（路径未改）
│   ├── nh.nix                   # nh
│   └── desktop/
│       ├── noctalia.nix         # Noctalia v5：天气/壁纸/控制中心
│       └── zen-browser.nix      # Zen Browser + Stylix target
├── assets/
│   └── wallpapers/wall.jpg      # Stylix 主题图
├── configs/
│   ├── niri/config.kdl
│   ├── kitty/kitty.conf
│   ├── fuzzel/fuzzel.ini
│   ├── nvim/                    # Neovim/LazyVim
│   ├── swaylock/config
│   └── rime/                    # Rime 数据（按要求全量保留）
├── 问题及修改建议.md
├── 修改记录.md
└── NixOS-最新变动与迁移指南.md
```
---

## 快速部署

### 1. 分区与挂载

```bash
mount /dev/disk/by-uuid/<根分区UUID> /mnt
mkdir -p /mnt/boot /mnt/home
mount /dev/disk/by-uuid/<EFIPartitionUUID> /mnt/boot
mount /dev/disk/by-uuid/<HomePartitionUUID> /mnt/home
```

### 2. 生成硬件配置

```bash
nixos-generate-config --root /mnt
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zero/nixos-configuration/
```

> `hardware-configuration.nix` 中的 UUID 和 `hardware.nix` 中的 PCI BusID 是机器相关值，换机必须重新生成/核对。

### 3. 配置 agenix（首次部署）

```bash
# 工具环境（包含 ssh-to-age）
nix-shell -p age agenix mkpasswd ssh-to-age

# 生成密码哈希
mkpasswd --method=yescrypt
# 输入密码，复制输出哈希

# 获取主机 SSH 公钥并转 age 格式
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# 输出：age1...（复制）

# 编辑 secrets/secrets.nix，把占位符替换成上面的 age 公钥
$EDITOR secrets/secrets.nix

# 加密密码哈希
cd secrets
agenix -e zero_password.age
# 或：printf '%s\n' '$y$j9T$...' | agenix -e zero_password.age
```

`secrets/secrets.nix` 里现在是一个占位公钥：

```nix
hostKey = "age1REPLACE_WITH_YOUR_HOST_PUBLIC_KEY";
```

### 4. 安装

```bash
ln -sfn /mnt/home/zero/nixos-configuration /mnt/etc/nixos
nixos-install --flake .#NCastleSurvivor --impure
```

如果使用镜像，建议通过 `--option` 传入，而不是依赖旧示例中的 `--substituters`：

```bash
nixos-install --flake .#NCastleSurvivor --impure \
  --option substituters "https://mirror.sjtu.edu.cn/nix-channels/store https://cache.nixos.org"
```

### 5. 首次登录后

```bash
nix --version                 # 确认 Lix >= 2.95.4（安全修复）
nixos-rebuild switch --flake .#NCastleSurvivor
systemctl --user status xwayland-satellite
niri msg outputs
fcitx5-remote -r
noctalia config validate
```

---

## agenix 密码管理

### 原理

用户密码哈希通过 [age](https://github.com/FiloSottile/age) 加密存储在 `secrets/zero_password.age`，系统激活时用主机 SSH 私钥（`/etc/ssh/ssh_host_ed25519_key`）解密。agenix 模块会自动把 `users` 的 activation 依赖挂到 `agenixInstall` 上，因此不需要 sops-nix 的 `neededForUsers` 选项。

### 密钥说明

| 密钥 | 位置 | 作用 |
|---|---|---|
| 主机 ed25519 私钥 | `/etc/ssh/ssh_host_ed25519_key` | 构建/激活时解密秘密 |
| 主机 ed25519 公钥（转 age） | `secrets/secrets.nix` | 加密时使用，仅本主机可解密 |

### 修改密码

本修改版设置了：

```nix
users.mutableUsers = false;
```

所以密码**完全由 secret 决定**。修改流程：

```bash
cd secrets
mkpasswd --method=yescrypt | agenix -e zero_password.age
cd ..
sudo nixos-rebuild switch --flake .#NCastleSurvivor
```

不要再用 `passwd` 修改密码；下一次 activation 会把它覆盖回 secret 中的值。

### 重装/换机

主机密钥变化后，旧的 `.age` 文件无法解密。两种方式：

1. **迁移旧主机密钥**（推荐）：备份 `/etc/ssh/ssh_host_ed25519_key*`，在新系统安装前复制到 `/mnt/etc/ssh/`，保持权限 `600`。
2. **重新加密**：在新机器上取得新的 age 公钥，更新 `secrets/secrets.nix`，用旧机器解密后重新 `agenix -e`。

`secrets/secrets.nix` 只包含公钥，可以提交；私钥永远不要放进仓库。

---

## SSH

本修改版默认**不运行 sshd**，只通过 `services.openssh.generateHostKeys = true` 生成 agenix 需要的主机密钥：

```nix
services.openssh = {
  enable = false;
  generateHostKeys = true;
  hostKeys = [ ... ];
};
```

如果需要远程登录：

1. 把 `enable` 改为 `true`；
2. 在 `modules/system/networking.nix` 放行 22；
3. 给 `users.users.zero.openssh.authorizedKeys.keys` 添加公钥；
4. 重新构建并测试。

---

## Noctalia / Stylix / 锁屏

### Noctalia

- `programs.noctalia.enable = true` 已设置；
- 包在系统层安装，`programs.noctalia.package = null`，避免 HM 重复安装；
- 配置已升级到 Noctalia v5 的 TOML 结构，包含：
  - 顶栏 `start/center/end` widget 列表（launcher、workspaces、weather、tray、network、bluetooth、volume、battery、control-center、session）；
  - 天气服务与苏州位置；
  - 壁纸轮播（30 分钟、随机、全屏时暂停）；
  - 控制中心（compact sidebar、媒体可视化）；
  - Catppuccin 深色主题。
- 修改配置后运行：

```bash
noctalia config validate
```

如果要从现有桌面导出配置：

```bash
noctalia config export > /tmp/noctalia.toml
```

再把 TOML 翻译成 `programs.noctalia.settings`。

要跟随最新 Noctalia 版本：

```bash
nix flake update noctalia
sudo nixos-rebuild switch --flake .#NCastleSurvivor
```

当前配置按 v5 的 `bar.default`、`widget`、`control_center`、`weather`、`location`、`wallpaper.automation` 结构编写；如果上游再改 schema，以 `noctalia config validate` 的结果为准。

### Stylix

`configuration.nix` 和 `home/zero/desktop/zen-browser.nix` 都设置了 `stylix.enable = true`，并使用 `assets/wallpapers/wall.jpg` 作为主题图。没有这个 enable，`stylix.targets` 会被全部忽略。

### 锁屏

- `swaylock-effects` + `swayidle` 已安装；
- niri 启动时运行 `swayidle`：5 分钟锁屏、10 分钟挂起；
- `Mod+Alt+L` 手动锁屏；
- `configs/swaylock/config` 已删除 `ignore-empty-password`；
- 锁屏配置通过 `xdg.configFile."swaylock"` 映射。

如果使用 Noctalia 自带的 idle/lock，请关闭 niri 里的 `swayidle` 行，避免两套策略同时运行。

---

## 常用命令

```bash
# 构建并切换
sudo nixos-rebuild switch --flake .#NCastleSurvivor

# 仅构建不切换
sudo nixos-rebuild build --flake .#NCastleSurvivor

# 查看系统差异
nvd diff /run/current-system result

# 更新所有 flake 输入
nix flake update

# 仅更新指定输入
nix flake update nixpkgs

# 垃圾回收（脚本已保留 14 天回滚窗口）
sudo nix-collect-garbage -d

# 清理脚本
clean-nixos

# agenix 解密查看
sudo agenix -d secrets/zero_password.age
```

> 旧写法 `nix flake lock --update-input nixpkgs` 已过时，使用 `nix flake update nixpkgs`。

---

## 需要按机器修改的项

| 文件 | 需更改项 |
|---|---|
| `hardware-configuration.nix` | 分区 UUID（`nixos-generate-config` 生成） |
| `modules/system/hardware.nix` | `amdgpuBusId` / `nvidiaBusId`（`lspci` 确认） |
| `home/zero/git.nix` | Git 用户名和邮箱 |
| `secrets/secrets.nix` | 主机 age 公钥（替换占位符） |
| `secrets/zero_password.age` | 用自己的密码重新加密 |
| `home/zero/desktop/noctalia.nix` | 按实际桌面导出结果补充 v5 配置 |
| `configs/nvim` | 首次运行后提交 `lazy-lock.json` |

