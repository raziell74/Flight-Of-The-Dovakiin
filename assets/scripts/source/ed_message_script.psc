Scriptname ED_Message_Script extends activemagiceffect  

; -----

Message Property ED_Message Auto

; -----

Event OnEffectStart(Actor akTarget, Actor akCaster)

	ED_Message.Show()

EndEvent

; -----