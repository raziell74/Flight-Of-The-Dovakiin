Scriptname _Anton_RealFlying_ME_Maintenance extends activemagiceffect  

GlobalVariable Property _Anton_RealFlying_fJumpHeightMin Auto		; Переменная для хранения текущего игрового значения игровой переменной "fJumpHeightMin", до одевания крыльев
ObjectReference		Player
Float	PressKeyReactionDelay	= 0.01			; Пауза между инициализацией DLL кода и запуском анимации (по большому счёту она уже не нужна)
Int		JumpsCounter 	= 0						; Переменная для переключения режимов Глайдинга и постоянного Полёта
Bool	isFlyingUp 		= False					; Переменная показывает выполняется сейчас подьём или нет (используется для определения: не отпускали ли мы кнопку подьёма, пока работала пауза, синхронизирующая анимацию с движением вверх)
Bool	isForwardPressed = False				; Переменная-флаг нажатой кнопки (для совместимости с контроллерами)
Float	Temp_fJumpHeightMin						; Переменная, для хранения текущей высоты прыжка, пока находимся в меню

; =========================================================================================================

Event OnPlayerLoadGame()
	; Восстанавливаем "высокие" прыжки после save/load
	Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
EndEvent

;/
Event OnMenuOpen(String MenuName)
	; Выключаем высокий прыжок, пока в меню (на случай, если захочется загрузить сохранение без высокого прыжка)
	If MenuName == "Cursor Menu"
		Temp_fJumpHeightMin = Game.GetGameSettingFloat("fJumpHeightMin")
		Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue())
	EndIf
EndEvent

Event OnMenuClose(String MenuName)
	; Включаем высокий прыжок, каким он был
	If MenuName == "Cursor Menu"
		Game.SetGameSettingFloat("fJumpHeightMin", Temp_fJumpHeightMin)
	EndIf
EndEvent
/;

; =========================================================================================================
Event onEffectStart(Actor akTarget, Actor akCaster)
	Player = Game.GetPlayer()
	JumpsCounter = 0
	
	; Будем следить за отжатием кнопки движения вперёд
;ForwardKeyDXScanCode 	= Input.GetMappedKey("Forward")
	RegisterForControl("Forward")
	RegisterForControl("Jump")
	RegisterForControl("Sprint")
	RegisterForControl("Sneak")
;RegisterForMenu("Cursor Menu")
	
	isFlyingUp = False
	isForwardPressed = False

	; Устанавливаем высоту прыжка чуть меньше, чем указано в нашем DLL файле
	_Anton_RealFlying_fJumpHeightMin.SetValue( Game.GetGameSettingFloat("fJumpHeightMin") )
	Game.SetGameSettingFloat("fJumpHeightMin", 300.0)

	; Будем следить за событием прыжка, и за событиями касания земли
	RegisterForAnimationEvent(Player, "FootLeft")
	RegisterForAnimationEvent(Player, "FootRight")
	RegisterForAnimationEvent(Player, "JumpLandEnd")
EndEvent

; ------------------------------------------------
Event OnEffectFinish(Actor akTarget, Actor akCaster)
	; Останавливаем все события, на которые регистрировались
	UnregisterForAnimationEvent(Player, "FootLeft")
	UnregisterForAnimationEvent(Player, "FootRight")
	UnregisterForAnimationEvent(Player, "JumpLandEnd")
	UnregisterForAllControls()
;UnregisterForAllMenus()
	UnregisterForUpdate()

	; Возвращаем игровую переменную в исходное значение
	Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue() )
EndEvent
; =========================================================================================================
Event OnAnimationEvent(ObjectReference akSource, string asEventName)
	; Отключаем "Глайдинг"
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
	; Сбрасываем флаг нажатой кнопки (для совместимости с контроллерами)
	If control == "Forward"
		isForwardPressed = False
		;Check_if_Player_is_on_Mount()
	EndIf
	
	; Отключаем "Глайдинг"
	If control == "Forward" && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0
		UnregisterForUpdate()
		JumpsCounter = 0
		isFlyingUp = False
		Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
		Utility.Wait(PressKeyReactionDelay)
;Debug.SendAnimationEvent(Player,"IdleForceDefaultState")				; MTState		IdleForceDefaultState		IdleStop			
;Utility.Wait(0.1)
		Debug.SendAnimationEvent(Player,"MTState")	; чтобы ГГ не перебирал в воздухе ногами
	EndIf

	; Отключаем подьём
	If control == "Sprint" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		isFlyingUp = False
		Game.SetGameSettingFloat("fJumpHeightMin", 400.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_Forward")
		RegisterForSingleUpdate( Utility.RandomFloat(5.0, 10.0) )
	EndIf
	
	; Отключаем спуск
	If control == "Sneak" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		Game.SetGameSettingFloat("fJumpHeightMin", 400.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_Forward")
		RegisterForSingleUpdate( Utility.RandomFloat(5.0, 10.0) )
	EndIf
EndEvent
; ------------------------------------------------
Event OnControlDown(string control)
	; Устанавливаем флаг нажатой кнопки (для совместимости с контроллерами)
	If control == "Forward"
		isForwardPressed = True
		;Check_if_Player_is_on_Mount()
	EndIf
	
; Обработка исключения, возникающего если слезть с лошади и сразу прыгнуть
;If control == "Jump" && !isForwardPressed && !(Player as Actor).IsOnMount() && Game.GetGameSettingFloat("fJumpHeightMin") < 300.0
	;Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
;EndIf
	
	; Включаем "Глайдинг"
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

	; Включаем подьём
	If control == "Sprint" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		UnregisterForUpdate()
		Debug.SendAnimationEvent(Player,"RealFlying_ForwardUp")
		isFlyingUp = True
		Utility.Wait(1.25)	; Задержка, чтобы дать отработать анимации взмаха крыльями, перед реальным подъёмом ГГ
		If isFlyingUp == True
			Game.SetGameSettingFloat("fJumpHeightMin", 450.0)
		EndIf
	EndIf
	
	; Включаем спуск
	If control == "Sneak" && isForwardPressed && Game.GetGameSettingFloat("fJumpHeightMin") > 325.0 && JumpsCounter > 1
		UnregisterForUpdate()
		Game.SetGameSettingFloat("fJumpHeightMin", 350.0)
		Utility.Wait(PressKeyReactionDelay)
		Debug.SendAnimationEvent(Player,"RealFlying_ForwardDown")
	EndIf
EndEvent

; ------------------------------------------------
Event OnUpdate()
	; Запускаем альтернативную анимацию крыльям (рандомно)
	Debug.SendAnimationEvent(Player,"RealFlying_ForwardAlt")
	RegisterForSingleUpdate( Utility.RandomFloat(1.0, 10.0) )	; 1.0 - єто длительность анимации одиночного взмаха
EndEvent

; ------------------------------------------------
;/
Function Check_if_Player_is_on_Mount()
	If (Player as Actor).IsOnMount()
		Game.SetGameSettingFloat("fJumpHeightMin", _Anton_RealFlying_fJumpHeightMin.GetValue() )	; Возвращаем игровую переменную в исходное значение
	Else
		Game.SetGameSettingFloat("fJumpHeightMin", 300.0)											; Выставляем высокий прыжок снова
	EndIf
EndFunction
/;