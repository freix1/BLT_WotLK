local BLT = LibStub("AceAddon-3.0"):GetAddon("BLT")
local L = LibStub("AceLocale-3.0"):GetLocale("BLT")
local AC = LibStub("AceConfig-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local Media = LibStub("LibSharedMedia-3.0")
local LibDualSpec = LibStub("LibDualSpec-1.0")
BLT.version = "BLT v"..GetAddOnMetadata("BLT", "Version")

local math, max, random = _G.math, _G.max, _G.random
local select, pairs, unpack = _G.select, _G.pairs, _G.unpack
local tinsert, tremove, tsort, tconcat = table.insert, table.remove, table.sort, table.concat
local format, find = string.format, string.find
local CreateFrame, GameTooltip = CreateFrame, GameTooltip
local UnitName, UnitClass, UnitExists = UnitName, UnitClass, UnitExists
local UnitInRaid, UnitInParty = UnitInRaid, UnitInParty
local UnitIsDeadOrGhost, UnitInRange, UnitIsConnected = UnitIsDeadOrGhost, UnitInRange, UnitIsConnected
local GetSpellInfo, GetSpellLink, GetItemInfo = GetSpellInfo, GetSpellLink, GetItemInfo
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local contains, clearList = BLT.contains, BLT.clearList

-- Local variables --
local db
local defaults = {
    profile = {
        enable              = true,
        scale               = 50,
        offset              = 50,
        posX                = 300,
        posY                = 800,
        iconSize            = 50,
        iconOffsetY         = 10,
        iconBorderSize      = 2,
        iconFont            = "Friz Quadrata TT",
        iconTextSize        = 28,
        iconTextAnchor      = "CENTER",
        iconTextColor       = { r = 1, g = 1, b = 1, a = 1 },
        barWidth            = 50,
        barHeight           = 50,
        barOffset           = 50,
        barOffsetX          = 50,
        barFont             = "Friz Quadrata TT",
        barPlayerTextSize   = 11,
        barTargetTextSize   = 8,
        barCDTextSize       = 11,
        displayTargets      = true,
        barTargetTextType   = "SEPARATE",
        barTargetTextCutoff = -30,
        barTargetTextAnchor = "LEFT",
        barTargetTextColor  = { r = 1, g = 1, b = 1, a = 1 },
        barPlayerTextColor  = { r = 1, g = 1, b = 1, a = 1 },
        barCDTextColor      = { r = 1, g = 1, b = 1, a = 1 },
        barTargetTextPosX   = 50,
        barTargetTextPosY   = 5,
        split               = 2,
        texture             = "Blizzard",
        sorting             = {},
        cooldowns           = {
            [29166] = true, -- Innervate
            [48477] = true, -- Rebirth
            [34477] = true, -- Misdirection
            [31821] = true, -- Aura Mastery
            [64205] = true, -- Divine Sacrifice
            [6940]  = true, -- Hand of Sacrifice
            [47788] = true, -- Guardian Spirit
            [64901] = true, -- Hymn of Hope
            [33206] = true, -- Pain Suppression
            [57934] = true, -- Tricks of the Trade
            [16190] = true, -- Mana Tide Totem
            [47883] = true, -- Soulstone Resurrection
            [54589] = true  -- Glowing Twilight Scale
        }
    }
}
do
    for k in pairs(BLT.spells) do
        for _,v in pairs(BLT.spells[k]) do
            defaults.profile.sorting[v.id] = v.nr
        end
    end
    for k in pairs(BLT.items) do
        for _,v in pairs(BLT.items[k]) do
            defaults.profile.sorting[v.itemId] = v.nr
        end
    end
end

local sortNr = {}
local trackCooldownClasses = {}
local trackCooldownSpecs = {}
local trackCooldownSpells = {}
local trackCooldownSpellIDs = {}
local trackCooldownSpellCooldown = {}
local trackTalents = {}
local talentRequired = {}
local trackCooldownAlternativeSpellCooldown = {}
local trackItems = {}
local trackItemSpellIDs = {}
local trackItemSpellIDsHC = {}
local trackItemIDs = {}
local trackItemCooldowns = {}
local trackLvlRequirement = {}
local trackGlyphs = {}
local trackGlyphCooldown = {}
local trackCooldownTargets = {}
local trackCooldownAllUniqueSpellNames = {}
local trackCooldownAllUniqueSpellEnabledStatuses = {}
local trackCooldownAllUniqueItemNames = {}
local trackCooldownAllUniqueItemEnabledStatuses = {}
local cooldown_Frames = {}
local icon_Frames = {}
local classesInGroup = {}
local playersInGroup = {}
local targetTable = {}
local mainFrame, scaleUI
local iconSize, iconSize_Scale, iconTextSize, iconTextSize_Scale
local offsetBetweenCooldowns, offsetBetweenCooldowns_Scale, cooldownXOffset, cooldownXOffset_Scale
local barPlayerTextSize, barPlayerTextSize_Scale, barCDTextSize, barCDTextSize_Scale, barTargetTextSize, barTargetTextSize_Scale
local cooldownWidth, cooldownWidth_Scale, cooldownHeight, cooldownHeight_Scale
local edgeOffset, edgeOffset_Scale, offsetBetweenIcons, offsetBetweenIcons_Scale
local targetTextPosX, targetTextPosX_Scale, targetTextPosY, targetTextPosY_Scale, textSplitOffset
local currentXOffset, currentYOffset, yOffsetMaximum, cooldownCurrentXOffset, cooldownCurrentYOffset
local cooldownCurrentXOffsetStart, cooldownCurrentYOffsetStart, cooldownBottomMostElementY, cooldownCurrentCounter
local cooldownForegroundBorderOffset = 4
local foundAtLeastOne = false
local frameColorLocked = { r=0, g=0, b=0, a=0 }
local frameColor = { r=0, g=0, b=0, a=0.4 }
local itemColor = { r=0.5, g=0, b=0.9, a=1.0 }
local classColors = {
    ["DEATHKNIGHT"] = "C41F3B",
    ["DRUID"] = "FF7D0A",
    ["HUNTER"] = "ABD473",
    ["MAGE"] = "69CCF0",
    ["PALADIN"] = "F58CBA",
    ["PRIEST"] = "FFFFFF",
    ["ROGUE"] = "FFF569",
    ["SHAMAN"] = "0070DE",
    ["WARLOCK"] = "9482C9",
    ["WARRIOR"] = "C79C6E"
}

-- Helper functions --
function BLT:Unit(name)
    if name then
        local class = select(2, UnitClass(name))
        if class then
            return format("|r|cFF%s|Hplayer:%s|h[%s]|h|r|cFFbebebe",classColors[class],name,name)
        else
            return format("|r|cFFffffff%s|r|cFFbebebe",name)
        end
    else
        return "Unknown"
    end
end

function BLT:Spell(id, group)
    if group then return GetSpellLink(id) end
    if type(id) ~= "number" then return id end
    if select(3, GetSpellInfo(id)) then
        return format("\124T%s:12:12:0:0:64:64:5:59:5:59\124t|r%s|cFFbebebe",select(3, GetSpellInfo(id)), GetSpellLink(id))
    else
        return format("|r%s|cFFbebebe", GetSpellLink(id))
    end
end

function BLT:Item(id)
    if type(id) ~= "number" then return id end
    local itemLink = select(2, GetItemInfo(id))
    if itemLink then
        return itemLink
    end
end

local function Sort(list)
    tsort(list, function(a,b)
        if a.num and b.num and a.num ~= b.num then
            return a.num < b.num
        end
    end)
end

local function ConvertSliderValueToPercentageValue(value)
    -- 1 to 100, to 0.1 - 5, where 50 is 1
    local sliderPercentageValue_Min = 1
    local sliderPercentageValue_Max = 100
    local sliderPercentageValue_Middle = 50
    local retValue = 0
    if value == sliderPercentageValue_Middle then
        retValue = 1.0
    elseif value == sliderPercentageValue_Min then
        retValue = 0.1
    elseif value > sliderPercentageValue_Middle then
        local percentage = (value - sliderPercentageValue_Middle) / (sliderPercentageValue_Max - sliderPercentageValue_Middle)
        local percentageMin = 1
        local percentageMax = 5
        retValue = percentageMin + ((percentageMax - percentageMin) * percentage)
    elseif value < sliderPercentageValue_Middle then
        local percentage = (value - sliderPercentageValue_Min) / (sliderPercentageValue_Max - sliderPercentageValue_Middle)
        local percentageMin = 0.1
        local percentageMax = 1
        retValue = percentageMin + ((percentageMax - percentageMin) * percentage)
    end

    return retValue
end

local function FormatCooldownText(cooldownLeft, printText)
    local minutes = math.floor(cooldownLeft / 60.0)
    cooldownLeft = cooldownLeft - (minutes * 60.0)
    local seconds = math.floor(cooldownLeft + 1)
    if seconds >= 60 then
        seconds = seconds - 60
        minutes = minutes + 1
    end
    local secondsStr = seconds
    if seconds <= 9 then
        secondsStr = "0" .. secondsStr
    end

    if printText then
        if minutes > 0 and seconds > 0 then
            return minutes .. "min " .. seconds .. "sec"
        elseif minutes > 0 then
            return minutes .. "min"
        else
            return seconds .. "sec"
        end
    else
        return minutes .. ":" .. secondsStr
    end
end

local function SetMainFrameLockedStatus(lockedStatus)
    if lockedStatus == true then
        mainFrame.isSetToMovable = false
        mainFrame:EnableMouse(false)
        mainFrame.texture:SetTexture(frameColorLocked.r, frameColorLocked.g, frameColorLocked.b, frameColorLocked.a)
    else
        mainFrame.isSetToMovable = true
        mainFrame:EnableMouse(true)
        mainFrame.texture:SetTexture(frameColor.r, frameColor.g, frameColor.b, frameColor.a)
    end
end

local function SetupNewScale()
    local resizeFromPixelPerfect = 1.25
    iconSize = 40 * resizeFromPixelPerfect * scaleUI * iconSize_Scale
    iconTextSize = math.ceil(40 * resizeFromPixelPerfect * scaleUI * iconTextSize_Scale)
    barPlayerTextSize = math.ceil(40 * resizeFromPixelPerfect * scaleUI * barPlayerTextSize_Scale)
    barCDTextSize = math.ceil(40 * resizeFromPixelPerfect * scaleUI * barCDTextSize_Scale)
    barTargetTextSize = math.ceil(40 * resizeFromPixelPerfect * scaleUI * barTargetTextSize_Scale)
    cooldownWidth = 130 * resizeFromPixelPerfect * scaleUI * cooldownWidth_Scale
    cooldownHeight = 18 * resizeFromPixelPerfect * scaleUI * cooldownHeight_Scale
    cooldownXOffset = 5 * resizeFromPixelPerfect * scaleUI * cooldownXOffset_Scale
    offsetBetweenIcons = 5 * resizeFromPixelPerfect * scaleUI * offsetBetweenIcons_Scale
    offsetBetweenCooldowns = 2.4 * resizeFromPixelPerfect * scaleUI * offsetBetweenCooldowns_Scale
    edgeOffset = 3 * resizeFromPixelPerfect * scaleUI * edgeOffset_Scale
    targetTextPosX = 40 * resizeFromPixelPerfect * scaleUI * targetTextPosX_Scale
    targetTextPosY = 40 * resizeFromPixelPerfect * scaleUI * targetTextPosY_Scale
    textSplitOffset = math.floor((math.exp(db.barWidth/15) * 2.7 / barPlayerTextSize) + .5) -- Might need some more tweaking
end

local function CreateBorder(parentFrame, offset, pixels, r, g, b, a, frameLevel, frameReuse)
    local frame = frameReuse or CreateFrame("Frame", nil, parentFrame)
    local texture1 = frame:CreateTexture(nil, "BACKGROUND")
    texture1:SetAllPoints()
    texture1:SetTexture(0, 0, 0, 0)
    frame.texture = texture1
    frame:SetFrameLevel(frameLevel)

    frame:SetBackdrop({nil, edgeFile = "Interface\\BUTTONS\\WHITE8X8", tile = false, tileSize = 0, edgeSize = pixels, insets = { left = 0, right = 0, top = 0, bottom = 0}})
    frame:SetBackdropBorderColor(r, g, b, a)
    frame:SetPoint("TOPLEFT", -offset, offset)
    frame:SetPoint("BOTTOMRIGHT", offset, -offset)

    if not parentFrame.borders then
        parentFrame.borders = {}
    end
    tinsert(parentFrame.borders, frame)
    return frame
end

local function ModifyFontString(fontString, font, fontSize, fontOutline, textColor, point1, point2, relativeFrame, relativePoint1, relativePoint2, ofsx1, ofsy1, ofsx2, ofsy2, posH, posV, setShadow)
    fontString:SetFont(font, fontSize, fontOutline)
    fontString:SetTextColor(textColor.r, textColor.g, textColor.b, textColor.a)
    if point1 then
        fontString:SetPoint(point1, relativeFrame, relativePoint1, ofsx1, ofsy1)
    end
    if point2 then
        fontString:SetPoint(point2, relativeFrame, relativePoint2, ofsx2, ofsy2)
    end
    if posH then
        fontString:SetJustifyH(posH)
    end
    if posV then
        fontString:SetJustifyV(posV)
    end
    if setShadow then
        fontString:SetShadowOffset(0, 0)
        fontString:SetShadowColor(0, 0, 0, 0)
    end
end

local function CooldownFrame_OnEnter(self)
    -- Check if the caller is valid
    if self then
        -- Set the tooltip
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 2, iconSize + 2)
        GameTooltip:SetText(self.name)

        -- Loop through all classes
        for i=1, #classesInGroup do
            -- Check if the current player has a valid name
            local playerName = playersInGroup[i]
            if playerName and playerName ~= UNKNOWNOBJECT then
                local function AddTooltip(text, r, g, b)
                    if BLT.playerClass[playerName] then
                        GameTooltip:AddLine(playerName .. ": " .. "Level " .. BLT.playerLevel[playerName] .. " " .. BLT.playerClass[playerName] .. " (" .. BLT.playerSpecs[playerName] .. ", " .. BLT.playerTalentPoints[playerName] .. ")" .. text, r, g, b)
                    end
                end
                -- Make sure the spell icon exists and is shown for the current class
                for n=1, #trackCooldownClasses do
                    -- Check if the current player is the class we are looking for
                    if trackCooldownClasses[n] == classesInGroup[i] then
                        -- Check if the current spell is the one we are looking for
                        if trackCooldownSpells[n] == self.name then
                            -- Check if the role of the current player is what we are looking for
                            if BLT:IsPlayerValidForSpellCooldown(playerName, n) then
                                local hasCD
                                for j=1, #cooldown_Frames do
                                    if cooldown_Frames[j].name == self.name and cooldown_Frames[j].player == playerName and cooldown_Frames[j].isUsed then
                                        hasCD = true
                                        break
                                    end
                                end
                                if hasCD then
                                    AddTooltip("", 1, 0, 0)
                                elseif UnitIsDeadOrGhost(playerName) then
                                    AddTooltip(" ["..L["Dead"].."]", 0.4, 0.4, 0.4)
                                elseif not UnitInRange(playerName) then
                                    AddTooltip(" ["..L["Out of Range"].."]", 0.2, 0.4, 1)
                                else
                                    AddTooltip("", 1, 1, 1)
                                end
                            end
                        end
                    end
                end
                for n=1, #trackItems do
                    if trackItems[n] == self.name then
                        if BLT:IsPlayerValidForItemCooldown(playerName, n) then
                            local hasCD
                            for j=1, #cooldown_Frames do
                                if cooldown_Frames[j].name == self.name and cooldown_Frames[j].player == playerName and cooldown_Frames[j].isUsed then
                                    hasCD = true
                                    break
                                end
                            end
                            if hasCD then
                                AddTooltip("",1, 0, 0)
                            elseif UnitIsDeadOrGhost(playerName) then
                                AddTooltip(" ["..L["Dead"].."]", 0.4, 0.4, 0.4)
                            elseif not UnitInRange(playerName) then
                                AddTooltip(" ["..L["Out of Range"].."]", 0.2, 0.4, 1)
                            else
                                AddTooltip("",1, 1, 1)
                            end
                        end
                    end
                end
            end
        end
        GameTooltip:Show()
    end
