--[[
--	SOTA - System Of Treasure Allocation
--
--	Unit: sota-options.lua
--	This holds the options (configuration) dialogue of SOTA plus
--	underlying functionality to support changing the options.
--]]

local SOTA_MAX_MESSAGES       = 15
local ConfigurationDialogOpen = false;

-- =================================================================================
-- Стилизация EditBox в FrameEventEditor (тёмный фон + серая рамка)
-- Применяется только к окну редактирования сообщений, не затрагивает стандартные EditBox Blizzard
-- =================================================================================
function SOTA_StyleEventEditorEditBox()
    if FrameEventEditorMessage then
        FrameEventEditorMessage:DisableDrawLayer("BACKGROUND");
        FrameEventEditorMessage:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8X8",
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            tile = true,
            edgeSize = 1,
            tileSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        });
        FrameEventEditorMessage:SetBackdropColor(0.784, 0.294, 0.192, 1);
        FrameEventEditorMessage:SetBackdropBorderColor(0.251, 0.251, 0.251, 1);
        FrameEventEditorMessage:SetTextInsets(5, 4, 2, 4);
        FrameEventEditorMessage:SetTextColor(0.925, 0.859, 0.729, 1);
        FrameEventEditorMessage:SetAutoFocus(false);  -- Отключаем автофокус для корректной работы Esc

        -- Добавляем реакцию на фокус (изменение цвета рамки)
        FrameEventEditorMessage:SetScript("OnEditFocusGained", function()
            this:SetBackdropBorderColor(0.784, 0.294, 0.192, 1);  -- accent-main (оранжевая)
        end);

        FrameEventEditorMessage:SetScript("OnEditFocusLost", function()
            this:SetBackdropBorderColor(0.251, 0.251, 0.251, 1);  -- border-main (серая)
        end);

        -- Обработка Esc: снимаем фокус
        FrameEventEditorMessage:SetScript("OnEscapePressed", function()
            this:ClearFocus();
            this:SetBackdropBorderColor(0.251, 0.251, 0.251, 1);  -- border-main (серая)
        end);
    end
end

-- =================================================================================
-- Стилизация кнопок в FrameEventEditor (тёмный фон + серая рамка + оранжевый акцент)
-- Применяется только к кнопкам ОК и ОТМЕНА в окне редактирования сообщений
-- =================================================================================
function SOTA_StyleEventEditorButtons()
    -- OK button
    local button1 = getglobal("OkButton");
    if button1 then
        button1:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1);
        button1:GetFontString():SetPoint("CENTER", button1, "CENTER", 0, 1);
        button1:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            bgFile = "Interface\\Buttons\\WHITE8X8",
            tile = true,
            edgeSize = 1,
            tileSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        });
        button1:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
        button1:SetBackdropBorderColor(0.251, 0.251, 0.251, 1); -- border-main
        button1:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1); -- text-main
        button1:GetFontString():SetPoint("CENTER", button1, "CENTER", 0, 2);
        button1:SetNormalTexture("");
        button1:SetPushedTexture("");
        button1:SetHighlightTexture("");
        button1:SetPushedTextOffset(0, 0);

        button1:SetScript("OnEnter", function()
            this:SetBackdropColor(0.098, 0.098, 0.098, 1);
        end);
        button1:SetScript("OnLeave", function()
            this:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
        end);
        button1:SetScript("OnMouseDown", function()
            this:SetBackdropColor(0.098, 0.098, 0.098, 1);
            this:GetFontString():SetTextColor(0.784, 0.294, 0.192, 1);
        end);
        button1:SetScript("OnMouseUp", function()
            this:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
            this:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1); -- text-main
        end);
    end

    -- Cancel button
    local button2 = getglobal("CancelButton");
    if button2 then
        button2:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1);
        button2:GetFontString():SetPoint("CENTER", button2, "CENTER", 0, 1);
        button2:SetBackdrop({
            edgeFile = "Interface\\Buttons\\WHITE8X8",
            bgFile = "Interface\\Buttons\\WHITE8X8",
            tile = true,
            edgeSize = 1,
            tileSize = 16,
            insets = { left = 0, right = 0, top = 0, bottom = 0 }
        });
        button2:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
        button2:SetBackdropBorderColor(0.251, 0.251, 0.251, 1);
        button2:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1); -- text-main
        button2:GetFontString():SetPoint("CENTER", button2, "CENTER", 0, 2);
        button2:SetNormalTexture("");
        button2:SetPushedTexture("");
        button2:SetHighlightTexture("");
        button2:SetPushedTextOffset(0, 0);

        button2:SetScript("OnEnter", function()
            this:SetBackdropColor(0.098, 0.098, 0.098, 1);
        end);
        button2:SetScript("OnLeave", function()
            this:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
        end);
        button2:SetScript("OnMouseDown", function()
            this:SetBackdropColor(0.098, 0.098, 0.098, 1);
            this:GetFontString():SetTextColor(0.784, 0.294, 0.192, 1);
        end);
        button2:SetScript("OnMouseUp", function()
            this:SetBackdropColor(0.145, 0.145, 0.145, 1); -- bg-section
            this:GetFontString():SetTextColor(0.925, 0.859, 0.729, 1); -- text-main
        end);
    end
