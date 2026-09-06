# 系统与桌面软件使用说明及详尽快捷键

> 本文档详细说明 NCastleSurvivor NixOS 系统的软件生态结构、各软件的使用方法，以及完整的快捷键列表。

---

## 一、系统软件生态结构

### 1.1 整体架构

```
┌─────────────────────────────────────────────────────────────────┐
│                      用户应用层 (User Apps)                       │
│  Kitty 终端 │ Neovim 编辑器 │ Zen Browser │ PcmanFM-QT │ PeaZip │
├─────────────────────────────────────────────────────────────────┤
│                     桌面工具层 (Desktop Utils)                    │
│  Waybar │ Fuzzel │ Mako │ Swaylock │ Swayidle │ Swaybg │ Wob  │
│  Grim/Slurp 截图 │ Wl-clipboard 剪贴板 │ Blueman 蓝牙           │
├─────────────────────────────────────────────────────────────────┤
│                    输入与国际化层 (Input & I18n)                  │
│              Fcitx5 + Rime 输入法 │ GTK/Qt 主题                  │
├─────────────────────────────────────────────────────────────────┤
│                   桌面环境层 (Desktop Environment)                 │
│         niri Wayland 合成器 + xwayland-satellite                 │
│         greetd + tuigreet 登录管理器 │ XDG Desktop Portal        │
├─────────────────────────────────────────────────────────────────┤
│                     系统服务层 (System Services)                   │
│  PipeWire+WirePlumber │ Seatd │ Udisks2 │ UPower │ Polkit      │
│  dhcpcd(有线) │ iwd(无线) │ Bluetooth │ Journald                 │
├─────────────────────────────────────────────────────────────────┤
│                      硬件驱动层 (Hardware Drivers)                  │
│  NVIDIA RTX 2060 (PRIME offload) │ AMD R7-4800H 核显+微码      │
│  Intel AX210 (WiFi6+BT5.2) │ linux-firmware │
├─────────────────────────────────────────────────────────────────┤
│                     内核与引导层 (Kernel & Boot)                   │
│         CachyOS Latest 内核 │ Limine Bootloader              │
│         内核参数: nvidia_drm.modeset=1 / mitigations=off        │
├─────────────────────────────────────────────────────────────────┤
│                    包管理与配置层 (Package & Config)                │
│  Lix (替代 Nix) │ Flake │ Home Manager │ doas (替代 sudo)        │
│  Fish Shell │ 国内镜像: 5高校+官方                                │
├─────────────────────────────────────────────────────────────────┤
│                       文件系统层 (Filesystem)                       │
│  EFI 800M (vfat) │ / ~651G (xfs) │ /home 1.3T (xfs) │ NTFS 支持│
└─────────────────────────────────────────────────────────────────┘
```

### 1.2 各层软件详解

#### 引导与内核层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **Limine** | 轻量引导加载器，EFI 可移动安装，不依赖 UEFI 变量 | `modules/system/boot.nix` |
| **CachyOS Latest** | EEVDF+BORE 调度器，LTO 优化内核 | `modules/system/boot.nix` |

#### 包管理与配置层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **Lix** | 替代 Nix 的声明式包管理器，支持 Flakes | `modules/system/lix.nix` |
| **Flake** | 可复现的配置管理，锁定依赖版本 | `flake.nix` |
| **Home Manager** | 用户级配置管理，映射配置文件到 ~/.config | `home/zero/` |
| **doas** | 替代 sudo 的特权命令执行工具 | `modules/system/doas.nix` |
| **Fish Shell** | 交互式 Shell，语法高亮、自动补全 | `home/zero/shell.nix` |

#### 系统服务层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **PipeWire + WirePlumber** | 音频/视频服务，替代 PulseAudio/JACK | `modules/system/audio.nix` |
| **Seatd** | 座位管理，Wayland 合成器所需 | `modules/system/services.nix` |
| **Udisks2** | 磁盘挂载服务 | `modules/system/services.nix` |
| **UPower** | 电源管理，电池信息 | `modules/system/services.nix` |
| **Polkit** | 权限策略框架 | `modules/system/services.nix` |
| **dhcpcd** | 有线网络 DHCP 客户端 | `modules/system/networking.nix` |
| **iwd** | 无线网络管理（Intel 网卡推荐） | `modules/system/networking.nix` |
| **Bluetooth** | 蓝牙服务 + blueman 图形前端 | `modules/system/networking.nix` |
| **TLP** | 笔记本电源管理优化 | `modules/system/hardware.nix` |

