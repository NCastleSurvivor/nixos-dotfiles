# 目录层级结构说明

> 本文档详细说明 NCastleSurvivor NixOS 配置仓库的目录结构、每个文件的作用，以及配置文件的映射机制。

---

## 一、完整目录树

```
NCastleSurvivor-nixos/                        # 配置仓库根目录
│                                              # 实际存放路径：/home/zero/nixos-config/
│                                              # 通过 activation script 映射到 /etc/nixos/
│
├── flake.nix                                 # Flake 入口文件（inputs/outputs）
├── flake.lock                                # 依赖锁定文件
├── configuration.nix                         # 系统主配置（imports 聚合 + 用户 + 映射）
├── hardware-configuration.nix                # 硬件配置（分区挂载/内核模块，建议用系统生成的替换）
├── README.md                                 # 主文档（安装指南/注意事项/镜像说明）
├── DIRECTORY-STRUCTURE.md                    # 本文档：目录层级结构说明
├── SOFTWARE-AND-KEYBINDINGS.md              # 软件使用说明 + 详尽快捷键
├── CHANGED.md                                # 本次整合修改记录（前后比对）
├── .gitignore                                # Git 忽略规则
│
├── modules/                                  # NixOS 系统模块目录
│   ├── system/                               # 系统级模块（9 个文件）
│   │   ├── default.nix                       # 聚合：imports 同目录所有模块
│   │   ├── boot.nix                          # 引导：Limine + CachyOS 内核 + 内核参数 + initrd
│   │   ├── hardware.nix                      # 硬件：NVIDIA + AMD + 固件 + 电源管理 + TLP + 传感器
│   │   ├── lix.nix                           # 包管理器：Lix + 国内镜像 substituters
│   │   ├── doas.nix                          # 特权管理：doas 替代 sudo
│   │   ├── networking.nix                    # 网络：dhcpcd + iwd + 防火墙 + 蓝牙 + 网络工具
│   │   ├── audio.nix                         # 音频：PipeWire + WirePlumber
│   │   ├── services.nix                      # 系统服务：seatd/udisks2/upower/polkit/portal
│   │   └── packages.nix                      # 全局环境变量 + Shell 别名（包组已移至 home/zero/）
│   │
│   └── desktop/                              # 桌面环境模块（5 个文件）
│       ├── default.nix                       # 聚合：imports 同目录所有模块
│       ├── greetd.nix                        # 登录管理器：greetd + tuigreet
│       ├── niri.nix                          # 合成器：niri + xwayland-satellite + GTK 主题
│       ├── fcitx.nix                         # 输入法：fcitx5 + rime
│       └── tools.nix                         # 桌面工具：waybar/fuzzel/mako/kitty/zen-browser/pcmanfm-qt/peazip
│
├── home/                                     # Home Manager 用户配置目录
│   └── zero/                                 # 用户 zero 的配置（4 个文件）
│       ├── default.nix                       # 入口：用户信息 + Git + Kitty + 聚合 shell+config-files
│       ├── packages.nix                      # ★ 统一软件包组（environment.systemPackages，所有用户可用）
│       ├── shell.nix                         # Fish Shell：环境变量/别名/函数/vi 键绑定
│       └── config-files.nix                  # 配置文件映射：xdg.configFile + 字体 + Rime 映射
│
├── configs/                                  # 软件原始配置文件目录
│   │                                         # 通过 Home Manager 映射到 ~/.config/
│   ├── limine/                               # Limine 参考配置（不映射，实际由 NixOS 生成）
│   │   └── limine.cfg
│   ├── waybar/                               # Waybar 状态栏配置
│   │   ├── config.jsonc                      # 主配置：模块布局/位置
│   │   ├── style.css                         # 样式：颜色/字体/间距
│   │   └── modules/                          # 自定义模块脚本
│   │       ├── updates.sh                    # 系统更新检查
│   │       └── weather.sh                    # 天气
│   ├── niri/                                 # Niri 合成器配置
│   │   └── config.kdl                        # 键绑定/窗口规则/布局/动画/自启
│   ├── fuzzel/                               # Fuzzel 应用启动器
│   │   └── fuzzel.ini
│   ├── kitty/                                # Kitty 终端
│   │   └── kitty.conf
│   ├── mako/                                 # Mako 通知守护
│   │   └── config
│   ├── swaylock/                             # Swaylock 锁屏
│   │   └── config
│   ├── rime/                                 # Rime 输入法配置（用户自备）
│   │   └── README.md                         # 说明：将 rime 配置放入此目录
│   └── nvim/                                 # Neovim 编辑器
│       └── init.lua                          # 插件管理/键绑定/UI
│
└── scripts/                                  # 辅助脚本
    └── install.sh                            # 安装辅助脚本
```

