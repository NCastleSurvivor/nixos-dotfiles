return {
    {
        "snacks.nvim",
        opts = {
            dashboard = {
                sections = {
                    { section = "header" },
                    { section = "keys", gap = 1, padding = 1 },
                    { icon = " ", title = "Recent Files", section = "recent_files", indent = 1, padding = { 1, 1 } },
                    { icon = " ", title = "Projects", section = "projects", indent = 1, padding = 1 },
                    { section = "startup" },
                    -- {
                    --     section = "terminal",
                    --     cmd = "pokemon-colorscripts -r --no-title; sleep .1",
                    --     random = 10,
                    --     pane = 2,
                    --     indent = 4,
                    --     height = 30,
                    -- },
                },
            },
        },
    },
    {
        "nvim-mini/mini.icons",
        opts = {
            extension = {
                h = { glyph = '', hl = 'MiniIconsPurple' },
            }
        }
    },
    {
        "nvim-lualine/lualine.nvim",
        opts = function(_, opts)
            local LazyVim = require("lazyvim.util")
            opts.sections.lualine_c[4] = {
                LazyVim.lualine.pretty_path({
                    length = 0
                })
            }
        end,
    },
    {
        "max397574/better-escape.nvim",
        config = function()
            require("better_escape").setup {
                default_mappings = false,
                mappings = {
                    i = {
                        j = {
                            k = "<Esc>",
                            j = "<Esc>",
                        },
                    },
                    t = {
                        j = {
                            i = "<C-\\><C-n>",
                        }
                    }
                }
            }
        end,
    }
}
