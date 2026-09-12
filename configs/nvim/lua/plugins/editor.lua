return {
    {
        "saghen/blink.cmp",
        opts = {
            completion = {
                trigger = {
                    show_on_keyword = true
                },
                keyword = {
                    range = 'full'
                },
                list = {
                    selection = {
                        preselect = false,
                    },
                },
                menu = {
                    auto_show = true,
                    border = "rounded",
                    draw = {
                        -- looks like nvim-cmp menu
                        -- columns = { { "label", "label_description", gap = 1}, {"kind_icon", "kind" } }
                    }
                },
                documentation = {
                    window = {
                        border = "rounded",
                    },
                },
                ghost_text = {
                    show_with_selection = false
                },
            },
            keymap = {
                preset = "none",
                ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
                ['<C-e>'] = { 'hide' },
                ['<CR>'] = { 'select_and_accept', 'fallback' },

                ['<Up>'] = { 'select_prev', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<C-p>'] = { 'select_prev', 'fallback' },
                ['<C-n>'] = { 'select_next', 'fallback' },

                ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
                ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },

                ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
                ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },

                ['<C-k>'] = { 'show_signature', 'hide_signature', 'fallback' },
            },
        },
    },
    {
        "saghen/blink.cmp",
        dependencies = {
            "moyiz/blink-emoji.nvim",
        },
        opts = {
            sources = {
                default = {
                    "emoji",
                },
                providers = {
                    emoji = {
                        module = "blink-emoji",
                        name = "Emoji",
                        score_offset = 15, -- Tune by preference
                        opts = {
                            insert = true, -- Insert emoji (default) or complete its name
                            ---@type string|table|fun():table
                            trigger = function()
                                return { ":" }
                            end,
                        },
                        should_show_items = function()
                            return vim.tbl_contains(
                            -- Enable emoji completion only for git commits and markdown.
                            -- By default, enabled for all file-types.
                                { "gitcommit", "markdown" },
                                vim.o.filetype
                            )
                        end,
                    }
                }
            }
        }
    }
}
