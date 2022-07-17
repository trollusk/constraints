Scriptname ConstraintsStoryQuest_IncreaseSkill extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto

; This event never runs

Event OnStoryIncreaseSkill(string skill)
    Actor player = Game.GetPlayer()
    ;ConsoleUtil.PrintMessage("StoryIncreaseSkill: " + skill + ", skillpoints=" + player.GetActorValue(skill) + ", exp=" + Game.GetPlayerExperience() + "/" + Game.GetExperienceForLevel(player.GetLevel()) + ", perks=" + Game.GetPerkPoints())
    if UI.IsMenuOpen("Book Menu")
            ;ConsoleUtil.PrintMessage("Gained skill inside book menu: " + skill)
            if mcmOptions.noReading
                    ; undo the skill gain
                    ;ConsoleUtil.PrintMessage("Reversing skill gain")
                    player.ModActorValue(skill, -1)
            endif
    endif
    self.stop()
EndEvent

