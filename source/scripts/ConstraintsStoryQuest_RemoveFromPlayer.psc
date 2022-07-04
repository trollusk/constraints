Scriptname ConstraintsStoryQuest_RemoveFromPlayer extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto
ObjectReference property lastItemRemovedRef auto
int property lastItemRemovedCount auto


Event OnStoryRemoveFromPlayer(ObjectReference ownerref, ObjectReference itemref, Location loc, Form base, int how)
	if how == 2			; consumed it
		notification("(RFP) player consumed " + itemref.GetDisplayName())
	elseif how == 5		; gave it to someone
		notification("(RFP) player gave " + itemref.GetDisplayName() + " to someone (? " + ownerref.GetDisplayName() + ")")
	endif
	self.stop()
EndEvent

