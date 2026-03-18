--[[
--	SOTA - System Of Treasure Allocation
--
--	Unit: sota-loottracker.lua
--	Модуль отслеживания 10-минутного таймера на передачу BoP предметов,
--	полученных Мастером Лутером с боссов в рейде.
--]]

-- === НАСТРОЙКИ LOOT TRACKER ===
local SOTA_LOOTTRACKER_MIN_QUALITY = 3            -- Минимальное качество: 0 (Poor (серый)), 1 (Common (белый)), 2 (Uncommon (зелёный)), 3 (Rare (синий)), 4 (Epic (фиол)), 5 (Legendary (оранж))
local SOTA_LOOTTRACKER_REQUIRE_RAID = true        -- true: только в рейде
local SOTA_LOOTTRACKER_REQUIRE_INSTANCE = false   -- true: только в инстансе
local SOTA_LOOTTRACKER_REQUIRE_BOSS = true        -- true: проверять, что цель - босс (для тестирования ставим false)
local SOTA_LOOTTRACKER_UPDATE_INTERVAL = 0.5      -- Интервал обновления UI (сек)
local SOTA_LOOTTRACKER_LOOT_WINDOW_TIME = 600     -- Время на передачу (сек), 600 = 10 мин
local SOTA_LOOTTRACKER_MAX_ROWS = 10              -- Максимум строк в UI

-- === НАСТРОЙКИ LOOT LINK (авто-линки лута при открытии босса) ===
local SOTA_LOOTLINK_MIN_QUALITY = 3               -- Мин. качество для линков: 0 (Poor (серый)), 1 (Common (белый)), 2 (Uncommon (зелёный)), 3 (Rare (синий)), 4 (Epic (фиол)), 5 (Legendary (оранж))
local SOTA_LOOTLINK_ROLE_MODE = 3                 -- 1 = только Рейд Лидер, 2 = только Мастер Лут, 3 = РЛ + МЛ + Ассист
local SOTA_LOOTLINK_COOLDOWN = 60                -- Кулдаун между линками (сек), 60 = 1 минута

-- Переменная для хранения времени последнего линка
local SOTA_LootLink_LastLinkTime = nil;

-- Кириллический шрифт для динамических элементов
local CYRILLIC_FONT_PATH = "Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf";

-- Таблица активных записей (рантайм, не сохраняется)
SOTA_LootTracker = {};

-- Накопитель для троттлинга OnUpdate
local SOTA_LootTracker_Elapsed = 0;

--[[
--	Создание записи в таблице отслеживания
--]]
local function SOTA_LootTracker_CreateEntry(itemLink, itemName, iconTexture, startTime, bossName, itemColor)
    -- Проверка на максимальное количество записей
    if table.getn(SOTA_LootTracker) >= SOTA_LOOTTRACKER_MAX_ROWS then
        debugEcho("SOTA LootTracker: достигнут лимит записей (" .. SOTA_LOOTTRACKER_MAX_ROWS .. "), пропускаем создание");
        return nil;
    end

    local entry = {
        itemLink = itemLink,
        itemName = itemName,
        iconTexture = iconTexture,
        startTime = startTime,
        bossName = bossName,
        winnerName = nil,
        winnerClass = nil,
        itemColor = itemColor or "ffffffff", -- Сохраняем цвет для поп-апа
    };
    table.insert(SOTA_LootTracker, entry);
    debugEcho("SOTA LootTracker: создана запись для " .. (itemName or "?") .. " с босса " .. (bossName or "?"));
    return entry;
end