end


function SOTA_EchoEvent(msgKey, item, dkp, bidder, rank, param1, param2, param3)
    local msgInfo = SOTA_getConfigurableMessage(msgKey, item, dkp, bidder, rank, param1, param2, param3);
    publicEcho(msgInfo);
end;

function SOTA_GetEventText(eventName)
    local messages = SOTA_GetConfigurableTextMessages();

    for n = 1, table.getn(messages), 1 do
        if (messages[n][1] == eventName) then
            return messages[n];
        end;
    end

    return nil;
end;

--[[
--	Get configurable message and fill out placeholders:
--	Parameters:
--	%i: Item, %d: DKP, %b: Bidder, %r: Rank, $1,$2,$3: params (percent, players in range, players in queue etc)
--	Automatic gathered:
--	%m: Min DKP, %s: SOTA master
--]]
function SOTA_getConfigurableMessage(msgKey, item, dkp, bidder, rank, param1, param2, param3)
    local msgInfo = SOTA_GetEventText(msgKey);

    if (not msgInfo) then
        localEcho("*** Упс, SOTA_CONFIG_Messages[" .. msgKey .. "] не найден");
        return nil;
    end;

    if not (item) then item = ""; end;
    if not (dkp) then dkp = ""; end;
    if not (bidder) then bidder = ""; end;
    if not (rank) then rank = ""; end;
    if not (param1) then param1 = ""; end;
    if not (param2) then param2 = ""; end;
    if not (param3) then param3 = ""; end;

    local msg = msgInfo[3];
    msg = string.gsub(msg, "$i", "" .. item);
    msg = string.gsub(msg, "$d", "" .. dkp);
    msg = string.gsub(msg, "$b", "" .. bidder);
    msg = string.gsub(msg, "$r", "" .. rank);
    msg = string.gsub(msg, "$m", "" .. SOTA_GetMinimumBid());
    msg = string.gsub(msg, "$s", UnitName("player"));
    msg = string.gsub(msg, "$1", "" .. param1);
    msg = string.gsub(msg, "$2", "" .. param2);
    msg = string.gsub(msg, "$3", "" .. param3);

    return { msgInfo[1], msgInfo[2], msg };
end;

function SOTA_SetConfigurableMessage(event, channel, message)
    --echo("Saving new message: Event: "..event..", Channel: "..channel..", Message: "..message);
    local messages = SOTA_GetConfigurableTextMessages();

    for n = 1, table.getn(messages), 1 do
        if (messages[n][1] == event) then
            messages[n] = { event, channel, message };
            SOTA_SetConfigurableTextMessages(messages);
            return;
        end;
    end;
end;

--[[
--	Copy the updated frame pos to frame siblings.
--	Since: 1.2.0
--]]
function SOTA_UpdateFramePos(frame)
    local framename = frame:GetName();

    if (framename ~= "FrameConfigBidding") then
        FrameConfigBidding:SetAllPoints(frame);
    end
    if (framename ~= "FrameConfigBossDkp") then
        FrameConfigBossDkp:SetAllPoints(frame);
    end
    if (framename ~= "FrameConfigMiscDkp") then
        FrameConfigMiscDkp:SetAllPoints(frame);
    end
    if (framename ~= "FrameConfigMessage") then
        FrameConfigMessage:SetAllPoints(frame);
    end
    if (framename ~= "FrameConfigBidRules") then
        FrameConfigBidRules:SetAllPoints(frame);
    end
    if (framename ~= "FrameConfigSyncCfg") then
        FrameConfigSyncCfg:SetAllPoints(frame);
    end
end;

