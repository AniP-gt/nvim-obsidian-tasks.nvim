local symbols = require("nvim-tasks.symbols")

local PRIORITY_LEVELS = {
  lowest = "lowest",
  low = "low",
  medium = "medium",
  high = "high",
  highest = "highest",
  none = "none",
  normal = "none",
}

local PRIORITY_SYMBOL_TO_LEVEL = {}
for level, symbol in pairs(symbols.priority) do
  if symbol ~= "" then
    PRIORITY_SYMBOL_TO_LEVEL[symbol] = level
  end
end

local function escape_pattern(value)
  return value:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

local function split_indent(line)
  local indent, rest = line:match("^(%s*)(.*)$")
  return indent or "", rest or ""
end

local function normalize_whitespace(value)
  return value:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end

local function remove_existing_priority(rest)
  for _, symbol in pairs(symbols.priority) do
    if symbol ~= "" then
      local pattern = "%s*" .. escape_pattern(symbol) .. "%s*"
      rest = rest:gsub(pattern, " ", 1)
    end
  end
  return normalize_whitespace(rest)
end

local function insert_priority(rest, symbol)
  if symbol == "" then
    return normalize_whitespace(rest)
  end
  rest = normalize_whitespace(rest)
  if rest == "" then
    return symbol
  end
  return rest .. " " .. symbol
end

local function canonical_level(value)
  if not value then
    return "none"
  end
  local normalized = value:lower():gsub("%s+", "")
  normalized = normalized:gsub("priority", "")
  if normalized == "" then
    return "none"
  end
  if PRIORITY_LEVELS[normalized] then
    return PRIORITY_LEVELS[normalized]
  end
  if PRIORITY_SYMBOL_TO_LEVEL[value] then
    return PRIORITY_SYMBOL_TO_LEVEL[value]
  end
  return nil
end

local M = {}

function M.normalize(value)
  return canonical_level(value)
end

function M.set_priority(line, level)
  local symbol = symbols.priority[level]
  if not symbol then
    return line
  end
  local indent, rest = split_indent(line)
  rest = remove_existing_priority(rest)
  local prioritized = insert_priority(rest, symbol)
  if prioritized == "" then
    return indent .. rest
  end
  return indent .. prioritized
end

return M
