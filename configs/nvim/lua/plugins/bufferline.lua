return {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = {"nvim-tree/nvim-web-devicons"},
    keys = {
        { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer"},
        { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer"},
        { "[b>", "<cmd>BufferLineCyclePrev<cr>", desc = "Prev Buffer"},
        { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer"},
        { "<leader>bd", "<cmd>bdelete!<cr>", desc = "Delete Buffer"},
    },
    opts = {
        options = {
            diagnostics = "nvim_lsp",
            always_show_bufferline = true,
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
        },
    },
}
