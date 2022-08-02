local loaded, hydra = pcall(require, "hydra")
if not loaded then
    return
end

local loaded, gitsigns = pcall(require, "gitsigns")
if not loaded then
    return
end

-- Side Scroll
hydra({
    name = "Side scroll",
    config = {
        {
            position = "bottom-right",
            border = "rounded",
        },
    },
    mode = "n",
    body = "z",
    heads = {
        { "h", "5zh" },
        { "l", "5zl", { desc = "←/→" } },
        { "H", "zH" },
        { "L", "zL", { desc = "half screen ←/→" } },
    },
})

local hint = [[
 _J_: next hunk   _s_: stage hunk        _d_: show deleted   _b_: blame line
 _K_: prev hunk   _u_: undo stage hunk   _p_: preview hunk   _B_: blame show full
 ^ ^              _S_: stage buffer      ^ ^                 _/_: show base file
 ^
 ^ ^              _<Enter>_: Neogit              _q_: exit
]]

hydra({
    hint = hint,
    config = {
        color = "pink",
        invoke_on_body = true,
        hint = {
            position = "bottom-right",
            border = "rounded",
        },
        on_enter = function()
            vim.bo.modifiable = false
            gitsigns.toggle_signs(true)
            gitsigns.toggle_linehl(true)
        end,
        on_exit = function()
            gitsigns.toggle_signs(false)
            gitsigns.toggle_linehl(false)
            gitsigns.toggle_deleted(false)
        end,
    },
    mode = { "n", "x" },
    body = "<leader>G",
    heads = {
        {
            "J",
            function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(function()
                    gitsigns.next_hunk()
                end)
                return "<Ignore>"
            end,
            { expr = true },
        },
        {
            "K",
            function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(function()
                    gitsigns.prev_hunk()
                end)
                return "<Ignore>"
            end,
            { expr = true },
        },
        { "s", ":Gitsigns stage_hunk<CR>", { silent = true } },
        { "u", gitsigns.undo_stage_hunk },
        { "S", gitsigns.stage_buffer },
        { "p", gitsigns.preview_hunk },
        { "d", gitsigns.toggle_deleted, { nowait = true } },
        { "b", gitsigns.blame_line },
        {
            "B",
            function()
                gitsigns.blame_line({ full = true })
            end,
        },
        { "/", gitsigns.show, { exit = true } }, -- show the base of the file
        { "<Enter>", "<cmd>Neogit<CR>", { exit = true } },
        { "q", nil, { exit = true, nowait = true } },
    },
})

-- Hydra to repeat expanding windows
hydra({
    name = "Window Sizing",
    mode = "n",
    body = "<C-w>",
    config = {
        {
            position = "bottom-right",
            border = "rounded",
        },
    },
    heads = {
        { "<", "2<C-w><" },
        { ">", "2<C-w>>", { desc = "←/→" } },
        { "+", "2<C-w>+" },
        { "-", "2<C-w>-", { desc = "↑/↓" } },
    },
})