--[[
--	Обработчик события LOOT_BIND_CONFIRM и срабатывания хука GiveMasterLoot
--]]
function SOTA_LootTracker_TrackItem(slot)
    -- Фильтр 1: Только в рейде
    if SOTA_LOOTTRACKER_REQUIRE_RAID then
        if GetNumRaidMembers() == 0 then
            debugEcho("SOTA LootTracker: Отклонено (игрок не в рейде)");
            return;
        end
    end

    -- Фильтр 2: Только в режиме Мастер-Лут
    local lootMethod = GetLootMethod();
    if lootMethod ~= "master" then
        debugEcho("SOTA LootTracker: Отклонено (режим лута не master, а " .. tostring(lootMethod) .. ")");
        return;
    end

    -- Фильтр 4: Проверка на босса через таргет
    local targetName = UnitName("target");
    if not targetName then
        debugEcho("SOTA LootTracker: нет таргета, запись не создана");
        return;
    end

    -- Фильтр 5: Проверка через T-Lib (только если SOTA_LOOTTRACKER_REQUIRE_BOSS = true)
    if SOTA_LOOTTRACKER_REQUIRE_BOSS then
        if not T_Lib or not T_Lib.IsBoss then
            debugEcho("SOTA LootTracker: T_Lib не загружена, запись не создана");
            return;
        end
        if not T_Lib:IsBoss(targetName) then
            debugEcho("SOTA LootTracker: " .. targetName .. " не является боссом (T_Lib)");
            return;
        end
    end

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
             debugEcho("SOTA LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") - не удалось определить качество по ссылке!");
        elseif itemQuality < SOTA_LOOTTRACKER_MIN_QUALITY then
             debugEcho("SOTA LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") отклонен (качество " .. tostring(itemQuality) .. " < " .. tostring(SOTA_LOOTTRACKER_MIN_QUALITY) .. ")");
        else
            -- Качество подходит конкретно
            -- Проверяем дубликат (тот же itemLink уже отслеживается)
            local isDuplicate = false;
            for n = 1, table.getn(SOTA_LootTracker), 1 do
                if SOTA_LootTracker[n].itemLink == itemLink then
                    isDuplicate = true;
                    debugEcho("SOTA LootTracker: Слот " .. slot .. " (" .. tostring(name) .. ") уже отслеживается");
                    break;
                end
            end

            if not isDuplicate then
                -- Извлекаем цвет предмета из itemLink для поп-апа
                local itemColor = "ffffffff"; -- По умолчанию белый
                local _, _, colorStr = string.find(itemLink, "|c(%x%x%x%x%x%x%x%x)|H");
                if colorStr then
                    itemColor = string.lower(colorStr);
                end

                -- Создаём запись (передаём цвет предмета из itemLink)
                local startTime = GetTime();
                SOTA_LootTracker_CreateEntry(itemLink, name, icon, startTime, targetName, itemColor);

                debugEcho("SOTA LootTracker: создана запись для " .. name .. " с босса " .. (targetName or "Неизвестно"));

                -- Обновляем UI, но не показываем его принудительно (чтобы не мешать)
                if SOTA_LootTrackerFrame and SOTA_LootTrackerFrame:IsVisible() then
                    SOTA_LootTracker_RefreshUI();
                end
            end
        end
    else
        debugEcho("SOTA LootTracker: Слот " .. slot .. " - нет itemLink (возможно золото/квест итем)");
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
        debugEcho("SOTA LootTracker: не удалось извлечь имя предмета из " .. auctionItemLink);
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

            debugEcho("SOTA LootTracker: победитель " .. winnerName .. " записан для " .. (entry.itemName or "?"));

            -- Показываем UI, если он был скрыт, так как аукцион завершён
            SOTA_LootTracker_ShowUI();

            return;
        end
    end

    debugEcho("SOTA LootTracker: запись для " .. auctionItemName .. " не найдена (аукцион)");
end

