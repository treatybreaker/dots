return {
    {
        "NeogitOrg/neogit",
        cmd = { "Neogit" },
        dev = true,
        keys = {
            { "<leader>g", desc = "> Git" },
            { "<leader>gg", "<cmd>Neogit<CR>", desc = "Neogit: Open" },
        },
        opts = function()
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*Neogit*",
                callback = function()
                    vim.opt_local.list = false
                end,
            })

            return {
                disable_insert_on_commit = "auto",
                disable_commit_confirmation = true,
                disable_builtin_notifications = true,
                integrations = {
                    diffview = true,
                    telescope = true,
                },
            }
        end,
        dependencies = {
            {
                keys = {
                    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Diff View: Open" },
                    { "<leader>gh", "<cmd>DiffviewFileHistory<CR>", desc = "Diff View: File History" },
                },
                "sindrets/diffview.nvim",
                cmd = {
                    "DiffviewToggleFiles",
                    "DiffviewFileHistory",
                    "DiffviewFocusFiles",
                    "DiffviewRefresh",
                    "DiffviewClose",
                    "DiffviewOpen",
                    "DiffviewLog",
                },
                opts = {
                    enhanced_diff_hl = true,
                },
            },
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim",
        },
    },
    {
        "tpope/vim-fugitive",
        -- event = "VeryLazy",
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        keys = {
            { "]g", "<cmd>Gitsigns next_hunk<CR><CR>", desc = "Gitsigns: Next Hunk" },
            { "[g", "<cmd>Gitsigns prev_hunk<CR><CR>", desc = "Gitsigns: Prev Hunk" },
            { "<leader>gs", "<cmd>Gitsigns stage_hunk<CR>", desc = "Gitsigns: Stage Hunk" },
            { "<leader>gr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Gitsigns: Reset Hunk" },
            { "<leader>gu", "<cmd>Gitsigns undo_stage_hunk<CR>", desc = "Gitsigns: Unstage Hunk" },
        },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
        },
    },
}