end

local function CooldownFrame_OnLeave()
    -- Hide the tooltip
    GameTooltip:Hide()
end

-- Core functions --
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function(_, elapsed)
    if not mainFrame then return end
    -- Update the Backend
    BLT:UpdateBackend(elapsed)
    -- Update the UI
    BLT:UpdateUI()
end)

local function HandleEvent(_, event, ...)
    -- If addon is disabled don't process any events
    if not db.enable then return end
    -- Check if we received a combat log event
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        -- Get the variables needed from the event
        local _, combatEvent, _, sourceName, _, _, destName = ...

        -- Check if we have a source for the event
        if sourceName and sourceName ~= "" then
            -- Check if we dealt damage with a spell
            local targetSpellId, targetSpellName
            -- Check if a spell was missed/resisted
            if combatEvent == "SPELL_MISSED" then
                local spellId, spellName = select(9,...)
                if not contains(trackCooldownSpells, spellName) then return end
                targetSpellId, targetSpellName = spellId, spellName

                -- Check if a spell was evaded
            elseif combatEvent == "DAMAGE_SHIELD_MISSED" then
                local spellId, spellName = select(9,...)
                if not contains(trackCooldownSpells, spellName) then return end
                targetSpellId, targetSpellName = spellId, spellName

                -- Check if we cast a spell
            elseif combatEvent == "SPELL_CAST_SUCCESS" then
                local spellId, spellName = select(9,...)
                if not contains(trackCooldownSpells, spellName) then return end
                if spellName == GetSpellInfo(57934) or spellName == GetSpellInfo(34477) then -- 'Tricks of the Trade' or 'Misdirection'
                    targetTable[sourceName] = destName
                elseif contains(trackCooldownSpellIDs, spellId) then
                    targetSpellId, targetSpellName = spellId, spellName
                end
                if spellName == GetSpellInfo(23989) then -- 'Readiness'
                    for i=1, #cooldown_Frames do
                        if cooldown_Frames[i].player == sourceName and cooldown_Frames[i].name == GetSpellInfo(34477) then -- 'Misdirection'
                            BLT:UpdateCooldownFrame(cooldown_Frames[i], false)
                            break
                        end
                    end
                elseif spellName == GetSpellInfo(11958) then -- 'Cold Snap'
                    for i=1, #cooldown_Frames do
                        if cooldown_Frames[i].player == sourceName and cooldown_Frames[i].name == GetSpellInfo(45438) then -- 'Ice Block'
                            BLT:UpdateCooldownFrame(cooldown_Frames[i], false)
                            break
                        end
                    end
                end

                -- Check if we got a spell aura applied
            elseif combatEvent == "SPELL_AURA_APPLIED" then
                local spellId, spellName = select(9,...)
                if not contains(trackCooldownSpells, spellName) then return end
                if spellName == GetSpellInfo(47788) then -- 'Guardian Spirit'
                    if BLT:TimeLeft(BLT.gsTimer) ~= 0 then
                        BLT:CancelTimer(BLT.gsTimer)
                    end
                    BLT.gsTimer = BLT:ScheduleTimer("GuardianSpiritTimer", 9.5)
                elseif not (spellName == GetSpellInfo(64901) or spellName == GetSpellInfo(64843) or spellName == GetSpellInfo(51052) or spellName == GetSpellInfo(34477) or spellName == GetSpellInfo(57934)) then -- 'Hymn of Hope' or 'Divine Hymn' or 'Anti-Magic Zone' or 'Misdirection' or 'Tricks of the Trade'
                    targetSpellId, targetSpellName = spellId, spellName
                end

            elseif combatEvent == "SPELL_AURA_REMOVED" then
                local spellId, spellName = select(9,...)
                if not contains(trackCooldownSpells, spellName) then return end
                -- 'Misdirection' and 'Tricks of the Trade' CDs should only be triggered when successfully procced or cancelled
                if (spellName == GetSpellInfo(34477) and spellId == 34477) or
                        (spellName == GetSpellInfo(57934) and spellId == 57934) then
                    targetSpellId, targetSpellName = spellId, spellName
                    if contains(targetTable, sourceName, true) then
                        destName = targetTable[sourceName]
                        targetTable[sourceName] = nil
                    end
                elseif spellName == GetSpellInfo(47788) then -- 'Guardian Spirit'
                    for i=1, #cooldown_Frames do
                        local frame = cooldown_Frames[i]
                        if frame.name == spellName and frame.player == sourceName and BLT:TimeLeft(BLT.gsTimer) == 0 then
                            frame.spellTimestamp = GetTime() + 60
                            frame.maximumCooldown = 60
                            break
                        end
                    end
                end

            elseif combatEvent == "SPELL_HEAL" then
                local spellName = select(10,...)
                if spellName == GetSpellInfo(47788) then -- 'Guardian Spirit'
                    BLT:CancelTimer(BLT.gsTimer)
                end

            elseif combatEvent == "SPELL_RESURRECT" then
                local spellId, spellName = select(9,...)
                -- This event is only thrown on the initial 'Rebirth' on a player, all subsequent casts of this spell on
                -- the same player will not trigger this event until 1 min has passed (the resurrection acceptance timer
                -- has elapsed)
                if spellName == GetSpellInfo(48477) then -- 'Rebirth'
                    targetSpellId, targetSpellName = spellId, spellName
                end
            end

            BLT:GenerateCooldown(sourceName, destName, targetSpellName, targetSpellId)
        end

    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local sourceUnitID, spellName = select(1,...)
        -- Because the 'SPELL_RESURRECT' event is only thrown once, we have to catch the subsequent casts of 'Rebirth'
        -- on the same player with this event. However, this event does not provide a target return value, which is
        -- why we try to get it from the frame that was created by the initially casted 'Rebirth'
        if spellName == GetSpellInfo(48477) then -- 'Rebirth'
            local spellId, sourceName = 48477, UnitName(sourceUnitID)
            BLT:ScheduleTimer("DelayRebirthTimer", 0.1, spellName, spellId, sourceName, GetTime())
        else
            return
        end

    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg = ...
        if prefix ~= "BLT" then return end
        local arg1, arg2 = strsplit(":", msg)
        if arg1 == "CD" then
            local source, name, id, destination, isItem = strsplit(";", arg2)
            local iconFound = false
            for i=1, #icon_Frames do
                local frame = icon_Frames[i]
                if frame.name == name then
                    iconFound = true
                    break
                end
            end
            if iconFound then
                local cooldownFound = false
                for i=1, #cooldown_Frames do
                    local frame = cooldown_Frames[i]
                    if frame.name == name and frame.player == source then
                        cooldownFound = true
                        break
                    end
                end
                if not cooldownFound then
                    if isItem == "true" and BLT:IsCooldownItemEnabled(name) then
                        BLT:CreateCooldownFrame(source, name, id, destination, true)
                    elseif BLT:IsCooldownSpellEnabled(name) then
                        BLT:CreateCooldownFrame(source, name, id, destination)
                    end
                end
            end
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        local inInstance, instanceType = IsInInstance()
        -- Reset cooldowns upon entering an arena match
        if inInstance and instanceType == "arena" then
            local hasAtLeastOneCooldownFrameUp = false
            for i=1, #cooldown_Frames do
                local frame = cooldown_Frames[i]
                if frame.isUsed then
                    hasAtLeastOneCooldownFrameUp = true
                end
            end
            if hasAtLeastOneCooldownFrameUp then
                -- Set all cooldown frames to not be used anymore
                for i=1, #cooldown_Frames do
                    local frame = cooldown_Frames[i]
                    if frame.isUsed then
                        frame.spellTimestamp = GetTime()
                        frame.maximumCooldown = 0
                    end
                end
            end
        end
    end