#### 硬件驱动层

| 硬件 | 驱动/配置 | 说明 |
|---|---|---|
| **NVIDIA RTX 2060** | 专有驱动 + PRIME offload | 日常用核显省电，高性能程序用 NVIDIA |
| **AMD R7-4800H** | 核显 + CPU 微码 | 集成显卡，日常显示输出 |
| **Intel AX210** | WiFi 6 + 蓝牙 5.2 | iwd 管理 WiFi，bluez 管理蓝牙 |
| **linux-firmware** | 全量固件 | `hardware.enableAllFirmware = true` |

#### 桌面环境层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **niri** | Wayland 平铺合成器，可滚动工作区 | `configs/niri/config.kdl` |
| **xwayland-satellite** | 独立 rootless XWayland 进程，X11 兼容 | `modules/desktop/niri.nix` |
| **greetd + tuigreet** | TUI 风格的 Wayland 登录管理器 | `modules/desktop/greetd.nix` |
| **XDG Desktop Portal** | 桌面门户（截图/文件选择/屏幕共享） | `modules/system/services.nix` + `modules/desktop/tools.nix` |

#### 桌面工具层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **Waybar** | 高度可定制的 Wayland 状态栏 | `configs/waybar/` |
| **Fuzzel** | 轻量应用启动器（Wayland 原生） | `configs/fuzzel/fuzzel.ini` |
| **Mako** | Wayland 通知守护进程 | `configs/mako/config` |
| **Swaylock-effects** | Wayland 锁屏（带模糊/特效） | `configs/swaylock/config` |
| **Swayidle** | 空闲守护（自动息屏/锁屏/休眠） | niri config 中启动 |
| **Swaybg** | Wayland 壁纸设置工具 | niri config 中启动 |
| **Wob** | Wayland 浮动进度条（音量/亮度 OSD） | niri config 中启动 |
| **Grim + Slurp** | Wayland 截图工具（全屏/区域） | niri 快捷键绑定 |
| **Wl-clipboard** | Wayland 剪贴板管理 | 系统包 |
| **Blueman** | 蓝牙图形管理前端 | 系统包 |

#### 用户应用层

| 软件 | 作用 | 配置文件 |
|---|---|---|
| **Kitty** | GPU 加速终端模拟器 | `configs/kitty/kitty.conf` |
| **Neovim** | 现代 Vim 编辑器，LSP/补全/模糊搜索 | `configs/nvim/init.lua` |
| **Zen Browser** | 基于 Firefox 的隐私浏览器，垂直标签页 | `modules/desktop/tools.nix` |
| **PcmanFM-QT** | 轻量 Qt 文件管理器 | 系统包 |
| **PeaZip** | 跨平台压缩包管理器 | 系统包 |
| **Fcitx5 + Rime** | 输入法框架 + 中州韵输入法 | `modules/desktop/fcitx.nix` + `configs/rime/` |

---

## 二、详尽快捷键

### 2.1 niri 合成器快捷键

**Mod = Super / Win 键**

#### 常用操作

| 快捷键 | 作用 |
|---|---|
| `Mod + T` | 打开 Kitty 终端 |
| `Mod + Return` | 打开 Kitty 终端（同 Mod+T） |
| `Mod + D` | 打开 Fuzzel 应用启动器 |
| `Mod + Q` | 关闭当前窗口 |
| `Mod + F` | 切换全屏 |
| `Mod + Shift + F` | 切换浮动/平铺 |
| `Mod + Space` | 焦点移到下一列 |
| `Mod + Shift + R` | 重新加载 niri 配置 |
| `Mod + Shift + E` | 退出 niri（注销） |
| `Mod + P` | 打开 PcmanFM-QT 文件管理器 |
| `Mod + B` | 打开 Zen Browser 浏览器 |
| `Mod + Shift + S` | 系统挂起（休眠） |
| `Mod + Shift + L` | 锁屏（Swaylock） |

