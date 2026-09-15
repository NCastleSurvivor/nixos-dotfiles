# NCastleSurvivor — NixOS 配置

> Lix + NixOS 26.05 (unstable) + Limine + niri + Home Manager + Flake

## 系统概览

| 项目 | 配置 |
|---|---|
| 主机名 | `NCastleSurvivor` |
| 用户名 | `zero` |
| CPU | AMD Ryzen 7 4800H (Renoir) |
| 显卡 | NVIDIA RTX 2060 + AMD Radeon 核显（双显卡 PRIME offload） |
| 网卡 | Intel AX210 (Wi-Fi 6E + BT 5.3) |
| 磁盘 | 2TB SSD（800M EFI + ~651G / + 1.3T /home） |
| 文件系统 | XFS（/ 和 /home），VFAT（EFI），支持 NTFS |
| 内核 | CachyOS Latest（EEVDF+BORE 调度器，LTO 优化） |
| 引导 | Limine（UEFI removable，不依赖 UEFI 变量） |
| 桌面 | niri（Wayland 平铺合成器）+ xwayland-satellite |
| 登录 | greetd + tuigreet |
| 状态栏 | Waybar |
| 启动器 | Fuzzel |
| 通知 | Mako |
| 终端 | Kitty + Fish Shell |
| 浏览器 | Zen Browser |
| 编辑器 | Neovim（lazy.nvim + LSP + Telescope） |
| 输入法 | Fcitx5 + Rime（rime-ice，用户自备配置） |
| 音频 | PipeWire + WirePlumber |
| 网络 | dhcpcd（有线）+ iwd（无线） |
| 特权 | doas（替代 sudo） |
| 包管理 | Lix（替代 Nix）+ Flake |

> **软件包策略**：最小化原则，仅保留开机、桌面运行、git、neovim 必需软件。统一软件包组在 `home/zero/packages.nix`（系统级，所有用户可用）。其他软件请自行添加。

---

## 目录结构与各层级说明

```
NCastleSurvivor-nixos/
├── flake.nix                          # Flake 入口（inputs/outputs）
├── flake.lock                         # 依赖锁定
├── configuration.nix                  # 系统主配置（imports 聚合 + 用户 + 映射）
├── hardware-configuration.nix         # 硬件配置（分区挂载/内核模块）
├── README.md                          # 本文档
├── DIRECTORY-STRUCTURE.md             # 目录层级结构详细说明
├── SOFTWARE-AND-KEYBINDINGS.md        # 软件使用说明 + 详尽快捷键
├── CHANGED.md                         # 本次整合修改记录（前后比对）
│
├── modules/                           # 【NixOS 系统模块层】
│   ├── system/                        #   系统级模块
│   │   ├── default.nix                #     聚合：imports 同目录所有模块
│   │   ├── boot.nix                   #     引导：Limine + 内核 + 内核参数 + initrd
│   │   ├── hardware.nix               #     硬件：NVIDIA + AMD + 固件 + 电源 + TLP + 传感器
│   │   ├── lix.nix                    #     包管理器：Lix + 国内镜像 substituters
│   │   ├── doas.nix                   #     特权管理：doas 替代 sudo
│   │   ├── networking.nix             #     网络：dhcpcd + iwd + 防火墙 + 蓝牙 + 网络工具
│   │   ├── audio.nix                  #     音频：PipeWire + WirePlumber
│   │   ├── services.nix               #     系统服务：seatd/udisks2/upower/polkit/portal
│   │   └── packages.nix               #     全局环境变量 + Shell 别名（包组已移至 home/zero/）
│   │
│   └── desktop/                       #   桌面环境模块
│       ├── default.nix                #     聚合
│       ├── greetd.nix                 #     登录管理器：greetd + tuigreet
│       ├── niri.nix                   #     合成器：niri + xwayland-satellite + GTK 主题
│       ├── fcitx.nix                  #     输入法：fcitx5 + rime
│       └── tools.nix                  #     桌面工具：waybar/fuzzel/mako/kitty/zen-browser 等
│
├── home/                              # 【Home Manager 用户配置层】
│   └── zero/                          #   用户 zero
│       ├── default.nix                #     Home Manager 入口（Git/Kitty/聚合 shell+config-files）
│       ├── packages.nix               #     ★ 统一软件包组（environment.systemPackages，所有用户可用）
│       ├── shell.nix                  #     fish Shell 配置（别名/函数/vi 键绑定/环境变量）
│       └── config-files.nix           #     配置文件映射（configs/ → ~/.config/）+ 字体 + Rime
│
├── configs/                           # 【软件原始配置层】
│   ├── waybar/                        #   waybar 状态栏（config.jsonc + style.css + modules/）
│   ├── niri/                          #   niri 合成器（config.kdl）
│   ├── fuzzel/                        #   fuzzel 应用启动器
│   ├── kitty/                         #   kitty 终端
│   ├── mako/                          #   mako 通知
│   ├── swaylock/                      #   swaylock 锁屏
│   ├── nvim/                          #   neovim 编辑器（init.lua）
│   ├── rime/                          #   rime 输入法配置（用户自备，映射到 ~/.local/share/fcitx5/rime/）
│   └── limine/                        #   limine 参考配置（不映射，实际由 NixOS 生成）
│
└── scripts/                           # 辅助脚本
    └── install.sh                     # 安装辅助脚本
```

