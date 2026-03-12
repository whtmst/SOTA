--[[
--	SOTA - State of the Art
--
--	Unit: sota-loottracker.lua
--	Модуль отслеживания 10-минутного таймера на передачу BoP предметов,
--	полученных Мастером Лутером с боссов в рейде.
--]]

-- === НАСТРОЙКИ LOOT TRACKER ===
local SOTA_LOOTTRACKER_MIN_QUALITY = 0         -- Минимальное качество: 0 (Poor (серый)), 1 (Common (белый)), 2 (Uncommon (зелёный)), 3 (Rare (синий)), 4 (Epic (фиол)), 5 (Legendary (оранж))
local SOTA_LOOTTRACKER_REQUIRE_RAID = true     -- true: только в рейде
local SOTA_LOOTTRACKER_REQUIRE_INSTANCE = false -- true: только в инстансе
local SOTA_LOOTTRACKER_UPDATE_INTERVAL = 0.5   -- Интервал обновления UI (сек)
local SOTA_LOOTTRACKER_LOOT_WINDOW_TIME = 600  -- Время на передачу (сек), 600 = 10 мин
local SOTA_LOOTTRACKER_MAX_ROWS = 10           -- Максимум строк в UI

-- Кириллический шрифт для динамических элементов
local CYRILLIC_FONT_PATH = "Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf";

-- Таблица активных записей (рантайм, не сохраняется)
SOTA_LootTracker = {};

-- Накопитель для троттлинга OnUpdate
local SOTA_LootTracker_Elapsed = 0;

--[[
--	Создание записи в таблице отслеживания
--]]
local function SOTA_LootTracker_CreateEntry(itemLink, itemName, iconTexture, startTime, bossName)
    local entry = {
        itemLink = itemLink,
        itemName = itemName,
        iconTexture = iconTexture,
        startTime = startTime,
        bossName = bossName,
        winnerName = nil,
        winnerClass = nil,
    };
    table.insert(SOTA_LootTracker, entry);
    debugEcho("LootTracker: создана запись для " .. (itemName or "?") .. " с босса " .. (bossName or "?"));
    return entry;
end

--[[
--	Обработчик события LOOT_BIND_CONFIRM и срабатывания хука GiveMasterLoot
--]]
function SOTA_LootTracker_TrackItem(slot)
    -- Фильтр 1: Только в рейде
    if SOTA_LOOTTRACKER_REQUIRE_RAID then
        if GetNumRaidMembers() == 0 then
            debugEcho("LootTracker: Отклонено (игрок не в рейде)");
            return;
        end
    end

    -- Фильтр 2: Только в режиме Мастер-Лут
    local lootMethod = GetLootMethod();
    if lootMethod ~= "master" then
        debugEcho("LootTracker: Отклонено (режим лута не master, а " .. tostring(lootMethod) .. ")");
        return;
    end

    -- Фильтр 4: Проверка на босса через таргет
    local targetName = UnitName("target");
    if not targetName then
        debugEcho("LootTracker: нет таргета, запись не создана");
        return;
    end

    -- Фильтр 5: Проверка через T-Lib
    -- if not T_Lib or not T_Lib.IsBoss then
        -- debugEcho("LootTracker: T_Lib не загружена, запись не создана");
        -- return;
    -- end
    -- if not T_Lib:IsBoss(targetName) then
        -- debugEcho("LootTracker: " .. targetName .. " не является боссом (T_Lib)");
        -- return;
    -- end

    -- Фильтр 6 (опционально): Только в инстансе
    if SOTA_LOOTTRACKER_REQUIRE_INSTANCE then
        if IsInInstance() ~= 1 then
            return;
        end
    end

    -- Получаем информацию об иконке и имени
    local icon, name, quantity = GetLootSlotInfo(slot);

    -- Получаем itemLink
    local itemLink = GetLootSlotLink(slot);
    if itemLink then
        -- В Vanilla данные могут не загрузиться к моменту лота
        -- Пытаемся получить из кэша
        local itemName, itemString, itemQuality = GetItemInfo(itemLink);

        -- Если предмета нет в кэше, пропингуем сервер скрытым Tooltip-ом!
        -- И извлекаем цвет (качество) прямо из подстроки линка!
        -- Формат: |cffXXXXXX|Hitem:ID:Enchant:Rand:Seed|h[Name]|h|r
        if not itemQuality or not itemName then
            -- Пингуем сервер скрытым тултипом (гениальное решение из T-Bidder)
            GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
            pcall(function() GameTooltip:SetHyperlink(itemLink) end)
            GameTooltip:Hide()

            -- Пробуем получить еще раз
            itemName, itemString, itemQuality = GetItemInfo(itemLink);

            -- Если itemName все еще nil, достанем имя из itemLink
            if not itemName then
                local _, _, nameFromLink = string.find(itemLink, "%[(.-)%]");
                if nameFromLink then itemName = nameFromLink end
            end

            if not itemQuality then
                local _, _, colorStr = string.find(itemLink, "|c(%x%x%x%x%x%x%x%x)|H");
                if colorStr then
                    colorStr = string.lower(colorStr);
                    if colorStr == "ff9d9d9d" then itemQuality = 0;      -- Poor (серый)
                    elseif colorStr == "ffffffff" then itemQuality = 1;  -- Common (белый)
                    elseif colorStr == "ff1eff00" then itemQuality = 2;  -- Uncommon (зелёный)
                    elseif colorStr == "ff0070dd" then itemQuality = 3;  -- Rare (синий)
                    elseif colorStr == "ffa335ee" then itemQuality = 4;  -- Epic (фиол)
                    elseif colorStr == "ffff8000" then itemQuality = 5;  -- Legendary (оранж)
                    end
                end
            end
        end

        -- Если всё равно не удалось (или это золото)
        if not itemQuality then
             debugEcho("LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") - не удалось определить качество по ссылке!");
        elseif itemQuality < SOTA_LOOTTRACKER_MIN_QUALITY then
             debugEcho("LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") отклонен (качество " .. tostring(itemQuality) .. " < " .. tostring(SOTA_LOOTTRACKER_MIN_QUALITY) .. ")");
        else
            -- Качество подходит конкретно
            -- Проверяем дубликат (тот же itemLink уже отслеживается)
            local isDuplicate = false;
            for n = 1, table.getn(SOTA_LootTracker), 1 do
                if SOTA_LootTracker[n].itemLink == itemLink then
                    isDuplicate = true;
                    debugEcho("LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") уже отслеживается");
                    break;
                end
            end

            if not isDuplicate then
                -- Создаём запись
                local startTime = GetTime();
                SOTA_LootTracker_CreateEntry(itemLink, name, icon, startTime, targetName);

                debugEcho("LootTracker: создана запись для " .. name .. " с босса " .. (targetName or "Неизвестно"));

                -- Обновляем UI, но не показываем его принудительно (чтобы не мешать)
                if SOTA_LootTrackerFrame and SOTA_LootTrackerFrame:IsVisible() then
                    SOTA_LootTracker_RefreshUI();
                end
            end
        end
    else
        debugEcho("LootTracker: Слот " .. slot .. " - нет itemLink (возможно золото/квест итем)");
    end
