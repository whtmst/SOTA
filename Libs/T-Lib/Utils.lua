-- =============================================================================
-- T-Lib: Utils Module
-- =============================================================================
-- Utility functions for T-Lib
--
-- Usage:
--   T_Lib.Utils:Print(...)           -- print colored message
--   T_Lib.Utils:TableCount(tbl)      -- get table length
--   T_Lib.Utils:TableContains(...)   -- check if table has value
--   T_Lib.Utils:StripColor(text)     -- remove color codes
--   T_Lib.Utils:MatchName(a, b)      -- case-insensitive name match
-- =============================================================================

T_Lib = T_Lib or {}
T_Lib.Utils = {}

-- Print a message to chat frame
function T_Lib.Utils:Print(...)
    local msg = table.concat({...}, " ")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFEC3E08[T-LIB]|r " .. msg)
end

-- Print an error message
function T_Lib.Utils:PrintError(...)
    local msg = table.concat({...}, " ")
    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF3333[T-LIB ERROR]|r " .. msg)
end

-- Print a debug message (only if debug mode is enabled)
function T_Lib.Utils:PrintDebug(...)
    if T_Lib.DebugMode then
        local msg = table.concat({...}, " ")
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF00FF[T-LIB DEBUG]|r " .. msg)
    end
end

-- Get table length (number of keys)
function T_Lib.Utils:TableCount(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Check if table contains a value
function T_Lib.Utils:TableContains(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Check if table has a key
function T_Lib.Utils:TableHasKey(tbl, key)
    return tbl[key] ~= nil
end

-- Remove color codes from text
function T_Lib.Utils:StripColor(text)
    if not text then
        return ""
    end
    return string.gsub(text, "|c%x%x%x%x%x%x%x%x", "")
end

-- Case-insensitive string comparison
function T_Lib.Utils:MatchName(str1, str2)
    if not str1 or not str2 then
        return false
    end
    return string.lower(str1) == string.lower(str2)
end

-- Check if string contains substring (case-insensitive)
function T_Lib.Utils:Contains(str, substring)
    if not str or not substring then
        return false
    end
    return string.find(string.lower(str), string.lower(substring), 1, true) ~= nil
end

-- Trim whitespace from string
function T_Lib.Utils:Trim(str)
    if not str then
        return ""
    end
    return string.match(str, "^%s*(.-)%s*$")
end

-- Safe division (returns 0 if dividing by zero)
function T_Lib.Utils:SafeDivide(a, b)
    if b == 0 then
        return 0
    end
    return a / b
end

-- Clamp value between min and max
function T_Lib.Utils:Clamp(value, minVal, maxVal)
    if value < minVal then
        return minVal
    elseif value > maxVal then
        return maxVal
    end
    return value
end

-- Format number with commas (1234567 -> "1,234,567")
function T_Lib.Utils:FormatNumber(num)
    if not num then return "0" end
    local left, right = string.match(tostring(num), "^([^%d]*%d+)(%d*)$")
    return left:gsub("%d(?=(%d%d%d)%D)", "%0,") .. right
end

-- Short number (1500000 -> "1.5m")
function T_Lib.Utils:ShortNumber(num)
    if not num then return "0" end
    if num >= 1000000 then
        return string.format("%.1fm", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fk", num / 1000)
    end
    return tostring(num)
end

-- Merge two tables
function T_Lib.Utils:MergeTables(t1, t2)
    local result = {}
    for k, v in pairs(t1) do
        result[k] = v
    end
    for k, v in pairs(t2) do
        result[k] = v
    end
    return result
end

-- Copy table (shallow copy)
function T_Lib.Utils:CopyTable(tbl)
    local result = {}
    for k, v in pairs(tbl) do
        result[k] = v
    end
    return result
end

-- Deep copy table
function T_Lib.Utils:DeepCopyTable(tbl)
    local lookup = {}
    local function copy(orig)
        if type(orig) ~= "table" then
            return orig
        end
        if lookup[orig] then
            return lookup[orig]
        end
        local new = {}
        lookup[orig] = new
        for k, v in pairs(orig) do
            new[copy(k)] = copy(v)
        end
        return new
    end
    return copy(tbl)
end
