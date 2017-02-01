Scriptname ED_FlightAbility_Script extends activemagiceffect
  
import utility
import game
import debug
import Math
import input
import NetImmerse
import sound

GlobalVariable Property ED_FlightAbility_Global_JumpHeightMin_Vanilla Auto
GlobalVariable Property ED_FlightAbility_Global_IsFlying Auto
GlobalVariable Property ED_FlightAbility_Global_FlyingPitch Auto	; 0 = horizontal, 1 = descend, 2 = ascend, 3 = Landing

Actor property Player auto
GlobalVariable property FlyingToggle auto
GlobalVariable property FlyingStamina auto
GlobalVariable property FlyingSpeed auto

GlobalVariable property PlyOrgSp auto

float oldspeed
float speed
float bearing
float elevation
float anglez
float orspeed
bool checkbearing
int fw
int bck
int lft
int rgt
int up
int down
int attackleft
int attackright
int selweapon
int combatSty
int SpSw
int randstrike
int slow
int sprint
int shoutk
int wordsel
float shouttime
float val
float basedmg
bool idleSpell
bool idleDualSw
bool idle2hSw
bool isEq
bool slowM
bool run
bool colcheck
bool IsColliding
bool effectR
bool IsWarned
bool inflight
spell sleft
spell sright
spell sdual
spell[] property SWDmg auto
spell[] property SWDmgH auto
spell[] property SWDmgDW auto
spell property FlyBlock auto
Weapon EqWeap
float mcost
float castingtime
float StaminaDrain

auto State Idle
	Event OnEffectStart(Actor akCaster, Actor akTarget)
		Player = Game.GetPlayer()
		fw = GetMappedKey("Forward")
		bck = getMappedKey("back")
		lft = GetMappedKey("Strafe Left")
		rgt = GetMappedKey("Strafe Right")
		up = GetMappedKey("Jump")
		down = GetMappedKey("Sneak")
		slow = GetMappedKey("Run")
		sprint = GetMappedKey("Sprint")
		selweapon = GetMappedKey("Ready Weapon")
		attackleft = GetMappedKey("Left Attack/Block")
		attackright = GetMappedKey("Right Attack/Block")
		shoutk = GetMappedKey("Shout")
		if FlyingToggle.GetValue() == 0 
			If DSouls.GetValue() == 1 && Player.GetAv("DragonSouls") > 0
				SetIniBool("bDisablePlayerCollision:Havok",true)
				SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",0.5)
				Inflight = true
				PlyOrgSp.SetValue(Player.GetAv("SpeedMult"))
				Player.ModAv("DragonSouls", -1)
				SendAnimationEvent(Player,"eFlyingIdle")
				FlyingToggle.SetValue(1)
			endIf
			If DSouls.GetValue() == 0
				SetIniBool("bDisablePlayerCollision:Havok",true)
				SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",0.5)
				Inflight = true
				PlyOrgSp.SetValue(Player.GetAv("SpeedMult"))
				SendAnimationEvent(Player,"eFlyingIdle")
				FlyingToggle.SetValue(1)
			endif
		endif
		
		if FlyingToggle.GetValue() == 1 && inflight == false
			FlyingToggle.SetValue(0)
			float speedz = PlyOrgSp.GetValue()
			
			wait(1)
			if Player.IsEquipped(effectitem)
				Player.RemoveItem(effectitem)
			EndIf
			if FlyingCollisions.GetValue() > 1
				Player.ForceRemoveRagdollFromWorld()
			EndIf
			SetIniBool("bDisablePlayerCollision:Havok",false)
			SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",3)
			Player.SetAv("SpeedMult",speedz)
			Player.AddItem(DumbItem,1,true)
			Player.RemoveItem(DumbItem,1,true)
		endIf
		if FlyingToggle.GetValue() == 0 && Player.GetAv("DragonSouls") == 0 && DSouls.GetValue() == 1
			Notification("Sorry you dont have dragon souls to spend")
			FlyingToggle.SetValue(0)
			SetIniBool("bDisablePlayerCollision:Havok",false)
			SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",3)
		EndIf
		Wait(1)
		GoToState("SelectIdle")
	EndEvent
	Event OnBeginState()
		while FlyingToggle.GetValue() == 1
			if (IsKeyPressed(Fw) || Player.IsRunning()) && !IsKeyPressed(Sprint)
				GoToState("Forward")
			elseif IsKeyPressed(Sprint)
				GoToState("Sprint")
			EndIf
			if IsKeyPressed(bck)
				GoToState("Back")
			endIf
			if IsKeyPressed(lft)
				GoToState("Left")
			EndIf
			If IsKeyPressed(rgt)
				GoToState("Right")
			EndIf
			If IsKeyPressed(Up)
				GoToState("Up")
			EndIf
			If IsKeyPressed(down)
				GoToState("Down")
			EndIf
			If IsKeyPressed(Slow)
				if SlowM == False
					SlowM = True
					Notification("Speed Reduced By 50%")
					Wait(1)
				ElseIf SlowM == True
					SlowM = False
					Notification("Speed Back To 100%")
					Wait(1)
				EndIf
			endiF
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
			If IsKeyPressed(shoutk) && Player.GetEquippedShout()
				GoToState("Shout")
			endIf
			if (IsKeyPressed(selweapon)) || ((IsKeyPressed(attackright) || IsKeyPressed(attackleft)) && IsEq == false)
				if IsEq == false
					IsEq = true
					Wait(1)
					SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",3)
				elseif IsEq == true
					IsEq = false
					ForceFirstPerson()
					sendAnimationEvent(Player, "UnequipNoAnim")
					Wait(3)
					ForceThirdPerson()
					SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",0.5)
				EndIf
				GoToState("SelectIdle")
			EndIf
			if EqWeap != Player.GetEquippedWeapon()
				GoToState("SelectIdle")
			EndIf
			if FlyingCollisions.GetValue() >= 1 && ColCheck == false
				Player.ForceAddRagdollToWorld()
				ColCheck = true
			elseif FlyingCollisions.GetValue() == 0 && ColCheck == true
				Player.ForceRemoveRagdollFromWorld()
				ColCheck = false
			endIf
			if FlyingEffects.GetValue() != 0 && effectR == false
				Player.AddItem(effectitem,1,true)
				Player.EquipItem(effectitem,true,true)
				effectR = True
			elseif (FlyingEffects.GetValue() == 0 && EffectR == True) || val != FlyingEffects.GetValue()
				Player.UnequipItem(effectitem,true,true)
				Player.RemoveItem(effectitem,1,true)
				effectR = false
			EndIf
			val = FlyingEffects.GetValue()
			IsWarned = false
		EndWhile
	EndEvent

	Event OnEffectFinish(Actor akCaster, Actor akTarget)
		float speedz = PlyOrgSp.GetValue()
		Wait(1)
		Player.SetAv("SpeedMult",speedz)
		Player.AddItem(DumbItem,1,true)
		Player.RemoveItem(DumbItem,1,true)
	endEvent
