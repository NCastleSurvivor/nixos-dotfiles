# NCastleSurvivor — NixOS 配置

> Lix + NixOS 26.05 (unstable) + Limine + niri + noctalia + Home Manager + agenix + Flake

## 系统概览

| 项目 | 配置 |
|---|---|
| 主机名 | `NCastleSurvivor` |
| 用户名 | `zero` |
| CPU | AMD Ryzen 7 4800H |
| 显卡 | NVIDIA RTX 2060 + AMD Radeon（PRIME offload） |
| 网卡 | Intel AX210 (Wi-Fi 6E + BT 5.3) |
| 内核 | CachyOS Latest |
| 引导 | Limine（UEFI removable） |
| 桌面 | niri（Wayland）+ xwayland-satellite |
| 登录 | greetd + tuigreet |
| 状态栏/通知 | noctalia |
| 终端 | Kitty + Fish |
| 浏览器 | Zen Browser |
| 编辑器 | Neovim（lazy.nvim） |
| 输入法 | Fcitx5 + Rime |
| 音频 | PipeWire + WirePlumber |
| 网络 | NetworkManager + iwd + systemd-resolved |
| 特权 | doas（替代 sudo） |
| 密码管理 | agenix（age + SSH 主机密钥） |
| 包管理 | Lix + Flake |

---

## 目录结构

```
nixos-dotfiles/
├── flake.nix                    # Flake 入口
├── configuration.nix            # 系统主配置 + unfree 白名单
├── hardware-configuration.nix   # 硬件配置（nixos-generate-config 生成）
├── secrets/
│   ├── secrets.nix              # agenix 加密规则（公钥列表）
│   └── zero_password.age        # 加密的用户密码哈希
├── modules/
│   ├── system/                  # 系统模块
│   │   ├── boot.nix             # 引导/内核/内核参数
│   │   ├── hardware.nix         # NVIDIA/蓝牙/电源/TLP
│   │   ├── networking.nix       # NetworkManager/DNS/防火墙
│   │   ├── audio.nix            # PipeWire
│   │   ├── users.nix            # 用户/密码
│   │   ├── age.nix              # agenix 解密配置
│   │   ├── proxy.nix            # dae 透明代理（可选）
│   │   └── ...
│   └── desktop/                 # 桌面模块（niri/greetd/fcitx...）
├── home/zero/                   # Home Manager 用户配置
│   ├── packages.nix             # 统一软件包组
│   ├── shell.nix                # Fish 配置
│   ├── noctalia.nix             # noctalia 桌面 Shell
│   ├── zen-browser.nix          # Zen Browser + stylix
│   └── ...
├── configs/                     # 软件原始配置（niri/kitty/nvim/rime...）
│   └── dae/config.dae           # dae 代理配置（可选）
├── proxy.md                     # 代理软件配置指南
└── 配置审计与优化方案.md         # 配置审计报告
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

### 3. 配置 agenix 密码（首次部署）

```bash
# 进入工具环境
nix-shell -p age agenix mkpasswd

# 生成密码哈希
mkpasswd --method=yescrypt
# Password: <你的密码>
# 输出：$y$j9T$...（复制备用）

# 获取主机 SSH 公钥（转 age 格式）
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# → age1主机公钥...

# 编辑 secrets/secrets.nix，填入主机 age 公钥
nano secrets/secrets.nix

# 创建明文密码文件并加密
echo '$y$j9T$你的哈希' > /tmp/zero_password.txt
cd secrets
agenix -e zero_password.age < /tmp/zero_password.txt
rm /tmp/zero_password.txt

# 验证（需要主机私钥）
agenix -d zero_password.age
```

### 4. 安装

```bash
ln -sfn /mnt/home/zero/nixos-configuration /mnt/etc/nixos
nixos-install --flake .#NCastleSurvivor --substituters https://mirror.sjtu.edu.cn/nix-channels/store --impure
reboot
```

### 5. 首次登录后

```bash
nix-shell -p nix-info --run "nix-info -m"
echo $XDG_SESSION_TYPE   # wayland
nvidia-smi
fcitx5-remote -r         # 重载输入法
```

---

## agenix 密码管理

### 原理

用户密码哈希通过 [age](https://github.com/FiloSottile/age) 加密存储在 `secrets/zero_password.age`，可安全提交到 git。系统激活时用主机 SSH 私钥 (`/etc/ssh/ssh_host_ed25519_key`) 解密。

### 密钥说明

| 密钥 | 位置 | 作用 |
|------|------|------|
| 主机 ed25519 私钥 | `/etc/ssh/ssh_host_ed25519_key` | `nixos-rebuild` 时解密秘密 |
| 主机 ed25519 公钥（转 age） | `secrets/secrets.nix` | 加密时使用，仅本主机可解密 |

### 日常操作

```bash
# 查看密码哈希（需要主机私钥）
cd secrets && agenix -d zero_password.age

# 修改密码
mkpasswd --method=yescrypt | agenix -e zero_password.age
# 输入新密码后自动加密

