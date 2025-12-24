local utils = require("nvim-tasks.utils")
local symbols = require("nvim-tasks.symbols")

local ID_SYMBOL = symbols.ids and symbols.ids.task or "🆔"
local ID_PATTERN = ID_SYMBOL .. "%s*[0-9A-Za-z]+"
local ID_LENGTH = 6
local CHARSET = "abcdefghijklmnopqrstuvwxyz0123456789"
local seeded = false

local function trim(value)
  if not value then
    return ""
  end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function remove_existing_id(line)
  local cleaned = line:gsub(ID_PATTERN, "", 1)
  return trim(cleaned)
end

local function ensure_seed()
  if seeded then
    return
  end
  math.randomseed(os.time())
  seeded = true
end

local function generate_id()
  ensure_seed()
  local parts = {}
  for i = 1, ID_LENGTH do
    local idx = math.random(#CHARSET)
    parts[i] = CHARSET:sub(idx, idx)
  end
  return table.concat(parts)
end

local function append_id(line, value)
  if not value or trim(value) == "" then
    return trim(line)
  end
  return string.format("%s %s %s", trim(line), ID_SYMBOL, trim(value))
end

local function apply(bufnr, start_idx, end_idx)
  return utils.update_range(bufnr, start_idx, end_idx, function(line)
    local cleaned = remove_existing_id(line)
    local generated = generate_id()
    return append_id(cleaned, generated)
  end)
end

return {
  apply = apply,
}
