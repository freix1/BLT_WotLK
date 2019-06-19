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
			name = L["BLT"],
			desc = L["Configure general options."],
			cmdHidden = true,
			args = {
				enable = {
					type = "toggle",
					name = L["Enable"],
					desc = L["Enable the addon and show it."],
					get = get,
					set = set,
					order = 1
				},
				locked = {
					type = "toggle",
					name = L["Lock"],
					desc = L["Locks the anchor in place and prevents it from being dragged."],
					get = get,
					set = set,
					order = 2
				},
				message = {
					type = "toggle",
					name = L["Cooldown Ready Message"],
					desc = L["Receive a chat message when a cooldown gets ready."],
					get = get,
					set = set,
					width = "full",
					order = 3
				},
				scale = {
					type = "range",
					name = L["Scale"],
					desc = L["Control the scale of the entire GUI."],
					min = 1, max = 100, step = 1, bigStep = 1,
					get = get,
					set = set,
					width = "full",
					order = 4
				},
				offset = {
					type = "range",
					name = L["Edge Offset"],
					desc = L["Control the offset from the edge of the screen."],
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
					desc = L["Check who in your raid is also running BLT."],
					func = function()
						if IsInRaid() then
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
					name = L["This section controls when BLT is automatically shown or hidden."],
					disabled = false,
					order = 1,
				},
				useShowWith = {
					type = "toggle",
					name = L["Use Auto Show/Hide"],
					desc = L["Use this option to restrict when BLT should be shown."],
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
							desc = L["Show BLT when you are alone."],
							get = get,
							set = set,
							order = 2,
						},
						party = {
							type = "toggle",
							name = L["You are in a party"],
							desc = L["Show BLT when you are in a 5-man party."],
							get = get,
							set = set,
							order = 3,
						},
						raid = {
							type = "toggle",
							name = L["You are in a raid"],
							desc = L["Show BLT when you are in a raid."],
							get = get,
							set = set,
							order = 4,
						},
						intro3 = {
							type = "description",
							name = L["However, hide BLT if any of the following are true (higher priority than the above)."],
							order = 5,
						},
						pvp = {
							type = "toggle",
							width = "double",
							name = L["You are in a battleground"],
							desc = L["Turning this on will cause BLT to hide whenever you are in a battleground or arena."],
							get = get,
							set = set,
							order = 6,
						},
						resting = {
							type = "toggle",
							width = "double",
							name = L["You are resting"],
							desc = L["Turning this on will cause BLT to hide whenever you are in a city or inn."],
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
			desc = L["Options which affect the look and behaviour of the icons."],
			args = {
				debugIcons = {
					type = "toggle",
					name = L["Test Icons"],
					desc = L["Show all enabled icons for testing purposes."],
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
							desc = L["Control the size of the icons."],
							min = 1, max = 100, step = 1, bigStep = 1,
							get = get,
							width = "full",
							set = set,
							order = 1
						},
						iconOffsetY = {
							type = "range",
							name = L["Icon Vertical Offset"],
							desc = L["Control the vertical offset between icons."],
							min = 1, max = 100, step = 1, bigStep = 1,
							get = get,
							set = set,
							width = "full",
							order = 2
						},
						iconBorderSize = {
							type = "range",
							name = L["Icon Border Size"],
							desc = L["Control the border size of the icons."],
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
							desc = L["Change the font of the icons."],
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
							desc = L["Control the size of the icon text size."],
							min = 1, max = 32, step = 1, bigStep = 1,
							get = get,
							set = set,
							order = 3
						},
						iconTextColor = {
							type = "color",
							name = L["Text Color"],
							desc = L["Change the color of the icon text."],
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
			desc = L["Options which affect the look and behaviour of the bars."],
			args = {
				debugBars = {
					type = "toggle",
					name = L["Test Bars"],
					desc = L["Show test bars for currently shown icons."],
					get = get,
					set = function(_, value)
						BLT.db.profile.debugBars = value

						BLT:DebugCooldownBars()
					end,
					order = 1
				},
				displayTargets = {
					type = "toggle",
					name = L["Display Targets"],
					desc = L["Show the names of targets on the bars."],
					get = get,
					set = set,
					order = 2
				},
				barGroup = {
					type = "group",
					name = L["Bar Options"],
					cmdHidden = true,
					guiInline = true,
					order = 3,
					args = {
						barWidth = {
							type = "range",
							name = L["Bar Width"],
							desc = L["Control the width of bars."],
							min = 1, max = 100, step = 1, bigStep = 1,
							get = get,
							set = set,
							width = "full",
							order = 1
						},
						barHeight = {
							type = "range",
							name = L["Bar Height"],
							desc = L["Control the height of bars."],
							min = 1, max = 100, step = 1, bigStep = 1,
							get = get,
							set = set,
							width = "full",
							order = 2
						},
						split = {
							type = "range",
							name = L["Bar Split"],
							desc = L["Control how many bars are shown until they are split."],
							min = 1, max = 10, step = 1, bigStep = 1,
							get = get,
							set = set,
							width = "full",
							order = 3
						},
						barOffset = {
							type = "range",
							name = L["Bar Spacing"],
							desc = L["Control the general offset between bars."],
							min = 1, max = 100, step = 1, bigStep = 1,
							get = get,
							set = set,
							width = "full",
							order = 4
						},
						barOffsetX = {
							type = "range",
							name = L["Bar Horizontal Offset"],
							desc = L["Control the horizontal offset between icons and bars."],
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
							desc = L["Change the font of the bars."],
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
							desc = L["Change the texture of the bars."],
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
					order = 4,
					args = {
						barPlayerTextSize = {
							type = "range",
							name = L["Player Text Size"],
							desc = L["Change the player text size of the bars."],
							min = 1, max = 32, step = 1, bigStep = 1,
							get = get,
							set = set,
							order = 1
						},
						barPlayerTextColor = {
							type = "color",
							name = L["Player Text Color"],
							desc = L["Change the color of the player text."],
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
					order = 5,
					args = {
						barTargetTextSize = {
							type = "range",
							name = L["Target Text Size"],
							desc = L["Change the target text size of the bars."],
							min = 1, max = 32, step = 1, bigStep = 1,
							get = get,
							set = set,
							order = 1
						},
						barTargetTextCutoff = {
							type = "range",
							name = L["Target Text Cutoff"],
							desc = L["Change the cutoff of the target text."],
							min = -100, max = 100, step = 1, bigStep = 1,
							get = get,
							set = function(_, value)
								BLT.db.profile.barTargetTextCutoff = value
								BLT:UpdateUISize()
							end,
							order = 2
						},
						barTargetTextPosX = {
							type = "range",
							name = L["Target Text X Position"],
							desc = L["Change the horizontal position of the target text."],
							min = -100, max = 100, step = 1, bigStep = 1,
							get = get,
							set = function(_, value)
								BLT.db.profile.barTargetTextPosX = value
								BLT:SetOptions()
							end,
							order = 3
						},
						barTargetTextPosY = {
							type = "range",
							name = L["Target Text Y Position"],
							desc = L["Change the vertical position of the target text."],
							min = -100, max = 100, step = 1, bigStep = 1,
							get = get,
							set = function(_, value)
								BLT.db.profile.barTargetTextPosY = value
								BLT:SetOptions()
							end,
							order = 4
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
							order = 5
						},
						barTargetTextColor = {
							type = "color",
							name = L["Target Text Color"],
							desc = L["Change the color of the target text."],
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
							order = 6
						}
					}
				},
				barCDTextGroup = {
					type = "group",
					name = L["Cooldown Text Options"],
					cmdHidden = true,
					guiInline = true,
					order = 6,
					args = {
						barCDTextSize = {
							type = "range",
							name = L["Cooldown Text Size"],
							desc = L["Change the cooldown text size of the bars."],
							min = 1, max = 32, step = 1, bigStep = 1,
							get = get,
							set = set,
							order = 1
						},
						barCDTextColor = {
							type = "color",
							name = L["Cooldown Text Color"],
							desc = L["Change the color of the cooldown text."],
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
			desc = L["Configure which spells are shown."],
			cmdHidden = true,
			args = {}
		}
	}
}

do
	local t = BLT.options.args.cooldowns.args
	local i = 5 -- Sorting

	for k,_ in pairs(BLT.spells) do
		-- Separate class spells with a header
		t[k] = {
			type = "header",
			name = L[k],
			cmdHidden = true,
			order = i
		}
		i = i + 1

		-- Add an option entry for each spell
		for k2, v2 in pairs(BLT.spells[k]) do
			t[tostring(v2.id)] = {
				type = "toggle",
				name = k2,
				desc = L["Display %s cooldowns."]:format(k2),
				order = i,
				get = function()
					return BLT.db.profile.cooldowns[v2.id]
				end,
				set = function(_, value)
					BLT.db.profile.cooldowns[v2.id] = value
					BLT:SetOptions()
				end,
				cmdHidden = true
			}
			i = i + 1
		end
	end

	for k,_ in pairs(BLT.items) do
		t[k] = {
			type = "header",
			name = L[k],
			cmdHidden = true,
			order = i
		}
		i = i + 1

		-- Add an option entry for each item
		for k2, v2 in pairs(BLT.items[k]) do
			t[k2] = {
				type = "toggle",
				name = k2,
				desc = L["Display %s cooldowns."]:format(k2),
				order = i,
				get = function()
					return BLT.db.profile.cooldowns[v2.itemId]
				end,
				set = function(_, value)
					BLT.db.profile.cooldowns[v2.itemId] = value
					BLT:SetOptions()
				end,
				cmdHidden = true
			}
			i = i + 1
		end
	end
end
