return {
    "folke/sidekick.nvim",
    opts = {
        cli = {
            win = {
                layout = "float", ---@type "float" | "bottom" | "right" | "left" | "top"
            }
        },
        tools = {
            codex = { cmd = { "codex" } },
        }
    }
}
