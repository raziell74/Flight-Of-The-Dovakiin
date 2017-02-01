Scriptname _Anton_ADW_MagicEffect_Counter extends activemagiceffect  

GlobalVariable Property _Anton_AnimatedDragonWings_Switch Auto
Int SwitchState

Event onEffectStart(Actor akTarget, Actor akCaster)

	SwitchState = _Anton_AnimatedDragonWings_Switch.GetValueInt()
	If SwitchState >= 2
		_Anton_AnimatedDragonWings_Switch.SetValueInt(0)
	Else
		SwitchState += 1
		_Anton_AnimatedDragonWings_Switch.SetValueInt(SwitchState)
	EndIf
	
EndEvent