endState
State SelectIdle
	Event OnBeginState()
		if FlyingToggle.GetValue() == 1
			Wait(0.6)
			EqWeap = Player.GetEquippedWeapon()
			basedmg = EqWeap.GetBaseDamage()
			if basedmg >= 10 && basedmg < 20
				SpSw = 0
			elseif basedmg >= 20 && basedmg < 30
				SpSw = 1
			elseif basedmg >= 30 && basedmg < 40
				SpSw = 2
			elseif basedmg >= 40 && basedmg < 50
				SpSw = 3
			elseif basedmg >= 50 && basedmg < 60
				SpSw = 4
			elseif basedmg >= 60
				SpSw = 5
			endIf
			if Player.IsWeaponDrawn() && IsEq == true
				if EqWeap.GetWeaponType() == 5 || EqWeap.GetWeaponType() == 6
					SendAnimationEvent(Player,"eFlying2hIdle")
					CombatSty = 1
				elseif (EqWeap.GetWeaponType() == 1 || EqWeap.GetWeaponType() == 2 || EqWeap.GetWeaponType() == 3 || EqWeap.GetWeaponType() == 4) && Player.GetEquippedWeapon(true)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					CombatSty = 2
				elseif (EqWeap.GetWeaponType() == 1 || EqWeap.GetWeaponType() == 2 || EqWeap.GetWeaponType() == 3 || EqWeap.GetWeaponType() == 4) && Player.GetEquippedShield()
					SendAnimationEvent(Player,"eFlyingShieldIdle")
					CombatSty = 3
				Else
					CombatSty = 4
					sendAnimationEvent(Player,"eFlyingSpellIdle")
				EndIf
			Else
				CombatSty = 0
				sendAnimationEvent(Player,"eFlyingIdle")
			EndIf
			
			GoToState("Idle")
		EndIf
	EndEvent
