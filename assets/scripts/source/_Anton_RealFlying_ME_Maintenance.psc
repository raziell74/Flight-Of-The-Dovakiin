Scriptname _Anton_RealFlying_ME_Maintenance extends activemagiceffect  

GlobalVariable Property _Anton_RealFlying_fJumpHeightMin Auto		; ���������� ��� �������� �������� �������� �������� ������� ���������� "fJumpHeightMin", �� �������� �������
ObjectReference		Player
Float	PressKeyReactionDelay	= 0.01			; ����� ����� �������������� DLL ���� � �������� �������� (�� �������� ����� ��� ��� �� �����)
Int		JumpsCounter 	= 0						; ���������� ��� ������������ ������� ��������� � ����������� �����
Bool	isFlyingUp 		= False					; ���������� ���������� ����������� ������ ������ ��� ��� (������������ ��� �����������: �� ��������� �� �� ������ �������, ���� �������� �����, ���������������� �������� � ��������� �����)
Bool	isForwardPressed = False				; ����������-���� ������� ������ (��� ������������� � �������������)
Float	Temp_fJumpHeightMin						; ����������, ��� �������� ������� ������ ������, ���� ��������� � ����

; =========================================================================================================

Event OnPlayerLoadGame()
	; ��������������� "�������" ������ ����� save/load
	Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
EndEvent

;/
Event OnMenuOpen(String MenuName)
	; ��������� ������� ������, ���� � ���� (�� ������, ���� ��������� ��������� ���������� ��� �������� ������)
	If MenuName == "Cursor Menu"
		Temp_fJumpHeightMin = Game.GetGameSettingFloat("fJumpHeightMin")
		Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue())
	EndIf
EndEvent

Event OnMenuClose(String MenuName)
	; �������� ������� ������, ����� �� ���
	If MenuName == "Cursor Menu"
		Game.SetGameSettingFloat("fJumpHeightMin", Temp_fJumpHeightMin)
	EndIf
EndEvent
/;

; =========================================================================================================
Event onEffectStart(Actor akTarget, Actor akCaster)
	Player = Game.GetPlayer()
	JumpsCounter = 0
	
	; ����� ������� �� �������� ������ �������� �����
;ForwardKeyDXScanCode 	= Input.GetMappedKey("Forward")
	RegisterForControl("Forward")
	RegisterForControl("Jump")
	RegisterForControl("Sprint")
	RegisterForControl("Sneak")
;RegisterForMenu("Cursor Menu")
	
	isFlyingUp = False
	isForwardPressed = False

	; ������������� ������ ������ ���� ������, ��� ������� � ����� DLL �����
	_Anton_RealFlying_fJumpHeightMin.SetValue( Game.GetGameSettingFloat("fJumpHeightMin") )
	Game.SetGameSettingFloat("fJumpHeightMin", 300.0)

	; ����� ������� �� �������� ������, � �� ��������� ������� �����
	RegisterForAnimationEvent(Player, "FootLeft")
	RegisterForAnimationEvent(Player, "FootRight")
	RegisterForAnimationEvent(Player, "JumpLandEnd")
EndEvent

; ------------------------------------------------
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; ������������� ��� �������, �� ������� ����������������
	UnregisterForAnimationEvent(Player, "FootLeft")
	UnregisterForAnimationEvent(Player, "FootRight")
	UnregisterForAnimationEvent(Player, "JumpLandEnd")
	UnregisterForAllControls()
;UnregisterForAllMenus()
	UnregisterForUpdate()

	; ���������� ������� ���������� � �������� ��������
	Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue() )
EndEvent
; =========================================================================================================
Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	; ��������� "��������"
	If (asEventName == "FootLeft" || asEventName == "FootRight" || asEventName == "JumpLandEnd" ) && (Game.GetGameSettingFloat("fJumpHeightMin") > 325.0) && (akSource == Player)
		UnregisterForUpdate()
		JumpsCounter = 0
		isFlyingUp = False
		Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
		Debug.SendAnimationEvent(Player,"SneakStop")
		Utility.Wait(0.1)