---

## 二、各层级作用说明

### 2.1 根目录文件

| 文件 | 作用 | 修改频率 |
|---|---|---|
| `flake.nix` | Flake 入口，定义 inputs（nixpkgs/home-manager/cachyos内核/zen-browser）和 outputs（nixosConfigurations/formatter） | 低（添加新 flake 输入时） |
| `flake.lock` | 依赖锁定，记录所有 inputs 的精确版本和哈希 | 自动（`nix flake update` 时更新） |
| `configuration.nix` | 系统主配置，imports 聚合所有模块，设置 locale/用户/activation 映射 | 中（添加新模块/修改用户时） |
| `hardware-configuration.nix` | 硬件配置，分区挂载/内核模块/CPU微码，**建议用系统生成的直接替换** | 低（硬件变更时） |
| `README.md` | 主文档，安装指南/注意事项/镜像说明/目录结构索引 | 低 |
| `DIRECTORY-STRUCTURE.md` | 本文档，目录层级结构详细说明 | 低 |
| `SOFTWARE-AND-KEYBINDINGS.md` | 软件使用说明 + 详尽快捷键 | 低（软件/快捷键变更时） |
| `CHANGED.md` | 本次整合修改记录（修改前后比对） | 仅本次 |

### 2.2 modules/system/ 系统级模块

| 文件 | 作用 | 关键配置项 |
|---|---|---|
| `default.nix` | 聚合模块，imports 同目录下所有 .nix 文件 | — |
| `boot.nix` | 引导加载器 + 内核 + initrd + 文件系统支持 | `boot.loader.limine`、`boot.kernelPackages`、`boot.kernelParams`、`boot.kernelModules`、`boot.initrd` |
| `hardware.nix` | 硬件驱动 + 固件 + 电源管理 + 传感器 | `hardware.nvidia`、`hardware.cpu.amd`、`hardware.enableAllFirmware`、`hardware.firmware`、`powerManagement`、`services.tlp` |
| `lix.nix` | 包管理器 + 国内镜像 | `nix.package`、`nix.settings.substituters`、`nix.settings.experimental-features` |
| `doas.nix` | 特权管理 | `security.doas`、`security.sudo.enable = false` |
| `networking.nix` | 网络 + 蓝牙 + 网络工具 | `networking.dhcpcd`、`networking.wireless.iwd`、`networking.firewall`、`hardware.bluetooth`、`systemd.services.dhcpcd-wait-online` |
| `audio.nix` | 音频服务 | `services.pipewire`、`security.rtkit` |
| `services.nix` | 系统基础服务 | `services.seatd`、`services.udisks2`、`services.upower`、`security.polkit`、`xdg.portal` |
| `packages.nix` | 全局环境变量 + Shell 别名 | `environment.sessionVariables`、`environment.shellAliases` |

> **注意**：`modules/system/packages.nix` 不再包含软件包列表。统一软件包组已移至 `home/zero/packages.nix`（使用 `environment.systemPackages`，所有用户可用）。

### 2.3 modules/desktop/ 桌面环境模块

