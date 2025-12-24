local on_completion = require("nvim-tasks.utils.on_completion")
local utils = require("nvim-tasks.utils")

local M = {}

local function create_state_command(name, state)
  if vim.fn.exists(":" .. name) == 2 then
    return
  end

  vim.api.nvim_create_user_command(name, function(opts)
    if not utils.can_operate() then
      return
    end

    local start_line = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_line = opts.line2 or start_line
    local changed = on_completion.apply(vim.api.nvim_get_current_buf(), start_line - 1, end_line, state)

    if not changed then
      vim.notify("nvim-tasks: No matching tasks found", vim.log.levels.INFO)
    end
  end, {
    range = true,
  })
end

function M.register()
  create_state_command("TasksOnCompletionDelete", "delete")
  create_state_command("TasksOnCompletionKeep", "keep")
end

return M
