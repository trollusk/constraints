ScriptName ConstraintsTargetScript extends ReferenceAlias

import Debug

; This script is attached to a referencealias, which is assigned to whatever the
; crosshair is pointing at. 
; In other words, this script is always attached to the player's crosshair target.

Actor property player auto
ConstraintsMCMQuest property mcmOptions auto
ConstraintsPlayerScript property PlayerScript auto


Function InitScript()
    RegisterForCrosshairRef()
EndFunction


; This script is attached to the objectreference targeted by the crosshair
Event OnCrosshairRefChange(ObjectReference ref)
    if self.GetReference() && (self.GetReference() != ref)
        ObjectReference oldRef = self.GetReference()
        ;oldRef.SetDisplayName(oldRef.GetBaseObject().GetName())
        ;oldRef.BlockActivation(false)
    endif
    if ref
        self.ForceRefTo(ref)
        ;if ref.GetBaseObject() as Book
            ;ref.SetDisplayName("?????")
            ;ref.BlockActivation(true)
        ;endif
    endif   
EndEvent

