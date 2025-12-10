local M = {}

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, desc = desc })
end

function M.setup()
  map("n", "<leader>x", require("nvim-tasks.complete").complete_current_line, "Complete task")
  map("v", "<leader>x", require("nvim-tasks.complete").complete_visual_selection, "Complete tasks in selection")
end

return M
