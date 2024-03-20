local BarHeight=20
local BarWidth=620
local TotalBuffs=30
local PlayersShown=8
local RowsCreated=8
local BuffSpacing=18

local BuffWindow_Functions={}

local BuffWindow_ResizeWindow, BuffWindow_UpdateWindow, BuffWindow_UpdateBuffs

local RL = AceLibrary("Roster-2.1")
local L = AceLibrary("AceLocale-2.2"):new("BigBrother")

local function spellData(spellID)
	local name,rank,icon = GetSpellInfo(spellID)
	return name, icon
end

--[[ Load up local tables from master spell ID tables ]]

local BigBrother_Flasks = {}
for i,v in ipairs(BigBrother_SpellData.flasks) do
	table.insert( BigBrother_Flasks, { spellData(v) } )
end

local BigBrother_Elixirs_Battle={}
for i,v in ipairs(BigBrother_SpellData.elixirBattle) do
	table.insert( BigBrother_Elixirs_Battle, { spellData(v) } )
end

local BigBrother_Elixirs_Guardian={}
for i,v in ipairs(BigBrother_SpellData.elixirGuardian) do
	table.insert( BigBrother_Elixirs_Guardian, { spellData(v) } )
end

local BigBrother_Foodbuffs={}
for i,v in ipairs(BigBrother_SpellData.foods) do
	table.insert(BigBrother_Foodbuffs,  { spellData(v) })
end
table.insert(BigBrother_Foodbuffs, { spellData(43763) }) -- Food

local function Sort_RaidBuffs(a,b)
	if a.totalBuffs<b.totalBuffs then
		return true
	elseif a.totalBuffs>b.totalBuffs then
		return false
	elseif a.name<b.name then
		return true
	end
	return false
end

local function Sort_PallyBuffs(a,b)
	if a.class<b.class then
		return true
	elseif a.class>b.class then
		return false
	elseif a.name<b.name then
		return true
	end
	return false
end

local BigBrother_BuffTable={
	{
		name=L["Raid Buffs"],
		buffs={
			{{spellData(1459)},{spellData(23028)},{spellData(61024)},{spellData(61316)}}, -- 1459 Arcane Intellect, 23028 Arcane Brilliance, 61024 Dalaran Intellect, 61316 Dalaran Brilliance
			{{spellData(1243)},{spellData(21562)},{spellData(69377)}}, -- 1243 Power Word: Fortitude, 21562 Prayer of Fortitude, 69377 Runescroll of Fortitude
			{{spellData(1126)},{spellData(21849)}}, -- 1126 Mark of the Wild, 21849 Gift of the Wild
			{{spellData(14752)},{spellData(27681)}}, -- 14752 Divine Spirit, 27681 Prayer of Spirit
			{{spellData(976)},{spellData(27683)}}, -- 976 Shadow Protection, 27683 Prayer of Shadow Protection

			{{spellData(20217)},{spellData(25898)},{spellData(69378)}}, -- 20217 Blessing of Kings, 25898 Greater Blessing of Kings, 69378 Blessing of Forgotten Kings	
			{{spellData(19740)},{spellData(25782)},{spellData(6673)}}, -- 19740 Blessing of Might, 25782 Greater Blessing of Might, 6673 Battle Shout
			{{spellData(19742)},{spellData(25894)},{spellData(5677)}}, -- 19742 Blessing of Wisdom, 25894 Greater Blessing of Wisdom, 5677 Mana Spring
			{{spellData(20911)},{spellData(25899)},{spellData(14893)}}, -- 20911 Blessing of Sanctuary, 25899 Greater Blessing of Sanctuary, 14893 Inspiration
			{{spellData(1038)},{spellData(25895)}}, -- 1038 Blessing of Salvation, 25899 Greater Blessing of Salvation

			BigBrother_Flasks,
			BigBrother_Elixirs_Battle,
			BigBrother_Elixirs_Battle,
			BigBrother_Elixirs_Battle,
			BigBrother_Elixirs_Battle,
			BigBrother_Elixirs_Guardian,
			BigBrother_Elixirs_Guardian,
			BigBrother_Elixirs_Guardian,
			BigBrother_Elixirs_Guardian,
      		BigBrother_Foodbuffs,

			{{spellData(15366)}}, -- 15366 Songflower Serenade
			{{spellData(16609)}}, -- 16609 Warchief's Blessing
			{{spellData(22888)}}, -- 16609 Rallying Cry of the Dragonslayer
			{{spellData(24425)}}, -- 24425 Spirit of Zandalar

			{{spellData(23768)}, -- 23768 Sayge's Dark Fortune of Damage(increase damage 10%)
				{spellData(23769)}, -- 23769 Sayge's Dark Fortune of Resistance(+25 all resistance)
				{spellData(23767)}, -- 23767 Sayge's Dark Fortune of Armor(increase armor 10%)
				{spellData(23766)}, -- 23766 Sayge's Dark Fortune of Intelligence(increase intelligence 10%)
				{spellData(23738)}, -- 23738 Sayge's Sayge's Dark Fortune of Spirit(increase spirit 10%)
				{spellData(23737)}, -- 23737 Sayge's Dark Fortune of Stamina(increase stamina 10%)
				{spellData(23735)}, -- 23735 Sayge's Dark Fortune of Strength(increase strength 10%)
				{spellData(23736)}, -- 23736 Sayge's Dark Fortune of Agility(increase agility 10%)
			},

			{{spellData(22818)}}, -- 22818 Mol'dar's Moxie
			{{spellData(22817)}}, -- 22817 Fengus' Ferocity
			{{spellData(22820)}}, -- 22820 Slip'kik's Savvy
			{{spellData(30178)}, -- 30178 Permanent R.O.I.D.S.
				{spellData(30173)}, -- 30173 Permanent Ground Scorpok Assay
				{spellData(30164)}, -- 30164 Permanent Lung Juice Cocktail
				{spellData(30175)}, -- 30175 Permanent Cerebral Cortex Compound
				{spellData(30177)}, -- 30177 Permanent Gizzard Gum
			},
			{{spellData(30336)}}, -- 30336 Permanent Spirit of Zanza
		}
	},
}