--[[
--	OnUpdate с троттлингом - обновление таймеров
--	Вызывается каждый кадр из XML, мы троттлим до раз в 0.5 сек
--]]
function SOTA_LootTracker_Update(elapsed)
    SOTA_LootTracker_Elapsed = SOTA_LootTracker_Elapsed + elapsed;

    if SOTA_LootTracker_Elapsed < SOTA_LOOTTRACKER_UPDATE_INTERVAL then
        return;
    end
    SOTA_LootTracker_Elapsed = 0;

    -- Если записей нет - ничего не делаем
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
            debugEcho("SOTA LootTracker: запись " .. (entry.itemName or "?") .. " истекла, удаляю");
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
--	Не создаёт новых таблиц - использует заранее созданные фреймы
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
                        winnerText:SetText("БЕЗ ВЛАДЕЛЬЦА");
                        winnerText:SetTextColor(0.5, 0.5, 0.5, 1);
                        -- Отключаем кнопку если нет победителя
                        if winnerButton then
                            winnerButton:Disable();
                        end
                    end
                end

                -- Время (4. Таймер внутри $parentTimerFrame)
                local timerText = getglobal("SOTA_LootTrackerRow" .. n .. "TimerFrameTimer");
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

                -- Имя босса (3. Босс внутри $parentBossFrame)
                local bossText = getglobal("SOTA_LootTrackerRow" .. n .. "BossFrameBoss");
                if bossText then
                    if entry.bossName then
                        bossText:SetText(entry.bossName);
                        bossText:SetTextColor(1, 0.8, 0, 1); -- Золотой цвет
                    else
                        bossText:SetText("---");
                        bossText:SetTextColor(0.5, 0.5, 0.5, 1);
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
--	Клик по иконке предмета - предложение создать аукцион
--	Вызывает поп-ап подтверждение, если аукцион ещё не создан
--]]
function SOTA_LootTracker_OnIconClick(rowIndex)
    local entry = SOTA_LootTracker[rowIndex];
    if not entry or not entry.itemLink then
        debugEcho("SOTA LootTracker: OnIconClick - нет записи или itemLink");
        return;
    end

    -- Если победитель уже есть - аукцион завершён, ничего не делаем
    if entry.winnerName then
        debugEcho("SOTA LootTracker: OnIconClick - победитель уже есть, выход");
        return;
    end

    -- Проверяем состояние аукциона
    if SOTA_GetAuctionState then
        local auctionState = SOTA_GetAuctionState();

        -- STATE_AUCTION_RUNNING (10) - аукцион идёт
        if auctionState == 10 then
            local currentItemLink = SOTA_GetAuctionedItemLink();
            if currentItemLink and currentItemLink == entry.itemLink then
                debugEcho("SOTA LootTracker: аукцион на " .. entry.itemName .. " уже идёт");
                return;
            end
        end

        -- STATE_AUCTION_COMPLETE (30) - аукцион завершён, ждём передачи лута
        -- В этом случае тоже не даём создать новый аукцион на этот предмет
        if auctionState == 30 then
            local currentItemLink = SOTA_GetAuctionedItemLink();
            if currentItemLink and currentItemLink == entry.itemLink then
                debugEcho("SOTA LootTracker: аукцион на " .. entry.itemName .. " завершён, ожидание победителя и передачи предмета");
                return;
            end
        end
    end

    -- Сохраняем itemLink и цвет для использования в поп-апе
    SOTA_LootTracker_PendingItemLink = entry.itemLink;
    SOTA_LootTracker_PendingItemName = entry.itemName or "Неизвестный предмет";
    SOTA_LootTracker_PendingItemColor = entry.itemColor or "ffffffff";

    debugEcho("SOTA LootTracker: показываем поп-ап для " .. SOTA_LootTracker_PendingItemName .. " (цвет: " .. SOTA_LootTracker_PendingItemColor .. ")");

    -- Показываем поп-ап подтверждение
    StaticPopup_Show("SOTA_LOOTTRACKER_CREATE_AUCTION");
end

--[[
--	Клик по имени победителя - таргет + попытка трейда
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
--	Клик по кнопке удаления записи
--]]
function SOTA_LootTracker_OnDeleteClick(rowIndex)
    if not rowIndex or rowIndex < 1 or rowIndex > table.getn(SOTA_LootTracker) then
        return;
    end

    local entry = SOTA_LootTracker[rowIndex];
    local itemName = entry.itemName or "Неизвестный предмет";

    debugEcho("SOTA LootTracker: удаление записи для " .. itemName);

    -- Удаляем запись из таблицы
    table.remove(SOTA_LootTracker, rowIndex);

    -- Обновляем UI
    SOTA_LootTracker_RefreshUI();
end

--[[
--	UI: показать/скрыть/переключить окно Loot Tracker
--]]
function SOTA_LootTracker_ShowUI()
    if SOTA_LootTrackerFrame then
        SOTA_LootTrackerFrame:Show();
        SOTA_LootTracker_RefreshUI();
        debugEcho("SOTA LootTracker: UI открыт");
    end
end

