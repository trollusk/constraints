Scriptname ConstraintsStoryQuest_IncreaseLevel extends Quest

import debug

ConstraintsMCMQuest property mcmOptions auto


Event OnStoryIncreaseLevel (int newlevel)
    Actor player = Game.GetPlayer()
    ;ConsoleUtil.PrintMessage("StoryIncreaseLevel: player.level=" + player.GetLevel() + ", newlevel=" + newlevel + ", exp=" + Game.GetPlayerExperience() + ", perks=" + Game.GetPerkPoints())
    self.stop()
EndEvent