end

function BLT:GuardianSpiritTimer() end

function BLT:DelayRebirthTimer(spellName, spellId, sourceName, time)
    local foundExistingFrame = false
    for i=1, #cooldown_Frames do
        local frame = cooldown_Frames[i]
        if frame.name == spellName then
            if frame.player and frame.player == sourceName then
                foundExistingFrame = true
                break
            end
        end
    end
    if not foundExistingFrame then
        for i=1, #cooldown_Frames do
            local frame = cooldown_Frames[i]
            if frame.name == spellName then
                if frame.time + 60 >= time then
                    BLT:CreateCooldownFrame(sourceName, spellName, spellId, frame.target)
                    SendAddonMessage("BLT", "CD:"..sourceName..";"..spellName..";"..spellId..";"..(frame.target or ""), BLT:GetGroupState(), UnitName("player"))
                end
            end
        end
    end
end

function BLT:GenerateCooldown(sourceName, destName, spellName, spellId)
    -- Check if the spell cast is in the list of tracked cooldowns
    if spellName ~= "" and (contains(trackCooldownSpells, spellName) or (contains(trackItemSpellIDs, spellId) or contains(trackItemSpellIDsHC, spellId))) then
        -- Check if the caster is in our party/raid
        if contains(playersInGroup, sourceName) then
            -- Check if the role of the caster is what we are looking for
            for i=1, #trackCooldownSpells do
                if trackCooldownSpells[i] == spellName then
                    if BLT:IsPlayerValidForSpellCooldown(sourceName, i) and BLT:IsCooldownSpellEnabled(spellName) then
                        if not trackCooldownTargets[i] then
                            destName = nil
                        end
                        BLT:CreateCooldownFrame(sourceName, spellName, spellId, destName)
                        SendAddonMessage("BLT", "CD:"..sourceName..";"..spellName..";"..spellId..";"..(destName or ""), BLT:GetGroupState(), UnitName("player"))
                        break
                    end
                end
            end
            for i=1, #trackItems do
                if trackItemSpellIDs[i] == spellId or trackItemSpellIDsHC[i] == spellId then
                    if BLT:IsPlayerValidForItemCooldown(sourceName, i) and BLT:IsCooldownItemEnabled(trackItems[i]) then
                        BLT:CreateCooldownFrame(sourceName, trackItems[i], trackItemIDs[i], nil, true)
                        SendAddonMessage("BLT", "CD:"..sourceName..";"..trackItems[i]..";"..trackItemIDs[i]..";;"..tostring(true), BLT:GetGroupState(), UnitName("player"))
                        break
                    end
                end
            end
        end
    end