end

--[[
--	Хук: вызывается из SOTA_AcceptBid после завершения аукциона
--	Записывает имя победителя и его класс в соответствующую запись
--]]
function SOTA_LootTracker_OnAuctionComplete(auctionItemLink, winnerName)
    if not auctionItemLink or not winnerName then
        return;
    end

    -- Извлекаем имя предмета из линка (текст между квадратными скобками [Item Name])
    local _, _, auctionItemName = string.find(auctionItemLink, "%[(.-)%]");
    if not auctionItemName then
        debugEcho("LootTracker: не удалось извлечь имя предмета из " .. auctionItemLink);
        return;
    end

    for n = 1, table.getn(SOTA_LootTracker), 1 do
        local entry = SOTA_LootTracker[n];
        -- Сравниваем по имени предмета, так как itemLink может отличаться (содержит instance id)
        if entry.itemName == auctionItemName then
            entry.winnerName = winnerName;

            -- Получаем класс победителя из данных гильдии
            local playerInfo = SOTA_GetGuildPlayerInfo(winnerName);
            if playerInfo then
                entry.winnerClass = playerInfo[3];
            end

            debugEcho("LootTracker: победитель " .. winnerName .. " записан для " .. (entry.itemName or "?"));

            -- Показываем UI, если он был скрыт, так как аукцион завершён
            SOTA_LootTracker_ShowUI();

            return;
        end
    end

    debugEcho("LootTracker: запись для " .. auctionItemName .. " не найдена (аукцион)");
end

--[[
--	OnUpdate с троттлингом — обновление таймеров
--	Вызывается каждый кадр из XML, мы троттлим до раз в 0.5 сек
--]]
function SOTA_LootTracker_Update(elapsed)
    SOTA_LootTracker_Elapsed = SOTA_LootTracker_Elapsed + elapsed;

    if SOTA_LootTracker_Elapsed < SOTA_LOOTTRACKER_UPDATE_INTERVAL then
        return;
    end
    SOTA_LootTracker_Elapsed = 0;

    -- Если записей нет — ничего не делаем
    local count = table.getn(SOTA_LootTracker);
    if count == 0 then
        return;
    end

    -- Удаляем протухшие записи (идём с конца чтобы не сбить индексы)
    local currentTime = GetTime();
    local removed = false;
    for n = count, 1, -1 do
        local entry = SOTA_LootTracker[n];
        local remaining = SOTA_LOOTTRACKER_LOOT_WINDOW_TIME - (currentTime - entry.startTime);
        if remaining <= 0 then
            debugEcho("LootTracker: запись " .. (entry.itemName or "?") .. " истекла, удаляю");
            table.remove(SOTA_LootTracker, n);
            removed = true;
        end
    end

    -- Сортируем по startTime (старые сверху)
    if table.getn(SOTA_LootTracker) > 1 then
        table.sort(SOTA_LootTracker, function(a, b) return a.startTime < b.startTime end);
    end

    -- Обновляем UI
    SOTA_LootTracker_RefreshUI();
