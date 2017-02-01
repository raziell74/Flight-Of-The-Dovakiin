Scriptname ed_reset_flightability_script extends activemagiceffect  
{Toggles the Edda Flight abilities}

; -----  ----- ----- ----- ----- ----- ----- ----- ----- -----

Spell Property ED_FlightAbility_AB Auto

Event OnEffectStart (Actor akTarget, Actor akCaster)
        akTarget.RemoveSpell(ED_FlightAbility_AB)
        akTarget.AddSpell(ED_FlightAbility_AB)
EndEvent