end

function BLT:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("BLT_DB", defaults, "Default")
    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")
    LibDualSpec:EnhanceDatabase(self.db, "BLT");
    db = self.db.profile

    self:SetupOptions()
    self.OnInitialize = nil
end

function BLT:OnEnable()
    for k in pairs(self.spells) do
        for k2,v in pairs(self.spells[k]) do
            self:AddTrackCooldownSpell(v.nr, k, v.spec, k2, v.id, v.cd, v.talent, v.talReq, v.altCd, v.lvlReq, v.tar, v.glyph, v.glyphCd)
        end
    end
    for k in pairs(self.items) do
        for k2,v in pairs(self.items[k]) do
            self:AddTrackCooldownItem(v.nr, k2, v.spellId, v.spellIdHc, v.itemId, v.cd)
        end
    end
    db.debugIcons = false
    self:RegisterEvent("PLAYER_UPDATE_RESTING", "UpdateVisible")
    self:RegisterEvent("PARTY_MEMBERS_CHANGED", "UpdateVisible")
    self:CreateMainFrame()
    self:CreateBackendFrame()
    self:SetAnchors(true)
    self:SetOptions()
end

function BLT:OnDisable()
    mainFrame:UnregisterAllEvents()
    mainFrame = nil
    self:ClearLists()
end

function BLT:OnProfileChanged(event, database, newProfileKey)
    db = database.profile
    self:SetAnchors(true, true)
    self:SetOptions()
end

function BLT:SetupOptions()
    AC:RegisterOptionsTable("BLT", self.options)
    AC:RegisterOptionsTable(L["BLT Commands"], self.commands, "blt")
    ACR:RegisterOptionsTable("BLT_Show When...", self.options.args.show)
    ACR:RegisterOptionsTable("BLT_Icons", self.options.args.icons)
    ACR:RegisterOptionsTable("BLT_Bars", self.options.args.bars)
    ACR:RegisterOptionsTable("BLT_Cooldowns", self.options.args.cooldowns)
    ACR:RegisterOptionsTable("BLT_Sorting", self.options.args.sorting)
    ACR:RegisterOptionsTable("BLT_Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db))
    LibDualSpec:EnhanceOptions(LibStub("AceDBOptions-3.0"):GetOptionsTable(self.db), self.db)

    self.optionsFrames = {}
    self.optionsFrames.BLT = ACD:AddToBlizOptions("BLT", self.version, nil, "general")
    self.optionsFrames.Show = ACD:AddToBlizOptions("BLT_Show When...", L["Show When..."], self.version)
    self.optionsFrames.Icon = ACD:AddToBlizOptions("BLT_Icons", L["Icons"], self.version)
    self.optionsFrames.Bar = ACD:AddToBlizOptions("BLT_Bars", L["Bars"], self.version)
    self.optionsFrames.Spells = ACD:AddToBlizOptions("BLT_Cooldowns", L["Cooldowns"], self.version)
    self.optionsFrames.Sorting = ACD:AddToBlizOptions("BLT_Sorting", L["Sorting"], self.version)
    self.optionsFrames.Profiles = ACD:AddToBlizOptions("BLT_Profiles", L["Profiles"], self.version)

    self.SetupOptions = nil
end

function BLT:ShowConfig()
    -- Open the profiles tab before, so the menu expands
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.Profiles)
    InterfaceOptionsFrame_OpenToCategory(self.optionsFrames.BLT)
end

function BLT:AddTrackCooldownSpell(nr, class, spec, spellName, spellId, maxCd, talent, talReq, altCd, lvlReq, tar, glyph, glyphCd)
    tinsert(sortNr, nr)
    tinsert(trackCooldownClasses, class)
    tinsert(trackCooldownSpecs, spec)
    tinsert(trackCooldownSpells, spellName)
    tinsert(trackCooldownSpellIDs, spellId)
    tinsert(trackCooldownSpellCooldown, maxCd)
    tinsert(trackTalents, talent)
    tinsert(talentRequired, talReq)
    tinsert(trackCooldownAlternativeSpellCooldown, altCd)
    tinsert(trackLvlRequirement, lvlReq)
    tinsert(trackCooldownTargets, tar)
    tinsert(trackGlyphs, glyph)
    tinsert(trackGlyphCooldown, glyphCd)

    if not contains(trackCooldownAllUniqueSpellNames, spellName) then
        tinsert(trackCooldownAllUniqueSpellNames, spellName)
        tinsert(trackCooldownAllUniqueSpellEnabledStatuses, true)
    end
end

function BLT:AddTrackCooldownItem(nr, itemName, spellId, spellIdHc, itemId, cd)
    tinsert(sortNr, db.useCustomSorting and db.sorting[itemId] or nr)
    tinsert(trackItems, itemName)
    tinsert(trackItemSpellIDs, spellId)
    tinsert(trackItemSpellIDsHC, spellIdHc)
    tinsert(trackItemIDs, itemId)
    tinsert(trackItemCooldowns, cd)

    if not contains(trackCooldownAllUniqueItemNames, itemName) then
        tinsert(trackCooldownAllUniqueItemNames, itemName)
        tinsert(trackCooldownAllUniqueItemEnabledStatuses, true)
    end
end

function BLT:CreateMainFrame()
    mainFrame = nil
    -- Create the main frame
    mainFrame = CreateFrame("Frame", "BLT_MainFrame", UIParent)
    mainFrame:SetMovable(true)
    mainFrame:EnableMouse(false)
    mainFrame:SetClampedToScreen(true)
    mainFrame:RegisterForDrag("LeftButton")
    mainFrame:SetPoint("CENTER")
    mainFrame:SetScript("OnDragStart", function(s) s:StartMoving() end)
    mainFrame:SetScript("OnDragStop", function(s) s:StopMovingOrSizing(); BLT:SetAnchors() end)
    local texture = mainFrame:CreateTexture("ARTWORK")
    texture:SetAllPoints()
    texture:SetTexture(frameColorLocked.r, frameColorLocked.g, frameColorLocked.b, frameColorLocked.a)
    mainFrame.texture = texture
    mainFrame:SetFrameLevel(1)
    mainFrame.isSetToHidden = false
    mainFrame.isSetToMovable = false

    -- Register all events we need
    mainFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    mainFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    mainFrame:RegisterEvent("CHAT_MSG_ADDON")
    mainFrame:SetScript("OnEvent", HandleEvent)
end

