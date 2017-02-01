Scriptname ED_FlightAbility_Script extends activemagiceffect  

; -----

import FlightPhysicsPluginScript

Actor Property PlayerRef Auto
GlobalVariable Property ED_FlightAbility_Global_JumpHeightMin_Vanilla Auto
GlobalVariable Property ED_FlightAbility_Global_IsFlying Auto
GlobalVariable Property ED_FlightAbility_Global_FlyingPitch Auto	; 0 = horizontal, 1 = descend, 2 = ascend, 3 = Landing

Float Property ED_SprintFlapDelay = 0.5 Auto Hidden
Float Property ED_FlapDelayMin = 5.0 Auto Hidden
Float Property ED_FlapDelayMax = 10.0 Auto Hidden
Float Property ED_KeyPressDelay = 0.01 Auto Hidden
Float Property ED_ClimbDelay = 1.25 Auto Hidden

; Jump heights do not actually have anything to do with jump height. They are just a value used for setting the SKSE plugin into different states
Float Property ED_JumpTakeoff = 500.0 Auto Hidden ; Fly up wards using LiftUp_Speed
Float Property ED_JumpHeightAscending = 450.0 Auto Hidden ; Fly up wards using LiftUp_Speed
Float Property ED_JumpHeightHover = 420.0 Auto Hidden ; Keeps actor in place
Float Property ED_JumpHeightHorizontal = 400.0 Auto Hidden ; Fly forward using Forward_Speed
Float Property ED_JumpHeightBackward = 390.0 Auto Hidden ; Fly backwards using Forward_Speed Divided by 2
Float Property ED_JumpHeightHorizontalSprint = 410.0 Auto Hidden ; Fly forward using Sprint_Speed
Float Property ED_JumpHeightDescending = 350.0 Auto Hidden ; Fly up wards using LiftUp_Speed

Float Property ED_JumpHeightDefault = 300.0 Auto Hidden

String Property ED_FlightState = "NotFlying" Auto Hidden

Message Property ED_FlightAbility_Message_NoFlyZoneZ Auto
GlobalVariable Property ED_FlightAbility_Global_NoFlyZoneZ Auto

Message Property ED_FlightAbility_Message_Help_HowToFly Auto
Message Property ED_FlightAbility_Message_Help_HowToDescend Auto
Message Property ED_FlightAbility_Message_Help_HowToClimb Auto

Float Property ED_ControlLockoutAfterLanding = 0.25 Auto Hidden
Float Property ED_ControlLockoutAfterTakeoff = 1.0 Auto Hidden
Float Property ED_ControlLockoutAfterAttitudeChange = 0.25 Auto Hidden

Float Property ED_LiftoffDuration = 0.5 Auto Hidden

GlobalVariable Property ED_FlightAbility_Global_Toggle_NoStaminaAscend Auto
GlobalVariable Property ED_FlightAbility_Global_Toggle_CanClimb Auto
GlobalVariable Property ED_FlightAbility_Global_StaminaForStartAscend Auto

Message Property ED_FlightAbility_Message_Debug Auto

Spell Property ED_FlightAbility_Spell_Ab Auto

Sound Property ORD_HeightCap Auto

; -----

Int JumpsCounter = 0
Float OldJumpHeight = 0.0
Bool JumpBlocked = false
Bool CanUseAttitudeControls = false
Bool IsCurrentlyTakingOff = false
Bool IsIgnoringTakeoff = false
Bool IsStationaryAfterLanding = false

; -----

Event OnPlayerLoadGame()

	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)
	If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
		RegisterForModEvent("NoFlyZoneZ", "OnEnteringNoFlyZoneZ")
		RegisterForModEvent("UnableToClimb", "OnUnableToClimb")
	EndIf

EndEvent

; -----

Event OnMenuOpen(String akMenuName)

	If akMenuName == "Cursor Menu"
		OldJumpHeight = Game.GetGameSettingFloat("fJumpHeightMin")
		Game.SetGameSettingFloat("fJumpHeightMin", 200)
	EndIf

