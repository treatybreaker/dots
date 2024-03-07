local M = {}
M.setup = function()
    -- If invoked as a preview callback, performs 'inccommand' preview by
    -- highlighting trailing whitespace in the current buffer.
    local function trim_space_preview(opts, preview_ns, preview_buf)
        vim.cmd("highlight clear Whitespace")
        local line1 = opts.line1
        local line2 = opts.line2
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)
        local preview_buf_line = 0

        for i, line in ipairs(lines) do
            local start_idx, end_idx = string.find(line, "%s+$")

            if start_idx and end_idx then
                -- Highlight the match
                vim.api.nvim_buf_add_highlight(buf, preview_ns, "Substitute", line1 + i - 2, start_idx - 1, end_idx)

                -- Add lines and set highlights in the preview buffer
                -- if inccommand=split
                if preview_buf then
                    local prefix = string.format("|%d| ", line1 + i - 1)

                    vim.api.nvim_buf_set_lines(
                        preview_buf,
                        preview_buf_line,
                        preview_buf_line,
                        false,
                        { prefix .. line }
                    )
                    vim.api.nvim_buf_add_highlight(
                        preview_buf,
                        preview_ns,
                        "Substitute",
                        preview_buf_line,
                        #prefix + start_idx - 1,
                        #prefix + end_idx
                    )
                    preview_buf_line = preview_buf_line + 1
                end
            end
        end

        -- Return the value of the preview type
        return 2
    end

    -- Trims all trailing whitespace in the current buffer.
    local function trim_space(opts)
        local line1 = opts.line1
        local line2 = opts.line2
        local buf = vim.api.nvim_get_current_buf()
        local lines = vim.api.nvim_buf_get_lines(buf, line1 - 1, line2, false)

        local new_lines = {}
        for i, line in ipairs(lines) do
            new_lines[i] = string.gsub(line, "%s+$", "")
        end
        vim.api.nvim_buf_set_lines(buf, line1 - 1, line2, false, new_lines)
    end

    -- Create the user command
    vim.api.nvim_create_user_command(
        "TrimTrailingWhitespace",
        trim_space,
        { nargs = "?", range = "%", addr = "lines", preview = trim_space_preview }
    )

    vim.api.nvim_create_user_command("DiffSaved", function()
        -- Thanks to sindrets: https://github.com/sindrets/dotfiles/blob/1990282dba25aaf49897f0fc70ebb50f424fc9c4/.config/nvim/lua/user/lib.lua#L175
        -- Minor alterations by me
        local buf_ft = vim.api.nvim_get_option_value("filetype", { scope = "local" })
        local buf_name = vim.api.nvim_buf_get_name(0)
        vim.cmd("tab split | diffthis")
        vim.cmd("aboveleft vnew | r # | normal! 1Gdd")
        vim.cmd.diffthis()
        local opts = {
            buftype = "nowrite",
            bufhidden = "wipe",
            swapfile = false,
            readonly = true,
            winbar = vim.opt.winbar:get(),
        }
        for option, value in pairs(opts) do
            vim.api.nvim_set_option_value(option, value, { scope = "local" })
        end
        if buf_name then
            pcall(vim.api.nvim_buf_set_name, 0, (vim.fn.fnamemodify(buf_name, ":t") or buf_name) .. " [OLD]")
        end
        if buf_ft then
            vim.opt_local.filetype = buf_ft
        end
        vim.cmd.wincmd("l")
    end, {})

    vim.api.nvim_create_user_command("SudoWrite", function(opts)
        opts.args = vim.trim(opts.args)
        local cmd = ":silent! w! !sudo tee " .. (#opts.args > 0 and opts.args or "%") .. " >/dev/null "
        vim.cmd(cmd)
        vim.cmd.edit({ bang = true, mods = { silent = true, confirm = false } })
        vim.bo.readonly = false
    end, {
        nargs = "*",
        desc = "Sudo Write"
    })
end

return M
