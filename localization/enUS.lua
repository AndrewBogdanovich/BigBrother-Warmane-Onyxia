local L = AceLibrary("AceLocale-2.2"):new("BigBrother")

L:RegisterTranslations("enUS", function() return {
	["Flask Check"] = true,
	["Checks for flasks, elixirs and food buffs."] = true,

	["Quick Check"] = true,
	["A quick report that shows who does not have flasks, elixirs or food."] = true,

	["Self"] = true,
	["Reports result only to yourself."] = true,

	["Party"] = true,
	["Reports result to your party."] = true,

	["Raid"] = true,
	["Reports result to your raid."] = true,

	["Guild"] = true,
	["Reports result to guild chat."] = true,

	["Officer"] = true,
	["Reports result to officer chat."] = true,

	["Whisper"] = true,
	["Reports result to the currently targeted individual."] = true,

	["Reports if and which player breaks crowd control effects (like polymorph, shackle undead, etc.) on enemies."] = true,

	["Misdirect"] = true,
	["Reports who gains misdirection."] = true,

	["BuffCheck"] = true,
	["Pops up a window to check various raid/elixir buffs (drag the bottom to resize)."] = true,

	["Settings"] = true,
	["Mod Settings"] = true,
	["Raid Groups"] = true,
	["Set which raid groups are checked for buffs"] = true,
	["Group 1"] = true,
	["Group 2"] = true,
	["Group 3"] = true,
	["Group 4"] = true,
	["Group 5"] = true,
	["Group 6"] = true,
	["Group 7"] = true,
	["Group 8"] = true,

	["Checks"] = true,
	["Set whether Flasks, Elixirs and Food are included in flaskcheck/quickcheck"] = true,
	["Flasks"] = true,
	["Elixirs"] = true,
	["Food Buffs"] = true,

	["No Flask"] = true,
	["No Flask or Elixir"] = true,
	["Only One Elixir"] = true,
	["Well Fed"] = true,
	["\"Well Fed\""] = true,
	["Enlightened"] = true,
	["Electrified"] = true,
	["No Food Buff"] = true,

	["%s cast %s on %s"] = true,
	["Polymorph/Misdirect Output"] = true,
	["Set where the polymorph/misdirect output is sent"] = true,
	["Polymorph"] = true,
	["Shackle"] = true,
	["Hibernate"] = true,
	["%s on %s removed by %s's %s"] = true,
	["%s on %s removed by %s"] = true,
	["CC on %s removed too frequently.  Throttling announcements."] = true,

	["Raid Buffs"] = true,
	["Paladin Buffs"] = true,
	["Consumables"] = true,
	["World Buffs"] = true,

	["Ready check auto-check"] = true,
	["Perform a quickcheck automatically on ready check"] = true,
	["Ready checks from self"] = true,
	["Ready checks from others"] = true,
	["Ready check Buff Window"] = true,
	["Open the Buff Window automatically on ready check"] = true,
	["Close Buff Window on Combat"] = true,
	["Close Buff Window when entering combat"] = true,
	["|cffff8040Left Click|r to toggle the buff window"] = true,
	["|cffff8040Right Click|r for menu"] = true,
	["Resurrection - Combat"] = true,
	["Reports when Combat Resurrection is performed."] = true,
	["Resurrection - Non-combat"] = true,
	["Reports when Non-combat Resurrection is performed."] = true,
	["Taunt"] = true,
	["Reports when players taunt mobs."] = true,
	["Interrupt"] = true,
	["Reports when players interrupt mob spell casts."] = true,
	["Events"] = true,
	["Events Output"] = true,
	["Set where the output for selected events is sent"] = true,
	["%s on %s removed"] = true,
	["%s taunted %s with %s"] = true,
	["%s aoe-taunted %s with %s"] = true,
	["%s taunt FAILED on %s (%s)"] = true,
	["%s interrupted %s casting %s"] = true,
	["Wintergrasp"] = true,
	["Custom"] = true,
	["Reports result to your custom channel."] = true,
	["Battleground"] = true,
	["Reports result to your battleground."] = true,
	["Custom Channel"] = true,
	["Name of custom channel to use for output"] = true,
	["No checks selected!"] = true,
	["No units in selected raid groups!"] = true,
	["Group Members Only"] = true,
	["Only reports events about players in my party/raid"] = true,

	-- Consumables
	["Flask of Supreme Power"] = true,
	["Shattrath Flask of Mighty Restoration"] = true,
	["Shattrath Flask of Fortification"] = true,
	["Shattrath Flask of Relentless Assault"] = true,
	["Shattrath Flask of Supreme Power"] = true,
	["Shattrath Flask of Pure Death"] = true,
	["Shattrath Flask of Blinding Light"] = true,

	-- Battle Elixirs
	["Fel Strength Elixir"] = true,
	["Onslaught Elixir"] = true,
	["Elixir of Major Strength"] = true,
	["Elixir of Major Agility"] = true,
	["Elixir of Mastery"] = true,
	["Elixir of Major Firepower"] = true,
	["Elixir of Major Shadow Power"] = true,
	["Elixir of Major Frost Power"] = true,
	["Elixir of Healing Power"] = true,
	["Elixir of the Mongoose"] = true,
	["Elixir of Greater Firepower"] = true,
	["Bloodberry Elixir"] = true,
	-- WotLK
	["Wrath Elixir"] = true,
	["Spellpower Elixir"] = true,
	["Guru's Elixir"] = true,
	["Elixir of Protection"] = true,
	["Elixir of Mighty Strength"] = true,
	["Elixir of Mighty Agility"] = true,
	["Elixir of Lightning Speed"] = true,
	["Elixir of Expertise"] = true,
	["Elixir of Deadly Strikes"] = true,
	["Elixir of Armor Piercing"] = true,
	["Elixir of Accuracy"] = true,

	-- Guardian Elixirs
	["Elixir of Major Defense"] = true,
	["Elixir of Superior Defense"] = true,
	["Elixir of Major Mageblood"] = true,
	["Mageblood Potion"] = true,
	["Elixir of Greater Intellect"] = true,
	["Elixir of Empowerment"] = true,
	-- WotLK
	["Elixir of Spirit"] = true,
	["Elixir of Mighty Thoughts"] = true,
	["Elixir of Mighty Mageblood"] = true,
	["Elixir of Mighty Fortitude"] = true,
	["Elixir of Mighty Defense"] = true,
} end)
