Scriptname ConstraintsPlayerScript extends ReferenceAlias

import Debug

; TODO
; - faction hate does nothing
; - pickpocket/steal from world - item remains in player inventory (duplicated)
; - stealing from containers - not detected
; - buy/sell - story quests "bought BLANK from BLANK"
; - burn in sunlight - not toggling properly
; - need-user-friendly messages
; - when player blocked from selling an item, need to claw back the gold they received
; - remember confidence of followers. 1=cautious 2=average 3=brave 4=foolhardy

ConstraintsMCMQuest property mcmOptions auto
ConstraintsStoryQuest_AddToPlayer property SQ_AddToPlayer auto
ConstraintsStoryQuest_RemoveFromPlayer property SQ_RemoveFromPlayer auto

Actor property player auto
Faction property playerFaction auto
Armor property inventoryToken auto		; fake item we put into inventory to force menu to refresh
Spell property spellToken auto			; likewise, for magic menu
MiscObject property goldBase auto

Spell property damageSpeech auto		; constant effect -100 debuffs for various skills
Spell property damageSmithing auto
Spell property damageAlchemy auto
Spell property damageEnchanting auto
Spell property sunDamageSpell auto
int property goldOverflow auto

Faction property factionStormcloaks auto
Faction property factionLegion auto
Faction property factionCompanions auto
Faction property factionThalmor auto
Faction property factionThievesGuild auto
Faction property factionVigilants auto
Faction property factionWinterholdCollege auto
Faction property factionDarkBrotherhood auto

Furniture lastFurniture = none			; used to remember furniture we interacted with in OnSit
int lastGoldAdded = 0
int MAX_FOLLOWERS = 100					; max number of followers whose confidence we will remember

; bool property noOneHanded auto
; bool property noTwoHanded auto
; bool property noEdged auto
; bool property noRanged auto
; bool property noShield auto
; bool property noLight auto
; bool property noHeavy auto
; bool property noSmith auto
; bool property noAlteration auto
; bool property noConjuration auto
; bool property noIllusion auto
; bool property noDestruction auto
; bool property noRestoration auto
; bool property noAlchemy auto
; bool property noEnchant auto

; bool property noSteal auto
; bool property noStealth auto
; bool property noLockpick auto
; bool property noSpeechcraft auto
; bool property noPickpocket auto
; bool property noBuy auto
; bool property noSell auto
; bool property noFollow auto
; bool property noShout auto
; bool property noTrain auto
; int property goldCap auto


Event OnInit()
	RegisterForMenu("Lockpicking Menu")
	RegisterForMenu("Crafting Menu")
	RegisterForMenu("BarterMenu")
	RegisterForMenu("Training Menu")
	RegisterForMenu("Journal Menu")					; the toplevel MCM/save/load/etc menu
	RegisterForKey(Input.GetMappedKey("Sneak"))
EndEvent


Event OnPlayerLoadGame()
	RegisterForMenu("Lockpicking Menu")
	RegisterForMenu("Crafting Menu")
	RegisterForMenu("BarterMenu")
	RegisterForMenu("Training Menu")
	RegisterForMenu("Journal Menu")					; the toplevel MCM/save/load/etc menu
	RegisterForKey(Input.GetMappedKey("Sneak"))
EndEvent


