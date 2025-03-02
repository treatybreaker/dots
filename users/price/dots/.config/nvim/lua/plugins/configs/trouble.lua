return {
    {
        "folke/todo-comments.nvim",
        event = "VeryLazy",
        cmd = {
            "TodoTrouble",
            "TodoTelescope",
            "TodoQuickFix",
            "TodoLocList",
        },
        dependencies = { "nvim-lua/plenary.nvim" },
        opts = {
            keywords = {
                SECURITY = {
                    icon = "󰒃",
                    color = "warning",
                    alt = { "SEC", "SECURITY" },
                },
            },
        },
    },
    {
        "folke/trouble.nvim",
        keys = {
            { "<leader>x", desc = "> Trouble" },
            { "<leader>lr", "<cmd>Trouble lsp_references toggle win.position=right<cr>", desc = "LSP: References" },
            {
                "<leader>li",
                "<cmd>Trouble lsp_implementations toggle win.position=right<cr>",
                desc = "LSP: Implementation",
            },
            { "<leader>ld", "<cmd>Trouble lsp_definitions toggle win.position=right<CR>", desc = "LSP: Definitions" },
            {
                "<leader>lD",
                "<cmd>Trouble lsp_type_definitions toggle win.position=right<CR>",
                desc = "LSP: Type Definitions",
            },
            {
                "<leader>xx",
                function()
                    local trouble = require("trouble")
                    if trouble.is_open() then
                        ---@diagnostic disable-next-line: missing-parameter
                        trouble.focus()
                    end
                end,
                desc = "Trouble: Focus Trouble",
            },
            {
                "<leader>xd",
                "<cmd>Trouble diagnostics toggle win.position=right<cr>",
                desc = "Trouble: Document Diagnostics",
            },
            { "<leader>xl", "<cmd>Trouble loclist toggle win.position=right<cr>", desc = "Trouble: Loclist" },
            { "<leader>xq", "<cmd>Trouble qflist toggle win.position=right<cr>", desc = "Trouble: Quickfix" },
            { "<leader>xt", "<cmd>Trouble todo toggle win.position=right<cr>", desc = "Trouble: Todo Items" },
            {
                "<leader>xo",
                "<cmd>Trouble symbols toggle<cr>",
                desc = "Trouble: Symbols",
            },
        },
        event = { "QuickFixCmdPre" },
        dependencies = {
            "nvim-tree/nvim-web-devicons",
            "todo-comments.nvim",
        },
        opts = {
            focus = true,
            auto_close = true,
            auto_jump = true,
            win = {
                position = "right",
                type = "split",
            },
            keys = {
                ["<tab>"] = "fold_toggle",
            },
        },
        cmd = {
            "Trouble",
        },
    },
}
