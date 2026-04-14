-- =============================================================================
-- T-Lib by Misha (Wht Mst) | Mikhail Palagin
-- =============================================================================
-- Universal library for Turtle WoW addons
--
-- Usage:
--   1. Copy T-Lib folder to Libs/ in your addon
--   2. Add library files to TOC before your addon files
--   3. Use API: T_Lib:FunctionName()
--
-- Modules:
--   - T_Lib.Bosses      -- boss data
--   - T_Lib.Raids       -- raid data
--   - T_Lib.L           -- localization
--   - T_Lib.Utils       -- utilities
-- =============================================================================

T_Lib = T_Lib or {}
T_Lib.Version = "1.1.0"
T_Lib.Author = "Misha (Wht Mst) | Mikhail Palagin"
T_Lib.Author_URL = "https://dalink.to/whtmst"
T_Lib.Lib_URL = "https://github.com/whtmst/T-Lib"

-- =============================================================================
-- DEBUG MODE (for development)
-- =============================================================================
-- Set to true to enable debug messages during development.
-- Add this line in your addon's main file (before using T_Lib):
--   T_Lib.DebugMode = true
--
-- Disable before release:
--   T_Lib.DebugMode = false
-- =============================================================================
T_Lib.DebugMode = T_Lib.DebugMode or false
