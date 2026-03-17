-- =============================================================================
-- T-Lib: BossData Module
-- =============================================================================
-- Boss and raid database for Turtle WoW
-- Client version: 1.12
--
-- API:
--   T_Lib:IsBoss(name)                  -- check if name is a boss
--   T_Lib:GetRaidByBoss(bossName)       -- get raid name by boss
--   T_Lib:GetRaidName(raidAlias)        -- get full raid name by alias
--   T_Lib:GetBossesByRaid(raid)         -- get all bosses in a raid
--   T_Lib:GetBossCount(raid)            -- get boss count in a raid
--   T_Lib:IsRaid(name)                  -- check if name is a raid/alias
--   T_Lib:FindBoss(partialName)         -- find boss by partial match
--   T_Lib:FindRaid(partialName)         -- find raid by partial match
--   T_Lib:CompareBossName(a, b)         -- case-insensitive boss comparison
--   T_Lib:GetAllRaids()                 -- get all raid names
--   T_Lib:GetAllRaidAliases()           -- get all raid aliases
--   T_Lib:GetBossType(bossName)         -- get boss type (Elemental, Dragon, etc.)
--   T_Lib:GetBossClassification(boss)   -- get boss classification (Elite, Boss, Rare Elite)
-- =============================================================================

-- Ensure T_Lib exists
T_Lib = T_Lib or {}

