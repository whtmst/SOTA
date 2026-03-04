--[[
--	SOTA - State of the Art
--
--	Unit: sota-raidqueue.lua
--	The Raid Queue contains a list of people currently in queue for the raid.
--	It is possible to invite people from the raid queue using the UI.
--]]

-- TODO: Нужно разобраться полностью с командами и работой данного модуля.

-- Unique number for each queued raid member. Used for Sorting.
local QueueID             = 1;

-- UI Status: True = Open, False = Closed - use to prevent update of UI elements when closed.
local RaidQueueUIOpen     = false;

-- Max # of characters displayes per role in the Raid Queue UI. A caption will be inserted in top.
local MAX_RAID_QUEUE_SIZE = 8;



function SOTA_OpenRaidQueueUI()
    RaidQueueUIOpen = true;
    SOTA_RefreshRaidQueue();

    RaidQueueFrame:Show();
end

function SOTA_CloseRaidQueueUI()
    RaidQueueUIOpen = false;
    RaidQueueFrame:Hide();
end

--[[
--	Initialize Raid Queues
--]]
function SOTA_RaidQueueUIInit()
    for n = 1, MAX_RAID_QUEUE_SIZE + 1, 1 do
        local tList = CreateFrame("Button", "$parentEntry" .. n, RaidQueueFrameTankList, "SOTA_PlayerTemplate");
        local mList = CreateFrame("Button", "$parentEntry" .. n, RaidQueueFrameMeleeList, "SOTA_PlayerTemplate");
        local rList = CreateFrame("Button", "$parentEntry" .. n, RaidQueueFrameRangedList, "SOTA_PlayerTemplate");
        local hList = CreateFrame("Button", "$parentEntry" .. n, RaidQueueFrameHealerList, "SOTA_PlayerTemplate");
        tList:SetID(n);
        mList:SetID(n);
        rList:SetID(n);
        hList:SetID(n);
        if (n == 1) then
            tList:SetPoint("TOPLEFT", 4, -4);
            mList:SetPoint("TOPLEFT", 4, -4);
            rList:SetPoint("TOPLEFT", 4, -4);
            hList:SetPoint("TOPLEFT", 4, -4);
        else
            tList:SetPoint("TOP", "$parentEntry" .. (n - 1), "BOTTOM");
            mList:SetPoint("TOP", "$parentEntry" .. (n - 1), "BOTTOM");
            rList:SetPoint("TOP", "$parentEntry" .. (n - 1), "BOTTOM");
            hList:SetPoint("TOP", "$parentEntry" .. (n - 1), "BOTTOM");
        end
    end
end;

--[[
--	Refresh the Raid Queue UI.
--	If a role is given, only the queue for that role is refreshed.
--	A role of nil will refresh all roles.
--]]
function SOTA_RefreshRaidQueue(role)
    -- UI not open; no need to update controls yet.
    -- This is used to allow GuildRosterUpdates to update UI when needed.
    if not RaidQueueUIOpen then
        return;
    end


    local raidRoster = SOTA_GetRaidRoster();

    local playersAlsoInRaid = {}

    -- Queue info: { Playername / queueId / Role / Class / Guild rank, offlinetime }
    local tQueue = {}
    local mQueue = {}
    local rQueue = {}
    local hQueue = {}

    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        local playername = SOTA_RaidQueue[n][1];

        local found = false;
        for f = 1, table.getn(raidRoster), 1 do
            if (raidRoster[f][1] == playername) then
                found = true;
                f = table.getn(raidRoster);
            end
        end

        if found then
            playersAlsoInRaid[table.getn(playersAlsoInRaid) + 1] = playername;
        else
            local role = SOTA_RaidQueue[n][3];
            if (role == "tank") then
                tQueue[table.getn(tQueue) + 1] = SOTA_RaidQueue[n];
            elseif (role == "melee") then
                mQueue[table.getn(mQueue) + 1] = SOTA_RaidQueue[n];
            elseif (role == "ranged") then
                rQueue[table.getn(rQueue) + 1] = SOTA_RaidQueue[n];
            elseif (role == "healer") then
                hQueue[table.getn(hQueue) + 1] = SOTA_RaidQueue[n];
            end
        end
    end

    SOTA_UpdateRaidQueueTable("ТАНКИ", "RaidQueueFrameTankListEntry", tQueue);
    SOTA_UpdateRaidQueueTable("МДД", "RaidQueueFrameMeleeListEntry", mQueue);
    SOTA_UpdateRaidQueueTable("РДД", "RaidQueueFrameRangedListEntry", rQueue);
    SOTA_UpdateRaidQueueTable("ХИЛЛЕРЫ", "RaidQueueFrameHealerListEntry", hQueue);

    -- Remove players from queue who are also in Raid
    for n = 1, table.getn(playersAlsoInRaid), 1 do
        SOTA_RemoveFromRaidQueue(playersAlsoInRaid[n]);
    end