EndEvent

; -----

Event OnMenuClose(String akMenuName)

	If akMenuName == "Cursor Menu"
		Game.SetGameSettingFloat("fJumpHeightMin", OldJumpHeight)
	EndIf

EndEvent

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	RegisterForControl("Forward")
	RegisterForControl("Jump")
	RegisterForControl("Sprint")
	RegisterForControl("Back")
	RegisterForControl("Sneak")

	ED_FlightAbility_Global_JumpHeightMin_Vanilla.SetValue(200)
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)

	RegisterForAnimationEvent(PlayerRef, "FootLeft")
	RegisterForAnimationEvent(PlayerRef, "FootRight")
	RegisterForAnimationEvent(PlayerRef, "JumpLandEnd")
	RegisterForAnimationEvent(PlayerRef, "JumpDown")

	ED_FlightAbility_Message_Help_HowToFly.ShowAsHelpMessage("HowToFly", 10, 999, 1)

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	Game.SetGameSettingFloat("fJumpHeightMin", 200)
	ED_FlightAbility_Global_IsFlying.SetValue(0.0)
	ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)

EndEvent

; -----

Event OnAnimationEvent(ObjectReference akSource, String asEventName)

	If (asEventName == "FootLeft" || asEventName == "FootRight" || asEventName == "JumpLandEnd" || asEventName == "JumpDown") && akSource == PlayerRef
		; pilot touched the ground
		IsStationaryAfterLanding = false

		If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
			; pilot touched the ground while flying (or rather without landing properly) so shut off engine and drop to the ground - RUN HIT
			
			; stop flapping
			UnregisterForUpdate()

			; set flags
			ED_FlightAbility_Global_IsFlying.SetValue(0.0)
			ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)

			; send falling animation event
			Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)
			Debug.SendAnimationEvent(PlayerRef,"MTState")
			
			; check if we are in sneak mode, if so stop sneaking
			if PlayerRef.IsSneaking() == true
				PlayerRef.StartSneaking()
			EndIf

			; after the lockout period, set flags
			Utility.Wait(ED_ControlLockoutAfterLanding)
			Game.EnablePlayerControls()
			Game.EnableFastTravel(true)
			JumpBlocked = false

			; allows taking off again
			IsIgnoringTakeoff = false
			
			ED_FlightState = "NotFlying"
		Else
			; stop flapping
			UnregisterForUpdate()
			
			; set flags
			ED_FlightAbility_Global_IsFlying.SetValue(0.0)
			ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)
			
			; send falling animation event
			Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)
			Debug.SendAnimationEvent(PlayerRef,"MTState")
			
			; allows taking off again
			IsIgnoringTakeoff = false
			
			ED_FlightState = "NotFlying"
		EndIf

	EndIf

EndEvent

; -----