Event OnMenuClose(string menu)
	consoleutil.printmessage("Menu closed: " + menu)
	if menu == "Journal Menu"
		; Runs after MCM closes
		; Deal with immediate effects of any toggled options
		; if mcmOptions.noSmith
			; AddSpellOnce(player, damageSmithing)
		; else
			; player.DispelSpell(damageSmithing)
		; endif
		; if mcmOptions.noAlchemy
			; AddSpellOnce(player, damageAlchemy)
		; else
			; player.DispelSpell(damageAlchemy)
		; endif
		; if mcmOptions.noEnchant
			; AddSpellOnce(player, damageEnchanting)
		; else
			; player.DispelSpell(damageEnchanting)
		; endif
		if mcmOptions.noSpeechcraft
			AddSpellOnce(player, damageSpeech)
		else
			player.DispelSpell(damageSpeech)
		endif
		
		if mcmOptions.noStealth && player.IsSneaking()
			StopSneaking()
		endif
		if mcmOptions.noFollow
			MakeFollowersCowardly()
		else
			RestoreBraveFollowers()
		endif
		if mcmOptions.goldCap > 0
			StoreExcessGold()
		elseif goldOverflow > 0
			player.AddItem(goldBase, goldOverflow)
			goldOverflow = 0
		endif
		
		if mcmOptions.burnInSunlight
			AddSpellOnce(player, sunDamageSpell)
		else
			player.DispelSpell(sunDamageSpell)
		endif
		consoleutil.printmessage("burn=" + mcmOptions.burnInSunlight + " player.HasSpell()=" + player.hasSpell(sunDamageSpell))
		if mcmOptions.hateLegion != FactionHatesPlayer(factionLegion)
			factionLegion.SetPlayerEnemy(mcmOptions.hateLegion)
		endif
		if mcmOptions.hateStormcloaks != FactionHatesPlayer(factionStormcloaks)
			factionStormcloaks.SetPlayerEnemy(mcmOptions.hateStormcloaks)
		endif
		if mcmOptions.hateCompanions != FactionHatesPlayer(factionCompanions)
			factionCompanions.SetPlayerEnemy(mcmOptions.hateCompanions)
		endif
		if mcmOptions.hateThalmor != FactionHatesPlayer(factionThalmor)
			factionThalmor.SetPlayerEnemy(mcmOptions.hateThalmor)
		endif
		if mcmOptions.hateThievesGuild != FactionHatesPlayer(factionThievesGuild)
			factionThievesGuild.SetPlayerEnemy(mcmOptions.hateThievesGuild)
		endif
		if mcmOptions.hateDarkBrotherhood != FactionHatesPlayer(factionDarkBrotherhood)
			factionDarkBrotherhood.SetPlayerEnemy(mcmOptions.hateDarkBrotherhood)
		endif
		if mcmOptions.hateVigilants != FactionHatesPlayer(factionVigilants)
			factionVigilants.SetPlayerEnemy(mcmOptions.hateVigilants)
		endif
		if mcmOptions.hateWinterholdCollege != FactionHatesPlayer(factionWinterholdCollege)
			factionWinterholdCollege.SetPlayerEnemy(mcmOptions.hateWinterholdCollege)
		endif
		UnequipProhibitedItems()
		consoleutil.printmessage("1h " + mcmOptions.noOneHanded + ", 2h " + mcmOptions.noTwoHanded + ", bow " + mcmOptions.noRanged + ", shld " + mcmOptions.noShield + ", light " + mcmOptions.noLight + ", heavy " + mcmOptions.noHeavy)
		consoleutil.printmessage("alch " + mcmOptions.noAlchemy + ", ench " + mcmOptions.noEnchant + ", smith " + mcmOptions.noSmith + ", follow " + mcmOptions.noFollow)
		consoleutil.printmessage(", alt " + mcmOptions.noAlteration + ", conj " + mcmOptions.noConjuration + ", ill " + mcmOptions.noIllusion + ", dest " + mcmOptions.noDestruction + ", rest " + mcmOptions.noRestoration + ", shout " + mcmOptions.noShout)
		consoleutil.printmessage(", sneak " + mcmOptions.noStealth + ", steal " + mcmOptions.noSteal + ", pick " + mcmOptions.noPickpocket + ", lock " + mcmOptions.noLockpick + ", buy " + mcmOptions.noBuy + ", sell " + mcmOptions.noSell)
	endif
EndEvent


bool Function FactionHatesPlayer(Faction fac)
	return fac.GetReaction(playerFaction) == 1
EndFunction