> 更详细的目录结构说明见 `DIRECTORY-STRUCTURE.md`。

---

## 安装指南

### 前置准备

1. 下载 NixOS 26.05 unstable Live ISO
2. 制作启动 U 盘，从 U 盘启动
3. 确认磁盘分区：800M EFI + ~651G / + 1.3T /home（均已预划分，XFS 文件系统）

### 分区与挂载

```bash
# 假设 EFI 分区为 /dev/nvme0n1p1，/ 为 /dev/nvme0n1p2，/home 为 /dev/nvme0n1p3
# 实际盘符可能不同，请用 lsblk 确认，用 UUID 挂载避免盘符随机变化

# 格式化（如尚未格式化）
mkfs.vfat -F 32 /dev/nvme0n1p1
mkfs.xfs /dev/nvme0n1p2
mkfs.xfs /dev/nvme0n1p3

# 挂载
mount /dev/nvme0n1p2 /mnt
mkdir -p /mnt/boot /mnt/home
mount /dev/nvme0n1p1 /mnt/boot
mount /dev/nvme0n1p3 /mnt/home
```

### 部署配置

```bash
# 1. 将配置复制到 home 分区（配置永久存放在 home 分区）
mkdir -p /mnt/home/zero/nixos-config
cp -r /path/to/NCastleSurvivor-nixos/* /mnt/home/zero/nixos-config/

# 2. 生成 hardware-configuration.nix（覆盖现有文件）
nixos-generate-config --root /mnt
# 生成的文件在 /mnt/etc/nixos/hardware-configuration.nix
# 将其复制到配置目录替换：
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/zero/nixos-config/

# 3. 创建 /etc/nixos 符号链接指向 home 分区配置
ln -sfn /mnt/home/zero/nixos-config /mnt/etc/nixos

# 4. 设置用户密码哈希（参考 configuration.nix 中的说明）
#    生成方法：nix run nixpkgs#mkpasswd -- --method=sha-512
#    将输出填入 configuration.nix 的 hashedPassword 字段

# 5. 安装系统
nixos-install --flake .#NCastleSurvivor --substituters https://mirror.sjtu.edu.cn/nix-channels/store --impure

# 6. 重启
reboot
```

### 首次登录后

```bash
# 1. 验证系统
nix-shell -p nix-info --run "nix-info -m"
echo $XDG_SESSION_TYPE  # 应输出 wayland
nvidia-smi               # 查看 NVIDIA 状态

# 2. 部署 Rime：将自备的 rime 配置放入 configs/rime/，然后
fcitx5-remote -r
# 按 F4 切换输入方案

# 3. 打开 nvim，lazy.nvim 自动安装插件
nvim

# 4. 放置壁纸到 ~/.config/niri/wallpaper.jpg
```

---

## 配置文件映射机制

### 映射原理

所有软件配置文件（kitty、waybar、niri、fuzzel、mako、swaylock、nvim 等）存放在仓库的 `configs/` 目录下，通过 **Home Manager** 的 `xdg.configFile` 选项映射到用户的 `~/.config/` 目录。

映射定义在 `home/zero/config-files.nix` 中：