Event OnControlDown(String asControl)
	If ED_FlightAbility_Global_FlyingPitch.GetValue() == 3.0
		CancelFlight()
		return
	EndIf

	If IsCurrentlyTakingOff == false && PlayerRef.isWeaponDrawn() == false && PlayerRef.isInInterior() == false
		; we only accept control inputs if moving forward and not currently taking off

		If asControl == "Jump" && Input.IsKeyPressed(Input.GetMappedKey("Back")) == false && JumpBlocked == false
			; pilot pressed jump and is not moving backwards

			If ED_FlightAbility_Global_IsFlying.GetValue() == 0.0 && IsIgnoringTakeoff == false && IsStationaryAfterLanding == false && Input.IsKeyPressed(Input.GetMappedKey("Forward")) == true
				; pilot pressed jump while not flying so start takeoff procedure
				TakeOff()

				If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && ED_FlightAbility_Global_FlyingPitch.GetValue() == 0.0
					; we are still flying horizontally and going forward

					If Input.IsKeyPressed(Input.GetMappedKey("Sneak")) || Input.IsKeyPressed(Input.GetMappedKey("Back"))
						; pilot pressed jump or back during takeoff so immediately descend
						Descend()
					Else
						; pilot did not press jump or back so continue horizontal flight
						Forward()
					EndIf

					; configure further flight
					RegisterForModEvent("NoFlyZoneZ", "OnEnteringNoFlyZoneZ")
					RegisterForModEvent("UnableToClimb", "OnUnableToClimb")

					; display help messages
					If ED_FlightAbility_Global_Toggle_CanClimb.GetValue() == 1.0
						ED_FlightAbility_Message_Help_HowToClimb.ShowAsHelpMessage("HowToClimb", 6, 999, 1)
					Else
						ED_FlightAbility_Message_Help_HowToDescend.ShowAsHelpMessage("HowToDescend", 6, 999, 1)
					EndIf

				EndIf
				
				IsCurrentlyTakingOff = false

			ElseIf ED_FlightAbility_Global_FlyingPitch.GetValue() == 0.0 && CanUseAttitudeControls == true
				; pilot pressed jump while flying horizontally so initiate ascension
				Ascend()
			EndIf
		ElseIf asControl == "Back" && ED_FlightAbility_Global_FlyingPitch.GetValue() == 0.0 && CanUseAttitudeControls == true
			; pilot pressed back while flying horizontally so initiate a descent
			Descend()
		EndIf

		If  ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && asControl == "Sneak" && IsCurrentlyTakingOff == false && ED_FlightAbility_Global_FlyingPitch.GetValue() == 0.0 && CanUseAttitudeControls == true
			; pilot pressed sprint while flying horizontally so initiate descend
			Descend()
		EndIf
		
		If  ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && asControl == "Sprint" && Input.IsKeyPressed(Input.GetMappedKey("Forward")) == true && IsCurrentlyTakingOff == false && ED_FlightAbility_Global_FlyingPitch.GetValue() == 0.0 && CanUseAttitudeControls == true
			; pilot pressed sprint while flying horizontally so fly faster
			Sprint()
		EndIf
		
		If  Input.IsKeyPressed(Input.GetMappedKey("Forward")) && ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && ED_FlightState == "Hovering"
			; pilot pressed 
			Forward()
		EndIf
		
		; Prevents default control for descending to enter player into sneaking mode
		Utility.Wait(0.75)
		if PlayerRef.IsSneaking() == true && ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
			PlayerRef.StartSneaking()
		EndIf
	EndIf

EndEvent

; -----

Event OnControlUp(String asControl, Float akHoldTime)
	If ED_FlightAbility_Global_FlyingPitch.GetValue() == 3.0
		CancelFlight()
		return
	EndIf

	If asControl == "Forward" && ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
		; pilot stoped moving forward initiate hover
		Hover()
	EndIf
	
	If asControl == "Sprint" && ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
		; pilot stoped sprinting initiate normal speed
		Forward()
	EndIf

	If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0 && (asControl == "Jump" || asControl == "Sneak" || asControl == "Back") && Input.IsKeyPressed(Input.GetMappedKey("Jump")) == false && Input.IsKeyPressed(Input.GetMappedKey("Sneak")) == false && Input.IsKeyPressed(Input.GetMappedKey("Back")) == false && ED_FlightAbility_Global_FlyingPitch.GetValue() != 0.0
		; pilot released jump or sprint while flying so revert to horizontal flight
		
		; if still changing attitude, spin until attitude change ends
		While CanUseAttitudeControls == false
			Utility.Wait(0.1)
		EndWhile

		; set flags
		ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)

		If ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
			; we are still flying
			If Input.IsKeyPressed(Input.GetMappedKey("Forward")) == true
				; We are still flying forward
				Forward()
			Else
				; We are not flying forward to just hover
				Hover()
			EndIf
		EndIf

	EndIf
	
	Utility.Wait(0.75)
	; Prevents default control for descending to enter player into sneaking mode
	if PlayerRef.IsSneaking() == true && ED_FlightAbility_Global_IsFlying.GetValue() == 1.0
		PlayerRef.StartSneaking()
	EndIf

EndEvent

; -----

