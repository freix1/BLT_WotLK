local BLT = LibStub("AceAddon-3.0"):GetAddon("BLT")
local L = LibStub("AceLocale-3.0"):GetLocale("BLT")
local Media = LibStub("LibSharedMedia-3.0")
local textures = Media:HashTable("statusbar")
local fonts = Media:HashTable("font")

local pairs = _G.pairs
local tonumber, tostring = _G.tonumber, _G.tostring

local function set(t, value)
    BLT.db.profile[t[#t]] = value
    BLT:SetOptions()
end
local function get(t)
    return BLT.db.profile[t[#t]]
end
local function tlen(t)
    local count = 0
    for k in pairs(t) do
        for _ in pairs(t[k]) do
            count = count + 1
        end
    end
    return count
end

-- Option table for slash commands
BLT.commands = {
    type = "group",
    name = L["Slash Commands"],
    args = {
        toggle = {
            type = "execute",
            name = L["Toggle"],
            desc = L["Toggle BLT"],
            func = function() BLT:Toggle() end,
            order = 1
        },
        show = {
            type = "execute",
            name = L["Show"],
            desc = L["Show BLT"],
            func = function() BLT:Toggle(true) end,
            order = 2
        },
        hide = {
            type = "execute",
            name = L["Hide"],
            desc = L["Hide BLT"],
            func = function() BLT:Toggle(false) end,
            order = 3
        },
        lock = {
            type = "execute",
            name = L["Lock"],
            desc = L["Lock BLT in place"],
            func = function() BLT:Lock() end,
            order = 4
        },
        reload = {
            type = "execute",
            name = L["Reload"],
            desc = L["Clear all data from inspected players"],
            func = function() BLT:ClearLists() end,
            order = 5
        },
        config = {
            type = "execute",
            name = L["Configure"],
            desc = L["Show the addon configurations"],
            func = function() BLT:ShowConfig() end,
            order = 6
        }
    }
}

-- Option table for the configuration window
BLT.options = {
    type = "group",
    name = L["General"],
    args = {
        general = {
            type = "group",
            name = "BLT",
            desc = L["Configure general options"],
            cmdHidden = true,
            args = {
                enable = {
                    type = "toggle",
                    name = L["Enable"],
                    desc = L["Enable the addon and show it"],
                    get = get,
                    set = set,
                    order = 1
                },
                locked = {
                    type = "toggle",
                    name = L["Lock"],
                    desc = L["Locks the anchor in place and prevents it from being dragged"],
                    get = get,
                    set = set,
                    order = 2
                },
                message = {
                    type = "toggle",
                    name = L["Cooldown Ready Message"],
                    desc = L["Receive a chat message when a cooldown gets ready"],
                    get = get,
                    set = set,
                    width = "full",
                    order = 3
                },
                scale = {
                    type = "range",
                    name = L["Scale"],
                    desc = L["Control the scale of the entire GUI"],
                    min = 1, max = 100, step = 1, bigStep = 1,
                    get = get,
                    set = set,
                    width = "full",
                    order = 4
                },
                offset = {
                    type = "range",
                    name = L["Edge Offset"],
                    desc = L["Control the offset from the edge of the screen"],
                    min = 1, max = 100, step = 1, bigStep = 1,
                    get = get,
                    set = set,
                    width = "full",
                    order = 5
                },
                posX = {
                    type = "input",
                    name = L["X Position"],
                    get = function() if BLT.db.profile.posX then return tostring(floor(BLT.db.profile.posX+0.5)) end end,
                    set = function(_, value)
                        BLT.db.profile.posX = tonumber(value)
                        BLT:SetAnchors(true, true)
                    end,
                    order = 6
                },
                posY = {
                    type = "input",
                    name = L["Y Position"],
                    get = function() if BLT.db.profile.posY then return tostring(floor(BLT.db.profile.posY+0.5)) end end,
                    set = function(_, value)
                        BLT.db.profile.posY = tonumber(value)
                        BLT:SetAnchors(true, true)
                    end,
                    order = 7
                },
                miscHeader = {
                    type = "header",
                    name = L["Miscellaneous"],
                    cmdHidden = true,
                    order = 8
                },
                checkRaid = {
                    type = "execute",
                    name = L["Raid Addon Check"],
                    desc = L["Check who in your raid is also running BLT"],
                    func = function()
                        if UnitInRaid("player") then
                            SendAddonMessage("BLT", "Request-Version", "RAID")
                        else
                            BLT:Print(L["You are not in a raid group!"])
                        end
                    end,
                    order = 9
                }
            }
        },
        show = {
            type = "group",
            name = L["Show When..."],
            desc = L["Show BLT when..."],
            args = {
                intro = {
                    type = "description",
                    name = L["This section controls when BLT is automatically shown or hidden"],
                    disabled = false,
                    order = 1,
                },
                useShowWith = {
                    type = "toggle",
                    name = L["Use Auto Show/Hide"],
                    desc = L["Use this option to restrict when BLT should be shown"],
                    get = get,
                    set = set,
                    disabled = false,
                    order = 2,
                },
                showWithGroup = {
                    type = "group",
                    guiInline = true,
                    name = L["Auto Show/Hide Options"],
                    disabled = function() return not BLT.db.profile.useShowWith end,
                    order = 3,
                    args = {
                        intro2 = {
                            type = "description",
                            name = L["Show BLT when any of the following are true..."],
                            order = 1,
                        },
                        solo = {
                            type = "toggle",
                            name = L["You are alone"],
                            desc = L["Show BLT when you are alone"],
                            get = get,
                            set = set,
                            order = 2,
                        },
                        party = {
                            type = "toggle",
                            name = L["You are in a party"],
                            desc = L["Show BLT when you are in a 5-man party"],
                            get = get,
                            set = set,
                            order = 3,
                        },
                        raid = {
                            type = "toggle",
                            name = L["You are in a raid"],
                            desc = L["Show BLT when you are in a raid"],
                            get = get,
                            set = set,
                            order = 4,
                        },
                        intro3 = {
                            type = "description",
                            name = L["However, hide BLT if any of the following are true (higher priority than the above)"],
                            order = 5,
                        },
                        pvp = {
                            type = "toggle",
                            width = "double",
                            name = L["You are in a battleground"],
                            desc = L["Turning this on will cause BLT to hide whenever you are in a battleground or arena"],
                            get = get,
                            set = set,
                            order = 6,
                        },
                        resting = {
                            type = "toggle",
                            width = "double",
                            name = L["You are resting"],
                            desc = L["Turning this on will cause BLT to hide whenever you are in a city or inn"],
                            get = get,
                            set = set,
                            order = 7,
                        }
                    }
                }
            }
        },
        icons = {
            type = "group",
            name = L["Icons"],
            desc = L["Options which affect the look and behaviour of the icons"],
            args = {
                debugIcons = {
                    type = "toggle",
                    name = L["Test Icons"],
                    desc = L["Show all enabled icons for testing purposes"],
                    get = get,
                    set = set,
                    width = "full",
                    order = 1
                },
                iconGroup = {
                    type = "group",
                    guiInline = true,
                    name = L["Icon Options"],
                    order = 2,
                    args = {
                        iconSize = {
                            type = "range",
                            name = L["Icon Size"],
                            desc = L["Control the size of the icons"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 1
                        },
                        iconOffsetY = {
                            type = "range",
                            name = L["Icon Vertical Offset"],
                            desc = L["Control the vertical offset between icons"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 2
                        },
                        iconBorderSize = {
                            type = "range",
                            name = L["Icon Border Size"],
                            desc = L["Control the border size of the icons"],
                            min = 1, max = 3, step = 1, bigStep = 1,
                            get = get,
                            set = function(_, value)
                                BLT.db.profile.iconBorderSize = value
                                BLT:UpdateIconBorders()
                            end,
                            width = "full",
                            order = 3
                        }
                    }
                },
                iconTextGroup = {
                    type = "group",
                    name = L["Icon Text Options"],
                    cmdHidden = true,
                    guiInline = true,
                    order = 5,
                    args = {
                        iconFont = {
                            type = "select",
                            dialogControl = 'LSM30_Font',
                            name = L["Font"],
                            desc = L["Change the font of the icons"],
                            values = fonts,
                            get = function()
                                return BLT.db.profile.iconFont
                            end,
                            set = function(_, value)
                                BLT.db.profile.iconFont = value
                                BLT:UpdateUISize()
                            end,
                            order = 1
                        },
                        iconTextAnchor = {
                            type = "select",
                            name = L["Text Anchor"],
                            desc = L["Control the anchor of the icon text. Default: CENTER"],
                            values = {
                                ["BOTTOM"] = L["BOTTOM"],
                                ["BOTTOMLEFT"] = L["BOTTOMLEFT"],
                                ["BOTTOMRIGHT"] = L["BOTTOMRIGHT"],
                                ["CENTER"] = L["CENTER"],
                                ["LEFT"] = L["LEFT"],
                                ["RIGHT"] = L["RIGHT"],
                                ["TOP"] = L["TOP"],
                                ["TOPLEFT"] = L["TOPLEFT"],
                                ["TOPRIGHT"] = L["TOPRIGHT"]
                            },
                            get = function()
                                return BLT.db.profile.iconTextAnchor
                            end,
                            set = function(_, value)
                                BLT.db.profile.iconTextAnchor = value
                                BLT:SetOptions()
                            end,
                            order = 2
                        },
                        iconTextSize = {
                            type = "range",
                            name = L["Text Size"],
                            desc = L["Control the size of the icon text size"],
                            min = 1, max = 32, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            order = 3
                        },
                        iconTextColor = {
                            type = "color",
                            name = L["Text Color"],
                            desc = L["Change the color of the icon text"],
                            hasAlpha = true,
                            get = function()
                                local t = BLT.db.profile.iconTextColor
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(_, r, g, b, a)
                                local t = BLT.db.profile.iconTextColor
                                t.r, t.g, t.b, t.a = r, g, b, a
                                BLT:UpdateUISize()
                            end,
                            order = 4
                        }
                    }
                }
            }
        },
        bars = {
            type = "group",
            name = L["Bars"],
            desc = L["Options which affect the look and behaviour of the bars"],
            args = {
                debugBars = {
                    type = "toggle",
                    name = L["Test Bars"],
                    desc = L["Show test bars for currently shown icons"],
                    get = get,
                    set = function(_, value)
                        BLT.db.profile.debugBars = value
                        BLT:DebugCooldownBars()
                    end,
                    width = "full",
                    order = 1
                },
                displayTargets = {
                    type = "toggle",
                    name = L["Display Targets"],
                    desc = L["Show the names of targets on the bars"],
                    get = get,
                    set = set,
                    order = 2
                },
                alignBarSide = {
                    type = "toggle",
                    name = L["Align Bars Left"],
                    desc = L["Align the bars to the left, instead of the default right side"],
                    get = get,
                    set = set,
                    order = 3
                },
                barGroup = {
                    type = "group",
                    name = L["Bar Options"],
                    cmdHidden = true,
                    guiInline = true,
                    order = 4,
                    args = {
                        barWidth = {
                            type = "range",
                            name = L["Bar Width"],
                            desc = L["Control the width of bars"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 1
                        },
                        barHeight = {
                            type = "range",
                            name = L["Bar Height"],
                            desc = L["Control the height of bars"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 2
                        },
                        split = {
                            type = "range",
                            name = L["Bar Split"],
                            desc = L["Control how many bars are shown until they are split"],
                            min = 1, max = 10, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 3
                        },
                        barOffset = {
                            type = "range",
                            name = L["Bar Spacing"],
                            desc = L["Control the general offset between bars"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 4
                        },
                        barOffsetX = {
                            type = "range",
                            name = L["Bar Horizontal Offset"],
                            desc = L["Control the horizontal offset between icons and bars"],
                            min = 1, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            width = "full",
                            order = 5
                        },
                        barFont = {
                            type = "select",
                            dialogControl = 'LSM30_Font',
                            name = L["Font"],
                            desc = L["Change the font of the bars"],
                            values = fonts,
                            get = function() return BLT.db.profile.barFont end,
                            set = function(_, value)
                                BLT.db.profile.barFont = value
                                BLT:UpdateUISize()
                            end,
                            order = 6
                        },
                        texture = {
                            type = "select",
                            dialogControl = 'LSM30_Statusbar',
                            name = L["Texture"],
                            desc = L["Change the texture of the bars"],
                            values = textures,
                            get = function() return BLT.db.profile.texture end,
                            set = function(_, value)
                                BLT.db.profile.texture = value
                                BLT:SetOptions()
                            end,
                            order = 7
                        }
                    }
                },
                barPlayerTextGroup = {
                    type = "group",
                    name = L["Player Text Options"],
                    guiInline = true,
                    cmdHidden = true,
                    order = 5,
                    args = {
                        barPlayerTextSize = {
                            type = "range",
                            name = L["Player Text Size"],
                            desc = L["Change the player text size of the bars"],
                            min = 1, max = 32, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            order = 1
                        },
                        barPlayerTextColor = {
                            type = "color",
                            name = L["Player Text Color"],
                            desc = L["Change the color of the player text"],
                            hasAlpha = true,
                            get = function()
                                local t = BLT.db.profile.barPlayerTextColor
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(_, r, g, b, a)
                                local t = BLT.db.profile.barPlayerTextColor
                                t.r, t.g, t.b, t.a = r, g, b, a
                                BLT:UpdateUISize()
                            end,
                            order = 2
                        }
                    }
                },
                barTargetTextGroup = {
                    type = "group",
                    name = L["Target Text Options"],
                    guiInline = true,
                    cmdHidden = true,
                    disabled = function()
                        return not BLT.db.profile.displayTargets
                    end,
                    order = 6,
                    args = {
                        barTargetTextType = {
                            type = "select",
                            name = L["Select Target Text Type"],
                            desc = L["Decide how the target text should be displayed"],
                            values = {
                                ["PLAYERTEXT"] = L["Together with player text"],
                                ["SEPARATE"] = L["Separate text which can be modified"]
                            },
                            get = function()
                                return BLT.db.profile.barTargetTextType
                            end,
                            set = function(_, value)
                                BLT.db.profile.barTargetTextType = value
                                BLT:SetOptions()
                            end,
                            width = "full",
                            order = 1
                        },
                        barTargetTextSize = {
                            type = "range",
                            name = L["Target Text Size"],
                            desc = L["Change the target text size of the bars"],
                            min = 1, max = 32, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 2
                        },
                        barTargetTextCutoff = {
                            type = "range",
                            name = L["Target Text Cutoff"],
                            desc = L["Change the cutoff of the target text"],
                            min = -100, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = function(_, value)
                                BLT.db.profile.barTargetTextCutoff = value
                                BLT:UpdateUISize()
                            end,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 3
                        },
                        barTargetTextPosX = {
                            type = "range",
                            name = L["Target Text X Position"],
                            desc = L["Change the horizontal position of the target text"],
                            min = -100, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = function(_, value)
                                BLT.db.profile.barTargetTextPosX = value
                                BLT:SetOptions()
                            end,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 4
                        },
                        barTargetTextPosY = {
                            type = "range",
                            name = L["Target Text Y Position"],
                            desc = L["Change the vertical position of the target text"],
                            min = -100, max = 100, step = 1, bigStep = 1,
                            get = get,
                            set = function(_, value)
                                BLT.db.profile.barTargetTextPosY = value
                                BLT:SetOptions()
                            end,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 5
                        },
                        barTargetTextAnchor = {
                            type = "select",
                            name = L["Target Text Anchor"],
                            desc = L["Control the anchor of the target text. Default: LEFT"],
                            values = {
                                ["CENTER"] = L["CENTER"],
                                ["LEFT"] = L["LEFT"],
                                ["RIGHT"] = L["RIGHT"]
                            },
                            get = function()
                                return BLT.db.profile.barTargetTextAnchor
                            end,
                            set = function(_, value)
                                BLT.db.profile.barTargetTextAnchor = value
                                BLT:SetOptions()
                            end,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 6
                        },
                        barTargetTextColor = {
                            type = "color",
                            name = L["Target Text Color"],
                            desc = L["Change the color of the target text"],
                            hasAlpha = true,
                            get = function()
                                local t = BLT.db.profile.barTargetTextColor
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(_, r, g, b, a)
                                local t = BLT.db.profile.barTargetTextColor
                                t.r, t.g, t.b, t.a = r, g, b, a
                                BLT:UpdateUISize()
                            end,
                            disabled = function() return BLT.db.profile.barTargetTextType == "PLAYERTEXT" end,
                            order = 7
                        }
                    }
                },
                barCDTextGroup = {
                    type = "group",
                    name = L["Cooldown Text Options"],
                    cmdHidden = true,
                    guiInline = true,
                    order = 7,
                    args = {
                        barCDTextSize = {
                            type = "range",
                            name = L["Cooldown Text Size"],
                            desc = L["Change the cooldown text size of the bars"],
                            min = 1, max = 32, step = 1, bigStep = 1,
                            get = get,
                            set = set,
                            order = 1
                        },
                        barCDTextColor = {
                            type = "color",
                            name = L["Cooldown Text Color"],
                            desc = L["Change the color of the cooldown text"],
                            hasAlpha = true,
                            get = function()
                                local t = BLT.db.profile.barCDTextColor
                                return t.r, t.g, t.b, t.a
                            end,
                            set = function(_, r, g, b, a)
                                local t = BLT.db.profile.barCDTextColor
                                t.r, t.g, t.b, t.a = r, g, b, a
                                BLT:UpdateUISize()
                            end,
                            order = 2
                        }
                    }
                }
            }
        },
        cooldowns = {
            type = "group",
            name = L["Cooldowns"],
            desc = L["Configure which spells/items are shown"],
            cmdHidden = true,
            args = {}
        },
        sorting = {
            type = "group",
            name = L["Sorting"],
            desc = L["Configure the sorting of the spells/items"],
            cmdHidden = true,
            args = {
                desc = {
                    type = "description",
                    name = L["This section controls how spells and items are sorted"],
                    disabled = false,
                    order = 0,
                },
                useCustomSorting = {
                    type = "toggle",
                    name = L["Use Custom Sorting"],
                    desc = L["Use custom sorting instead of the default sorting"],
                    get = get,
                    set = set,
                    disabled = false,
                    order = 0.1,
                },
                resetCustomSorting = {
                    type = "execute",
                    name = L["Reset to Default"],
                    desc = L["Reset the custom sorting to the default sorting"],
                    confirm = true,
                    func = function()
                        for k in pairs(BLT.db.profile.sorting) do
                            for k2 in pairs(BLT.spells) do
                                for _,v in pairs(BLT.spells[k2]) do
                                    if v.id == k then
                                        BLT.db.profile.sorting[k] = v.nr
                                        break
                                    end
                                end
                            end
                        end
                        for k in pairs(BLT.db.profile.sorting) do
                            for k2 in pairs(BLT.items) do
                                for _,v in pairs(BLT.items[k2]) do
                                    if v.itemId == k then
                                        BLT.db.profile.sorting[k] = v.nr
                                        break
                                    end
                                end
                            end
                        end
                    end,
                    order = 0.2,
                },
                defineSorting = {
                    type = "header",
                    name = L["Define Sorting"],
                    order = 0.3,
                }
            }
        }
    }
}

do
    local t = BLT.options.args.cooldowns.args
    local s = BLT.options.args.sorting.args
    local i = 5 -- Sorting

    for k in pairs(BLT.spells) do
        -- Separate class spells with a header
        t[k] = {
            type = "header",
            name = L[k],
            cmdHidden = true,
            order = i
        }
        i = i + 1

        -- Add an option entry for each spell
        for k2, v in pairs(BLT.spells[k]) do
            t[tostring(v.id)] = {
                type = "toggle",
                name = k2,
                desc = L["Display %s cooldowns"]:format(k2),
                order = i,
                get = function()
                    return BLT.db.profile.cooldowns[v.id]
                end,
                set = function(_, value)
                    BLT.db.profile.cooldowns[v.id] = value
                    BLT:SetOptions()
                end,
                cmdHidden = true
            }

            s[tostring(v.id)] = {
                type = "group",
                name = function() return BLT.db.profile.sorting[v.id] .. ". " .. k2 end,
                order = function() return tonumber(BLT.db.profile.sorting[v.id]) end,
                guiInline = true,
                args = {
                    up = {
                        type = "execute",
                        name = L["Up"],
                        func = function()
                            if BLT.db.profile.sorting[v.id] ~= 1 then
                                for key, value in pairs(BLT.db.profile.sorting) do
                                    if value == BLT.db.profile.sorting[v.id]-1 then
                                        BLT.db.profile.sorting[key] = value+1
                                        break
                                    end
                                end
                                BLT.db.profile.sorting[v.id] = BLT.db.profile.sorting[v.id]-1
                            end
                        end,
                        order = 1
                    },
                    down = {
                        type = "execute",
                        name = L["Down"],
                        func = function()
                            if BLT.db.profile.sorting[v.id] ~= (tlen(BLT.spells) + tlen(BLT.items)) then
                                for key, value in pairs(BLT.db.profile.sorting) do
                                    if value == BLT.db.profile.sorting[v.id]+1 then
                                        BLT.db.profile.sorting[key] = value-1
                                        break
                                    end
                                end
                                BLT.db.profile.sorting[v.id] = BLT.db.profile.sorting[v.id]+1
                            end
                        end,
                        order = 2
                    },
                    nr = {
                        type = "input",
                        name = L["Sort Nr"],
                        get = function() return tostring(BLT.db.profile.sorting[v.id]) end,
                        set = function(_, value) BLT.db.profile.sorting[v.id] = tonumber(value) end,
                        guiHidden = true,
                        order = 3
                    }
                }
            }
            i = i + 1
        end
    end

    for k in pairs(BLT.items) do
        t[k] = {
            type = "header",
            name = L[k],
            cmdHidden = true,
            order = i
        }
        i = i + 1

        -- Add an option entry for each item
        for k2, v in pairs(BLT.items[k]) do
            t[k2] = {
                type = "toggle",
                name = k2,
                desc = L["Display %s cooldowns"]:format(k2),
                order = i,
                get = function()
                    return BLT.db.profile.cooldowns[v.itemId]
                end,
                set = function(_, value)
                    BLT.db.profile.cooldowns[v.itemId] = value
                    BLT:SetOptions()
                end,
                cmdHidden = true
            }

            s[k2] = {
                type = "group",
                name = function() return BLT.db.profile.sorting[v.itemId] .. ". " ..  k2 end,
                order = function() return tonumber(BLT.db.profile.sorting[v.itemId]) end,
                guiInline = true,
                args = {
                    up = {
                        type = "execute",
                        name = L["Up"],
                        func = function()
                            if BLT.db.profile.sorting[v.itemId] ~= 1 then
                                for key, value in pairs(BLT.db.profile.sorting) do
                                    if value == BLT.db.profile.sorting[v.itemId]-1 then
                                        BLT.db.profile.sorting[key] = value+1
                                        break
                                    end
                                end
                                BLT.db.profile.sorting[v.itemId] = BLT.db.profile.sorting[v.itemId]-1
                            end
                        end,
                        order = 1
                    },
                    down = {
                        type = "execute",
                        name = L["Down"],
                        func = function()
                            if BLT.db.profile.sorting[v.itemId] ~= (tlen(BLT.spells) + tlen(BLT.items)) then
                                for key, value in pairs(BLT.db.profile.sorting) do
                                    if value == BLT.db.profile.sorting[v.itemId]+1 then
                                        BLT.db.profile.sorting[key] = value-1
                                        break
                                    end
                                end
                                BLT.db.profile.sorting[v.itemId] = BLT.db.profile.sorting[v.itemId]+1
                            end
                        end,
                        order = 2
                    },
                    nr = {
                        type = "input",
                        name = L["Sort Nr"],
                        get = function() return tostring(BLT.db.profile.sorting[v.itemId]) end,
                        set = function(_, value) BLT.db.profile.sorting[v.itemId] = tonumber(value) end,
                        guiHidden = true,
                        order = 3
                    }
                }
            }
            i = i + 1
        end
    end
end
