Scriptname ED_IsFlying_Script extends activemagiceffect  

; -----

Float Property ED_UpdateRate Auto
Actor Property PlayerRef Auto
GlobalVariable Property ED_FlightAbility_Global_IsFlying Auto
Spell Property ED_FlightAbility_Spell_CrashBomb Auto
GlobalVariable Property ED_FlightAbility_Global_NoFlyZoneZ Auto
Sound[] Property ED_Wind Auto

; -----

Float NoFlyZoneZ = 20000.0
Int SoundID

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	NoFlyZoneZ = ED_FlightAbility_Global_NoFlyZoneZ.GetValue()
	Int WindType = Utility.RandomInt(0, ED_Wind.Length - 1)
	SoundID = ED_Wind[WindType].Play(PlayerRef)
	RegisterForSingleUpdate(ED_UpdateRate)

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	Sound.StopInstance(SoundID)

EndEvent

; -----

Event OnUpdate()

	If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
		ED_FlightAbility_Spell_CrashBomb.Cast(PlayerRef)
	EndIf
	If PlayerRef.GetPositionZ() >= NoFlyZoneZ
		SendModEvent("NoFlyZoneZ")
	EndIf

	RegisterForSingleUpdate(ED_UpdateRate)

EndEvent

; -----