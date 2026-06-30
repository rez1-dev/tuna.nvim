-- lua/tuna/init.lua
local config = require("tuna.config")
local commands = require("tuna.commands")
local receive = require("tuna.receive")

local M = {}

local function command_complete(arg_lead)
    local subcommands = commands.get_complete_list()
    local matches = {}

    for _, subcmd in ipairs(subcommands) do
        if arg_lead == "" or subcmd:sub(1, #arg_lead) == arg_lead then
            table.insert(matches, subcmd)
        end
    end

    return matches
end

function M.setup(user_opts)
    config.setup(user_opts)

    vim.api.nvim_create_user_command("Tuna", function(opts)
        local args = opts.fargs
        if #args == 0 then
            vim.notify("Tuna: at least one argument required", vim.log.levels.INFO)
            return
        end

        commands.execute(args)
    end, {
        nargs = "*",
        desc = "Tuna",
        complete = command_complete,
    })
end

---lualine component: shows the receive listener's state, or nothing when idle.
function M.lualine_component()
    return receive.status()
end

return M