```nix
xdg.configFile = {
  "waybar/config.jsonc".source = "${configsDir}/waybar/config.jsonc";
  "waybar/style.css".source      = "${configsDir}/waybar/style.css";
  "waybar/modules".source         = "${configsDir}/waybar/modules";
  "niri/config.kdl".source        = "${configsDir}/niri/config.kdl";
  "fuzzel/fuzzel.ini".source      = "${configsDir}/fuzzel/fuzzel.ini";
  "kitty/kitty.conf".source       = "${configsDir}/kitty/kitty.conf";
  "mako/config".source            = "${configsDir}/mako/config";
  "swaylock/config".source        = "${configsDir}/swaylock/config";
  "nvim/init.lua".source          = "${configsDir}/nvim/init.lua";
};

# fcitx5-rime 数据映射到 ~/.local/share/fcitx5/rime/
xdg.dataFile."fcitx5/rime".source = "${configsDir}/rime";
```

### 修改现有配置文件

```bash
# 1. 编辑仓库中的源文件
nvim /home/zero/nixos-config/configs/kitty/kitty.conf

# 2. 重新构建并应用
doas nixos-rebuild switch --flake /home/zero/nixos-config#NCastleSurvivor

# 3. 部分软件支持热重载
#    niri:    Mod+Shift+R
#    kitty:   kitty @ set-colors --all --configured ~/.config/kitty/kitty.conf
#    mako:    makoctl reload
#    waybar:  killall -SIGUSR2 waybar
```

### 新增配置文件

```bash
# 1. 在 configs/ 下创建新目录和配置文件
mkdir -p /home/zero/nixos-config/configs/alacritty
nvim /home/zero/nixos-config/configs/alacritty/alacritty.toml

# 2. 在 home/zero/config-files.nix 的 xdg.configFile 中添加映射
#    "alacritty/alacritty.toml".source = "${configsDir}/alacritty/alacritty.toml";

# 3. 如需安装软件，在 home/zero/packages.nix 或 modules/desktop/tools.nix 中添加

# 4. 重新构建
doas nixos-rebuild switch --flake /home/zero/nixos-config#NCastleSurvivor
```

> 注意：映射到 `~/.config/` 的文件是只读的，必须修改仓库 `configs/` 中的源文件。

---

## 日常使用命令

### 系统管理

```bash
cd /home/zero/nixos-config  # 或 cd /etc/nixos

# 重建系统 + 用户配置
doas nixos-rebuild switch --flake .#NCastleSurvivor

# 测试配置（不切换）
doas nixos-rebuild test --flake .#NCastleSurvivor

# 仅构建，下次启动生效
doas nixos-rebuild boot --flake .#NCastleSurvivor

# 更新 flake 输入（nixpkgs、home-manager、内核等）
nix flake update

# 清理旧世代（释放空间）
doas nix-collect-garbage -d

# 格式化所有 .nix 文件
nix fmt
```

### 网络管理

```bash
# 查看网络状态
ip addr
dhcpcd -U

# WiFi 管理（iwd）
iwctl station wlan0 scan
iwctl station wlan0 get-networks
iwctl station wlan0 connect "SSID"

# 蓝牙
blueman-manager  # 图形界面
bluetoothctl     # 命令行
```

### 音量/亮度

```bash
# 音量（PipeWire）
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+
wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle

# 亮度
brightnessctl set +5%
brightnessctl set 5%-
```

---

## 国内软件源

### Lix substituters（二进制缓存）

在 `modules/system/lix.nix` 中配置，当前包含：

| 镜像站 | URL | 说明 |
|---|---|---|
| 官方缓存 | `https://cache.nixos.org` | NixOS 官方二进制缓存 |
| 中科大 | `https://mirrors.ustc.edu.cn/nix-channels/store` | 中国科学技术大学 |
| 清华大学 | `https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store` | 清华大学 TUNA |
| 南京大学 | `https://mirror.nju.edu.cn/nix-channels/store` | 南京大学 |
| 兰州大学 | `https://mirror.lzu.edu.cn/nix-channels/store` | 兰州大学 |

> 多个 substituters 同时配置，Lix 会自动从最快的源下载。如某源限速或拉黑 IP，可在 `lix.nix` 中注释掉对应 URL。

### nixpkgs 源码镜像

如需加速 `nix flake update`，可在 `flake.nix` 中将 nixpkgs 输入改为国内镜像 tarball：

```nix
# 中科大
nixpkgs.url = "https://mirrors.ustc.edu.cn/nix-channels/nixpkgs-unstable.tar.xz";
# 清华大学
nixpkgs.url = "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/nixpkgs-unstable.tar.xz";
```

> 注意：使用 tarball 后无法用 `follows` 联动，home-manager 需独立指定 nixpkgs。

---

## 需要修改/注意的地方

### 必须修改