EndState
State Forward	
	Event OnBeginState()
		if SlowM == True
			Speed = 200
		Else
			Speed = 400
		EndIf
		UpdateSpeed()
		while (IsKeyPressed(fw) || Player.GetAnimationVariableFloat("Speed") > 0) && FlyingToggle.GetValue() == 1
			bearing = floor(Player.GetAngleZ())
			elevation = Player.GetAngleX()
			if (anglez > bearing + 10 || anglez < bearing - 10 || Elevation > 15 || Elevation < -15) && !IsKeyPressed(lft) && !IsKeyPressed(rgt) && SlowM == False && !IsKeyPressed(Slow)
				if anglez > bearing + 10
					sendAnimationEvent(Player,"eFlyingForwardLeft")
					checkbearing = false
				EndIf
				if anglez < bearing - 10
					SendAnimationEvent(Player,"eFlyingForwardRight")
					checkbearing = false
				EndIf
				if Elevation > 15
					SendAnimationEvent(Player,"eFlyingForwardUp")
				EndIf
				
				if Elevation < -15
					sendAnimationEvent(Player,"eFlyingForwardDown")
				EndIf
			Else
				sendAnimationEvent(Player,"eFlyingForward")
			EndIf
			if IsKeyPressed(lft) && SlowM == False
				SendAnimationEvent(Player,"eFlyingForwardLeft")
			EndIf
			if IsKeyPressed(rgt) && SlowM == False
				SendAnimationEvent(Player,"eFlyingForwardRight")
			EndIf
			if SlowM == True || IsKeyPressed(Slow)
				SendAnimationEvent(Player,"eFlyingForwardSlow")
			EndIf
			if IsKeyPressed(bck)
				GoToState("Back")
			EndIf
			if IsKeyPressed(sprint)
				Speed = -speed
				UpdateSpeed()
				GoToState("Sprint")
			EndIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
			if FlyingStamina.GetValue() != 2 && FlyingStamina.GetValue() != 1 && !IsKeyPressed(Slow) && !IsInMenuMode() && SlowM == false
				ConsumeStamina()
			EndIf
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if checkbearing == False
				anglez = bearing
				checkbearing = True
			EndIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
endState
State Sprint
	Event OnBeginState()
		Speed = 800
		UpdateSpeed()
		while IsKeyPressed(fw) && IsKeyPressed(sprint) && FlyingToggle.GetValue() == 1
			sendAnimationEvent(Player,"eFlyingSprint")
			if FlyingStamina.GetValue() != 2
				ConsumeStamina()
			EndIf
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
EndState

State Back
	Event OnBeginState()
		if SLowM == True
			Speed = 100
		Else
			Speed = 200
		EndIf
		UpdateSpeed()
		while IsKeyPressed(bck) && FlyingToggle.GetValue() == 1
			SendAnimationEvent(Player,"eFlyingBack")
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
endState
State Left
	Event OnBeginState()
		if SLowM == True
			Speed = 100
		Else
			Speed = 200
		EndIf
		UpdateSpeed()
		while IsKeyPressed(lft) && FlyingToggle.GetValue() == 1
			SendAnimationEvent(Player,"eFlyingLeft")
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
			if IsKeyPressed(fw)
				GoToState("Forward")
			endIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
endState
State Right
	Event OnBeginState()
		if SLowM == True
			Speed = 100
		Else
			Speed = 200
		EndIf
		UpdateSpeed()
		while IsKeyPressed(rgt) && FlyingToggle.GetValue() == 1
			SendAnimationEvent(Player,"eFlyingRight")
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
			if IsKeyPressed(fw)
				GoToState("Forward")
			endIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
endState
State Up
	Event OnBeginState()
		if SLowM == True
			Speed = 250
		Else
			Speed = 500
		EndIf
		UpdateSpeed()
		while IsKeyPressed(Up) && FlyingToggle.GetValue() == 1
			float posz = Player.GetPositionZ() + 1000
			Player.TranslateTo(Player.GetPositionX(),Player.GetPositionY(),posz,0,0,0,Speed)
			SendAnimationEvent(Player,"eFlyingUp")
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
	Event OnEndState()
		Player.StopTranslation()
	EndEvent
