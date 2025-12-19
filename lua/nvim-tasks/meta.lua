local symbols = require("nvim-tasks.symbols")

local DATE_PATTERN = "%d%d%d%d%-%d%d%-%d%d"

local function trim(value)
  if not value then
    return value
  end
  return value:gsub("^%s+", ""):gsub("%s+$", "")
end

local function escape_pattern(value)
  return value:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function remove_existing_field(line, symbol)
  local symbol_pattern = escape_pattern(symbol)
  local pattern = symbol_pattern .. "%s*" .. DATE_PATTERN
  local cleaned = line:gsub(pattern, "", 1)
  return trim(cleaned)
end

local function append_field(line, symbol, date_value)
  return string.format("%s %s %s", trim(line), symbol, trim(date_value))
end

local M = {}

function M.set_date_field(line, field, value)
  local symbol = symbols.dates[field]
  if not symbol or not value or trim(value) == "" then
    return line
  end
  local cleaned = remove_existing_field(line, symbol)
  return append_field(cleaned, symbol, value)
end

return M
