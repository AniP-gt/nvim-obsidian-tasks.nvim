local M = {}

local function default_options()
  return {}
end

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", default_options(), opts or {})
  require("nvim-tasks.keymaps").setup()
end

return M