endState
State Down
	Event OnBeginState()
		if SLowM == True
			Speed = 250
		Else
			Speed = 500
		EndIf
		UpdateSpeed()
		while IsKeyPressed(Down) && FlyingToggle.GetValue() == 1
			float posz = Player.GetPositionZ() - 1000
			Player.TranslateTo(Player.GetPositionX(),Player.GetPositionY(),posz,0,0,0,Speed)
			SendAnimationEvent(Player,"eFlyingDown")
			if FlyingCollisions.GetValue() >= 1
				Collide()
			endIf
			if IsKeyPressed(attackleft) && IsEq == true
				GoToState("LeftAttack")
			EndIf
			if IsKeyPressed(attackright) && IsEq == true
				GoToState("RightAttack")
			EndIf
			if IsKeyPressed(attackright) && IsKeyPressed(attackleft) && IsEq == true
				GoToState("DualAttack")
			EndIf
		EndWhile
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
	Event OnEndState()
		Player.StopTranslation()
	EndEvent
endState
State LeftAttack
	Event OnBeginState()
		sleft = Player.GetEquippedSpell(0)
		mcost = sleft.GetEffectiveMagickaCost(Player)
		while IsKeyPressed(attackleft) && FlyingToggle.GetValue() == 1
			if combatsty == 2 && !Player.IsInKillMove()
				randstrike += 1
				if randstrike > 3
					randstrike = 0
				EndIf
				if randStrike == 1
					sendAnimationEvent(Player,"eFlyingDWAttackFront")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				elseif randStrike == 2
					sendAnimationEvent(Player,"eFlyingDWAttackBack")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				elseif randStrike == 3
					sendAnimationEvent(Player,"eFlyingDWAttackBoth")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				EndIf
			EndIf
			if CombatSty == 3
				sendAnimationEvent(Player, "eFlying1hBlock")
				FlyBlock.Cast(Player)
			EndIf
			if CombatSty == 4 && Player.GetAV("Magicka") > 10
				if castingtime < GetCurrentRealTime()
					if sleft.GetNthEffectMagicEffect(0).GetAssociatedSkill() == "Restoration"
						SendAnimationEvent(Player,"eFlyingHealRight")
					else
						sendAnimationEvent(Player,"eFlyingAttackRight")
					endIf
					sleft.Cast(Player)
					Player.DamageActorValue("Magicka", mcost)
					castingtime = GetCurrentRealTime() + sleft.GetCastTime()
					if IsKeyPressed(attackright)
						GoToState("DualAttack")
					EndIf
				endIf
			EndIf
		EndWhile
		castingtime = 0
		randStrike = 0
		Player.InterruptCast()
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
EndState
State RightAttack
	Event OnBeginState()
		sright = Player.GetEquippedSpell(1)
		mcost = sright.GetEffectiveMagickaCost(Player)
		while IsKeyPressed(attackright) && FlyingToggle.GetValue() == 1
			if combatsty == 1 && !Player.IsInKillMove()
				randstrike += 1
				if randstrike > 3
					randstrike = 0
				EndIf
				if randStrike == 1
					sendAnimationEvent(Player,"eFlying2hAttackLeft")
					Wait(0.5)
					SWDmgH[SpSW].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlying2hIdle")
					ConsumeStamina()
					Wait(1)
				elseif randStrike == 2
					sendAnimationEvent(Player,"eFlying2hAttackRight")
					Wait(0.5)
					SWDmgH[SpSW].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlying2hIdle")
					ConsumeStamina()
					Wait(1)
				elseif randStrike == 3
					sendAnimationEvent(Player,"eFlying2hAttackFront")
					Wait(0.5)
					SWDmg[SpSW].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlying2hIdle")
					ConsumeStamina()
					Wait(1)
				EndIf
			EndIf
			if combatsty == 2 && !Player.IsInKillMove()
				randstrike += 1
				if randstrike > 3
					randstrike = 0
				EndIf
				if randStrike == 1
					sendAnimationEvent(Player,"eFlyingDWAttackFront")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				elseif randStrike == 2
					sendAnimationEvent(Player,"eFlyingDWAttackBack")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				elseif randStrike == 3
					sendAnimationEvent(Player,"eFlyingDWAttackBoth")
					wait(0.5)
					SWDmgDW[SpSW+1].Cast(Player)
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingDualIdle")
					ConsumeStamina()
					wait(1)
				EndIf
			EndIf
			if combatsty == 3 && !Player.IsInKillMove()
				randstrike += 1
				if randstrike > 3
					randstrike = 0
				EndIf
				if randStrike == 1
					sendAnimationEvent(Player,"eFlying1HAttackFront")
					Wait(0.5)
					SendAnimationEvent(Player,"eFlyingShieldIdle")
					SWDmg[SpSW].Cast(Player)
					ConsumeStamina()
					Wait(1)
				elseif randStrike == 2
					sendAnimationEvent(Player,"eFlying1HAttackLeft")
					wait(0.5)
					SendAnimationEvent(Player,"eFlyingShieldIdle")
					SWDmgH[SpSW].Cast(Player)
					ConsumeStamina()
					Wait(1)
				elseif randStrike == 3
					sendAnimationEvent(Player,"eFlying1HAttackRight")
					wait(0.5)
					SendAnimationEvent(Player,"eFlyingShieldIdle")
					SWDmgH[SpSW].Cast(Player)
					ConsumeStamina()
					Wait(1)
				EndIf
			EndIf
			if combatsty == 4 && Player.GetAV("Magicka") > 10
				if castingtime == 0 
					castingtime = GetCurrentRealTime() + (sright.GetCastTime()*2)
				EndIf
				if castingtime < GetCurrentRealTime()
					if sright.GetNthEffectMagicEffect(0).GetAssociatedSkill() == "Restoration"
						SendAnimationEvent(Player,"eFlyingHealLeft")
					else
						sendAnimationEvent(Player,"eFlyingAttackLeft")
					endIf
					sRight.Cast(Player)
					Player.DamageActorValue("Magicka", mcost)
					castingtime = 0
					if IsKeyPressed(attackleft)
						GoToState("DualAttack")
					EndIf
				endIf
			EndIf
		EndWhile
		randStrike = 0
		castingtime = 0
		Player.InterruptCast()
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
EndState
State DualAttack
	Event OnBeginState()
		sright = Player.GetEquippedSpell(1)
		sleft = Player.GetEquippedSpell(0)
		mcost = (sright.GetEffectiveMagickaCost(Player) + sleft.GetEffectiveMagickaCost(Player))/2
		while IsKeyPressed(attackright) && IsKeyPressed(attackleft) && FlyingToggle.GetValue() == 1
			if castingtime < GetCurrentRealTime() && Player.GetAV("Magicka") > 10
				SendAnimationEvent(Player,"eFlyingAttackDual")
				sright.Cast(Player)
				sleft.Cast(Player)
				Player.DamageActorValue("Magicka", mcost)
				castingtime = GetCurrentRealTime() + (sright.GetCastTime() + sleft.GetCastTime())/2
			endIf
		EndWhile
		castingtime = 0
		Player.InterruptCast()
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	EndEvent
EndState
State Shout
	Event OnBeginState()
		EqShout = Player.GetEquippedShout()
		shouttime = GetCurrentRealTime()
		SendAnimationEvent(Player,"eFlyingShoutInhale")
		while IsKeyPressed(shoutk) && wordsel < 2
			if GetCurrentRealTime() < shouttime + 1
				wordsel = 0
			elseif GetCurrentRealTime() < shouttime + 2
				wordsel = 1
			elseif GetCurrentRealTime() < shouttime + 3
				wordsel = 2
			endif
		endWhile
		SendAnimationEvent(Player, "eFlyingShoutExhale")
		EqShout.GetNthSpell(wordsel).Cast(Player)
		wordsel = 0
		Speed = PlyOrgSp.GetValue()
		UpdateSpeed()
		GoToState("SelectIdle")
	endEvent
