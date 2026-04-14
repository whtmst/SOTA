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
--   T_Lib:GetBossNPCID(bossName)        -- get boss NPC ID by name
--   T_Lib:GetBossNameByID(npcId)        -- get boss name by NPC ID (reverse lookup)
--   T_Lib:GetTrashByRaid(raid)          -- get trash mobs of a raid
--   T_Lib:GetRaidType(raid)             -- get instance type (Raid, Dungeon)
--   T_Lib:GetNPCsByRaid(raid)           -- get NPCs of a raid (trainers, vendors, etc.)
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
        Type = "Raid",
        Bosses = {
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
    },
    -- Onyxia's Lair (Ony)
    ["Onyxia's Lair"] = {
        Type = "Raid",
        Bosses = {
            "Onyxia",
            "Broodcommander Axelus",
        },
    },
    -- Molten Core (MC)
    ["Molten Core"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Core Hound",
            "Ancient Core Hound",
            "Lava Surger",
            "Flame Imp",
        },
    },
    -- Blackwing Lair (BWL)
    ["Blackwing Lair"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Death Talon Wyrmguard",
        },
    },
    -- Lower Karazhan Halls (LKH)
    ["Lower Karazhan Halls"] = {
        Type = "Raid",
        Bosses = {
            "Brood Queen Araxxna",
            "Grizikil",
            "Clawlord Howlfang",
            "Dark Rider Champion",
            "Lord Blackwald II",
            "Moroes",
        },
        Trash = {
            "Phantom Servant",
            "Master Blacksmith Rolfen",
        },
    },
    -- Zul'Gurub (ZG)
    ["Zul'Gurub"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Gurubashi Bat Rider",
            "Gurubashi Berserker",
            "Mad Servant",
        },
    },
    -- Emerald Sanctum (ES)
    ["Emerald Sanctum"] = {
        Type = "Raid",
        Bosses = {
            "Erennius",
            "Solnius",
        },
        Trash = {
            "Sanctum Dragonkin",
            "Sanctum Dreamer",
            "Sanctum Supressor",
            "Sanctum Wyrm",
            "Sanctum Wyrmkin",
        },
    },
    -- Ruins of Ahn'Qiraj (AQ20)
    ["Ruins of Ahn'Qiraj"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Flesh Hunter",
            "Anubisath Guardian",
            "Hive'Zara Soldier",
        },
    },
    -- Ahn'Qiraj / Temple of Ahn'Qiraj (AQ40)
    ["Ahn'Qiraj"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Qiraji Brainwasher",
            "Qiraji Champion",
            "Qiraji Mindslayer",
            "Anubisath Defender",
            "Anubisath Sentinel",
            "Anubisath Warder",
        },
    },
    -- Timbermaw Hold (TmH)
    ["Timbermaw Hold"] = {
        Type = "Raid",
        Bosses = {
            "Peroth'arn",
            "Karrsh the Sentinel",
            "Rotgrowl",
            "Chieftain Partath",
            "Trioch the Devourer",
            "Selenaxx Foulheart",
            "Ormanos the Cracked",
            "Loktanag the Vile",
            "Archdruid Kronn",
            "Ursol",
        },
    },
    -- Naxxramas (Naxx)
    ["Naxxramas"] = {
        Type = "Raid",
        Bosses = {
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
        Trash = {
            "Patchwork Golem",
            "Deathknight Captain",
            "Deathknight Cavalier",
            "Plagued Gargoyle",
            "Stoneskin Gargoyle",
            "Living Monstrosity",
            "Venom Stalker",
        },
    },
    -- Tower of Karazhan (ToK)
    ["Tower of Karazhan"] = {
        Type = "Raid",
        Bosses = {
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
    },
    -- World Bosses
    ["World Bosses"] = {
        Type = "World Bosses",
        Bosses = {
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
    },
    -- TW Custom Bosses (Turtle WoW unique bosses)
    ["TW Custom Bosses"] = {
        Type = "Turtle WoW Custom Bosses",
        Bosses = {
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
    },
    -- ========================================================================
    -- DUNGEONS
    -- ========================================================================

    -- Ragefire Chasm (RFC)
    ["Ragefire Chasm"] = {
        Type = "Dungeon",
        Bosses = {
            "Oggleflint",
            "Taragaman the Hungerer",
            "Jergosh the Invoker",
            "Bazzalan",
        },
    },
    -- Frostmane Hollow (FH)
    ["Frostmane Hollow"] = {
        Type = "Dungeon",
        Bosses = {
            "Tan'sha The Sleek",
            "Battlemaster Ubukaz",
            "Kan'za The Seer",
            "Hailar The Frigid",
        },
    },
    -- Deadmines (VC)
    ["Deadmines"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Wailing Caverns (WC)
    ["Wailing Caverns"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Shadowfang Keep (SFK)
    ["Shadowfang Keep"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- The Stockade (Stock)
    ["The Stockade"] = {
        Type = "Dungeon",
        Bosses = {
            "Targorr the Dread",
            "Kam Deepfury",
            "Hamhock",
            "Bazil Thredd",
            "Dextren Ward",
            "Bruegal Ironknuckle",
        },
    },
    -- Blackfathom Deeps (BFD)
    ["Blackfathom Deeps"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Windhorn Canyon (WhC)
    ["Windhorn Canyon"] = {
        Type = "Dungeon",
        Bosses = {
            "Pathun Duskhide",
            "Ahgk'tos the Pure",
            "Ambassador Vortalus",
            "Walgan Bloodcaller",
            "Bonespeaker Narlgom",
            "Prophet Stormhoof",
            "Chieftain Shalk Blackwind",
        },
    },
    -- Razorfen Kraul (RFK)
    ["Razorfen Kraul"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Razorfen Downs (RFD)
    ["Razorfen Downs"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Gnomeregan (Gnome)
    ["Gnomeregan"] = {
        Type = "Dungeon",
        Bosses = {
            "Grubbis",
            "Chomper",
            "Viscous Fallout",
            "Electrocutioner 6000",
            "Crowd Pummeler 9-60",
            "Dark Iron Ambassador",
            "Mekgineer Thermaplugg",
        },
    },
    -- The Crescent Grove (TCG)
    ["The Crescent Grove"] = {
        Type = "Dungeon",
        Bosses = {
            "Grovetender Engryss",
            "Elder Blackmaw",
            "Elder \"One Eye\"",
            "Keeper Ranathos",
            "High Priestess A'lathea",
            "Fenektis the Deceiver",
            "Master Raxxieth",
        },
    },
    -- Dragonmaw Retreat (DMR)
    ["Dragonmaw Retreat"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Scarlet Monastery (SM)
    ["Scarlet Monastery"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Stormwrought Ruins (SwR)
    ["Stormwrought Ruins"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Gilneas City (GC)
    ["Gilneas City"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Maraudon (Mara)
    ["Maraudon"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Uldaman (Ulda)
    ["Uldaman"] = {
        Type = "Dungeon",
        Bosses = {
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
        },
    },
    -- Zul'Farrak (ZF)
    ["Zul'Farrak"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Sunken Temple (ST)
    ["Sunken Temple"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Dire Maul (DM)
    ["Dire Maul"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Hateforge Quarry (HQ)
    ["Hateforge Quarry"] = {
        Type = "Dungeon",
        Bosses = {
            "High Foreman Bargul Blackhammer",
            "Engineer Figgles",
            "Corrosis",
            "Hatereaver Annihilator",
            "Har'gesh Doomcaller",
        },
    },
    -- Karazhan Crypt (KC)
    ["Karazhan Crypt"] = {
        Type = "Dungeon",
        Bosses = {
            "Marrowspike",
            "Hivaxxis",
            "Corpsemuncher",
            "Guard Captain Gort",
            "Archlich Enkhraz",
            "Commander Andreon",
            "Alarus",
        },
    },
    -- Blackrock Depths (BRD)
    ["Blackrock Depths"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Stratholme (Strat)
    ["Stratholme"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Scholomance (Scholo)
    ["Scholomance"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- Stormwind Vault (SwV)
    ["Stormwind Vault"] = {
        Type = "Dungeon",
        Bosses = {
            "Aszosh Grimflame",
            "Tham'Grarr",
            "Black Bride",
            "Damian",
            "Volkan Cruelblade",
        },
    },
    -- Lower Blackrock Spire (LBRS)
    ["Lower Blackrock Spire"] = {
        Type = "Dungeon",
        Bosses = {
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
    },
    -- The Black Morass (BM)
    ["The Black Morass"] = {
        Type = "Dungeon",
        Bosses = {
            "Chronar",
            "Epidamu",
            "Drifting Avatar of Sand",
            "Time-Lord Epochronos",
            "Mossheart",
            "Antnormi",
            "Rotmaw",
        },
    },
    -- Miscellaneous
    ["Miscellaneous"] = {
        Type = "Miscellaneous",
        NPCs = {
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
    },
}

-- =============================================================================
-- BOSS NPC IDs
-- =============================================================================
-- Maps boss names (enUS) to their NPC IDs.
-- Used for: unit targeting, tooltip scanning, localization by ID.
--
-- Usage:
--   local npcId = T_Lib:GetBossNPCID("Ragnaros")    -- returns number or nil
--   local name  = T_Lib:GetBossNameByID(11502)      -- returns string or nil
-- =============================================================================
T_Lib.BossIDs = {
    -- Upper Blackrock Spire
    ["Pyroguard Emberseer"] = 9816,
    ["Solakar Flamewreath"] = 10264,
    ["Jed Runewatcher"] = 10509,
    ["Goraluk Anvilcrack"] = 10899,
    ["Warchief Rend Blackhand"] = 10429,
    ["Gyth"] = 10339,
    ["The Beast"] = 10430,
    ["Lord Valthalak"] = 16042,
    ["General Drakkisath"] = 10363,

    -- Onyxia's Lair
    ["Onyxia"] = 10184,
    ["Broodcommander Axelus"] = 49018,

    -- Molten Core
    ["Core Hound"] = 11671,
    ["Ancient Core Hound"] = 11673,
    ["Lava Surger"] = 12101,
    ["Flame Imp"] = 11669,
    ["Incindis"] = 52145,
    ["Lucifron"] = 12118,
    ["Magmadar"] = 11982,
    ["Garr"] = 12057,
    ["Baron Geddon"] = 12056,
    ["Shazzrah"] = 12264,
    ["Golemagg the Incinerator"] = 11988,
    ["Sulfuron Harbinger"] = 12098,
    ["Majordomo Executus"] = 12018,
    ["Basalthar"] = 65020,
    ["Smoldaris"] = 65021,
    ["Sorcerer-Thane Thaurissan"] = 57642,
    ["Gehennas"] = 12259,
    ["Ragnaros"] = 11502,

    -- Blackwing Lair
    ["Death Talon Wyrmguard"] = 12460,
    ["Razorgore the Untamed"] = 12435,
    ["Vaelastrasz the Corrupt"] = 13020,
    ["Broodlord Lashlayer"] = 12017,
    ["Firemaw"] = 11983,
    ["Ebonroc"] = 14601,
    ["Flamegor"] = 11981,
    ["Chromaggus"] = 14020,
    ["Nefarian"] = 11583,
    ["Ezzel Darkbrewer"] = 65148,

    -- Lower Karazhan Halls
    ["Phantom Servant"] = 61205,
    ["Master Blacksmith Rolfen"] = 61319,
    ["Brood Queen Araxxna"] = 61221,
    ["Grizikil"] = 61224,
    ["Clawlord Howlfang"] = 61223,
    ["Dark Rider Champion"] = 61204,
    ["Lord Blackwald II"] = 61222,
    ["Moroes"] = 61225,

    -- Zul'Gurub
    ["Gurubashi Bat Rider"] = 14750,
    ["Gurubashi Berserker"] = 11352,
    ["Mad Servant"] = 15111,
    ["High Priestess Jeklik"] = 14517,
    ["High Priest Venoxis"] = 14507,
    ["High Priestess Mar'li"] = 14510,
    ["Bloodlord Mandokir"] = 11382,
    ["Gri'lek"] = 15082,
    ["Hazza'rah"] = 15083,
    ["Renataki"] = 15084,
    ["Wushoolay"] = 15085,
    ["Gahz'ranka"] = 15114,
    ["High Priest Thekal"] = 14509,
    ["High Priestess Arlokk"] = 14515,
    ["Jin'do the Hexxer"] = 11380,
    ["Hakkar"] = 14834,

    -- Emerald Sanctum
    ["Sanctum Dragonkin"] = 60743,
    ["Sanctum Dreamer"] = 60742,
    ["Sanctum Supressor"] = 61212,
    ["Sanctum Wyrm"] = 60744,
    ["Sanctum Wyrmkin"] = 60745,
    ["Erennius"] = 60747,
    ["Solnius"] = 60748,

    -- Ruins of Ahn'Qiraj
    ["Flesh Hunter"] = 15335,
    ["Anubisath Guardian"] = 15355,
    ["Hive'Zara Soldier"] = 15320,
    ["Kurinnaxx"] = 15348,
    ["Lieutenant General Andorov"] = 15471,
    ["General Rajaxx"] = 15341,
    ["Captain Qeez"] = 15391,
    ["Captain Tuubid"] = 15392,
    ["Captain Drenn"] = 15389,
    ["Captain Xurrem"] = 15390,
    ["Major Yeggeth"] = 15386,
    ["Major Pakkon"] = 15388,
    ["Colonel Zerran"] = 15385,
    ["Moam"] = 15340,
    ["Buru the Gorger"] = 15370,
    ["Ayamiss the Hunter"] = 15369,
    ["Ossirian the Unscarred"] = 15339,

    -- Ahn'Qiraj
    ["Qiraji Brainwasher"] = 15247,
    ["Qiraji Champion"] = 15252,
    ["Qiraji Mindslayer"] = 15246,
    ["Anubisath Defender"] = 15277,
    ["Anubisath Sentinel"] = 15264,
    ["Anubisath Warder"] = 15311,
    ["The Prophet Skeram"] = 15263,
    ["Vem"] = 15544,
    ["Lord Kri"] = 15511,
    ["Princess Yauj"] = 15543,
    ["Battleguard Sartura"] = 15516,
    ["Fankriss the Unyielding"] = 15510,
    ["Viscidus"] = 15299,
    ["Princess Huhuran"] = 15509,
    ["Emperor Vek'lor"] = 15276,
    ["Emperor Vek'nilash"] = 15275,
    ["Ouro"] = 15517,
    ["C'Thun"] = 15727,

    -- Timbermaw Hold
    ["Peroth'arn"] = 60686,
    ["Karrsh the Sentinel"] = 62934,
    ["Rotgrowl"] = 62936,
    ["Chieftain Partath"] = 62941,
    ["Trioch the Devourer"] = 62946,
    ["Selenaxx Foulheart"] = 62940,
    ["Ormanos the Cracked"] = 62935,
    ["Loktanag the Vile"] = 2139,
    ["Archdruid Kronn"] = 62938,
    ["Ursol"] = 62947,

    -- Naxxramas
    ["Patchwork Golem"] = 16017,
    ["Deathknight Captain"] = 16145,
    ["Deathknight Cavalier"] = 16163,
    ["Plagued Gargoyle"] = 16446,
    ["Stoneskin Gargoyle"] = 16168,
    ["Living Monstrosity"] = 16021,
    ["Venom Stalker"] = 15976,
    ["Patchwerk"] = 16028,
    ["Grobbulus"] = 15931,
    ["Gluth"] = 15932,
    ["Thaddius"] = 15928,
    ["Anub'Rekhan"] = 15956,
    ["Grand Widow Faerlina"] = 15953,
    ["Maexxna"] = 15952,
    ["Noth the Plaguebringer"] = 15954,
    ["Heigan the Unclean"] = 15936,
    ["Loatheb"] = 16011,
    ["Instructor Razuvious"] = 16061,
    ["Gothik the Harvester"] = 16060,
    ["Thane Korth'azz"] = 16064,
    ["Lady Blaumeux"] = 16065,
    ["Highlord Mograine"] = 16062,
    ["Sir Zeliek"] = 16063,
    ["Sapphiron"] = 15989,
    ["Kel'Thuzad"] = 15990,

    -- Tower of Karazhan
    ["Keeper Gnarlmoon"] = 61939,
    ["Ley-Watcher Incantagos"] = 61946,
    ["Anomalus"] = 61951,
    ["Echo of Medivh"] = 61958,
    ["King"] = 59967,
    ["Sanv Tas'dal"] = 59981,
    ["Rupturan the Broken"] = 59961,
    ["Kruul"] = 59991,
    ["Mephistroth"] = 93333,

    -- World Bosses
    ["Azuregos"] = 6109,
    ["Cla'ckora"] = 59963,
    ["Concavius"] = 92213,
    ["Moo"] = 91799,
    ["Lethon"] = 14888,
    ["Emeriss"] = 14889,
    ["Taerar"] = 14890,
    ["Ysondre"] = 14887,
    ["Lord Kazzak"] = 12397,
    ["Nerubian Overseer"] = 16184,
    ["Ostarius"] = 80935,
    ["Dark Reaver of Karazhan"] = 80936,

    -- TW Custom Bosses
    ["Avalanchion"] = 14464,
    ["The Windreaver"] = 14454,
    ["Baron Charr"] = 14461,
    ["Princess Tempestria"] = 14457,
    ["Doctor Weavil"] = 15552,
    ["Twilight Corrupter"] = 15625,
    ["Trigore the Lasher"] = 3652,
    ["Boahn"] = 3672,
    ["Mad Magglish"] = 3655,
    ["Marisa du'Paige"] = 599,
    ["Brainwashed Noble"] = 596,
    ["Foreman Thistlenettle"] = 626,
    ["Kazkaz the Unholy"] = 5401,
    ["Zekkis"] = 5400,
    ["Veyzhak the Cannibal"] = 5399,
    ["Magregan Deepshadow"] = 2932,
    ["Techbot"] = 6231,

    -- Ragefire Chasm
    ["Oggleflint"] = 11517,
    ["Taragaman the Hungerer"] = 11520,
    ["Jergosh the Invoker"] = 11518,
    ["Bazzalan"] = 11519,

    -- Frostmane Hollow
    ["Tan'sha The Sleek"] = 63133,
    ["Battlemaster Ubukaz"] = 63131,
    ["Kan'za The Seer"] = 63129,
    ["Hailar The Frigid"] = 63130,

    -- Deadmines
    ["Jared Voss"] = 61961,
    ["Rhahk'Zor"] = 644,
    ["Miner Johnson"] = 3586,
    ["Sneed"] = 643,
    ["Sneed's Shredder"] = 642,
    ["Gilnid"] = 1763,
    ["Masterpiece Harvester"] = 61963,
    ["Mr. Smite"] = 646,
    ["Cookie"] = 645,
    ["Captain Greenskin"] = 647,
    ["Edwin VanCleef"] = 639,

    -- Wailing Caverns
    ["Lord Cobrahn"] = 3669,
    ["Lady Anacondra"] = 3671,
    ["Kresh"] = 3653,
    ["Deviate Faerie Dragon"] = 5912,
    ["Zandara Windhoof"] = 61968,
    ["Lord Pythas"] = 3670,
    ["Skum"] = 3674,
    ["Vangros"] = 61965,
    ["Lord Serpentis"] = 3673,
    ["Verdan the Everliving"] = 5775,
    ["Mutanus the Devourer"] = 3654,

    -- Shadowfang Keep
    ["Rethilgore"] = 3914,
    ["Fel Steed"] = 3864,
    ["Razorclaw the Butcher"] = 3886,
    ["Baron Silverlaine"] = 3887,
    ["Commander Springvale"] = 4278,
    ["Sever"] = 14682,
    ["Odo the Blindwatcher"] = 4279,
    ["Deathsworn Captain"] = 3872,
    ["Fenrus the Devourer"] = 4274,
    ["Arugal's Voidwalker"] = 4627,
    ["Wolf Master Nandos"] = 3927,
    ["Archmage Arugal"] = 4275,
    ["Prelate Ironmane"] = 61969,

    -- The Stockade
    ["Targorr the Dread"] = 1696,
    ["Kam Deepfury"] = 1666,
    ["Hamhock"] = 1717,
    ["Bazil Thredd"] = 1716,
    ["Dextren Ward"] = 1663,
    ["Bruegal Ironknuckle"] = 1720,

    -- Blackfathom Deeps
    ["Ghamoo-ra"] = 4887,
    ["Lady Sarevess"] = 4831,
    ["Gelihast"] = 6243,
    ["Lorgus Jett"] = 12902,
    ["Velthelaxx the Defiler"] = 62530,
    ["Baron Aquanis"] = 12876,
    ["Twilight Lord Kelris"] = 4832,
    ["Old Serra'kis"] = 4830,
    ["Aku'mai"] = 4829,

    -- Windhorn Canyon
    ["Pathun Duskhide"] = 62779,
    ["Ahgk'tos the Pure"] = 62778,
    ["Ambassador Vortalus"] = 62783,
    ["Walgan Bloodcaller"] = 62784,
    ["Bonespeaker Narlgom"] = 62780,
    ["Prophet Stormhoof"] = 62781,
    ["Chieftain Shalk Blackwind"] = 62782,

    -- Razorfen Kraul
    ["Roogug"] = 6168,
    ["Aggem Thorncurse"] = 4424,
    ["Death Speaker Jargba"] = 4428,
    ["Overlord Ramtusk"] = 4420,
    ["Razorfen Spearhide"] = 4438,
    ["Rotthorn"] = 62503,
    ["Agathelos the Raging"] = 4422,
    ["Blind Hunter"] = 4425,
    ["Charlga Razorflank"] = 4421,
    ["Earthcaller Halmgar"] = 4842,

    -- Razorfen Downs
    ["Tuten'kash"] = 7355,
    ["Henry Stern"] = 8696,
    ["Lady Falther'ess"] = 14686,
    ["Plaguemaw the Rotting"] = 7356,
    ["Mordresh Fire Eye"] = 7357,
    ["Glutton"] = 8567,
    ["Death Prophet Rakameg"] = 62679,
    ["Ragglesnout"] = 7354,
    ["Amnennar the Coldbringer"] = 7358,

    -- Gnomeregan
    ["Grubbis"] = 7361,
    ["Chomper"] = 6215,
    ["Viscous Fallout"] = 7079,
    ["Electrocutioner 6000"] = 6235,
    ["Crowd Pummeler 9-60"] = 6229,
    ["Dark Iron Ambassador"] = 6228,
    ["Mekgineer Thermaplugg"] = 7800,

    -- The Crescent Grove
    ["Grovetender Engryss"] = 92107,
    ["Elder Blackmaw"] = 92106,
    ["Elder \"One Eye\""] = 92105,
    ["Keeper Ranathos"] = 92109,
    ["High Priestess A'lathea"] = 92108,
    ["Fenektis the Deceiver"] = 92111,
    ["Master Raxxieth"] = 92110,

    -- Dragonmaw Retreat
    ["Gowlfang"] = 62057,
    ["Bogpaw Truthsay"] = 62056,
    ["Cavernweb Broodmother"] = 62066,
    ["Web Master Torkon"] = 62067,
    ["Garlok Flamekeeper"] = 62071,
    ["Halgan Redbrand"] = 62069,
    ["Slagfist Destroyer"] = 62068,
    ["Overlord Blackheart"] = 62070,
    ["Elder Hollowblood"] = 62038,
    ["Searistrasz"] = 62072,
    ["Zuluhed the Whacked"] = 62037,

    -- Scarlet Monastery
    ["Herod"] = 3975,
    ["Armory Quartermaster Daghelm"] = 61982,
    ["High Inquisitor Fairbanks"] = 4542,
    ["Scarlet Commander Mograine"] = 3976,
    ["High Inquisitor Whitemane"] = 3977,
    ["Interrogator Vishas"] = 3983,
    ["Scorn"] = 14693,
    ["Bloodmage Thalnos"] = 4543,
    ["Ironspine"] = 6489,
    ["Azshir the Sleepless"] = 6490,
    ["Fallen Champion"] = 6488,
    ["Duke Dreadmoore"] = 61972,
    ["Houndmaster Loksey"] = 3974,
    ["Arcanist Doan"] = 6487,
    ["Brother Wystan"] = 61983,

    -- Stormwrought Ruins
    ["Oronok Torn-Heart"] = 62548,
    ["Dagar the Glutton"] = 62547,
    ["Librarian Theodorus"] = 62552,
    ["Duke Balor the IV"] = 62549,
    ["Chieftain Stormsong"] = 62551,
    ["Deathlord Tidebane"] = 62550,
    ["Subjugator Halthas Shadecrest"] = 62652,
    ["Mycellakos"] = 62664,
    ["Eldermaw the Primordial"] = 62661,
    ["Lady Drazare"] = 62665,
    ["Ighal'for"] = 62671,
    ["Mergothid"] = 62673,
    ["Remains of the Innocent"] = 62670,

    -- Gilneas City
    ["Matthias Holtz"] = 61419,
    ["Packmaster Ragetooth"] = 61420,
    ["Judge Sutherland"] = 61421,
    ["Dustivan Blackcowl"] = 61422,
    ["Marshal Magnus Greystone"] = 61423,
    ["Horsemaster Levvin"] = 61605,
    ["Regent-Lady Celia Harlow"] = 61263,
    ["Regent-Lord Mortimer Harlow"] = 61264,
    ["Genn Greymane"] = 61418,

    -- Maraudon
    ["The Nameless Prophet"] = 13718,
    ["Cursed Centaur"] = 11688,
    ["Kolk"] = 13742,
    ["Gelk"] = 13741,
    ["Magra"] = 13740,
    ["Veng"] = 13738,
    ["Noxxion"] = 13282,
    ["Razorlash"] = 12258,
    ["Maraudos"] = 13739,
    ["Lord Vyletongue"] = 12236,
    ["Meshlok the Harvester"] = 12237,
    ["Celebras the Cursed"] = 12225,
    ["Landslide"] = 12203,
    ["Tinkerer Gizlock"] = 13601,
    ["Rotgrip"] = 13596,
    ["Princess Theradras"] = 12201,

    -- Uldaman
    ["Baelog"] = 6906,
    ["Eric \"The Swift\""] = 6907,
    ["Olaf"] = 6908,
    ["Revelosh"] = 6910,
    ["Ironaya"] = 7228,
    ["Obsidian Sentinel"] = 7023,
    ["Ancient Stone Keeper"] = 7206,
    ["Galgann Firehammer"] = 7291,
    ["Grimlok"] = 4854,
    ["Archaedas"] = 2748,

    -- Zul'Farrak
    ["Antu'sul"] = 8127,
    ["Theka the Martyr"] = 7272,
    ["Witch Doctor Zum'rah"] = 7271,
    ["Nekrum Gutchewer"] = 7796,
    ["Shadowpriest Sezz'ziz"] = 7275,
    ["Dustwraith"] = 10081,
    ["Sandfury Executioner"] = 7274,
    ["Chief Ukorz Sandscalp"] = 7267,
    ["Ruuzlu"] = 7797,
    ["Hydromancer Velratha"] = 7795,
    ["Gahz'rilla"] = 7273,
    ["Zel'jeb the Ancient"] = 62495,
    ["Champion Razjal the Quick"] = 62498,
    ["Zerillis"] = 10082,

    -- Sunken Temple
    ["Gasher"] = 5713,
    ["Loro"] = 5714,
    ["Hukku"] = 5715,
    ["Zolo"] = 5712,
    ["Mijan"] = 5717,
    ["Zul'Lor"] = 5716,
    ["Atal'alarion"] = 8580,
    ["Spawn of Hakkar"] = 5708,
    ["Avatar of Hakkar"] = 8443,
    ["Jammal'an the Prophet"] = 5710,
    ["Ogom the Wretched"] = 5711,
    ["Dreamscythe"] = 5721,
    ["Weaver"] = 5720,
    ["Morphaz"] = 5719,
    ["Hazzas"] = 5722,
    ["Shade of Eranikus"] = 5709,

    -- Dire Maul
    ["Pusillin"] = 14354,
    ["Zevrim Thornhoof"] = 11490,
    ["Hydrospawn"] = 13280,
    ["Lethtendris"] = 14327,
    ["Pimgib"] = 14349,
    ["Alzzin the Wildshaper"] = 11492,
    ["Isalien"] = 16097,
    ["Guard Mol'dar"] = 14326,
    ["Stomper Kreeg"] = 14322,
    ["Guard Fengus"] = 14321,
    ["Guard Slip'kik"] = 14323,
    ["Captain Kromcrush"] = 14325,
    ["King Gordok"] = 11501,
    ["Cho'Rush the Observer"] = 14324,
    ["Tendris Warpwood"] = 11489,
    ["Illyanna Ravenoak"] = 11488,
    ["Magister Kalendris"] = 11487,
    ["Tsu'zee"] = 11467,
    ["Immol'thar"] = 11496,
    ["Lord Hel'nurath"] = 14506,
    ["Prince Tortheldrin"] = 11486,
    ["Revanchion"] = 14690,

    -- Hateforge Quarry
    ["High Foreman Bargul Blackhammer"] = 60735,
    ["Engineer Figgles"] = 60736,
    ["Corrosis"] = 60829,
    ["Hatereaver Annihilator"] = 60734,
    ["Har'gesh Doomcaller"] = 60737,

    -- Karazhan Crypt
    ["Marrowspike"] = 91920,
    ["Hivaxxis"] = 91929,
    ["Corpsemuncher"] = 91917,
    ["Guard Captain Gort"] = 92935,
    ["Archlich Enkhraz"] = 91916,
    ["Commander Andreon"] = 91919,
    ["Alarus"] = 91928,

    -- Blackrock Depths
    ["Overmaster Pyron"] = 9026,
    ["Scarshield Quartermaster"] = 9046,
    ["The Behemoth"] = 8924,
    ["Lord Roccor"] = 9025,
    ["High Interrogator Gerstahn"] = 9018,
    ["Anub'shiah"] = 9031,
    ["Eviscerator"] = 9029,
    ["Gorosh the Dervish"] = 9027,
    ["Grizzle"] = 9028,
    ["Hedrum the Creeper"] = 9032,
    ["Ok'thor the Breaker"] = 9030,
    ["Theldren"] = 16059,
    ["Houndmaster Grebmar"] = 9319,
    ["Pyromancer Loregrain"] = 9024,
    ["Warder Stilgiss"] = 9041,
    ["Verek"] = 9042,
    ["Watchman Doomgrip"] = 9476,
    ["Fineous Darkvire"] = 9056,
    ["Lord Incendius"] = 9017,
    ["Bael'Gar"] = 9016,
    ["General Angerforge"] = 9033,
    ["Golem Lord Argelmach"] = 8983,
    ["Hurley Blackbreath"] = 9537,
    ["Phalanx"] = 9502,
    ["Plugger Spazzring"] = 9499,
    ["Ribbly Screwspigot"] = 9543,
    ["Ambassador Flamelash"] = 9156,
    ["Panzor the Invincible"] = 8923,
    ["The Lyceum"] = 170558,
    ["Magmus"] = 9938,
    ["Emperor Dagran Thaurissan"] = 9019,
    ["Princess Moira Bronzebeard"] = 8929,

    -- Stratholme
    ["Skul"] = 10393,
    ["Stratholme Courier"] = 11082,
    ["Balzaphon"] = 14684,
    ["Hearthsinger Forresten"] = 10558,
    ["The Unforgiven"] = 10516,
    ["Timmy the Cruel"] = 10808,
    ["Malor the Zealous"] = 11032,
    ["Crimson Hammersmith"] = 11120,
    ["Cannon Master Willey"] = 10997,
    ["Archivist Galford"] = 10811,
    ["Balnazzar"] = 10813,
    ["Sothos"] = 16102,
    ["Jarien"] = 16101,
    ["Magistrate Barthilas"] = 10435,
    ["Stonespine"] = 10809,
    ["Baroness Anastari"] = 10436,
    ["Black Guard Swordsmith"] = 11121,
    ["Nerub'enkan"] = 10437,
    ["Maleki the Pallid"] = 10438,
    ["Ramstein the Gorger"] = 10439,
    ["Baron Rivendare"] = 10440,
    ["Postmaster Malown"] = 11143,
    ["Atiesh"] = 16387,

    -- Scholomance
    ["Blood Steward of Kirtonos"] = 14861,
    ["Kirtonos the Herald"] = 10506,
    ["Jandice Barov"] = 10503,
    ["Lord Blackwood"] = 14695,
    ["Rattlegore"] = 11622,
    ["Death Knight Darkreaver"] = 14516,
    ["Marduk Blackpool"] = 10433,
    ["Vectus"] = 10432,
    ["Ras Frostwhisper"] = 10508,
    ["Kormok"] = 16118,
    ["Instructor Malicia"] = 10505,
    ["Doctor Theolen Krastinov"] = 11261,
    ["Lorekeeper Polkelt"] = 10901,
    ["The Ravenian"] = 10507,
    ["Lord Alexei Barov"] = 10504,
    ["Lady Illucia Barov"] = 10502,
    ["Darkmaster Gandling"] = 1853,

    -- Stormwind Vault
    ["Aszosh Grimflame"] = 80853,
    ["Tham'Grarr"] = 80852,
    ["Black Bride"] = 80850,
    ["Damian"] = 80854,
    ["Volkan Cruelblade"] = 80851,

    -- Lower Blackrock Spire
    ["Spirestone Butcher"] = 9219,
    ["Highlord Omokk"] = 9196,
    ["Spirestone Battle Lord"] = 9218,
    ["Spirestone Lord Magus"] = 9217,
    ["Shadow Hunter Vosh'gajin"] = 9236,
    ["War Master Voone"] = 9237,
    ["Mor Grayhoof"] = 16080,
    ["Bannok Grimaxe"] = 9596,
    ["Mother Smolderweb"] = 10596,
    ["Crystal Fang"] = 10376,
    ["Urok Doomhowl"] = 10584,
    ["Quartermaster Zigris"] = 9736,
    ["Halycon"] = 10220,
    ["Gizrul the Slavener"] = 10268,
    ["Ghok Bashguud"] = 9718,
    ["Overlord Wyrmthalak"] = 9568,
    ["Burning Felguard"] = 10263,

    -- The Black Morass
    ["Chronar"] = 65113,
    ["Epidamu"] = 61575,
    ["Drifting Avatar of Sand"] = 61316,
    ["Time-Lord Epochronos"] = 65116,
    ["Mossheart"] = 65124,
    ["Antnormi"] = 65125,
    ["Rotmaw"] = 65122,

    -- Miscellaneous
    ["Woo Ping"] = 11867,
    ["Bixi Wobblebonk"] = 13084,
    ["Buliwyf Stonehand"] = 11865,
    ["Ilyenia Moonfire"] = 11866,
    ["Hanashi"] = 2704,
    ["Sayoc"] = 11868,
    ["Archibald"] = 11870,
    ["Ansekhwa"] = 11869,
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

    -- Raid bosses - Timbermaw Hold (Nightmare of Ursol)
    ["Peroth'arn"] = { type = "Demon", classification = "Boss" },
    ["Karrsh the Sentinel"] = { type = "Humanoid", classification = "Boss" },
    ["Rotgrowl"] = { type = "Humanoid", classification = "Boss" },
    ["Chieftain Partath"] = { type = "Humanoid", classification = "Boss" },
    ["Trioch the Devourer"] = { type = "Beast", classification = "Boss" },
    ["Selenaxx Foulheart"] = { type = "Demon", classification = "Boss" },
    ["Ormanos the Cracked"] = { type = "Giant", classification = "Boss" },
    ["Loktanag the Vile"] = { type = "Elemental", classification = "Boss" },
    ["Archdruid Kronn"] = { type = "Humanoid", classification = "Boss" },
    ["Ursol"] = { type = "Beast", classification = "Boss" },

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
    for raidName, raidData in pairs(self.Raids) do
        local list = raidData.Bosses or raidData
        for i = 1, table.getn(list) do
            self.BossToRaid[list[i]] = raidName
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
    local raidData = self.Raids[raidName]
    if not raidData then return {} end
    return raidData.Bosses or raidData
end

-- Get boss count in a raid
function T_Lib:GetBossCount(raidAlias)
    self:EnsureBossDataInitialized()
    local bosses = self:GetBossesByRaid(raidAlias)
    return table.getn(bosses)
end

-- Get trash mobs of a raid by name or alias
function T_Lib:GetTrashByRaid(raidAlias)
    self:EnsureBossDataInitialized()
    local raidName = self.RaidAliases[raidAlias] or raidAlias
    local raidData = self.Raids[raidName]
    if not raidData then return {} end
    return raidData.Trash or {}
end

-- Get instance type ("Raid", "Dungeon", or "Unknown")
function T_Lib:GetRaidType(raidAlias)
    self:EnsureBossDataInitialized()
    local raidName = self.RaidAliases[raidAlias] or raidAlias
    local raidData = self.Raids[raidName]
    if not raidData then return "Unknown" end
    return raidData.Type or "Unknown"
end

-- Get NPCs of a raid by name or alias
function T_Lib:GetNPCsByRaid(raidAlias)
    self:EnsureBossDataInitialized()
    local raidName = self.RaidAliases[raidAlias] or raidAlias
    local raidData = self.Raids[raidName]
    if not raidData then return {} end
    return raidData.NPCs or {}
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

-- Get NPC ID of a boss by name
function T_Lib:GetBossNPCID(bossName)
    if not bossName or not self.BossIDs then
        return nil
    end
    return self.BossIDs[bossName] or nil
end

-- Get boss name by NPC ID (reverse lookup)
function T_Lib:GetBossNameByID(npcId)
    if not npcId or not self.BossIDs then
        return nil
    end
    for name, id in pairs(self.BossIDs) do
        if id == npcId then
            return name
        end
    end
    return nil
end

-- Initialize on load
if T_Lib and T_Lib.InitializeBossData then
    T_Lib:InitializeBossData()
end