end

function SOTA_UpdateRaidQueueTable(caption, framename, sourcetable)
    local headColor    = { 240, 240, 240 };
    local textColor    = { 240, 200, 40 }
    local offlineColor = { 128, 128, 128 };

    local playername, playerrole, playerclass, queueid, playerzone, offlinetime;
    for n = 0, MAX_RAID_QUEUE_SIZE, 1 do
        playerzone = "";

        if n == 0 or table.getn(sourcetable) < n then
            playername  = "";
            playerrole  = "";
            queueid     = "";
            playerclass = "";
            playerrank  = "";
            offlinetime = 0;
        else
            playername  = sourcetable[n][1];
            queueid     = sourcetable[n][2];
            playerrole  = sourcetable[n][3];
            playerclass = sourcetable[n][4];
            playerrank  = sourcetable[n][5];
            offlinetime = sourcetable[n][6];
        end

        local nameColor = offlineColor;
        if not (playername == "") then
            local guildInfo = SOTA_GetGuildPlayerInfo(playername);
            if guildInfo then
                if guildInfo[5] == 1 then
                    nameColor = SOTA_GetClassColorCodes(playerclass);
                end
                playerzone = guildInfo[6];
            end
        end

        local zoneColor = textColor;
        if offlinetime > 0 then
            zoneColor = offlineColor;
            -- DC time is the total # of seconds the player has been offline:
            local dctime = SOTA_TimerTick - offlinetime;
            local mm = math.floor(dctime / 60);
            local hh = math.floor(mm / 60);

            if mm == 1 then
                playerzone = "НЕ В СЕТИ (1 минута)";
            elseif mm < 60 then
                playerzone = "НЕ В СЕТИ (" .. mm .. " минут)";
            elseif hh == 1 then
                playerzone = "НЕ В СЕТИ (1 час)";
            else
                playerzone = "НЕ В СЕТИ (" .. hh .. " часов)";
            end;
        end;


        local frame = getglobal(framename .. (n + 1));
        if n == 0 then
            local color = headColor;
            getglobal(frame:GetName() .. "Name"):SetText(caption);
            getglobal(frame:GetName() .. "Name"):SetTextColor((headColor[1] / 255), (headColor[2] / 255),
                (headColor[3] / 255), 255);
            getglobal(frame:GetName() .. "Zone"):SetText("ЗОНА");
            getglobal(frame:GetName() .. "Zone"):SetTextColor((headColor[1] / 255), (headColor[2] / 255),
                (headColor[3] / 255), 255);
            getglobal(frame:GetName() .. "Rank"):SetText("В ОЧЕРЕДИ: " .. table.getn(sourcetable));
            getglobal(frame:GetName() .. "Rank"):SetTextColor((headColor[1] / 255), (headColor[2] / 255),
                (headColor[3] / 255), 255);
        else
            getglobal(frame:GetName() .. "Name"):SetText(playername);
            getglobal(frame:GetName() .. "Name"):SetTextColor((nameColor[1] / 255), (nameColor[2] / 255),
                (nameColor[3] / 255), 255);
            getglobal(frame:GetName() .. "Zone"):SetText(playerzone);
            getglobal(frame:GetName() .. "Zone"):SetTextColor((zoneColor[1] / 255), (zoneColor[2] / 255),
                (zoneColor[3] / 255), 255);
            getglobal(frame:GetName() .. "Rank"):SetText(playerrank);
            getglobal(frame:GetName() .. "Rank"):SetTextColor((zoneColor[1] / 255), (zoneColor[2] / 255),
                (zoneColor[3] / 255), 255);
        end

        frame:Show();
    end