| 文件 | 作用 | 关键配置项 |
|---|---|---|
| `default.nix` | 聚合模块 | — |
| `greetd.nix` | 登录管理器 | `services.greetd`、tuigreet 命令 |
| `niri.nix` | Wayland 合成器 | `programs.xwayland.enable = false`、`environment.sessionVariables`、`gtk` |
| `fcitx.nix` | 输入法 | `i18n.inputMethod`、fcitx5 systemd 用户服务 |
| `tools.nix` | 桌面工具包 | waybar/fuzzel/mako/kitty/zen-browser/pcmanfm-qt/peazip/grim/slurp 等 |

### 2.4 home/zero/ Home Manager 用户配置

| 文件 | 作用 | 关键配置项 |
|---|---|---|
| `default.nix` | 入口 + 聚合 | `home.username`、`programs.git`、`programs.kitty`、imports（shell.nix + config-files.nix） |
| `packages.nix` | **统一软件包组**（系统级，所有用户可用） | `environment.systemPackages`（整合原系统级和用户级所有包） |
| `shell.nix` | Fish Shell 配置 | `programs.fish`（环境变量/别名/函数/键绑定） |
| `config-files.nix` | 配置文件映射 + 字体 | `xdg.configFile`、`xdg.dataFile`、`fonts.fonts`、`fonts.fontconfig` |

> **重要**：`home/zero/packages.nix` 虽然物理位置在 `home/zero/` 下，但它定义的是 `environment.systemPackages`（NixOS 系统级选项），在 `configuration.nix` 中作为 NixOS 模块直接 import，**不是** Home Manager 模块。因此所有用户（包括 root）都能使用这些软件。

### 2.5 configs/ 软件原始配置

| 目录 | 软件 | 映射目标 | 配置格式 |
|---|---|---|---|
| `configs/waybar/` | Waybar 状态栏 | `~/.config/waybar/` | JSONC + CSS + Shell |
| `configs/niri/` | Niri 合成器 | `~/.config/niri/` | KDL |
| `configs/fuzzel/` | Fuzzel 启动器 | `~/.config/fuzzel/` | INI |
| `configs/kitty/` | Kitty 终端 | `~/.config/kitty/` | conf |
| `configs/mako/` | Mako 通知 | `~/.config/mako/` | conf |
| `configs/swaylock/` | Swaylock 锁屏 | `~/.config/swaylock/` | conf |
| `configs/nvim/` | Neovim 编辑器 | `~/.config/nvim/` | Lua |
| `configs/rime/` | Rime 输入法 | `~/.local/share/fcitx5/rime/` | YAML（用户自备） |
| `configs/limine/` | Limine 参考 | 不映射（参考用） | conf |

---

## 三、配置文件映射机制

### 3.1 映射原理

所有软件配置文件存放在仓库的 `configs/` 目录下，通过 **Home Manager** 的 `xdg.configFile` 选项映射到用户的 `~/.config/` 目录。

映射定义在 `home/zero/config-files.nix` 中：

```nix
xdg.configFile = {
  "waybar/config.jsonc".source = "${configsDir}/waybar/config.jsonc";
  "waybar/style.css".source      = "${configsDir}/waybar/style.css";
  "waybar/modules".source         = "${configsDir}/waybar/modules";  # 目录也可映射
  "niri/config.kdl".source        = "${configsDir}/niri/config.kdl";
  "fuzzel/fuzzel.ini".source      = "${configsDir}/fuzzel/fuzzel.ini";
  "kitty/kitty.conf".source       = "${configsDir}/kitty/kitty.conf";
  "mako/config".source            = "${configsDir}/mako/config";
  "swaylock/config".source        = "${configsDir}/swaylock/config";
  "nvim/init.lua".source          = "${configsDir}/nvim/init.lua";
};

# fcitx5-rime 数据映射到 ~/.local/share/fcitx5/rime/（非 ~/.config/）
xdg.dataFile."fcitx5/rime".source = "${configsDir}/rime";
```

其中 `configsDir` 是在 `flake.nix` 的 `specialArgs` 中定义的：

```nix
specialArgs = {
  configsDir = ./configs;  # 指向仓库根目录下的 configs/
};
```

### 3.2 映射后的实际效果