-- Boss data organized by raid
T_Lib.Raids = {
    -- ========================================================================
    -- RAIDS
    -- ========================================================================

    -- Upper Blackrock Spire (UBRS)
    ["Upper Blackrock Spire"] = {
        "Pyroguard Emberseer",
        "Solakar Flamewreath",
        "Jed Runewatcher",
        "Goraluk Anvilcrack",
        "Warchief Rend Blackhand",
        "Gyth",
        "The Beast",
        "Lord Valthalak",
        "General Drakkisath",
    },
    -- Onyxia's Lair (Ony)
    ["Onyxia's Lair"] = {
        "Onyxia",
        "Broodcommander Axelus",
    },
    -- Molten Core (MC)
    ["Molten Core"] = {
        "Core Hound",
        "Ancient Core Hound",
        "Lava Surger",
        "Flame Imp",
        "Incindis",
        "Lucifron",
        "Magmadar",
        "Garr",
        "Baron Geddon",
        "Shazzrah",
        "Golemagg the Incinerator",
        "Sulfuron Harbinger",
        "Majordomo Executus",
        "Basalthar",
        "Smoldaris",
        "Sorcerer-Thane Thaurissan",
        "Gehennas",
        "Ragnaros",
    },
    -- Blackwing Lair (BWL)
    ["Blackwing Lair"] = {
        "Death Talon Wyrmguard",
        "Razorgore the Untamed",
        "Vaelastrasz the Corrupt",
        "Broodlord Lashlayer",
        "Firemaw",
        "Ebonroc",
        "Flamegor",
        "Chromaggus",
        "Nefarian",
        "Ezzel Darkbrewer",
    },
    -- Lower Karazhan Halls (LKH)
    ["Lower Karazhan Halls"] = {
        "Phantom Servant",
        "Master Blacksmith Rolfen",
        "Brood Queen Araxxna",
        "Grizikil",
        "Clawlord Howlfang",
        "Dark Rider Champion",
        "Lord Blackwald II",
        "Moroes",
    },
    -- Zul'Gurub (ZG)
    ["Zul'Gurub"] = {
        "Gurubashi Bat Rider",
        "Gurubashi Berserker",
        "Mad Servant",
        "High Priestess Jeklik",
        "High Priest Venoxis",
        "High Priestess Mar'li",
        "Bloodlord Mandokir",
        "Gri'lek",
        "Hazza'rah",
        "Renataki",
        "Wushoolay",
        "Gahz'ranka",
        "High Priest Thekal",
        "High Priestess Arlokk",
        "Jin'do the Hexxer",
        "Hakkar",
    },
    -- Emerald Sanctum (ES)
    ["Emerald Sanctum"] = {
        "Sanctum Dragonkin",
        "Sanctum Dreamer",
        "Sanctum Supressor",
        "Sanctum Wyrm",
        "Sanctum Wyrmkin",
        "Erennius",
        "Solnius",
    },
    -- Ruins of Ahn'Qiraj (AQ20)
    ["Ruins of Ahn'Qiraj"] = {
        "Flesh Hunter",
        "Anubisath Guardian",
        "Hive'Zara Soldier",
        "Kurinnaxx",
        "Lieutenant General Andorov",
        "General Rajaxx",
        "Captain Qeez",
        "Captain Tuubid",
        "Captain Drenn",
        "Captain Xurrem",
        "Major Yeggeth",
        "Major Pakkon",
        "Colonel Zerran",
        "Moam",
        "Buru the Gorger",
        "Ayamiss the Hunter",
        "Ossirian the Unscarred",
    },
    -- Ahn'Qiraj / Temple of Ahn'Qiraj (AQ40)
    ["Ahn'Qiraj"] = {
        "Qiraji Brainwasher",
        "Qiraji Champion",
        "Qiraji Mindslayer",
        "Anubisath Defender",
        "Anubisath Sentinel",
        "Anubisath Warder",
        "The Prophet Skeram",
        "Vem",
        "Lord Kri",
        "Princess Yauj",
        "Battleguard Sartura",
        "Fankriss the Unyielding",
        "Viscidus",
        "Princess Huhuran",
        "Emperor Vek'lor",
        "Emperor Vek'nilash",
        "Ouro",
        "C'Thun",
    },
    -- Timbermaw Hold (TmH)
    ["Timbermaw Hold"] = {
    },
    -- Naxxramas (Naxx)
    ["Naxxramas"] = {
        "Patchwork Golem",
        "Deathknight Captain",
        "Deathknight Cavalier",
        "Gargoyle",
        "Living Monstrosity",
        "Venom Stalker",
        "Patchwerk",
        "Grobbulus",
        "Gluth",
        "Thaddius",
        "Anub'Rekhan",
        "Grand Widow Faerlina",
        "Maexxna",
        "Noth the Plaguebringer",
        "Heigan the Unclean",
        "Loatheb",
        "Instructor Razuvious",
        "Gothik the Harvester",
        "Thane Korth'azz",
        "Lady Blaumeux",
        "Highlord Mograine",
        "Sir Zeliek",
        "Sapphiron",
        "Kel'Thuzad",
    },
    -- Tower of Karazhan (ToK)
    ["Tower of Karazhan"] = {
        "Keeper Gnarlmoon",
        "Ley-Watcher Incantagos",
        "Anomalus",
        "Echo of Medivh",
        "King",
        "Sanv Tas'dal",
        "Rupturan the Broken",
        "Kruul",
        "Mephistroth",
    },
    -- World Bosses
    ["World Bosses"] = {
        "Azuregos",
        "Cla'ckora",
        "Concavius",
        "Moo",
        "Lethon",
        "Emeriss",
        "Taerar",
        "Ysondre",
        "Lord Kazzak",
        "Nerubian Overseer",
        "Ostarius",
        "Dark Reaver of Karazhan",
    },
    -- TW Custom Bosses (Turtle WoW unique bosses)
    ["TW Custom Bosses"] = {
        "Avalanchion",
        "The Windreaver",
        "Baron Charr",
        "Princess Tempestria",
        "Doctor Weavil",
        "Twilight Corrupter",
        "Trigore the Lasher",
        "Boahn",
        "Mad Magglish",
        "Marisa du'Paige",
        "Brainwashed Noble",
        "Foreman Thistlenettle",
        "Kazkaz the Unholy",
        "Zekkis",
        "Veyzhak the Cannibal",
        "Magregan Deepshadow",
        "Techbot",
    },
    -- ========================================================================
    -- DUNGEONS
    -- ========================================================================

    -- Ragefire Chasm (RFC)
    ["Ragefire Chasm"] = {
        "Oggleflint",
        "Taragaman the Hungerer",
        "Jergosh the Invoker",
        "Bazzalan",
    },
    -- Frostmane Hollow (FH)
    ["Frostmane Hollow"] = {
    },
    -- Deadmines (VC)
    ["Deadmines"] = {
        "Jared Voss",
        "Rhahk'Zor",
        "Miner Johnson",
        "Sneed",
        "Sneed's Shredder",
        "Gilnid",
        "Masterpiece Harvester",
        "Mr. Smite",
        "Cookie",
        "Captain Greenskin",
        "Edwin VanCleef",
    },
    -- Wailing Caverns (WC)
    ["Wailing Caverns"] = {
        "Lord Cobrahn",
        "Lady Anacondra",
        "Kresh",
        "Deviate Faerie Dragon",
        "Zandara Windhoof",
        "Lord Pythas",
        "Skum",
        "Vangros",
        "Lord Serpentis",
        "Verdan the Everliving",
        "Mutanus the Devourer",
    },
    -- Shadowfang Keep (SFK)
    ["Shadowfang Keep"] = {
        "Rethilgore",
        "Fel Steed",
        "Razorclaw the Butcher",
        "Baron Silverlaine",
        "Commander Springvale",
        "Sever",
        "Odo the Blindwatcher",
        "Deathsworn Captain",
        "Fenrus the Devourer",
        "Arugal's Voidwalker",
        "Wolf Master Nandos",
        "Archmage Arugal",
        "Prelate Ironmane",
    },
    -- The Stockade (Stock)
    ["The Stockade"] = {
        "Targorr the Dread",
        "Kam Deepfury",
        "Hamhock",
        "Bazil Thredd",
        "Dextren Ward",
        "Bruegal Ironknuckle",
    },
    -- Blackfathom Deeps (BFD)
    ["Blackfathom Deeps"] = {
        "Ghamoo-ra",
        "Lady Sarevess",
        "Gelihast",
        "Lorgus Jett",
        "Velthelaxx the Defiler",
        "Baron Aquanis",
        "Twilight Lord Kelris",
        "Old Serra'kis",
        "Aku'mai",
    },
    -- Windhorn Canyon (WhC)
    ["Windhorn Canyon"] = {
    },
    -- Razorfen Kraul (RFK)
    ["Razorfen Kraul"] = {
        "Roogug",
        "Aggem Thorncurse",
        "Death Speaker Jargba",
        "Overlord Ramtusk",
        "Razorfen Spearhide",
        "Rotthorn",
        "Agathelos the Raging",
        "Blind Hunter",
        "Charlga Razorflank",
        "Earthcaller Halmgar",
    },
    -- Razorfen Downs (RFD)
    ["Razorfen Downs"] = {
        "Tuten'kash",
        "Henry Stern",
        "Lady Falther'ess",
        "Plaguemaw the Rotting",
        "Mordresh Fire Eye",
        "Glutton",
        "Death Prophet Rakameg",
        "Ragglesnout",
        "Amnennar the Coldbringer",
    },
    -- Gnomeregan (Gnome)
    ["Gnomeregan"] = {
        "Grubbis",
        "Chomper",
        "Viscous Fallout",
        "Electrocutioner 6000",
        "Crowd Pummeler 9-60",
        "Dark Iron Ambassador",
        "Mekgineer Thermaplugg",
    },
    -- The Crescent Grove (TCG)
    ["The Crescent Grove"] = {
        "Grovetender Engryss",
        "Elder Blackmaw",
        "Elder \"One Eye\"",
        "Keeper Ranathos",
        "High Priestess A'lathea",
        "Fenektis the Deceiver",
        "Master Raxxieth",
    },
    -- Dragonmaw Retreat (DMR)
    ["Dragonmaw Retreat"] = {
        "Gowlfang",
        "Bogpaw Truthsay",
        "Cavernweb Broodmother",
        "Web Master Torkon",
        "Garlok Flamekeeper",
        "Halgan Redbrand",
        "Slagfist Destroyer",
        "Overlord Blackheart",
        "Elder Hollowblood",
        "Searistrasz",
        "Zuluhed the Whacked",
    },
    -- Scarlet Monastery (SM)
    ["Scarlet Monastery"] = {
        "Herod",
        "Armory Quartermaster Daghelm",
        "High Inquisitor Fairbanks",
        "Scarlet Commander Mograine",
        "High Inquisitor Whitemane",
        "Interrogator Vishas",
        "Scorn",
        "Bloodmage Thalnos",
        "Ironspine",
        "Azshir the Sleepless",
        "Fallen Champion",
        "Duke Dreadmoore",
        "Houndmaster Loksey",
        "Arcanist Doan",
        "Brother Wystan",
    },
    -- Stormwrought Ruins (SwR)
    ["Stormwrought Ruins"] = {
        "Oronok Torn-Heart",
        "Dagar the Glutton",
        "Librarian Theodorus",
        "Duke Balor the IV",
        "Chieftain Stormsong",
        "Deathlord Tidebane",
        "Subjugator Halthas Shadecrest",
        "Mycellakos",
        "Eldermaw the Primordial",
        "Lady Drazare",
        "Ighal'for",
        "Mergothid",
        "Remains of the Innocent",
    },
    -- Gilneas City (GC)
    ["Gilneas City"] = {
        "Matthias Holtz",
        "Packmaster Ragetooth",
        "Judge Sutherland",
        "Dustivan Blackcowl",
        "Marshal Magnus Greystone",
        "Horsemaster Levvin",
        "Regent-Lady Celia Harlow",
        "Regent-Lord Mortimer Harlow",
        "Genn Greymane",
    },
    -- Maraudon (Mara)
    ["Maraudon"] = {
        "The Nameless Prophet",
        "Cursed Centaur",
        "Kolk",
        "Gelk",
        "Magra",
        "Veng",
        "Noxxion",
        "Razorlash",
        "Maraudos",
        "Lord Vyletongue",
        "Meshlok the Harvester",
        "Celebras the Cursed",
        "Landslide",
        "Tinkerer Gizlock",
        "Rotgrip",
        "Princess Theradras",
    },
    -- Uldaman (Ulda)
    ["Uldaman"] = {
        "Baelog",
        "Eric \"The Swift\"",
        "Olaf",
        "Revelosh",
        "Ironaya",
        "Obsidian Sentinel",
        "Ancient Stone Keeper",
        "Galgann Firehammer",
        "Grimlok",
        "Archaedas",
        "Archaedas: Lower",
    },
    -- Zul'Farrak (ZF)
    ["Zul'Farrak"] = {
        "Antu'sul",
        "Theka the Martyr",
        "Witch Doctor Zum'rah",
        "Nekrum Gutchewer",
        "Shadowpriest Sezz'ziz",
        "Dustwraith",
        "Sandfury Executioner",
        "Chief Ukorz Sandscalp",
        "Ruuzlu",
        "Hydromancer Velratha",
        "Gahz'rilla",
        "Zel'jeb the Ancient",
        "Champion Razjal the Quick",
        "Zerillis",
    },
    -- Sunken Temple (ST)
    ["Sunken Temple"] = {
        "Gasher",
        "Loro",
        "Hukku",
        "Zolo",
        "Mijan",
        "Zul'Lor",
        "Atal'alarion",
        "Spawn of Hakkar",
        "Avatar of Hakkar",
        "Jammal'an the Prophet",
        "Ogom the Wretched",
        "Dreamscythe",
        "Weaver",
        "Morphaz",
        "Hazzas",
        "Shade of Eranikus",
    },
    -- Dire Maul (DM)
    ["Dire Maul"] = {
        -- Dire Maul East
        "Pusillin",
        "Zevrim Thornhoof",
        "Hydrospawn",
        "Lethtendris",
        "Pimgib",
        "Alzzin the Wildshaper",
        "Isalien",
        -- Dire Maul North
        "Guard Mol'dar",
        "Stomper Kreeg",
        "Guard Fengus",
        "Guard Slip'kik",
        "Captain Kromcrush",
        "King Gordok",
        "Cho'Rush the Observer",
        -- Dire Maul West
        "Tendris Warpwood",
        "Illyanna Ravenoak",
        "Magister Kalendris",
        "Tsu'zee",
        "Immol'thar",
        "Lord Hel'nurath",
        "Prince Tortheldrin",
        "Revanchion",
    },
    -- Hateforge Quarry (HQ)
    ["Hateforge Quarry"] = {
        "High Foreman Bargul Blackhammer",
        "Engineer Figgles",
        "Corrosis",
        "Hatereaver Annihilator",
        "Har'gesh Doomcaller",
    },
    -- Karazhan Crypt (KC)
    ["Karazhan Crypt"] = {
        "Marrowspike",
        "Hivaxxis",
        "Corpsemuncher",
        "Guard Captain Gort",
        "Archlich Enkhraz",
        "Commander Andreon",
        "Alarus",
    },
    -- Blackrock Depths (BRD)
    ["Blackrock Depths"] = {
        -- Blackrock Mountain (BRM)
        "Overmaster Pyron",
        "Scarshield Quartermaster",
        "The Behemoth",
        -- Blackrock Depths (BRD)
        "Lord Roccor",
        "High Interrogator Gerstahn",
        "Anub'shiah",
        "Eviscerator",
        "Gorosh the Dervish",
        "Grizzle",
        "Hedrum the Creeper",
        "Ok'thor the Breaker",
        "Theldren",
        "Houndmaster Grebmar",
        "Pyromancer Loregrain",
        "Warder Stilgiss",
        "Verek",
        "Watchman Doomgrip",
        "Fineous Darkvire",
        "Lord Incendius",
        "Bael'Gar",
        "General Angerforge",
        "Golem Lord Argelmach",
        "Hurley Blackbreath",
        "Phalanx",
        "Plugger Spazzring",
        "Ribbly Screwspigot",
        "Ambassador Flamelash",
        "Panzor the Invincible",
        "The Lyceum",
        "Magmus",
        "Emperor Dagran Thaurissan",
        "Princess Moira Bronzebeard",
    },
    -- Stratholme (Strat)
    ["Stratholme"] = {
        "Skul",
        "Stratholme Courier",
        "Balzaphon",
        "Hearthsinger Forresten",
        "The Unforgiven",
        "Timmy the Cruel",
        "Malor the Zealous",
        "Crimson Hammersmith",
        "Cannon Master Willey",
        "Archivist Galford",
        "Balnazzar",
        "Sothos",
        "Jarien",
        "Magistrate Barthilas",
        "Stonespine",
        "Baroness Anastari",
        "Black Guard Swordsmith",
        "Nerub'enkan",
        "Maleki the Pallid",
        "Ramstein the Gorger",
        "Baron Rivendare",
        "Postmaster Malown",
        "Atiesh",
    },
    -- Scholomance (Scholo)
    ["Scholomance"] = {
        "Blood Steward of Kirtonos",
        "Kirtonos the Herald",
        "Jandice Barov",
        "Lord Blackwood",
        "Rattlegore",
        "Death Knight Darkreaver",
        "Marduk Blackpool",
        "Vectus",
        "Ras Frostwhisper",
        "Kormok",
        "Instructor Malicia",
        "Doctor Theolen Krastinov",
        "Lorekeeper Polkelt",
        "The Ravenian",
        "Lord Alexei Barov",
        "Lady Illucia Barov",
        "Darkmaster Gandling",
    },
    -- Stormwind Vault (SwV)
    ["Stormwind Vault"] = {
        "Aszosh Grimflame",
        "Tham'Grarr",
        "Black Bride",
        "Damian",
        "Volkan Cruelblade",
    },
    -- Lower Blackrock Spire (LBRS)
    ["Lower Blackrock Spire"] = {
        "Spirestone Butcher",
        "Highlord Omokk",
        "Spirestone Battle Lord",
        "Spirestone Lord Magus",
        "Shadow Hunter Vosh'gajin",
        "War Master Voone",
        "Mor Grayhoof",
        "Bannok Grimaxe",
        "Mother Smolderweb",
        "Crystal Fang",
        "Urok Doomhowl",
        "Quartermaster Zigris",
        "Halycon",
        "Gizrul the Slavener",
        "Ghok Bashguud",
        "Overlord Wyrmthalak",
        "Burning Felguard",
    },
    -- The Black Morass (BM)
    ["The Black Morass"] = {
        "Chronar",
        "Epidamu",
        "Drifting Avatar of Sand",
        "Time-Lord Epochronos",
        "Mossheart",
        "Antnormi",
        "Rotmaw",
    },
    -- Miscellaneous
    ["Miscellaneous"] = {
        -- Alliance Weapon Master's
        "Woo Ping",
        "Bixi Wobblebonk",
        "Buliwyf Stonehand",
        "Ilyenia Moonfire",
        -- Horde Weapon Master's
        "Hanashi",
        "Sayoc",
        "Archibald",
        "Ansekhwa",
    },
}

