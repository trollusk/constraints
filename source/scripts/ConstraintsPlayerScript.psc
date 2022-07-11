Scriptname ConstraintsPlayerScript extends ReferenceAlias

import Debug

; script attached to player alias

; TODO staff.GetEnchantment(), ench.GetCostliestEffectIndex(), ench.GetNthEffectMagicEffect(), keyword
; or wpn.GetSkill() ?
; TODO book with text starting <font face='$MageScriptFont'> or DwemerFont DragonFont FalmerFont

ConstraintsMCMQuest property mcmOptions auto
ConstraintsStoryQuest_AddToPlayer property SQ_AddToPlayer auto
ConstraintsTargetScript property targetscript auto

Actor property player auto
Faction property playerFaction auto
Armor property inventoryToken auto		; fake item we put into inventory to force menu to refresh
Spell property spellToken auto			; likewise, for magic menu
MiscObject property goldBase auto
ObjectReference property illegibleBook auto

Spell property damageSpeech auto		; constant effect -100 debuffs for various skills
Spell property damageSmithing auto
Spell property damageAlchemy auto
Spell property damageEnchanting auto
Spell property sunDamageSpell auto
MagicEffect property burnInSunlightEffect auto
Perk property noPickpocketPerk auto

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
int MAX_FOLLOWERS = 100					; max number of followers whose confidence we will remember
string[] skillNames
FormList property knownSpells auto
Form property lastItemAddedBase auto	; base form of the last non-gold item acquired by the player
Form property lastItemAddedOwner auto	; actorbase or faction that is the direct owner of last acquired item
int property lastItemAddedCount auto
int property goldOverflow auto
ReferenceAlias property targetRef auto


Event OnInit()
	InitSkillNames()
	RegisterForMenu("Lockpicking Menu")
	RegisterForMenu("Crafting Menu")
	RegisterForMenu("BarterMenu")
	RegisterForMenu("Training Menu")
	RegisterForMenu("Journal Menu")					; the toplevel MCM/save/load/etc menu
	RegisterForMenu("MapMenu")	
	RegisterForMenu("Book Menu")	
	RegisterForKey(Input.GetMappedKey("Sneak"))
    targetscript.InitScript()
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


; OnPlayerLoadGame events can only be received by player/player alias

Event OnPlayerLoadGame()
	InitSkillNames()
	RegisterForMenu("Lockpicking Menu")
	RegisterForMenu("Crafting Menu")
	RegisterForMenu("BarterMenu")
	RegisterForMenu("Training Menu")
	RegisterForMenu("Journal Menu")					; the toplevel MCM/save/load/etc menu
	RegisterForMenu("MapMenu")
	RegisterForMenu("Book Menu")	
	RegisterForKey(Input.GetMappedKey("Sneak"))
    targetscript.InitScript()
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
				;consoleutil.printmessage("Player does not have sun damage effect, recasting")
				player.RemoveSpell(sunDamageSpell)
				player.AddSpell(sunDamageSpell, false)
			else
				;consoleutil.printmessage("Player has sun damage effect")
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


Function UnnameAllBooks()
    Form[] books = PO3_SKSEFunctions.GetAllForms(27)
    int index = 0
    while index < books.Length
        books[index].SetName("?????")
        index += 1
    endwhile
EndFunction


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
		
		if mcmOptions.noPickpocket && !player.HasPerk(noPickpocketPerk)
			player.AddPerk(noPickpocketPerk)
		elseif !mcmOptions.noPickpocket && player.HasPerk(noPickpocketPerk)
			player.RemovePerk(noPickpocketPerk)
		endif

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
		endif
	elseif mcmOptions.noMap && menu == "MapMenu"
		ForceCloseMenu("MapMenu")
		notification("You may not look at the map.")
	elseif mcmOptions.noReading && menu == "Book Menu"
        ForceCloseMenu("Book Menu")
        notification("You cannot read.")
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
				notification("You may not equip that item.")
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
			elseif mcmOptions.noPower && player.GetEquippedSpell(2) == sp
				notification("You may not equip powers.")
				player.UnequipSpell(player.GetEquippedSpell(2), 2)
				ForceCloseMenu("MagicMenu")
			endif
		elseif base as Shout
			Shout sh = base as Shout
			if mcmOptions.noShout
    			notification("You may not equip shouts.")
				player.UnequipShout(sh)
				ForceCloseMenu("MagicMenu")
			endif
		elseif base as Book
			Book bk = Base as book
			if bk.GetSpell()
				Spell sp = bk.GetSpell()
				if mcmOptions.noReading || IsProhibitedSchool(GetSpellSchool(sp))
					if mcmOptions.noReading
						notification("You cannot read.")
					else
						notification("You may not learn spells from the school of " + GetSpellSchool(sp) + ".")
					endif
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
			elseif mcmOptions.noReading 
                notification("You cannot read.")
                if ref
				    player.UnequipItem(ref)
                else
                    player.UnequipItem(base)
                endif
                ForceCloseMenu("Book Menu")
                ForceRefreshInventoryMenu()
			endif
		elseif base as Scroll
			if mcmOptions.noReading
				notification("You cannot read.")
				player.UnequipItem(base)
				ForceRefreshInventoryMenu()
			elseif IsProhibitedSchool(GetScrollSchool(base as Scroll))
				notification("You may not cast spells from the school of " + GetScrollSchool(base as Scroll) + ".")
				player.UnequipItem(base)
				ForceRefreshInventoryMenu()
			endif
		endif
	endif
