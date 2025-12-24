local vim = vim
local symbols = require("nvim-tasks.symbols")
local utils = require("nvim-tasks.utils")

local ON_COMPLETION_SYMBOL = symbols.on_completion or "🏁"
local ESCAPED_SYMBOL = vim.pesc(ON_COMPLETION_SYMBOL)
local STATE_PATTERN = ESCAPED_SYMBOL .. "%s*([dD]elete|[kK]eep)"
local ALLOWED_STATES = {
  delete = true,
  keep = true,
}

local function trim(value)
  if not value then
    return ""
  end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function find_last_state(text)
  local last_start, last_end, last_state
  local search_pos = 1
  while true do
    local start_idx, end_idx, state = text:find(STATE_PATTERN, search_pos)
    if not start_idx then
      break
    end
    last_start, last_end, last_state = start_idx, end_idx, state
    search_pos = end_idx + 1
  end
  return last_start, last_end, last_state
end

local function strip_trailing_states(line)
  local cleaned = trim(line)
  local last_state
  local suffix = ""
  while true do
    local start_idx, end_idx, state = find_last_state(cleaned)
    if not start_idx then
      break
    end
    if not last_state then
      last_state = state:lower()
      suffix = cleaned:sub(end_idx + 1)
    end
    cleaned = trim(cleaned:sub(1, start_idx - 1))
  end
  return cleaned, last_state, suffix
end

local function normalize_state(value)
  if not value then
    return nil
  end
  local lowered = value:lower()
  if ALLOWED_STATES[lowered] then
    return lowered
  end
  return nil
end

local function append_state(line, state, suffix)
  local trimmed = trim(line)
  if not state then
    if suffix and suffix ~= "" then
      return trimmed .. suffix
    end
    return trimmed
  end
  local formatted = string.format("%s %s %s", trimmed, ON_COMPLETION_SYMBOL, state)
  if suffix and suffix ~= "" then
    formatted = formatted .. suffix
  end
  return formatted
end

local function apply(bufnr, start_idx, end_idx, state)
  local target_state = normalize_state(state)
  return utils.update_range(bufnr, start_idx, end_idx, function(line)
    local base, _, suffix = strip_trailing_states(line)
    return append_state(base, target_state, suffix)
  end)
end

return {
  apply = apply,
}