function BLT:CreateIconFrame(name, id, class, isItem)
    -- Check if we do not already have a frame with this name
    local frame
    for i=1, #icon_Frames do
        if icon_Frames[i].name == name then
            frame = icon_Frames[i]
            return i
        end
    end
    if not frame then
        -- Create a new frame
        frame = CreateFrame("Frame", "TrackCooldownIconFrame_" .. #icon_Frames, mainFrame)
        frame:SetWidth(iconSize)
        frame:SetHeight(iconSize)
        local texture1 = frame:CreateTexture(nil, "BACKGROUND")
        texture1:SetAllPoints()
        frame.texture = texture1
        frame.name = name
        frame.id = id
        frame.isItem = isItem
        frame.class = class
        frame.count = 0
        frame:SetPoint("TOPLEFT", 0, 0)
        frame:EnableMouse(true)
        frame:SetScript("OnEnter", CooldownFrame_OnEnter)
        frame:SetScript("OnLeave", CooldownFrame_OnLeave)

        frame.innerBorder = CreateBorder(frame, -1 - db.iconBorderSize, 1, 0, 0, 0, 0.7, frame:GetFrameLevel() + 2)
        frame.outerBorder = CreateBorder(frame, 0, 1, 0, 0, 0, 0.8, frame:GetFrameLevel() + 2)
        if class then
            local playerClassColor = RAID_CLASS_COLORS[class]
            if playerClassColor then
                frame.colorBorder = CreateBorder(frame, -1, db.iconBorderSize,  playerClassColor.r,  playerClassColor.g, playerClassColor.b, 1, frame:GetFrameLevel() + 1)
            end
        else
            frame.colorBorder = CreateBorder(frame, -1, db.iconBorderSize, itemColor.r, itemColor.g, itemColor.b, itemColor.a, frame:GetFrameLevel() + 1)
        end

        local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ModifyFontString(fontString, Media:Fetch("font", db.iconFont), iconTextSize, "OUTLINE", db.iconTextColor)
        fontString:SetPoint(db.iconTextAnchor)
        frame.fontString = fontString

        -- Set the new texture of the frame
        local icon = isItem and GetItemIcon(id) or select(3, GetSpellInfo(self:GetSpellIDFromName(name)))
        if icon then
            texture1:SetTexture(icon)
            texture1:SetTexCoord(unpack({.08, .92, .08, .92}))
            texture1:SetPoint('TOPLEFT', 2, -2)
            texture1:SetPoint('BOTTOMRIGHT', -2, 2)
        end

        tinsert(icon_Frames, frame)
    end

    return #icon_Frames
end

function BLT:CreateCooldownFrame(player, name, id, target, isItem)
    -- Check if we do not already have a frame with this name
    local frame
    for i=1, #cooldown_Frames do
        if cooldown_Frames[i].player == player and cooldown_Frames[i].name == name then
            frame = cooldown_Frames[i]
            tremove(cooldown_Frames, i)
            tinsert(cooldown_Frames, frame)
            break
        end
    end
    local cooldownColor = { r=0.8, g=0.8, b=0.8, a=1.0 }
    local cooldownBackgroundColor = { r=0.2, g=0.2, b=0.2, a=1.0 }
    if not frame then
        -- Create a new frame
        frame = CreateFrame("Frame", "TrackCooldownFrame_" .. #cooldown_Frames, mainFrame)
        frame:SetWidth(cooldownWidth - cooldownForegroundBorderOffset)
        frame:SetHeight(cooldownHeight - cooldownForegroundBorderOffset)
        local texture1 = frame:CreateTexture("ARTWORK")
        texture1:SetTexture(Media:Fetch("statusbar", db.texture))
        texture1:SetAllPoints()
        texture1:SetVertexColor(cooldownColor.r, cooldownColor.g, cooldownColor.b, cooldownColor.a)
        frame.texture = texture1
        frame.player = player:match("[^-]+")
        frame.name = name
        frame.id = id
        frame.time = GetTime()
        frame:SetPoint("TOPLEFT", 0, 0)
        frame:SetFrameLevel(2)

        local frameBackground = CreateFrame("Button", "TrackCooldownFrameBackground_" .. #cooldown_Frames, mainFrame)
        frameBackground:SetWidth(cooldownWidth)
        frameBackground:SetHeight(cooldownHeight)
        local texture2 = frameBackground:CreateTexture("ARTWORK")
        texture2:SetTexture(Media:Fetch("statusbar", db.texture))
        texture2:SetAllPoints()
        texture2:SetVertexColor(cooldownBackgroundColor.r, cooldownBackgroundColor.g, cooldownBackgroundColor.b, cooldownBackgroundColor.a)
        frameBackground.texture = texture2
        frameBackground:SetFrameLevel(1)
        frameBackground:EnableMouse(true)
        frame.frameBackground = frameBackground

        CreateBorder(frameBackground, -2, 1, 0, 0, 0, 0.7, frame:GetFrameLevel() + 1)
        CreateBorder(frameBackground, -1, 1, cooldownColor.r, cooldownColor.g, cooldownColor.b, cooldownColor.a, frame:GetFrameLevel() + 1)
        CreateBorder(frameBackground, 0, 1, 0, 0, 0, 0.8, frame:GetFrameLevel() + 1)

        local fontFrame = CreateFrame("Frame", "TrackCooldownFontFrame_" .. #cooldown_Frames, frameBackground)
        local texture3 = fontFrame:CreateTexture(nil, "BACKGROUND")
        texture3:SetAllPoints()
        texture3:SetTexture(0, 0, 0, 0)
        fontFrame.texture = texture3
        fontFrame:SetFrameLevel(4)
        frame.fontFrame = fontFrame
        fontFrame:SetPoint("TOPLEFT", -0, 0)
        fontFrame:SetPoint("BOTTOMRIGHT", 0, -0)

        -- Player name font string
        local fontString = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ModifyFontString(fontString, Media:Fetch("font", db.barFont), barPlayerTextSize, "OUTLINE", db.barPlayerTextColor, "TOPLEFT", "BOTTOMRIGHT", fontFrame,"TOPLEFT", "BOTTOMRIGHT", 4, 0, -40, 0, "LEFT", "MIDDLE", true)
        frame.fontString = fontString

        -- CD time font string
        local fontString2 = fontFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        ModifyFontString(fontString2, Media:Fetch("font", db.barFont), barCDTextSize, "OUTLINE", db.barCDTextColor, "TOPLEFT", "BOTTOMRIGHT", fontFrame,"TOPLEFT", "BOTTOMRIGHT", 4, 0, -3, 0, "RIGHT", "MIDDLE", true)
        fontString2.cooldownLeft = 0
        frame.fontString2 = fontString2

        -- Target name font string
        local fontString3 = fontFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        ModifyFontString(fontString3, Media:Fetch("font", db.barFont), barTargetTextSize, "OUTLINE", db.barTargetTextColor, "TOPLEFT", "BOTTOMRIGHT", fontFrame,"TOPLEFT", "BOTTOMRIGHT", targetTextPosX, targetTextPosY, db.barTargetTextCutoff, targetTextPosY*1.5, db.barTargetTextAnchor, "MIDDLE", true)
        frame.fontString3 = fontString3

        tinsert(cooldown_Frames, frame)
    end
    local maximumCooldown = db.debugBars and random(5, 80) or self:GetMaximumCooldown(name, player, isItem)
    frame.spellTimestamp = GetTime() + maximumCooldown
    frame.maximumCooldown = maximumCooldown
    frame:Show()
    frame.frameBackground:Show()
    frame.fontFrame:Show()
    frame.isUsed = true
    frame.target = target and target:match("[^-]+")

    local class
    for i=1, #trackCooldownSpells do
        if trackCooldownSpells[i] == name then
            class = trackCooldownClasses[i]
            break
        end
    end
    if not class then
        class = select(2, UnitClass(player))
    end
    if class then
        local playerClassColor = RAID_CLASS_COLORS[class]
        if playerClassColor then
            frame.texture:SetVertexColor(cooldownColor.r * playerClassColor.r, cooldownColor.g * playerClassColor.g, cooldownColor.b * playerClassColor.b, cooldownColor.a)
            frame.frameBackground.texture:SetVertexColor(cooldownBackgroundColor.r * playerClassColor.r, cooldownBackgroundColor.g * playerClassColor.g, cooldownBackgroundColor.b * playerClassColor.b, cooldownBackgroundColor.a)
            frame.frameBackground.borders[2]:SetBackdropBorderColor(playerClassColor.r, playerClassColor.g, playerClassColor.b, 1)
        end
    else
        frame.texture:SetVertexColor(cooldownColor.r * itemColor.r, cooldownColor.g * itemColor.g, cooldownColor.b * itemColor.b, cooldownColor.a * itemColor.a)
        frame.frameBackground.texture:SetVertexColor(cooldownBackgroundColor.r * itemColor.r, cooldownBackgroundColor.g * itemColor.g, cooldownBackgroundColor.b * itemColor.b, cooldownBackgroundColor.a * itemColor.a)
        frame.frameBackground.borders[2]:SetBackdropBorderColor(itemColor.r, itemColor.g, itemColor.b, itemColor.a)
    end

    return frame
end

function BLT:UpdateUI()
    -- Get a list of all classes we have in our party/raid (including ourself)
    clearList(classesInGroup)
    clearList(playersInGroup)

    local selfPlayerName = UnitName("player")

    local unitTarget = "player"
    local class, classFileName = UnitClass(unitTarget)
    if class then
        tinsert(classesInGroup, classFileName)
        tinsert(playersInGroup, selfPlayerName)
    end

    if UnitExists("raid1") then
        for i=1, 40 do
            local unitTarget = "raid" .. i
            local unitName = UnitName(unitTarget)
            if unitName ~= selfPlayerName then
                local class, classFileName = UnitClass(unitTarget)
                if class then
                    tinsert(classesInGroup, classFileName)
                    tinsert(playersInGroup, unitName)
                end
            end
        end
    elseif UnitExists("party1") then
        for i=1, 4 do
            local unitTarget = "party" .. i
            local unitName = UnitName(unitTarget)
            if unitName ~= selfPlayerName then
                local class, classFileName = UnitClass(unitTarget)
                if class then
                    tinsert(classesInGroup, classFileName)
                    tinsert(playersInGroup, unitName)
                end
            end
        end
    end

    -- Hide all spell icon frames
    for i=1, #icon_Frames do
        local frame = icon_Frames[i]
        frame:Hide()
        frame.count = 0
    end

    -- Loop through all classes
    for i=1, #classesInGroup do
        -- Check if the current player has a valid name
        local playerName = playersInGroup[i]
        if playerName and playerName ~= UNKNOWNOBJECT then
            -- Make sure the icon exists and is shown for the current class
            for n=1, #trackCooldownClasses do
                -- Check if the current track cooldown is enabled
                if self:IsCooldownSpellEnabled(trackCooldownSpells[n]) then
                    -- Check if the current player is the class we are looking for
                    if trackCooldownClasses[n] == classesInGroup[i] then
                        -- Check if the current player is valid for the cooldown
                        if self:IsPlayerValidForSpellCooldown(playerName, n) then
                            -- Create or get an icon index for it
                            local index = self:CreateIconFrame(trackCooldownSpells[n], trackCooldownSpellIDs[n], trackCooldownClasses[n])
                            local frame = icon_Frames[index]
                            frame.num = db.useCustomSorting and db.sorting[trackCooldownSpellIDs[n]] or sortNr[n]
                            frame:Show()
                            if not UnitIsDeadOrGhost(playerName) or trackCooldownSpellIDs[n] == 20608 then -- 'Reincarnation' is usable while dead
                                frame.count = frame.count + 1
                            end
                        end
                    end
                end
            end
            for n=1, #trackItems do
                if self:IsCooldownItemEnabled(trackItems[n]) and self:IsPlayerValidForItemCooldown(playerName, n) then
                    -- Create or get an icon index for it
                    local index = self:CreateIconFrame(trackItems[n], trackItemIDs[n], nil, true)
                    local frame = icon_Frames[index]
                    frame.num = db.useCustomSorting and db.sorting[trackItemIDs[n]] or sortNr[#sortNr-#trackItems + n]
                    frame:Show()
                    if not UnitIsDeadOrGhost(playerName) then
                        frame.count = frame.count + 1
                    end
                end
            end
        end
    end

    if db.debugIcons == true then
        for n=1, #trackCooldownClasses do
            -- Check if the current track cooldown is enabled
            if self:IsCooldownSpellEnabled(trackCooldownSpells[n]) then
                local index = self:CreateIconFrame(trackCooldownSpells[n], trackCooldownSpellIDs[n], trackCooldownClasses[n])
                local frame = icon_Frames[index]
                frame.num = db.useCustomSorting and db.sorting[trackCooldownSpellIDs[n]] or sortNr[n]
                frame:Show()
            end
        end
        for n=1, #trackItems do
            if self:IsCooldownItemEnabled(trackItems[n]) then
                local index = self:CreateIconFrame(trackItems[n], trackItemIDs[n], nil, true)
                local frame = icon_Frames[index]
                frame.num = db.useCustomSorting and db.sorting[trackItemIDs[n]] or sortNr[#sortNr-#trackItems + n]
                frame:Show()
            end
        end
    end

    if db.debugBars == true then
        local isInUse = false
        for i=1,#cooldown_Frames do
            if cooldown_Frames[i].isUsed and cooldown_Frames[i].isTest then
                isInUse = true
                break
            end
        end
        if isInUse == false then
            db.debugBars = false
            ACR:NotifyChange("BLT")
        end
    end

    -- Loop through all spell icon frames
    yOffsetMaximum = edgeOffset * 2.0
    currentXOffset = edgeOffset
    currentYOffset = edgeOffset
    foundAtLeastOne = false
    for i=1, #icon_Frames do
        -- Update the current spell icon frame
        self:UpdateIconFrame(i)
    end
    yOffsetMaximum = yOffsetMaximum - offsetBetweenIcons

    -- Update the frame visibility
    if foundAtLeastOne then
        if mainFrame.isSetToHidden == false then
            mainFrame:Show()
        end

        -- Make sure the frame is only scaled to the bottom
        local diff = yOffsetMaximum - mainFrame:GetHeight()
        local point, _, _, xOfs, yOfs = mainFrame:GetPoint()
        if point == "LEFT" or point == "RIGHT" or point == "CENTER" then
            yOfs = yOfs - (diff * 0.5)
        elseif point == "BOTTOM" or point == "BOTTOMLEFT" or point == "BOTTOMRIGHT" then
            yOfs = yOfs - diff
        end
        mainFrame:SetPoint(point, xOfs, yOfs)

        -- Set the new width and height of the main frame
        local xOffsetMaximum = (edgeOffset * 2.0) + iconSize
        mainFrame:SetWidth(xOffsetMaximum)
        mainFrame:SetHeight(yOffsetMaximum)
    else
        mainFrame:Hide()
    end

    Sort(icon_Frames)
end

function BLT:UpdateUISize()
    SetupNewScale()

    -- Loop through all spell icon frames
    for i=1, #icon_Frames do
        -- Update the size of the current frame
        local frame = icon_Frames[i]

        frame:SetWidth(iconSize)
        frame:SetHeight(iconSize)

        ModifyFontString(frame.fontString, Media:Fetch("font", db.iconFont), iconTextSize, "OUTLINE", db.iconTextColor)
    end

    -- Loop through all cooldown frames
    for i=1, #cooldown_Frames do
        -- Update the size of the current frame
        local frame = cooldown_Frames[i]

        frame:SetWidth(cooldownWidth - cooldownForegroundBorderOffset)
        frame:SetHeight(cooldownHeight - cooldownForegroundBorderOffset)

        frame.frameBackground:SetWidth(cooldownWidth)
        frame.frameBackground:SetHeight(cooldownHeight)

        ModifyFontString(frame.fontString, Media:Fetch("font", db.barFont), barPlayerTextSize, "OUTLINE", db.barPlayerTextColor)
        ModifyFontString(frame.fontString2, Media:Fetch("font", db.barFont), barCDTextSize, "OUTLINE", db.barCDTextColor)
        ModifyFontString(frame.fontString3, Media:Fetch("font", db.barFont), barTargetTextSize, "OUTLINE", db.barTargetTextColor, "TOPLEFT", "BOTTOMRIGHT", frame.fontFrame, "TOPLEFT", "BOTTOMRIGHT", targetTextPosX, targetTextPosY, db.barTargetTextCutoff, targetTextPosY*1.5, db.barTargetTextAnchor)
    end
end

function BLT:GetReadyPlayerCooldowns(frame)
    local players = {}
    for i=1, #classesInGroup do
        local playerName = playersInGroup[i]
        if playerName and playerName ~= UNKNOWNOBJECT then
            for n=1, #trackCooldownClasses do
                if trackCooldownClasses[n] == classesInGroup[i] then
                    if trackCooldownSpells[n] == frame.name then
                        if BLT:IsPlayerValidForSpellCooldown(playerName, n) then
                            local hasCD
                            for j=1, #cooldown_Frames do
                                if cooldown_Frames[j].name == frame.name and cooldown_Frames[j].player == playerName and cooldown_Frames[j].isUsed then
                                    hasCD = true
                                    break
                                end
                            end
                            if not hasCD then
                                tinsert(players, UnitIsDeadOrGhost(playerName) and playerName .. " ["..L["Dead"].."]" or playerName)
                            end
                        end
                    end
                end
            end
            for n=1, #trackItems do
                if trackItems[n] == frame.name then
                    if BLT:IsPlayerValidForItemCooldown(playerName, n) then
                        local hasCD
                        for j=1, #cooldown_Frames do
                            if cooldown_Frames[j].name == frame.name and cooldown_Frames[j].player == playerName and cooldown_Frames[j].isUsed then
                                hasCD = true
                                break
                            end
                        end
                        if not hasCD then
                            tinsert(players, UnitIsDeadOrGhost(playerName) and playerName .. " ["..L["Dead"].."]" or playerName)
                        end
                    end
                end
            end
        end
    end
    return players
end

function BLT:UpdateIconFrame(index)
    -- Check if the current frame is used
    local frame = icon_Frames[index]
    local name = frame.name

    -- Update the cooldown frames of the spell icon
    cooldownBottomMostElementY = 0
    cooldownCurrentCounter = 0
    cooldownCurrentXOffset = currentXOffset + iconSize + cooldownXOffset
    if db.alignBarSide then
        cooldownCurrentXOffset = currentXOffset - cooldownXOffset - cooldownWidth
    end
    cooldownCurrentYOffset = currentYOffset
    cooldownCurrentXOffsetStart = cooldownCurrentXOffset
    cooldownCurrentYOffsetStart = cooldownCurrentYOffset

    local count = 0
    for i=1, #cooldown_Frames do
        local cooldownFrame = cooldown_Frames[i]
        if cooldownFrame.isUsed then
            if cooldownFrame.name == name then
                self:UpdateCooldownFrame(cooldownFrame, frame:IsShown() and true or false)
                count = count + 1
            end
        end
    end

    -- Check if the current frame is used
    if frame:IsShown() then
        foundAtLeastOne = true

        -- Set the position of the current frame
        frame:SetPoint("TOPLEFT", currentXOffset, -currentYOffset)

        -- Set the text of the current frame
        local fontString = frame.fontString
        if frame.count - count < 0 then
            fontString:SetText("" .. 0)
        else
            fontString:SetText("" .. (frame.count - count))
        end

        -- Shift-Click on an icon will print whose cooldowns are ready to be used
        frame:SetScript("OnMouseDown", function()
            if IsShiftKeyDown() then
                local players = self:GetReadyPlayerCooldowns(frame)
                if GetNumPartyMembers() ~= 0 then
                    SendChatMessage(L["%s is ready to be used by %s"]:format(contains(trackCooldownSpellIDs, frame.id) and self:Spell(frame.id, true) or self:Item(frame.id, true), next(players) and tconcat(players, ", ") or "—"), BLT:GetGroupState())
                else
                    self:Print(L["%s is ready to be used by %s"]:format(contains(trackCooldownSpellIDs, frame.id) and self:Spell(frame.id or self:Item(frame.id)), next(players) and tconcat(players, ", ") or "—"))
                    SendCharMessage(("%s"):format(), BLT:GetGroupState())
                end
            end
        end)

        -- Go to the next position
        local diff = 0
        if cooldownBottomMostElementY + cooldownHeight - iconSize > currentYOffset then
            diff = diff + ((cooldownBottomMostElementY + cooldownHeight - iconSize) - currentYOffset)
        end
        diff = diff + iconSize + offsetBetweenIcons
        currentYOffset = currentYOffset + diff
        yOffsetMaximum = yOffsetMaximum + diff
    end
end

function BLT:UpdateCooldownFrame(frame, show)
    local frameBackground = frame.frameBackground
    local fontFrame = frame.fontFrame

    -- Check if we should show the frame
    if show and (UnitIsConnected(frame.player) or db.debugBars) then
        -- Check if the current frame is used
        if frame.isUsed and (UnitInRaid(frame.player) or UnitInParty(frame.player) or UnitName("player") == frame.player or db.debugBars) then
            -- Set the position of the current frame
            frameBackground:SetPoint("TOPLEFT", cooldownCurrentXOffset, -cooldownCurrentYOffset)
            frame:SetPoint("TOPLEFT", cooldownCurrentXOffset + (cooldownForegroundBorderOffset * 0.5), -cooldownCurrentYOffset - (cooldownForegroundBorderOffset * 0.5))
            frameBackground:Show()
            fontFrame:Show()
            frame:Show()
            cooldownBottomMostElementY = max(cooldownBottomMostElementY, cooldownCurrentYOffset)

            -- Set the width of the current frame
            local cooldownLeft = frame.spellTimestamp - GetTime()
            local percentage = cooldownLeft / frame.maximumCooldown
            if percentage == 0 then
                percentage = 0.000001
            end
            frame:SetWidth((cooldownWidth - cooldownForegroundBorderOffset) * percentage)

            -- Set the text of the current frame
            frame.fontString:SetText(frame.player)
            frame.fontString2:SetText(FormatCooldownText(cooldownLeft))

            if db.displayTargets and frame.target then
                if db.barTargetTextType == "SEPARATE" then
                    frame.fontString3:SetText(frame.target)
                else
                    -- Credit to Bog/Jezz for this option
                    frame.fontString:SetText(string.sub(frame.player, 1, textSplitOffset) .. " > " .. string.sub(frame.target, 1, textSplitOffset))
                    frame.fontString3:SetText("")
                end
            end

            -- Shift-Click on the current frame will print when the cooldown will be ready in chat
            frameBackground:SetScript("OnMouseDown", function()
                if IsShiftKeyDown() then
                    if GetNumPartyMembers() ~= 0 then
                        SendChatMessage(L["%s's %s will be ready in %s%s"]:format(frame.player, contains(trackCooldownSpellIDs, frame.id) and self:Spell(frame.id, true) or self:Item(frame.id, true), FormatCooldownText(cooldownLeft,true), frame.target and L[" (used on %s)"]:format(frame.target) or ""), BLT:GetGroupState())
                    else
                        self:Print(L["%s's %s will be ready in %s%s"]:format(self:Unit(frame.player), contains(trackCooldownSpellIDs, frame.id) and self:Spell(frame.id) or self:Item(frame.id), FormatCooldownText(cooldownLeft,true), frame.target and L[" (used on %s)"]:format(frame.target) or ""))
                    end
                end
            end)

            -- Check if the current frame has no cooldown left
            if cooldownLeft <= 0 then
                -- Set that the frame is not used anymore
                frame.isUsed = false
                frameBackground:Hide()
                fontFrame:Hide()
                frame:Hide()

                if db.message then
                    self:Print(L["%s's %s is ready!"]:format(self:Unit(frame.player), contains(trackCooldownSpellIDs, frame.id) and self:Spell(frame.id) or self:Item(frame.id)))
                end
            else
                -- Go to the next position
                cooldownCurrentCounter = cooldownCurrentCounter + 1
                if cooldownCurrentCounter == db.split then
                    cooldownCurrentYOffset = cooldownCurrentYOffsetStart
                    if db.alignBarSide then
                        cooldownCurrentXOffset = cooldownCurrentXOffset - cooldownWidth - offsetBetweenCooldowns
                    else
                        cooldownCurrentXOffset = cooldownCurrentXOffset + cooldownWidth + offsetBetweenCooldowns
                    end
                    cooldownCurrentCounter = 0
                else
                    cooldownCurrentYOffset = cooldownCurrentYOffset + cooldownHeight + offsetBetweenCooldowns
                end
            end
        end
    else
        -- Hide the cooldown frame
        frame.isUsed = false
        frameBackground:Hide()
        fontFrame:Hide()
        frame:Hide()
    end
end

function BLT:UpdateIconBorders()
    for i=1, #icon_Frames do
        local frame = icon_Frames[i]
        self.clearList(frame.borders)

        CreateBorder(frame, -1 - db.iconBorderSize, 1, 0, 0, 0, 0.7, frame:GetFrameLevel() + 2, frame.outerBorder)
        CreateBorder(frame, 0, 1, 0, 0, 0, 0.8, frame:GetFrameLevel() + 2, frame.innerBorder)

        if frame.class then
            local playerClassColor = RAID_CLASS_COLORS[frame.class]
            if playerClassColor then
                CreateBorder(frame, -1, db.iconBorderSize, playerClassColor.r, playerClassColor.g, playerClassColor.b, 1, frame:GetFrameLevel() + 1, frame.colorBorder)
            end
        else
            CreateBorder(frame, -1, db.iconBorderSize, itemColor.r, itemColor.g, itemColor.b, itemColor.a, frame:GetFrameLevel() + 1, frame.colorBorder)
        end
    end
end

function BLT:DebugCooldownBars()
    local hasAtLeastOneCooldownFrameUp = false
    for i=1, #cooldown_Frames do
        local frame = cooldown_Frames[i]
        if frame.isUsed and frame.isTest then
            hasAtLeastOneCooldownFrameUp = true
        end
    end
    if hasAtLeastOneCooldownFrameUp then
        -- Set all test cooldown frames to not be used anymore
        for i=1, #cooldown_Frames do
            local frame = cooldown_Frames[i]
            if frame.isUsed and frame.isTest then
                frame.isUsed = false
                frame.frameBackground:Hide()
                frame.fontFrame:Hide()
                frame:Hide()
            end
        end
    else
        -- Debug code to see how it looks with multiple cooldowns up
        for n=1, #icon_Frames do
            local frame = icon_Frames[n]
            local name = frame.name
            local class = frame.class
            local id = frame.id
            local isItem = frame.isItem

            for i=1, 7 do
                local testFrame = self:CreateCooldownFrame("Test" .. i, name, id, (db.displayTargets and
                        not isItem and BLT.spells[class][name].tar) and L["Target"] .. i+1 or nil, isItem)
                testFrame.class = class
                testFrame.isTest = true
            end
        end
    end
end

function BLT:IsCooldownSpellEnabled(spellName)
    for i=1, #trackCooldownAllUniqueSpellNames do
        if trackCooldownAllUniqueSpellNames[i] == spellName then
            return trackCooldownAllUniqueSpellEnabledStatuses[i]
        end
    end
    return true
end

function BLT:IsCooldownItemEnabled(itemName)
    for i=1, #trackCooldownAllUniqueItemNames do
        if trackCooldownAllUniqueItemNames[i] == itemName then
            return trackCooldownAllUniqueItemEnabledStatuses[i]
        end
    end
    return true
end

function BLT:IsPlayerValidForSpellCooldown(player, index)
    if self.playerSpecs[player] and self.playerLevel[player] >= trackLvlRequirement[index] then
        if trackCooldownSpecs[index] == self.playerSpecs[player] or trackCooldownSpecs[index] == "Any" then
            if trackTalents[index] == "nil" or (trackTalents[index] ~= "nil" and talentRequired[index] == false) then
                return true
            elseif self.playerTalentsSpecced[player] and contains(self.playerTalentsSpecced[player], trackTalents[index], true) then
                return true
            end
        end
    end
    return false
end

function BLT:IsPlayerValidForItemCooldown(player, index)
    if self.playerEquipment[player] and contains(self.playerEquipment[player], trackItems[index]) then
        return true
    end
    return false
end

function BLT:GetMaximumCooldown(name, player, isItem)
    if isItem then
        for i=1, #trackItems do
            if trackItems[i] == name then
                return trackItemCooldowns[i]
            end
        end
    else
        local cooldown = 0
        for i=1, #trackCooldownSpells do
            if trackCooldownSpells[i] == name and
                    (trackCooldownSpecs[i] == "Any" or trackCooldownSpecs[i] == self.playerSpecs[player]) then
                if self.playerTalentsSpecced[player] and contains(self.playerTalentsSpecced[player],trackTalents[i],true) then
                    for talent,rank in pairs(self.playerTalentsSpecced[player]) do
                        if talent == trackTalents[i] then
                            if trackCooldownAlternativeSpellCooldown[i] ~= "nil" then
                                cooldown = trackCooldownSpellCooldown[i] - (trackCooldownAlternativeSpellCooldown[i] * rank)
                                break
                            else
                                cooldown = trackCooldownSpellCooldown[i]
                                break
                            end
                        end
                    end
                else
                    cooldown = trackCooldownSpellCooldown[i]
                end
                if self.playerGlyphs[player] and find(self.playerGlyphs[player], trackGlyphs[i]) then
                    cooldown = cooldown - trackGlyphCooldown[i]
                end
            end
        end
        return cooldown
    end
    return 0
end

function BLT:GetSpellIDFromName(spellName)
    for i=1, #trackCooldownSpells do
        if trackCooldownSpells[i] == spellName then
            return trackCooldownSpellIDs[i]
        end
    end
end

function BLT:SetOptions()
    scaleUI = ConvertSliderValueToPercentageValue(db.scale)
    cooldownXOffset_Scale = ConvertSliderValueToPercentageValue(db.barOffsetX)
    barPlayerTextSize_Scale = ConvertSliderValueToPercentageValue(db.barPlayerTextSize)
    barCDTextSize_Scale = ConvertSliderValueToPercentageValue(db.barCDTextSize)
    barTargetTextSize_Scale = ConvertSliderValueToPercentageValue(db.barTargetTextSize)
    cooldownWidth_Scale = ConvertSliderValueToPercentageValue(db.barWidth)
    cooldownHeight_Scale = ConvertSliderValueToPercentageValue(db.barHeight)
    offsetBetweenIcons_Scale = ConvertSliderValueToPercentageValue(db.iconOffsetY)
    offsetBetweenCooldowns_Scale = ConvertSliderValueToPercentageValue(db.barOffset)
    edgeOffset_Scale = ConvertSliderValueToPercentageValue(db.offset)
    iconTextSize_Scale = ConvertSliderValueToPercentageValue(db.iconTextSize)
    iconSize_Scale = ConvertSliderValueToPercentageValue(db.iconSize)
    targetTextPosX_Scale = ConvertSliderValueToPercentageValue(db.barTargetTextPosX)
    targetTextPosY_Scale = ConvertSliderValueToPercentageValue(db.barTargetTextPosY)

    for i=1, #cooldown_Frames do
        cooldown_Frames[i].texture:SetTexture(Media:Fetch("statusbar", db.texture))
    end

    for i=1, #trackCooldownAllUniqueSpellNames do
        trackCooldownAllUniqueSpellEnabledStatuses[i] = db.cooldowns[trackCooldownSpellIDs[i]]
    end
    for i=1, #trackCooldownAllUniqueItemNames do
        trackCooldownAllUniqueItemEnabledStatuses[i] = db.cooldowns[trackItemIDs[i]]
    end

    for i=1, #icon_Frames do
        icon_Frames[i].fontString:ClearAllPoints()
        icon_Frames[i].fontString:SetPoint(db.iconTextAnchor)
    end

    SetMainFrameLockedStatus(db.locked)
    self:UpdateVisible()
    self:UpdateUISize()
end

function BLT:UpdateVisible()
    local inParty = GetNumPartyMembers() > 0
    local inRaid = GetNumRaidMembers() > 0
    -- Check for pet|party|raid|alone
    local show = (db.party and inParty) or
            (db.raid and inRaid) or
            (db.solo and not inParty and not inRaid)

    -- Then hide override if necessary for resting|pvp
    local _, instanceType = IsInInstance()
    if (db.resting and IsResting()) or (db.pvp and (instanceType == "pvp" or instanceType == "arena")) then
        show = false
    end
    if not db.useShowWith or db.debugIcons then
        show = true
    end

    if db.enable and show then
        mainFrame:Show()
        mainFrame.isSetToHidden = false
    else
        mainFrame:Hide()
        mainFrame.isSetToHidden = true
    end
end

function BLT:SetAnchors(useDB, conf)
    local x, y
    if useDB then
        if conf then
            x, y = db.posX, db.posY-yOffsetMaximum
        else
            x, y = db.posX, db.posY -- If the mainframe has a height defined, then we need to subtract it here
        end
        if x and y then
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("BOTTOMLEFT", x, y)
        else
            mainFrame:ClearAllPoints()
            mainFrame:SetPoint("CENTER", 0, 0)
        end
    else
        x, y = math.floor(mainFrame:GetLeft() + 0.5), math.floor(mainFrame:GetTop() + 0.5)
        db.posX, db.posY = x, y
    end
    ACR:NotifyChange("BLT")
end

function BLT:Toggle(setting)
    if setting then
        if setting == true then
            db.enable = true
        else
            db.enable = false
        end
    else
        db.enable = not db.enable
    end
    ACR:NotifyChange("BLT")
    self:SetOptions()
end

function BLT:Lock()
    db.locked = not db.locked
    ACR:NotifyChange("BLT")
    self:SetOptions()
end