end

--[[
--	Обновление отображения UI (строки таблицы)
--	Не создаёт новых таблиц — использует заранее созданные фреймы
--]]
function SOTA_LootTracker_RefreshUI()
    if not SOTA_LootTrackerFrame then
        return;
    end

    local count = table.getn(SOTA_LootTracker);

    -- Показываем/скрываем надпись "Нет активных таймеров"
    local emptyText = getglobal("SOTA_LootTrackerFrameEmptyText");
    if emptyText then
        if count == 0 then
            emptyText:Show();
        else
            emptyText:Hide();
        end
    end

    -- Обновляем строки
    local currentTime = GetTime();
    for n = 1, SOTA_LOOTTRACKER_MAX_ROWS, 1 do
        local row = getglobal("SOTA_LootTrackerRow" .. n);
        if row then

			-- 1. ПОЛУЧАЕМ ПОДЛОЖКУ (Texture)
            local rowBG = getglobal("SOTA_LootTrackerRow" .. n .. "RowBG");

            if n <= count then
                local entry = SOTA_LootTracker[n];

				-- 2. КРАСИМ ПОДЛОЖКУ (Чередование)
                if rowBG then
                    if (math.mod(n, 2) == 0) then
                        rowBG:SetVertexColor(1, 1, 1, 0.05) -- Четные (светлый)
                    else
                        rowBG:SetVertexColor(0, 0, 0, 0.25)  -- Нечетные (темный)
                    end
                end

                local remaining = SOTA_LOOTTRACKER_LOOT_WINDOW_TIME - (currentTime - entry.startTime);
                if remaining < 0 then
                    remaining = 0;
                end

                -- Формат MM:SS
                local minutes = math.floor(remaining / 60);
                local seconds = math.floor(math.mod(remaining, 60));
                local timeText = string.format("%02d:%02d", minutes, seconds);

                -- Иконка предмета
                local iconFrame = getglobal("SOTA_LootTrackerRow" .. n .. "Icon");
                if iconFrame then
                    iconFrame:SetNormalTexture(entry.iconTexture or "Interface\\ICONS\\INV_Misc_QuestionMark");
                end

                -- Имя победителя или "АУКЦИОН НЕ ПРОВЕДЕН"
                local winnerButton = getglobal("SOTA_LootTrackerRow" .. n .. "WinnerButton");
                local winnerText = getglobal("SOTA_LootTrackerRow" .. n .. "WinnerButtonText");
                if winnerText then
                    if entry.winnerName then
                        winnerText:SetText(entry.winnerName);
                        -- Цвет класса
                        local color = SOTA_GetClassColorCodes(entry.winnerClass or "");
                        winnerText:SetTextColor(color[1] / 255, color[2] / 255, color[3] / 255, 1);
                        -- Показываем фон кнопки только если есть победитель
                        if winnerButton then
                            winnerButton:Enable();
                        end
                    else
                        winnerText:SetText("АУКЦИОН НЕ ПРОВЕДЕН");
                        winnerText:SetTextColor(0.5, 0.5, 0.5, 1);
                        -- Отключаем кнопку если нет победителя
                        if winnerButton then
                            winnerButton:Disable();
                        end
                    end
                end

                -- Время
                local timerText = getglobal("SOTA_LootTrackerRow" .. n .. "Timer");
                if timerText then
                    timerText:SetText(timeText);
                    -- Цвет таймера: красный если < 2 мин, жёлтый если < 5 мин, зелёный иначе
                    if remaining < 120 then
                        timerText:SetTextColor(1, 0.2, 0.2, 1);
                    elseif remaining < 300 then
                        timerText:SetTextColor(1, 1, 0.2, 1);
                    else
                        timerText:SetTextColor(0.2, 1, 0.2, 1);
                    end
                end

                row:Show();
            else
                row:Hide();
            end
        end
    end
end

