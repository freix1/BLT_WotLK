local BLT = LibStub("AceAddon-3.0"):NewAddon("BLT", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("BLT")
local TalentQuery = LibStub:GetLibrary("LibTalentQuery-1.0")

local select, pairs, ipairs, next = _G.select, _G.pairs, _G.ipairs, _G.next
local tinsert, tremove, tconcat, twipe = table.insert, table.remove, table.concat, table.wipe
local format, sub = string.format, string.sub

-- Local variables --
local mainFrame
local selfPlayerName
local addonUsers = {}
local inspectedUnits = {}
local updateCooldownTimer = 0
local classSpecs = {
    ["DRUID"] =         { [1] = "Balance",       [2] = "Feral",        [3] = "Restoration" },
    ["DEATHKNIGHT"] =   { [1] = "Blood",         [2] = "Frost",        [3] = "Unholy"      },
    ["MAGE"] =          { [1] = "Arcane",        [2] = "Fire",         [3] = "Frost"       },
    ["PRIEST"] =        { [1] = "Discipline",    [2] = "Holy",         [3] = "Shadow"      },
    ["ROGUE"] =         { [1] = "Assassination", [2] = "Combat",       [3] = "Subtlety"    },
    ["WARRIOR"] =       { [1] = "Arms",          [2] = "Fury",         [3] = "Protection"  },
    ["HUNTER"] =        { [1] = "Beastmastery",  [2] = "Marksmanship", [3] = "Survival"    },
    ["PALADIN"] =       { [1] = "Holy",          [2] = "Protection",   [3] = "Retribution" },
    ["SHAMAN"] =        { [1] = "Elemental",     [2] = "Enhancement",  [3] = "Restoration" },
    ["WARLOCK"] =       { [1] = "Affliction",    [2] = "Demonology",   [3] = "Destruction" }
}

-- Addon-specific variables --
BLT.playerSpecs = {}
BLT.playerClass = {}
BLT.playerLevel = {}
BLT.playerEquipment = {}
BLT.playerTalentPoints = {}
BLT.playerTalentsSpecced = {}
BLT.playerGlyphs = {}
BLT.specificTalents = {
    ["DEATHKNIGHT"] = {
        ["Hysteria"] = {1,19},
        ["Vampiric Blood"] = {1,23},
        ["Anti-Magic Zone"] = {3,22}
    },
    ["DRUID"] = {
        ["Survival Instincts"] = {2,7},
        ["Tranquility"] = {3,14}
    },
    ["MAGE"] = {
        ["Ice Block"] = {3,3}
    },
    ["PALADIN"] = {
        ["Aura Mastery"] = {1,6},
        ["Lay on Hands"] = {1,8},
        ["Hand of Protection"] = {2,4},
        ["Divine Sacrifice"] = {2,6},
        ["Divine Protection"] = {2,14},
        ["Ardent Defender"] = {2,18}
    },
    ["PRIEST"] = {
        ["Pain Suppression"] = {1,23},
        ["Power Infusion"] = {1,23},
        ["Guardian Spirit"] = {2,27},
        ["Dispersion"] = {3,27}
    },
    ["ROGUE"] = {
        ["Tricks of the Trade"] = {3,26}
    },
    ["SHAMAN"] = {
        ["Reincarnation"] = {3,3},
        ["Mana Tide Totem"] = {3,17}
    },
    ["WARRIOR"] = {
        ["Last Stand"] = {3,6},
        ["Shield Wall"] = {3,13}
    }
}

-- Local helper functions --
local function removeFirst(tbl, val)
    for i, v in ipairs(tbl) do
        if v == val then
            return tremove(tbl, i)
        end
    end
end

-- Global helper functions --
function BLT.contains(array, element, boolKey)
    if boolKey then
        for key, _ in pairs(array) do
            if key == element then
                return true
            end
        end
    else
        for _, value in pairs(array) do
            if value == element then
                return true
            end
        end
    end
end

function BLT.clearList(t)
    for k in pairs (t) do
        t[k] = nil
    end
end

local contains = BLT.contains
local clearList = BLT.clearList

-- Backend functions --
local function HandleEvent(_, event, ...)
    -- Check if the player has entered the world or we reloaded the UI
    if event == "PLAYER_ENTERING_WORLD" or event == "RAID_ROSTER_UPDATE" or event == "PARTY_MEMBERS_CHANGED" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
        clearList(inspectedUnits)
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, _, sender = ...
        if prefix ~= "BLT" then return end
        local arg1, arg2 = strsplit(":", msg)
        if arg1 == "Glyphs" then
            BLT.playerGlyphs[sender] = arg2
        elseif arg1 == "Request-Version" then
            SendAddonMessage("BLT", "Version:"..sub(BLT.version, 5), "WHISPER", sender)
        elseif arg1 == "Version" then
            addonUsers[sender] = arg2
            BLT:ScheduleTimer("ReportUserTimer", 0.5)
        end
    end
end

function BLT:ReportUserTimer()
    local users = {}
    local newUser
    local newVersion
    local myVersion = sub(self.version, 5)
    for user,version in pairs(addonUsers) do
        if version > myVersion then
            if version > newVersion then
                newUser, newVersion = user, version
            end
            tinsert(users, format("%s (|r|cFF00FF00%s|r|cFFBEBEBE)", self:Unit(user),version))
        else
            tinsert(users, format("%s (%s)", self:Unit(user),version))
        end
    end
    if next(users) ~= nil then
        self:Print(L["Online raid members using the addon: %s"]:format(tconcat(users, ", ")))
    end
    twipe(addonUsers)
end

function BLT:Update()
    -- Check if we are in a raid
    if UnitExists("raid1") then
        -- Update the unit targets as a raid
        for i=1, GetNumRaidMembers() do
            if UnitExists("raid" .. i) then
                local unitTarget = "raid" .. i
                local unitName = UnitName(unitTarget)
                if not UnitIsConnected(unitTarget) then
                    self:RemoveUnitFromTables(unitTarget)
                end
                if not contains(inspectedUnits,unitName) then
                    TalentQuery:Query(unitTarget)
                end
            end
        end

    -- Check if we are in a party
    elseif UnitExists("party1") then
        -- Update the unit targets as a party
        for i=1, GetNumPartyMembers() do
            if UnitExists("party" .. i) then
                local unitTarget = "party" .. i
                local unitName = UnitName(unitTarget)
                if not UnitIsConnected(unitTarget) then
                    self:RemoveUnitFromTables(unitTarget)
                end
                if not contains(inspectedUnits,unitName) then
                    TalentQuery:Query(unitTarget)
                end
            end
        end
    end
    if not UnitInRaid("player") and not contains(inspectedUnits,selfPlayerName) then
        TalentQuery:Query("player")
    end
end

function BLT:TalentQuery_Ready(e, name, r, unitId)
    -- Check if the player name is valid
    if name then
        -- Calculate the spec of the player
        local unitTargetLevel = UnitLevel(unitId)
        if unitTargetLevel > 9 then
            -- Check if the target seems to have a valid class
            local className, unitTargetClass = UnitClass(unitId)
            local getForInspectedPlayer -- This gets the talents from the last character NotifyInspect was called for
            if name == selfPlayerName then -- Sometimes "player" can be "raid3" etc
                getForInspectedPlayer = false -- This gets the talents from the current player
                self:CheckGlyphInformation()
            else
                getForInspectedPlayer = true
            end

            -- Check which spec (dual spec) is active
            local talentGroup = GetActiveTalentGroup(getForInspectedPlayer, false)
            if talentGroup and talentGroup ~= 0 then
                local x = select(3, GetTalentTabInfo(1, getForInspectedPlayer, false, talentGroup))
                local y = select(3, GetTalentTabInfo(2, getForInspectedPlayer, false, talentGroup))
                local z = select(3, GetTalentTabInfo(3, getForInspectedPlayer, false, talentGroup))

                local playerTalents = {}
                if contains(self.specificTalents, unitTargetClass, true) then
                    for _, value in pairs(self.specificTalents[unitTargetClass]) do
                        local talentFound, currentRank = self:CheckSpecificTalent(getForInspectedPlayer, value[1], value[2], talentGroup)
                        if talentFound and currentRank then
                            playerTalents[talentFound] = currentRank
                        end
                    end
                end

                local w = 0
                if unitTargetClass then
                    -- Calculate and set the spec
                    local unitTargetClassSpec
                    if (x + y + z) > 0 and not ((x == y and x >= z) or (x == z and x >= y) or (y == z and y >= x)) then
                        if (x > y) and (x > z) then
                            w = 1
                        elseif (y > z) then
                            w = 2
                        else
                            w = 3
                        end
                        unitTargetClassSpec = classSpecs[unitTargetClass][w]
                    else
                        unitTargetClassSpec = "Unknown"
                    end
                    self.playerSpecs[name] = unitTargetClassSpec
                    self.playerClass[name] = className
                    self.playerLevel[name] = unitTargetLevel
                    self.playerTalentPoints[name] = x .. "/" .. y .. "/" .. z
                    self.playerTalentsSpecced[name] = {}
                    if next(playerTalents) ~= nil then
                        self.playerTalentsSpecced[name] = playerTalents
                    end
                    local playerItems = {}
                    for i=1, 19 do
                        local itemID = GetInventoryItemID(unitId, i)
                        if itemID then
                            local itemName = GetItemInfo(itemID)
                            tinsert(playerItems, itemName)
                        end
                    end
                    self.playerEquipment[name] = {}
                    if next(playerItems) ~= nil then
                        self.playerEquipment[name] = playerItems
                    end

                    if self.playerSpecs[name] and not contains(inspectedUnits,name) then
                        tinsert(inspectedUnits, name)
                    end
                end
            end
        end
    end
end

function BLT:CheckSpecificTalent(getForInspectedPlayer, tabIndex, talentIndex, talentGroup)
    -- name, iconTexture, tier, column, rank, maxRank, isExceptional, meetsPrereq = GetTalentInfo(tabIndex, talentIndex[, isInspect[, isPet[, talentGroupIndex]]])
    local name,_,_,_,currentRank = GetTalentInfo(tabIndex, talentIndex, getForInspectedPlayer, false, talentGroup)
    if currentRank ~= 0 then
        return name, currentRank
    end
end

function BLT:CheckGlyphInformation()
    local glyphs = {}
    for i=1, GetNumGlyphSockets() do
        local glyphSpellID = select(3, GetGlyphSocketInfo(i))
        if glyphSpellID then
            local name = GetSpellInfo(glyphSpellID)
            tinsert(glyphs, name)
        end
    end
    SendAddonMessage("BLT", "Glyphs:"..tconcat(glyphs, ", "), self:GetGroupState(), selfPlayerName)
end

function BLT:GetGroupState()
    if select(2, IsInInstance()) == "pvp" then
        return "BATTLEGROUND"
    elseif UnitExists("raid1") then
        return "RAID"
    elseif GetNumPartyMembers() == 0 then
        return "WHISPER"
    elseif UnitExists("party1") then
        return "PARTY"
    end
end

function BLT:CreateBackendFrame()
    -- Create the main frame
    mainFrame = CreateFrame("Frame", "BLT_BackendFrame", UIParent)
    mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    mainFrame:RegisterEvent("RAID_ROSTER_UPDATE")
    mainFrame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    mainFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    mainFrame:RegisterEvent("CHAT_MSG_ADDON")
    mainFrame:SetScript("OnEvent", HandleEvent)
    TalentQuery.RegisterCallback(self, "TalentQuery_Ready")
    selfPlayerName = UnitName("player")
end

function BLT:UpdateBackend(elapsed)
    updateCooldownTimer = updateCooldownTimer - elapsed
    if updateCooldownTimer < 0 then
        self:Update()
        updateCooldownTimer = 0.1
    end
end

function BLT:ClearLists()
    clearList(self.playerSpecs)
    clearList(self.playerClass)
    clearList(self.playerLevel)
    clearList(self.playerTalentPoints)
    clearList(self.playerTalentsSpecced)
    clearList(self.playerEquipment)
    clearList(inspectedUnits)
    self:Print(L["All data cleared!"])
end

function BLT:RemoveUnitFromTables(unit)
    local unitName = UnitName(unit)
    self.playerSpecs[unitName] = nil
    self.playerClass[unitName] = nil
    self.playerLevel[unitName] = nil
    self.playerTalentPoints[unitName] = nil
    self.playerTalentsSpecced[unitName] = nil
    self.playerEquipment[unitName] = nil
    removeFirst(inspectedUnits,unitName)
end