执行 `nixos-rebuild switch` 后，Home Manager 会在 `~/.config/` 下创建**只读符号链接**，指向 Nix store 中的配置文件：

```bash
ls -la ~/.config/kitty/kitty.conf
# 输出：~/.config/kitty/kitty.conf -> /nix/store/...-kitty.conf
```

**重要**：映射到 `~/.config/` 的文件是**只读**的，不能直接在 `~/.config/` 中编辑。必须修改仓库 `configs/` 中的源文件，然后重新构建。

### 3.3 修改现有配置文件

```bash
# 1. 编辑仓库中的源文件
nvim /home/zero/nixos-config/configs/kitty/kitty.conf

# 2. 重新构建并应用
doas nixos-rebuild switch --flake /home/zero/nixos-config#NCastleSurvivor

# 3. 验证映射结果
ls -la ~/.config/kitty/kitty.conf

# 4. 部分软件支持热重载（无需重启软件）
#    niri:    Mod+Shift+R 或 niri msg action reload-config
#    kitty:   kitty @ set-colors --all --configured ~/.config/kitty/kitty.conf
#    mako:    makoctl reload
#    waybar:  killall -SIGUSR2 waybar 或 waybar -r
#    fuzzel:  下次启动时自动加载新配置
```

### 3.4 新增配置文件

以新增 `alacritty` 终端配置为例：

```bash
# 1. 在 configs/ 下创建新目录和配置文件
mkdir -p /home/zero/nixos-config/configs/alacritty
nvim /home/zero/nixos-config/configs/alacritty/alacritty.toml

# 2. 在 home/zero/config-files.nix 的 xdg.configFile 中添加映射
#    添加一行：
#    "alacritty/alacritty.toml".source = "${configsDir}/alacritty/alacritty.toml";

# 3. 如果该软件需要安装，在 home/zero/packages.nix 或 modules/desktop/tools.nix 中添加包
#    environment.systemPackages = with pkgs; [ ... alacritty ];

# 4. 重新构建
doas nixos-rebuild switch --flake /home/zero/nixos-config#NCastleSurvivor

# 5. 验证
ls -la ~/.config/alacritty/alacritty.toml
```

### 3.5 新增数据文件（非 ~/.config/ 路径）

对于需要映射到 `~/.local/share/` 等非 `~/.config/` 路径的文件，使用 `xdg.dataFile`：

```nix
# 映射到 ~/.local/share/fcitx5/rime/
xdg.dataFile."fcitx5/rime".source = "${configsDir}/rime";

# 映射到 ~/.local/share/fonts/
xdg.dataFile."fonts/MyFont.ttf".source = "${configsDir}/fonts/MyFont.ttf";
```

### 3.6 删除配置文件

1. 从 `configs/` 目录删除源文件
2. 从 `home/zero/config-files.nix` 中删除对应的映射条目
3. 重新构建：`doas nixos-rebuild switch`
4. Home Manager 会自动清理 `~/.config/` 中不再管理的文件

### 3.7 注意事项

| 注意项 | 说明 |
|---|---|
| **只读** | 映射到 `~/.config/` 的文件是只读的，必须修改仓库 `configs/` 中的源文件 |
| **构建生效** | 修改后必须执行 `nixos-rebuild switch` 才能生效 |
| **热重载** | niri/kitty/mako/waybar 支持热重载；fuzzel/nvim 下次启动生效 |
| **目录映射** | `xdg.configFile` 支持映射整个目录（如 `waybar/modules`），会递归复制 |
| **configsDir** | 所有映射路径基于 `${configsDir}`，即仓库根目录下的 `configs/` |
| **rime 配置** | rime 配置映射到 `~/.local/share/fcitx5/rime/`，不是 `~/.config/` |
| **limine 配置** | `configs/limine/limine.cfg` 仅作参考，不映射，实际由 NixOS 生成到 `/boot/limine.cfg` |
| **壁纸** | niri 配置中引用 `~/.config/niri/wallpaper.jpg`，需手动放置壁纸到该路径 |

---

## 四、NixOS 模块系统说明