end

function SOTA_UpdateQueueOfflineTimers()
    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        local playername = SOTA_RaidQueue[n][1];

        local guildInfo = SOTA_GetGuildPlayerInfo(playername);
        if guildInfo then
            -- 0=OFFLINE, 1=ONLINE
            if guildInfo[5] == 1 then
                if SOTA_RaidQueue[n][6] > 0 then
                    SOTA_RaidQueue[n][6] = 0;
                end;
            else
                if SOTA_RaidQueue[n][6] == 0 then
                    SOTA_RaidQueue[n][6] = SOTA_TimerTick;
                end;
            end
        end
    end
end;

function SOTA_CheckOfflineStatus()
    if RaidQueueUIOpen then
        SOTA_RefreshRaidQueue(nil);
    end;
end

--[[
--	Invite all of one role type (e.g. all Tanks)
--]]
function SOTA_InviteQueuedPlayerGroup(rolename, roleidentifier)
    StaticPopupDialogs["SOTA_POPUP_INVITE_PLAYER"] = {
        text = string.format("Вы хотите пригласить всех игроков роли %s ?", rolename),
        button1 = "Да",
        button2 = "Нет",
        OnAccept = function() SOTA_InviteQueuedPlayerGroupNow(roleidentifier) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function()
            local frameName = this:GetName();
            local fontPath = "Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf";

            local textElement = getglobal(frameName .. "Text");
            if textElement then
                textElement:SetFont(fontPath, 12);
            end

            local editBox = getglobal(frameName .. "EditBox");
            if editBox then
                editBox:SetFont(fontPath, 12);
            end

            local button1 = getglobal(frameName .. "Button1");
            if button1 then
                button1:SetFont(fontPath, 12);
            end

            local button2 = getglobal(frameName .. "Button2");
            if button2 then
                button2:SetFont(fontPath, 12);
            end
        end,
    }

    StaticPopup_Show("SOTA_POPUP_INVITE_PLAYER");
end

function SOTA_InviteQueuedPlayerGroupNow(role)
    if not SOTA_IsInRaid(true) then
        return;
    end

    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        if SOTA_RaidQueue[n][3] == role then
            InviteByName(SOTA_RaidQueue[n][1]);
        end
    end
end

function SOTA_InviteQueuedPlayer(playername)
    if not SOTA_IsInRaid(true) then
        return;
    end

    local qInfo = SOTA_GetQueuedPlayer(playername);

    if not qInfo then
        localEcho("Игрок " .. playername .. " не находится в очереди!");
        return;
    end

    StaticPopupDialogs["SOTA_POPUP_INVITE_PLAYER"] = {
        text = string.format("Вы хотите пригласить %s в рейд?", playername),
        button1 = "Да",
        button2 = "Нет",
        OnAccept = function() InviteByName(playername) end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
        OnShow = function()
            local frameName = this:GetName();
            local fontPath = "Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf";

            local textElement = getglobal(frameName .. "Text");
            if textElement then
                textElement:SetFont(fontPath, 12);
            end

            local editBox = getglobal(frameName .. "EditBox");
            if editBox then
                editBox:SetFont(fontPath, 12);
            end

            local button1 = getglobal(frameName .. "Button1");
            if button1 then
                button1:SetFont(fontPath, 12);
            end

            local button2 = getglobal(frameName .. "Button2");
            if button2 then
                button2:SetFont(fontPath, 12);
            end
        end,
    }

    StaticPopup_Show("SOTA_POPUP_INVITE_PLAYER");
end