function SOTA_OpenConfigurationUI()
    ConfigurationDialogOpen = true;
    SOTA_RefreshBossDKPValues();

    -- Устанавливаем текст подсказки для Boss DKP (две строки)
    getglobal("FrameConfigBossDkpExplanationLine1"):SetText(
        "МИНИМАЛЬНАЯ СТАВКА В РЕЙДЕ = ЗНАЧЕНИЕ ПОЛЗУНКА / 10"
    );
    getglobal("FrameConfigBossDkpExplanationLine2"):SetText(
        "ПРИМЕР: ПОЛЗУНОК НА 1000 - МИН. СТАВКА: 100 DKP"
    );

    -- Устанавливаем версию аддона в футере (для всех фреймов)
    local version = GetAddOnMetadata("SOTA", "Version") or "unknown";
    local footerText = "Версия " .. version .. " от |cFFEC3E08Misha|r (Wht Mst)";
    getglobal("FrameConfigBiddingFooter"):SetText(footerText);
    getglobal("FrameConfigBossDkpFooter"):SetText(footerText);
    getglobal("FrameConfigMiscDkpFooter"):SetText(footerText);
    getglobal("FrameConfigMessageFooter"):SetText(footerText);

    -- Показываем Bidding config по умолчанию
    SOTA_OpenBiddingConfig();

    -- Показываем главный фрейм
    FrameConfigBidding:Show();
end

function SOTA_CloseConfigurationUI()
    SOTA_CloseAllConfig();

    ConfigurationDialogOpen = false;
end

function SOTA_CloseAllConfig()
    FrameConfigBidding:Hide();
    FrameConfigBossDkp:Hide();
    FrameConfigMiscDkp:Hide();
    FrameConfigMessage:Hide();
    FrameConfigBidRules:Hide();
    FrameConfigSyncCfg:Hide();
end;

function SOTA_SaveRules_OnClick()
    SOTA_CONFIG_BIDRULES = SOTA_GetBidRules();
end;

function SOTA_HighlightTab(tabIndex)
    -- Подсветка активной вкладки (оранжевый текст)
    local frames = {"FrameConfigBidding", "FrameConfigBossDkp", "FrameConfigMiscDkp", "FrameConfigMessage"};

    for _, frameName in ipairs(frames) do
        for i = 1, 4 do
            local tabText = getglobal(frameName .. "Tab" .. i .. "Text");
            if tabText then
                -- Подсвечиваем вкладку с номером tabIndex на ВСЕХ фреймах
                if i == tabIndex then
                    tabText:SetTextColor(0.784, 0.294, 0.192);  -- Акцентный цвет
                else
                    tabText:SetTextColor(0.925, 0.859, 0.729, 1);    -- Белый для неактивных
                end
            end
        end
    end
end

function SOTA_ToggleConfigurationUI()
    if ConfigurationDialogOpen then
        SOTA_CloseConfigurationUI();
    else
        SOTA_OpenConfigurationUI();
    end;
end;

function SOTA_OpenBiddingConfig()
    SOTA_CloseAllConfig();
    FrameConfigBidding:Show();
    SOTA_HighlightTab(1);
end

function SOTA_OpenBossDkpConfig()
    SOTA_CloseAllConfig();
    FrameConfigBossDkp:Show();
    SOTA_HighlightTab(2);
end

function SOTA_OpenMiscDkpConfig()
    SOTA_CloseAllConfig();
    FrameConfigMiscDkp:Show();
    SOTA_HighlightTab(3);
end

function SOTA_OpenMessageConfig()
    SOTA_CloseAllConfig();
    FrameConfigMessage:Show();
    SOTA_HighlightTab(4);
end

function SOTA_OpenBidRulesConfig()
    SOTA_SetBidRules();
    SOTA_CloseAllConfig();
    FrameConfigBidRules:Show();
end;

function SOTA_OpenSyncCfgConfig()
    SOTA_CloseAllConfig();
    SOTA_RequestUpdateConfigVersion();
    FrameConfigSyncCfg:Show();
end;

function SOTA_OnOptionAuctionTimeChanged(object)
    SOTA_CONFIG_AuctionTime = tonumber(getglobal(object:GetName()):GetValue());

    local valueString = "" .. SOTA_CONFIG_AuctionTime;
    if SOTA_CONFIG_AuctionTime == 0 then
        valueString = "(|cFFEC3E08БЕЗ ТАЙМЕРА|r)";
    end

    local textObj = getglobal(object:GetName() .. "Text");
    textObj:SetText(string.format("Время аукциона: %s сек.", valueString));
    textObj:SetFont("Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf", 12);
    textObj:SetTextColor(1, 1, 1); -- Белый цвет для текст ползунков
end

function SOTA_OnOptionAuctionExtensionChanged(object)
    SOTA_CONFIG_AuctionExtension = tonumber(getglobal(object:GetName()):GetValue());

    local valueString = "" .. SOTA_CONFIG_AuctionExtension;
    if SOTA_CONFIG_AuctionExtension == 0 then
        valueString = "(|cFFEC3E08БЕЗ ПРОДЛЕНИЯ|r)";
    end

    local textObj = getglobal(object:GetName() .. "Text");
    textObj:SetText(string.format("Продление аукциона: %s сек.", valueString));
    textObj:SetFont("Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf", 12);
    textObj:SetTextColor(1, 1, 1); -- Белый цвет для текст ползунков
