Scriptname ConstraintsMCMQuest extends SKI_ConfigBase  

ConstraintsPlayerScript property PlayerScript auto
Actor property player auto

bool property noOneHanded auto
bool _onehanded
bool property noTwoHanded auto
bool property noRanged auto
bool property noEdged auto
bool Property noStaff Auto
bool property noDagger auto
bool property noSword1H auto
bool property noMace1H auto
bool property noAxe1H auto
bool property noShield auto
bool property noLight auto
bool property noHeavy auto
bool property noSmith auto
bool property noAlteration auto
bool property noConjuration auto
bool property noIllusion auto
bool property noDestruction auto
bool property noRestoration auto
bool property noAlchemy auto
bool property noEnchant auto
bool property noSteal auto
bool property noStealth auto
bool property noLockpick auto
bool property noSpeechcraft auto
bool property noPickpocket auto
bool property noBuy auto
bool property noSell auto
bool property noFollow auto
bool property noShout auto
bool property noTrain auto
int property goldCap auto
int property weightCap auto
bool property destroyExcessGold auto

bool property burnInSunlight auto
bool Property noMap auto
bool property noReading auto
bool property hateStormcloaks auto
bool property hateLegion auto
bool property hateCompanions auto
bool property hateThalmor auto
bool property hateThievesGuild auto
bool property hateVigilants auto
bool property hateWinterholdCollege auto
bool property hateDarkBrotherhood auto

; Materials
bool property noMaterialIron auto
bool property noMaterialSteel auto
bool property noMaterialDaedric auto
bool property noMaterialLeather auto
bool property noMaterialOrcish auto
bool property noMaterialDwarven auto
bool property noMaterialElven auto
bool property noMaterialGlass auto
bool property noMaterialEbony auto
bool property noMaterialHide auto
bool property noMaterialDragonscale auto
bool property noMaterialDragonplate auto
bool property noMaterialFalmer auto
bool property noMaterialSilver auto		; weapon only
bool property noMaterialWood auto		; weapon only

FormList property cowardlyFollowers auto
int[] property followerConfidence auto

; MCM option indices
int iOneHanded
int iTwoHanded
int iRanged
int iEdged
int iStaff
int iDagger
int iSword1H
int iAxe1H
int iMace1H
int iShield
int iLight
int iHeavy
int iSmith
int iAlteration
int iConjuration
int iIllusion
int iDestruction
int iRestoration
int iAlchemy
int iEnchant
int iSteal
int iStealth
int iLockpick
int iSpeechcraft
int iPickpocket
int iBuy
int iSell
int iFollow
int iMaterialIron
int iMaterialSteel
int iMaterialDaedric
int iMaterialLeather
int iMaterialOrcish
int iMaterialDwarven
int iMaterialElven
int iMaterialGlass
int iMaterialEbony
int iMaterialHide
int iMaterialDragonscale
int iMaterialDragonplate
int iMaterialFalmer
int iMaterialSilver		; weapon only
int iMaterialWood		; weapon only

int iShout
int iTrain
int iGoldCap
int iWeightCap
int iDestroyExcessGold
int iBurnInSunlight
int iMap
int iReading
int iLegion
int iStormcloaks
int iCompanions
int iThalmor
int iThievesGuild
int iDarkBrotherhood
int iVigilants
int iWHCollege


; Event OnConfigInit()
; 	Pages = new string[5]
; 	Pages[0] = "Equipment"
; 	Pages[1] = "Magic"
; 	Pages[2] = "Subterfuge"
; 	Pages[3] = "Society"
; 	Pages[4] = "Misc"
; EndEvent