function SOTA_LootTracker_HideUI()
    if SOTA_LootTrackerFrame then
        SOTA_LootTrackerFrame:Hide();
        debugEcho("SOTA LootTracker: UI закрыт");
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
        debugEcho("SOTA LootTracker: Хук GiveMasterLoot установлен");
    end

    -- Регистрируем события на фрейме SOTA_LootTrackerEventFrame
    local eventFrame = getglobal("SOTA_LootTrackerEventFrame");
    if eventFrame then
        eventFrame:RegisterEvent("LOOT_BIND_CONFIRM");
        eventFrame:RegisterEvent("LOOT_CLOSED");
        eventFrame:RegisterEvent("LOOT_OPENED");
    end

    -- Создаём StaticPopupDialog для подтверждения создания аукциона
    SOTA_LootTracker_CreateAuctionDialog();

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

    -- СЛЕШ-КОМАНДА ДЛЯ СОЗДАНИЯ ТЕСТОВЫХ ЗАПИСЕЙ
    SLASH_SOTALOOT1 = "/sotaloot";
    SlashCmdList["SOTALOOT"] = function(msg)
        -- Парсим аргументы: /sotaloot [itemName]|[bossName]
        local itemName = "Тестовый предмет";
        local bossName = "Тестовый Босс";

        if msg and msg ~= "" then
            -- Ищем разделитель |
            local sepPos = string.find(msg, "|", 1, true);
            if sepPos then
                itemName = string.sub(msg, 1, sepPos - 1);
                bossName = string.sub(msg, sepPos + 1);
            else
                itemName = msg;
            end
        end

        -- Создаём тестовую запись
        local fakeItemLink = "|cffff8000|Hitem:" .. math.random(10000, 99999) .. ":0:0:0|h[" .. itemName .. "]|h|r";
        local fakeIcon = "INV_Misc_QuestionMark";
        local fakeColor = "ffff8000";

        local entry = SOTA_LootTracker_CreateEntry(fakeItemLink, itemName, fakeIcon, GetTime(), bossName, fakeColor);

        if entry then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA LootTracker] Создана тестовая запись: " .. itemName .. " с босса " .. bossName .. "|r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA LootTracker] Лимит записей достигнут (" .. SOTA_LOOTTRACKER_MAX_ROWS .. ")!|r");
        end

        -- Показываем UI если скрыт
        if SOTA_LootTrackerFrame and not SOTA_LootTrackerFrame:IsVisible() then
            SOTA_LootTracker_ShowUI();
        else
            SOTA_LootTracker_RefreshUI();
        end
    end;

    -- СЛЕШ-КОМАНДА ДЛЯ НАСТРОЙКИ LOOTLINK
    SLASH_SOTALOOTLINK1 = "/sotalootlink";
    SlashCmdList["SOTALOOTLINK"] = function(msg)
        -- Парсим команду: /sotalootlink quality 4 | mode 3
        local cmd = nil;
        local value = nil;

        if msg and msg ~= "" then
            -- Ищем первый пробел
            local spacePos = string.find(msg, " ", 1, true);
            if spacePos then
                cmd = string.sub(msg, 1, spacePos - 1);
                local valueStr = string.sub(msg, spacePos + 1);
                value = tonumber(valueStr);
            else
                cmd = msg;
            end
        end

        if not cmd then
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA LootLink] Использование:|r");
            DEFAULT_CHAT_FRAME:AddMessage("  /sotalootlink quality [0-5] - мин. качество (0=серый, 1=белый, 2=зелёный, 3=синька, 4=эпик, 5=лега)");
            DEFAULT_CHAT_FRAME:AddMessage("  /sotalootlink mode [1-3] - кто линкует (1=РЛ, 2=МЛ, 3=РЛ+МЛ+Ассист)");
            DEFAULT_CHAT_FRAME:AddMessage("  /sotalootlink cooldown [60-600] - кулдаун в секундах (по умолчанию 180)");
            DEFAULT_CHAT_FRAME:AddMessage("Текущие настройки: quality=" .. SOTA_LOOTLINK_MIN_QUALITY .. ", mode=" .. SOTA_LOOTLINK_ROLE_MODE .. ", cooldown=" .. SOTA_LOOTLINK_COOLDOWN);
            return;
        end

        cmd = string.lower(cmd);
        value = tonumber(value);

        if cmd == "quality" then
            if not value or value < 0 or value > 5 then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA LootLink] Ошибка: качество должно быть 0-5|r");
                return;
            end
            SOTA_LOOTLINK_MIN_QUALITY = value;
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA LootLink] Мин. качество установлено: " .. value .. "|r");
        elseif cmd == "mode" then
            if not value or value < 1 or value > 3 then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA LootLink] Ошибка: режим должен быть 1-3|r");
                return;
            end
            SOTA_LOOTLINK_ROLE_MODE = value;
            local modeDesc = (value == 1 and "Только РЛ") or (value == 2 and "Только МЛ") or "РЛ+МЛ+Ассист";
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA LootLink] Режим установлен: " .. value .. " (" .. modeDesc .. ")|r");
        elseif cmd == "cooldown" then
            if not value or value < 60 or value > 600 then
                DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA LootLink] Ошибка: кулдаун должен быть 60-600 сек|r");
                return;
            end
            SOTA_LOOTLINK_COOLDOWN = value;
            DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[SOTA LootLink] Кулдаун установлен: " .. value .. " сек (" .. math.floor(value / 60) .. " мин)|r");
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cFFFF0000[SOTA LootLink] Неизвестная команда: " .. cmd .. "|r");
        end
    end;

    debugEcho("SOTA LootTracker: модуль загружен");