#### 工作区切换

| 快捷键 | 作用 |
|---|---|
| `Mod + 1` ~ `Mod + 9` | 切换到工作区 1~9 |
| `Mod + 0` | 切换到工作区 10 |
| `Mod + Shift + 1` ~ `Mod + Shift + 9` | 将当前窗口移到工作区 1~9 |
| `Mod + Shift + 0` | 将当前窗口移到工作区 10 |

#### 窗口焦点移动

| 快捷键 | 作用 |
|---|---|
| `Mod + H` / `Mod + Left` | 焦点移到左列 |
| `Mod + L` / `Mod + Right` | 焦点移到右列 |
| `Mod + J` / `Mod + Down` | 焦点移到下方窗口 |
| `Mod + K` / `Mod + Up` | 焦点移到上方窗口 |

#### 窗口移动

| 快捷键 | 作用 |
|---|---|
| `Mod + Shift + H` / `Mod + Shift + Left` | 当前列左移 |
| `Mod + Shift + L` / `Mod + Shift + Right` | 当前列右移 |
| `Mod + Shift + J` / `Mod + Shift + Down` | 当前窗口下移 |
| `Mod + Shift + K` / `Mod + Shift + Up` | 当前窗口上移 |

#### 窗口大小调整

| 快捷键 | 作用 |
|---|---|
| `Mod + Ctrl + H` | 减小列宽度 |
| `Mod + Ctrl + L` | 增大列宽度 |
| `Mod + Ctrl + J` | 减小窗口高度 |
| `Mod + Ctrl + K` | 增大窗口高度 |
| `Mod + Equal` | 增加列或工作区宽度 |
| `Mod + Minus` | 减少列或工作区宽度 |

#### 显示器切换

| 快捷键 | 作用 |
|---|---|
| `Mod + O` | 焦点移到下一个显示器 |
| `Mod + Shift + O` | 当前窗口移到下一个显示器 |

#### 媒体键

| 快捷键 | 作用 |
|---|---|
| `XF86AudioRaiseVolume` | 音量 +5% |
| `XF86AudioLowerVolume` | 音量 -5% |
| `XF86AudioMute` | 静音切换 |
| `XF86AudioPlay` | 播放/暂停 |
| `XF86AudioNext` | 下一曲 |
| `XF86AudioPrev` | 上一曲 |
| `XF86MonBrightnessUp` | 亮度 +5% |
| `XF86MonBrightnessDown` | 亮度 -5% |

#### 截图

| 快捷键 | 作用 |
|---|---|
| `Print` | 全屏截图到剪贴板 |
| `Shift + Print` | 区域截图到剪贴板（框选） |
| `Ctrl + Print` | 全屏截图并用 swappy 编辑 |

---

### 2.2 Kitty 终端快捷键

| 快捷键 | 作用 |
|---|---|
| `Ctrl + Shift + C` | 复制到剪贴板 |
| `Ctrl + Shift + V` | 从剪贴板粘贴 |
| `Ctrl + Shift + S` | 从选区粘贴 |
| `Ctrl + Shift + T` | 新建标签页 |
| `Ctrl + Shift + W` | 关闭标签页 |
| `Ctrl + Shift + Right` | 下一个标签页 |
| `Ctrl + Shift + Left` | 上一个标签页 |
| `Ctrl + Shift + Alt + T` | 设置标签页标题 |
| `Ctrl + Shift + Enter` | 新建窗口（分屏） |
| `Ctrl + Shift + R` | 关闭窗口（分屏） |
| `Ctrl + Shift + ]` | 下一个窗口 |
| `Ctrl + Shift + [` | 上一个窗口 |
| `Ctrl + Shift + F` | 切换堆叠布局 |
| `Ctrl + Shift + Z` | 滚动到上一个提示符 |
| `Ctrl + Shift + X` | 滚动到下一个提示符 |
| `Ctrl + Shift + G` | 滚动到开头 |
| `Ctrl + Shift + H` | 显示滚动历史 |
| `Ctrl + Equal` | 字体放大 +2 |
| `Ctrl + Minus` | 字体缩小 -2 |
| `Ctrl + 0` | 字体重置 |
| `Ctrl + Shift + U` | Unicode 输入 |
| `Ctrl + Shift + E` | 打开 kitten hints（选择链接/路径） |
| `Ctrl + Shift + Y` | 水平面板 |
| `F11` | 切换全屏 |
| `Ctrl + Shift + F11` | 切换最大化 |