function BuffWindow_Functions:CreateBuffRow(parent, xoffset, yoffset)
	local Row=CreateFrame("FRAME",nil,parent)

	Row:SetPoint("TOPLEFT",parent,"TOPLEFT",xoffset,yoffset)
	Row:SetHeight(BarHeight)
	Row:SetWidth(BarWidth)
	Row:Show()

	Row.Background=Row:CreateTexture(nil,"BACKGROUND")
	Row.Background:SetAllPoints(Row)
	Row.Background:SetTexture("Interface\\Buttons\\WHITE8X8.blp")
	Row.Background:SetGradientAlpha("HORIZONTAL",1.0/2,0.0,0.0,0.8,1.0/2,0.0,0.0,0.0)
	Row.Background:Show()

	Row.Name=Row:CreateFontString(nil,"OVERLAY","GameFontNormal")	
	Row.Name:SetPoint("LEFT",Row,"LEFT",4,0)
	Row.Name:SetTextColor(1.0,1.0,1.0)
	Row.Name:SetText("Test")


	Row.Buff={}
	for i=1,TotalBuffs do
		Row.Buff[i]=CreateFrame("FRAME",nil,Row)		
		Row.Buff[i]:SetPoint("RIGHT",Row,"RIGHT",-4-(TotalBuffs-i)*BuffSpacing,0)
		Row.Buff[i]:SetHeight(16)
		Row.Buff[i]:SetWidth(16)

		Row.Buff[i].texture=Row.Buff[i]:CreateTexture(nil,"OVERLAY")
		Row.Buff[i].texture:SetAllPoints(Row.Buff[i])
		--Row.Buff[i].texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check.blp")

		Row.Buff[i].BuffName = nil
		--GameTooltip:ClearLines();GameTooltip:AddLine(this.BuffName);GameTooltip:Show()
		Row.Buff[i]:SetScript("OnEnter", BuffWindow_Functions.OnEnterBuff)
		Row.Buff[i]:SetScript("OnLeave", BuffWindow_Functions.OnLeaveBuff)
		Row.Buff[i]:EnableMouse()

		Row.Buff[i]:Show()
	end

	Row.SetPlayer=BuffWindow_Functions.SetPlayer
	Row.SetBuffValue=BuffWindow_Functions.SetBuffValue
	Row.SetBuffIcon=BuffWindow_Functions.SetBuffIcon
	Row.SetBuffName=BuffWindow_Functions.SetBuffName

	return Row
end

