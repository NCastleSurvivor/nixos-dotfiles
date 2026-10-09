return {
    -- fix lsp keymaps
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ["*"] = {
                    keys = {
                        { "gd",         "<cmd>Lspsaga peek_definition<CR>", desc = "[G]oto [D]efinition" },
                        { "K",          "<cmd>Lspsaga hover_doc<CR>",       desc = "Hover Docmentstion" },
                        { "<leader>ca", "<cmd>Lspsaga code_action<CR>",     desc = "[C]ode [A]ction" },
                        {
                            "<leader>cf",
                            function()
                                vim.lsp.buf.format({ async = true })
                            end,
                            desc = "[C]ode [F]ormat",
                        }
                    }
                },
                clangd = {
                    keys = {
                        { "<leader>a", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
                    },
                },
            },
            diagnostics = {
                underline = false,
                virtual_text = false,
            },
            inlay_hints = {
                enabled = false,
            },
        },
    },
    {
        "nvimdev/lspsaga.nvim",
        dependencies = {
            "neovim/nvim-lspconfig"
        },
        opts = {
            definition = {
                keys = {
                    edit = { "<CR>" },
                    quit = { "q", "Q", "<ESC>" },
                    vsplit = { "sj" },
                    split = { "sl" },
                },
            },
            finder = {
                max_height = 0.6,
                keys = {
                    toggle_or_open = { "<CR>" },
                    quit = { "q", "Q", "<ESC>" },
                    vsplit = { "sj" },
                    split = { "sl" },
                },
            },
            rename = {
                keys = {
                    quit = { "<ESC>" },
                },
            },
            diagnostic = {
                diagnostic_only_current = true,
            },
            symbol_in_winbar = {
                enable = true,
            },
            lightbulb = {
                virtual_text = false
            },
            scroll_preview = {
                scroll_down = "<C-d>",
                scroll_up = "<C-u>",
            }
        }
    },
}