-- =============================================================================
-- BOSS METADATA
-- =============================================================================
-- Usage:
--   local bossType = T_Lib:GetBossType("Ragnaros")           -- returns "Elemental"
--   local classification = T_Lib:GetBossClassification("Ragnaros") -- returns "Boss"
-- =============================================================================
T_Lib.BossMetadata = {
    -- Raid bosses - Upper Blackrock Spire
    ["Pyroguard Emberseer"] = { type = "Elemental", classification = "Boss" },
    ["Solakar Flamewreath"] = { type = "Dragonkin", classification = "Elite" },
    ["Jed Runewatcher"] = { type = "Humanoid", classification = "Rare Elite" },
    ["Goraluk Anvilcrack"] = { type = "Humanoid", classification = "Rare Elite" },
    ["Warchief Rend Blackhand"] = { type = "Humanoid", classification = "Boss" },
    ["Gyth"] = { type = "Dragon", classification = "Boss" },
    ["The Beast"] = { type = "Beast", classification = "Boss" },
    ["Lord Valthalak"] = { type = "Humanoid", classification = "Boss" },
    ["General Drakkisath"] = { type = "Dragonkin", classification = "Boss" },

    -- Raid bosses - Onyxia's Lair
    ["Onyxia"] = { type = "Dragon", classification = "Boss" },
    ["Broodcommander Axelus"] = { type = "Dragonkin", classification = "Boss" },

    -- Raid bosses - Molten Core
    ["Core Hound"] = { type = "Beast", classification = "Elite" },
    ["Ancient Core Hound"] = { type = "Beast", classification = "Elite" },
    ["Lava Surger"] = { type = "Elemental", classification = "Elite" },
    ["Flame Imp"] = { type = "Elemental", classification = "Elite" },
    ["Incindis"] = { type = "Beast", classification = "Boss" },
    ["Lucifron"] = { type = "Humanoid", classification = "Boss" },
    ["Magmadar"] = { type = "Beast", classification = "Boss" },
    ["Garr"] = { type = "Elemental", classification = "Boss" },
    ["Baron Geddon"] = { type = "Elemental", classification = "Boss" },
    ["Shazzrah"] = { type = "Humanoid", classification = "Boss" },
    ["Golemagg the Incinerator"] = { type = "Giant", classification = "Boss" },
    ["Sulfuron Harbinger"] = { type = "Humanoid", classification = "Boss" },
    ["Majordomo Executus"] = { type = "Humanoid", classification = "Boss" },
    ["Basalthar"] = { type = "Elemental", classification = "Boss" },
    ["Smoldaris"] = { type = "Elemental", classification = "Boss" },
    ["Sorcerer-Thane Thaurissan"] = { type = "Humanoid", classification = "Boss" },
    ["Gehennas"] = { type = "Humanoid", classification = "Boss" },
    ["Ragnaros"] = { type = "Elemental", classification = "Boss" },

    -- Raid bosses - Blackwing Lair
    ["Death Talon Wyrmguard"] = { type = "Dragonkin", classification = "Elite" },
    ["Razorgore the Untamed"] = { type = "Dragonkin", classification = "Boss" },
    ["Vaelastrasz the Corrupt"] = { type = "Dragon", classification = "Boss" },
    ["Broodlord Lashlayer"] = { type = "Dragonkin", classification = "Boss" },
    ["Firemaw"] = { type = "Dragonkin", classification = "Boss" },
    ["Ebonroc"] = { type = "Dragonkin", classification = "Boss" },
    ["Flamegor"] = { type = "Dragonkin", classification = "Boss" },
    ["Chromaggus"] = { type = "Beast", classification = "Boss" },
    ["Nefarian"] = { type = "Dragon", classification = "Boss" },
    ["Ezzel Darkbrewer"] = { type = "Humanoid", classification = "Boss" },

    -- Raid bosses - Lower Karazhan Halls
    ["Phantom Servant"] = { type = "Undead", classification = "Elite" },
    ["Master Blacksmith Rolfen"] = { type = "Humanoid", classification = "Elite" },
    ["Brood Queen Araxxna"] = { type = "Beast", classification = "Boss" },
    ["Grizikil"] = { type = "Humanoid", classification = "Boss" },
    ["Clawlord Howlfang"] = { type = "Beast", classification = "Boss" },
    ["Dark Rider Champion"] = { type = "Undead", classification = "Elite" },
    ["Lord Blackwald II"] = { type = "Undead", classification = "Boss" },
    ["Moroes"] = { type = "Undead", classification = "Boss" },

    -- Raid bosses - Zul'Gurub
    ["Gurubashi Bat Rider"] = { type = "Humanoid", classification = "Elite" },
    ["Gurubashi Berserker"] = { type = "Humanoid", classification = "Elite" },
    ["Mad Servant"] = { type = "Demon", classification = "Elite" },
    ["High Priestess Jeklik"] = { type = "Humanoid", classification = "Boss" },
    ["High Priest Venoxis"] = { type = "Humanoid", classification = "Boss" },
    ["High Priestess Mar'li"] = { type = "Humanoid", classification = "Boss" },
    ["Bloodlord Mandokir"] = { type = "Humanoid", classification = "Boss" },
    ["Gri'lek"] = { type = "Undead", classification = "Boss" },
    ["Hazza'rah"] = { type = "Undead", classification = "Boss" },
    ["Renataki"] = { type = "Undead", classification = "Elite" },
    ["Wushoolay"] = { type = "Undead", classification = "Boss" },
    ["Gahz'ranka"] = { type = "Beast", classification = "Boss" },
    ["High Priest Thekal"] = { type = "Humanoid", classification = "Boss" },
    ["High Priestess Arlokk"] = { type = "Humanoid", classification = "Boss" },
    ["Jin'do the Hexxer"] = { type = "Humanoid", classification = "Boss" },
    ["Hakkar"] = { type = "Loa", classification = "Boss" },

    -- Raid bosses - Emerald Sanctum
    ["Sanctum Dragonkin"] = { type = "Dragonkin", classification = "Elite" },
    ["Sanctum Dreamer"] = { type = "Dragonkin", classification = "Elite" },
    ["Sanctum Supressor"] = { type = "Dragonkin", classification = "Elite" },
    ["Sanctum Wyrm"] = { type = "Dragonkin", classification = "Elite" },
    ["Sanctum Wyrmkin"] = { type = "Dragonkin", classification = "Elite" },
    ["Erennius"] = { type = "Dragon", classification = "Boss" },
    ["Solnius"] = { type = "Dragon", classification = "Boss" },

    -- Raid bosses - Ruins of Ahn'Qiraj
    ["Flesh Hunter"] = { type = "Miscellaneous", classification = "Elite" },
    ["Anubisath Guardian"] = { type = "Giant", classification = "Elite" },
    ["Hive'Zara Soldier"] = { type = "Miscellaneous", classification = "Elite" },
    ["Kurinnaxx"] = { type = "Aberration", classification = "Boss" },
    ["Lieutenant General Andorov"] = { type = "Humanoid", classification = "Elite" },
    ["General Rajaxx"] = { type = "Aberration", classification = "Boss" },
    ["Captain Qeez"] = { type = "Miscellaneous", classification = "Elite" },
    ["Captain Tuubid"] = { type = "Miscellaneous", classification = "Elite" },
    ["Captain Drenn"] = { type = "Miscellaneous", classification = "Elite" },
    ["Captain Xurrem"] = { type = "Miscellaneous", classification = "Elite" },
    ["Major Yeggeth"] = { type = "Miscellaneous", classification = "Elite" },
    ["Major Pakkon"] = { type = "Miscellaneous", classification = "Elite" },
    ["Colonel Zerran"] = { type = "Miscellaneous", classification = "Elite" },
    ["Moam"] = { type = "Elemental", classification = "Boss" },
    ["Buru the Gorger"] = { type = "Aberration", classification = "Boss" },
    ["Ayamiss the Hunter"] = { type = "Aberration", classification = "Boss" },
    ["Ossirian the Unscarred"] = { type = "Giant", classification = "Boss" },

    -- Raid bosses - Ahn'Qiraj
    ["Qiraji Brainwasher"] = { type = "Miscellaneous", classification = "Elite" },
    ["Qiraji Champion"] = { type = "Miscellaneous", classification = "Elite" },
    ["Qiraji Mindslayer"] = { type = "Miscellaneous", classification = "Elite" },
    ["Anubisath Defender"] = { type = "Giant", classification = "Elite" },
    ["Anubisath Sentinel"] = { type = "Giant", classification = "Elite" },
    ["Anubisath Warder"] = { type = "Giant", classification = "Elite" },
    ["The Prophet Skeram"] = { type = "Aberration", classification = "Boss" },
    ["Vem"] = { type = "Aberration", classification = "Boss" },
    ["Lord Kri"] = { type = "Aberration", classification = "Boss" },
    ["Princess Yauj"] = { type = "Aberration", classification = "Boss" },
    ["Battleguard Sartura"] = { type = "Aberration", classification = "Boss" },
    ["Fankriss the Unyielding"] = { type = "Aberration", classification = "Boss" },
    ["Viscidus"] = { type = "Elemental", classification = "Boss" },
    ["Princess Huhuran"] = { type = "Aberration", classification = "Boss" },
    ["Emperor Vek'lor"] = { type = "Aberration", classification = "Boss" },
    ["Emperor Vek'nilash"] = { type = "Aberration", classification = "Boss" },
    ["Ouro"] = { type = "Aberration", classification = "Boss" },
    ["C'Thun"] = { type = "Old God", classification = "Boss" },

    -- Raid bosses - Timbermaw Hold

    -- Raid bosses - Naxxramas
    ["Patchwork Golem"] = { type = "Undead", classification = "Elite" },
    ["Deathknight Captain"] = { type = "Undead", classification = "Elite" },
    ["Deathknight Cavalier"] = { type = "Undead", classification = "Elite" },
    ["Gargoyle"] = { type = "Undead", classification = "Elite" },
    ["Living Monstrosity"] = { type = "Undead", classification = "Elite" },
    ["Venom Stalker"] = { type = "Beast", classification = "Elite" },
    ["Patchwerk"] = { type = "Undead", classification = "Boss" },
    ["Grobbulus"] = { type = "Undead", classification = "Boss" },
    ["Gluth"] = { type = "Undead", classification = "Boss" },
    ["Thaddius"] = { type = "Undead", classification = "Boss" },
    ["Anub'Rekhan"] = { type = "Undead", classification = "Boss" },
    ["Grand Widow Faerlina"] = { type = "Humanoid", classification = "Boss" },
    ["Maexxna"] = { type = "Beast", classification = "Boss" },
    ["Noth the Plaguebringer"] = { type = "Undead", classification = "Boss" },
    ["Heigan the Unclean"] = { type = "Undead", classification = "Boss" },
    ["Loatheb"] = { type = "Undead", classification = "Boss" },
    ["Instructor Razuvious"] = { type = "Undead", classification = "Boss" },
    ["Gothik the Harvester"] = { type = "Undead", classification = "Boss" },
    ["Thane Korth'azz"] = { type = "Undead", classification = "Boss" },
    ["Lady Blaumeux"] = { type = "Undead", classification = "Boss" },
    ["Highlord Mograine"] = { type = "Undead", classification = "Boss" },
    ["Sir Zeliek"] = { type = "Undead", classification = "Boss" },
    ["Sapphiron"] = { type = "Undead", classification = "Boss" },
    ["Kel'Thuzad"] = { type = "Undead", classification = "Boss" },

    -- Raid bosses - Tower of Karazhan
    ["Keeper Gnarlmoon"] = { type = "Beast", classification = "Boss" },
    ["Ley-Watcher Incantagos"] = { type = "Dragonkin", classification = "Boss" },
    ["Anomalus"] = { type = "Void Entity", classification = "Boss" },
    ["Echo of Medivh"] = { type = "Undead", classification = "Boss" },
    ["King"] = { type = "Mechanical", classification = "Boss" },
    ["Sanv Tas'dal"] = { type = "Demon", classification = "Boss" },
    ["Rupturan the Broken"] = { type = "Elemental", classification = "Boss" },
    ["Kruul"] = { type = "Demon", classification = "Boss" },
    ["Mephistroth"] = { type = "Demon", classification = "Boss" },

    -- Raid bosses - World Bosses
    ["Azuregos"] = { type = "Dragon", classification = "Boss" },
    ["Cla'ckora"] = { type = "Beast", classification = "Boss" },
    ["Concavius"] = { type = "Void Entity", classification = "Boss" },
    ["Moo"] = { type = "Humanoid", classification = "Boss" },
    ["Lethon"] = { type = "Dragon", classification = "Boss" },
    ["Emeriss"] = { type = "Dragon", classification = "Boss" },
    ["Taerar"] = { type = "Dragon", classification = "Boss" },
    ["Ysondre"] = { type = "Dragon", classification = "Boss" },
    ["Lord Kazzak"] = { type = "Demon", classification = "Boss" },
    ["Nerubian Overseer"] = { type = "Undead", classification = "Boss" },
    ["Ostarius"] = { type = "Golem", classification = "Boss" },
    ["Dark Reaver of Karazhan"] = { type = "Undead", classification = "Boss" },

    -- Raid bosses - TW Custom Bosses
    ["Avalanchion"] = { type = "Elemental", classification = "Elite" },
    ["The Windreaver"] = { type = "Elemental", classification = "Elite" },
    ["Baron Charr"] = { type = "Elemental", classification = "Elite" },
    ["Princess Tempestria"] = { type = "Elemental", classification = "Elite" },
    ["Doctor Weavil"] = { type = "Humanoid", classification = "Elite" },
    ["Twilight Corrupter"] = { type = "Demon", classification = "Boss" },
    ["Trigore the Lasher"] = { type = "Beast", classification = "Rare Elite" },
    ["Boahn"] = { type = "Humanoid", classification = "Rare" },
    ["Mad Magglish"] = { type = "Humanoid", classification = "Elite" },
    ["Marisa du'Paige"] = { type = "Humanoid", classification = "Elite" },
    ["Brainwashed Noble"] = { type = "Humanoid", classification = "Elite" },
    ["Foreman Thistlenettle"] = { type = "Undead", classification = "Elite" },
    ["Kazkaz the Unholy"] = { type = "Humanoid", classification = "Elite" },
    ["Zekkis"] = { type = "Undead", classification = "Rare Elite" },
    ["Veyzhak the Cannibal"] = { type = "Humanoid", classification = "Rare Elite" },
    ["Magregan Deepshadow"] = { type = "Humanoid", classification = "Elite" },
    ["Techbot"] = { type = "Mechanical", classification = "Elite" },

    -- Add more bosses as needed...
}