function BuffWindow_Functions:OnEnterBuff()
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT")
	GameTooltip:SetUnitBuff(self.unit, self.BuffName)
	GameTooltip:Show()
end

function BuffWindow_Functions:OnLeaveBuff()
	GameTooltip:Hide()
end


function BuffWindow_Functions:SetPlayer(player,class,unit)
	self.Name:SetText(player)
	local color=RAID_CLASS_COLORS[class]
	self.Background:SetGradientAlpha("HORIZONTAL",color.r/1.5,color.g/1.5,color.b/1.5,0.8,color.r/1.5,color.g/2,color.b/1.5,0)
end

function BuffWindow_Functions:SetBuffValue(num,enabled)
	if enabled then
		self.Buff[num]:Show()
	else
		self.Buff[num]:Hide()
	end
end

function BuffWindow_Functions:SetBuffIcon(num,texture)
	self.Buff[num].texture:SetTexture(texture)
end

function BuffWindow_Functions:SetBuffName(num,buffName,unit)
	self.Buff[num].BuffName=buffName
	self.Buff[num].unit=unit
end

function BigBrother:ToggleBuffWindow()
	if BigBrother_BuffWindow then
		if BigBrother_BuffWindow:IsShown() then
			BigBrother_BuffWindow:Hide()
			if self:IsEventRegistered("UNIT_AURA") then
				-- might already be unregistered if we standby with buffwin open
				self:UnregisterEvent("UNIT_AURA")
			end
		else
			BuffWindow_UpdateBuffs()
			BuffWindow_UpdateWindow()
			BigBrother_BuffWindow:Show()
			self:RegisterEvent("UNIT_AURA", "BuffUpdating")
		end
	else
		self:CreateBuffWindow()
	end
end

