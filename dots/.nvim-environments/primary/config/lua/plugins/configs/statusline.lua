local present, lualine = pcall(require, "lualine")
if not present then
    return
end

-- Thanks to rockyzhang24 (github.com/rockyzhang24)

local function simplifiedMode(str)
    return "  " .. (str == "V-LINE" and "VL" or (str == "V-BLOCK" and "VB" or str:sub(1, 1)))
end

-- For location, show total lines
local function customLocation(str)
    return string.gsub(str, "%w+", "%1" .. "/%%L", 1)
end

-- For progress, add a fancy icon
local function customProgress(str)
    return " " .. str
end

-- For filename, show the filename and the filesize
local function fileNameAndSize(str)
    -- For doc, only show filename
    if string.find(str, ".*/doc/.*%.txt") then
        str = vim.fn.expand("%:t")
    end
    local size = require("lualine.components.filesize")()
    return size == "" and str or str .. " [" .. size .. "]"
end

local function show_macro_recording()
    local recording_register = vim.fn.reg_recording()
    if recording_register == "" then
        return ""
    else
        return "Recording @" .. recording_register
    end
end

lualine.setup({
    options = {
        icons_enabled = true,
        theme = "auto",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = {},
        always_divide_middle = true,
        globalstatus = true,
    },
    winbar = {
        lualine_a = {
            {
                "filename",
                path = 1,
            },
        },
        lualine_b = {
            {
                "macro-recording",
                fmt = show_macro_recording,
            },
        },
        lualine_c = {},
        lualine_x = {
            "encoding",
            "fileformat",
            "filetype",
        },
        lualine_y = {
            {
                "location",
                fmt = customLocation,
            },
        },
        lualine_z = {
            {
                "progress",
                fmt = customProgress,
            },
        },
    },
    inactive_winbar = {
        lualine_a = { { "filename", path = 1 } },
        lualine_b = {},
        lualine_c = {},
        lualine_x = {
            "filetype",
        },
        lualine_y = {},
        lualine_z = {},
    },
    sections = {
        lualine_a = {
            {
                "mode",
                fmt = simplifiedMode,
            },
        },
        lualine_b = {
            {
                "branch",
                icon = "",
            },
            {
                "diff",
                symbols = { added = " ", modified = " ", removed = " " },
            },
            {
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = { error = " ", warn = " ", info = " ", hint = " " },
            },
            {
                "macro-recording",
                fmt = show_macro_recording,
            },
        },
        lualine_c = {
            {
                "filename",
                path = 3,
                symbols = {
                    modified = "[+]",
                    readonly = "[]",
                    unnamed = "[No Name]",
                },
                fmt = fileNameAndSize,
            },
        },

        -- Right
        lualine_x = {
            {
                function()
                    local lazy_stats = require("lazy").stats()
                    local plugin_count = lazy_stats.count
                    local loaded_plugins = lazy_stats.loaded
                    return "" .. loaded_plugins .. "/" .. plugin_count .. " "
                end,
            },
            {
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
            },
        },
        lualine_y = {
            {
                "buffers",
                mode = 2,
            },
        },
        lualine_z = {
            { "tabs" },
        },
    },
    inactive_sections = {},
    tabline = {},
    extensions = {
        "aerial",
        "fugitive",
        "nvim-tree",
        "neo-tree",
        "quickfix",
        "toggleterm",
    },
})

local macro_refresh_places = { "statusline", "winbar" }
vim.api.nvim_create_autocmd("RecordingEnter", {
    callback = function()
        lualine.refresh({
            place = macro_refresh_places,
        })
    end,
})

vim.api.nvim_create_autocmd("RecordingLeave", {
    callback = function()
        local timer = vim.loop.new_timer()
        timer:start(
            30,
            0,
            vim.schedule_wrap(function()
                lualine.refresh({
                    place = macro_refresh_places,
                })
            end)
        )
    end,
})