--[[
--	Показать тултип предмета при наведении на иконку
--]]
function SOTA_LootTracker_OnIconEnter(rowIndex)
    local entry = SOTA_LootTracker[rowIndex];
    if not entry or not entry.itemLink then
        return;
    end

    local iconFrame = getglobal("SOTA_LootTrackerRow" .. rowIndex .. "Icon");
    if iconFrame then
        GameTooltip:SetOwner(iconFrame, "ANCHOR_RIGHT");
        -- Извлекаем ID для надежности, так как полный itemLink иногда не работает в Tooltip
        local _, _, itemID = string.find(entry.itemLink, "item:(%d+):");
        if itemID then
            GameTooltip:SetHyperlink("item:" .. itemID .. ":0:0:0");
        else
            GameTooltip:SetHyperlink(entry.itemLink);
        end
        GameTooltip:Show();
    end
end

function SOTA_LootTracker_OnIconLeave()
    GameTooltip:Hide();
end

--[[
--	Клик по имени победителя — таргет + попытка трейда
--]]
function SOTA_LootTracker_OnPlayerClick(rowIndex)
    local entry = SOTA_LootTracker[rowIndex];
    if not entry or not entry.winnerName then
        return;
    end

    TargetByName(entry.winnerName, true);
    InitiateTrade("target");
end

--[[
--	UI: показать/скрыть/переключить окно Loot Tracker
--]]
function SOTA_LootTracker_ShowUI()
    if SOTA_LootTrackerFrame then
        SOTA_LootTrackerFrame:Show();
        SOTA_LootTracker_RefreshUI();
        debugEcho("LootTracker: UI открыт");
    end
end

function SOTA_LootTracker_HideUI()
    if SOTA_LootTrackerFrame then
        SOTA_LootTrackerFrame:Hide();
        debugEcho("LootTracker: UI закрыт");
    end
end

function SOTA_LootTracker_ToggleUI()
    if SOTA_LootTrackerFrame then
        if SOTA_LootTrackerFrame:IsVisible() then
            SOTA_LootTracker_HideUI();
        else
            SOTA_LootTracker_ShowUI();
        end
    end
end

--[[
--	Оригинальная функция из WoW API
--]]
local SOTA_Orig_GiveMasterLoot;

--[[
--	Хук функции GiveMasterLoot для трекинга предметов, взятых МЛ себе
--	Вызывается клиентом каждый раз при распределении Мастер Лута.
--]]
local function SOTA_Hooked_GiveMasterLoot(slot, index)
    -- Проверяем, отдается ли предмет самому себе
    local playerName = UnitName("player");
    local candidateName = GetMasterLootCandidate(index);
    if candidateName == playerName then
        SOTA_LootTracker_TrackItem(slot);
    end

    -- Вызываем оригинальную функцию
    if SOTA_Orig_GiveMasterLoot then
        SOTA_Orig_GiveMasterLoot(slot, index);
    end
end

--[[
--	Регистрация событий при загрузке фрейма (вызывается из XML OnLoad)
--]]
function SOTA_LootTracker_OnLoad()
    -- Устанавливаем хук
    if not SOTA_Orig_GiveMasterLoot then
        SOTA_Orig_GiveMasterLoot = GiveMasterLoot;
        GiveMasterLoot = SOTA_Hooked_GiveMasterLoot;
        debugEcho("LootTracker: Хук GiveMasterLoot установлен");
    end

    -- Регистрируем события на фрейме SOTA_LootTrackerEventFrame
    local eventFrame = getglobal("SOTA_LootTrackerEventFrame");
    if eventFrame then
        eventFrame:RegisterEvent("LOOT_BIND_CONFIRM");
        eventFrame:RegisterEvent("LOOT_CLOSED");
    end

    -- СЛЕШ-КОМАНДА ДЛЯ ТЕСТА БОССОВ
    SLASH_SOTABOSS1 = "/tlboss";
    SlashCmdList["SOTABOSS"] = function()
        local targetName = UnitName("target");
        if not targetName then
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA] У вас нет цели!|r");
            return;
        end

        if T_Lib and T_Lib.IsBoss then
            if T_Lib:IsBoss(targetName) then
                DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA] ЦЕЛЬ '" .. targetName .. "' ЯВЛЯЕТСЯ БОССОМ!|r");
            else
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA] ЦЕЛЬ '" .. targetName .. "' НЕ БОСС!|r");
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA] T_Lib НЕ ЗАГРУЖЕНА!|r");
        end
    end;

    debugEcho("LootTracker: модуль загружен");
end

--[[
--	Диспетчер событий (вызывается из XML OnEvent)
--]]
function SOTA_LootTracker_OnEvent(event, arg1)
    if event == "LOOT_BIND_CONFIRM" then
        SOTA_LootTracker_TrackItem(arg1);
    elseif event == "LOOT_CLOSED" then
        -- Можно добавить обработку закрытия окна лута
    end
end