Event OnPageReset (string page)
	SetCursorFillMode(TOP_TO_BOTTOM)
	if (page == "Equipment")
		AddHeaderOption("Weapons")
		iOneHanded = AddToggleOption("No one-handed weapons", _onehanded)
		iTwoHanded = AddToggleOption("No two-handed weapons", noTwoHanded)
		iRanged = AddToggleOption("No ranged weapons", noRanged)
		iEdged = AddToggleOption("No edged weapons", noEdged)
		iStaff = AddToggleOption("No staves", noStaff)
		iDagger = AddToggleOption("No daggers", noDagger)
		iSword1H = AddToggleOption("No one-handed swords", noSword1H)
		iMace1H = AddToggleOption("No one-handed maces", noMace1H)
		iAxe1H = AddToggleOption("No one-handed axes", noAxe1H)
		iShield = AddToggleOption("No shields", noShield)
		;SetCursorPosition(1)
		AddEmptyOption()
		AddHeaderOption("Armour")
		iLight = AddToggleOption("No light armour", noLight)
		iHeavy = AddToggleOption("No heavy armour", noHeavy)
		AddEmptyOption()
		AddHeaderOption("Smithing")
		iSmith = AddToggleOption("No smithing", noSmith)
		AddEmptyOption()
		AddHeaderOption("Encumbrance")
		iWeightCap = AddSliderOption("Encumbrance limit", weightCap)
		SetCursorPosition(1)
		AddHeaderOption("Prohibited Materials")
		iMaterialIron = AddToggleOption("No Iron", noMaterialIron)
		iMaterialSteel = AddToggleOption("No Steel", noMaterialSteel)
		iMaterialDaedric = AddToggleOption("No Daedric", noMaterialDaedric)
		iMaterialLeather = AddToggleOption("No Leather", noMaterialLeather)
		iMaterialOrcish = AddToggleOption("No Orcish", noMaterialOrcish)
		iMaterialDwarven = AddToggleOption("No Dwarven", noMaterialDwarven)
		iMaterialElven = AddToggleOption("No Elven", noMaterialElven)
		iMaterialGlass = AddToggleOption("No Glass", noMaterialGlass)
		iMaterialEbony = AddToggleOption("No Ebony", noMaterialEbony)
		iMaterialHide = AddToggleOption("No Hide", noMaterialHide)
		iMaterialDragonscale = AddToggleOption("No Dragonscale", noMaterialDragonscale)
		iMaterialDragonplate = AddToggleOption("No Dragonplate", noMaterialDragonplate)
		iMaterialFalmer = AddToggleOption("No Falmer", noMaterialFalmer)
		iMaterialSilver = AddToggleOption("No Silver", noMaterialSilver)		; weapon only
		iMaterialWood = AddToggleOption("No Wood", noMaterialWood)		; weapon only
	elseif (page == "Magic")
		AddHeaderOption("Schools")
		iAlteration = AddToggleOption("No Alteration spells", noAlteration)
		iConjuration = AddToggleOption("No Conjuration spells", noConjuration)
		iIllusion = AddToggleOption("No Illusion spells", noIllusion)
		iDestruction = AddToggleOption("No Destruction spells", noDestruction)
		iRestoration = AddToggleOption("No Restoration spells", noRestoration)
		AddEmptyOption()
		iShout = AddToggleOption("No shouts or powers", noShout)
		AddEmptyOption()
		AddHeaderOption("Crafting")
		iAlchemy = AddToggleOption("No alchemy", noAlchemy)
		iEnchant = AddToggleOption("No enchanting", noEnchant)
	elseif (page == "Subterfuge")
		iStealth = AddToggleOption("No sneaking", noStealth)
		iLockpick = AddToggleOption("No lockpicking", noLockpick)
		iPickpocket = AddToggleOption("No picking pockets", noPickpocket)
		iSteal = AddToggleOption("No stealing", noSteal)
	elseif page == "Society"
		AddHeaderOption("Trade")
		iSpeechcraft = AddToggleOption("No speechcraft", noSpeechcraft)
		iBuy = AddToggleOption("No buying", noBuy)
		iSell = AddToggleOption("No selling", noSell)
		iTrain = AddToggleOption("No skill trainers", noTrain)
		AddEmptyOption()
		iGoldCap = AddSliderOption("Gold cap", goldCap)
		iDestroyExcessGold = AddToggleOption("Destroy excess gold", destroyExcessGold)
		SetCursorPosition(1)
		AddHeaderOption("Enemy Factions")
		iLegion = AddToggleOption("Imperial Legion", hateLegion)
		iStormcloaks = AddToggleOption("Stormcloaks", hateStormcloaks)
		iCompanions = AddToggleOption("Companions", hateCompanions)
		iThalmor = AddToggleOption("Thalmor", hateThalmor)
		iThievesGuild = AddToggleOption("Thieves Guild", hateThievesGuild)
		iDarkBrotherhood = AddToggleOption("Dark Brotherhood", hateDarkBrotherhood)
		iVigilants = AddToggleOption("Vigilants of Stendarr", hateVigilants)
		iWHCollege = AddToggleOption("Winterhold College", hateWinterholdCollege)
	elseif page == "Misc." || page == "Misc"
		iMap = AddToggleOption("No map", noMap)
		iReading = AddToggleOption("Illiterate", noReading)
		iFollow = AddToggleOption("No combat followers", noFollow)
		iBurnInSunlight = AddToggleOption("Burn in sunlight", burnInSunlight)
	endif
