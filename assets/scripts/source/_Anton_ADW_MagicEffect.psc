Scriptname _Anton_ADW_MagicEffect extends activemagiceffect  

Spell Property _Anton_AnimatedDragonWings_Spell Auto
GlobalVariable Property _Anton_AnimatedDragonWings_JumpHeight Auto

Event onEffectStart(Actor akTarget, Actor akCaster)

	; _Anton_AnimatedDragonWings_JumpHeight.SetValue( Game.GetGameSettingFloat("fJumpHeightMin") )
	; Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
	Game.GetPlayer().AddSpell( _Anton_AnimatedDragonWings_Spell, False)
	
EndEvent


Event OnCellLoad()

	;_Anton_AnimatedDragonWings_JumpHeight.SetValue( Game.GetGameSettingFloat("fJumpHeightMin") )
	; Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
	Game.GetPlayer().AddSpell( _Anton_AnimatedDragonWings_Spell, False)
	
EndEvent


Event OnPlayerLoadGame()

	; _Anton_AnimatedDragonWings_JumpHeight.SetValue( Game.GetGameSettingFloat("fJumpHeightMin") )
	; Game.SetGameSettingFloat("fJumpHeightMin", 300.0)
	Game.GetPlayer().AddSpell( _Anton_AnimatedDragonWings_Spell, False)
	
EndEvent