Event OnUpdate()
	If ED_FlightAbility_Global_FlyingPitch.GetValue() == 3.0
		CancelFlight()
		return
	EndIf
	
	; flap
	Debug.SendAnimationEvent(PlayerRef,"RealFlying_ForwardAlt")
	
	If ED_FlightState == "Sprinting"
		RegisterForSingleUpdate(Utility.RandomFloat((ED_FlapDelayMin/2), (ED_FlapDelayMax/2)))
	Else
		RegisterForSingleUpdate(Utility.RandomFloat(ED_FlapDelayMin, ED_FlapDelayMax))
	EndIf
EndEvent

; -----

Event OnEnteringNoFlyZoneZ(string eventName, string strArg, float numArg, Form sender)

	If ED_FlightAbility_Global_FlyingPitch.GetValue() == 2.0
		; revert to horizontal flight instantly
		Forward()

		; tell player why they cannot climb
		ED_FlightAbility_Message_NoFlyZoneZ.Show()
	EndIf

EndEvent

; -----

Event OnUnableToClimb(string eventName, string strArg, float numArg, Form sender)

	If ED_FlightAbility_Global_FlyingPitch.GetValue() == 2.0
		; revert to horizontal flight instantly		
		Forward()
		
		; sound
		ORD_HeightCap.Play(PlayerRef)
	EndIf

EndEvent

; -----

Event OnRaceSwitchComplete()

	PlayerRef.RemoveSpell(ED_FlightAbility_Spell_Ab)
	Utility.Wait(1.0)
	PlayerRef.AddSpell(ED_FlightAbility_Spell_Ab)

EndEvent

; ----- Flight States

Function TakeOff()
	ED_FlightState = "TakingOff"
	Debug.Notification(ED_FlightState)
	
	ED_FlightAbility_Global_IsFlying.SetValue(1.0)
	UnregisterForUpdate()
	IsIgnoringTakeoff = true
	IsCurrentlyTakingOff = true
	Game.ForceThirdPerson()
	Game.DisablePlayerControls(false, true, true, false, false, false, true, false, 0)
	Game.EnableFastTravel(false)
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightHorizontal)

	; wait during takeoff
	Utility.Wait(ED_ControlLockoutAfterTakeoff)
	IsCurrentlyTakingOff = false
EndFunction

Function Hover()
	ED_FlightState = "Hovering"
	Debug.Notification(ED_FlightState)

	; set flags
	CanUseAttitudeControls = false
	ED_FlightAbility_Global_FlyingPitch.SetValue(2.0)

	; send descending flight animation event
	Debug.SendAnimationEvent(PlayerRef,"eFlyingIdle")

	; start hovering
	Utility.Wait(ED_KeyPressDelay)
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightHover)

	; set flags
	Utility.Wait(ED_ControlLockoutAfterAttitudeChange)
	CanUseAttitudeControls = true
	
	; register for flap
	RegisterForSingleUpdate(Utility.RandomFloat(ED_FlapDelayMin, ED_FlapDelayMax))
EndFunction

Function Forward()
	ED_FlightState = "Flying Forward"
	Debug.Notification(ED_FlightState)
	
	; send horizontal flight animation event
	Debug.SendAnimationEvent(PlayerRef,"eFlyingForwardSlow")
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightHorizontal)

	; set flags
	CanUseAttitudeControls = true
	ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)

	; register for flap
	RegisterForSingleUpdate(Utility.RandomFloat(ED_FlapDelayMin, ED_FlapDelayMax))
EndFunction

Function Sprint()
	ED_FlightState = "Sprinting"
	Debug.Notification(ED_FlightState)
	
	; stop flapping
	UnregisterForUpdate()
	
	; send horizontal flight animation event
	Debug.SendAnimationEvent(PlayerRef,"eFlyingForward")
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightHorizontalSprint)

	; set flags
	CanUseAttitudeControls = true
	ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)

	; register for faster flapping
	RegisterForSingleUpdate(Utility.RandomFloat((ED_FlapDelayMin/2), (ED_FlapDelayMax/2)))
