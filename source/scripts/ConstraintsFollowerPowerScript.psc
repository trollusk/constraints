Scriptname ConstraintsFollowerPowerScript extends ActiveMagicEffect

Actor property player auto
ConstraintsPlayerScript property playerref auto

Event OnEffectStart(Actor target, Actor caster)
    if caster == player
        if target.IsPlayerTeammate()
            ; if target is a player follower, then set braveFollower = target
            playerref.braveFollower = target
            if target.GetActorValue("confidence") <= 0
                target.SetActorValue("confidence", target.GetBaseActorValue("confidence"))
            endif
        elseif target
            debug.Notification(target.GetDisplayName() + " is not following you.")
        endif
    endif
EndEvent

