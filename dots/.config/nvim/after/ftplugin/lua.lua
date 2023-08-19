vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true

vim.keymap.set("n", "<leader>fr", ":luafile %<CR>", {
    buffer = true,
    silent = true
})
