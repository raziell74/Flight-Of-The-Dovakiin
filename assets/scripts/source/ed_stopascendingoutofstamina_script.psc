Scriptname ED_StopAscendingOutOfStamina_Script extends activemagiceffect  

; -----

Actor Property PlayerRef Auto
Float Property ED_UpdateRate Auto
GlobalVariable Property ED_FlightAbility_Global_FlyingPitch Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	OnUpdate()

EndEvent

; -----

Event OnUpdate()

	If PlayerRef.GetActorValue("Stamina") < 1.0 && ED_FlightAbility_Global_FlyingPitch.GetValue() == 2.0
		SendModEvent("UnableToClimb")
	EndIf
	RegisterForSingleUpdate(ED_UpdateRate)

EndEvent

; -----