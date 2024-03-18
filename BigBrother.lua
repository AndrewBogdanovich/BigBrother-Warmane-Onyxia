--[[
BigBrother
Concept and original mod: Cryect
Currently maintained by: oscarucb
Additional thanks:
    * All of the translators
    * Other wowace developers for assistance and bug fixes
    * Ahti and the other members of Cohors Praetoria (Vek'nilash US) for beta testing new versions of the mod
    * Thanks to vhaarr for helping Cryect out with reducing the length of code
    * Thanks to pastamancer for fixing the issues with Supreme Power Flasks and pointing in right direction for others
    * Window Resizing code based off the dragbar from violation
    * And also thanks to all those in #wowace for the various suggestions
]]
if AceLibrary:HasInstance("FuBarPlugin-2.0") then
	BigBrother = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0","FuBarPlugin-2.0")
else
	BigBrother = AceLibrary("AceAddon-2.0"):new("AceConsole-2.0","AceDB-2.0","AceEvent-2.0")
end

local addon = BigBrother

local AceEvent = AceLibrary("AceEvent-2.0")
local RL = AceLibrary("Roster-2.1")
local L = AceLibrary("AceLocale-2.2"):new("BigBrother")

local flasks = BigBrother_SpellData.flasks
local elixirs = BigBrother_SpellData.elixirs
local ccspells = BigBrother_SpellData.ccspells
local foods = BigBrother_SpellData.foods

local ccSpellNames = {}
-- Create a set out of the CC spell ID
for _, v in ipairs(ccspells) do
	local spellName = GetSpellInfo(v)
	ccSpellNames[spellName] = true
end

local brezSpellNames = {}
for _, v in ipairs(BigBrother_SpellData.brezSpells) do
	local spellName = GetSpellInfo(v)
	brezSpellNames[spellName] = true
end
local rezSpellNames = {}
for _, v in ipairs(BigBrother_SpellData.rezSpells) do
	local spellName = GetSpellInfo(v)
	if not brezSpellNames[spellName] then
  	rezSpellNames[spellName] = true  	
  end
end

local tauntSpellNames = {}
for _, v in ipairs(BigBrother_SpellData.tauntSpells) do
	local spellName = GetSpellInfo(v)
	tauntSpellNames[spellName] = true
end
local aoetauntSpellNames = {}
for _, v in ipairs(BigBrother_SpellData.aoetauntSpells) do
	local spellName = GetSpellInfo(v)
	aoetauntSpellNames[spellName] = true
end

local color = "|cffff8040%s|r"

-- FuBar stuff
addon.name = "BigBrother"
addon.hasIcon = true
addon.hasNoColor = true
addon.clickableTooltip = false
addon.independentProfile = true
addon.cannotDetachTooltip = true
addon.hideWithoutStandby = true

function addon:OnClick(button)
	self:ToggleBuffWindow()
end

function addon:OnTextUpdate()
	self:SetText("BigBrother")
  local f = addon.minimapFrame; 
  if f then -- ticket #14
    f.SetFrameStrata(f,"MEDIUM") -- ensure the minimap icon isnt covered by others 	
  end
end

-- AceDB stuff
addon:RegisterDB("BigBrotherDB")
addon:RegisterDefaults("profile", {
  PolyBreak = true,
  Misdirect = true,
  CombatRez = true,
  NonCombatRez = true,
  Groups = {true, true, true, true, true, true, true, true},
  PolyOut = {true, false, false, false, false, false, false},
  GroupOnly = true,
  ReadyCheckMine = true,
  ReadyCheckOther = true,
  ReadyCheckToSelf = true,  
  ReadyCheckToRaid = false,
  ReadyCheckBuffWinMine = false,
  ReadyCheckBuffWinOther = false,
  BuffWindowCombatClose = true,
  CheckFlasks = true,
  CheckElixirs = true,
  CheckFood = true,
  Taunt = false,
  Interrupt = false
})

-- ACE options menu
local options = {
  type = 'group',
  handler = BigBrother,
  args = {
    flaskcheck = {
      name = L["Flask Check"],
      desc = L["Checks for flasks, elixirs and food buffs."],
      type = 'group',
      args = {
        self = {
          name = L["Self"],
          desc = L["Reports result only to yourself."],
          type = 'execute',
          func = "FlaskCheck",
          passValue = "SELF",
        },
        party = {
          name = L["Party"],
          desc = L["Reports result to your party."],
          type = 'execute',
          func = "FlaskCheck",
          disabled = function() return GetNumPartyMembers()==0 end,
          passValue = "PARTY",
        },
        raid = {
          name = L["Raid"],
          desc = L["Reports result to your raid."],
          type = 'execute',
          func = "FlaskCheck",
          disabled = function() return GetNumRaidMembers()==0 end,
          passValue = "RAID",
        },
        guild = {
          name = L["Guild"],
          desc = L["Reports result to guild chat."],
          type = 'execute',
          func = "FlaskCheck",
          passValue = "GUILD",
        },
        officer = {
          name = L["Officer"],
          desc = L["Reports result to officer chat."],
          type = 'execute',
          func = "FlaskCheck",
          passValue = "OFFICER",
        },
        whisper = {
          name = L["Whisper"],
          desc = L["Reports result to the currently targeted individual."],
          type = 'execute',
          func = "FlaskCheck",
          passValue = "WHISPER",
        }
      }
    },
    quickcheck = {
      name = L["Quick Check"],
      desc = L["A quick report that shows who does not have flasks, elixirs or food."],
      type = 'group',
      args = {
        self = {
          name = L["Self"],
          desc = L["Reports result only to yourself."],
          type = 'execute',
          func = "QuickCheck",
          passValue = "SELF",
        },
        party = {
          name = L["Party"],
          desc = L["Reports result to your party."],
          type = 'execute',
          func = "QuickCheck",
          disabled = function() return GetNumPartyMembers()==0 end,
          passValue = "PARTY",
        },
        raid = {
          name = L["Raid"],
          desc = L["Reports result to your raid."],
          type = 'execute',
          func = "QuickCheck",
          disabled = function() return GetNumRaidMembers()==0 end,
          passValue = "RAID",
        },
        guild = {
          name = L["Guild"],
          desc = L["Reports result to guild chat."],
          type = 'execute',
          func = "QuickCheck",
          passValue = "GUILD",
        },
        officer = {
          name = L["Officer"],
          desc = L["Reports result to officer chat."],
          type = 'execute',
          func = "QuickCheck",
          passValue = "OFFICER",
        },
        whisper = {
          name = L["Whisper"],
          desc = L["Reports result to the currently targeted individual."],
          type = 'execute',
          func = "QuickCheck",
          passValue = "WHISPER",
        }
      }
    },
    settings = {
      name = L["Settings"],
      desc = L["Mod Settings"],
      type = 'group',
      args = {
     events = {
      name = L["Events"],
      desc = L["Events"],
      type = 'group',
      args = {   
        grouponly = {
          name  = L["Group Members Only"],
          desc = L["Only reports events about players in my party/raid"],
          type = 'toggle',
          get = function() return addon.db.profile.GroupOnly end,
          set = function(v)
            addon.db.profile.GroupOnly=v 
          end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },         
        polymorph = {
          name  = L["Polymorph"],
          desc = L["Reports if and which player breaks crowd control effects (like polymorph, shackle undead, etc.) on enemies."],
          type = 'toggle',
          get = function() return addon.db.profile.PolyBreak end,
          set = function(v)
            addon.db.profile.PolyBreak=v 
          end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },
        misdirect = {
          name  = L["Misdirect"],
          desc = L["Reports who gains misdirection."],
          type = 'toggle',
          get = function() return addon.db.profile.Misdirect end,
          set = function(v) addon.db.profile.Misdirect = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },
        taunt = {
          name  = L["Taunt"],
          desc = L["Reports when players taunt mobs."],
          type = 'toggle',
          get = function() return addon.db.profile.Taunt end,
          set = function(v) addon.db.profile.Taunt = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },        
        interrupt = {
          name  = L["Interrupt"],
          desc = L["Reports when players interrupt mob spell casts."],
          type = 'toggle',
          get = function() return addon.db.profile.Interrupt end,
          set = function(v) addon.db.profile.Interrupt = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },            
        brez = {
          name  = L["Resurrection - Combat"],
          desc = L["Reports when Combat Resurrection is performed."],
          type = 'toggle',
          get = function() return addon.db.profile.CombatRez end,
          set = function(v) addon.db.profile.CombatRez = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },      
        rez = {
          name  = L["Resurrection - Non-combat"],
          desc = L["Reports when Non-combat Resurrection is performed."],
          type = 'toggle',
          get = function() return addon.db.profile.NonCombatRez end,
          set = function(v) addon.db.profile.NonCombatRez = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },    
       }, }, -- end events        
       eventsoutput = {
          name = L["Events Output"],
          desc = L["Set where the output for selected events is sent"],
          type = 'group',
          args = {
            self = {
              name = L["Self"],
              desc = L["Reports result only to yourself."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[1] end,
              set = function(v) addon.db.profile.PolyOut[1] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            party = {
              name = L["Party"],
              desc = L["Reports result to your party."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[2] end,
              set = function(v) addon.db.profile.PolyOut[2] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            raid = {
              name = L["Raid"],
              desc = L["Reports result to your raid."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[3] end,
              set = function(v) addon.db.profile.PolyOut[3] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            guild = {
              name = L["Guild"],
              desc = L["Reports result to guild chat."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[4] end,
              set = function(v) addon.db.profile.PolyOut[4] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            officer = {
              name = L["Officer"],
              desc = L["Reports result to officer chat."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[5] end,
              set = function(v) addon.db.profile.PolyOut[5] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },             
            custom = {
              name = L["Custom"],
              desc = L["Reports result to your custom channel."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[6] end,
              set = function(v) addon.db.profile.PolyOut[6] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },           
            battleground = {
              name = L["Battleground"],
              desc = L["Reports result to your battleground."],
              type = 'toggle',
              get = function() return addon.db.profile.PolyOut[7] end,
              set = function(v) addon.db.profile.PolyOut[7] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },                        
          }
        },
        checks = {
          name = L["Checks"],
          desc = L["Set whether Flasks, Elixirs and Food are included in flaskcheck/quickcheck"],
          type = 'group',
          args = {
            flask = {
              name  = L["Flasks"],
              desc = L["Flasks"],
              type = 'toggle',
              get = function() return addon.db.profile.CheckFlasks end,
              set = function(v) addon.db.profile.CheckFlasks = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            elixir = {
              name  = L["Elixirs"],
              desc = L["Elixirs"],
              type = 'toggle',
              get = function() return addon.db.profile.CheckElixirs end,
              set = function(v) addon.db.profile.CheckElixirs = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            food = {
              name  = L["Food Buffs"],
              desc = L["Food Buffs"],
              type = 'toggle',
              get = function() return addon.db.profile.CheckFood end,
              set = function(v) addon.db.profile.CheckFood = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
          },
        },
        ready = {
          name = L["Ready check auto-check"],
          desc = L["Perform a quickcheck automatically on ready check"],
          type = 'group',
          args = {
            fromself = {
              name  = L["Ready checks from self"],
              desc = L["Ready checks from self"],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckMine end,
              set = function(v) addon.db.profile.ReadyCheckMine = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            fromother = {
              name  = L["Ready checks from others"],
              desc = L["Ready checks from others"],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckOther end,
              set = function(v) addon.db.profile.ReadyCheckOther = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            toraid = {
              name  = L["Reports result to your raid."],
              desc = L["Reports result to your raid."],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckToRaid end,
              set = function(v) addon.db.profile.ReadyCheckToRaid = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },            
            toself = {
              name  = L["Reports result only to yourself."],
              desc = L["Reports result only to yourself."],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckToSelf end,
              set = function(v) addon.db.profile.ReadyCheckToSelf = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },  
          },      
        },
        readywin = {
          name = L["Ready check Buff Window"],
          desc = L["Open the Buff Window automatically on ready check"],
          type = 'group',
          args = {
            fromself = {
              name  = L["Ready checks from self"],
              desc = L["Ready checks from self"],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckBuffWinMine end,
              set = function(v) addon.db.profile.ReadyCheckBuffWinMine = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            fromother = {
              name  = L["Ready checks from others"],
              desc = L["Ready checks from others"],
              type = 'toggle',
              get = function() return addon.db.profile.ReadyCheckBuffWinOther end,
              set = function(v) addon.db.profile.ReadyCheckBuffWinOther = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
          },
        },        
        combatbuffwin = {
          name  = L["Close Buff Window on Combat"],
          desc = L["Close Buff Window when entering combat"],
          type = 'toggle',
          get = function() return addon.db.profile.BuffWindowCombatClose end,
          set = function(v) addon.db.profile.BuffWindowCombatClose = v end,
          map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
        },      
        customchannel = {
          name  = L["Custom Channel"],
          desc = L["Name of custom channel to use for output"],
          type = 'text',
          usage = '',
          validate = function(v) return true end,
          get = function() return addon.db.profile.CustomChannel end,
          set = function(v) addon.db.profile.CustomChannel = v end,

        },            
        groups = {
          name = L["Raid Groups"],
          desc = L["Set which raid groups are checked for buffs"],
          type = 'group',
          args = {
            group1 = {
              name  = L["Group 1"],
              desc = L["Group 1"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[1] end,
              set = function(v) addon.db.profile.Groups[1] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group2 = {
              name  = L["Group 2"],
              desc = L["Group 2"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[2] end,
              set = function(v) addon.db.profile.Groups[2] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group3 = {
              name  = L["Group 3"],
              desc = L["Group 3"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[3] end,
              set = function(v) addon.db.profile.Groups[3] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group4 = {
              name  = L["Group 4"],
              desc = L["Group 4"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[4] end,
              set = function(v) addon.db.profile.Groups[4] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group5 = {
              name  = L["Group 5"],
              desc = L["Group 5"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[5] end,
              set = function(v) addon.db.profile.Groups[5] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group6 = {
              name  = L["Group 6"],
              desc = L["Group 6"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[6] end,
              set = function(v) addon.db.profile.Groups[6] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group7 = {
              name  = L["Group 7"],
              desc = L["Group 7"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[7] end,
              set = function(v) addon.db.profile.Groups[7] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
            group8 = {
              name  = L["Group 8"],
              desc = L["Group 8"],
              type = 'toggle',
              get = function() return addon.db.profile.Groups[8] end,
              set = function(v) addon.db.profile.Groups[8] = v end,
              map = { [false] = "|cffff4040Disabled|r", [true] = "|cff40ff40Enabled|r" }
            },
          }
        },
      }
    },
    buffcheck = {
      name = L["BuffCheck"],
      desc = L["Pops up a window to check various raid/elixir buffs (drag the bottom to resize)."],
      type = 'execute',
      func = function() BigBrother:ToggleBuffWindow() end,
    }
  }
}

addon.OnMenuRequest = options

function addon:OnInitialize()
  self:RegisterChatCommand("/bb", "/bigbrother", options, "BIGBROTHER")
end

local LDB
function addon:OnEnable()
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self:RegisterEvent("READY_CHECK")  
  self:RegisterEvent("PLAYER_REGEN_DISABLED")
  self:OnProfileEnable() 
  
  if LDB then
    return
  end
  if AceLibrary:HasInstance("LibDataBroker-1.1") then
    LDB = AceLibrary("LibDataBroker-1.1")
  elseif LibStub then
    LDB = LibStub:GetLibrary("LibDataBroker-1.1",true)
  end
  if LDB then
    LDB:NewDataObject("BigBrother", {
        type = "launcher",
        label = "BigBrother",
        icon = "Interface\\AddOns\\BigBrother\\icon",
        OnClick = function(self, button)
	        if button == "RightButton" then
	                BigBrother:OpenMenu(self)
	        else
	                BigBrother:ToggleBuffWindow()
	        end
        end,    
        OnTooltipShow = function(tooltip)
                if tooltip and tooltip.AddLine then
                        tooltip:SetText("BigBrother")
                        tooltip:AddLine(L["|cffff8040Left Click|r to toggle the buff window"])
                        tooltip:AddLine(L["|cffff8040Right Click|r for menu"])
                        tooltip:Show()
                end
        end,            
     })
    -- if AceLibrary:HasInstance("LibDBIcon-1.0") then
    --   AceLibrary("LibDBIcon-1.0"):Register("BigBrother", LDB, self.db.profile.minimap)
    -- end  
  end  
end

function addon:OnDisable()
  if BigBrother_BuffWindow and BigBrother_BuffWindow:IsShown() then
    BigBrother:ToggleBuffWindow()
  end
end

function addon:OnProfileDisable()
end

function addon:OnProfileEnable()
end

function addon:SpecialEvents_UnitBuffGained(unit, name, index, count, icon, rank)
    self:BuffUpdating()
end

function addon:SendMessageList(Pre,List,Where)
  if #List > 0 then
    if Where == "SELF" then
      self:Print(string.format(color, Pre..":") .. " " .. table.concat(List, ", "))
    elseif Where == "WHISPER" then
      local theTarget = UnitName("playertarget")
      if theTarget == nil then
         theTarget = UnitName("player")
      end
      SendChatMessage(Pre..": "..table.concat(List, ", "),Where,nil,theTarget)
    else
      SendChatMessage(Pre..": "..table.concat(List, ", "),Where)
    end
  end
end

function addon:HasBuff(player,MissingBuffList)
  for k, v in pairs(MissingBuffList) do
    if v==player then
      table.remove(MissingBuffList,k)
    end
  end
end

function addon:FlaskCheck(Where)
  self:ConsumableCheck(Where, true)
end

function addon:QuickCheck(Where)
  self:ConsumableCheck(Where, false)
end


function addon:ConsumableCheck(Where,Full)
  local numElixirs = 0
  local MissingFlaskList={}
  local MissingElixirList={}
  local MissingFoodList={}

  if not (self.db.profile.CheckFlasks or self.db.profile.CheckElixirs or self.db.profile.CheckFood) then
    self:Print(L["No checks selected!"])
    return
  end

	-- Fill up the food and flask lists with the raid roster names
	-- We wil remove those that are "ok" later
  for unit in RL:IterateRoster(false) do
    if self.db.profile.Groups[unit.subgroup] then
      table.insert(MissingFlaskList,unit.name)
      table.insert(MissingFoodList,unit.name)
    end
  end
  if #MissingFlaskList == 0 then
    self:Print(L["No units in selected raid groups!"])
    return
  end

  -- Print the flask list and determine who has no flask
  for i, v in ipairs(flasks) do
			local spellName = GetSpellInfo(v)
      local t = self:BuffPlayerList(spellName,MissingFlaskList)
      if Full and self.db.profile.CheckFlasks then
        self:SendMessageList(spellName, t, Where)
      end
  end    
  
  --use this to print out who has what elixir, and who has no elixirs
  if self.db.profile.CheckElixirs then
    for i, v in ipairs(elixirs) do
			local spellName = GetSpellInfo(v)
      local t = self:BuffPlayerList(spellName, MissingFlaskList)
      if Full then
        self:SendMessageList(spellName, t, Where)
      end
    end  
    
    --now figure out who has only one elixir
    for unit in RL:IterateRoster(false) do
      if self.db.profile.Groups[unit.subgroup] then
        numElixirs = 0
        for i, v in ipairs(elixirs) do
					local spellName = GetSpellInfo(v)
            if UnitBuff(unit.unitid, spellName) then
              numElixirs = numElixirs + 1
            end
        end
        if numElixirs == 1 then
            table.insert(MissingElixirList,unit.name)
        end
      end
    end

    self:SendMessageList(L["Only One Elixir"], MissingElixirList, Where)
    self:SendMessageList(L["No Flask or Elixir"], MissingFlaskList, Where)
  elseif self.db.profile.CheckFlasks then -- user wants flasks only, not elixers
    self:SendMessageList(L["No Flask"], MissingFlaskList, Where)  
  end
  
	--check for missing food
	if self.db.profile.CheckFood then
		for i, v in ipairs(foods) do
			local spellName = GetSpellInfo(v)
			local t = self:BuffPlayerList(spellName, MissingFoodList)
		end
		self:SendMessageList(L["No Food Buff"], MissingFoodList, Where)
	end  
end

function addon:BuffPlayerList(buffname,MissingBuffList)
  local list = {}
  for unit in RL:IterateRoster(false) do
    if UnitBuff(unit.unitid, buffname) then
      table.insert(list, unit.name)
      self:HasBuff(unit.name,MissingBuffList)
    end
  end
  return list
end

local iconlookup = {
  [COMBATLOG_OBJECT_RAIDTARGET1] = "{star}",
  [COMBATLOG_OBJECT_RAIDTARGET2] = "{circle}",
  [COMBATLOG_OBJECT_RAIDTARGET3] = "{diamond}",
  [COMBATLOG_OBJECT_RAIDTARGET4] = "{triangle}",
  [COMBATLOG_OBJECT_RAIDTARGET5] = "{moon}",
  [COMBATLOG_OBJECT_RAIDTARGET6] = "{square}",
  [COMBATLOG_OBJECT_RAIDTARGET7] = "{cross}",
  [COMBATLOG_OBJECT_RAIDTARGET8] = "{skull}",
  }
local iconmask = bit.bor(
	COMBATLOG_OBJECT_RAIDTARGET1, COMBATLOG_OBJECT_RAIDTARGET2, COMBATLOG_OBJECT_RAIDTARGET3, COMBATLOG_OBJECT_RAIDTARGET4,
	COMBATLOG_OBJECT_RAIDTARGET5, COMBATLOG_OBJECT_RAIDTARGET6, COMBATLOG_OBJECT_RAIDTARGET7, COMBATLOG_OBJECT_RAIDTARGET8
)

local function iconize(flags,chatoutput)
  local iconflag = bit.band(flags or 0, iconmask)
  
  if chatoutput then
    return (iconlookup[iconflag] or "")
  elseif iconflag then
    local check, iconidx = math.frexp(iconflag)
    iconidx = iconidx - 20
    if check == 0.5 and iconidx >= 1 and iconidx <= 8 then
      return "|Hicon:"..iconflag..":dest|h|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"..iconidx..".blp:0|t|h"  
    end
  end
  
  return ""
end

local function sendspam(spam,channels)
	if not spam then return end
	
  local it = select(2, IsInInstance())
  local inbattleground = (it == "pvp") 
  local inwintergrasp = (GetRealZoneText() == L["Wintergrasp"])
  local inarena = (it == "arena")

  -- BG reporting - never spam bg unless specifically requested, and dont spam anyone else
	if inbattleground then 
	  if channels[7] then 
	    SendChatMessage(spam, "BATTLEGROUND")
	  end
	  return	  
	elseif inwintergrasp then
    if channels[7] then 
	    SendChatMessage(spam, "RAID")
	  end	
	  return	  
	elseif inarena then
	  if channels[2] or channels[7] then
	    SendChatMessage(spam, "PARTY")
	  end
	  return
  end	
    
  -- raid/party reporting
	if GetNumRaidMembers() ~= 0 and channels[3] then
	  SendChatMessage(spam, "RAID")
	elseif GetNumPartyMembers() ~= 0 and channels[2] then
	  SendChatMessage(spam, "PARTY")	
	end
	
	-- guild reporting - dont spam both channels
	if IsInGuild() and channels[4] then
	  SendChatMessage(spam, "GUILD")	
	elseif IsInGuild() and channels[5] then
	  SendChatMessage(spam, "OFFICER")	
	end
	
	-- custom reporting
	if channels[6] and addon.db.profile.CustomChannel then
	  local chanid = GetChannelName(addon.db.profile.CustomChannel)
	  if chanid then
      SendChatMessage(spam, "CHANNEL", nil, chanid)	  
	  end
	end
end

function addon:PLAYER_REGEN_DISABLED()
  if addon.db.profile.BuffWindowCombatClose then
    if BigBrother_BuffWindow and BigBrother_BuffWindow:IsShown() then
      BigBrother:ToggleBuffWindow()
    end  
  end
end

function addon:READY_CHECK(sender)
  local doquickcheck = false
  local dowindisplay = false
  
  if addon.IsDisabled(addon) then
    return
  end
          
  if UnitIsUnit(sender, "player") then
    if addon.db.profile.ReadyCheckMine then doquickcheck = true end
    if addon.db.profile.ReadyCheckBuffWinMine then dowindisplay = true end  
  else     
    if addon.db.profile.ReadyCheckOther then doquickcheck = true end           
    if addon.db.profile.ReadyCheckBuffWinOther then dowindisplay = true end  
  end
  
  if dowindisplay then
    if not BigBrother_BuffWindow or not BigBrother_BuffWindow:IsShown() then
      BigBrother:ToggleBuffWindow()
    end
  end    
  
  if doquickcheck then
    if addon.db.profile.ReadyCheckToRaid then
      if GetNumRaidMembers() > 0 then
          addon:ConsumableCheck("RAID")
      elseif GetNumPartyMembers() > 0 then
          addon:ConsumableCheck("PARTY")                
      end
    elseif addon.db.profile.ReadyCheckToSelf then
      addon:ConsumableCheck("SELF")         
    end
  end    
end

function addon:COMBAT_LOG_EVENT_UNFILTERED(timestamp, subevent, srcGUID, srcname, srcflags, dstGUID, dstname, dstflags, spellID, spellname, spellschool, extraspellID, extraspellname, extraspellschool, auratype)  
  local is_playersrc = bit.band(srcflags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) > 0
  local is_playerdst = bit.band(dstflags or 0, COMBATLOG_OBJECT_TYPE_PLAYER) > 0  
  -- print((spellname or "nil")..":"..(spellID or "nil")..":"..(subevent or "nil")..":"..(srcname or "nil")..":"..(dstname or "nil")..":"..(dstGUID or "nil")..":"..(dstflags or "nil")..":".."is_playersrc:"..((is_playersrc and "true") or "false"))
  if self.db.profile.GroupOnly and 
     bit.band(srcflags or 0, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0 and
     bit.band(dstflags or 0, COMBATLOG_OBJECT_AFFILIATION_OUTSIDER) > 0 then
     -- print("skipped event from "..(srcname or "nil").." on "..(dstname or "nil"))
    return
	elseif self.db.profile.PolyBreak and is_playersrc
	  and (subevent == "SPELL_AURA_BROKEN" or subevent == "SPELL_AURA_BROKEN_SPELL" or subevent == "SPELL_AURA_REMOVED")
	  and ccSpellNames[spellname] then

		local throttleResetTime = 15;
		local now = GetTime();

		-- Reset the spam throttling cache if it isn't initialized or
		-- if it's been more than 15 seconds since any CC broke
		if (nil == self.spamCache or (nil ~= self.spamCacheLastTimeMax and now - self.spamCacheLastTimeMax > throttleResetTime)) then
			self.spamCache = {};
			self.spamCacheLastTimeMax = nil;
		end

		local output, spam
		local srcspam = iconize(srcflags,true)..srcname
		local srcout = iconize(srcflags,false)..srcname
		local dstspam = iconize(dstflags,true)..dstname
		local dstout = iconize(dstflags,false)..dstname
		
		if subevent == "SPELL_AURA_BROKEN" then
				spam = (L["%s on %s removed by %s"]):format(GetSpellLink(spellID), dstspam, srcspam)
				output = (L["%s on %s removed by %s"]):format(GetSpellLink(spellID), dstout, srcout)
		elseif subevent == "SPELL_AURA_BROKEN_SPELL" then
				spam = (L["%s on %s removed by %s's %s"]):format(GetSpellLink(spellID), dstspam, srcspam, GetSpellLink(extraspellID))
				output = (L["%s on %s removed by %s's %s"]):format(GetSpellLink(spellID), dstout, srcout, GetSpellLink(extraspellID))
		elseif subevent == "SPELL_AURA_REMOVED" and (spellID == 51514) then -- hex does not get a AURA_BROKEN event because it doesnt break on first damage
				spam = (L["%s on %s removed"]):format(GetSpellLink(spellID), dstspam)
				output = (L["%s on %s removed"]):format(GetSpellLink(spellID), dstout)
		end

		-- Should we throttle the spam?
		if self.spamCache[dstGUID] and now - self.spamCache[dstGUID]["lasttime"] < throttleResetTime then
			-- If we've been broken 3 or more times without a 15 second reprieve, then
			-- supress the spam
			if (self.spamCache[dstGUID]["count"] > 3) then
				spam = nil;
				output = nil;
			end

			-- Increment the cache entry
			self.spamCache[dstGUID]["count"] = self.spamCache[dstGUID]["count"] + 1;
			self.spamCache[dstGUID]["lasttime"] = now;
		else
			-- Reset the cache entry
			self.spamCache[dstGUID] = {["count"] = 1, ["lasttime"] = now};
		end
		self.spamCacheLastTimeMax = now;

		if output and self.db.profile.PolyOut[1] then
			self:Print(output)
		end

		if spam then
			sendspam(spam,addon.db.profile.PolyOut)
		end
	elseif self.db.profile.Misdirect and is_playersrc and subevent == "SPELL_CAST_SUCCESS" and (spellID == 34477 or spellID == 57934) then
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s cast %s on %s"]:format("|cff40ff40"..srcname.."|r", GetSpellLink(spellID), "|cffff4040"..dstname.."|r"))
		end
		sendspam(L["%s cast %s on %s"]:format(srcname, GetSpellLink(spellID), dstname),addon.db.profile.PolyOut)
	elseif self.db.profile.CombatRez and is_playersrc and (subevent == "SPELL_RESURRECT" or subevent == "SPELL_CAST_SUCCESS") and brezSpellNames[spellname] then
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s cast %s on %s"]:format("|cff40ff40"..srcname.."|r", GetSpellLink(spellID), "|cffff4040"..dstname.."|r"))
		end
		sendspam(L["%s cast %s on %s"]:format(srcname, GetSpellLink(spellID), dstname),addon.db.profile.PolyOut)		
	elseif self.db.profile.NonCombatRez and is_playersrc and subevent == "SPELL_RESURRECT" and rezSpellNames[spellname] then
		-- would like to report at spell cast start, but unfortunately the SPELL_CAST_SUCCESS combat log event for all rezzes has a nil target
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s cast %s on %s"]:format("|cff40ff40"..srcname.."|r", GetSpellLink(spellID), "|cffff4040"..dstname.."|r"))
		end
		sendspam(L["%s cast %s on %s"]:format(srcname, GetSpellLink(spellID), dstname),addon.db.profile.PolyOut)		
	elseif self.db.profile.Taunt and is_playersrc and not is_playerdst and subevent == "SPELL_CAST_SUCCESS" and tauntSpellNames[spellname] then
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s taunted %s with %s"]:format("|cff40ff40"..srcname.."|r", iconize(dstflags,false).."|cffff4040"..dstname.."|r", GetSpellLink(spellID)))
		end
		sendspam(L["%s taunted %s with %s"]:format(srcname, iconize(dstflags,true)..dstname, GetSpellLink(spellID)),addon.db.profile.PolyOut)
	elseif self.db.profile.Taunt and is_playersrc and not is_playerdst and subevent == "SPELL_AURA_APPLIED" and aoetauntSpellNames[spellname] then
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s aoe-taunted %s with %s"]:format("|cff40ff40"..srcname.."|r", iconize(dstflags,false).."|cffff4040"..dstname.."|r", GetSpellLink(spellID)))
		end
		sendspam(L["%s aoe-taunted %s with %s"]:format(srcname, iconize(dstflags,true)..dstname, GetSpellLink(spellID)),addon.db.profile.PolyOut)
	elseif self.db.profile.Taunt and is_playersrc and not is_playerdst and subevent == "SPELL_MISSED" and (tauntSpellNames[spellname] or aoetauntSpellNames[spellname]) 
	  and not (spellID == 49576 and extraspellID == "IMMUNE") then -- ignore immunity messages from death grip caused by mobs immune to the movement component
    local missType = extraspellID
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s taunt FAILED on %s (%s)"]:format("|cff40ff40"..srcname.."|r", iconize(dstflags,false).."|cffff4040"..dstname.."|r", missType))
		end
		sendspam(L["%s taunt FAILED on %s (%s)"]:format(srcname, iconize(dstflags,true)..dstname, missType),addon.db.profile.PolyOut)
	elseif self.db.profile.Interrupt and is_playersrc and subevent == "SPELL_INTERRUPT" then
		if self.db.profile.PolyOut[1] then
			self:Print(L["%s interrupted %s casting %s"]:format("|cff40ff40"..srcname.."|r", iconize(dstflags,false).."|cffff4040"..dstname.."|r", GetSpellLink(extraspellID)))
		end
		sendspam(L["%s interrupted %s casting %s"]:format(srcname, iconize(dstflags,true)..dstname, GetSpellLink(extraspellID)),addon.db.profile.PolyOut)
  end
end

local BuffWindow_Update_Inprogress = false
local BuffWindow_Update_LastUpdate = 0
function addon:BuffWindow_Update_Throttled() 
  BigBrother.BuffWindow_Update()
  BuffWindow_Update_Inprogress = false
end

function addon:BuffUpdating(info)
  if BigBrother_BuffWindow and BigBrother_BuffWindow:IsShown() then
    -- self:ScheduleEvent(BigBrother.BuffWindow_Update,0.25)
    local now =  GetTime()
    local interval = now - BuffWindow_Update_LastUpdate
    if (interval > 0.5) and                 -- throttle to half-second max queing frequency
       (not BuffWindow_Update_Inprogress or -- nothing queued, or
        interval > 5) then               -- scheduled event got lost for over 5 sec
      BuffWindow_Update_Inprogress = true
      BuffWindow_Update_LastUpdate = now
      self:ScheduleEvent(BigBrother.BuffWindow_Update_Throttled,0.25)
    end
  end
end