endState
function ConsumeStamina()

	if FlyingStamina.GetValue() == 1 && Player.GetAnimationVariableFloat("Speed") > 0
		StaminaDrain = (Player.GetBaseAv("Stamina") * 2) / 100
		if IsKeyPressed(sprint)
			Player.DamageActorValue("Stamina",StaminaDrain)
		endif
	elseif FlyingStamina.GetValue() == 0 && Player.GetAnimationVariableFloat("Speed") > 0
		StaminaDrain = (Player.GetBaseAv("Stamina") * 2) / 100
		if IsKeyPressed(sprint)
			StaminaDrain = (Player.GetBaseAv("Stamina") * 4) / 100
		endIf
		Player.DamageActorValue("Stamina",StaminaDrain)
	elseif FlyingStamina.GetValue() == 3 && Player.GetAnimationVariableFloat("Speed") > 0
		StaminaDrain = (Player.GetBaseAv("Stamina") * 4) / 100
		if IsKeyPressed(sprint)
			StaminaDrain = (Player.GetBaseAv("Stamina") * 8) / 100
		endIf
		Player.DamageActorValue("Stamina",StaminaDrain)
	endIf
	if IsKeyPressed(attackleft) || IsKeyPressed(attackRight)
		StaminaDrain = (Player.GetBaseAv("Stamina") * 20) / 100
		Player.DamageActorValue("Stamina",StaminaDrain)
	endIf
	if Player.GetAvPercentage("Stamina") < 0.2 && Player.GetAvPercentage("Stamina") > 0.1 && IsWarned == false
		Notification("Running low on stamina... You are going to die!" + Player.GetAVPercentage("Stamina"))
		IsWarned = true
	elseif Player.GetAvPercentage("Stamina") < 0.1
		FlyingToggle.SetValue(0)
		float speedz = PlyOrgSp.GetValue()
		Wait(1)
		Player.SetAv("SpeedMult",speedz)
		Player.AddItem(DumbItem,1,true)
		Player.RemoveItem(DumbItem,1,true)
		if Player.IsEquipped(effectitem)
			Player.RemoveItem(effectitem)
		EndIf
		if FlyingCollisions.GetValue() == 1
			Player.ForceRemoveRagdollFromWorld()
		EndIf
		SetIniBool("bDisablePlayerCollision:Havok",false)
		SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",3)
	EndIf
