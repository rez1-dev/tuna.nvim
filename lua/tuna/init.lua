-- lua/tuna/init.lua
local config = require("tuna.config")

local M = {}

-- Handle autocomplete logic
local function command_complete(arg_lead, cmd_line, cursos_pos)
    local subcommands = {
        "add_testcase",
        "edit_testcase",
        "delete_testcase",
        "run",
        "run_no_compile",
        "receive",
    }

    local matches = {}
    for _, subcmd in ipairs(subcommands) do
        if subcmd:sub(1, #arg_lead) == arg_lead then
            table.insert(matches, subcmd)
        end
    end

    return matches
end

function M.setup(user_opts)
    -- Parse and merge the configuration
    config.setup(user_opts)

    -- Create user command
    vim.api.nvim_create_user_command("Tuna", function(opts)
        -- opts.fargs contains the arguments passed to the command, e.g. {"run"}
        local args = opts.fargs
        if #args == 0 then
            vim.notify("Tuna: at least one argument required", vim.log.levels.ERROR)
            return
        end

        local subcommand = args[1]

        -- Need to route this to a commands.lua file
        vim.notify("Tuna: subcommand " .. subcommand, vim.log.levels.INFO)
    end, {
        nargs = "*", -- Accepts any number of arguments
        desc = "Tuna",
        complete = command_complete, -- Attach the complletion function
    })

    -- Setup highlight groups
end

return M
