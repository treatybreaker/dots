return {
    {
        "luukvbaal/statuscol.nvim",
        opts = function()
            local builtin = require("statuscol.builtin")
            local last_sign_def_len = 0

            -- HACK: Ensure all signs get the correct CursorLineSign set to their "culhl" value
            -- This, in effect, extends the CursorLine background highlight into the signcolumn
            vim.uv.new_timer():start(
                100,
                100,
                vim.schedule_wrap(function()
                    -- Make all signs support "CusorLine.*" highlights
                    local signs_defined = vim.fn.sign_getdefined() or {}
                    if #signs_defined == last_sign_def_len or #signs_defined == 0 then
                        return
                    end
                    last_sign_def_len = #signs_defined
                    local bg = vim.api.nvim_get_hl(0, { name = "SignColumn", link = false }).bg
                    local cl_bg = vim.api.nvim_get_hl(0, { name = "CursorLineSign", link = false }).bg
                    for _, sign in ipairs(signs_defined) do
                        local name = sign.texthl
                        if name and not sign.culhl then
                            local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
                            vim.api.nvim_set_hl(0, name, vim.tbl_deep_extend("force", hl, { bg = bg, force = true }))
                            local cul_hl_name = name .. "Cul"
                            vim.api.nvim_set_hl(
                                0,
                                cul_hl_name,
                                vim.tbl_deep_extend("force", hl, { bg = cl_bg, nocombine = true, force = true })
                            )
                            sign.culhl = cul_hl_name
                            vim.fn.sign_define(sign.name, sign)
                        end
                    end
                end)
            )

            return {
                setopt = true,
                relculright = false,
                segments = {
                    { text = { "%s" }, click = "v:lua.ScSa" },
                    { text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
                    { text = { " ", builtin.foldfunc, " " }, click = "v:lua.ScFa" },
                },
            }
        end,
    },
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            current_line_blame = true,
            current_line_blame_opts = {
                delay = 0,
            },
            -- HACK: This allows the gitsigns to correctly use the culhl for their bg
            _extmark_signs = false,
        },
    },
}
