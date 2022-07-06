Scriptname ConstraintsPlayerScript extends ReferenceAlias

import Debug

; TODO
; - toggling hate OFF doesn't stop combat
; - test the gold bookkeeping on rejected transactions, steealing, pickpocketing

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
MagicEffect property burnInSunlightEffect auto
int property goldOverflow auto

Faction property factionStormcloaks auto
Faction property factionLegion auto
Faction property factionCompanions auto
Faction property factionThalmor auto
Faction property factionThievesGuild auto
Faction property factionVigilants auto
Faction property factionWinterholdCollege auto
Faction property factionDarkBrotherhood auto

Faction property EnemyOfStormcloaks auto
Faction property EnemyOfLegion auto
Faction property EnemyOfCompanions auto
Faction property EnemyOfThalmor auto
Faction property EnemyOfThievesGuild auto
Faction property EnemyOfVigilants auto
Faction property EnemyOfWinterholdCollege auto
Faction property EnemyOfDarkBrotherhood auto

; state
Furniture lastFurniture = none			; used to remember furniture we interacted with in OnSit
int lastGoldAdded = 0
int lastGoldRemoved = 0
int MAX_FOLLOWERS = 100					; max number of followers whose confidence we will remember
int startingBarterPlayerGold = 0
Form rejectedBarterItem = none
FormList property knownSpells auto
Form property lastItemAddedBase auto	; base form of the last non-gold item acquired by the player
Form property lastItemAddedOwner auto	; actorbase or faction that is the direct owner of last acquired item
int property lastItemAddedCount auto

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
	factionLegion.SetEnemy(EnemyOfLegion)
	factionStormcloaks.SetEnemy(EnemyOfStormcloaks)
	factionCompanions.SetEnemy(EnemyOfCompanions)
	factionThalmor.SetEnemy(EnemyOfThalmor)
	factionThievesGuild.SetEnemy(EnemyOfThievesGuild)
	factionDarkBrotherhood.SetEnemy(EnemyOfDarkBrotherhood)
	factionVigilants.SetEnemy(EnemyOfVigilants)
	factionWinterholdCollege.SetEnemy(EnemyOfWinterholdCollege)
	if mcmOptions.burnInSunlight
		RegisterForSingleUpdate(3.0)
	endif
EndEvent


Event OnPlayerLoadGame()
	RegisterForMenu("Lockpicking Menu")
	RegisterForMenu("Crafting Menu")
	RegisterForMenu("BarterMenu")
	RegisterForMenu("Training Menu")
	RegisterForMenu("Journal Menu")					; the toplevel MCM/save/load/etc menu
	RegisterForKey(Input.GetMappedKey("Sneak"))
	factionLegion.SetEnemy(EnemyOfLegion)
	factionStormcloaks.SetEnemy(EnemyOfStormcloaks)
	factionCompanions.SetEnemy(EnemyOfCompanions)
	factionThalmor.SetEnemy(EnemyOfThalmor)
	factionThievesGuild.SetEnemy(EnemyOfThievesGuild)
	factionDarkBrotherhood.SetEnemy(EnemyOfDarkBrotherhood)
	factionVigilants.SetEnemy(EnemyOfVigilants)
	factionWinterholdCollege.SetEnemy(EnemyOfWinterholdCollege)
	if mcmOptions.burnInSunlight
		RegisterForSingleUpdate(3.0)
	endif
EndEvent


Event OnUpdate()
	; runs every 3s
	if mcmOptions.burnInSunlight
		if !player.IsInInterior() && Game.GetSunPositionZ() > 0
			if !player.HasMagicEffect(burnInSunlightEffect)
				consoleutil.printmessage("Player does not have sun damage effect, recasting")
				player.RemoveSpell(sunDamageSpell)
				player.AddSpell(sunDamageSpell, false)
			else
				consoleutil.printmessage("Player has sun damage effect")
			endif
		elseif player.HasMagicEffect(burnInSunlightEffect)
			player.DispelSpell(sunDamageSpell)
			player.RemoveSpell(sunDamageSpell)
		endif
		RegisterForSingleUpdate(3.0)
	elseif player.HasMagicEffect(burnInSunlightEffect)
		player.DispelSpell(sunDamageSpell)
		player.RemoveSpell(sunDamageSpell)
	endif
