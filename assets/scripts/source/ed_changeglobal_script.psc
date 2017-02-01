Scriptname ED_ChangeGlobal_Script extends activemagiceffect  

; -----

GlobalVariable Property ED_Global Auto
GlobalVariable Property ED_GlobalLow Auto
GlobalVariable Property ED_GlobalHigh Auto
Message Property ED_Message Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	ED_Message.Show()
	ED_Global.SetValue(ED_GlobalHigh.GetValue())

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	ED_Global.SetValue(ED_GlobalLow.GetValue())

EndEvent

; -----