EndEvent


Event OnOptionSelect (int option)
	if option == iOneHanded
		noOneHanded = !noOneHanded
		_onehanded = noOneHanded
		SetToggleOptionValue(iOneHanded, _onehanded)
	elseif option == iTwoHanded
		noTwoHanded = !noTwoHanded
		SetToggleOptionValue(iTwoHanded, noTwoHanded)
	elseif option == iRanged
		noRanged = !noRanged
		SetToggleOptionValue(iRanged, noRanged)
	elseif option == iEdged
		noEdged = !noEdged
		SetToggleOptionValue(iEdged, noEdged)
	elseif option == iStaff
		noStaff = !noStaff
		SetToggleOptionValue(iStaff, noStaff)
	elseif option == iDagger
		noDagger = !noDagger
		SetToggleOptionValue(iDagger, noDagger)
	elseif option == iSword1H
		noSword1H = !noSword1H
		SetToggleOptionValue(iSword1H, noSword1H)
	elseif option == iAxe1H
		noAxe1H = !noAxe1H
		SetToggleOptionValue(iAxe1H, noAxe1H)
	elseif option == iMace1H
		noMace1H = !noMace1H
		SetToggleOptionValue(iMace1H, noMace1H)
	elseif option == iShield
		noShield = !noShield
		SetToggleOptionValue(iShield, noShield)
	elseif option == iLight
		noLight = !noLight
		SetToggleOptionValue(iLight, noLight)
	elseif option == iHeavy
		noHeavy = !noHeavy
		SetToggleOptionValue(iHeavy, noHeavy)
	elseif option == iSmith
		noSmith = !noSmith
		SetToggleOptionValue(iSmith, noSmith)
	elseif option == iAlteration
		noAlteration = !noAlteration
		SetToggleOptionValue(iAlteration, noAlteration)
	elseif option == iConjuration
		noConjuration = !noConjuration
		SetToggleOptionValue(iConjuration, noConjuration)
	elseif option == iIllusion
		noIllusion = !noIllusion
		SetToggleOptionValue(iIllusion, noIllusion)
	elseif option == iDestruction
		noDestruction = !noDestruction
		SetToggleOptionValue(iDestruction, noDestruction)
	elseif option == iRestoration
		noRestoration = !noRestoration
		SetToggleOptionValue(iRestoration, noRestoration)
	elseif option == iAlchemy
		noAlchemy = !noAlchemy
		SetToggleOptionValue(iAlchemy, noAlchemy)
	elseif option == iEnchant
		noEnchant = !noEnchant
		SetToggleOptionValue(iEnchant, noEnchant)
	elseif option == iSteal
		noSteal = !noSteal
		SetToggleOptionValue(iSteal, noSteal)
	elseif option == iStealth
		noStealth = !noStealth
		SetToggleOptionValue(iStealth, noStealth)
	elseif option == iLockpick
		noLockpick = !noLockpick
		SetToggleOptionValue(iLockpick, noLockpick)
	elseif option == iSpeechcraft
		noSpeechcraft = !noSpeechcraft
		SetToggleOptionValue(iSpeechcraft, noSpeechcraft)
	elseif option == iPickpocket
		noPickpocket = !noPickpocket
		SetToggleOptionValue(iPickpocket, noPickpocket)
	elseif option == iBuy
		noBuy = !noBuy
		SetToggleOptionValue(iBuy, noBuy)
	elseif option == iSell
		noSell = !noSell
		SetToggleOptionValue(iSell, noSell)
	elseif option == iTrain
		noTrain = !noTrain
		SetToggleOptionValue(iTrain, noTrain)
	elseif option == iFollow
		noFollow = !noFollow
		SetToggleOptionValue(iFollow, noFollow)
	elseif option == iMaterialIron
		noMaterialIron = !noMaterialIron
		SetToggleOptionValue(iMaterialIron, noMaterialIron)
	elseif option == iMaterialSteel
		noMaterialSteel = !noMaterialSteel
		SetToggleOptionValue(iMaterialSteel, noMaterialSteel)
	elseif option == iMaterialDaedric
		noMaterialDaedric = !noMaterialDaedric
		SetToggleOptionValue(iMaterialDaedric, noMaterialDaedric)
	elseif option == iMaterialLeather
		noMaterialLeather = !noMaterialLeather
		SetToggleOptionValue(iMaterialLeather, noMaterialLeather)
	elseif option == iMaterialOrcish
		noMaterialOrcish = !noMaterialOrcish
		SetToggleOptionValue(iMaterialOrcish, noMaterialOrcish)
	elseif option == iMaterialDwarven
		noMaterialDwarven = !noMaterialDwarven
		SetToggleOptionValue(iMaterialDwarven, noMaterialDwarven)
	elseif option == iMaterialElven
		noMaterialElven = !noMaterialElven
		SetToggleOptionValue(iMaterialElven, noMaterialElven)
	elseif option == iMaterialGlass
		noMaterialGlass = !noMaterialGlass
		SetToggleOptionValue(iMaterialGlass, noMaterialGlass)
	elseif option == iMaterialEbony
		noMaterialEbony = !noMaterialEbony
		SetToggleOptionValue(iMaterialEbony, noMaterialEbony)
	elseif option == iMaterialHide
		noMaterialHide = !noMaterialHide
		SetToggleOptionValue(iMaterialHide, noMaterialHide)
	elseif option == iMaterialDragonscale
		noMaterialDragonscale = !noMaterialDragonscale
		SetToggleOptionValue(iMaterialDragonscale, noMaterialDragonscale)
	elseif option == iMaterialDragonplate
		noMaterialDragonplate = !noMaterialDragonplate
		SetToggleOptionValue(iMaterialDragonplate, noMaterialDragonplate)
	elseif option == iMaterialFalmer
		noMaterialFalmer = !noMaterialFalmer
		SetToggleOptionValue(iMaterialFalmer, noMaterialFalmer)
	elseif option == iMaterialSilver
		noMaterialSteel = !noMaterialSilver
		SetToggleOptionValue(iMaterialSilver, noMaterialSilver)
	elseif option == iMaterialWood
		noMaterialWood = !noMaterialWood
		SetToggleOptionValue(iMaterialWood, noMaterialWood)
	elseif option == iShout
		noShout = !noShout
		SetToggleOptionValue(iShout, noShout)
	elseif option == iDestroyExcessGold
		destroyExcessGold = !destroyExcessGold
		SetToggleOptionValue(iDestroyExcessGold, destroyExcessGold)
	elseif option == iBurnInSunlight
		burnInSunlight = !burnInSunlight
		SetToggleOptionValue(iBurnInSunlight, burnInSunlight)
	elseif option == iMap
		noMap = !noMap
		SetToggleOptionValue(iMap, noMap)
	elseif option == iLegion
		hateLegion = !hateLegion
		SetToggleOptionValue(iLegion, hateLegion)
	elseif option == iStormcloaks
		hateStormcloaks = !hateStormcloaks
		SetToggleOptionValue(iStormcloaks, hateStormcloaks)
	elseif option == iCompanions
		hateCompanions = !hateCompanions
		SetToggleOptionValue(iCompanions, hateCompanions)
	elseif option == iThalmor
		hateThalmor = !hateThalmor
		SetToggleOptionValue(iThalmor, hateThalmor)
	elseif option == iThievesGuild
		hateThievesGuild = !hateThievesGuild
		SetToggleOptionValue(iThievesGuild, hateThievesGuild)
	elseif option == iDarkBrotherhood
		hateDarkBrotherhood = !hateDarkBrotherhood
		SetToggleOptionValue(iDarkBrotherhood, hateDarkBrotherhood)
	elseif option == iVigilants
		hateVigilants = !hateVigilants
		SetToggleOptionValue(iVigilants, hateVigilants)
	elseif option == iWHCollege
		hateWinterholdCollege = !hateWinterholdCollege
		SetToggleOptionValue(iWHCollege, hateWinterholdCollege)
	endif