EndEvent


Event OnMenuClose(string menu)
	if menu == "Journal Menu"
		; Runs after MCM closes
		; Deal with immediate effects of any toggled options
		
		if mcmOptions.noSpeechcraft
			AddSpellOnce(player, damageSpeech)
		else
			player.RemoveSpell(damageSpeech)
		endif
		
		if mcmOptions.noStealth && player.IsSneaking()
			StopSneaking()
		endif
		RegisterForKey(Input.GetMappedKey("Sneak"))
		
		UnequipProhibitedItems()

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
		
		if mcmOptions.noAlteration || mcmOptions.noConjuration || mcmOptions.noIllusion || mcmOptions.noDestruction || mcmOptions.noRestoration
			int spellIndex = player.GetSpellCount()
			knownSpells.Revert()
			while spellIndex > 0
				spellIndex -= 1
				knownSpells.AddForm(player.GetNthSpell(spellIndex))
			endwhile
		endif
		
		if mcmOptions.burnInSunlight
			player.RemoveSpell(sunDamageSpell)
			player.AddSpell(sunDamageSpell, false)
			RegisterForSingleUpdate(3.0)
		else
			player.DispelSpell(sunDamageSpell)
			player.RemoveSpell(sunDamageSpell)
		endif
		
		consoleutil.printmessage("burn=" + mcmOptions.burnInSunlight + " player.HasSpell()=" + player.hasSpell(sunDamageSpell))
		
		UpdateFactionRelation(factionLegion, mcmOptions.hateLegion, EnemyOfLegion)
		UpdateFactionRelation(factionStormcloaks, mcmOptions.hateStormcloaks, EnemyOfStormcloaks)
		UpdateFactionRelation(factionCompanions, mcmOptions.hateCompanions, EnemyOfCompanions)
		UpdateFactionRelation(factionThalmor, mcmOptions.hateThalmor, EnemyOfThalmor)
		UpdateFactionRelation(factionThievesGuild, mcmOptions.hateThievesGuild, EnemyOfThievesGuild)
		UpdateFactionRelation(factionDarkBrotherhood, mcmOptions.hateDarkBrotherhood, EnemyOfDarkBrotherhood)
		UpdateFactionRelation(factionVigilants, mcmOptions.hateVigilants, EnemyOfVigilants)
		UpdateFactionRelation(factionWinterholdCollege, mcmOptions.hateWinterholdCollege, EnemyOfWinterholdCollege)
	endif
EndEvent


Function UpdateFactionRelation(Faction fac, bool hateFaction, Faction enemyFaction)
	if hateFaction && !player.IsInFaction(enemyFaction)
		player.AddToFaction(enemyFaction)
		notification("Members of the " + fac.GetName() + " will now attack you on sight.")
	elseif !hateFaction && player.IsInFaction(enemyFaction)
		player.RemoveFromFaction(enemyFaction)
		StopCombatWithFaction(fac)
		notification("Members of the " + fac.GetName() + " will no longer attack you on sight.")
	endif
EndFunction


Function StopCombatWithFaction(Faction fac)
	Actor[] actors = PO3_SKSEFunctions.GetActorsByProcessingLevel(0)		; all actors in loaded cells
	int actorIndex = actors.Length
	while actorIndex > 0
		Actor npc = actors[actorIndex]
		if npc.IsInCombat() && npc.IsHostileToActor(player) && npc.IsInFaction(fac)
			consoleutil.printmessage(" > enemy " + npc.GetDisplayName() + "|" + npc.GetName()  + " id=" + npc.GetFormID() + " is in faction " + fac.GetName())
			consoleutil.printmessage("  > objref=" + (npc as ObjectReference))
			npc.StopCombat()
		endif
		actorIndex -= 1
	endwhile
EndFunction