function BigBrother:CreateBuffWindow()
	local BuffWindow = CreateFrame("FRAME",nil,UIParent)

	BuffWindow:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
		edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
		tile = true, tileSize = 16, edgeSize = 16, 
		insets = { left = 4, right = 4, top = 4, bottom = 4 }});
	BuffWindow:SetBackdropColor(0,0,0,0.5);
	BuffWindow:SetWidth(BarWidth+16+24);
	BuffWindow:SetMovable(true)
	BuffWindow:SetClampedToScreen(true)
	BuffWindow:EnableMouse()
	
	BuffWindow:ClearAllPoints()
	if BigBrother.db.profile.BuffWindow_posX then
		BuffWindow:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT",
			BigBrother.db.profile.BuffWindow_posX,
			BigBrother.db.profile.BuffWindow_posY)	 
		BuffWindow:SetHeight(BigBrother.db.profile.BuffWindow_height);                           
	else
		BuffWindow:SetPoint("CENTER",UIParent)
		BuffWindow:SetHeight(190);     
	end

	BuffWindow:SetScript("OnMouseDown", function() 
		if ( ( ( not BigBrother_BuffWindow.isLocked ) or ( BigBrother_BuffWindow.isLocked == 0 ) ) and ( arg1 == "LeftButton" ) ) then
			BigBrother_BuffWindow:StartMoving();
			BigBrother_BuffWindow.isMoving = true;
		end
	end)
	BuffWindow:SetScript("OnMouseUp", function() 
		if ( BigBrother_BuffWindow.isMoving ) then
			BigBrother_BuffWindow:StopMovingOrSizing();
			BigBrother_BuffWindow.isMoving = false;
			BigBrother.db.profile.BuffWindow_posX = BigBrother_BuffWindow:GetLeft();
			BigBrother.db.profile.BuffWindow_posY = BigBrother_BuffWindow:GetTop();				  
		end
	end)

	BuffWindow:SetScript("OnHide", function() 
		if ( BigBrother_BuffWindow.isMoving ) then
			BigBrother_BuffWindow:StopMovingOrSizing();
			BigBrother_BuffWindow.isMoving = false;
		end
	end)
	
	BuffWindow:Show()

	BuffWindow.Title=BuffWindow:CreateFontString(nil,"OVERLAY","GameFontNormal")
	BuffWindow.Title:SetPoint("TOP",BuffWindow,"TOP",0,-8)
	BuffWindow.Title:SetTextColor(1.0,1.0,1.0)

	-- Refresh button
	BuffWindow.RefreshButton=CreateFrame("Button",nil,BuffWindow)
	BuffWindow.RefreshButton:SetNormalTexture("Interface\\Buttons\\UI-RotationRight-Button-Up.blp")
	BuffWindow.RefreshButton:SetPushedTexture("Interface\\Buttons\\UI-RotationRight-Button-Down.blp")
	BuffWindow.RefreshButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	BuffWindow.RefreshButton:SetWidth(20)
	BuffWindow.RefreshButton:SetHeight(20)
	BuffWindow.RefreshButton:SetPoint("TOPLEFT", BuffWindow,"TOPLEFT", 64,-5)
	BuffWindow.RefreshButton:SetScript("OnClick", function () BuffWindow_UpdateBuffs() BuffWindow_UpdateWindow() end)

	-- Close button
	BuffWindow.CloseButton=CreateFrame("Button",nil,BuffWindow)
	BuffWindow.CloseButton:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up.blp")
	BuffWindow.CloseButton:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down.blp")
	BuffWindow.CloseButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	BuffWindow.CloseButton:SetWidth(20)
	BuffWindow.CloseButton:SetHeight(20)
	BuffWindow.CloseButton:SetPoint("TOPRIGHT",BuffWindow,"TOPRIGHT",-4,-4)
	BuffWindow.CloseButton:SetScript("OnClick",function() BigBrother_BuffWindow:Hide();self:UnregisterEvent("UNIT_AURA") end)

	-- Ready check button
	BuffWindow.RCButton=CreateFrame("Button", nil, BuffWindow)
	BuffWindow.RCButton:SetNormalTexture("Interface\\RAIDFRAME\\ReadyCheck-Waiting")
	BuffWindow.RCButton:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight.blp")
	BuffWindow.RCButton:SetWidth(12)
	BuffWindow.RCButton:SetHeight(12)
	BuffWindow.RCButton:SetPoint("TOPLEFT", BuffWindow, "TOPLEFT", 8, -8)
	BuffWindow.RCButton:SetScript("OnClick",function() DoReadyCheck() end)

	BuffWindow.Rows={}
	for i=1,PlayersShown do
		BuffWindow.Rows[i]=BuffWindow_Functions:CreateBuffRow(BuffWindow,8,-4-i*(BuffSpacing+2))
	end

	RowsCreated=PlayersShown

	BuffWindow.ScrollBar=CreateFrame("SCROLLFRAME","BuffWindow_ScrollBar",BuffWindow,"FauxScrollFrameTemplate")
	BuffWindow.ScrollBar:SetScript("OnVerticalScroll", function(self, offset) FauxScrollFrame_OnVerticalScroll(self, offset, 20, BuffWindow_UpdateWindow) end)

	BuffWindow.ScrollBar:SetPoint("TOPLEFT", BuffWindow.Rows[1], "TOPLEFT", 0, 0)
	BuffWindow.ScrollBar:SetPoint("BOTTOMRIGHT", BuffWindow.Rows[8], "BOTTOMRIGHT", 0, 0)

	-- drag handle
	
	BuffWindow.draghandle = CreateFrame("Frame", nil, BuffWindow)
	BuffWindow.draghandle:Show()
	BuffWindow.draghandle:SetFrameLevel( BuffWindow:GetFrameLevel() + 10 ) -- place this above everything
	BuffWindow.draghandle:SetWidth(BarWidth+16+24)
	BuffWindow.draghandle:SetHeight(16)
	BuffWindow.draghandle:SetPoint("BOTTOM", BuffWindow, "BOTTOM", 0, 0)
	BuffWindow.draghandle:EnableMouse(true)
	BuffWindow.draghandle:SetScript("OnMouseDown", function() this:GetParent().isResizing = true; this:GetParent():StartSizing("BOTTOMRIGHT") end )
	BuffWindow.draghandle:SetScript("OnMouseUp", function() this:GetParent():StopMovingOrSizing(); this:GetParent().isResizing = false; end )
	
	BuffWindow:SetMinResize(BarWidth+16+24,110)
	BuffWindow:SetMaxResize(BarWidth+16+24,530.5)	
	BuffWindow:SetResizable(true);

	BuffWindow:SetScript("OnSizeChanged", function()
		if ( BigBrother_BuffWindow.isResizing ) then
			BuffWindow_ResizeWindow()
		end
	end)
    

	BigBrother_BuffWindow=BuffWindow
	BigBrother_BuffWindow.SelectedBuffs=1
	BuffWindow_UpdateBuffs()
	BuffWindow_ResizeWindow()
	self:RegisterEvent("UNIT_AURA", "BuffUpdating")
