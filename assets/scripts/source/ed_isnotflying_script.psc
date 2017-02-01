Scriptname ED_IsNotFlying_Script extends activemagiceffect  

; -----

Float Property ED_DelayBeforeRemoved Auto
Actor Property PlayerRef Auto
Spell Property ED_FlightAbility_Spell_Ab_IsNotFlying_AbProc Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	RegisterForSingleUpdate(ED_DelayBeforeRemoved)

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	PlayerRef.AddSpell(ED_FlightAbility_Spell_Ab_IsNotFlying_AbProc, false)

EndEvent

; -----

Event OnUpdate()

	PlayerRef.RemoveSpell(ED_FlightAbility_Spell_Ab_IsNotFlying_AbProc)

EndEvent

; -----