# 修改后重新构建
doas nixos-rebuild switch --flake .#NCastleSurvivor
```

---

## 重装系统 / 更换电脑：agenix 重新加密密钥

当你重装系统或更换电脑时，主机 SSH 密钥会变化，导致旧的 `.age` 文件无法解密。有两种处理方式：

### 方式 A：迁移旧主机密钥（推荐，最简单）

如果旧电脑还能启动，直接备份并恢复密钥：

```bash
# ===== 旧电脑上操作 =====
# 备份主机 SSH 密钥
doas cp /etc/ssh/ssh_host_ed25519_key /mnt/usb/ssh_host_ed25519_key
doas cp /etc/ssh/ssh_host_ed25519_key.pub /mnt/usb/ssh_host_ed25519_key.pub

# ===== 新电脑上操作（安装系统前，在 live ISO 中）=====
# 先恢复密钥到目标系统
doas cp /mnt/usb/ssh_host_ed25519_key /mnt/etc/ssh/
doas cp /mnt/usb/ssh_host_ed25519_key.pub /mnt/etc/ssh/
doas chmod 600 /mnt/etc/ssh/ssh_host_ed25519_key
doas chmod 644 /mnt/etc/ssh/ssh_host_ed25519_key.pub

# 然后正常 nixos-install，密钥会被保留
```

> 恢复后无需重新加密 `.age` 文件，因为密钥没变。

---

### 方式 B：用新密钥重新加密（旧电脑不可用时）

如果旧电脑已无法启动，需要用新主机的公钥重新加密所有 `.age` 文件。

#### 步骤 1：获取新主机的 age 公钥

```bash
# 在新电脑上（安装完系统后）
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# 输出：age1xxxxxxxx...（复制备用）
```

#### 步骤 2：更新 `secrets/secrets.nix`

```nix
# secrets/secrets.nix
let
  # 替换为新主机的 age 公钥
  hostKey = "age1新主机公钥...";
in
{
  "zero_password.age".publicKeys = [ hostKey ];
}
```

#### 步骤 3：重新加密所有 `.age` 文件

```bash
# 进入 secrets 目录
cd secrets

# 方式一：如果你还能在某处解密旧文件（如另一台有旧密钥的机器）
# 先解密，再用新公钥加密
agenix -d zero_password.age > /tmp/zero_password.txt
agenix -e zero_password.age < /tmp/zero_password.txt
rm /tmp/zero_password.txt

# 方式二：使用 agenix --rekey（需要旧私钥可访问）
# 将旧私钥临时放到可访问位置
agenix -r -i /path/to/old/ssh_host_ed25519_key

# 方式三：如果完全无法解密旧文件，只能重新创建
mkpasswd --method=yescrypt | agenix -e zero_password.age
# 输入新密码
```

#### 步骤 4：验证并构建

```bash
# 验证新加密文件可被新主机解密
agenix -d zero_password.age

# 重新构建系统
cd ..
doas nixos-rebuild switch --flake .#NCastleSurvivor
```

---

### 方式 C：多主机密钥（提前配置，避免重装麻烦）

在 `secrets/secrets.nix` 中同时加入多台机器的公钥，这样任意一台都能解密：

```nix
# secrets/secrets.nix
let
  laptopKey = "age1笔记本公钥...";
  desktopKey = "age1台式机公钥...";
  backupKey = "age1备份密钥公钥...";  # age-keygen 生成的个人密钥
in
{
  "zero_password.age".publicKeys = [ laptopKey desktopKey backupKey ];
}
```

添加新主机后重新加密：

```bash
# 在已有解密权限的机器上执行
cd secrets
agenix --rekey
# 或：agenix -r -i /etc/ssh/ssh_host_ed25519_key
```

---

## 非自由软件管理

使用 `allowUnfreePredicate` 白名单替代全局 `allowUnfree = true`。各模块通过 `myUnfreePackages` 选项声明所需的非自由包，自动合并。

当前白名单（`home/zero/packages.nix`）：

| 包名 | 用途 |
|------|------|
| `qq` | 腾讯 QQ |
| `wechat-uos` | 微信 |
| `unrar` | RAR 解压 |
| `p7zip` | 7z 解压 |
| `wpsoffice-cn` | WPS Office |

> NVIDIA 驱动通过 `hardware.nvidia` 模块自动处理 unfree 许可，无需手动加入白名单。

---

## 需要修改的项

| 文件 | 需更改项 |
|------|----------|
| `hardware-configuration.nix` | 分区 UUID（`nixos-generate-config` 生成） |
| `modules/system/hardware.nix` | `amdgpuBusId` / `nvidiaBusId`（`lspci` 确认） |
| `home/zero/programs.nix` | Git 用户名和邮箱 |
| `secrets/secrets.nix` | 主机 age 公钥 |
| `secrets/zero_password.age` | 用自己的密码重新加密 |
| `configs/dae/config.dae` | 代理订阅链接（如使用代理） |

---

## 常用命令

```bash
# 构建并切换
doas nixos-rebuild switch --flake .#NCastleSurvivor

# 仅构建不切换
doas nixos-rebuild build --flake .#NCastleSurvivor

# 查看系统差异（升级前后）
nvd diff /run/current-system result

# 垃圾回收
doas nix-collect-garbage -d

# 更新所有 flake 输入
nix flake update

# 仅更新指定输入
nix flake lock --update-input nixpkgs
```