---

### 2.3 Fuzzel 应用启动器快捷键

**启动：`Mod + D`**

| 快捷键 | 作用 |
|---|---|
| `Up` / `Ctrl + P` / `Ctrl + K` | 向上移动选择 |
| `Down` / `Ctrl + N` / `Ctrl + J` | 向下移动选择 |
| `Home` / `Ctrl + G` | 移到第一个 |
| `End` / `Ctrl + E` | 移到最后一个 |
| `Page_Up` / `Alt + V` | 向上翻页 |
| `Page_Down` / `Ctrl + V` | 向下翻页 |
| `Return` / `Ctrl + J` / `Ctrl + M` | 执行选中项 |
| `Shift + Return` / `Ctrl + Return` | 在终端中执行 |
| `Ctrl + T` | 在终端中执行 |
| `Escape` / `Ctrl + C` / `Ctrl + G` | 退出/取消 |
| `BackSpace` / `Ctrl + H` | 删除前一个字符 |
| `Ctrl + W` | 删除前一个词 |
| `Ctrl + U` | 删除整行 |
| `Left` / `Ctrl + B` | 光标左移 |
| `Right` / `Ctrl + F` | 光标右移 |
| `Alt + B` / `Ctrl + Left` | 光标左移一个词 |
| `Alt + F` / `Ctrl + Right` | 光标右移一个词 |
| `Ctrl + A` / `Home` | 光标移到行首 |
| `Ctrl + E` / `End` | 光标移到行尾 |

---

### 2.4 Fish Shell 快捷键与别名

#### 快捷键

| 快捷键 | 作用 |
|---|---|
| `Ctrl + R` | 搜索历史（vi 模式下也可用） |
| `Ctrl + C` | 中断当前命令 |
| `Ctrl + D` | 退出 Shell（EOF） |
| `Ctrl + L` | 清屏 |
| `Ctrl + A` | 光标移到行首 |
| `Ctrl + E` | 光标移到行尾 |
| `Alt + ←` / `Alt + B` | 光标左移一个词 |
| `Alt + →` / `Alt + F` | 光标右移一个词 |
| `Tab` | 自动补全 |
| `↑` / `↓` | 历史命令浏览 |

**Fish 使用 vi 键绑定**（已在配置中启用 `fish_vi_key_bindings`）：
- 按 `Esc` 进入普通模式
- 普通模式下 `h/j/k/l` 移动光标
- 按 `i` 进入插入模式
- `Ctrl + R` 在两种模式下都可搜索历史

#### 常用别名

| 别名 | 对应命令 | 作用 |
|---|---|---|
| `ls` | `eza --icons=auto` | 列表显示（带图标） |
| `ll` | `eza -l --icons=auto --git` | 详细列表 |
| `la` | `eza -a --icons=auto` | 显示隐藏文件 |
| `lla` | `eza -la --icons=auto --git` | 详细列表+隐藏文件 |
| `lt` | `eza --tree --icons=auto` | 树形显示 |
| `cat` | `bat` | 语法高亮的 cat |
| `grep` | `rg` | 更快的 grep |
| `find` | `fd` | 更快的 find |
| `vi` / `vim` | `nvim` | Neovim |
| `sudo` | `doas` | 特权命令 |
| `reboot` | `doas reboot` | 重启 |
| `poweroff` | `doas poweroff` | 关机 |
| `shutdown` | `doas shutdown now` | 立即关机 |
| `df` | `df -h` | 磁盘使用（人类可读） |
| `du` | `du -h` | 目录大小（人类可读） |
| `free` | `free -h` | 内存使用（人类可读） |
| `mkdir` | `mkdir -pv` | 创建目录（递归+显示） |
| `cp` | `cp -iv` | 复制（交互+显示） |
| `mv` | `mv -iv` | 移动（交互+显示） |
| `rm` | `rm -Iv` | 删除（交互+显示） |
| `..` | `cd ..` | 上一级目录 |
| `...` | `cd ../..` | 上两级目录 |
| `g` | `git` | Git |
| `gs` | `git status` | Git 状态 |
| `ga` | `git add` | Git 添加 |
| `gc` | `git commit` | Git 提交 |
| `gp` | `git push` | Git 推送 |
| `gl` | `git pull` | Git 拉取 |
| `gd` | `git diff` | Git 差异 |
| `gf` | `git fetch` | Git 获取 |
| `py` | `python3` | Python 3 |
| `h` | `history` | 历史命令 |
| `c` | `clear` | 清屏 |
| `q` | `exit` | 退出 |