### 4.1 模块聚合机制

NixOS 使用模块系统，所有 `.nix` 文件通过 `imports` 聚合：

```
flake.nix
  └── configuration.nix (imports)
        ├── hardware-configuration.nix
        ├── home/zero/packages.nix        ← 统一软件包组（系统级模块）
        └── modules/ (imports)
              ├── system/default.nix (imports)
              │     ├── boot.nix
              │     ├── hardware.nix
              │     ├── lix.nix
              │     ├── doas.nix
              │     ├── networking.nix
              │     ├── audio.nix
              │     ├── services.nix
              │     └── packages.nix      ← 仅环境变量+别名（无包列表）
              └── desktop/default.nix (imports)
                    ├── greetd.nix
                    ├── niri.nix
                    ├── fcitx.nix
                    └── tools.nix

Home Manager（通过 flake.nix 中的 home-manager.users.zero 导入）
  └── home/zero/default.nix (imports)
        ├── shell.nix
        └── config-files.nix
```

> **关键设计**：`home/zero/packages.nix` 虽然在 `home/zero/` 目录下，但它是作为 **NixOS 系统模块**在 `configuration.nix` 中 import 的，定义 `environment.systemPackages`。它**不是** Home Manager 模块，因此不在 `home/zero/default.nix` 的 imports 中。

### 4.2 配置合并规则

- 多个模块中定义的相同选项会**自动合并**（如 `environment.systemPackages` 会合并所有模块的包列表）
- 列表类型（list）会拼接合并
- 属性集（attrset）会递归合并
- 单值类型后面的定义会覆盖前面的（除非使用 `mkForce`/`mkDefault`）

### 4.3 软件包分布说明

当前配置中，软件包分布在以下几个位置：

| 位置 | 选项 | 作用域 | 包含内容 |
|---|---|---|---|
| `home/zero/packages.nix` | `environment.systemPackages` | 所有用户 | 基础工具、neovim 及依赖、额外字体（统一包组） |
| `modules/system/networking.nix` | `environment.systemPackages` | 所有用户 | 网络工具（inetutils/dnsutils/iwd/bluez/nmap 等） |
| `modules/system/hardware.nix` | `environment.systemPackages` | 所有用户 | 硬件工具（nvidia-vaapi-driver/lshw/powertop/tlp 等） |
| `modules/desktop/tools.nix` | `environment.systemPackages` | 所有用户 | 桌面工具（waybar/fuzzel/mako/kitty/zen-browser/pcmanfm-qt 等） |

> 所有包均使用 `environment.systemPackages`（系统级），因此 root 和所有普通用户都能使用。各模块的专属依赖保留在对应模块文件中，便于维护。

---

## 五、配置仓库存放与映射

### 5.1 存放位置

配置仓库实际存放在 **home 分区**：`/home/zero/nixos-config/`

这样设计的目的：
- home 分区独立，更换系统时配置不丢失
- 配置文件与用户数据放在一起，便于备份
- 升级/更换其他 Linux 发行版时，home 分区内容不做改变

### 5.2 映射到 /etc/nixos

通过 `configuration.nix` 中的 `system.activationScripts` 自动映射：

```nix
system.activationScripts.link-nixos-config = {
  deps = [ "users" "groups" "specialfs" ];
  text = ''
    NIXOS_CONFIG_HOME="/home/zero/nixos-config"
    if [ ! -e /etc/nixos ] && [ -d "$NIXOS_CONFIG_HOME" ]; then
      ln -s "$NIXOS_CONFIG_HOME" /etc/nixos
    fi
    # ... 更多逻辑
  '';
};
```

每次 `nixos-rebuild switch` 时都会确保 `/etc/nixos` 指向配置仓库。

### 5.3 首次安装时的手动映射

首次安装时（在 Live ISO 环境中）需要手动创建映射：

```bash
# 假设配置已复制到 /mnt/home/zero/nixos-config/
ln -sfn /mnt/home/zero/nixos-config /mnt/etc/nixos
```

安装完成后，activation script 会自动维护这个映射。
