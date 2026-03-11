-- =============================================================================
-- T-Lib: Localization Module
-- =============================================================================
-- Localization support for T-Lib
--
-- Usage:
--   T_Lib.L:GetText(key)        -- get localized text by key
--   T_Lib.L:SetLocale(locale)   -- set current locale (enUS, ruRU, etc.)
--   T_Lib.L:GetLocale()         -- get current locale
--
-- Example:
--   local text = T_Lib.L:GetText("BOSS_FOUND")
--   T_Lib.L:SetLocale("ruRU")
-- =============================================================================

T_Lib = T_Lib or {}

-- Localization table
T_Lib.L = {}

-- Current locale (detect from game client)
local currentLocale = GetLocale()

-- Localization strings database
local L = {
    -- English (default)
    enUS = {
        -- Boss data
        BOSS_FOUND = "Boss found: %s",
        BOSS_NOT_FOUND = "No boss found",
        RAID_FOUND = "Raid: %s",
        UNKNOWN_RAID = "Unknown raid",

        -- Boss types
        BOSS_TYPE_MISCELLANEOUS = "Miscellaneous",
        BOSS_TYPE_BEAST = "Beast",
        BOSS_TYPE_HUMANOID = "Humanoid",
        BOSS_TYPE_ABOMINATION = "Abomination",
        BOSS_TYPE_GOLEM = "Golem",
        BOSS_TYPE_GIANT = "Giant",
        BOSS_TYPE_MECHANICAL = "Mechanical",
        BOSS_TYPE_ABERRATION = "Aberration",
        BOSS_TYPE_UNDEAD = "Undead",
        BOSS_TYPE_DEMON = "Demon",
        BOSS_TYPE_DRAGONKIN = "Dragonkin",
        BOSS_TYPE_DRAGON = "Dragon",
        BOSS_TYPE_ELEMENTAL = "Elemental",
        BOSS_TYPE_VOID = "Void Entity",
        BOSS_TYPE_LOA = "Loa",
        BOSS_TYPE_OLD_GOD = "Old God",

        -- Boss classification
        BOSS_CLASSIFICATION_ELITE = "Elite",
        BOSS_CLASSIFICATION_RARE_ELITE = "Rare Elite",
        BOSS_CLASSIFICATION_BOSS = "Boss",

        -- Common
        YES = "Yes",
        NO = "No",
        UNKNOWN = "Unknown",
    },

    -- Russian
    ruRU = {
        -- Boss data
        BOSS_FOUND = "Босс найден: %s",
        BOSS_NOT_FOUND = "Босс не найден",
        RAID_FOUND = "Рейд: %s",
        UNKNOWN_RAID = "Неизвестный рейд",

        -- Boss types
        BOSS_TYPE_MISCELLANEOUS = "Разное",
        BOSS_TYPE_BEAST = "Зверь",
        BOSS_TYPE_HUMANOID = "Гуманоид",
        BOSS_TYPE_ABOMINATION = "Мерзость",
        BOSS_TYPE_GOLEM = "Голем",
        BOSS_TYPE_GIANT = "Великан",
        BOSS_TYPE_MECHANICAL = "Механизм",
        BOSS_TYPE_ABERRATION = "Чудовище",
        BOSS_TYPE_UNDEAD = "Нежить",
        BOSS_TYPE_DEMON = "Демон",
        BOSS_TYPE_DRAGONKIN = "Драконид",
        BOSS_TYPE_DRAGON = "Дракон",
        BOSS_TYPE_ELEMENTAL = "Элементаль",
        BOSS_TYPE_VOID = "Существо Бездны",
        BOSS_TYPE_LOA = "Лоа",
        BOSS_TYPE_OLD_GOD = "Древний Бог",

        -- Boss classification
        BOSS_CLASSIFICATION_ELITE = "Элита",
        BOSS_CLASSIFICATION_RARE_ELITE = "Редкая элита",
        BOSS_CLASSIFICATION_BOSS = "Босс",

        -- Common
        YES = "Да",
        NO = "Нет",
        UNKNOWN = "Неизвестно",
    },
}

-- Get text by key
function T_Lib.L:GetText(key)
    local localeData = L[currentLocale] or L.enUS
    return localeData[key] or L.enUS[key] or key
end

-- Set current locale
function T_Lib.L:SetLocale(locale)
    if L[locale] then
        currentLocale = locale
    end
end

-- Get current locale
function T_Lib.L:GetLocale()
    return currentLocale
end

-- Add new localization string
function T_Lib.L:AddString(locale, key, text)
    if not L[locale] then
        L[locale] = {}
    end
    L[locale][key] = text
end