#### 自定义函数

| 函数 | 作用 |
|---|---|
| `extract <file>` | 自动识别格式解压各种压缩包 |
| `mkcd <dir>` | 创建目录并进入 |
| `ports` | 查看端口占用（需 lsof） |
| `myip` | 查看公网 IP |
| `editconfig` | 编辑 fish 配置 |
| `reloadfish` | 重新加载 fish 配置 |

---

### 2.5 Neovim 快捷键

**Leader 键 = 空格（Space）**

#### 基础操作

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> w` | 保存 | 普通 |
| `<leader> q` | 退出 | 普通 |
| `<leader> x` | 保存并退出 | 普通 |
| `<leader> Q` | 强制退出所有 | 普通 |
| `<leader> h` | 清除搜索高亮 | 普通 |
| `<leader> a` | 全选 | 普通 |
| `<leader> +` | 增加数字 | 普通 |
| `<leader> -` | 减少数字 | 普通 |

#### 窗口导航

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `Ctrl + H` | 左窗口 | 普通 |
| `Ctrl + J` | 下窗口 | 普通 |
| `Ctrl + K` | 上窗口 | 普通 |
| `Ctrl + L` | 右窗口 | 普通 |
| `Ctrl + Left` | 窗口宽度 -2 | 普通 |
| `Ctrl + Right` | 窗口宽度 +2 | 普通 |
| `Ctrl + Up` | 窗口高度 -2 | 普通 |
| `Ctrl + Down` | 窗口高度 +2 | 普通 |
| `<leader> v` | 垂直分屏 | 普通 |
| `<leader> s` | 水平分屏 | 普通 |

#### 标签页与缓冲区

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> tn` | 新标签页 | 普通 |
| `<leader> tc` | 关闭标签页 | 普通 |
| `<leader> th` | 上一标签页 | 普通 |
| `<leader> tl` | 下一标签页 | 普通 |
| `<leader> bn` | 下一缓冲区 | 普通 |
| `<leader> bp` | 上一缓冲区 | 普通 |
| `<leader> bd` | 删除缓冲区 | 普通 |

#### 编辑操作

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<` / `>` | 左/右缩进（保持选中） | 可视 |
| `Alt + J` | 下移行/选中 | 普通/可视 |
| `Alt + K` | 上移行/选中 | 普通/可视 |
| `p` | 粘贴不覆盖（可视模式） | 可视 |
| `<leader> y` | 复制到系统剪贴板 | 普通/可视 |
| `<leader> Y` | 复制行到系统剪贴板 | 普通 |

#### 文件树（nvim-tree）

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> e` | 切换文件树 | 普通 |

#### 模糊搜索（Telescope）

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> ff` | 查找文件 | 普通 |
| `<leader> fg` | 查找内容（live grep） | 普通 |
| `<leader> fb` | 查找缓冲区 | 普通 |
| `<leader> fh` | 帮助标签 | 普通 |
| `<leader> fr` | 最近文件 | 普通 |

#### LSP

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `gd` | 跳转到定义 | 普通 |
| `gr` | 查找引用 | 普通 |
| `K` | 悬停显示文档 | 普通 |
| `<leader> ca` | 代码操作（Code Action） | 普通 |
| `<leader> rn` | 重命名 | 普通 |
| `<leader> f` | 格式化 | 普通 |

#### Git

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> gg` | 打开 LazyGit | 普通 |

