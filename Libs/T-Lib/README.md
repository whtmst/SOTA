# T-Lib

Universal library for Turtle WoW addons.

## Installation

1. Copy the `T-Lib` folder to your addon's `Libs/` directory
2. Add library files to your `.toc` file **before** your addon files:

```toc
## Interface: 11200
## Title: MyAddon

# T-Lib Library
Libs\T-Lib\T-Lib.lua
Libs\T-Lib\BossData.lua
Libs\T-Lib\Localization.lua
Libs\T-Lib\Utils.lua

# Your addon
MyAddon.lua
```

## Usage

```lua
-- Check if unit is a boss
if T_Lib:IsBoss(UnitName("target")) then
    print("Target is a boss!")
end

-- Get raid by boss name
local raid = T_Lib:GetRaidByBoss("Ragnaros")
print(raid) -- "Molten Core"

-- Get all bosses in a raid
local bosses = T_Lib:GetBossesByRaid("MC")
for _, boss in ipairs(bosses) do
    print(boss)
end
```

## API Reference

### Boss Data Module

| Function | Description |
|----------|-------------|
| `T_Lib:IsBoss(name)` | Check if name is a boss |
| `T_Lib:GetRaidByBoss(bossName)` | Get raid name by boss |
| `T_Lib:GetRaidName(raidAlias)` | Get full raid name by alias |
| `T_Lib:GetBossesByRaid(raidAlias)` | Get all bosses in a raid |
| `T_Lib:GetBossCount(raidAlias)` | Get boss count in a raid |
| `T_Lib:IsRaid(name)` | Check if name is a raid/alias |
| `T_Lib:FindBoss(partialName)` | Find boss by partial match |
| `T_Lib:FindRaid(partialName)` | Find raid by partial match |
| `T_Lib:CompareBossName(a, b)` | Case-insensitive boss comparison |
| `T_Lib:GetAllRaids()` | Get all raid names |
| `T_Lib:GetAllRaidAliases()` | Get all raid aliases |
| `T_Lib:GetBossType(bossName)` | Get boss type (Elemental, Dragon, etc.) |
| `T_Lib:GetBossClassification(bossName)` | Get boss classification (Elite, Rare Elite, Boss) |

### Localization Module

| Function | Description |
|----------|-------------|
| `T_Lib.L:GetText(key)` | Get localized text by key |
| `T_Lib.L:SetLocale(locale)` | Set current locale (enUS, ruRU) |
| `T_Lib.L:GetLocale()` | Get current locale |
| `T_Lib.L:AddString(locale, key, text)` | Add new localization string |

### Utils Module

| Function | Description |
|----------|-------------|
| `T_Lib.Utils:Print(...)` | Print colored message |
| `T_Lib.Utils:PrintError(...)` | Print error message |
| `T_Lib.Utils:PrintDebug(...)` | Print debug message |
| `T_Lib.Utils:TableCount(tbl)` | Get table length |
| `T_Lib.Utils:TableContains(tbl, value)` | Check if table has value |
| `T_Lib.Utils:StripColor(text)` | Remove color codes |
| `T_Lib.Utils:MatchName(a, b)` | Case-insensitive name match |
| `T_Lib.Utils:Contains(str, substr)` | Check if string contains substring |
| `T_Lib.Utils:Trim(str)` | Trim whitespace |
| `T_Lib.Utils:Clamp(val, min, max)` | Clamp value between min/max |
| `T_Lib.Utils:CopyTable(tbl)` | Shallow copy table |
| `T_Lib.Utils:DeepCopyTable(tbl)` | Deep copy table |
| `T_Lib.Utils:FormatNumber(num)` | Format number with commas (1234567 → "1,234,567") |
| `T_Lib.Utils:ShortNumber(num)` | Short number (1500000 → "1.5m") |

## Supported Raids

- Blackrock Spire (UBRS/LBRS)
- Onyxia's Lair (Ony)
- Molten Core (MC)
- Blackwing Lair (BWL)
- Karazhan (LKH/ToK)
- Zul'Gurub (ZG)
- Emerald Sanctum (ES)
- Ruins of Ahn'Qiraj (AQ20)
- Ahn'Qiraj (AQ40)
- Timbermaw Hold (TmH)
- Naxxramas (Naxx)
- World Bosses
- TW Custom Bosses

## Supported Dungeons

- Ragefire Chasm (RFC)
- Frostmane Hollow (FH)
- Deadmines (VC)
- Wailing Caverns (WC)
- Shadowfang Keep (SFK)
- The Stockade (Stock)
- Blackfathom Deeps (BFD)
- Windhorn Canyon (WhC)
- Razorfen Kraul (RFK)
- Razorfen Downs (RFD)
- Gnomeregan (Gnome)
- The Crescent Grove (TCG)
- Dragonmaw Retreat (DMR)
- Scarlet Monastery (SM)
- Stormwrought Ruins (SwR)
- Gilneas City (GC)
- Maraudon (Mara)
- Uldaman (Ulda)
- Zul'Farrak (ZF)
- Sunken Temple (ST)
- Dire Maul (DM)
- Hateforge Quarry (HQ)
- Karazhan Crypt (KC)
- Blackrock Depths (BRD)
- Stratholme (Strat)
- Scholomance (Scholo)
- Stormwind Vault (SwV)
- The Black Morass (BM)

## Miscellaneous
- Alliance Weapon Master's
- Horde Weapon Master's

## Examples

### Boss Detection

```lua
local bossName = UnitName("target")
if T_Lib:IsBoss(bossName) then
    local raid = T_Lib:GetRaidByBoss(bossName)
    print("Boss detected: " .. bossName .. " in " .. raid)
end
```

### Raid Progress Tracking

```lua
local bosses = T_Lib:GetBossesByRaid("MC")
local defeated = 0
for _, boss in ipairs(bosses) do
    if IsBossDead(boss) then
        defeated = defeated + 1
    end
end
print(defeated .. "/" .. #bosses .. " bosses defeated")
```

### Get Boss Type and Classification

```lua
local bossName = UnitName("target")
if T_Lib:IsBoss(bossName) then
    local bossType = T_Lib:GetBossType(bossName)
    local classification = T_Lib:GetBossClassification(bossName)
    print("Boss: " .. bossName .. " (" .. bossType .. ") - " .. classification)
end
-- Output: "Boss: Ragnaros (Elemental) - Elite"
```

### Format Numbers

```lua
local health = 1500000
print(T_Lib.Utils:FormatNumber(health))    -- "1,500,000"
print(T_Lib.Utils:ShortNumber(health))     -- "1.5m"
```

### Localization

```lua
-- Auto-detect client locale
local locale = GetLocale()
T_Lib.L:SetLocale(locale)

-- Get localized text
local message = T_Lib.L:GetText("BOSS_FOUND")
print(string.format(message, UnitName("target")))
```

## For Developers

### Debug Mode

Enable debug output during development:

```lua
-- In your addon's main file (before using T_Lib)
T_Lib.DebugMode = true  -- Enable debug messages
```

Disable before release:

```lua
T_Lib.DebugMode = false  -- Disable debug messages
```

Debug messages will appear in chat with a pink `[T-LIB DEBUG]` prefix.

---

## 📄 License

[GPL-3.0 license](LICENSE) - feel free to use this in your projects!

---

## 👥 Author

**Created and/or maintained by**: [Wht Mst](https://dalink.to/whtmst)

*Made with ❤️ for the Turtle WoW community*

*This project is not affiliated (or associated) with Turtle WoW or Blizzard Entertainment.*
