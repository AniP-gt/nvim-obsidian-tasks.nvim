local M = {}

local function default_options()
  return {}
end

local function register_commands()
  if vim.fn.exists(":TasksComplete") == 2 then
    return
  end

  local complete = require("nvim-tasks.complete")
  vim.api.nvim_create_user_command("TasksComplete", function(opts)
    if not complete.can_operate() then
      return
    end

    local start_line = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_line = opts.line2 or start_line
    local changed = complete.complete_range(start_line - 1, end_line)

    if not changed then
      vim.notify("nvim-tasks: No convertible tasks found", vim.log.levels.INFO)
    end
  end, {
    range = true,
  })
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", default_options(), opts or {})
  register_commands()
end

return M
