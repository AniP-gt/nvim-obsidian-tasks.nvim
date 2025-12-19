local utils = require("nvim-tasks.utils")
local priority = require("nvim-tasks.utils.priority")

local M = {}

local function apply_priority(bufnr, start_idx, end_idx, level)
  return utils.update_range(bufnr, start_idx, end_idx, function(line)
    return priority.set_priority(line, level)
  end)
end

local function create_command()
  if vim.fn.exists(":TasksSetPriority") == 2 then
    return
  end

  vim.api.nvim_create_user_command("TasksSetPriority", function(opts)
    if not utils.can_operate() then
      return
    end

    local level = priority.normalize(opts.args)
    if not level then
      vim.notify("nvim-tasks: Unknown priority level", vim.log.levels.INFO)
      return
    end

    local start_line = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_line = opts.line2 or start_line
    local changed = apply_priority(vim.api.nvim_get_current_buf(), start_line - 1, end_line, level)

    if not changed then
      vim.notify("nvim-tasks: No open tasks found", vim.log.levels.INFO)
    end
  end, {
    range = true,
    nargs = "?",
  })
end

function M.register()
  create_command()
end

return M