-- Raid aliases (short names -> full names)
T_Lib.RaidAliases = {
    -- ========================================================================
    -- RAIDS
    -- ========================================================================
    -- Upper Blackrock Spire (UBRS)
    ["UBRS"] = "Upper Blackrock Spire",
    ["Upper Blackrock Spire"] = "Upper Blackrock Spire",
    -- Onyxia's Lair (Ony)
    ["Ony"] = "Onyxia's Lair",
    ["Onyxia"] = "Onyxia's Lair",
    ["Onyxia's Lair"] = "Onyxia's Lair",
    -- Molten Core (MC)
    ["MC"] = "Molten Core",
    ["Molten Core"] = "Molten Core",
    -- Blackwing Lair (BWL)
    ["BWL"] = "Blackwing Lair",
    ["Blackwing Lair"] = "Blackwing Lair",
    -- Zul'Gurub (ZG)
    ["ZG"] = "Zul'Gurub",
    ["Zul'Gurub"] = "Zul'Gurub",
    -- Emerald Sanctum (ES)
    ["ES"] = "Emerald Sanctum",
    ["EmeraldSanctum"] = "Emerald Sanctum",
    ["Emerald Sanctum"] = "Emerald Sanctum",
    -- Lower Karazhan Halls (LKH)
    ["Kara10"] = "Lower Karazhan Halls",
    ["LKH"] = "Lower Karazhan Halls",
    ["Lower Karazhan Halls"] = "Lower Karazhan Halls",
    -- Ruins of Ahn'Qiraj (AQ20)
    ["AQ20"] = "Ruins of Ahn'Qiraj",
    ["RoA"] = "Ruins of Ahn'Qiraj",
    ["Ruins of Ahn'Qiraj"] = "Ruins of Ahn'Qiraj",
    -- Ahn'Qiraj / Temple of Ahn'Qiraj (AQ40)
    ["AQ40"] = "Ahn'Qiraj",
    ["Ahn'Qiraj"] = "Ahn'Qiraj",
    ["ToA"] = "Ahn'Qiraj",
    ["Temple of Ahn'Qiraj"] = "Ahn'Qiraj",
    -- Timbermaw Hold (TmH)
    ["TmH"] = "Timbermaw Hold",
    ["Timbermaw Hold"] = "Timbermaw Hold",
    -- Naxxramas (Naxx)
    ["Naxx"] = "Naxxramas",
    ["Naxxramas"] = "Naxxramas",
    -- Tower of Karazhan (ToK)
    ["Kara40"] = "Tower of Karazhan",
    ["Karazhan"] = "Tower of Karazhan",
    ["KarazhanUpper"] = "Tower of Karazhan",
    ["ToK"] = "Tower of Karazhan",
    ["TowerofKarazhan"] = "Tower of Karazhan",
    ["Tower of Karazhan"] = "Tower of Karazhan",

    -- ========================================================================
    -- DUNGEONS
    -- ========================================================================
    -- Ragefire Chasm (RFC)
    ["RFC"] = "Ragefire Chasm",
    ["Ragefire Chasm"] = "Ragefire Chasm",
    -- Frostmane Hollow (FH)
    ["FH"] = "Frostmane Hollow",
    ["Frostmane Hollow"] = "Frostmane Hollow",
    -- Deadmines (VC)
    ["VC"] = "Deadmines",
    ["Deadmines"] = "Deadmines",
    -- Wailing Caverns (WC)
    ["WC"] = "Wailing Caverns",
    ["Wailing Caverns"] = "Wailing Caverns",
    -- Shadowfang Keep (SFK)
    ["SFK"] = "Shadowfang Keep",
    ["Shadowfang Keep"] = "Shadowfang Keep",
    -- The Stockade (Stock)
    ["Stockade"] = "The Stockade",
    ["Stock"] = "The Stockade",
    -- Blackfathom Deeps (BFD)
    ["BFD"] = "Blackfathom Deeps",
    ["Blackfathom Deeps"] = "Blackfathom Deeps",
    -- Windhorn Canyon (WhC)
    ["WhC"] = "Windhorn Canyon",
    ["Windhorn Canyon"] = "Windhorn Canyon",
    -- Razorfen Kraul (RFK)
    ["RFK"] = "Razorfen Kraul",
    ["Razorfen Kraul"] = "Razorfen Kraul",
    -- Razorfen Downs (RFD)
    ["RFD"] = "Razorfen Downs",
    ["Razorfen Downs"] = "Razorfen Downs",
    -- Gnomeregan (Gnome)
    ["Gnomeregan"] = "Gnomeregan",
    ["Gnome"] = "Gnomeregan",
    -- The Crescent Grove
    ["The Crescent Grove"] = "The Crescent Grove",
    ["TCG"] = "The Crescent Grove",
    ["Crescent Grove"] = "The Crescent Grove",
    ["Crescent"] = "The Crescent Grove",
    -- Dragonmaw Retreat (DMR)
    ["DmR"] = "Dragonmaw Retreat",
    ["Dragonmaw Retreat"] = "Dragonmaw Retreat",
    ["Dragonmaw"] = "Dragonmaw Retreat",
    -- Scarlet Monastery (SM)
    ["SM"] = "Scarlet Monastery",
    ["SM Armory"] = "Scarlet Monastery",
    ["SM Cathedral"] = "Scarlet Monastery",
    ["SM Graveyard"] = "Scarlet Monastery",
    ["SM Library"] = "Scarlet Monastery",
    ["Scarlet Monastery"] = "Scarlet Monastery",
    -- Stormwrought Ruins
    ["SwR"] = "Stormwrought Ruins",
    ["Stormwrought Ruins"] = "Stormwrought Ruins",
    ["Stormwrought"] = "Stormwrought Ruins",
    ["SW Ruins"] = "Stormwrought Ruins",
    -- Gilneas City (GC)
    ["GC"] = "Gilneas City",
    ["Gilneas City"] = "Gilneas City",
    ["Gilneas"] = "Gilneas City",
    -- Maraudon (Mara)
    ["Maraudon"] = "Maraudon",
    ["Mara"] = "Maraudon",
    -- Uldaman (Ulda)
    ["Uldaman"] = "Uldaman",
    ["Ulda"] = "Uldaman",
    -- Zul'Farrak (ZF)
    ["ZF"] = "Zul'Farrak",
    ["Zul'Farrak"] = "Zul'Farrak",
    -- Sunken Temple (ST)
    ["Sunken Temple"] = "Sunken Temple",
    -- Dire Maul (DM)
    ["DM"] = "Dire Maul",
    ["DME"] = "Dire Maul",
    ["DMN"] = "Dire Maul",
    ["DMW"] = "Dire Maul",
    ["DireMaul"] = "Dire Maul",
    ["Dire Maul"] = "Dire Maul",
    -- Hateforge Quarry (HQ)
    ["HQ"] = "Hateforge Quarry",
    ["Hateforge Quarry"] = "Hateforge Quarry",
    -- Karazhan Crypt (KC)
    ["KC"] = "Karazhan Crypt",
    ["Kara Crypt"] = "Karazhan Crypt",
    ["Karazhan Crypt"] = "Karazhan Crypt",
    -- Blackrock Depths (BRD)
    ["BRD"] = "Blackrock Depths",
    ["Blackrock Depths"] = "Blackrock Depths",
    -- Stratholme (Strat)
    ["Stratholme"] = "Stratholme",
    ["Strat Live"] = "Stratholme",
    ["Strat UD"] = "Stratholme",
    -- Scholomance (Scholo)
    ["Scholomance"] = "Scholomance",
    ["Scholo"] = "Scholomance",
    -- Stormwind Vault (SwV)
    ["SwV"] = "Stormwind Vault",
    ["SV"] = "Stormwind Vault",
    ["Stormwind Vault"] = "Stormwind Vault",
    ["Storm Vault"] = "Stormwind Vault",
    -- Lower Blackrock Spire (LBRS)
    ["LBRS"] = "Lower Blackrock Spire",
    ["Lower Blackrock Spire"] = "Lower Blackrock Spire",
    -- The Black Morass (BM)
    ["BM"] = "The Black Morass",
    ["BlackMorass"] = "The Black Morass",
    ["The Black Morass"] = "The Black Morass",

    -- ========================================================================
    -- WORLD BOSSES
    -- ========================================================================
    -- World Bosses
    ["World Bosses"] = "World Bosses",
    ["Azshara"] = "World Bosses",
    ["Desolace"] = "World Bosses",
    ["Deadwind Pass"] = "World Bosses",
    ["Dustwallow Marsh"] = "World Bosses",
    ["Ashenvale"] = "World Bosses",
    ["Blasted Lands"] = "World Bosses",
    ["Eastern Plaguelands"] = "World Bosses",
    ["Tanaris"] = "World Bosses",
    ["Duskwood"] = "World Bosses",

    -- TW Custom Bosses
    ["TWCustom"] = "TW Custom Bosses",
    ["TW Custom Bosses"] = "TW Custom Bosses",

    -- Miscellaneous
    ["Other"] = "Other",
    ["Miscellaneous"] = "Miscellaneous",
}