Event OnMenuOpen(string menu)
	consoleutil.printmessage("Menu opened: " + menu)
	if mcmOptions.noLockpick && menu == "Lockpicking Menu"
		consoleutil.printmessage("player is picking a lock")
		ForceCloseMenu("Lockpicking Menu")
	
	elseif menu == "Crafting Menu" && lastFurniture
		consoleutil.printmessage("Opened crafting menu, lastfurniture = " + lastFurniture.GetName())
	
		if mcmOptions.noEnchant && (lastFurniture.HasKeywordString("isEnchanting") || lastFurniture.HasKeywordString("WICraftingEnchanting"))
			consoleutil.printmessage("player began enchanting")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		elseif mcmOptions.noAlchemy && (lastFurniture.HasKeywordString("isAlchemy") || lastFurniture.HasKeywordString("WICraftingAlchemy"))
			consoleutil.printmessage("player began alchemy")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		elseif mcmOptions.noSmith && IsSmithingStation(lastFurniture)
			consoleutil.printmessage("player began smithing")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		endif
	
	elseif mcmOptions.noTrain && menu == "Training Menu"
		consoleutil.printmessage("player began training")
		ForceCloseMenu("Training Menu")
	elseif (mcmOptions.noBuy && mcmOptions.noSell) && menu == "BarterMenu"
		consoleutil.printmessage("player began bartering")
		ForceCloseMenu("BarterMenu")
	endif
EndEvent


Event OnKeyDown(int keycode)
	if (keycode == Input.GetMappedKey("Sneak"))
		consoleutil.printmessage("sneak key pressed")
		if mcmOptions.noStealth
			StopSneaking()
		endif
	endif
EndEvent


Event OnCombatStateChanged (Actor target, int combatState)
	if mcmOptions.noFollow && combatState == 1
		consoleutil.printmessage("player entered combat")
		MakeFollowersCowardly()
	endif
EndEvent


Event OnObjectEquipped (Form base, ObjectReference ref)
	
	consoleutil.printmessage("player equipped item: " + base.GetName())
	if !PO3_SKSEFunctions.IsQuestItem(ref)
		if (base as Weapon) || (base as Armor) || (base as Ammo)
			if IsProhibitedItem(base)
				consoleutil.printmessage("player equipped a prohibited item: " + base.GetName())
				player.UnequipItem(base)
				ForceRefreshInventoryMenu()
			endif
		elseif base as Spell
			Spell sp = base as Spell
			consoleutil.printmessage("player equipped a spell: (" + GetSpellSchool(sp) + " school)  prohibiteditem=" + IsProhibitedItem(base))
			if IsProhibitedSchool(GetSpellSchool(sp))
				consoleutil.printmessage("spell school is prohibited")
				if player.GetEquippedSpell(0) == sp
					player.UnequipSpell(sp, 0)
				endif
				if player.GetEquippedSpell(1) == sp
					player.UnequipSpell(sp, 1)
				endif
				if player.GetEquippedSpell(2) == sp
					player.UnequipSpell(sp, 2)
				endif
				;ForceRefreshMagicMenu()
				ForceCloseMenu("MagicMenu")
			elseif mcmOptions.noShout && player.GetEquippedSpell(2) == sp
				consoleutil.printmessage("unequipping power")
				player.UnequipSpell(player.GetEquippedSpell(2), 2)
				;ForceRefreshMagicMenu()
				ForceCloseMenu("MagicMenu")
			endif
		elseif base as Shout
			Shout sh = base as Shout
			consoleutil.printmessage("player equipped a shout")
			if mcmOptions.noShout
				player.UnequipShout(sh)
				ForceRefreshMagicMenu()
			endif
		elseif base as Book
			consoleutil.printmessage("player equipped a book")
			if (base as Book).GetSpell()
				Spell sp = (base as Book).GetSpell()
				if IsProhibitedSchool(GetSpellSchool(sp))
					consoleutil.printmessage("player learning a spell from the school of " + GetSpellSchool(sp))
					; This event triggers AFTER we have learned the spell, so we always appear to know the spell
					player.AddItem(base, 1, true)
					player.RemoveSpell(sp)
				endif
			endif
		endif
	endif
EndEvent


; Various mods can cause significant delays between interacting with the crafting station, and the crafting menu opening.
; alternative is to record the station here, then do the rest in OnMenuOpen

Event OnSit (ObjectReference furnref)
	Form furn = furnref.GetBaseObject()
	lastFurniture = furn as Furniture
	consoleutil.printmessage("Last furniture set to: " + lastFurniture.GetName())
EndEvent