-- Remove queued player from queue
function SOTA_RemoveQueuedPlayerGroupNow(playername)
    if not SOTA_IsInRaid(true) then
        return;
    end

    localEcho("Удаление " .. playername .. " из очереди");

    SOTA_RemoveFromRaidQueue(playername);

    local guildInfo = SOTA_GetGuildPlayerInfo(playername);
    if (guildInfo and guildInfo[5] == 1) then
        SOTA_whisper(playername, "Вы были удалены из очереди в рейд.")
    end
end

function SOTA_GetQueuedPlayer(playername)
    local queueInfo = nil;
    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        queueInfo = SOTA_RaidQueue[n];
        if queueInfo[1] == playername then
            return queueInfo;
        end
    end

    return queueInfo;
end

--[[
--	Handle incoming /queue or !queue command
--	Since: 0.1.1
--]]
function SOTA_HandleQueueRequest(sender, message)
    local _, _, queueparam = string.find(string.lower(message), "очередь (%a+)")
    if not queueparam then
        if sender == UnitName("player") then
            SOTA_OpenRaidQueueUI();
        else
            -- { Name, QueueID, Role , Class }
            local t = 0
            local m = 0
            local r = 0
            local h = 0;
            for n = 1, table.getn(SOTA_RaidQueue), 1 do
                if SOTA_RaidQueue[n][3] == "tank" then
                    t = t + 1
                elseif SOTA_RaidQueue[n][3] == "melee" then
                    m = m + 1
                elseif SOTA_RaidQueue[n][3] == "ranged" then
                    r = r + 1
                elseif SOTA_RaidQueue[n][3] == "healer" then
                    h = h + 1
                end
            end
            SOTA_whisper(sender, string.format("В очереди: %d ТАНКОВ, %d МДД, %d РДД, %d ХИЛЛЕРОВ", t, m, r, h));
        end
        return;
    end

    local queuetype = nil;

    queueparam = string.lower(queueparam);
    if queueparam == "танк" or queueparam == "т" or queueparam == "tank" or queueparam == "t" then
        queuetype = "tank";
    elseif queueparam == "мдд" or queueparam == "м" or queueparam == "melee" or queueparam == "m" then
        queuetype = "melee";
    elseif queueparam == "рдд" or queueparam == "р" or queueparam == "ranged" or queueparam == "r" then
        queuetype = "ranged";
    elseif queueparam == "хил" or queueparam == "х" or queueparam == "healer" or queueparam == "h" then
        queuetype = "healer";
    elseif queueparam == "sheyliny" or queueparam == "noob" or queueparam == "нуб" then
        SOTA_whisper(sender, "Сорри, рейд уже забит нубами ;-)");
        return;
    end

    if queuetype then
        SOTA_CheckForMaster();
        if SOTA_IsMaster() then
            SOTA_AddToRaidQueue(sender, queuetype);
        end
    else
        SOTA_whisper(sender, "Напиши !queue <роль>, где роль: ТАНК, МДД, РДД или ХИЛЛЕР.");
    end
end

function SOTA_AddToRaidQueueByName(args)
    if args then
        local _, _, playername, playerrole = string.find(args, "(%S+) (%S+)")

        if playername and playerrole then
            if SOTA_AddToRaidQueue(playername, playerrole, false, true) then
                SOTA_BroadcastJoinQueue(playername, playerrole);
            end
            return;
        end
    end

    localEcho("Синтаксис: /sota addqueue <игрок> <роль>");
end

