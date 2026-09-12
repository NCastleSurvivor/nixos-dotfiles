return {
    {
        "folke/tokyonight.nvim",
        style = "moon",
        opts = {
            transparent = true,
            styles = {
                sidebars = "transparent",
                floats = "transparent",
            },
        },
    },
    {
        "catppuccin/nvim",
        opts = {
            background = {
                light = "latte",
                drak = "frappe",
            },
            transparent_background = true,
            float = {
                transparent = true,
                solid = false
            }
        },
    },
    {
        "LazyVim/LazyVim",
        opts = {
            -- colorscheme = "tokyonight-storm",
            colorscheme = "catppuccin-frappe",
        },
    },
}