EndEvent


Event OnSit (ObjectReference furnref)
	Form furn = furnref.GetBaseObject()
	lastFurniture = furn as Furniture
EndEvent

; if nosell, cant remove items 
; if nobuy, cant remove gold

; if nosell, cant add gold
; if nobuy, cant add items 

Event OnItemAdded (Form base, int count, ObjectReference itemref, ObjectReference source)
	; player picks up item or takes it from container
	; gold: player paid for completing a quest
	; player stole item from world or container
	; player pickpocketed item
	; gold: player stole gold
	; gold: player pickpocketed gold
	; in bartermenu:
	;   player bought this item (noBuy = false)
	;   gold: player has been paid for sold item (noSell = false)
	;   gold: player bought item but was not allowed to, so gold is being refunded to player (noBuy = true)
	;   player sold item but not allowed to so it is being returned to player (noSell = true)

	if PO3_SKSEFunctions.IsQuestItem(itemref)
		return
	endif
	
	if base == inventoryToken
		return
	endif

	if UI.IsMenuOpen("BarterMenu") 
		if mcmOptions.noBuy && !mcmOptions.noSell
			if base != goldBase
				Notification("You may not buy items.")
				if itemref
					source.AddItem(itemref, count)
					player.RemoveItem(itemref, count)
				else
					source.AddItem(base, count)
					player.RemoveItem(base, count)
				endif
			endif
		elseif mcmOptions.noSell && !mcmOptions.noBuy
			if base == goldBase
				source.AddItem(goldBase, count)
				RemoveGold(count)
			endif
		endif
	endif
	
	if (mcmOptions.weightCap > 0) && (player.GetTotalItemWeight() > mcmOptions.weightCap)
		; At this point, GetTotalItemWeight includes worn + carried items, and includes the
		; item we just picked up
		if itemref
			notification("You drop the " + itemref.GetDisplayName() + ", since it is too heavy for you to carry.")
			player.DropObject(itemref, count)
		else
			notification("You drop the " + base.GetName() + ", since it is too heavy for you to carry.")
			player.DropObject(base, count)
		endif
	endif

	if base == goldBase
		StoreExcessGold()
	endif
EndEvent


Event OnItemRemoved (Form base, int count, ObjectReference itemref, ObjectReference dest)
	; player drops item or stores it in container
	; player consumes item
	; player gives item to someone
	; gold: player bribes guard, etc
	; in bartermenu:
	;   player sells item
	;   gold: player pays for purchased item
	;   gold: player sold item but was not allowed to, so gold is being removed and refunded to vendor
	;   player bought item but not allowed to so it is being returned to vendor
	if PO3_SKSEFunctions.IsQuestItem(itemref)
		return
	endif

	if base == inventoryToken
		return
	endif

	if UI.IsMenuOpen("BarterMenu") 
		if mcmOptions.noBuy && !mcmOptions.noSell
			if base == goldBase
				player.AddItem(goldBase, count)
				dest.RemoveItem(goldBase, count)
			endif
		elseif mcmOptions.noSell && !mcmOptions.noBuy
			if base != goldBase
				Notification("You may not sell items.")
				if itemref
					player.AddItem(itemref, count)
					dest.RemoveItem(itemref, count)
				else
					player.AddItem(base, count)
					dest.RemoveItem(base, count)
				endif
			endif
		endif
	endif
	
	if base == goldBase
		StoreExcessGold()
	endif
EndEvent


Function AddSpellOnce(Actor who, Spell sp)
	if !who.HasSpell(sp)
		who.AddSpell(sp, false)
	else
		;consoleutil.printmessage("Can't add spell " + sp.GetName() + ", already present")
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
		notification("Removing " + excess + " excess gold...")
		player.RemoveItem(goldBase, excess)
		if !mcmOptions.destroyExcessGold
			goldOverflow += excess
		endif
	endif
EndFunction


