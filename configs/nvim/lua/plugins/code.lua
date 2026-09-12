return {
    -- disable todo-comments
    { "LongwayBai/Mark--KarKat" },
    { "gcmt/wildfire.vim" },
    {
        "nvim-treesitter/nvim-treesitter",
        opts = {
            indent = {
                enable = false,
            },
            highlight = {
                enable = true
            }
        },
    },
    {
        "snacks.nvim",
        opts = {
            picker = {
                prompt = "🔍 ",
                formatters = {
                    file = {
                        truncate = 80,
                    }
                }
            }
        },
        keys = {
            { "<leader><space>", LazyVim.pick("files", { root = false }),           desc = "Find Files (cwd)" },
            { "<leader>sD",      function() Snacks.picker.diagnostics() end,        desc = "Diagnostics" },
            { "<leader>sd",      function() Snacks.picker.diagnostics_buffer() end, desc = "Buffer Diagnostics" },
            { "<leader>sG",      LazyVim.pick("live_grep"),                         desc = "Grep (Root Dir)" },
            { "<leader>sg",      LazyVim.pick("live_grep", { root = false }),       desc = "Grep (cwd)" },
            { "<leader>sW",      LazyVim.pick("grep_word"),                         desc = "Visual selection or word (Root Dir)", mode = { "n", "x" } },
            { "<leader>sw",      LazyVim.pick("grep_word", { root = false }),       desc = "Visual selection or word (cwd)",      mode = { "n", "x" } },
        }
    },
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            code = {
                enabled = true,
                sign = true,
                style = "full",
                border = "thin",
            },
            heading = {
                sign = true,
                icons = { " 󰼏 ", " 󰎨 ", " 󰼑 ", " 󰎲 ", " 󰼓 ", " 󰎴 " },
                -- border = true,
                -- render_modes = true,          -- keep rendering while inserting
            },
            pipe_table = {
                alignment_indicator = "─",
                border = { "╭", "┬", "╮", "├", "┼", "┤", "╰", "┴", "╯", "│", "─" },
            },
            checkbox = {
                enabled = true,
            },
        },
    },
    {
        "3rd/image.nvim",
        build = false,
        enabled = function()
            local has_magick = vim.fn.executable("magick") == 1 or vim.fn.executable("convert") == 1
            local is_kitty = vim.env.KITTY_WINDOW_ID ~= nil or vim.env.TERM == "xterm-kitty"
            return has_magick and is_kitty
        end,
        opts = {
            backend = "kitty",
            processor = "magick_cli",
            max_height_window_percentage = 50,
            window_overlap_clear_enabled = false,
            editor_only_render_when_focused = false,
            tmux_show_only_in_active_window = false,
            integrations = {
                markdown = {
                    enabled = true,
                    clear_in_insert_mode = false,
                    download_remote_images = true,
                    floating_windows = false,
                    filetypes = { "markdown" },
                    only_render_image_at_cursor = false,
                },
            },
        },
    },
    {
        "iamcco/markdown-preview.nvim",
        config = function()
            vim.cmd([[do FileType]])
            vim.g.mkdp_open_to_the_world = 1
            vim.g.mkdp_open_ip = ''
            vim.g.mkdp_port = '7100'
            vim.g.mkdp_browser = 'google-chrome'
            vim.g.mkdp_echo_preview_url = 1
            vim.g.mkdp_auto_start = 1
            vim.g.mkdp_combine_preview = 1
            vim.g.mkdp_combine_preview_auto_refresh = 1
        end,
    },
    {

        "mikavilpas/yazi.nvim",
        -- "🦆"
        version = "*", -- use the latest stable version
        event = "VeryLazy",
        dependencies = {
            { "nvim-lua/plenary.nvim", lazy = true },
        },
        keys = {
            -- 👇 in this section, choose your own keymappings!
            {
                "<leader>fy",
                mode = { "n", "v" },
                "<cmd>Yazi<cr>",
                desc = "Open yazi at the current file"
            },
            {
                -- Open in the current working directory
                "<leader>fw",
                "<cmd>Yazi cwd<cr>",
                desc = "Open the file manager in nvim's working directory"
            },
            {
                "<c-up>",
                "<cmd>Yazi toggle<cr>",
                desc = "Resume the last yazi session",
            },
        },
        ---@type YaziConfig | {}
        opts = {
            -- if you want to open yazi instead of netrw, see below for more info
            open_for_directories = false,
            keymaps = {
                show_help = "<f1>",
            },
        },
        -- 👇 if you use `open_for_directories=true`, this is recommended
        init = function()
            -- mark netrw as loaded so it's not loaded at all.
            --
            -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
            vim.g.loaded_netrwPlugin = 1
        end,
    }
}
