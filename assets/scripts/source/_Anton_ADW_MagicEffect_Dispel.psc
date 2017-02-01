Scriptname _Anton_ADW_MagicEffect_Dispel extends activemagiceffect  

GlobalVariable Property _Anton_AnimatedDragonWings_Switch Auto
GlobalVariable Property _Anton_AnimatedDragonWings_JumpHeight Auto

Event onEffectStart(Actor akTarget, Actor akCaster)

	; Game.SetGameSettingFloat("fJumpHeightMin", _Anton_AnimatedDragonWings_JumpHeight.GetValue() )
	_Anton_AnimatedDragonWings_Switch.SetValueInt(2)
	
EndEvent
