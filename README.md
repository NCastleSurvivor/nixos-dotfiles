# NCastleSurvivor — NixOS 配置

> Lix + NixOS 26.05 (unstable) + Limine + niri + noctalia + Home Manager + sops-nix + Flake

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
| 密码管理 | sops-nix（age 加密） |
| 包管理 | Lix + Flake |

---

## 目录结构

```
nixos-dotfiles/
├── flake.nix                    # Flake 入口
├── configuration.nix            # 系统主配置 + unfree 白名单
├── hardware-configuration.nix   # 硬件配置（勿手改，由 nixos-generate-config 生成）
├── .sops.yaml                   # sops 加密规则（公钥）
├── secrets/
│   └── secrets.yaml             # 加密的用户密码哈希
├── modules/
│   ├── system/                  # 系统模块（boot/hardware/network/audio/users/sops...）
│   └── desktop/                 # 桌面模块（niri/greetd/fcitx/xwayland...）
├── home/zero/                   # Home Manager 用户配置
│   ├── packages.nix             # 统一软件包组（系统级 environment.systemPackages）
│   ├── shell.nix                # Fish 配置
│   ├── programs.nix             # Git 配置
│   ├── config-files.nix         # 配置文件映射（configs/ → ~/.config/）
│   ├── noctalia.nix             # noctalia 桌面 Shell
│   └── zen-browser.nix          # Zen Browser
└── configs/                     # 软件原始配置（niri/kitty/nvim/rime...）
```

---

## 快速部署

### 1. 分区与挂载

```bash
# 用 lsblk 确认盘符，用 UUID 挂载
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

### 3. 配置 sops-nix 密码（首次部署）

```bash
# 进入工具环境
nix-shell -p sops age ssh-to-age mkpasswd

# 生成密码哈希
mkpasswd --method=yescrypt
# Password: <你的密码>
# 输出：$y$j9T$...（复制备用）

# 获取主机 SSH 公钥（转 age 格式）
ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub
# → age1主机公钥...

# 生成个人 age 密钥对
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# → age1个人公钥...

# 编辑 .sops.yaml，填入上面两个公钥
nano .sops.yaml

# 创建明文秘密文件并加密
mkdir -p secrets
echo 'zero_password: "$y$j9T$你的哈希"' > secrets/secrets.yaml
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt
sops -e -i secrets/secrets.yaml

# 验证
sops -d secrets/secrets.yaml
```

### 4. 安装

```bash
ln -sfn /mnt/home/zero/nixos-configuration /mnt/etc/nixos
nixos-install --flake .#NCastleSurvivor --substituters https://mirror.sjtu.edu.cn/nix-channels/store --impure
reboot
```

### 5. 首次登录后

```bash
# 验证
nix-shell -p nix-info --run "nix-info -m"
echo $XDG_SESSION_TYPE   # wayland
nvidia-smi

# 部署 Rime 配置后重载
fcitx5-remote -r
```

---

## sops-nix 密码管理

### 原理

用户密码哈希通过 [age](https://github.com/FiloSottile/age) 加密存储在 `secrets/secrets.yaml`，可安全提交到 git。系统激活时用主机 SSH 私钥解密到 `/run/secrets-for-users/`。

### 密钥说明

| 密钥 | 位置 | 作用 |
|------|------|------|
| 主机 ed25519 私钥 | `/etc/ssh/ssh_host_ed25519_key` | `nixos-rebuild` 时解密秘密 |
| 主机 ed25519 公钥（转 age） | `.sops.yaml` | 加密时使用，仅本主机可解密 |
| 个人 age 私钥 | `~/.config/sops/age/keys.txt` | 日常编辑秘密文件时解密 |
| 个人 age 公钥 | `.sops.yaml` | 加密时使用，让你能在任意机器编辑 |

### 日常操作

```bash
export SOPS_AGE_KEY_FILE=~/.config/sops/age/keys.txt

# 查看密码哈希
sops -d --extract '["zero_password"]' secrets/secrets.yaml

# 修改密码（自动解密→编辑器→重新加密）
sops secrets/secrets.yaml

# 修改后重新构建
doas nixos-rebuild switch --flake .#NCastleSurvivor

# 添加新机器解密权限
# 1. 在 .sops.yaml 中添加新机器 age 公钥
# 2. 重新加密：sops updatekeys secrets/secrets.yaml
```

### 重装/换电脑

```bash
# 旧电脑：备份主机密钥和个人密钥
doas cp /etc/ssh/ssh_host_ed25519_key* backup/
cp ~/.config/sops/age/keys.txt backup/

# 新电脑：恢复密钥后即可正常解密构建
doas cp backup/ssh_host_ed25519_key* /etc/ssh/
cp backup/keys.txt ~/.config/sops/age/
```

---

## 非自由软件管理

使用 `allowUnfreePredicate` 白名单替代全局 `allowUnfree = true`。各模块通过 `myUnfreePackages` 选项声明所需的非自由包，自动合并。

当前白名单：

| 包名 | 用途 | 声明文件 |
|------|------|----------|
| `qq` | 腾讯 QQ | `home/zero/packages.nix` |
| `wechat-uos` | 微信 | `home/zero/packages.nix` |
| `unrar` | RAR 解压 | `home/zero/packages.nix` |
| `nvidia-x11` | NVIDIA 驱动 | `modules/system/hardware.nix` |
| `nvidia-settings` | NVIDIA 设置面板 | `modules/system/hardware.nix` |



---

## 需要修改的项

| 文件 | 需更改项 |
|------|----------|
| `hardware-configuration.nix` | 分区 UUID（用 `nixos-generate-config` 生成） |
| `modules/system/hardware.nix` | `amdgpuBusId` / `nvidiaBusId`（用 `lspci` 确认） |
| `home/zero/programs.nix` | Git 用户名和邮箱 |
| `secrets/secrets.yaml` | 用自己的密码哈希重新加密 |

