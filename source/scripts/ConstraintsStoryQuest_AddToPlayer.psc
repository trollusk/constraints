Scriptname ConstraintsStoryQuest_AddToPlayer extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto
ObjectReference property lastItemAddedRef auto
int property lastItemAddedCount auto


Event OnStoryAddToPlayer(ObjectReference ownerref, ObjectReference containerref, Location loc, Form base, int how)
	Actor player = Game.GetPlayer()
	Actor owner = ownerref as Actor
	
	if lastItemAddedCount < 1
		lastItemAddedCount = 1
	endif
	consoleutil.printmessage("(ATP) item added to player: " + base.GetName() + ", owner=" + ownerref.GetDisplayName() + ", how=" + how)
	if mcmOptions.noSteal && (how == 1 || (how == 5 && owner))		; stole it
		; If the player steals an item from the world, how=1
		; But if they steal an item from a container, how=5
		; reverse it here
		if how == 5 && owner
			consoleutil.printmessage("(ATP) player stole item from container: " + base.GetName() + " x" + lastItemAddedCount + ", returning it to " + containerref.GetDisplayName())
			containerref.AddItem(base, lastItemAddedCount)
			player.RemoveItem(base, lastItemAddedCount)
		elseif ownerref as Actor && player.GetDistance(ownerref) < 400
			consoleutil.printmessage("(ATP) player stole item from world: " + base.GetName() + " x" + lastItemAddedCount + ", returning it to " + ownerref.GetDisplayName())
			ownerref.AddItem(base, lastItemAddedCount)
			player.RemoveItem(base, lastItemAddedCount)
		else
			consoleutil.printmessage("(ATP) player stole item from world: " + base.GetName() + " x" + lastItemAddedCount + ", owner not nearby, dropping it")
			player.DropObject(base, lastItemAddedCount)
		endif
	elseif mcmOptions.noPickpocket && how == 3		; pickpocketed it
		notification("(ATP) player pickpocketed item: " + base.GetName() + " x" + lastItemAddedCount + ", returning it to " + owner.GetDisplayName())
		owner.AddItem(base, lastItemAddedCount)
		player.RemoveItem(base, lastItemAddedCount)
	endif
	self.stop()
EndEvent