Event OnItemAdded (Form base, int count, ObjectReference itemref, ObjectReference source)
	consoleutil.printmessage("item added to player: " + base.GetName() + " x" +count+ " source=" + source.GetDisplayName())
	if base == goldBase
		lastGoldAdded = count
		StoreExcessGold()
	elseif PO3_SKSEFunctions.IsQuestItem(itemref)
		; ignore as it's a quest item
	elseif mcmOptions.noBuy && UI.IsMenuOpen("BarterMenu") 
		; not gold, so presumably we bought this item
		consoleutil.printmessage("player bought " + base.GetName() + " from someone (? " + source.GetDisplayName() + "), returning it")
		if itemref
			source.AddItem(itemref, count)
			player.RemoveItem(itemref, count)
		else
			source.AddItem(base, count)
			player.RemoveItem(base, count)
		endif
	else
		SQ_AddToPlayer.lastItemAddedCount = count
	endif
EndEvent


Event OnItemRemoved (Form base, int count, ObjectReference itemref, ObjectReference dest)
	consoleutil.printmessage("(item removed from player: " + base.GetName() + " x" + count + ", to " + dest.GetDisplayName())
	if PO3_SKSEFunctions.IsQuestItem(itemref)
		;
	elseif mcmOptions.noSell && base != goldBase && UI.IsMenuOpen("BarterMenu") 
		; we must have sold this item
		consoleutil.printmessage("player sold " + base.GetName() + " to someone (? " + dest.GetDisplayName() + "), returning it")
		if itemref
				player.AddItem(itemref, count)
				dest.RemoveItem(itemref, count)
			else
				player.AddItem(base, count)
				dest.RemoveItem(base, count)
			endif
	else
		SQ_RemoveFromPlayer.lastItemRemovedCount = count
	endif
EndEvent




Function AddSpellOnce(Actor who, Spell sp)
	if !who.HasSpell(sp)
		who.AddSpell(sp)
	else
		consoleutil.printmessage("Can't add spell " + sp.GetName() + ", already present")
	endif	
EndFunction


bool Function IsSmithingStation(Form furn)
	if furn.HasKeywordString("WICraftingSmithing") || furn.HasKeywordString("CraftingSmithingForge")
		return true
	elseif furn.HasKeywordString("CraftingTanningRack") || furn.HasKeywordString("isTanning")
		return true
	elseif furn.HasKeywordString("CraftingSmelter") || furn.HasKeywordString("isSmelter")
		return true
	elseif furn.HasKeywordString("CraftingSmithingArmorTable") || furn.HasKeywordString("isBlacksmithWorkbench")
		return true
	elseif furn.HasKeywordString("CraftingSmithingSharpeningWheel") 
		return true
	endif
	return false
EndFunction


Function StoreExcessGold()
	int goldAmount = player.GetGoldAmount()
	if mcmOptions.goldCap > 0 && goldAmount > mcmOptions.goldCap
		int excess = goldAmount - mcmOptions.goldCap
		consoleutil.printmessage("Removing " + excess + " excess gold...")
		player.RemoveItem(goldBase, excess)
		if !mcmOptions.destroyExcessGold
			goldOverflow += excess
		endif
	endif
EndFunction



string Function GetSpellSchool(Spell sp)
	MagicEffect mgef = sp.GetNthEffectMagicEffect(sp.GetCostliestEffectIndex())
	return mgef.GetAssociatedSkill()
EndFunction


bool Function IsProhibitedSchool(string school)
	if mcmOptions.noAlteration && school == "Alteration"
		return true
	elseif mcmOptions.noIllusion && school == "Illusion"
		return true
	elseif mcmOptions.noConjuration && school == "Conjuration"
		return true
	elseif mcmOptions.noDestruction && school == "Destruction"
		return true
	elseif mcmOptions.noRestoration && school == "Restoration"
		return true
	else
		return false
	endif
EndFunction


Function CloseAllMenus()
	Game.DisablePlayerControls()
	Utility.Wait(0.1)
	Game.EnablePlayerControls()
EndFunction


Function ForceCloseMenu(string menu)
	UI.InvokeString("HUD Menu", "_global.skse.CloseMenu", menu)
	;CloseAllMenus()
EndFunction


Function ForceRefreshInventoryMenu()
	player.AddItem(inventoryToken, 1, true)
	Utility.Wait(0.1)
	player.RemoveItem(inventoryToken, 1, true)
	;UI.invokeBool("HUD Menu", "_global.skyui.components.list.ListLayout.Refresh", true)
EndFunction


