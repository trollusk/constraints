Scriptname ConstraintsStoryQuest_IncreaseSkill extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto


Event OnStoryIncreaseSkill(string skill)
	Actor player = Game.GetPlayer()
	; if it's a prohibited skill, undo it
	; if IsProhibitedSkill(skill)
		; notification("(IS) player increased their '" + skill + "' skill (prohibited)")
		; ; TODO nondestructive
		; ; player.SetActorValue(skill, 0)
	; endif
	self.stop()
EndEvent



bool Function IsProhibitedSkill (string skill)
	if mcmOptions.noOneHanded && skill == "OneHanded" 
		return true
	elseif mcmOptions.noTwoHanded && skill == "TwoHanded" 
		return true
	elseif mcmOptions.noRanged && skill == "Marksman" 
		return true
	elseif mcmOptions.noShield && skill == "Block" 
		return true
	elseif mcmOptions.noLight && skill == "LightArmor" 
		return true
	elseif mcmOptions.noHeavy && skill == "HeavyArmor" 
		return true
	elseif mcmOptions.noSmith && skill == "Smithing" 
		return true
	elseif mcmOptions.noAlteration && skill == "Alteration" 
		return true
	elseif mcmOptions.noConjuration && skill == "Conjuration" 
		return true
	elseif mcmOptions.noIllusion && skill == "Illusion" 
		return true
	elseif mcmOptions.noDestruction && skill == "Destruction" 
		return true
	elseif mcmOptions.noRestoration && skill == "Restoration" 
		return true
	elseif mcmOptions.noAlchemy && skill == "Alchemy" 
		return true
	elseif mcmOptions.noEnchant && skill == "Enchanting" 
		return true
	elseif mcmOptions.noStealth && skill == "Sneak" 
		return true
	elseif mcmOptions.noLockpick && skill == "Lockpicking" 
		return true
	elseif mcmOptions.noSpeechcraft && skill == "Speechcraft" 
		return true
	elseif mcmOptions.noPickpocket && skill == "Pickpocket" 
		return true
	else
		return false
	endif
EndFunction