-- Reverse mapping: boss -> raid
T_Lib.BossToRaid = {}

-- Ensure boss data is initialized
function T_Lib:EnsureBossDataInitialized()
    if not self.BossToRaid or next(self.BossToRaid) == nil then
        self:InitializeBossData()
    end
end

-- Initialize reverse mapping
function T_Lib:InitializeBossData()
    for raidName, bosses in pairs(self.Raids) do
        for _, bossName in ipairs(bosses) do
            self.BossToRaid[bossName] = raidName
        end
    end
end

-- Get exact boss name (check if exists)
function T_Lib:GetBossName(bossName)
    self:EnsureBossDataInitialized()
    if self.BossToRaid[bossName] then
        return bossName
    end
    return nil
end

-- Get full raid name by alias or short name
function T_Lib:GetRaidName(raidAlias)
    self:EnsureBossDataInitialized()
    return self.RaidAliases[raidAlias]
end

-- Get raid name by boss name
function T_Lib:GetRaidByBoss(bossName)
    self:EnsureBossDataInitialized()
    return self.BossToRaid[bossName]
end

-- Check if name is a boss
function T_Lib:IsBoss(name)
    self:EnsureBossDataInitialized()
    return self.BossToRaid[name] ~= nil
end

-- Get boss type (Elemental, Dragon, Demon, Undead, etc.)
function T_Lib:GetBossType(bossName)
    self:EnsureBossDataInitialized()
    if self.BossMetadata and self.BossMetadata[bossName] then
        return self.BossMetadata[bossName].type or "Unknown"
    end
    return "Unknown"
