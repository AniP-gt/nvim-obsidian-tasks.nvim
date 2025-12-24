local status = require("nvim-tasks.toggle.status")
local utils = require("nvim-tasks.utils")

local M = {}

function M.complete_current_line()
  if not utils.can_operate() then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  local state = status.get_state(line)
  if state == status.STATE.DONE then
    vim.notify("nvim-tasks: Task already completed", vim.log.levels.INFO)
    return
  end
  if state ~= status.STATE.OPEN then
    vim.notify("nvim-tasks: No task found on this line", vim.log.levels.INFO)
    return
  end
  status.complete_range(bufnr, row, row + 1)
end

function M.complete_visual_selection()
  if not utils.can_operate() then
    return
  end
  local bufnr = vim.api.nvim_get_current_buf()
  local start_pos = vim.fn.getpos("<")
  local end_pos = vim.fn.getpos(">")
  local start_idx = math.min(start_pos[2], end_pos[2]) - 1
  local end_idx = math.max(start_pos[2], end_pos[2])

  local changed = status.complete_range(bufnr, start_idx, end_idx)

  if not changed then
    vim.notify("nvim-tasks: No convertible tasks found", vim.log.levels.INFO)
  end
end

function M.complete_range(start_idx, end_idx)
  local bufnr = vim.api.nvim_get_current_buf()
  return status.complete_range(bufnr, start_idx, end_idx)
end

M.can_operate = utils.can_operate

return M