Function RemoveGold (int amount)
	int inventoryGold = player.GetGoldAmount()
	;consoleutil.printmessage("Removing " + amount + " player gold (current inventory gold " +inventoryGold+ ", overflow "+goldOverflow+")")
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


string Function GetEnchantmentSchool(Enchantment ench)
	MagicEffect mgef = ench.GetNthEffectMagicEffect(ench.GetCostliestEffectIndex())
	return mgef.GetAssociatedSkill()
EndFunction


string Function GetScrollSchool(Scroll scr)
	MagicEffect mgef = scr.GetNthEffectMagicEffect(scr.GetCostliestEffectIndex())
	return mgef.GetAssociatedSkill()
EndFunction


; Return the enchantment that is cast when the staff is wielded and used by the player.

Enchantment Function GetStaffEnchantment(Weapon staff)
	if staff.IsStaff()
		Enchantment ench = staff.GetEnchantment()
		if PO3_SKSEFunctions.GetEnchantmentType(ench) == 12		; 12=staff, 6=other, -1=none
			return ench
		else
			return none
		endif
	else
		return none
	endif
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


Function InitSkillNames()
	skillNames = new string[24]
	skillNames[6] = "OneHanded"
	skillNames[7] = "TwoHanded"
	skillNames[8] = "Marksman"
	skillNames[9] = "Block"
	skillNames[10] = "Smithing"
	skillNames[11] = "HeavyArmor"
	skillNames[12] = "LightArmor"
	skillNames[13] = "Pickpocket"
	skillNames[14] = "LockPicking"
	skillNames[15] = "Sneak"
	skillNames[16] = "Alchemy"
	skillNames[17] = "SpeechCraft"
	skillNames[18] = "Alteration"
	skillNames[19] = "Conjuration"
	skillNames[20] = "Destruction"
	skillNames[21] = "Illusion"
	skillNames[22] = "Restoration"
	skillNames[23] = "Enchanting"
EndFunction


; https://www.creationkit.com/index.php?title=ActorValueInfo_Script#Actor_Value_IDs

string function SkillIDToName (int id)
	if id >= 6 && id <= 22
		return skillNames[id]
	else
		return ""
	endif
endfunction


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
	;consoleutil.printmessage("Got list of " + items.Length + " equipped items")
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
		elseif mcmOptions.noStaff && wpn.IsStaff()
			return true
		elseif mcmOptions.noOneHanded && (wpn.IsSword() || wpn.IsMace() || wpn.IsDagger() || wpn.IsWarAxe())
			return true
		elseif mcmOptions.noTwoHanded && (wpn.IsWarHammer() || wpn.IsBattleAxe() || wpn.IsGreatsword() || wpn.IsStaff())
			return true
		elseif mcmOptions.noDagger && wpn.IsDagger()
			return true
		elseif mcmOptions.noAxe1H && wpn.IsWarAxe()
			return true
		elseif mcmOptions.noMace1H && wpn.IsMace()
			return true
		elseif mcmOptions.noSword1H && wpn.IsSword()
			return true
		endif
		if wpn.IsStaff()
			if IsProhibitedSchool(GetEnchantmentSchool(GetStaffEnchantment(wpn)))
				return true
			endif
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
		elseif mcmOptions.noPower && player.GetEquippedSpell(2) == sp
			return true
		endif
	elseif mcmOptions.noShout && (base as Shout)
		return true
	elseif base as Book
        if mcmOptions.noReading
            return true
        endif
		if (base as Book).GetSpell()
			Spell sp = (base as Book).GetSpell()
			if IsProhibitedSchool(GetSpellSchool(sp))
				return true
			endif
		endif
    elseif base as Scroll
        if mcmOptions.noReading
            return true
        endif
	endif
	return false
EndFunction


bool Function FactionHatesPlayer(Faction fac)
	return fac.GetReaction(playerFaction) == 1
EndFunction


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
			;consoleutil.printmessage(" > enemy " + npc.GetDisplayName() + "|" + npc.GetName()  + " id=" + npc.GetFormID() + " is in faction " + fac.GetName())
			;consoleutil.printmessage("  > objref=" + (npc as ObjectReference))
			npc.StopCombat()
		endif
		actorIndex -= 1
	endwhile
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
		;consoleutil.printmessage("Cowardifying follower: " + follower.GetDisplayName())
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
		;consoleutil.printmessage("Restoring follower: " + follower.GetDisplayName())
		if followerIndex < 0
			;consoleutil.printmessage("Error: could not find Actor " + follower + "in follower formlist, using default confidence of 2")
			confidence = 2
		endif
		follower.SetActorValue("confidence", confidence)
	endwhile
	mcmOptions.cowardlyFollowers.Revert()
EndFunction

