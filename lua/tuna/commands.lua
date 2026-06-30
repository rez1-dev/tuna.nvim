-- lua/tuna/commands.lua
local M = {}

local config = require("tuna.config")
local receive = require("tuna.receive")
local runner = require("tuna.runner")
local testcases = require("tuna.testcases")

---Start receiving in `mode`, honouring the current buffer's configuration.
---@param mode tuna.ReceiveMode
local function start_receiving(mode)
    local bufnr = vim.api.nvim_get_current_buf()
    local cfg = config.get_buffer_config(bufnr)
    local err = receive.start_receiving(mode, cfg.companion_port, true, cfg.receive_print_message, bufnr, cfg)
    if err then
        vim.notify("Tuna: " .. err, vim.log.levels.ERROR)
    end
end

M.subcommands = {
    download_problem = function()
        start_receiving("problem")
    end,
    download_contest = function()
        start_receiving("contest")
    end,
    receive = function()
        start_receiving("persistently")
    end,
    receive_testcases = function()
        start_receiving("testcases")
    end,
    stop_receive = function()
        receive.stop_receiving()
        vim.notify("Tuna: stopped receiving.", vim.log.levels.INFO)
    end,
    receive_status = function()
        receive.show_status()
    end,
    test = function()
        runner.new():run()
    end,
    add_testcase = function()
        local name = vim.fn.input("Testcase name: ", "sample")
        if name == "" then
            return
        end

        local ok, err = testcases.add(vim.fn.getcwd(), name)
        if ok then
            vim.notify("Tuna: created testcase " .. name, vim.log.levels.INFO)
        else
            vim.notify("Tuna: " .. tostring(err), vim.log.levels.ERROR)
        end
    end,
}

function M.execute(args)
    local subcmd_name = args[1]
    local subcmd_fn = M.subcommands[subcmd_name]

    if subcmd_fn then
        subcmd_fn(unpack(args, 2))
    else
        vim.notify("Tuna: unknown subcommand '" .. tostring(subcmd_name) .. "'", vim.log.levels.ERROR)
    end
end

function M.get_complete_list()
    local keys = {}
    for k, _ in pairs(M.subcommands) do
        table.insert(keys, k)
    end

    table.sort(keys)
    return keys
end

return M