end

-- Get boss classification (Elite, Rare Elite, Boss)
function T_Lib:GetBossClassification(bossName)
    self:EnsureBossDataInitialized()
    if self.BossMetadata and self.BossMetadata[bossName] then
        return self.BossMetadata[bossName].classification or "Elite"
    end
    return "Elite"
end

-- Check if name is a raid (or raid alias)
function T_Lib:IsRaid(name)
    self:EnsureBossDataInitialized()
    return self.RaidAliases[name] ~= nil
end

-- Get all bosses in a raid by name or alias
function T_Lib:GetBossesByRaid(raidAlias)
    self:EnsureBossDataInitialized()
    local raidName = self.RaidAliases[raidAlias] or raidAlias
    return self.Raids[raidName] or {}
end

-- Get boss count in a raid
function T_Lib:GetBossCount(raidAlias)
    self:EnsureBossDataInitialized()
    local bosses = self:GetBossesByRaid(raidAlias)
    return table.getn(bosses)
end

-- Get all raid names
function T_Lib:GetAllRaids()
    self:EnsureBossDataInitialized()
    local raids = {}
    for raidName, _ in pairs(self.Raids) do
        table.insert(raids, raidName)
    end
    return raids
end

-- Get all raid aliases
function T_Lib:GetAllRaidAliases()
    self:EnsureBossDataInitialized()
    local aliases = {}
    for alias, _ in pairs(self.RaidAliases) do
        table.insert(aliases, alias)
    end
    return aliases
end

-- Case-insensitive boss name comparison
function T_Lib:CompareBossName(inputName, bossName)
    self:EnsureBossDataInitialized()
    if not inputName or not bossName then
        return false
    end
    return string.lower(inputName) == string.lower(bossName)
end

-- Find boss by partial name match
function T_Lib:FindBoss(partialName)
    self:EnsureBossDataInitialized()
    if not partialName then
        return nil
    end
    local lowerInput = string.lower(partialName)
    for bossName, _ in pairs(self.BossToRaid) do
        if string.find(string.lower(bossName), lowerInput, 1, true) then
            return bossName
        end
    end
    return nil
end

-- Find raid by partial name match
function T_Lib:FindRaid(partialName)
    self:EnsureBossDataInitialized()
    if not partialName then
        return nil
    end
    local lowerInput = string.lower(partialName)
    for raidName, _ in pairs(self.Raids) do
        if string.find(string.lower(raidName), lowerInput, 1, true) then
            return raidName
        end
    end
    return nil
end

-- Initialize on load
if T_Lib and T_Lib.InitializeBossData then
    T_Lib:InitializeBossData()
end
