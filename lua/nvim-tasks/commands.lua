local complete_command = require("nvim-tasks.commands.complete")
local toggle_command = require("nvim-tasks.commands.toggle")
local due_date_command = require("nvim-tasks.commands.due_date")
local scheduled_date_command = require("nvim-tasks.commands.scheduled_date")
local start_date_command = require("nvim-tasks.commands.start_date")
local created_date_command = require("nvim-tasks.commands.created_date")
local done_date_command = require("nvim-tasks.commands.done_date")
local cancelled_date_command = require("nvim-tasks.commands.cancelled_date")
local priority_command = require("nvim-tasks.commands.priority")

local M = {}

function M.register()
  complete_command.register()
  toggle_command.register()
  due_date_command.register()
  scheduled_date_command.register()
  start_date_command.register()
  created_date_command.register()
  done_date_command.register()
  cancelled_date_command.register()
  priority_command.register()
end

return M
