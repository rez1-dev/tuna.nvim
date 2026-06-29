local utils = require("tuna.utils")

local M = {}

local function find_testcase_dirs(root, source_basename)
    local dirs = {}
    local scan = function(path)
        local ok, entries = pcall(vim.fn.readdir, path)
        if not ok then
            return
        end

        for _, entry in ipairs(entries) do
            if entry ~= "." and entry ~= ".." then
                local full_path = path .. "/" .. entry
                local stat = vim.uv.fs_stat(full_path)
                if stat and stat.type == "directory" then
                    table.insert(dirs, full_path)
                end
            end
        end
    end

    if utils.directory_exists(root .. "/tests") then
        scan(root .. "/tests")
    end

    if source_basename and source_basename ~= "" then
        local base_dir = root
        local input_path = base_dir .. "/" .. source_basename .. "_input0.txt"
        local output_path = base_dir .. "/" .. source_basename .. "_output0.txt"
        local input_exists = utils.file_exists(input_path)
        local output_exists = utils.file_exists(output_path)

        if input_exists or output_exists then
            table.insert(dirs, base_dir)
        end
    end

    return dirs
end

function M.add(project_root, name)
    project_root = project_root or vim.fn.getcwd()
    name = name or "sample"

    local testcase_dir = project_root .. "/tests/" .. name
    local ok = utils.ensure_directory(testcase_dir)
    if not ok then
        return false, "failed to create testcase directory"
    end

    local input_path = testcase_dir .. "/input.txt"
    local output_path = testcase_dir .. "/output.txt"

    if not utils.file_exists(input_path) then
        local fh = io.open(input_path, "w")
        if fh then
            fh:write("")
            fh:close()
        end
    end

    if not utils.file_exists(output_path) then
        local fh = io.open(output_path, "w")
        if fh then
            fh:write("")
            fh:close()
        end
    end

    return true, testcase_dir
end

function M.load_first(project_root, source_basename)
    project_root = project_root or vim.fn.getcwd()
    local dirs = find_testcase_dirs(project_root, source_basename)

    table.sort(dirs)

    for _, dir in ipairs(dirs) do
        local candidates = {
            { dir .. "/input.txt", dir .. "/output.txt" },
            { dir .. "/" .. (source_basename or "") .. "_input0.txt", dir .. "/" .. (source_basename or "") .. "_output0.txt" },
        }

        for _, pair in ipairs(candidates) do
            local input_path = pair[1]
            local output_path = pair[2]
            if utils.file_exists(input_path) or utils.file_exists(output_path) then
                local input_file = io.open(input_path, "r")
                local output_file = io.open(output_path, "r")
                local input = input_file and input_file:read("*a") or ""
                local output = output_file and output_file:read("*a") or ""

                if input_file then
                    input_file:close()
                end
                if output_file then
                    output_file:close()
                end

                return {
                    name = vim.fn.fnamemodify(dir, ":t"),
                    input = input,
                    output = output,
                    dir = dir,
                }
            end
        end
    end

    return nil
end

return M