Function ForceRefreshMagicMenu()
	; player.AddSpell(spellToken,true)
	; Utility.Wait(0.1)
	; player.RemoveSpell(spellToken)
	UI.invokeBool("MagicMenu", "_global.skyui.components.list.ListLayout.Refresh", true)
	UI.invokeBool("HUD Menu", "_global.skyui.components.list.ListLayout.Refresh", true)
EndFunction


Function StopSneaking()
	if player.IsSneaking()
		notification("You may not sneak.")
		player.StartSneaking()		; actually TOGGLES sneaking
	endif
EndFunction


Function UnequipProhibitedItems()
	Form[] items = PO3_SKSEFunctions.AddAllEquippedItemsToArray(player)
	consoleutil.printmessage("Got list of " + items.Length + " equipped items")
	int index = 0
	while index < items.Length
		Form item = items[index]
		if IsProhibitedItem(item)
			consoleutil.printmessage("unequipped: " + item.GetName())
			player.UnequipItem(item, false, false)
		else
			consoleutil.printmessage("OK: " + item.GetName())
		endif
		index += 1
	endwhile
	
	; Need to do spells separately
	int hand = 0
	while hand < 3
		Spell sp = player.GetEquippedSpell(hand)
		if sp && IsProhibitedItem(sp)
			player.UnequipSpell(sp, hand)
		endif
		hand += 1
	endwhile
EndFunction


bool Function IsProhibitedItem(Form base)
	; first check materials
	if (base as Weapon) || (base as Ammo)
		if mcmOptions.noMaterialIron && base.HasKeywordString("WeapMaterialIron")
			return true
		elseif mcmOptions.noMaterialSteel && base.HasKeywordString("WeapMaterialSteel")
			return true
		elseif mcmOptions.noMaterialDaedric && base.HasKeyWordString("WeapMaterialDaedric")
			return true
		elseif mcmOptions.noMaterialLeather && base.HasKeyWordString("WeapMaterialLeather")
			return true
		elseif mcmOptions.noMaterialOrcish && base.HasKeyWordString("WeapMaterialOrcish")
			return true
		elseif mcmOptions.noMaterialDwarven && base.HasKeyWordString("WeapMaterialDwarven")
			return true
		elseif mcmOptions.noMaterialElven && base.HasKeyWordString("WeapMaterialElven")
			return true
		elseif mcmOptions.noMaterialGlass && base.HasKeyWordString("WeapMaterialGlass")
			return true
		elseif mcmOptions.noMaterialEbony && base.HasKeyWordString("WeapMaterialEbony")
			return true
		elseif mcmOptions.noMaterialHide && base.HasKeyWordString("WeapMaterialHide")
			return true
		elseif mcmOptions.noMaterialDragonscale && base.HasKeyWordString("WeapMaterialDragonscale")
			return true
		elseif mcmOptions.noMaterialDragonplate && base.HasKeyWordString("WeapMaterialDragonplate")
			return true
		elseif mcmOptions.noMaterialFalmer && base.HasKeyWordString("WeapMaterialFalmer")
			return true
		elseif mcmOptions.noMaterialSilver && base.HasKeyWordString("WeapMaterialSilver")
			return true
		elseif mcmOptions.noMaterialWood && base.HasKeyWordString("WeapMaterialWood")
			return true
		endif
	elseif (base as Armor) 
		if mcmOptions.noMaterialIron && base.HasKeywordString("ArmorMaterialIron")
			return true
		elseif mcmOptions.noMaterialSteel && base.HasKeywordString("ArmorMaterialSteel")
			return true
		elseif mcmOptions.noMaterialDaedric && base.HasKeyWordString("ArmorMaterialDaedric")
			return true
		elseif mcmOptions.noMaterialLeather && base.HasKeyWordString("ArmorMaterialLeather")
			return true
		elseif mcmOptions.noMaterialOrcish && base.HasKeyWordString("ArmorMaterialOrcish")
			return true
		elseif mcmOptions.noMaterialDwarven && base.HasKeyWordString("ArmorMaterialDwarven")
			return true
		elseif mcmOptions.noMaterialElven && base.HasKeyWordString("ArmorMaterialElven")
			return true
		elseif mcmOptions.noMaterialGlass && base.HasKeyWordString("ArmorMaterialGlass")
			return true
		elseif mcmOptions.noMaterialEbony && base.HasKeyWordString("ArmorMaterialEbony")
			return true
		elseif mcmOptions.noMaterialHide && base.HasKeyWordString("ArmorMaterialHide")
			return true
		elseif mcmOptions.noMaterialDragonscale && base.HasKeyWordString("ArmorMaterialDragonscale")
			return true
		elseif mcmOptions.noMaterialDragonplate && base.HasKeyWordString("ArmorMaterialDragonplate")
			return true
		elseif mcmOptions.noMaterialFalmer && base.HasKeyWordString("ArmorMaterialFalmer")
			return true
		elseif mcmOptions.noMaterialSilver && base.HasKeyWordString("ArmorMaterialSilver")
			return true
		elseif mcmOptions.noMaterialWood && base.HasKeyWordString("ArmorMaterialWood")
			return true
		endif
	endif
	
	if (base as Weapon) || (base as Ammo)
		Weapon wpn = base as Weapon
		if mcmOptions.noRanged && (base as Ammo || wpn.IsBow())
			return true
		elseif mcmOptions.noEdged && (wpn.IsBattleAxe() || wpn.IsGreatsword() || wpn.IsSword() || wpn.IsDagger() || wpn.IsWarAxe())
			return true
		elseif mcmOptions.noOneHanded && (wpn.IsSword() || wpn.IsMace() || wpn.IsDagger() || wpn.IsWarAxe())
			return true
		elseif mcmOptions.noTwoHanded && (wpn.IsWarHammer() || wpn.IsBattleAxe() || wpn.IsGreatsword() || wpn.IsStaff())
			return true
		endif
	elseif base as Armor
		Armor arm = base as Armor
		if mcmOptions.noLight && arm.IsLightArmor()
			return true
		elseif mcmOptions.noHeavy && arm.IsHeavyArmor()
			return true
		elseif mcmOptions.noShield && arm.IsShield()
			return true
		endif
	elseif base as Spell
		Spell sp = base as Spell
		if IsProhibitedSchool(GetSpellSchool(sp))
			return true
		elseif mcmOptions.noShout && player.GetEquippedSpell(2) == sp
			return true
		endif
	elseif mcmOptions.noShout && (base as Shout)
		return true
	elseif base as Book
		if (base as Book).GetSpell()
			Spell sp = (base as Book).GetSpell()
			if IsProhibitedSchool(GetSpellSchool(sp))
				return true
			endif
		endif
	endif
	return false
