local vault = require("nvim-tasks.vault")

local M = {}

local function today()
	return os.date("%Y-%m-%d")
end

local function is_markdown()
	local ft = vim.bo.filetype
	return ft == "markdown" or ft == "md" or ft == "pandoc"
end

local function is_open_task(line)
	return line:match("^%s*%- %[%s%] .+") ~= nil
end

local function is_done_task(line)
	return line:match("^%s*%- %[%s*x%s*%]") ~= nil
end

local function normalize_task(line)
	local indent, content = line:match("^(%s*)%- %[%s%] (.+)$")
	if not indent then
		return false, line
	end
	local new_line = string.format("%s- [x] ✅ %s %s", indent, today(), content)
	return true, new_line
end

local function can_operate()
	if not is_markdown() then
		vim.notify("nvim-tasks: Markdown 以外では実行しません", vim.log.levels.INFO)
		return false
	end
	return true
end

local function apply_lines(bufnr, start_idx, end_idx)
	local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
	local changed = false
	for i, line in ipairs(lines) do
		if is_open_task(line) then
			local ok, replaced = normalize_task(line)
			if ok then
				lines[i] = replaced
				changed = true
			end
		end
	end
	if changed then
		vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
	end
	return changed
end

function M.complete_current_line()
	if not can_operate() then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local row = vim.api.nvim_win_get_cursor(0)[1] - 1
	local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
	if is_done_task(line) then
		vim.notify("nvim-tasks: 既に完了済みです", vim.log.levels.INFO)
		return
	end
	if not is_open_task(line) then
		vim.notify("nvim-tasks: 対象タスクがありません", vim.log.levels.INFO)
		return
	end
	apply_lines(bufnr, row, row + 1)
end

function M.complete_visual_selection()
	if not can_operate() then
		return
	end
	local bufnr = vim.api.nvim_get_current_buf()
	local start_pos = vim.fn.getpos("<")
	local end_pos = vim.fn.getpos(">")
	local start_idx = math.min(start_pos[2], end_pos[2]) - 1
	local end_idx = math.max(start_pos[2], end_pos[2])

	local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
	local any = false
	for i, line in ipairs(lines) do
		if is_open_task(line) then
			local ok, replaced = normalize_task(line)
			if ok then
				lines[i] = replaced
				any = true
			end
		end
	end

	if not any then
		vim.notify("nvim-tasks: 変換対象のタスクがありません", vim.log.levels.INFO)
		return
	end

	-- Replace in one undoable chunk
	vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
end

return M
