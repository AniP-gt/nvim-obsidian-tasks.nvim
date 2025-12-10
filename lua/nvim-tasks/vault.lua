local M = {}

local uv = vim.loop

local function path_dir(path)
  return vim.fs.dirname(path)
end

local function file_exists(path)
  local stat = uv.fs_stat(path)
  return stat ~= nil
end

local function find_obsidian_root(start_path)
  local search_path = start_path or vim.fn.expand("%:p:h")
  local found = vim.fs.find(".obsidian", { path = search_path, upward = true, type = "directory" })[1]
  if not found then
    return nil
  end
  return path_dir(found)
end

function M.current_context()
  local buf_path = vim.api.nvim_buf_get_name(0)
  local start = buf_path ~= "" and vim.fn.fnamemodify(buf_path, ":p:h") or vim.loop.cwd()
  local root = find_obsidian_root(start)
  return {
    has_vault = root ~= nil,
    root_path = root,
    file_path = buf_path,
  }
end

function M.in_vault()
  return M.current_context().has_vault
end

return M
