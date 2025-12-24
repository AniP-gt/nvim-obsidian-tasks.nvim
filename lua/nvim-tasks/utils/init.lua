local M = {}

local vault = require("nvim-tasks.vault")

local function is_markdown_filetype(ft)
  return ft == "markdown" or ft == "md" or ft == "pandoc"
end

function M.is_markdown(ft)
  return is_markdown_filetype(ft or vim.bo.filetype)
end

function M.can_operate()
  if not is_markdown_filetype(vim.bo.filetype) then
    vim.notify("nvim-tasks: Only available in Markdown files", vim.log.levels.INFO)
    return false
  end
  if not vault.in_vault() then
    vim.notify("nvim-tasks: Only available inside an Obsidian vault", vim.log.levels.INFO)
    return false
  end
  return true
end

function M.is_open_task(line)
  return line:match("^%s*%- %[ %] .+") ~= nil
end

function M.update_range(bufnr, start_idx, end_idx, transformer)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
  local changed = false
  for i, line in ipairs(lines) do
    if M.is_open_task(line) then
      local updated = transformer(line)
      if updated ~= line then
        lines[i] = updated
        changed = true
      end
    end
  end
  if changed then
    vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
  end
  return changed
end

return M

