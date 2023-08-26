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
 
    player.RemoveSpell(playerref.magickaFatigueSpell)

    if caster == player
        if !playerref.SafeLocation(player.GetCurrentLocation())
            ; Show a dialog message listing currently slotted spells, but don't allow changing them
            int slots = playerref.CalculateSpellSlots()
            index = 1
            string spellNames = "Slotted spells:\n\n" + playerref.slottedSpells[0].GetName()
            while index < slots
                spellNames = spellNames + "\n" + playerref.slottedSpells[index].GetName()
                index += 1
            endwhile
            spellNames = spellNames + "\n\n(To assign slots, use this power in a safe location)"
            debug.MessageBox(spellNames)
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

    string[] entries = new string[2]
    int menuLine = 0
    int spellIndex = 0
    int index = 0

    menu.ResetMenu()
    menu.AddEntryItem("+++ Slot which spell? +++", -1, -2, false)
    menu.AddEntryItem("<nothing>", -1, 999, false)
    entries[0] = "+++ Slot which spell? +++ ;;-1;;0;;-2;;0"
    entries[1] = "<nothing> ;;-1;;0;;999;;0"

    index = 0
    while index < playerSpellCount
        menu.AddEntryItem(playerSpells[index].GetName(), -1, index, false)
        ; Format: text;;parent;;id;;callback;;children
        ; PO3_SKSEFunctions.AddStringToArray(playerSpells[index].GetName() + "     ;;-1;;" + index + ";;0", entries)
        entries = PapyrusUtil.PushString(entries, playerSpells[index].GetName() + "     ;;-1;;0;;" + index + ";;0")
        consoleutil.PrintMessage("Entries length: " + entries.Length)
        index += 1
    endwhile

    entries = PO3_SKSEFunctions.SortArrayString(entries)
    consoleutil.PrintMessage("After sorting, entries length: " + entries.Length)
    menu.ResetMenu()
    menu.SetPropertyStringA("appendEntries", entries)
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