end

--When called will update buffs and the window
function BigBrother:BuffWindow_Update()
	BuffWindow_UpdateBuffs()
	BuffWindow_UpdateWindow()
end


local PlayerList={}
--When called will update the table of what buffs everyone has
function BuffWindow_UpdateBuffs()
	local unit
	local BuffChecking=BigBrother_BuffTable[BigBrother_BuffWindow.SelectedBuffs]
	local Filter=BuffChecking.filter
	local index = 1

	for unit in RL:IterateRoster(false) do
		if BigBrother.db.profile.Groups[unit.subgroup] then
			if (not Filter) or Filter[unit.class] then
				local player = PlayerList[index]

				if player==nil then
					player = {}
					PlayerList[index] = player
				end

				player.name=unit.name
				player.class=unit.class
				player.totalBuffs = 0
				if player.buff==nil then
					player.buff={}
				end
				player.unit=unit.unitid
				curIndex = 0
				for i, BuffList in pairs(BuffChecking.buffs) do
					local buffNotSet = true
					for _, buffs in pairs(BuffList) do
						if UnitBuff(unit.unitid, buffs[1]) then
							player.buff[i] = buffs
							player.totalBuffs = player.totalBuffs + 1
							buffNotSet = false
							break
						end
					end
					if buffNotSet then
						player.buff[i] = nil
					end
					curIndex = i
				end
				player.buff[curIndex+1] = nil
				
				index = index + 1
			end
		end
	end

	while PlayerList[index] do -- clear the rest of the table so we dont get nil holes that lead to ill-defined behavior in sort
		PlayerList[index] = nil
		index = index + 1
	end

	table.sort(PlayerList,BuffChecking.sortFunc)
	BigBrother_BuffWindow.List=PlayerList
end

function BuffWindow_UpdateWindow()
	local PlayerList=BigBrother_BuffWindow.List
	local Rows=BigBrother_BuffWindow.Rows
	local endOfList = false
	
	FauxScrollFrame_Update(BigBrother_BuffWindow.ScrollBar, table.getn(PlayerList), PlayersShown, 20)
	local offset = FauxScrollFrame_GetOffset(BigBrother_BuffWindow.ScrollBar)
	
	BigBrother_BuffWindow.Title:SetText(BigBrother_BuffTable[BigBrother_BuffWindow.SelectedBuffs].name)

	for i=1,PlayersShown do
		if not endOfList and PlayerList[i+offset] then
			local Player=PlayerList[i+offset]
			Rows[i]:SetPlayer(Player.name,Player.class,Player.unit)
			for j=1,30 do
				if Player.buff[j] then
					Rows[i]:SetBuffIcon(j,Player.buff[j][2])
					Rows[i]:SetBuffName(j,Player.buff[j][1], Player.unit)
					Rows[i]:SetBuffValue(j,true)
				else
					Rows[i]:SetBuffValue(j,false)
				end
			end
			Rows[i]:Show()
		else
			endOfList = true
			Rows[i]:Hide()
		end
	end
end

function BuffWindow_ResizeWindow()

	local NumVisibleRows=math.floor( (BigBrother_BuffWindow:GetHeight() - (BuffSpacing+4)-8) / (BuffSpacing+2) )

	if NumVisibleRows>RowsCreated then
		for i=(1+RowsCreated),NumVisibleRows do
			BigBrother_BuffWindow.Rows[i]=BuffWindow_Functions:CreateBuffRow(BigBrother_BuffWindow,8,-4-i*(BuffSpacing+2))
			BigBrother_BuffWindow.Rows[i]:Hide()
		end
		RowsCreated=NumVisibleRows
	end

	if NumVisibleRows<PlayersShown then
		for i=(1+NumVisibleRows),PlayersShown do
			BigBrother_BuffWindow.Rows[i]:Hide()
		end
	end
	PlayersShown=NumVisibleRows

	BigBrother_BuffWindow.ScrollBar:SetPoint("BOTTOMRIGHT", BigBrother_BuffWindow.Rows[PlayersShown], "BOTTOMRIGHT", 0, 0)
	BuffWindow_UpdateWindow()
	
	BigBrother.db.profile.BuffWindow_height = BigBrother_BuffWindow:GetHeight();
end