;Player.SetAnimationVariableInt("iState_NPCSneaking", 0)
;Player.SetAnimationVariableInt("iIsInSneak", 0)
;Player.SetAnimationVariableInt("iIsSneaking", 0)
;Player.SetAnimationVariableInt("iState_NPCDefault", 1)
		Debug.SendAnimationEvent(Player,"MTState")
	EndIf
EndEvent
; =========================================================================================================
Event OnControlUp(string control, float HoldTime)
	; ���������� ���� ������� ������ (��� ������������� � �������������)
	If control == "Forward"
		isForwardPressed = False
		;Check_if_Player_is_on_Mount()
	EndIf
	
	; ��������� "��������"
	If control == "Forward" && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0
		UnregisterForUpdate()
		JumpsCounter = 0
		isFlyingUp = False
		Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
		Utility.Wait(PressKeyReactionDelay)
;Debug.SendAnimationEvent(Player,"IdleForceDefaultState")				; MTState		IdleForceDefaultState		IdleStop			
;Utility.Wait(0.1)
		Debug.SendAnimationEvent(Player,"MTState")	; ����� �� �� ��������� � ������� ������
	EndIf

	; ��������� ������
	If control == "Sprint" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		isFlyingUp = False
		Game.SetGameSettingFloat("fJumpHeightMin", 400.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_Forward")
		RegisterForSingleUpdate( Utility.RandomFloat(5.0, 10.0) )
	EndIf
	
	; ��������� �����
	If control == "Sneak" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		Game.SetGameSettingFloat("fJumpHeightMin", 400.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_Forward")
		RegisterForSingleUpdate( Utility.RandomFloat(5.0, 10.0) )
	EndIf
EndEvent
; ------------------------------------------------
Event OnControlDown(string control)
	; ������������� ���� ������� ������ (��� ������������� � �������������)
	If control == "Forward"
		isForwardPressed = True
		;Check_if_Player_is_on_Mount()
	EndIf
	
; ��������� ����������, ������������ ���� ������ � ������ � ����� ��������
;If control == "Jump" && !isForwardPressed && !(Player as Actor).IsOnMount() && Game.GetGameSettingFloat("fJumpHeightMin") < 300.0
	;Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
;EndIf
	
	; �������� "��������"
	If control == "Jump" && isForwardPressed && !(Player as Actor).IsOnMount()
		UnregisterForUpdate()
		Game.SetGameSettingFloat("fJumpHeightMin", 400.0)
		Utility.Wait(PressKeyReactionDelay)
		If JumpsCounter > 0 
			Debug.SendAnimationEvent(Player,"RealFlying_Forward")	; eFlyingForward		SpectatorClap		SwimForwardFast			SwimStart
			RegisterForSingleUpdate( Utility.RandomFloat(5.0, 10.0) )
		EndIf
		JumpsCounter += 1
	EndIf

	; �������� ������
	If control == "Sprint" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		UnregisterForUpdate()
		Debug.SendAnimationEvent(Player,"RealFlying_ForwardUp")
		isFlyingUp = True
		Utility.Wait(1.25)	; ��������, ����� ���� ���������� �������� ������ ��������, ����� �������� �������� ��
		If isFlyingUp == True
			Game.SetGameSettingFloat("fJumpHeightMin", 450.0)
		EndIf
	EndIf
	
	; �������� �����
	If control == "Sneak" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		UnregisterForUpdate()
		Game.SetGameSettingFloat("fJumpHeightMin", 350.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_ForwardDown")
	EndIf
EndEvent

; ------------------------------------------------
Event OnUpdate()
	; ��������� �������������� �������� ������� (��������)
	Debug.SendAnimationEvent(Player,"RealFlying_ForwardAlt")
	RegisterForSingleUpdate( Utility.RandomFloat(1.0, 10.0) )	; 1.0 - ��� ������������ �������� ���������� ������
EndEvent

; ------------------------------------------------
;/
Function Check_if_Player_is_on_Mount()
	If (Player as Actor).IsOnMount()
		Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue() )	; ���������� ������� ���������� � �������� ��������
	Else
		Game.SetGameSettingFloat("fJumpHeightMin", 300.0)											; ���������� ������� ������ �����
	EndIf
EndFunction
/;