--[[
--	Add a player to the raid queue
--	byProxy means the player was added by the current player,
--	so whispers should be sent to localEcho instead.
--	Since: 0.1.1
--]]
function SOTA_AddToRaidQueue(playername, playerrole, silentmode, byProxy)
    if not silentmode then
        silentmode = false;
    end
    if not byProxy then
        byProxy = false;
    end


    playername = SOTA_UCFirst(playername);
    playerrole = string.lower(playerrole);

    if playerrole ~= "tank" and
        playerrole ~= "melee" and
        playerrole ~= "ranged" and
        playerrole ~= "healer" then
        if not silentmode then
            if byProxy then
                localEcho("Допустимые роли: ТАНК, МДД, РДД или ХИЛЛЕР.");
            else
                SOTA_whisper(playername, "Допустимые роли: ТАНК, МДД, РДД или ХИЛЛЕР.");
            end;
        end
        return false;
    end;


    local playerInfo = SOTA_GetGuildPlayerInfo(playername);
    if not playerInfo then
        -- We end here in two situations:
        -- * If player is not in the guild, or
        -- * Player is offline, and receiver have turned SHOW OFFLINE MEMBERS off.
        -- However, there is a third way getting here: logging in and joining queue
        -- straight away; that whay the guild roster data is not yet updated.
        --
        -- Impact of skipping offliners is that these are not synchronized.
        if not silentmode then
            if byProxy then
                localEcho(string.format("%s должен состоять в гильдии, чтобы встать в очередь!", playername));
            else
                SOTA_whisper(playername, "Ты должен состоять в гильдии, чтобы встать в очередь!");
            end;
        end
        return false;
    end

    local raidRoster = SOTA_GetRaidRoster();

    -- Check if player is already in the raid:
    for n = 1, table.getn(raidRoster), 1 do
        if raidRoster[n][1] == playername then
            if not silentmode then
                if byProxy then
                    localEcho(string.format("%s уже в рейде.", playername));
                else
                    SOTA_whisper(playername, "Ты уже в рейде.");
                end;
            end
            return false;
        end
    end

    -- Check if player is already queued:
    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        local rq = SOTA_RaidQueue[n];
        if rq[1] == playername and rq[3] == playerrole then
            if not silentmode then
                if byProxy then
                    localEcho(string.format("%s уже в очереди как %s.", playername, playerrole));
                else
                    SOTA_whisper(playername, string.format("Ты уже в очереди как %s.", playerrole));
                end;
            end
            return false;
        end
    end

    -- Remove if already queued - that way you can change role.
    SOTA_RemoveFromRaidQueue(playername, silentmode);

    -- Playername / queueId / Role / Class / Guild rank / Offline Time (0=ONLINE)
    SOTA_RaidQueue[table.getn(SOTA_RaidQueue) + 1] = { playername, QueueID, playerrole, playerInfo[3], playerInfo[4], 0 };
    QueueID = QueueID + 1;

    if not silentmode then
        SOTA_BroadcastJoinQueue(playername, playerrole);

        if byProxy then
            localEcho(string.format("%s в очереди как %s - Персонажей в очереди: %d", playername,
                SOTA_UCFirst(playerrole), table.getn(SOTA_RaidQueue)));
        else
            SOTA_whisper(playername,
                string.format("Ты в очереди как %s - Персонажей в очереди: %d", SOTA_UCFirst(playerrole),
                    table.getn(SOTA_RaidQueue)));
        end;
    end

    SOTA_RefreshRaidQueue();

    return true;
end

--[[
--	Remove a player from the raid queue
--]]
function SOTA_RemoveFromRaidQueue(playername, silentmode)
    if not silentmode then
        silentmode = false;
    end

    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        if SOTA_RaidQueue[n][1] == playername then
            SOTA_RaidQueue[n] = {};
            SOTA_RaidQueue = SOTA_RenumberTable(SOTA_RaidQueue);

            if not silentmode then
                SOTA_BroadcastLeaveQueue(playername);
            end
            SOTA_RefreshRaidQueue();
            return true;
        end
    end

    SOTA_RefreshRaidQueue();
    return false;
end

