Scriptname ConstraintsStoryQuest_Lockpicked extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto


Event OnStoryPickLock (ObjectReference picker, ObjectReference lockref)
	Actor player = Game.GetPlayer()
	if mcmOptions.noLockpick && picker == player
		notification("(LP) player successfully picked a lock on: " + lockref.GetDisplayName())
	endif
	self.stop()
EndEvent