EndFunction


Function MakeFollowersCowardly()
	Actor[] followers = PO3_SKSEFunctions.GetPlayerFollowers()
	int index = followers.Length
	while index > 0
		index -= 1
		MakeFollowerCowardly(followers[index])
	endwhile	
EndFunction


Function MakeFollowerCowardly(Actor follower)
	int confidence = follower.GetActorValue("confidence") as int
	if confidence > 0
		consoleutil.printmessage("Cowardifying follower: " + follower.GetDisplayName())
		follower.SetActorValue("confidence", 0)
		mcmOptions.cowardlyFollowers.AddForm(follower)
		int index = mcmOptions.cowardlyFollowers.Find(follower)
		if index < MAX_FOLLOWERS
			mcmOptions.followerConfidence[index] = confidence
		endif
	endif
EndFunction


Function RestoreBraveFollowers()
	Actor follower
	int index = mcmOptions.cowardlyFollowers.GetSize()
	while index > 0
		index -= 1
		follower = mcmOptions.cowardlyFollowers.GetAt(index) as Actor
		int followerIndex = mcmOptions.cowardlyFollowers.Find(follower)
		int confidence 
		if followerIndex < MAX_FOLLOWERS
			confidence = mcmOptions.followerConfidence[followerIndex]
		endif
		consoleutil.printmessage("Restoring follower: " + follower.GetDisplayName())
		if followerIndex < 0
			consoleutil.printmessage("Error: could not find Actor " + follower + "in follower formlist, using default confidence of 2")
			confidence = 2
		endif
		follower.SetActorValue("confidence", confidence)
	endwhile
	mcmOptions.cowardlyFollowers.Revert()
EndFunction

