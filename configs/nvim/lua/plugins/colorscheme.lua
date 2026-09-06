return {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
        style = "moon",
        transparent = false,
        terminal_colors = true,
        styles = {
            comments = { italic = true },
            keywords = { italic = true },
            sidebars = "dark",
            floats = "dark",
        },
    },
}