Event OnMenuOpen(string menu)
	if mcmOptions.noLockpick && menu == "Lockpicking Menu"
		notification("You may not pick locks.")
		ForceCloseMenu("Lockpicking Menu")
	
	elseif lastFurniture && menu == "Crafting Menu" 
		if mcmOptions.noEnchant && (lastFurniture.HasKeywordString("isEnchanting") || lastFurniture.HasKeywordString("WICraftingEnchanting"))
			notification("You may not use enchanting stations.")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		elseif mcmOptions.noAlchemy && (lastFurniture.HasKeywordString("isAlchemy") || lastFurniture.HasKeywordString("WICraftingAlchemy"))
			notification("You may not use alchemy stations.")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		elseif mcmOptions.noSmith && IsSmithingStation(lastFurniture)
			notification("You may not use smithing stations.")
			ForceCloseMenu("Crafting Menu")
			player.moveto(player)
		endif
	
	elseif mcmOptions.noTrain && menu == "Training Menu"
		notification("You may not use skill trainers.")
		ForceCloseMenu("Training Menu")
	elseif menu == "BarterMenu"
		if (mcmOptions.noBuy && mcmOptions.noSell)
			notification("You may not buy or sell items.")
			ForceCloseMenu("BarterMenu")
		else
			startingBarterPlayerGold = player.GetGoldAmount()
			rejectedBarterItem = none
		endif
	endif
EndEvent


Event OnKeyDown(int keycode)
	if (keycode == Input.GetMappedKey("Sneak"))
		if mcmOptions.noStealth
			StopSneaking()
		endif
	endif
EndEvent


Event OnCombatStateChanged (Actor target, int combatState)
	if mcmOptions.noFollow && combatState == 1
		MakeFollowersCowardly()
	endif
EndEvent


Event OnObjectEquipped (Form base, ObjectReference ref)
	
	if !PO3_SKSEFunctions.IsQuestItem(ref)
		if (base as Weapon) || (base as Armor) || (base as Ammo)
			if IsProhibitedItem(base)
				consoleutil.printmessage("You may not equip that item.")
				player.UnequipItem(base)
				ForceRefreshInventoryMenu()
			endif
		elseif base as Spell
			Spell sp = base as Spell
			if IsProhibitedSchool(GetSpellSchool(sp))
				notification("You may not equip that spell.")
				if player.GetEquippedSpell(0) == sp
					player.UnequipSpell(sp, 0)
				endif
				if player.GetEquippedSpell(1) == sp
					player.UnequipSpell(sp, 1)
				endif
				if player.GetEquippedSpell(2) == sp
					player.UnequipSpell(sp, 2)
				endif
				ForceCloseMenu("MagicMenu")
			elseif mcmOptions.noShout && player.GetEquippedSpell(2) == sp
				notification("You may not equip powers.")
				player.UnequipSpell(player.GetEquippedSpell(2), 2)
				ForceCloseMenu("MagicMenu")
			endif
		elseif base as Shout
			Shout sh = base as Shout
			notification("You may not equip shouts.")
			if mcmOptions.noShout
				player.UnequipShout(sh)
				ForceCloseMenu("MagicMenu")
			endif
		elseif base as Book
			if (base as Book).GetSpell()
				Spell sp = (base as Book).GetSpell()
				if IsProhibitedSchool(GetSpellSchool(sp))
					notification("You may not learn spells from the school of " + GetSpellSchool(sp) + ".")
					; Return the spellbook to the player's inventory
					if !knownSpells.HasForm(sp)
						; we have newly learned the spell - we did not know it before. Return the book
						; and unlearn the spell.
						player.RemoveSpell(sp)
						player.AddItem(base, 1, true)
					else
						; we already knew the spell before noXSchool was turned on. Do not remove the spell.
					endif
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
EndEvent