EndFunction

function UpdateSpeed()
	if FlyingToggle.GetValue() == 1
		if FlyingSpeed.GetValue() == -3
			speed = speed - ((Speed*75)/100)
		elseif FlyingSpeed.GetValue() == -2
			speed = speed - ((Speed*50)/100)
		elseif FlyingSpeed.GetValue() == -1
			speed = speed - ((Speed*25)/100)
		elseif FlyingSpeed.GetValue() == 0
			speed = speed
		elseif FlyingSpeed.GetValue() == 1
			speed = speed + ((Speed*25)/100)
		elseif FlyingSpeed.GetValue() == 2
			Speed = speed + ((Speed*50)/100)
		elseif FlyingSpeed.GetValue() == 3
			Speed = speed + ((Speed*75)/100)
		endif
	endIf
	Player.SetAv("SpeedMult",speed)
	Player.AddItem(DumbItem,1,true)
	Player.RemoveItem(DumbItem,1,true)
EndFunction
Function Collide()
	
	float posx = Player.GetPositionX()
	float posy = Player.GetPositionY()
	float posz = Player.GetPositionZ()
	float cposx = GetNodePositionX(Player,"NPC COM [COM ]",False)
	float cposy = GetNodePositionY(Player,"NPC COM [COM ]",False)
	float cposZ = GetNodePositionZ(Player,"NPC COM [COM ]",False)
	float Distance = sqrt((pow((posx - cposx),2) + pow((posy - cposy),2) + pow((posz - cposz),2)))
	if FlyingCollisions.GetValue() == 1
		If Distance > 250
			DisablePlayerControls()
			float offx = (cposx - (sin(Player.GetAngleZ()) * 200))
			float offy = (cposy - (cos(Player.GetAngleZ()) * 200))
			Player.SplineTranslateTo(offx,offy,cposz,Player.GetAngleZ(),0,Player.GetAngleX(),10000000,1)
			Wait(1)
			EnablePlayerControls()
		EndIf
	elseif FlyingCollisions.GetValue() == 2
		if Distance > 250
			FlyingToggle.SetValue(0)
			Player.ModAv("SpeedMult",-Player.GetAv("SpeedMult"))
			Player.AddItem(DumbItem,1,true)
			Player.RemoveItem(DumbItem,1,true)
			if Player.IsEquipped(effectitem)
				Player.RemoveItem(effectitem)
			EndIf
			Player.ForceRemoveRagdollFromWorld()
			SetIniBool("bDisablePlayerCollision:Havok",false)
			SetIniFloat("fPlayerCharacterDrawSheatheTimeout:Animation",3)
			Player.PushActorAway(Player,50)
		EndIf
	EndIf	
EndFunction