end

--[[
--	Создание StaticPopupDialog для подтверждения создания аукциона
--]]
function SOTA_LootTracker_CreateAuctionDialog()
    -- Определяем диалог
    StaticPopupDialogs["SOTA_LOOTTRACKER_CREATE_AUCTION"] = {
        text = "Создать аукцион на предмет?",
        button1 = "ДА",
        button2 = "ОТМЕНА",
        OnAccept = function()
            -- Пользователь нажал "ДА" - создаём аукцион
            if SOTA_LootTracker_PendingItemLink then
                debugEcho("SOTA LootTracker: создание аукциона на " .. SOTA_LootTracker_PendingItemName);
                -- Вызываем SOTA_StartAuction напрямую
                if SOTA_StartAuction then
                    SOTA_StartAuction(SOTA_LootTracker_PendingItemLink);
                else
                    debugEcho("SOTA LootTracker: ОШИБКА - SOTA_StartAuction не доступна!");
                end
                SOTA_LootTracker_PendingItemLink = nil;
                SOTA_LootTracker_PendingItemName = nil;
                SOTA_LootTracker_PendingItemColor = nil;
            end
        end,
        OnCancel = function()
            -- Пользователь нажал "ОТМЕНА"
            debugEcho("SOTA LootTracker: отмена создания аукциона");
            SOTA_LootTracker_PendingItemLink = nil;
            SOTA_LootTracker_PendingItemName = nil;
            SOTA_LootTracker_PendingItemColor = nil;
        end,
        OnShow = function()
            -- В WoW 1.12 OnShow для StaticPopupDialog не получает self, используем this
            debugEcho("SOTA LootTracker: OnShow диалога вызван, this = " .. tostring(this));

            -- Применяем стили при показе диалога
            local dialogName = this:GetName();
            debugEcho("SOTA LootTracker: имя диалога = " .. tostring(dialogName));

            SOTA_StyleStaticPopup(dialogName);
            SOTA_StyleStaticPopupButtons(dialogName);

            -- Устанавливаем текст с именем предмета и применяем кириллический шрифт
            local text = getglobal(dialogName .. "Text");
            if text and SOTA_LootTracker_PendingItemName then
                text:SetFont(CYRILLIC_FONT_PATH, 12);
                -- Красим имя предмета в цвет качества (формат: |cAARRGGBB)
                local itemColor = SOTA_LootTracker_PendingItemColor or "ffffffff";
                text:SetText("Создать аукцион на предмет:\n\n|c" .. itemColor .. SOTA_LootTracker_PendingItemName .. "|r?");
                debugEcho("SOTA LootTracker: текст установлен для " .. SOTA_LootTracker_PendingItemName .. " (цвет: " .. itemColor .. ")");
            else
                debugEcho("SOTA LootTracker: не удалось установить текст (text=" .. tostring(text) .. ", name=" .. tostring(SOTA_LootTracker_PendingItemName) .. ")");
            end
        end,
        timeout = 0, -- Без таймаута
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3, -- Чтобы не конфликтовал с другими диалогами
    };
end

--[[
--	Диспетчер событий (вызывается из XML OnEvent)
--]]
function SOTA_LootTracker_OnEvent(event, arg1)
    if event == "LOOT_BIND_CONFIRM" then
        SOTA_LootTracker_TrackItem(arg1);
    elseif event == "LOOT_CLOSED" then
    elseif event == "LOOT_OPENED" then
        SOTA_LootLink_OnLootOpen();
    elseif event == "RAID_ROSTER_UPDATE" then
        -- Очищаем кулдаун только если рейд распался
        if GetNumRaidMembers() == 0 then
            SOTA_LootLink_LastLinkTime = nil;
            debugEcho("SOTA LootLink: рейд распался, кулдаун сброшен");
        end
    end
end

-- =============================================================================
-- === LOOT LINK: Авто-линки лута в рейд при открытии босса ===
-- =============================================================================
-- Функция проверяет роль игрока и таргет на босса, затем линкует в рейд
-- все предметы указанного качества и выше из лута босса.
-- =============================================================================