EndEvent



Event OnOptionSliderOpen (int option)
	if (option == iGoldCap)
		SetSliderDialogStartValue(goldCap)
		SetSliderDialogDefaultValue(0)
		SetSliderDialogRange(0, 1000)
		SetSliderDialogInterval(10)
	elseif (option == iWeightCap)
			SetSliderDialogStartValue(weightCap)
			SetSliderDialogDefaultValue(0)
			SetSliderDialogRange(0, 500)
			SetSliderDialogInterval(5)
		EndIf
EndEvent


Event OnOptionSliderAccept (int option, float value)
	if (option == iGoldCap)
		goldCap = value as int
		SetSliderOptionValue(iGoldCap, goldCap)
	elseif (option == iWeightCap)
		weightCap = value as int
		SetSliderOptionValue(iWeightCap, weightCap)
	EndIf
	ForcePageReset()
EndEvent


Event OnOptionHighlight(int option)
	if option == iOneHanded
		SetInfoText("Prevent yourself from equipping one-handed melee weapons.")
	elseif option == iTwoHanded
		SetInfoText("Prevent yourself from equipping two-handed melee weapons.")
	elseif option == iRanged
		SetInfoText("Prevent yourself from equipping ranged weapons.")
	elseif option == iEdged
		SetInfoText("Prevent yourself from equipping edged weapons (daggers, swords, axes).")
	elseif option == iStaff
		SetInfoText("Prevent yourself from equipping a staff. Note that staves are neither one-handed nor two-handed weapons, as they improve neither skill.")
	elseif option == iDagger
		SetInfoText("Prevent yourself from equipping daggers.")
	elseif option == iSword1H
		SetInfoText("Prevent yourself from equipping one-handed swords.")
	elseif option == iAxe1H
		SetInfoText("Prevent yourself from equipping one-handed axes.")
	elseif option == iMace1H
		SetInfoText("Prevent yourself from equipping one-handed blunt weapons.")
	elseif option == iShield
		SetInfoText("Prevent yourself from equipping shields.")
	elseif option == iLight
		SetInfoText("Prevent yourself from equipping light armor.")
	elseif option == iHeavy
		SetInfoText("Prevent yourself from equipping heavy armor.")
	elseif option == iSmith
		SetInfoText("Prevent yourself from using smithing stations.")
	elseif option == iWeightCap
		SetInfoText("Prevent yourself from carrying more than this amount of weight. If you pick up an item that puts you over this limit, the item will be dropped at your feet. Your normal in-game encumbrance limit still applies as well. Zero means that this option is not active.")
	elseif option == iAlteration
		SetInfoText("Prevent yourself from learning or casting Alteration spells.")
	elseif option == iConjuration
		SetInfoText("Prevent yourself from learning or casting Conjuration spells.")
	elseif option == iIllusion
		SetInfoText("Prevent yourself from learning or casting Illusion spells.")
	elseif option == iDestruction
		SetInfoText("Prevent yourself from learning or casting Destruction spells.")
	elseif option == iRestoration
		SetInfoText("Prevent yourself from learning or casting Restoration spells.")
	elseif option == iAlchemy
		SetInfoText("Prevent yourself from using alchemy stations.")
	elseif option == iEnchant
		SetInfoText("Prevent yourself from using enchanting stations.")
	elseif option == iSteal
		SetInfoText("Prevent yourself from stealing items.")
	elseif option == iStealth
		SetInfoText("Prevent yourself from sneaking.")
	elseif option == iLockpick
		SetInfoText("Prevent yourself from picking locks.")
	elseif option == iSpeechcraft
		SetInfoText("Set your speechcraft skill to zero.")
	elseif option == iPickpocket
		SetInfoText("You will always fail at pickpocketing.")
	elseif option == iBuy
		SetInfoText("Prevent yourself from buying items from vendors.")
	elseif option == iSell
		SetInfoText("Prevent yourself from selling items to vendors.")
	elseif option == iFollow
		SetInfoText("Prevent followers from assisting you in combat.")
	elseif option == iMaterialIron
		SetInfoText("Prevent yourself from using iron weapons or armor.")
	elseif option == iMaterialSteel
		SetInfoText("Prevent yourself from using steel weapons or armor.")
	elseif option == iMaterialLeather
		SetInfoText("Prevent yourself from using leather weapons or armor.")
	elseif option == iMaterialHide
		SetInfoText("Prevent yourself from using hide weapons or armor.") 
	elseif option == iMaterialSilver
		SetInfoText("Prevent yourself from using silver weapons or armor.") ;weapon only
	elseif option == iMaterialWood
		SetInfoText("Prevent yourself from using wooden weapons or armor.") ;weapon only
	elseif option == iMaterialElven
		SetInfoText("Prevent yourself from using Elven weapons or armor.")
	elseif option == iMaterialOrcish
		SetInfoText("Prevent yourself from using Orcish weapons or armor.")
	elseif option == iMaterialDwarven
		SetInfoText("Prevent yourself from using Dwarven weapons or armor.")
	elseif option == iMaterialFalmer
		SetInfoText("Prevent yourself from using Falmer weapons or armor.")
	elseif option == iMaterialDaedric
		SetInfoText("Prevent yourself from using Daedric weapons or armor.")
	elseif option == iMaterialGlass
		SetInfoText("Prevent yourself from using glass weapons or armor.") 
	elseif option == iMaterialEbony
		SetInfoText("Prevent yourself from using ebony weapons or armor.") 
	elseif option == iMaterialDragonscale
		SetInfoText("Prevent yourself from using dragonscale weapons or armor.")
	elseif option == iMaterialDragonplate
		SetInfoText("Prevent yourself from using dragonplate weapons or armor.")
	elseif option == iShout
		SetInfoText("Prevent yourself from equipping shouts or powers.")
	elseif option == iTrain
		SetInfoText("Prevent yourself from using skill trainers.")
	elseif option == iGoldCap
		SetInfoText("Prevent yourself from carrying more than this much gold. When you acquire gold in excess of this number, that gold will disappear. If 'Destroy Excess Gold' is false, all the disappeared gold will be returned to you when you toggle this option off. Zero means no cap.")
	elseif option == iDestroyExcessGold
		SetInfoText("If true, and you are using a gold cap, then any gold you acquire in excess of the cap will be destroyed rather than stored.")
	elseif option == iBurnInSunlight
		SetInfoText("Take continuous health damage whenever you are exposed to daylight.")
	elseif option == iMap
		SetInfoText("Prevent yourself from opening the map. This will also mean you are unable to fast travel via the map.")
	elseif option == iReading
		SetInfoText("Prevent yourself from reading books or other written material. This will also make it impossible to gain skill points or spells from books.")
	elseif option == iLegion
		SetInfoText("The Imperial Legion will attack you on sight. Will break quests!")
	elseif option == iStormcloaks
		SetInfoText("The Stormcloaks will attack you on sight. Will break quests!")
	elseif option == iCompanions
		SetInfoText("The Companions will attack you on sight. Will break quests!")
	elseif option == iThalmor
		SetInfoText("The Thalmor will attack you on sight. Will break quests!")
	elseif option == iThievesGuild
		SetInfoText("The Thieves Guild will attack you on sight. Will break quests!")
	elseif option == iDarkBrotherhood
		SetInfoText("The Dark Brotherhood will attack you on sight. Will break quests!")
	elseif option == iVigilants
		SetInfoText("The Vigilants of Stendarr will attack you on sight. Will break quests!")
	elseif option == iWHCollege
		SetInfoText("Members of the College of Winterhold will attack you on sight. Will break quests!")
	endif
EndEvent