end

function SOTA_OnOptionDKPStringLengthChanged(object)
    SOTA_CONFIG_DKPStringLength = tonumber(getglobal(object:GetName()):GetValue());

    local valueString = "" .. SOTA_CONFIG_DKPStringLength;
    if SOTA_CONFIG_DKPStringLength == 0 then
        valueString = "(|cFFEC3E08БЕЗ ЛИМИТА|r)";
    end

    local textObj = getglobal(object:GetName() .. "Text");
    textObj:SetText(string.format("Длина DKP-строки: %s", valueString));
    textObj:SetFont("Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf", 12);
    textObj:SetTextColor(1, 1, 1); -- Белый цвет для текст ползунков
end

function SOTA_OnOptionMinimumDKPPenaltyChanged(object)
    SOTA_CONFIG_MinimumDKPPenalty = tonumber(getglobal(object:GetName()):GetValue());

    local valueString = "" .. SOTA_CONFIG_MinimumDKPPenalty;
    if SOTA_CONFIG_MinimumDKPPenalty == 0 then
        valueString = "(|cFFEC3E08ОТСУТСТВУЕТ|r)";
    end

    local textObj = getglobal(object:GetName() .. "Text");
    textObj:SetText(string.format("Минимальный штраф DKP: %s", valueString));
    textObj:SetFont("Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf", 12);
    textObj:SetTextColor(1, 1, 1); -- Белый цвет для текст ползунков
end

function SOTA_RefreshBossDKPValues()
    getglobal("FrameConfigBossDkp_20Mans"):SetValue(SOTA_GetBossDKPValue("20Mans"));
    getglobal("FrameConfigBossDkp_MoltenCore"):SetValue(SOTA_GetBossDKPValue("MoltenCore"));
    getglobal("FrameConfigBossDkp_Onyxia"):SetValue(SOTA_GetBossDKPValue("Onyxia"));
    getglobal("FrameConfigBossDkp_EmeraldSanctum"):SetValue(SOTA_GetBossDKPValue("EmeraldSanctum"));
    getglobal("FrameConfigBossDkp_BlackwingLair"):SetValue(SOTA_GetBossDKPValue("BlackwingLair"));
    getglobal("FrameConfigBossDkp_AQ40"):SetValue(SOTA_GetBossDKPValue("AQ40"));
    getglobal("FrameConfigBossDkp_Naxxramas"):SetValue(SOTA_GetBossDKPValue("Naxxramas"));
    getglobal("FrameConfigBossDkp_WorldBosses"):SetValue(SOTA_GetBossDKPValue("WorldBosses"));
end

