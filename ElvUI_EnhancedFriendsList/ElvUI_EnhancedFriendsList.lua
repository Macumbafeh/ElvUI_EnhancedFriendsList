local E, L, V, P, G = unpack(ElvUI)
local EFL = E:NewModule("EnhancedFriendsList")
local EP = LibStub("LibElvUIPlugin-1.0")
local LSM = LibStub("LibSharedMedia-3.0", true)
local addonName = "ElvUI_EnhancedFriendsList"

local pairs, ipairs = pairs, ipairs
local format = format

local GetFriendInfo = GetFriendInfo
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumFriends = GetNumFriends
local LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_FEMALE
local LOCALIZED_CLASS_NAMES_MALE = LOCALIZED_CLASS_NAMES_MALE
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local LEVEL = LEVEL

local StatusIcons = {
	Default = {
		Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Default\\Online",
		Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Default\\Offline",
		DND	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Default\\DND",
		AFK	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Default\\AFK"
	},
	Square = {
		Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\Online",
		Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\Offline",
		DND	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\DND",
		AFK	= "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\Square\\AFK"
	},
	D3 = {
		Online = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\Online",
		Offline = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\Offline",
		DND = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\DND",
		AFK = "Interface\\AddOns\\ElvUI_EnhancedFriendsList\\Media\\Textures\\D3\\AFK"
	}
}

local Locale = GetLocale()

-- Profile
P["enhanceFriendsList"] = {
	-- General
	["showBackground"] = true,
	["showStatusIcon"] = true,
	["statusIcons"] = "Square",
	["hideLevelText"] = false,
	["hideNotesIcon"] = true,
	-- Online
	["enhancedName"] = true,
	["colorizeNameOnly"] = false,
	["enhancedZone"] = false,
	["enhancedZoneColor"] = {r = 1, g = 0.96, b = 0.45},
	["hideClass"] = true,
	["levelColor"] = false,
	["shortLevel"] = false,
	["sameZone"] = true,
	["sameZoneColor"] = {r = 0, g = 1, b = 0},
	-- Offline
	["offlineEnhancedName"] = false,
	["offlineColorizeNameOnly"] = true,
	["offlineHideClass"] = true,
	["offlineHideLevel"] = false,
	["offlineLevelColor"] = false,
	["offlineShortLevel"] = false,
	["offlineShowZone"] = false,
	["offlineShowLastSeen"] = true,
	-- Name Text Font
	["nameFont"] = "PT Sans Narrow",
	["nameFontSize"] = 12,
	["nameFontOutline"] = "NONE",
	-- Zone Text Font
	["zoneFont"] = "PT Sans Narrow",
	["zoneFontSize"] = 12,
	["zoneFontOutline"] = "NONE"
}

-- Options
local function ColorizeSettingName(settingName)
	return format("|cff1784d1%s|r", settingName)
end