| 文件 | 需更改项 | 说明 |
|---|---|---|
| `configuration.nix` | `users.users.zero.hashedPassword` | **必须修改**。当前为示例哈希，需生成自己的密码哈希。生成方法：`nix run nixpkgs#mkpasswd -- --method=sha-512` |
| `hardware-configuration.nix` | 分区 UUID | **必须用系统生成的替换**。执行 `nixos-generate-config --root /mnt` 生成，确保 UUID 与实际分区匹配 |
| `modules/system/hardware.nix` | `amdgpuBusId` / `nvidiaBusId` | **必须确认**。用 `lspci` 查看实际 PCI 地址，当前为示例值 `PCI:6:0:0` 和 `PCI:1:0:0` |
| `configs/rime/` | 整个目录 | **必须放入用户自备配置**。当前仅含 README.md。需将 rime 配置（`.yaml`、词库等）放入此目录 |

### 建议修改

| 文件 | 需更改项 | 说明 |
|---|---|---|
| `home/zero/default.nix` | `programs.git.userName` / `userEmail` | 建议修改为实际 Git 用户名和邮箱 |
| `configs/niri/config.kdl` | 壁纸路径、输出配置 | 需放置壁纸到 `~/.config/niri/wallpaper.jpg`；输出配置（分辨率、缩放）需根据实际显示器调整 |
| `configs/waybar/config.jsonc` | 网络模块 | 由于不使用 NetworkManager，默认 `network` 模块可能不工作，当前已包含自定义网络模块 |

### 可选修改

| 文件 | 需更改项 | 说明 |
|---|---|---|
| `home/zero/packages.nix` | `environment.systemPackages` | 统一软件包组，所有用户可用。添加/删除软件在此处 |
| `modules/system/packages.nix` | `environment.sessionVariables` / `shellAliases` | 全局环境变量和别名 |
| `home/zero/shell.nix` | `programs.fish` | Fish Shell 配置（别名、函数、vi 键绑定） |
| `home/zero/config-files.nix` | `xdg.configFile` | 配置文件映射，添加新软件配置在此处 |
| `modules/system/lix.nix` | `nix.settings.substituters` | 国内镜像源，可按需增删 |
| `configs/kitty/kitty.conf` | 字体大小 | 可根据显示器分辨率调整 |
| `configs/mako/config` | 通知位置 | 当前为右上角 |

---

## 重要注意事项

1. **盘符随机变化**：Limine 使用 `efiInstallAsRemovable = true`，安装到 EFI 分区的 `/EFI/BOOT/BOOTX64.EFI`，不依赖 UEFI 启动项变量。分区挂载使用 UUID（在 `hardware-configuration.nix` 中），不受盘符变化影响。

2. **配置文件存放在 home 分区**：通过 `system.activationScripts` 自动创建 `/etc/nixos` → `/home/zero/nixos-config` 符号链接。更换/升级系统时不格式化 home 分区，配置永久保留。

3. **doas 替代 sudo**：系统未安装 sudo，所有特权命令使用 `doas`。如习惯 sudo，可在 `home/zero/shell.nix` 中添加 `alias sudo=doas`（已配置）。

4. **NVIDIA PRIME offload**：日常使用 AMD 核显输出，NVIDIA 用于高性能渲染。运行 NVIDIA 程序需加环境变量：
   ```bash
   __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia zen-browser
   ```

5. **xwayland-satellite**：X11 程序通过独立的 rootless XWayland 进程运行，在 niri 配置中自启。不要移除 `spawn-at-startup "Xwayland-satellite"`。

6. **Rime 配置**：用户自备配置放在 `configs/rime/`，映射到 `~/.local/share/fcitx5/rime/`。修改后执行 `fcitx5-remote -r` 重新加载。

7. **NTFS 支持**：内核内置 `ntfs3` 驱动（性能优于 ntfs-3g），同时安装了 `ntfs3g` 作为兼容。`boot.supportedFilesystems` 包含 `"ntfs"`。

8. **最小化软件包**：统一包组在 `home/zero/packages.nix`，仅保留基础工具、neovim 依赖和字体。其他软件（浏览器、办公、娱乐等）请自行添加。

---

## 相关文档

- `DIRECTORY-STRUCTURE.md` — 目录层级结构详细说明、配置文件映射机制、NixOS 模块系统
- `SOFTWARE-AND-KEYBINDINGS.md` — 系统软件生态结构、各软件使用说明、详尽快捷键
- `CHANGED.md` — 本次整合修改记录（修改前后比对）
