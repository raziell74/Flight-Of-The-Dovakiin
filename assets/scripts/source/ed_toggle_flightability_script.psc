Scriptname ed_toggle_flightability_script extends activemagiceffect  
{Toggles the Edda Flight abilities}

; -----  ----- ----- ----- ----- ----- ----- ----- ----- -----

Spell Property ED_FlightAbility_Grounded Auto

Event OnEffectStart (Actor akTarget, Actor akCaster)
        If akTarget.HasSpell(ED_FlightAbility_Grounded) == false
                akTarget.AddSpell(ED_FlightAbility_Grounded, false)
        Else
                akTarget.RemoveSpell(ED_FlightAbility_Grounded)
        EndIf
EndEvent