function SOTA_OnOptionBossDKPChanged(object)
    local slider = object:GetName();
    local value = tonumber(getglobal(object:GetName()):GetValue());
    local valueString = "";

    if slider == "FrameConfigBossDkp_20Mans" then
        SOTA_SetBossDKPValue("20Mans", value);
        valueString = string.format("-- РЕЙДЫ НА 20 ЧЕЛОВЕК (ZG, AQ20): %d DKP", value);
    elseif slider == "FrameConfigBossDkp_MoltenCore" then
        SOTA_SetBossDKPValue("MoltenCore", value);
        valueString = string.format("-- MOLTEN CORE: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_Onyxia" then
        SOTA_SetBossDKPValue("Onyxia", value);
        valueString = string.format("-- ONYXIA: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_EmeraldSanctum" then
        SOTA_SetBossDKPValue("EmeraldSanctum", value);
        valueString = string.format("-- EMERALD SANCTUM: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_BlackwingLair" then
        SOTA_SetBossDKPValue("BlackwingLair", value);
        valueString = string.format("-- BLACKWING LAIR: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_AQ40" then
        SOTA_SetBossDKPValue("AQ40", value);
        valueString = string.format("-- TEMPLE OF AHN'QIRAJ: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_Naxxramas" then
        SOTA_SetBossDKPValue("Naxxramas", value);
        valueString = string.format("-- NAXXRAMAS: %d DKP", value);
    elseif slider == "FrameConfigBossDkp_WorldBosses" then
        SOTA_SetBossDKPValue("WorldBosses", value);
        valueString = string.format("-- МИРОВЫЕ БОССЫ: %d DKP", value);
    end

    local textObj = getglobal(slider .. "Text");
    textObj:SetText(valueString);
    textObj:SetFont("Interface\\AddOns\\SOTA\\assets\\fonts\\ARIALN.ttf", 12);
    textObj:SetTextColor(1, 1, 1); -- Белый цвет для текст ползунков
end

function SOTA_InitializeConfigSettings()
    if not SOTA_CONFIG_UseGuildNotes then
        SOTA_CONFIG_UseGuildNotes = 0;
    end
    if not SOTA_CONFIG_MinimumBidStrategy then
        SOTA_CONFIG_MinimumBidStrategy = 0;
    end
    if not SOTA_CONFIG_DKPStringLength then
        SOTA_CONFIG_DKPStringLength = 5;
    end
    if not SOTA_CONFIG_MinimumDKPPenalty then
        SOTA_CONFIG_MinimumDKPPenalty = 50;
    end
    if not SOTA_CONFIG_SilentBidding then
        SOTA_CONFIG_SilentBidding = 1; -- По умолчанию 1 (тихий режим)
    end

    -- Кнопка сворачивания/разворачивания панели (по умолчанию развёрнута)
    if SOTA_CONFIG_DashboardButtonsExpanded == nil then
        SOTA_CONFIG_DashboardButtonsExpanded = true;
    end

    -- Update GUI:
    if not SOTA_CONFIG_EnableOSBidding then
        SOTA_CONFIG_EnableOSBidding = 1;
    end
    if not SOTA_CONFIG_EnableZoneCheck then
        SOTA_CONFIG_EnableZoneCheck = 1;
    end
    if not SOTA_CONFIG_EnableOnlineCheck then
        SOTA_CONFIG_EnableOnlineCheck = 1;
    end
    if not SOTA_CONFIG_AllowPlayerPass then
        SOTA_CONFIG_AllowPlayerPass = 1;
    end;
    if not SOTA_CONFIG_DisableDashboard then
        SOTA_CONFIG_DisableDashboard = 1;
    end
    if not SOTA_CONFIG_OutputChannel then
        SOTA_CONFIG_OutputChannel = WARN_CHANNEL;
    end
    if not SOTA_HISTORY_DKP then
        SOTA_HISTORY_DKP = {};
    end


    getglobal("FrameConfigBiddingMSoverOSPriority"):SetChecked(SOTA_CONFIG_EnableOSBidding);
    getglobal("FrameConfigBiddingEnableZonecheck"):SetChecked(SOTA_CONFIG_EnableZoneCheck);
    getglobal("FrameConfigBiddingEnableOnlinecheck"):SetChecked(SOTA_CONFIG_EnableOnlineCheck);
    getglobal("FrameConfigBiddingAllowPlayerPass"):SetChecked(SOTA_CONFIG_AllowPlayerPass);
    getglobal("FrameConfigBiddingDisableDashboard"):SetChecked(SOTA_CONFIG_DisableDashboard);

    if SOTA_CONFIG_UseGuildNotes == 1 then
        getglobal("FrameConfigMiscDkpPublicNotes"):SetChecked(1)
    end

    getglobal("FrameConfigMiscDkpMinBidStrategy" .. SOTA_CONFIG_MinimumBidStrategy):SetChecked(1)
    getglobal("FrameConfigMiscDkpDKPStringLength"):SetValue(SOTA_CONFIG_DKPStringLength);
    getglobal("FrameConfigMiscDkpMinimumDKPPenalty"):SetValue(SOTA_CONFIG_MinimumDKPPenalty);
    getglobal("FrameConfigBiddingAuctionTime"):SetValue(SOTA_CONFIG_AuctionTime);
    getglobal("FrameConfigBiddingAuctionExtension"):SetValue(SOTA_CONFIG_AuctionExtension);

    SOTA_RefreshBossDKPValues();

    SOTA_VerifyEventMessages();
end

function SOTA_VerifyEventMessages()
    -- Syntax: [index] = { EVENT_NAME, CHANNEL, TEXT }
    -- Channel value: 0: Off, 1: RW, 2: Raid, 3: Guild, 4: Yell, 5: Say
    local defaultMessages = {
        { SOTA_MSG_OnOpen,               1, "АУКЦИОН НА ПРЕДМЕТ $i ОТКРЫТ, МИНИМАЛЬНАЯ СТАВКА $m DKP!" },
        { SOTA_MSG_OnAnnounceBid,        2, "Пишите /w $s bid <ваша ставка>" },
        { SOTA_MSG_OnAnnounceMinBid,     0, "Минимальная ставка: $m DKP" }, -- НЕ ИСПОЛЬЗУЕТСЯ
        { SOTA_MSG_On10SecondsLeft,      1, "Осталось 10 секунд для $i" },
        { SOTA_MSG_On9SecondsLeft,       0, "Осталось 9 секунд" },
        { SOTA_MSG_On8SecondsLeft,       0, "Осталось 8 секунд" },
        { SOTA_MSG_On7SecondsLeft,       0, "Осталось 7 секунд" },
        { SOTA_MSG_On6SecondsLeft,       0, "Осталось 6 секунд" },
        { SOTA_MSG_On5SecondsLeft,       1, "Осталось 5 секунд / ТЕКУЩАЯ СТАВКА: $d DKP за $i от $b" },
        { SOTA_MSG_On5SecondsLeftNoBid,  1, "Осталось 5 секунд (СТАВОК НЕТ)" },
        { SOTA_MSG_On4SecondsLeft,       2, "Осталось 4 секунды" },
        { SOTA_MSG_On3SecondsLeft,       2, "Осталось 3 секунды" },
        { SOTA_MSG_On2SecondsLeft,       2, "Осталось 2 секунды" },
        { SOTA_MSG_On1SecondLeft,        2, "Осталась 1 секунда" },
        { SOTA_MSG_OnMainspecBid,        1, "$b ($r) ставит $d DKP на МЕЙН-СПЕК за $i" },
        { SOTA_MSG_OnOffspecBid,         1, "$b ($r) ставит $d DKP на ОФФ-СПЕК за $i" },
        { SOTA_MSG_OnMainspecMaxBid,     1, "$b ($r) пошёл ва-банк ($d DKP) на МЕЙН-СПЕК за $i" },
        { SOTA_MSG_OnOffspecMaxBid,      1, "$b ($r) пошёл ва-банк ($d DKP) на ОФФ-СПЕК за $i" },
        { SOTA_MSG_OnComplete,           2, "$i продан $b ($r) за $d DKP" },
        { SOTA_MSG_OnPause,              2, "Аукцион приостановлен" },
        { SOTA_MSG_OnResume,             2, "Аукцион возобновлен" },
        { SOTA_MSG_OnClose,              1, "АУКЦИОН НА ПРЕДМЕТ $i ЗАВЕРШЕН" },
        { SOTA_MSG_OnCancel,             2, "Аукцион отменён" },
        { SOTA_MSG_OnDKPAdded,           1, "$d DKP добавлено игроку $b" },
        { SOTA_MSG_OnDKPAddedRaid,       1, "$d DKP добавлено всем игрокам в рейде" },
        { SOTA_MSG_OnWelcomeDKP,         1, "Приветственный бонус: $d DKP добавлено всем игрокам в рейде" },
        { SOTA_MSG_OnNoWipeDKP,          1, "Бонус за проход без вайпов: $d DKP добавлено всем игрокам в рейде" },
        { SOTA_MSG_OnNoDeathDKP,         1, "Бонус за проход без смертей: $d DKP добавлено всем игрокам в рейде" },
        { SOTA_MSG_OnRecordDKP,          1, "Бонус за рекорд времени: $d DKP добавлено всем игрокам в рейде" },
        { SOTA_MSG_OnDKPAddedRange,      1, "$d DKP добавлено для $1 игроков в радиусе" },
        { SOTA_MSG_OnDKPAddedQueue,      1, "$d DKP добавлено для $1 игроков в радиусе (включая $2 в очереди)." },
        { SOTA_MSG_OnDKPSubtract,        1, "$d DKP снято с игрока $b" },
        { SOTA_MSG_OnDKPSubtractRaid,    1, "$d DKP снято со всех игроков в рейде" },
        { SOTA_MSG_OnDKPPercent,         1, "$1 % ($d DKP) вычтено из $b" },
        { SOTA_MSG_OnDKPShared,          1, "$1 DKP распределено ($d DKP на игрока)" },
        { SOTA_MSG_OnDKPSharedQueue,     1, "$1 DKP распределено ($d DKP на игрока плюс $2 в очереди)" },
        { SOTA_MSG_OnDKPSharedRange,     1, "$1 DKP распределено для $2 игроков в радиусе ($d DKP на игрока)" },
        { SOTA_MSG_OnDKPSharedRangeQ,    1, "$1 DKP распределено для $2 игроков в радиусе ($d DKP на игрока, включая $3 в очереди)" },
        { SOTA_MSG_OnDKPReplaced,        1, "$1 заменен на $2 ($d DKP)" }
    }

    -- Merge default messages into saved messages; in case we added some new event names.
    local messages = SOTA_GetConfigurableTextMessages();
    if not messages or table.getn(messages) == 0 then
        SOTA_SetConfigurableTextMessages(defaultMessages);
        return;
    end;

    --echo("--- Merging messages");
    for n = 1, table.getn(defaultMessages), 1 do
        local foundMessage = false;
        for f = 1, table.getn(messages), 1 do
            if (messages[f][1] == defaultMessages[n][1]) then
                foundMessage = true;
                --				echo("Found msg: ".. messages[f][1]);
                break;
            end;
        end;

        if (not foundMessage) then
            --			echo("Adding message: ".. defaultMessages[n][1]);
            messages[table.getn(messages) + 1] = defaultMessages[n];
        end;
    end

    SOTA_SetConfigurableTextMessages(messages);
end;

function SOTA_HandleCheckbox(checkbox)
    local checkboxname = checkbox:GetName();

    --	Enable MS>OS priority:
    if checkboxname == "FrameConfigBiddingMSoverOSPriority" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_EnableOSBidding = 1;
        else
            SOTA_CONFIG_EnableOSBidding = 0;
        end
        return;
    end

    --	Enable RQ Zonecheck:
    if checkboxname == "FrameConfigBiddingEnableZonecheck" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_EnableZoneCheck = 1;
        else
            SOTA_CONFIG_EnableZoneCheck = 0;
        end
        return;
    end

    --	Enable RQ Onlinecheck:
    if checkboxname == "FrameConfigBiddingEnableOnlinecheck" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_EnableOnlineCheck = 1;
        else
            SOTA_CONFIG_EnableOnlineCheck = 0;
        end
        return;
    end

    --	Allow Player Pass:
    if checkboxname == "FrameConfigBiddingAllowPlayerPass" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_AllowPlayerPass = 1;
        else
            SOTA_CONFIG_AllowPlayerPass = 0;
        end
        return;
    end

    --	Disable Dashboard:
    if checkboxname == "FrameConfigBiddingDisableDashboard" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_DisableDashboard = 1;
            SOTA_CloseDashboard();
        else
            SOTA_CONFIG_DisableDashboard = 0;
        end
        return;
    end


    --	Store DKP in Public Notes:
    if checkboxname == "FrameConfigMiscDkpPublicNotes" then
        if checkbox:GetChecked() then
            SOTA_CONFIG_UseGuildNotes = 1;
        else
            SOTA_CONFIG_UseGuildNotes = 0;
        end
        return;
    end

    if checkbox:GetChecked() then
        --	Bid type:
        --	If checked, then we need to uncheck others in same group:
        if checkboxname == "FrameConfigMiscDkpMinBidStrategy0" then
            getglobal("FrameConfigMiscDkpMinBidStrategy1"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy2"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy3"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy4"):SetChecked(0);
            SOTA_CONFIG_MinimumBidStrategy = 0;
        elseif checkboxname == "FrameConfigMiscDkpMinBidStrategy1" then
            getglobal("FrameConfigMiscDkpMinBidStrategy0"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy2"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy3"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy4"):SetChecked(0);
            SOTA_CONFIG_MinimumBidStrategy = 1;
        elseif checkboxname == "FrameConfigMiscDkpMinBidStrategy2" then
            getglobal("FrameConfigMiscDkpMinBidStrategy0"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy1"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy3"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy4"):SetChecked(0);
            SOTA_CONFIG_MinimumBidStrategy = 2;
        elseif checkboxname == "FrameConfigMiscDkpMinBidStrategy3" then
            getglobal("FrameConfigMiscDkpMinBidStrategy0"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy1"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy2"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy4"):SetChecked(0);
            SOTA_CONFIG_MinimumBidStrategy = 3;
        elseif checkboxname == "FrameConfigMiscDkpMinBidStrategy4" then
            getglobal("FrameConfigMiscDkpMinBidStrategy0"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy1"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy2"):SetChecked(0);
            getglobal("FrameConfigMiscDkpMinBidStrategy3"):SetChecked(0);
            SOTA_CONFIG_MinimumBidStrategy = 4;
        end
    end
end

local currentEvent;
function SOTA_OnEventMessageClick(object)
    local event = getglobal(object:GetName() .. "Event"):GetText();
    local channel = 1 * getglobal(object:GetName() .. "Channel"):GetText();
    local message = getglobal(object:GetName() .. "Message"):GetText();

    currentEvent = event;

    if not message then
        message = "";
    end

    --	echo("** Event: "..event..", Channel: "..channel..", Message: "..message);

    local frame = getglobal("FrameEventEditor");
    getglobal(frame:GetName() .. "Message"):SetText(message);

    getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(0);
    getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(0);
    getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(0);
    getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(0);
    getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(0);

    if channel == 1 then
        getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(1);
    elseif channel == 2 then
        getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(1);
    elseif channel == 3 then
        getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(1);
    elseif channel == 4 then
        getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(1);
    elseif channel == 5 then
        getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(1);
    end
    -- Yes, channel can be disabled (0) = nothing is written.

    -- Стилизация EditBox и кнопок перед открытием
    SOTA_StyleEventEditorEditBox();
    SOTA_StyleEventEditorButtons();

    FrameEventEditor:Show();
    FrameEventEditorMessage:SetFocus();
end

function SOTA_OnEventCheckboxClick(checkbox)
    local checkboxname = checkbox:GetName();
    local frame = getglobal("FrameEventEditor");

    if checkboxname == "FrameEventEditorCheckbuttonRW" then
        if checkbox:GetChecked() then
            getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(0);
        end;
    elseif checkboxname == "FrameEventEditorCheckbuttonRaid" then
        if checkbox:GetChecked() then
            getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(0);
        end;
    elseif checkboxname == "FrameEventEditorCheckbuttonGuild" then
        if checkbox:GetChecked() then
            getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(0);
        end;
    elseif checkboxname == "FrameEventEditorCheckbuttonYell" then
        if checkbox:GetChecked() then
            getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonSay"):SetChecked(0);
        end;
    elseif checkboxname == "FrameEventEditorCheckbuttonSay" then
        if checkbox:GetChecked() then
            getglobal(frame:GetName() .. "CheckbuttonRW"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonRaid"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonGuild"):SetChecked(0);
            getglobal(frame:GetName() .. "CheckbuttonYell"):SetChecked(0);
        end;
    end;
end;

function SOTA_OnEventEditorSave()
    local event = currentEvent;
    local message = FrameEventEditorMessage:GetText();
    local channel = 0;

    local frame = getglobal("FrameEventEditor");

    if getglobal(frame:GetName() .. "CheckbuttonRW"):GetChecked() then
        channel = 1
    elseif getglobal(frame:GetName() .. "CheckbuttonRaid"):GetChecked() then
        channel = 2
    elseif getglobal(frame:GetName() .. "CheckbuttonGuild"):GetChecked() then
        channel = 3
    elseif getglobal(frame:GetName() .. "CheckbuttonYell"):GetChecked() then
        channel = 4
    elseif getglobal(frame:GetName() .. "CheckbuttonSay"):GetChecked() then
        channel = 5
    end;

    SOTA_SetConfigurableMessage(event, channel, message);

    SOTA_UpdateTextList();

    FrameEventEditor:Hide();
end;

function SOTA_OnEventEditorClose()
    FrameEventEditor:Hide();
end;

function SOTA_RefreshVisibleTextList(offset)
    --echo(string.format("Offset=%d", offset));
    local messages = SOTA_GetConfigurableTextMessages();
    local msgInfo;

    for n = 1, SOTA_MAX_MESSAGES, 1 do
        msgInfo = messages[n + offset]
        if not msgInfo then
            msgInfo = { "", 0, "" }
        end

        local event = msgInfo[1];
        local channel = msgInfo[2];
        local message = msgInfo[3];

        --echo(string.format("-> Event=%s, Channel=%d, Text=%s", event, 1*channel, message));

        local frame = getglobal("FrameConfigMessageTableListEntry" .. n);
        if (not frame) then
            echo("*** Упс, frame равен nil");
            return;
        end;

        getglobal(frame:GetName() .. "Event"):SetText(event);
        getglobal(frame:GetName() .. "Channel"):SetText(channel);
        getglobal(frame:GetName() .. "Message"):SetText(message);

        frame:Show();
    end
end

function SOTA_UpdateTextList(frame)
    --	FauxScrollFrame_Update(FrameConfigMessageTableList, SOTA_MAX_MESSAGES, 10, 20);
    local messages = SOTA_GetConfigurableTextMessages();

    SOTA_VerifyEventMessages();

    FauxScrollFrame_Update(FrameConfigMessageTableList, table.getn(messages), SOTA_MAX_MESSAGES, 20);
    local offset = FauxScrollFrame_GetOffset(FrameConfigMessageTableList);

    SOTA_RefreshVisibleTextList(offset);
end

function SOTA_InitializeTextElements()
    local entry = CreateFrame("Button", "$parentEntry1", FrameConfigMessageTableList, "SOTA_TextTemplate");
    entry:SetID(1);
    entry:SetPoint("TOPLEFT", 4, -4);
    for n = 2, SOTA_MAX_MESSAGES, 1 do
        local entry = CreateFrame("Button", "$parentEntry" .. n, FrameConfigMessageTableList, "SOTA_TextTemplate");
        entry:SetID(n);
        entry:SetPoint("TOP", "$parentEntry" .. (n - 1), "BOTTOM");
    end
end
