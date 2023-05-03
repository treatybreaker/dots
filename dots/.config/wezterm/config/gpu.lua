-- We have to provide a good gpu for wezterm to use gpu acceleration. We ideally want to use a vullkan front end, but if
-- we are unable to locate a card that supports Vulkan we fall back to OpenGL
local config = {}
local wezterm = require("wezterm")
local wlib = require("wlib")

local found_valid_gpu = false
wezterm.log_info(wlib.Table.dump(wezterm.gui.enumerate_gpus()))
for _, gpu in ipairs(wezterm.gui.enumerate_gpus()) do
    if gpu.backend == "Vulkan" then
        wezterm.log_info("Found Usable Vulkan GPU\n  Device Name -> " .. gpu.name .."\n  Device Type -> " .. gpu.device_type)
        config.webgpu_preferred_adapter = gpu
        config.front_end = "WebGpu"
        found_valid_gpu = true
        break
    end
end

if not found_valid_gpu then
    wezterm.log_warn("Unable to locate a Vulkan-supported GPU, falling back to OpenGL")
    config.front_end = "OpenGL"
end

return config
