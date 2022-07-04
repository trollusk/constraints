Scriptname ConstraintsStoryQuest_RelChange extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto
ConstraintsPlayerScript property playerscript auto


Event OnStoryRelationshipChange(ObjectReference actor1, ObjectReference actor2, int oldrel, int newrel)
	Actor player = Game.GetPlayer()
	if mcmOptions.noFollow && (actor1 as Actor == player || actor2 as Actor == player)
		if newrel >= 3		; 2=confidant 3=ally 4=lover
			Actor follower
			if actor1 as Actor == player
				follower = actor2 as Actor
			else
				follower = actor1 as Actor
			endif
			notification("(RC) player reached relationship rank " + newrel + " with " + follower.GetDisplayName())
			playerscript.MakeFollowerCowardly(follower)
		endif
	endif
	self.stop()
EndEvent