--[[
--	Проверка прав игрока на линкование лута
--	Возвращает true, если игрок имеет право линковать
--]]
local function SOTA_LootLink_HasPermission()
    -- Проверка 1: Только в рейде
    if GetNumRaidMembers() == 0 then
        return false;
    end

    -- Проверка 2: Проверяем роль по настройке SOTA_LOOTLINK_ROLE_MODE
    local mode = SOTA_LOOTLINK_ROLE_MODE;

    if mode == 1 then
        -- Только Рейд Лидер
        return IsRaidLeader();
    elseif mode == 2 then
        -- Только Мастер Лут — проверяем, что игрок назначен МЛ
        local lootMethod, lootMaster = GetLootMethod();
        return lootMethod == "master" and lootMaster == 0;
    elseif mode == 3 then
        -- Рейд Лидер + Ассистент + Мастер Лут
        if IsRaidLeader() then
            return true;
        end
        if IsRaidOfficer() then
            return true;
        end
        -- Проверяем, что игрок назначен МЛ
        local lootMethod, lootMaster = GetLootMethod();
        if lootMethod == "master" and lootMaster == 0 then
            return true;
        end
    end

    return false;
end

--[[
--	Основная функция LootLink - линкует лут в рейд
--	Вызывается при событии LOOT_OPENED
--]]
function SOTA_LootLink_OnLootOpen()
    -- Проверка прав
    if not SOTA_LootLink_HasPermission() then
        return;
    end

    -- Проверка кулдауна
    if SOTA_LootLink_LastLinkTime then
        local elapsed = GetTime() - SOTA_LootLink_LastLinkTime;
        if elapsed < SOTA_LOOTLINK_COOLDOWN then
            debugEcho("SOTA LootLink: кулдаун (" .. math.floor(elapsed) .. "/" .. SOTA_LOOTLINK_COOLDOWN .. " сек)");
            return;
        end
    end

    -- Получаем количество предметов в луте
    local numLootItems = GetNumLootItems();
    if numLootItems == 0 then
        return;
    end

    -- Определяем источник лута
    local targetName = UnitName("target");
    local bossName = nil;

    -- Если есть таргет, проверяем через T-Lib (для будущего с локализацией)
    if targetName and T_Lib and T_Lib.IsBoss then
        if T_Lib:IsBoss(targetName) then
            -- Это босс - используем название из библиотеки
            bossName = T_Lib:GetBossName(targetName) or targetName;
        end
    end

    -- Собираем предметы для линковки
    local itemsToLink = {};
    for slot = 1, numLootItems, 1 do
        -- Получаем информацию о предмете
        local icon, itemName, quantity, quality = GetLootSlotInfo(slot);

        -- Если качество не определилось — пропускаем
        if quality then
            -- Проверяем минимальное качество
            if quality >= SOTA_LOOTLINK_MIN_QUALITY then
                -- Получаем itemLink
                local itemLink = GetLootSlotLink(slot);
                if itemLink then
                    -- Добавляем в список
                    table.insert(itemsToLink, {
                        link = itemLink,
                        quantity = quantity
                    });

                    debugEcho("SOTA LootLink: добавлен предмет " .. itemName .. " (качество: " .. quality .. ")");
                else
                    debugEcho("SOTA LootLink: Слот " .. slot .. " - нет itemLink");
                end
            else
                debugEcho("SOTA LootLink: Слот " .. slot .. " (" .. tostring(itemName) .. ") - качество " .. tostring(quality) .. " ниже порога " .. tostring(SOTA_LOOTLINK_MIN_QUALITY));
            end
        else
            debugEcho("SOTA LootLink: Слот " .. slot .. " - не удалось определить качество");
        end
    end

    -- Если нет предметов для линковки - выходим
    if table.getn(itemsToLink) == 0 then
        return;
    end

    -- Отправляем заголовок
    local header;
    if bossName then
        header = "Добыча с [" .. bossName .. "]:";
    else
        header = "Добыча:";
    end
    SendChatMessage(header, "RAID");

    -- Отправляем каждый предмет отдельным сообщением с номером
    for i = 1, table.getn(itemsToLink), 1 do
        local item = itemsToLink[i];
        local lootMessage = i .. ". " .. item.link;
        if item.quantity and item.quantity > 1 then
            lootMessage = lootMessage .. " (x" .. item.quantity .. ")";
        end
        SendChatMessage(lootMessage, "RAID");
    end

    -- Запоминаем время линка
    SOTA_LootLink_LastLinkTime = GetTime();

    debugEcho("SOTA LootLink: залинковано предметов: " .. table.getn(itemsToLink));
end
