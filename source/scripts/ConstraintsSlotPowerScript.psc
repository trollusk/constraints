Scriptname ConstraintsSlotPowerScript extends ActiveMagicEffect

;import Debug

Actor property player auto
ConstraintsPlayerScript property playerref auto
ConstraintsMCMQuest property mcmOptions auto

Spell[] playerSpells
int playerSpellCount = 0
Spell dummySpell 
bool selectedUnslot = false 
bool exitWithoutSelect = false 



Event OnEffectStart(Actor target, Actor caster)
    dummySpell = playerref.spellToken
    playerSpells = new Spell[128]
    int numSpells = 0
    int index = 0
 
    if caster == player
        if !playerref.SafeLocation(player.GetCurrentLocation())
            debug.MessageBox("To favorite and unfavorite spells, you must be \nin a safe location such as an inn, guild, or player home.")
        else
            ; Do this once only, as it's slow
            debug.notification("Please wait, getting list of player spells...")
            numSpells = player.GetSpellCount()
            consoleutil.printmessage("Player spell count: " + numSpells)
            consoleutil.printmessage("Dummy spell: " + playerref.spellToken + " " + playerref.spellToken.GetName())
            index = 0
            playerSpellCount = 0
            while index < numSpells
                Spell spl = player.GetNthSpell(index) as Spell
                if playerref.IsTrueSpell(spl) 
                    playerSpells[playerSpellCount] = spl
                    playerSpellCount += 1
                endif
                index += 1
            endwhile
            ; bring up list of SLOTS
            ChangeSpellSlots_UIExt()
        endif
    endif
EndEvent



function ChangeSpellSlots_UIExt()
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu
    bool bLoop = true

	while bLoop
        menu.ResetMenu()
        menu.AddEntryItem("=== Spell Slots (select to change) ===", -1, -2, false)
        int slots = playerref.CalculateSpellSlots()

        int index = 0
        while index < slots
            Spell sp = playerref.slottedSpells[index]
            if sp
                consoleutil.printmessage("Player slotted Spells[" + index + "] = " + sp.GetName())
            endif
            if !sp || (sp == dummySpell)
                menu.AddEntryItem("(empty)", -1, index, false)
                consoleutil.printmessage("  --> adding empty entry " + index)
            else
                menu.AddEntryItem(sp.GetName(), -1, index, false)
                consoleutil.printmessage("  --> adding entry for spell " + sp.GetName() + ", index " + index)
            endif
            index += 1
        endwhile

		menu.OpenMenu()

        ; GetResultInt returns the entry number that was selected. 0 = the first entry, etc.
        ; GetResultFloat returns the "entryCallback" value that was stored with the entry.

		int selected = menu.GetResultFloat() as int
        consoleutil.printmessage("GetResultInt: " + selected + ", GetResultFloat: " + menu.GetResultFloat())
		if selected < 0     ; exit
		    bLoop = false
		else
            UI.CloseCustomMenu()
            Spell sp = SelectSpell_UIExt()
            consoleutil.printmessage("SelectSpell returned " + sp.GetName() + ", unslot:" + selectedUnslot + ", exit:" + exitWithoutSelect + " for slot " + selected)
            if selectedUnslot
                consoleutil.printmessage("Selected to clear slot " + selected)
                ; playerref.slottedSpells[selected] = dummySpell
                playerref.AssignSpellToSlot(dummySpell, selected)
            elseif !exitWithoutSelect
                consoleutil.printmessage("Assigning spell " + sp.GetName() +  " to slot " + selected)
                index = 0
                while index < slots     ; unslot if already slotted elsewhere
                    if playerref.slottedSpells[index] == sp 
                        playerref.AssignSpellToSlot(dummySpell, index)
                    endif
                    index += 1
                endwhile
                playerref.AssignSpellToSlot(sp, selected)
            endif
		endif
	endwhile
endfunction


; TODO
; why not preventing equipping spells
; use power outside safe zone = display list of slotted spells
; sort?

; Spell function SelectSpell_UIExt()
;     return playerSpells[0]
; endfunction


Spell function SelectSpell_UIExt()
	UIListMenu menu = UIExtensions.GetMenu("UIListMenu") as UIListMenu

    int menuLine = 0
    int spellIndex = 0
    int index = 0

    menu.ResetMenu()
    menu.AddEntryItem("=== Slot which spell? ===", -1, -2, false)
    menu.AddEntryItem("(nothing)", -1, 999, false)

    index = 0
    while index < playerSpellCount
        menu.AddEntryItem(playerSpells[index].GetName(), -1, index, false)
        index += 1
    endwhile

    menu.OpenMenu()

    int selected = menu.GetResultFloat() as int
    consoleutil.printmessage("GetResultInt: " + selected + ", GetResultFloat: " + menu.GetResultFloat())
    if selected < 0
        ;consoleutil.printmessage("Exited ListMenu")
        exitWithoutSelect = true 
        selectedUnslot = false
        return dummySpell
    elseif selected == 999          ; "nothing"
        exitWithoutSelect = false 
        selectedUnslot = true
        return dummySpell         ; signifies an empty slot
    else
        exitWithoutSelect = false 
        selectedUnslot = false 
        return playerSpells[selected]
    endif
endfunction
