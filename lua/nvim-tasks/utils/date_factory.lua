local utils = require("nvim-tasks.utils")
local meta = require("nvim-tasks.meta")

local DATE_FORMAT = "%Y-%m-%d"

local function trim(value)
  if not value then
    return ""
  end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function ensure_date(value)
  local normalized = trim(value)
  if normalized == "" then
    return os.date(DATE_FORMAT)
  end
  return normalized
end

local function apply_field(bufnr, start_line, end_line, field, date_value)
  local start_idx = start_line - 1
  local end_idx = end_line
  return utils.update_range(bufnr, start_idx, end_idx, function(line)
    return meta.set_date_field(line, field, date_value)
  end)
end

local function register(command_name, field, config)
  config = config or {}
  if vim.fn.exists(":" .. command_name) == 2 then
    return
  end

  vim.api.nvim_create_user_command(command_name, function(opts)
    if not utils.can_operate() then
      return
    end

    local date_value = ensure_date(opts.args)
    local start_line = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_line = opts.line2 or start_line
    local changed = apply_field(vim.api.nvim_get_current_buf(), start_line, end_line, field, date_value)

    if not changed then
      vim.notify(config.fail_message or "nvim-tasks: No matching tasks found", vim.log.levels.INFO)
    end
  end, {
    range = true,
    nargs = "?",
  })
end

local M = {}

function M.register(command_name, field, config)
  register(command_name, field, config)
end

return M
