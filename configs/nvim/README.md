# LazyVim 配置

[English](README_EN.md) | 简体中文

[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)
[![LazyVim](https://img.shields.io/badge/LazyVim-v8-green.svg)](https://github.com/LazyVim/LazyVim)

基于 [LazyVim](https://github.com/LazyVim/LazyVim) 的个人 Neovim 配置，面向以键盘为主的日常开发流程，预先接入了 LSP、搜索、文件管理、Markdown 和常用语言支持。

> 配套文档与博客说明见 <https://longwaybai.github.io/docs/lazyvim/>。本仓库保存实际配置，文档站提供安装说明、快捷键速查、插件选型说明与延伸文章。

![LazyVim dashboard](https://longwaybai.github.io/img/lazyvim/lazyvim.png)

![Yazi integration](https://longwaybai.github.io/assets/images/yazi-a8663bf253da6cfd16990f094bff2a05.png)

## ✨ 特性

- 以 LazyVim v8 为基础，保留默认生态，同时按个人工作流做定制
- 默认使用 **Catppuccin Frappé**，同时保留 Tokyo Night 主题配置
- 通过 **Lspsaga** 优化定义预览、悬浮文档、代码操作等 LSP 交互
- 通过 **Blink.cmp** 提供补全与文档窗口，并为 Markdown / Git commit 启用 Emoji 补全
- 集成 **Yazi**、**Snacks picker** 与 **lazygit**，覆盖文件导航、搜索与 Git 操作
- 集成 **render-markdown.nvim** 与 **markdown-preview.nvim**，用于 Markdown 编辑与预览
- 通过 **image.nvim** 支持在 Kitty 终端中直接预览 Markdown 内嵌图片
- 启用 LazyVim extras：Copilot、Sidekick、clangd、JSON、Markdown、Python、TypeScript

## 📚 文档与仓库关联

本仓库与文档站点是一一对应的：

- [LazyVim 配置说明](https://longwaybai.github.io/docs/lazyvim/)：整体定位、适用人群与阅读入口
- [安装与环境准备](https://longwaybai.github.io/docs/lazyvim/installation)：完整安装流程、依赖说明与排错建议
- [快捷键速查](https://longwaybai.github.io/docs/lazyvim/keymaps)：常用按键与工作流入口
- [插件与扩展](https://longwaybai.github.io/docs/lazyvim/plugins)：主要插件选择与配置思路
- [LongwayBai 博客 / 文档站首页](https://longwaybai.github.io/)：相关工具链文章与其他开发配置

README 侧重仓库落地使用；更完整的解释、截图与扩展说明请以文档站为准。

## 📋 环境要求

- **Neovim**：`>= 0.11.2`
- **基础依赖**：`git`、`node`、`ripgrep`、`fd`
- **推荐工具**：`yazi`、`lazygit`、`stylua`
- **语言支持**：通过 `:Mason` 安装所需 LSP，同时准备对应语言运行时

```bash
nvim --version
git --version
node --version
rg --version
fd --version
```

## 🚀 安装

### 快速安装

```bash
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null || true
mv ~/.local/share/nvim ~/.local/share/nvim.bak 2>/dev/null || true
mv ~/.local/state/nvim ~/.local/state/nvim.bak 2>/dev/null || true
mv ~/.cache/nvim ~/.cache/nvim.bak 2>/dev/null || true

git clone https://github.com/LongwayBai/lazyvim-config.git ~/.config/nvim
nvim
```

首次启动时，LazyVim 会自动完成插件引导。随后可在 Neovim 中执行 `:Mason` 安装所需语言服务器。

### 更新

```bash
cd ~/.config/nvim
git pull
```

然后在 Neovim 中执行：

```vim
:Lazy update
```

## ⚡ 最小上手闭环

Leader 键为 **Space**。如果是第一次使用这套配置，建议先掌握下面几个操作：

| 快捷键 | 说明 |
| --- | --- |
| `jk` / `jj` | 退出插入模式 |
| `<C-s>` | 保存所有文件 |
| `<leader><space>` | 在当前工作目录查找文件 |
| `<leader>fy` | 打开 Yazi 文件管理器 |
| `<leader>sg` | 在当前目录搜索文本 |
| `gd` | 预览定义 |
| `K` | 查看悬浮文档 |
| `<leader>?` | 查看可用快捷键 |

更多按键请参考：[快捷键速查](https://longwaybai.github.io/docs/lazyvim/keymaps)。

## 🔌 配置重点

### 主题与界面

- `lua/plugins/theme.lua`：配置 Tokyo Night 与 Catppuccin，默认启用 `catppuccin-frappe`
- `lua/plugins/ui.lua`：调整 dashboard、lualine、图标与 better-escape 行为

### 编辑、搜索与文件管理

- `lua/plugins/code.lua`：配置 Snacks picker、Markdown 渲染/预览/Yazi 集成与图片预览
- `lua/plugins/editor.lua`：配置 Blink.cmp、文档窗口、按键与 Emoji 补全

### LSP 与工作流

- `lua/plugins/lsp.lua`：将 `gd`、`K`、`<leader>ca`、`<leader>cf` 等入口统一接入 Lspsaga / LSP
- `lua/config/keymaps.lua`：补充保存、终端、lazygit、窗口缩放等通用操作
- `lua/config/options.lua`：保留 4 空格缩进、关闭 swapfile、关闭自动格式化并设置 UTF-8

### 已启用的 LazyVim extras

```lua
lazyvim.plugins.extras.ai.copilot
lazyvim.plugins.extras.ai.sidekick
lazyvim.plugins.extras.lang.clangd
lazyvim.plugins.extras.lang.json
lazyvim.plugins.extras.lang.markdown
lazyvim.plugins.extras.lang.python
lazyvim.plugins.extras.lang.typescript
```

## 🧩 目录结构

```text
lazyvim-config/
├── init.lua
├── lazyvim.json
├── stylua.toml
├── lua/
│   ├── config/
│   │   ├── autocmds.lua
│   │   ├── keymaps.lua
│   │   ├── lazy.lua
│   │   └── options.lua
│   └── plugins/
│       ├── ai.lua
│       ├── code.lua
│       ├── editor.lua
│       ├── lsp.lua
│       ├── theme.lua
│       └── ui.lua
├── README.md
├── README_EN.md
└── LICENSE
```

## 🛠️ 故障排查

### 插件与整体健康检查

```vim
:Lazy health
:checkhealth
```

### LSP 未正常工作

```vim
:Mason
:LspInfo
:LspLog
```

### 插件更新后状态异常

```bash
rm -rf ~/.local/state/nvim
rm -rf ~/.local/share/nvim
```

更完整的排错说明请参考 [安装与环境准备](https://longwaybai.github.io/docs/lazyvim/installation)。

## 🤝 贡献

欢迎提交 issue 或 pull request。若修改了面向用户的行为、快捷键或安装方式，请同步更新本仓库 README 与配套文档站点，保持仓库与博客内容一致。

## 📜 许可证

详见 [LICENSE](LICENSE)。