Event OnItemAdded (Form base, int count, ObjectReference itemref, ObjectReference source)
	if base == goldBase
		lastGoldAdded = count
		lastItemAddedCount = count
		lastItemAddedBase = base
		lastItemAddedOwner = itemref.GetActorOwner()
		if !lastItemAddedOwner
			lastItemAddedOwner = itemref.GetFactionOwner()
		endif
		StoreExcessGold()
	elseif PO3_SKSEFunctions.IsQuestItem(itemref)
		; ignore as it's a quest item
	elseif UI.IsMenuOpen("BarterMenu") 
		if mcmOptions.noSell && rejectedBarterItem && ((itemref == rejectedBarterItem) || (base == rejectedBarterItem))
			; we tried to SELL this item and it has been returned to us because noSell is true
			consoleutil.printmessage("item " + base.GetName() + " could not be sold so was returned to player")
			rejectedBarterItem = none
		elseif mcmOptions.noBuy
			; we must have bought this item, so return it to source
			notification("You may not buy items.")
			if itemref
				source.AddItem(itemref, count)
				player.RemoveItem(itemref, count)
				rejectedBarterItem = itemref
			else
				source.AddItem(base, count)
				player.RemoveItem(base, count)
				rejectedBarterItem = base
			endif
		else
			; we bought something, which we are allowed to do.
			int inventoryGold = player.GetGoldAmount()
			consoleutil.printmessage("Player purchased " + base.GetName() + ", player inventory gold now " + inventoryGold)
			startingBarterPlayerGold = inventoryGold
			lastItemAddedCount = count
			lastItemAddedBase = base
			lastItemAddedOwner = itemref.GetActorOwner()
			if !lastItemAddedOwner
				lastItemAddedOwner = itemref.GetFactionOwner()
			endif
		endif
	else
		; picked up item, not gold. We can't remember its reference directly as it won't persist, so we have
		; to remember any important details.
		lastItemAddedCount = count
		lastItemAddedBase = base
		lastItemAddedOwner = itemref.GetActorOwner()
		if !lastItemAddedOwner
			lastItemAddedOwner = itemref.GetFactionOwner()
		endif
		consoleutil.printmessage("Item added to player: " + base.GetName() + " x" + count + ", source=" + source.GetDisplayName())
		consoleutil.printmessage(" > set lastItemAddedBase=" + lastItemAddedBase.GetName() + ", lastItemAddedOwner=" + lastItemAddedOwner.GetName())
	endif
EndEvent


Event OnItemRemoved (Form base, int count, ObjectReference itemref, ObjectReference dest)
	if PO3_SKSEFunctions.IsQuestItem(itemref)
		;
	elseif UI.IsMenuOpen("BarterMenu") 
		if base == goldBase
			lastGoldRemoved = count
		elseif mcmOptions.noBuy  && rejectedBarterItem && ((itemref == rejectedBarterItem) || (base == rejectedBarterItem))
			; the removed item is something we bought, but were not allowed to
			consoleutil.printmessage("item " + base.GetName() + " could not be purchased so was returned to vendor")
			rejectedBarterItem = none
			SQ_RemoveFromPlayer.lastItemRemovedCount = count
			if lastGoldRemoved > 0
				player.AddItem(goldBase, lastGoldRemoved)
				lastGoldRemoved = 0
				StoreExcessGold()
			endif
		elseif mcmOptions.noSell
			; we must have sold this item, but we are not allowed to
			consoleutil.printmessage("player sold " + base.GetName() + " to someone (? " + dest.GetDisplayName() + "), returning it")
			if itemref
				player.AddItem(itemref, count)
				dest.RemoveItem(itemref, count)
				rejectedBarterItem = itemref
			else
				player.AddItem(base, count)
				dest.RemoveItem(base, count)
				rejectedBarterItem = base
			endif
			RemoveGold(lastGoldAdded)
			lastGoldAdded = 0
		else
			SQ_RemoveFromPlayer.lastItemRemovedCount = count
		endif
	endif
EndEvent


Function AddSpellOnce(Actor who, Spell sp)
	if !who.HasSpell(sp)
		who.AddSpell(sp, false)
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


Function RemoveGold (int amount)
	int inventoryGold = player.GetGoldAmount()
	consoleutil.printmessage("Removing " + amount + " player gold (current inventory gold " +inventoryGold+ ", overflow "+goldOverflow+")")
	if amount > 0
		if !mcmOptions.goldCap || goldOverflow <= 0
			player.RemoveItem(goldBase, amount)
		elseif amount <= inventoryGold
			player.RemoveItem(goldBase, amount)
		else
			player.RemoveItem(goldBase, inventoryGold)
			goldOverflow -= (amount - inventoryGold)
			if goldOverflow < 0
				goldOverflow = 0
			endif
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
			player.UnequipItem(item, false, false)
		endif
		index += 1
	endwhile
	
	; Need to do spells separately
	; hand 0=right, 1=left, 2=neither (powers, shouts)
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


bool Function FactionHatesPlayer(Faction fac)
	return fac.GetReaction(playerFaction) == 1
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