#### 其他

| 快捷键 | 作用 | 模式 |
|---|---|---|
| `<leader> xx` | 打开 Trouble 问题列表 | 普通 |
| `<leader> t` | 打开浮动终端 | 普通 |
| `Esc` | 退出终端模式（浮动终端中） | 终端 |
| `Ctrl + Space` | 触发补全 | 插入 |
| `Ctrl + E` | 关闭补全 | 插入 |
| `Tab` | 下一个补全项/展开代码片段 | 插入 |
| `Shift + Tab` | 上一个补全项 | 插入 |
| `Ctrl + B` | 补全文档向上滚动 | 插入 |
| `Ctrl + F` | 补全文档向下滚动 | 插入 |

---

### 2.6 Mako 通知操作

Mako 通知本身没有内置快捷键，需要通过 niri 绑定 `makoctl` 命令。可在 niri config.kdl 中添加：

```kdl
// 示例（可自行添加到 configs/niri/config.kdl）
Mod+Shift+M { spawn "makoctl dismiss"; }       // 关闭当前通知
Mod+Shift+N { spawn "makoctl restore"; }        // 恢复通知
Mod+Shift+D { spawn "makoctl dismiss -a"; }     // 关闭所有通知
```

**鼠标操作**：
- 左键：执行默认操作
- 右键/中键：关闭通知

---

## 三、NVIDIA 双显卡使用

### 3.1 PRIME Offload 模式

系统使用 NVIDIA PRIME offload 模式：
- 日常显示输出使用 AMD 核显（省电）
- 需要高性能时使用 NVIDIA 独显

### 3.2 运行 NVIDIA 程序

在需要使用 NVIDIA 显卡的程序前添加环境变量：

```bash
# 方式一：使用环境变量
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia zen-browser

# 方式二：使用 niri-run（如果配置了）
niri-run zen-browser
```

### 3.3 验证 NVIDIA 工作

```bash
# 查看 NVIDIA 状态
nvidia-smi

# 测试 OpenGL（应显示 NVIDIA 显卡信息）
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep "OpenGL renderer"
```

---

## 四、输入法使用

### 4.1 Fcitx5 + Rime

- 输入法框架：Fcitx5
- 输入引擎：Rime（中州韵）
- 默认方案：rime-ice（雾凇拼音，用户自备配置）

### 4.2 输入法切换

| 操作 | 方法 |
|---|---|
| 切换中英文 | `Ctrl + Space`（默认）或 niri 中 `Win + Space`（切换键盘布局） |
| 切换输入方案 | 在 Rime 中按 `F4` |
| 重新加载配置 | `fcitx5-remote -r` |

### 4.3 Rime 配置位置

- 配置文件存放：`configs/rime/`（用户自备，放入此目录）
- 映射目标：`~/.local/share/fcitx5/rime/`
- 修改后执行：`fcitx5-remote -r` 重新加载

---

## 五、音频控制

### 5.1 PipeWire + WirePlumber

系统使用 PipeWire 作为音频服务，WirePlumber 作为会话管理器。

### 5.2 常用命令

| 命令 | 作用 |
|---|---|
| `wpctl status` | 查看音频设备状态 |
| `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+` | 音量 +5% |
| `wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-` | 音量 -5% |
| `wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle` | 静音切换 |
| `pavucontrol` | 图形音量控制（需自行安装） |

### 5.3 媒体键

键盘上的音量/播放键已在 niri 配置中绑定，可直接使用。

---

## 六、网络管理

### 6.1 有线网络（dhcpcd）

- 自动获取 IP，无需手动配置
- 配置文件：`modules/system/networking.nix`
- 禁用了 IPv6（`ipv4only`）
- 启动时不等待网络（`dhcpcd-wait-online.enable = false`）

### 6.2 无线网络（iwd）