function EFL:InsertOptions()
	E.Options.args.enhanceFriendsList = {
		order = 54,
		type = "group",
		name = ColorizeSettingName(L["Enhanced Friends List"]),
		get = function(info) return E.db.enhanceFriendsList[ info[#info] ] end,
		set = function(info, value) E.db.enhanceFriendsList[ info[#info] ] = value end,
		args = {
			header = {
				order = 1,
				type = "header",
				name = L["Enhanced Friends List"]
			},
			general = {
				order = 2,
				type = "group",
				name = L["General"],
				guiInline = true,
				args = {
					showBackground = {
						order = 1,
						type = "toggle",
						name = L["Show Background"],
						set = function(info, value) E.db.enhanceFriendsList.showBackground = value EFL:EnhanceFriends() end
					},
					showStatusIcon = {
						order = 2,
						type = "toggle",
						name = L["Show Status Icon"],
						set = function(info, value) E.db.enhanceFriendsList.showStatusIcon = value EFL:EnhanceFriends() end
					},
					statusIcons = {
						order = 3,
						type = "select",
						name = L["Status Icons Textures"],
						values = {
							["Default"] = "Default",
							["Square"] = "Square",
							["D3"] = "Diablo 3"
						},
						set = function(info, value) E.db.enhanceFriendsList.statusIcons = value EFL:EnhanceFriends() end
					},
					hideLevelText = {
						order = 4,
						type = "toggle",
						name = L["Hide Level or L Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideLevelText = value EFL:EnhanceFriends() end
					},
					hideNotesIcon = {
						order = 5,
						type = "toggle",
						name = L["Hide Note Icon"],
						set = function(info, value) E.db.enhanceFriendsList.hideNotesIcon = value EFL:EnhanceFriends() end
					}
				}
			},
			onlineFriends = {
				order = 3,
				type = "group",
				name = L["Online Friends"],
				guiInline = true,
				args = {
					enhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedName = value EFL:EnhanceFriends() end
					},
					colorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.colorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedName end
					},
					hideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.hideClass = value EFL:EnhanceFriends() end
					},
					enhancedZone = {
						order = 4,
						type = "toggle",
						name = L["Enhanced Zone"],
						set = function(info, value) E.db.enhanceFriendsList.enhancedZone = value EFL:EnhanceFriends() end
					},
					enhancedZoneColor = {
						order = 5,
						type = "color",
						name = L["Enhanced Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.enhancedZoneColor
							local d = P.enhanceFriendsList.enhancedZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.enhancedZoneColor
							t.r, t.g, t.b = r, g, b
							EFL:EnhanceFriends()
						end,
						disabled = function() return not E.db.enhanceFriendsList.enhancedZone end
					},
					levelColor = {
						order = 6,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.levelColor = value EFL:EnhanceFriends() end
					},
					sameZone = {
						order = 7,
						type = "toggle",
						name = L["Same Zone"],
						desc = L["Friends that are in the same area as you, have their zone info colorized green."],
						set = function(info, value) E.db.enhanceFriendsList.sameZone = value EFL:EnhanceFriends() end
					},
					sameZoneColor = {
						order = 8,
						type = "color",
						name = L["Same Zone Color"],
						get = function(info)
							local t = E.db.enhanceFriendsList.sameZoneColor
							local d = P.enhanceFriendsList.sameZoneColor
							return t.r, t.g, t.b, t.a, d.r, d.g, d.b
						end,
						set = function(info, r, g, b)
							local t = E.db.enhanceFriendsList.sameZoneColor
							t.r, t.g, t.b = r, g, b
							EFL:EnhanceFriends()
						end,
						disabled = function() return not E.db.enhanceFriendsList.sameZone end
					},
					shortLevel = {
						order = 9,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.shortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.hideLevelText end
					}
				}
			},
			offlineFriends = {
				order = 4,
				type = "group",
				name = L["Offline Friends"],
				guiInline = true,
				args = {
					offlineEnhancedName = {
						order = 1,
						type = "toggle",
						name = L["Enhanced Name"],
						set = function(info, value) E.db.enhanceFriendsList.offlineEnhancedName = value EFL:EnhanceFriends() end
					},
					offlineColorizeNameOnly = {
						order = 2,
						type = "toggle",
						name = L["Colorize Name Only"],
						set = function(info, value) E.db.enhanceFriendsList.offlineColorizeNameOnly = value EFL:EnhanceFriends() end,
						disabled = function() return not E.db.enhanceFriendsList.offlineEnhancedName end
					},
					offlineHideClass = {
						order = 3,
						type = "toggle",
						name = L["Hide Class Text"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideClass = value EFL:EnhanceFriends() end
					},
					offlineHideLevel = {
						order = 4,
						type = "toggle",
						name = L["Hide Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineHideLevel = value EFL:EnhanceFriends() end
					},
					offlineLevelColor = {
						order = 5,
						type = "toggle",
						name = L["Level Range Color"],
						set = function(info, value) E.db.enhanceFriendsList.offlineLevelColor = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShortLevel = {
						order = 6,
						type = "toggle",
						name = L["Short Level"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShortLevel = value EFL:EnhanceFriends() end,
						disabled = function() return E.db.enhanceFriendsList.hideLevelText or E.db.enhanceFriendsList.offlineHideLevel end
					},
					offlineShowZone = {
						order = 7,
						type = "toggle",
						name = L["Show Zone"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowZone = value EFL:EnhanceFriends() end
					},
					offlineShowLastSeen = {
						order = 8,
						type = "toggle",
						name = L["Show Last Seen"],
						set = function(info, value) E.db.enhanceFriendsList.offlineShowLastSeen = value EFL:EnhanceFriends() end
					}
				}
			},
			font = {
				order = 5,
				type = "group",
				name = L["Font"],
				guiInline = true,
				args = {
					nameFont = {
						order = 1,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Name Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.nameFont = value EFL:EnhanceFriends() end
					},
					nameFontSize = {
						order = 2,
						type = "range",
						name = L["Name Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.nameFontSize = value EFL:EnhanceFriends() end
					},
					nameFontOutline = {
						order = 3,
						type = "select",
						name = L["Name Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						set = function(info, value) E.db.enhanceFriendsList.nameFontOutline = value EFL:EnhanceFriends() end
					},
					zoneFont = {
						order = 4,
						type = "select", dialogControl = "LSM30_Font",
						name = L["Zone Font"],
						values = AceGUIWidgetLSMlists.font,
						set = function(info, value) E.db.enhanceFriendsList.zoneFont = value EFL:EnhanceFriends() end
					},
					zoneFontSize = {
						order = 5,
						type = "range",
						name = L["Zone Font Size"],
						min = 6, max = 22, step = 1,
						set = function(info, value) E.db.enhanceFriendsList.zoneFontSize = value EFL:EnhanceFriends() end
					},
					zoneFontOutline = {
						order = 6,
						type = "select",
						name = L["Zone Font Outline"],
						desc = L["Set the font outline."],
						values = {
							["NONE"] = NONE,
							["OUTLINE"] = "OUTLINE",
							["MONOCHROMEOUTLINE"] = "MONOCROMEOUTLINE",
							["THICKOUTLINE"] = "THICKOUTLINE"
						},
						set = function(info, value) E.db.enhanceFriendsList.zoneFontOutline = value EFL:EnhanceFriends() end
					}
				}
			}
		}
	}
end

local function ClassColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 255, 255, 255)
	else
		return format("|cFF%02x%02x%02x", color.r*255, color.g*255, color.b*255)
	end
end

local function OfflineColorCode(class)
	for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
		if class == v then
			class = k
		end
	end
	if Locale ~= "enUS" then
		for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
			if class == v then
				class = k
			end
		end
	end

	local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	if not color then
		return format("|cFF%02x%02x%02x", 160, 160, 160)
	else
		return format("|cFF%02x%02x%02x", color.r*160, color.g*160, color.b*160)
	end
end

local function timeDiff(t2, t1)
	if t2 < t1 then return end

	local d1, d2, carry, diff = date("*t", t1), date("*t", t2), false, {}
	local colMax = {60, 60, 24, date("*t", time{year = d1.year,month = d1.month + 1, day = 0}).day, 12}

	d2.hour = d2.hour - (d2.isdst and 1 or 0) + (d1.isdst and 1 or 0)
	for i, v in ipairs({"sec", "min", "hour", "day", "month", "year"}) do
		diff[v] = d2[v] - d1[v] + (carry and -1 or 0)
		carry = diff[v] < 0
		if carry then diff[v] = diff[v] + colMax[i] end
	end

	return diff
end

function EFL:EnhanceFriends()
	local db = E.db.enhanceFriendsList
	local numFriends = GetNumFriends()
	local friendOffset = FauxScrollFrame_GetOffset(FriendsFrameFriendsScrollFrame)
	local friendIndex
	local playerZone = GetRealZoneText()

	for i = 1, FRIENDS_TO_DISPLAY, 1 do
		friendIndex = friendOffset + i
		local name, level, class, area, connected, status, note, RAF = GetFriendInfo(friendIndex)

		if not name then return end

		local button = _G["FriendsFrameFriendButton"..i]
		local nameText = _G["FriendsFrameFriendButton"..i.."ButtonTextName"]
		local LocationText = _G["FriendsFrameFriendButton"..i.."ButtonTextLocation"]
		local infoText = _G["FriendsFrameFriendButton"..i.."ButtonTextInfo"]
		local noteFrame = _G["FriendsFrameFriendButton"..i.."ButtonTextNote"]
		local noteText = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteText"]
		local noteIcon = _G["FriendsFrameFriendButton"..i.."ButtonTextNoteIcon"]
		local buttonSummon = _G["FriendsFrameFriendButton"..i.."ButtonTextSummonButton"]

		local diff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 255, GetQuestDifficultyColor(level).g * 255, GetQuestDifficultyColor(level).b * 255) or "|cFFFFFFFF"
		local shortLevel = db.shortLevel and L["SHORT_LEVEL"] or LEVEL
		local offlineShortLevel = db.offlineShortLevel and L["SHORT_LEVEL"] or LEVEL

		if not button.background then
			button.background = button:CreateTexture(nil, "BACKGROUND")
			button.background:SetInside()
		end

		if db.showBackground then
			button.background:Show()
		else
			button.background:Hide()
		end

		if not button.statusIcon then
			button.statusIcon = button:CreateTexture(nil, "ARTWORK")
			button.statusIcon:Point("RIGHT", nameText, "LEFT", 1, -1)
		end

		nameText:ClearAllPoints()
		if db.showStatusIcon then
			if db.hideNotesIcon then
				noteFrame:Hide()
				nameText:Point("TOPLEFT", 15, -3)
			else
				noteFrame:Point("RIGHT", nameText, "LEFT", -3, -13)
				noteFrame:Show()
				nameText:Point("TOPLEFT", 15, -3)
			end

			button.statusIcon:Show()
		else
			button.statusIcon:Hide()

			if db.hideNotesIcon then
				noteFrame:Hide()
				nameText:Point("TOPLEFT", 3, -3)
			else
				nameText:Point("TOPLEFT", 10, -3)
				noteFrame:Point("RIGHT", nameText, "LEFT", 0, 0)
				noteFrame:Show()
			end
		end

		buttonSummon:Point("LEFT", 270, 1)

		LocationText:Hide()
		noteText:Hide()

		if connected then
			button.background:SetTexture(1, 0.80, 0.10, 0.10)

			button.statusIcon:SetTexture(StatusIcons[db.statusIcons][(status == CHAT_FLAG_DND and "DND" or status == CHAT_FLAG_AFK and "AFK" or "Online")])

			nameText:SetTextColor(1, 0.80, 0.10)

			if not ElvCharacterDB.EnhancedFriendsList_Data[name] then
				ElvCharacterDB.EnhancedFriendsList_Data[name] = {}
			end

			ElvCharacterDB.EnhancedFriendsList_Data[name].level = level
			ElvCharacterDB.EnhancedFriendsList_Data[name].class = class
			ElvCharacterDB.EnhancedFriendsList_Data[name].area = area
			ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen = format("%i", time())

			if db.enhancedName then
				if db.colorizeNameOnly then
					if db.hideClass then
						if db.levelColor then
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s|r|cffffffff - %s%s|r", ClassColorCode(class), name, diff, level)
							else
								nameText:SetFormattedText("%s%s|r|cffffffff - %s|r %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
							end
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s|r|cffffffff - %s|r", ClassColorCode(class), name, level)
							else
								nameText:SetFormattedText("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, shortLevel, level)
							end
						end
					else
						if db.levelColor then
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s|r|cffffffff - %s%s|r|cffffffff %s|r", ClassColorCode(class), name, diff, level, class)
							else
								nameText:SetFormattedText("%s%s|r|cffffffff - %s|r %s%s|r|cffffffff %s|r", ClassColorCode(class), name, shortLevel, diff, level, class)
							end
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s|r|cffffffff - %s %s|r", ClassColorCode(class), name, level, class)
							else
								nameText:SetFormattedText("%s%s|r|cffffffff - %s %s %s|r", ClassColorCode(class), name, shortLevel, level, class)
							end
						end
					end
				else
					if db.hideClass then
						if db.levelColor then
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s - %s%s|r", ClassColorCode(class), name, diff, level)
							else
								nameText:SetFormattedText("%s%s - %s %s%s|r", ClassColorCode(class), name, shortLevel, diff, level)
							end
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s - %s", ClassColorCode(class), name, level)
							else
								nameText:SetFormattedText("%s%s - %s %s", ClassColorCode(class), name, shortLevel, level)
							end
						end
					else
						if db.levelColor then
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s - %s%s|r %s%s", ClassColorCode(class), name, diff, level, ClassColorCode(class), class)
							else
								nameText:SetFormattedText("%s%s - %s %s%s|r %s%s", ClassColorCode(class), name, shortLevel, diff, level, ClassColorCode(class), class)
							end
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s%s - %s %s", ClassColorCode(class), name, level, class)
							else
								nameText:SetFormattedText("%s%s - %s %s %s", ClassColorCode(class), name, shortLevel, level, class)
							end
						end
					end
				end
			else
				if db.hideClass then
					if db.levelColor then
						if db.hideLevelText then
							nameText:SetFormattedText("%s, %s%s|r", name, diff, level)
						else
							nameText:SetFormattedText("%s, %s %s%s|r", name, shortLevel, diff, level)
						end
					else
						if db.hideLevelText then
							nameText:SetFormattedText("%s, %s", name, level)
						else
							nameText:SetFormattedText("%s, %s %s", name, shortLevel, level)
						end
					end
				else
					if db.levelColor then
						if db.hideLevelText then
							nameText:SetFormattedText("%s, %s%s|r %s", name, diff, level, class)
						else
							nameText:SetFormattedText("%s, %s %s%s|r %s", name, shortLevel, diff, level, class)
						end
					else
						if db.hideLevelText then
							nameText:SetFormattedText("%s, %s %s", name, level, class)
						else
							nameText:SetFormattedText("%s, %s %s %s", name, shortLevel, level, class)
						end
					end
				end
			end

			infoText:SetText(area)
		else
			button.background:SetTexture(0.5, 0.5, 0.5, 0.10)

			button.statusIcon:SetTexture(StatusIcons[db.statusIcons].Offline)

			nameText:SetTextColor(0.7, 0.7, 0.7)

			if ElvCharacterDB.EnhancedFriendsList_Data[name] then
				local lastSeen = ElvCharacterDB.EnhancedFriendsList_Data[name].lastSeen
				local td = timeDiff(time(), tonumber(lastSeen))
				level = ElvCharacterDB.EnhancedFriendsList_Data[name].level
				class = ElvCharacterDB.EnhancedFriendsList_Data[name].class
				area = ElvCharacterDB.EnhancedFriendsList_Data[name].area

				local offlineDiff = level ~= 0 and format("|cff%02x%02x%02x", GetQuestDifficultyColor(level).r * 160, GetQuestDifficultyColor(level).g * 160, GetQuestDifficultyColor(level).b * 160) or "|cFFAFAFAF|r"
				local offlineDiffColor
				if db.offlineEnhancedName then
					if db.offlineColorizeNameOnly then
						offlineDiffColor = db.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
					else
						offlineDiffColor = db.offlineLevelColor and offlineDiff or OfflineColorCode(class)
					end
				else
					offlineDiffColor = db.offlineLevelColor and offlineDiff or "|cFFAFAFAF|r"
				end

				if db.offlineEnhancedName then
					if db.offlineColorizeNameOnly then
						if db.offlineHideClass then
							if db.offlineHideLevel then
								nameText:SetFormattedText("%s%s", OfflineColorCode(class), name)
							else
								if db.hideLevelText then
									nameText:SetFormattedText("%s%s|r - %s%s", OfflineColorCode(class), name, offlineDiffColor, level)
								else
									nameText:SetFormattedText("%s%s|r - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
								end
							end
						else
							if db.offlineHideLevel then
								nameText:SetFormattedText("%s%s|r - %s", OfflineColorCode(class), name, class)
							else
								if db.hideLevelText then
									nameText:SetFormattedText("%s%s|r - %s%s|r %s", OfflineColorCode(class), name, offlineDiffColor, level, class)
								else
									nameText:SetFormattedText("%s%s|r - %s %s%s|r %s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, class)
								end
							end
						end
					else
						if db.offlineHideClass then
							if db.offlineHideLevel then
								nameText:SetFormattedText("%s%s", OfflineColorCode(class), name)
							else
								if db.hideLevelText then
									nameText:SetFormattedText("%s%s - %s%s", OfflineColorCode(class), name, offlineDiffColor, level)
								else
									nameText:SetFormattedText("%s%s - %s %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level)
								end
							end
						else
							if db.offlineHideLevel then
								nameText:SetFormattedText("%s%s - %s", OfflineColorCode(class), name, class)
							else
								if db.hideLevelText then
									nameText:SetFormattedText("%s%s - %s%s|r %s%s", OfflineColorCode(class), name, offlineDiffColor, level, OfflineColorCode(class), class)
								else
									nameText:SetFormattedText("%s%s - %s %s%s|r %s%s", OfflineColorCode(class), name, offlineShortLevel, offlineDiffColor, level, OfflineColorCode(class), class)
								end
							end
						end
					end
				else
					if db.offlineHideClass then
						if db.offlineHideLevel then
							nameText = name
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s - %s%s", name, offlineDiffColor, level)
							else
								nameText:SetFormattedText("%s - %s %s%s", name, offlineShortLevel, offlineDiffColor, level)
							end
						end
					else
						if db.offlineHideLevel then
							nameText:SetFormattedText("%s - %s", name, class)
						else
							if db.hideLevelText then
								nameText:SetFormattedText("%s - %s%s|r %s", name, offlineDiffColor, level, class)
							else
								nameText:SetFormattedText("%s - %s %s%s|r %s", name, offlineShortLevel, offlineDiffColor, level, class)
							end
						end
					end
				end

				if db.offlineShowZone then
					if db.offlineShowLastSeen then
						infoText:SetFormattedText("%s - %s %s", area, L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
					else
						infoText:SetText(area)
					end
				else
					if db.offlineShowLastSeen then
						infoText:SetFormattedText("%s %s", L["Last seen"], RecentTimeDate(td.year, td.month, td.day, td.hour))
					else
						infoText:SetText("")
					end
				end
			else
				nameText:SetText(name)

				if db.offlineShowZone then
					if db.offlineShowLastSeen then
						infoText:SetFormattedText("%s - %s", area, area)
					else
						infoText:SetText(area)
					end
				else
					if db.offlineShowLastSeen then
						infoText:SetText(area)
					else
						infoText:SetText("")
					end
				end
			end
		end

		if db.enhancedZone and connected then
			if db.sameZone then
				if area == playerZone then
					infoText:SetTextColor(db.sameZoneColor.r, db.sameZoneColor.g, db.sameZoneColor.b)
				else
					infoText:SetTextColor(db.enhancedZoneColor.r, db.enhancedZoneColor.g, db.enhancedZoneColor.b)
				end
			else
				infoText:SetTextColor(db.enhancedZoneColor.r, db.enhancedZoneColor.g, db.enhancedZoneColor.b)
			end
		else
			if db.sameZone and connected then
				if area == playerZone then
					infoText:SetTextColor(db.sameZoneColor.r, db.sameZoneColor.g, db.sameZoneColor.b)
				else
					infoText:SetTextColor(0.6, 0.6, 0.6)
				end
			else
				infoText:SetTextColor(0.6, 0.6, 0.6)
			end
		end

		nameText:SetFont(LSM:Fetch("font", db.nameFont), db.nameFontSize, db.nameFontOutline)
		infoText:SetFont(LSM:Fetch("font", db.zoneFont), db.zoneFontSize, db.zoneFontOutline)

		-- Tooltip
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 333, -35)
			GameTooltip:ClearLines()
			if connected then
				GameTooltip:AddLine(format("%s%s", ClassColorCode(class), name))
				GameTooltip:AddLine(format("%s %s %s", LEVEL, level, class))
				if db.sameZone and area == playerZone then
					GameTooltip:AddLine(area, db.sameZoneColor.r, db.sameZoneColor.g, db.sameZoneColor.b)
				else
					GameTooltip:AddLine(area, 0.75, 0.75, 0.75)
				end
			else
				GameTooltip:AddLine(name, 0.75, 0.75, 0.75)
			end

			if note then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(L["Notes"], 1, 1, 1)
				GameTooltip:AddLine(note, db.enhancedZoneColor.r, db.enhancedZoneColor.g, db.enhancedZoneColor.b)
			end
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
	end
end

function EFL:FriendListUpdate()
	if not ElvCharacterDB.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = {}
	end

	if E.global.EnhancedFriendsList_Data then
		ElvCharacterDB.EnhancedFriendsList_Data = E.global.EnhancedFriendsList_Data
		E.global.EnhancedFriendsList_Data = nil
	end

	hooksecurefunc("FriendsList_Update", EFL.EnhanceFriends)
	FriendsFrameFriendsScrollFrame:HookScript("OnVerticalScroll", function() EFL:EnhanceFriends() end)
end

function EFL:Initialize()
	EP:RegisterPlugin(addonName, EFL.InsertOptions)

	EFL:FriendListUpdate()
end

E:RegisterModule(EFL:GetName())