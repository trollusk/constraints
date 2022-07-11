Scriptname ConstraintsStoryQuest_AddToPlayer extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto
ConstraintsPlayerScript property playerscript auto


; Here we are only interested in stealing and pickpocketing.
; All other item transactions are dealth with in OnItemAdded/Removed.

Event OnStoryAddToPlayer(ObjectReference ownerref, ObjectReference containerref, Location loc, Form base, int how)
	Actor player = Game.GetPlayer()
	Actor owner = ownerref as Actor
	
	;consoleutil.printmessage("(ATP) Adding " + base.GetName() + " to player, ownerref=" + ownerref.GetDisplayName() + ", container=" + containerref.GetDisplayName() + ", how=" + how)
	;consoleutil.printmessage(" > Last item: count=" + playerscript.lastItemAddedCount + ", owner=" + playerscript.lastItemAddedOwner.GetName() + ", base=" + playerscript.lastItemAddedBase.GetName())
	if playerscript.lastItemAddedCount < 1
		playerscript.lastItemAddedCount = 1
	endif

	if base == playerscript.inventoryToken
		return
	endif

	if mcmOptions.noSteal && how != 3		; either stole it from world or from container
		; If the player steals an item from the world, how=1
		; But if they steal an item from a container, how=5
		; reverse it here
		if how == 1
			;consoleutil.printmessage(" > stolen from world")
			; if ownerref as Actor && player.GetDistance(ownerref) < 400
			; 	; stole item from world, owner is nearby
			; 	notification("You may not steal items.")
			; 	ownerref.AddItem(base, playerscript.lastItemAddedCount)
			; 	if base == playerscript.goldBase
			; 		playerscript.RemoveGold(playerscript.lastItemAddedCount)
			; 	else
			; 		player.RemoveItem(base, playerscript.lastItemAddedCount)
			; 	endif
			; else
			notification("You may not steal items.")
			if base == playerscript.goldBase
				playerscript.RemoveGold(playerscript.lastItemAddedCount)
				Player.PlaceAtMe(base, playerscript.lastItemAddedCount)		; does this work?
			else
				player.DropObject(base, playerscript.lastItemAddedCount)
			endif
		elseif how == 5
			; player took an item from a container. May or may not have stolen it.
			Form containerOwner = containerref.GetActorOwner()
			if !containerOwner
				containerOwner = containerref.GetFactionOwner()
			endif
			
			if ownerref
				;consoleutil.printmessage(" > from container, item owned by " + ownerref.GetDisplayName())
				notification("You may not steal items.")
				containerref.AddItem(base, playerscript.lastItemAddedCount)
				if base == playerscript.goldBase
					playerscript.RemoveGold(playerscript.lastItemAddedCount)
				else
					player.RemoveItem(base, playerscript.lastItemAddedCount)
				endif
			elseif containerOwner
				;consoleutil.printmessage(" > from container owned by " + containerOwner.GetName() + " (OK)")
				; OK
			else
				; item had no owner, so is OK
				;consoleutil.printmessage(" > item & container have no owner")
			endif
		endif
	elseif mcmOptions.noPickpocket && how == 3		; pickpocketed it, somehow
		; consoleutil.printmessage(" > pickpocketed from " + owner.GetDisplayName())
		notification("You may not pickpocket items!")
		owner.AddItem(base, playerscript.lastItemAddedCount)
		if base == playerscript.goldBase
			playerscript.RemoveGold(playerscript.lastItemAddedCount)
		else
			player.RemoveItem(base, playerscript.lastItemAddedCount)
		endif
	endif
	self.stop()
EndEvent


