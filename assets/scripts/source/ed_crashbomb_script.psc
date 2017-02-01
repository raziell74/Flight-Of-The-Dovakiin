Scriptname ED_CrashBomb_Script extends ObjectReference  

; -----

Actor Property PlayerRef Auto
GlobalVariable Property ED_FlightAbility_Global_IsFlying Auto
Sound Property ED_FlightAbility_Marker_CrashBomb Auto
Message Property ED_FlightAbility_Message_Help_DoNotCrash Auto

Float Property ED_ForcedMoveAfterImpact = 1.75 Auto Hidden
GlobalVariable Property ED_FlightAbility_Global_FlyingPitch Auto

; -----

Event OnLoad()
    Utility.Wait(0.25)
	If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && ED_FlightAbility_Global_FlyingPitch.GetValue() != 3.0
		; pilot touched the ground while flying (or rather without landing properly) so shut off engine and drop to the ground - RUN HIT
		
		; Do a tiny jump to break out of the flying animation
		Game.SetGameSettingFloat("fJumpHeightMin", 5)
		Input.TapKey(Input.GetMappedKey("Jump"))
		
		ED_FlightAbility_Global_FlyingPitch.SetValue(3)
		
		Game.ShakeCamera(afStrength = 0.25, afDuration = 0.75)
	EndIf
	Delete()

EndEvent

; -----