EndFunction

Function Descend()
	ED_FlightState = "Descending"
    Debug.Notification(ED_FlightState)
	
	; stop flapping
	UnregisterForUpdate()

	; set flags
	CanUseAttitudeControls = false
	ED_FlightAbility_Global_FlyingPitch.SetValue(1.0)

	; send descending flight animation event
	Debug.SendAnimationEvent(PlayerRef,"eFlyingForwardUp")

	; start descending after a delay
	Utility.Wait(ED_KeyPressDelay)
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDescending)

	; set flags
	Utility.Wait(ED_ControlLockoutAfterAttitudeChange)
	CanUseAttitudeControls = true
EndFunction

Function Ascend()
	; If ED_FlightAbility_Global_Toggle_CanClimb.GetValue() == 1.0 && (ED_FlightAbility_Global_Toggle_NoStaminaAscend.GetValue() == 1.0 || PlayerRef.GetAV("Stamina") >= ED_FlightAbility_Global_StaminaForStartAscend.GetValue())
		ED_FlightState = "Ascending"
		Debug.Notification(ED_FlightState)
		
		If PlayerRef.GetPositionZ() < ED_FlightAbility_Global_NoFlyZoneZ.GetValue()
			; stop flapping
			UnregisterForUpdate()
	
			; set flags
			CanUseAttitudeControls = false
			ED_FlightAbility_Global_FlyingPitch.SetValue(2.0)
	
			; send ascending flight animation event
			Debug.SendAnimationEvent(PlayerRef,"eFlyingForwardDown")
			
			; start ascending after a delay
			Utility.Wait(ED_ClimbDelay)
			Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightAscending)
			ED_FlightAbility_Message_Debug.Show()
	
			; set flags
			Utility.Wait(ED_ControlLockoutAfterAttitudeChange)
			CanUseAttitudeControls = true
		Else
			; tell player that they are in a no fly zone
			ED_FlightAbility_Message_NoFlyZoneZ.Show()
		EndIf
	; EndIf
EndFunction

Function Backward()
	ED_FlightState = "FlyingBackwards"
EndFunction

Function CancelFlight()
	ED_FlightState = "NotFlying"
	Debug.Notification("Flight Cancelled")
	
	; release all active modifier keys
	Input.ReleaseKey(Input.GetMappedKey("Sprint"))
	Input.ReleaseKey(Input.GetMappedKey("Sneak"))
	Input.ReleaseKey(Input.GetMappedKey("Jump"))
	
	; stop flapping
	UnregisterForUpdate()

	; if still taking off, spin until takeoff ends
	While IsCurrentlyTakingOff == true
		Utility.Wait(0.2)
	EndWhile

	; set flags
	JumpBlocked = true
	ED_FlightAbility_Global_FlyingPitch.SetValue(0.0)
	ED_FlightAbility_Global_IsFlying.SetValue(0.0)

	; send falling animation event
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)	; no longer needed?
	Debug.SendAnimationEvent(PlayerRef,"MTState")
	
	; check if we are in sneak mode, if so stop sneaking
	if PlayerRef.IsSneaking() == true
		PlayerRef.StartSneaking()
	EndIf
	
	; Do a tiny jump to break out of the flying animation
	Game.SetGameSettingFloat("fJumpHeightMin", 5)
	Input.TapKey(Input.GetMappedKey("Jump"))
	
	; hold forward to break out of this weird state where you hover in the air without flying
	Utility.Wait(ED_KeyPressDelay)
	Game.SetGameSettingFloat("fJumpHeightMin", ED_JumpHeightDefault)	; no longer needed?
	Input.HoldKey(Input.GetMappedKey("Forward"))

	; after the lockout period, set flags
	Utility.Wait(ED_ControlLockoutAfterLanding)
	Game.EnablePlayerControls()
	Game.EnableFastTravel(true)

	; release forward
	Input.ReleaseKey(Input.GetMappedKey("Forward"))
	IsStationaryAfterLanding = true
	JumpBlocked = false
EndFunction

; -----