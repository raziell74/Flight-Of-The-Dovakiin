Scriptname ED_DragonShield_Script extends activemagiceffect  

; -----

ObjectReference Property ED_FlightAbility_Activator_DragonShield Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	Utility.Wait(0.1)
	ED_FlightAbility_Activator_DragonShield.Enable()

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	ED_FlightAbility_Activator_DragonShield.Disable()

EndEvent

; -----