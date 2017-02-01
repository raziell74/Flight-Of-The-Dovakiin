Scriptname ED_SetGlobal_Script extends activemagiceffect  

; -----

GlobalVariable Property ED_Global Auto
Message Property ED_Message Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	ED_Message.Show()
	ED_Global.SetValue(1.0)

EndEvent

; -----

Event OnEffectFinish(Actor akTarget, Actor akCaster)

	ED_Global.SetValue(0.0)

EndEvent

; -----