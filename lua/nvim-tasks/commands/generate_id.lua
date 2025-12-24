local id_utils = require("nvim-tasks.utils.id")
local utils = require("nvim-tasks.utils")

local M = {}

local function create_command()
  if vim.fn.exists(":TasksGenerateId") == 2 then
    return
  end

  vim.api.nvim_create_user_command("TasksGenerateId", function(opts)
    if not utils.can_operate() then
      return
    end

    local start_line = opts.line1 or vim.api.nvim_win_get_cursor(0)[1]
    local end_line = opts.line2 or start_line
    local changed = id_utils.apply(vim.api.nvim_get_current_buf(), start_line - 1, end_line)

    if not changed then
      vim.notify("nvim-tasks: No matching tasks found", vim.log.levels.INFO)
    end
  end, {
    range = true,
  })
end

function M.register()
  create_command()
end

return M
