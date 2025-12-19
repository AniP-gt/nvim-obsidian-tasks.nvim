local date_factory = require("nvim-tasks.utils.date_factory")

local M = {}

function M.register()
  date_factory.register("TasksSetCreatedDate", "created", {
    fail_message = "nvim-tasks: No open tasks found",
  })
end

return M
