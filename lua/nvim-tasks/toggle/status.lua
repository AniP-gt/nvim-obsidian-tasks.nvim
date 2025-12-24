local meta = require("nvim-tasks.meta")
local symbols = require("nvim-tasks.symbols")

local STATE = {
  OPEN = "open",
  DONE = "done",
}

local CHECKBOXES = {
  [STATE.OPEN] = "[ ]",
  [STATE.DONE] = "[x]",
}

local function today()
  return os.date("%Y-%m-%d")
end

local function trim(value)
  if not value then
    return ""
  end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function cleanup_content(value)
  local result = value or ""
  result = meta.remove_date_field(result, "done")
  return trim(result)
end

local function parse_line(line)
  local indent, checkbox, remainder = line:match("^(%s*)%- %[(%s*[xX]?%s*)%] ?(.*)$")
  if not indent then
    return nil
  end
  local state
  local normalized = trim(checkbox):upper()
  if normalized:match("X") then
    state = STATE.DONE
  else
    state = STATE.OPEN
  end
  return {
    indent = indent,
    state = state,
    content = cleanup_content(remainder),
  }
end

local function build_line(parsed, target_state)
  if not parsed then
    return nil
  end
  local checkbox = CHECKBOXES[target_state]
  if not checkbox then
    return nil
  end
  local line = string.format("%s- %s", parsed.indent, checkbox)
  local segments = {}
  if target_state == STATE.DONE then
    local symbol = symbols.dates.done
    if symbol then
      table.insert(segments, symbol)
      table.insert(segments, today())
    end
  end
  if parsed.content ~= "" then
    table.insert(segments, parsed.content)
  end
  if #segments > 0 then
    line = line .. " " .. table.concat(segments, " ")
  end
  return line
end

local function apply_transform(bufnr, start_idx, end_idx, transformer)
  local lines = vim.api.nvim_buf_get_lines(bufnr, start_idx, end_idx, false)
  local changed = false
  for i, line in ipairs(lines) do
    local replacement = transformer(line)
    if replacement and replacement ~= line then
      lines[i] = replacement
      changed = true
    end
  end
  if changed then
    vim.api.nvim_buf_set_lines(bufnr, start_idx, end_idx, false, lines)
  end
  return changed
end

local function complete_line(line)
  local parsed = parse_line(line)
  if not parsed or parsed.state ~= STATE.OPEN then
    return nil
  end
  return build_line(parsed, STATE.DONE)
end

local function toggle_line(line)
  local parsed = parse_line(line)
  if not parsed then
    return nil
  end
  if parsed.state == STATE.OPEN then
    return build_line(parsed, STATE.DONE)
  end
  if parsed.state == STATE.DONE then
    return build_line(parsed, STATE.OPEN)
  end
  return nil
end

local M = {}

function M.get_state(line)
  local parsed = parse_line(line)
  return parsed and parsed.state
end

function M.complete_range(bufnr, start_idx, end_idx)
  return apply_transform(bufnr, start_idx, end_idx, complete_line)
end

function M.toggle_range(bufnr, start_idx, end_idx)
  return apply_transform(bufnr, start_idx, end_idx, toggle_line)
end

M.STATE = STATE

return M