| 命令 | 作用 |
|---|---|
| `iwctl` | 进入 iwd 交互界面 |
| `iwctl station wlan0 scan` | 扫描 WiFi |
| `iwctl station wlan0 get-networks` | 列出可用 WiFi |
| `iwctl station wlan0 connect "SSID"` | 连接 WiFi |
| `iwctl station wlan0 show` | 查看连接状态 |

### 6.3 蓝牙

| 命令 | 作用 |
|---|---|
| `blueman-manager` | 图形蓝牙管理（托盘图标） |
| `bluetoothctl` | 命令行蓝牙管理 |

---

## 七、截图与录屏

### 7.1 截图（Grim + Slurp）

| 快捷键 | 作用 |
|---|---|
| `Print` | 全屏截图到剪贴板 |
| `Shift + Print` | 区域截图到剪贴板（框选） |
| `Ctrl + Print` | 全屏截图并用 swappy 编辑 |

### 7.2 保存截图到文件

```bash
# 全屏截图保存
grim ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png

# 区域截图保存
grim -g "$(slurp)" ~/pictures/screenshot-$(date +%Y%m%d-%H%M%S).png
```

---

## 八、文件管理器

### 8.1 PcmanFM-QT

- 启动：`Mod + P` 或应用启动器搜索
- 轻量 Qt 文件管理器
- 支持挂载 U 盘/移动硬盘（通过 udisks2 + udiskie）
- 支持标签页、双面板

### 8.2 压缩包管理（PeaZip）

- 启动：应用启动器搜索 "peazip"
- 支持几乎所有压缩格式（zip/rar/7z/tar/gz/xz/zst 等）
- 跨平台，界面友好

---

## 九、浏览器（Zen Browser）

### 9.1 简介

- **Zen Browser**：基于 Firefox 的隐私优先浏览器，主打垂直标签页、侧边栏、分屏浏览
- 启动：`Mod + B` 或应用启动器搜索 "zen"
- 包名：`zen-browser`（已在 `modules/desktop/tools.nix` 中安装，通过 flake input `zen-browser` 提供）
- 配置目录：`~/.zen/`（浏览器自身管理，不通过 Home Manager 映射）

### 9.2 常用快捷键

| 快捷键 | 作用 |
|---|---|
| `Ctrl + T` | 新建标签页 |
| `Ctrl + W` | 关闭标签页 |
| `Ctrl + Shift + T` | 恢复关闭的标签页 |
| `Ctrl + L` | 聚焦地址栏 |
| `Ctrl + F` | 页面内搜索 |
| `Ctrl + R` / `F5` | 刷新页面 |
| `Ctrl + Shift + R` / `Ctrl + F5` | 强制刷新（忽略缓存） |
| `Ctrl + Tab` | 下一个标签页 |
| `Ctrl + Shift + Tab` | 上一个标签页 |
| `Ctrl + 1` ~ `Ctrl + 8` | 切换到第 1~8 个标签页 |
| `Ctrl + 9` | 切换到最后一个标签页 |
| `Ctrl + N` | 新建窗口 |
| `Ctrl + Shift + N` | 新建隐私窗口 |
| `Ctrl + D` | 收藏当前页面 |
| `Ctrl + H` | 历史记录 |
| `Ctrl + J` | 下载记录 |
| `Ctrl + Shift + A` | 附加组件/扩展管理 |
| `Ctrl + ,` | 设置 |
| `F11` | 全屏 |
| `Ctrl + Shift + P` | 分屏浏览（Zen 特有） |
| `Alt + Left` | 后退 |
| `Alt + Right` | 前进 |
| `Escape` | 停止加载 / 退出全屏 |

### 9.3 使用 NVIDIA 独显运行

如需用 NVIDIA 显卡运行浏览器（游戏、视频硬解等）：

```bash
__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia zen-browser
```

---

## 十、系统监控

| 命令 | 作用 |
|---|---|
| `htop` | 交互式进程/资源监控 |
| `nvidia-smi` | NVIDIA 显卡状态 |
| `df -h` | 磁盘使用 |
| `free -h` | 内存使用 |
| `journalctl -b -p err` | 查看本次启动的错误日志 |
| `systemctl --failed` | 查看失败的系统服务 |
