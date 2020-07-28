local BLT = LibStub("AceAddon-3.0"):GetAddon("BLT")

local GetSpellInfo  = GetSpellInfo
local GetItemInfo   = GetItemInfo
local GetItemName   = BLT_ItemNames
local GetTalentName = BLT_TalentNames
local GetGlyphName  = BLT_GlyphNames

--[[
    ["Localized Spell Name"] = {
        nr = 1,         -- Sort number (do NOT use a sort number twice)
        id = 12345,     -- Spell ID
        cd = 123,       -- Spell cooldown (sec)
        spec = "Any",   -- Class specialization
        talent = "nil", -- Talent to check
        talReq = true,  -- Talent requirement
        altCd = 456,    -- Talent cooldown reduction ([cd] - [altCd] * [spent points in talent] = [cd with reduction])
        lvlReq = 80,    -- Level requirement
        tar = true,     -- Spell has a target
        glyph = "nil",  -- Glyph name
        glyphCd = 567   -- Glyph cooldown reduction
    }

    - We assume that every Discipline Priest has specced into 'Pain Suppression' and 'Power Infusion'.
    - The WoW API doesn't allow us to track other players glyphs. However, there is a mechanism in place where people, that also have this addon, share glyph information with each other and their glyphs will be taken into consideration.
]]
local hero = (UnitFactionGroup("player") == "Alliance") and 32182 or 2825
BLT.spells = {
    ["DEATHKNIGHT"] = {
        -- Anti-Magic Zone
        [GetSpellInfo(51052)] = {
            nr = 7,
            id = 51052,
            cd = 120,
            spec = "Unholy",
            talent = GetTalentName[51052],
            talReq = true,
            altCd = "nil",
            lvlReq = 55,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Anti-Magic Shell
        [GetSpellInfo(48707)] = {
            nr = 10,
            id = 48707,
            cd = 45,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 68,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Icebound Fortitude
        [GetSpellInfo(48792)] = {
            nr = 8,
            id = 48792,
            cd = 120,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 62,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Vampiric Blood
        [GetSpellInfo(55233)] = {
            nr = 9,
            id = 55233,
            cd = 60,
            spec = "Blood",
            talent = GetTalentName[55233],
            talReq = true,
            altCd = "nil",
            lvlReq = 55,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Hysteria
        [GetSpellInfo(49016)] = {
            nr = 6,
            id = 49016,
            cd = 180,
            spec = "Blood",
            talent = GetTalentName[49016],
            talReq = true,
            altCd = "nil",
            lvlReq = 55,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["DRUID"] = {
        -- Barkskin
        [GetSpellInfo(22812)] = {
            nr = 5,
            id = 22812,
            cd = 60,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 44,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Innervate
        [GetSpellInfo(29166)] = {
            nr = 2,
            id = 29166,
            cd = 180,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 40,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Rebirth
        [GetSpellInfo(48477)] = {
            nr = 1,
            id = 48477,
            cd = 600,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 20,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Survival Instincts
        [GetSpellInfo(61336)] = {
            nr = 4,
            id = 61336,
            cd = 180,
            spec = "Feral",
            talent = GetTalentName[61336],
            talReq = true,
            altCd = "nil",
            lvlReq = 20,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Tranquility
        [GetSpellInfo(26983)] = {
            nr = 3,
            id = 26983,
            cd = 480,
            spec = "Any",
            talent = GetTalentName[26983],
            talReq = false,
            altCd = 144,
            lvlReq = 30,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["HUNTER"] = {
        -- Misdirection
        [GetSpellInfo(34477)] = {
            nr = 33,
            id = 34477,
            cd = 30,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 70,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["MAGE"] = {
        -- Ice Block
        [GetSpellInfo(45438)] = {
            nr = 37,
            id = 45438,
            cd = 300,
            spec = "Any",
            talent = GetTalentName[45438],
            talReq = false,
            altCd = 21,
            lvlReq = 30,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["PALADIN"] = {
        -- Ardent Defender
        [GetSpellInfo(66233)] = {
            nr = 21,
            id = 66233,
            cd = 120,
            spec = "Protection",
            talent = GetTalentName[66233],
            talReq = true,
            altCd = "nil",
            lvlReq = 40,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Aura Mastery
        [GetSpellInfo(31821)] = {
            nr = 13,
            id = 31821,
            cd = 120,
            spec = "Any",
            talent = GetTalentName[31821],
            talReq = true,
            altCd = "nil",
            lvlReq = 20,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Divine Protection
        [GetSpellInfo(498)] = {
            nr = 20,
            id = 498,
            cd = 180,
            spec = "Any",
            talent = GetTalentName[498],
            talReq = false,
            altCd = 30,
            lvlReq = 6,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Divine Sacrifice
        [GetSpellInfo(64205)] = {
            nr = 14,
            id = 64205,
            cd = 120,
            spec = "Any",
            talent = GetTalentName[64205],
            talReq = true,
            altCd = "nil",
            lvlReq = 20,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Divine Shield
        [GetSpellInfo(642)] = {
            nr = 22,
            id = 642,
            cd = 300,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 34,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Hand of Freedom
        [GetSpellInfo(1044)] = {
            nr = 18,
            id = 1044,
            cd = 25,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 18,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Hand of Protection
        [GetSpellInfo(10278)] = {
            nr = 17,
            id = 10278,
            cd = 300,
            spec = "Any",
            talent = GetTalentName[10278],
            talReq = false,
            altCd = 60,
            lvlReq = 10,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Hand of Sacrifice
        [GetSpellInfo(6940)] = {
            nr = 15,
            id = 6940,
            cd = 120,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 46,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Hand of Salvation
        [GetSpellInfo(1038)] = {
            nr = 16,
            id = 1038,
            cd = 120,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 26,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Lay on Hands
        [GetSpellInfo(48788)] = {
            nr = 19,
            id = 48788,
            cd = 1200,
            spec = "Any",
            talent = GetTalentName[48788],
            talReq = false,
            altCd = 120,
            lvlReq = 10,
            tar = true,
            glyph = GetGlyphName[48788],
            glyphCd = 300
        }
    },
    ["PRIEST"] = {
        -- Divine Hymn
        [GetSpellInfo(64843)] = {
            nr = 25,
            id = 64843,
            cd = 480,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 80,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Fear Ward
        [GetSpellInfo(6346)] = {
            nr = 29,
            id = 6346,
            cd = 180,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 20,
            tar = true,
            glyph = GetGlyphName[6346],
            glyphCd = 60
        },
        -- Dispersion
        [GetSpellInfo(47585)] = {
            nr = 28,
            id = 47585,
            cd = 120,
            spec = "Shadow",
            talent = GetTalentName[47585],
            talReq = true,
            altCd = "nil",
            lvlReq = 60,
            tar = true,
            glyph = GetGlyphName[47585],
            glyphCd = 45
        },
        -- Guardian Spirit
        [GetSpellInfo(47788)] = {
            nr = 24,
            id = 47788,
            cd = 180,
            spec = "Holy",
            talent = GetTalentName[47788],
            talReq = true,
            altCd = "nil",
            lvlReq = 60,
            tar = true,
            glyph = GetGlyphName[47788],
            glyphCd = 0
        },
        -- Hymn of Hope
        [GetSpellInfo(64901)] = {
            nr = 26,
            id = 64901,
            cd = 360,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 80,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Pain Suppression
        [GetSpellInfo(33206)] = {
            nr = 23,
            id = 33206,
            cd = 180,
            spec = "Discipline",
            talent = GetTalentName[33206],
            talReq = false,
            altCd = 18,
            lvlReq = 50,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        },
        -- Power Infusion
        [GetSpellInfo(10060)] = {
            nr = 27,
            id = 10060,
            cd = 120,
            spec = "Discipline",
            talent = GetTalentName[10060],
            talReq = false,
            altCd = 12,
            lvlReq = 40,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["ROGUE"] = {
        -- Tricks of the Trade
        [GetSpellInfo(57934)] = {
            nr = 34,
            id = 57934,
            cd = 30,
            spec = "Any",
            talent = GetTalentName[57934],
            talReq = false,
            altCd = 5,
            lvlReq = 75,
            tar = true,
            glyph = GetGlyphName[57934],
            glyphCd = 0
        }
    },
    ["SHAMAN"] = {
        -- Bloodlust/Heroism
        [GetSpellInfo(hero)] = {
            nr = 30,
            id = hero,
            cd = 300,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 70,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Mana Tide Totem
        [GetSpellInfo(16190)] = {
            nr = 31,
            id = 16190,
            cd = 300,
            spec = "Restoration",
            talent = GetTalentName[16190],
            talReq = true,
            altCd = "nil",
            lvlReq = 40,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Reincarnation
        [GetSpellInfo(20608)] = {
            nr = 32,
            id = 20608,
            cd = 1800,
            spec = "Any",
            talent = GetTalentName[20608],
            talReq = false,
            altCd = 450,
            lvlReq = 30,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["WARLOCK"] = {
        -- Soulshatter
        [GetSpellInfo(29858)] = {
            nr = 36,
            id = 29858,
            cd = 300,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 66,
            tar = false,
            glyph = "nil",
            glyphCd = 0
        },
        -- Soulstone Resurrection
        [GetSpellInfo(47883)] = {
            nr = 35,
            id = 47883,
            cd = 900,
            spec = "Any",
            talent = "nil",
            talReq = false,
            altCd = "nil",
            lvlReq = 18,
            tar = true,
            glyph = "nil",
            glyphCd = 0
        }
    },
    ["WARRIOR"] = {
        -- Last Stand
        [GetSpellInfo(12975)] = {
            nr = 12,
            id = 12975,
            cd = 180,
            spec = "Protection",
            talent = GetTalentName[12975],
            talReq = true,
            altCd = "nil",
            lvlReq = 20,
            tar = false,
            glyph = GetGlyphName[12975],
            glyphCd = 60
        },
        -- Shield Wall
        [GetSpellInfo(871)] = {
            nr = 11,
            id = 871,
            cd = 300,
            spec = "Any",
            talent = GetTalentName[871],
            talReq = false,
            altCd = 30,
            lvlReq = 28,
            tar = false,
            glyph = GetGlyphName[871],
            glyphCd = 120
        }
    }
}

--[[
    ["Localized Item Name"] = {
        nr = 1,            -- Sort number (do NOT use a sort number twice),
        spellId = 12345,   -- Spell ID Normal
        spellIdHc = 23456, -- Spell ID Heroic
        itemId = 34567,    -- Item ID (doesn't matter if Normal or Heroic version)
        cd = 123           -- Item cooldown (sec)
    }

    - GetItemInfo will only return item information if it is directly available in memory! Because of this we store all localized item names in a table by ourselves to avoid empty results.
]]
BLT.items = {
    ["ITEMS"] = {
        -- Glowing Twilight Scale
        [GetItemInfo(54589) or GetItemName[54589]]  = {
            nr = 38,
            spellId = 75490,
            spellIdHc = 75495,
            itemId = 54589,
            cd = 120
        },
        -- Sindragosa's Flawless Fang
        [GetItemInfo(50364) or GetItemName[50364]]  = {
            nr = 39,
            spellId = 71635,
            spellIdHc = 71638,
            itemId = 50364,
            cd = 60
        }
    }
}