--[[
--	Whisper or print queue details.
--	Since: 1.0.3
--]]
function SOTA_Call_ListQueue(receiver)
    local qTank = "";
    local qMelee = "";
    local qRanged = "";
    local qHealer = "";

    for n = 1, table.getn(SOTA_RaidQueue), 1 do
        if SOTA_RaidQueue[n][3] == "tank" then
            if qTank == "" then
                qTank = SOTA_RaidQueue[n][1];
            else
                qTank = qTank .. ", " .. SOTA_RaidQueue[n][1];
            end
        end;

        if SOTA_RaidQueue[n][3] == "melee" then
            if qMelee == "" then
                qMelee = SOTA_RaidQueue[n][1];
            else
                qMelee = qMelee .. ", " .. SOTA_RaidQueue[n][1];
            end
        end;

        if SOTA_RaidQueue[n][3] == "ranged" then
            if qRanged == "" then
                qRanged = SOTA_RaidQueue[n][1];
            else
                qRanged = qRanged .. ", " .. SOTA_RaidQueue[n][1];
            end
        end;

        if SOTA_RaidQueue[n][3] == "healer" then
            if qHealer == "" then
                qHealer = SOTA_RaidQueue[n][1];
            else
                qHealer = qHealer .. ", " .. SOTA_RaidQueue[n][1];
            end
        end;
    end;

    SOTA_whisper(receiver, "Игроков в очереди:");
    local queued = false;
    if not (qTank == "") then
        SOTA_whisper(receiver, "(ТАНКИ) " .. qTank);
        queued = true;
    end;
    if not (qMelee == "") then
        SOTA_whisper(receiver, "(МДД) " .. qMelee);
        queued = true;
    end;
    if not (qRanged == "") then
        SOTA_whisper(receiver, "(РДД) " .. qRanged);
        queued = true;
    end;
    if not (qHealer == "") then
        SOTA_whisper(receiver, "(ХИЛЛЕРЫ) " .. qHealer);
        queued = true;
    end;
    if not queued then
        SOTA_whisper(receiver, "(Очередь пуста)");
    end;
end;

function SOTA_OnQueuedPlayerClick(object, buttonname)
    local msgID = object:GetID();

    local playername = getglobal(object:GetName() .. "Name"):GetText();
    if not playername or playername == "" then
        return;
    end

    if not SOTA_IsPromoted(true) then
        return;
    end


    -- Promote player to Master if none is currently set
    SOTA_CheckForMaster();

    --	Header was clicked; invite all players for the current role:
    if getglobal(object:GetName() .. "Zone"):GetText() == "Zone" then
        if playername == "Tanks" then
            SOTA_InviteQueuedPlayerGroup(playername, "tank");
        elseif playername == "Melee" then
            SOTA_InviteQueuedPlayerGroup(playername, "melee");
        elseif playername == "Ranged" then
            SOTA_InviteQueuedPlayerGroup(playername, "ranged");
        elseif playername == "Healers" then
            SOTA_InviteQueuedPlayerGroup(playername, "healer");
        end
        return;
    end;

    -- Single player removal / invitation:
    if buttonname == "RightButton" then
        StaticPopupDialogs["SOTA_POPUP_REMOVE_PLAYER"] = {
            text = string.format("Удалить %s из очереди рейда?", playername),
            button1 = "Да",
            button2 = "Нет",
            OnAccept = function() SOTA_RemoveQueuedPlayerGroupNow(playername) end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function()
                local frameName = this:GetName();
                local fontPath = "Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf";

                local textElement = getglobal(frameName .. "Text");
                if textElement then
                    textElement:SetFont(fontPath, 12);
                end

                local editBox = getglobal(frameName .. "EditBox");
                if editBox then
                    editBox:SetFont(fontPath, 12);
                end

                local button1 = getglobal(frameName .. "Button1");
                if button1 then
                    button1:SetFont(fontPath, 12);
                end

                local button2 = getglobal(frameName .. "Button2");
                if button2 then
                    button2:SetFont(fontPath, 12);
                end
            end,
        }

        StaticPopup_Show("SOTA_POPUP_REMOVE_PLAYER");
    else
        -- Quit if player isnt in guild:
        local playerinfo = SOTA_GetGuildPlayerInfo(playername);
        if not (playerinfo) then
            return;
        end

        -- Invite player if he is online:
        if (playerinfo[5] == 1) then
            SOTA_InviteQueuedPlayer(playername);
        end;
    end
end
