/*
 * integratedSprint.d
 * Source: https://forum.worldofplayers.de/forum/threads/?p=26441848
 *
 * Add sprint integrated into the internal breath (diving) system
 *
 * - Requires Ikarus 1.2.2, LeGo 2.6.0 (FrameFunctions), breath.d
 * - Compatible with Gothic 1 and Gothic 2
 *
 * Instructions
 * - Initialize from Init_Global with
 *     IntegratedSprint_Init();
 * - Set the variable IntegratedSprint_DurationMS from the scripts. This allows to dynamically change the duration. E.g.
 *     IntegratedSprint_DurationMS = 15000; // 15 seconds of total sprint
 *
 *
 * Note: All symbols are prefixed with "Ninja_Stamina_" to not interfere with the mod. Remove if using somewhere else!
 */

// In this patch, these symbols are defined elsewhere with different names
// const string IntegratedSprint_Mds = "HUMANS_SPRINT_CLEAN.MDS"; // MDS overlay name
// var   int    IntegratedSprint_DurationMS;                      // Duration of sprint in milliseconds: Set in scripts

/*
 * Check if an MDS overlay of given name is active
 */
func int Wld_GetHour()
{
    var int h;
    h = divf(MEM_WorldTimer.worldTime, mkf(4167));
    h = divf(h, mkf(60));
    return truncf(h);
};

func int Wld_GetMin()
{
    var int m;
    m = divf(MEM_WorldTimer.worldTime, mkf(4167));
    m = truncf(m);
    m = m%60;
    return m;
};
func int Ninja_Stamina_Mdl_OverlayMdsIsActive(var C_Npc slf, var string mdsName) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    mdsName = STR_Upper(mdsName);

    repeat(i, npc.activeOverlays_numInArray); var int i;
        if (Hlp_StrCmp(mdsName, MEM_ReadStringArray(npc.activeOverlays_array, i))) {
            return TRUE;
        };
    end;

    return FALSE;
};

/*
 * Check if an NPC is running
 */
func int Ninja_Stamina_Npc_IsRunning(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning = 7004672; //0x6AE200

        const int call = 0;
        if (CALL_Begin(call)) {
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning);
            call = CALL_End();
        };

        var int ret;
        return +ret;

    } else {
        // Gothic 1 does not have the function oCAniCtrl_Human::IsRunning. Re-implement it here
        // These lines require at lease Ikarus 1.2.2

        var oCAniCtrl_Human ai; ai = _^(aiPtr);
        var int modelPtr; modelPtr = ai._zCAIPlayer_model;

        if (!modelPtr) {
            return FALSE;
        };

        // Modified from auxillary.d in GothicFreeAim
        // https://github.com/szapp/GothicFreeAim/blob/v1.2.0/_work/data/Scripts/Content/GFA/_intern/auxiliary.d#L169
        const int zCModel_numActAnis_offset = 52; //0x34
        const int zCModel_actAniList_offset = 56; //0x37
        const int zCModelAni_aniID_offset   = 76; //0x4C
        var int actAniOffset; actAniOffset = modelPtr+zCModel_actAniList_offset;
        repeat(i, MEM_ReadInt(modelPtr+zCModel_numActAnis_offset)); var int i;
            var int aniID; aniID = MEM_ReadInt(MEM_ReadInt(MEM_ReadInt(actAniOffset))+zCModelAni_aniID_offset);
            if (aniID == MEM_ReadStatArr(ai.s_runl,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.s_runr,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_run_2_runl,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runl_2_run,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runl_2_runr, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runr_2_runl, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_runr_2_run,  npc.fmode)) {
                return TRUE;
            };
            actAniOffset += 4;
        end;
    };
    return FALSE;
};
func int Ninja_Stamina_Npc_IsSneak(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning = 7004672; //0x6AE200

        const int call = 0;
        if (CALL_Begin(call)) {
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning);
            call = CALL_End();
        };

        var int ret;
        return +ret;

    } else {
        // Gothic 1 does not have the function oCAniCtrl_Human::IsRunning. Re-implement it here
        // These lines require at lease Ikarus 1.2.2

        var oCAniCtrl_Human ai; ai = _^(aiPtr);
        var int modelPtr; modelPtr = ai._zCAIPlayer_model;

        if (!modelPtr) {
            return FALSE;
        };

        // Modified from auxillary.d in GothicFreeAim
        // https://github.com/szapp/GothicFreeAim/blob/v1.2.0/_work/data/Scripts/Content/GFA/_intern/auxiliary.d#L169
        const int zCModel_numActAnis_offset = 52; //0x34
        const int zCModel_actAniList_offset = 56; //0x37
        const int zCModelAni_aniID_offset   = 76; //0x4C
        var int actAniOffset; actAniOffset = modelPtr+zCModel_actAniList_offset;
        repeat(i, MEM_ReadInt(modelPtr+zCModel_numActAnis_offset)); var int i;
            var int aniID; aniID = MEM_ReadInt(MEM_ReadInt(MEM_ReadInt(actAniOffset))+zCModelAni_aniID_offset);
            if (aniID == MEM_ReadStatArr(ai.t_Sneak_2_SneakL,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.s_SneakL,        npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_SneakL_2_Sneak,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_SneakR_2_Sneak,  npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_Sneak_2_SneakBL, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.s_SneakBL, npc.fmode))
            || (aniID == MEM_ReadStatArr(ai.t_SneakBL_2_Sneak,  npc.fmode))
			|| (aniID == MEM_ReadStatArr(ai.t_SneakBR_2_Sneak,  npc.fmode))
			|| (aniID == MEM_ReadStatArr(ai.s_Sneak,  npc.fmode))
			|| (aniID == MEM_ReadStatArr(ai.t_SneakStrafeL,  npc.fmode))
			|| (aniID == MEM_ReadStatArr(ai.t_SneakStrafeR,  npc.fmode)) {
                return TRUE;
            };
            actAniOffset += 4;
        end;
    };
    return FALSE;
};
func int Ninja_Stamina_Npc_IsSwim(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning = 7004672; //0x6AE200

        const int call = 0;
        if (CALL_Begin(call)) {
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning);
            call = CALL_End();
        };

        var int ret;
        return +ret;

    } else {
        // Gothic 1 does not have the function oCAniCtrl_Human::IsRunning. Re-implement it here
        // These lines require at lease Ikarus 1.2.2

        var oCAniCtrl_Human ai; ai = _^(aiPtr);
        var int modelPtr; modelPtr = ai._zCAIPlayer_model;

        if (!modelPtr) {
            return FALSE;
        };

        // Modified from auxillary.d in GothicFreeAim
        // https://github.com/szapp/GothicFreeAim/blob/v1.2.0/_work/data/Scripts/Content/GFA/_intern/auxiliary.d#L169
        const int zCModel_numActAnis_offset = 52; //0x34
        const int zCModel_actAniList_offset = 56; //0x37
        const int zCModelAni_aniID_offset   = 76; //0x4C
        var int actAniOffset; actAniOffset = modelPtr+zCModel_actAniList_offset;
        repeat(i, MEM_ReadInt(modelPtr+zCModel_numActAnis_offset)); var int i;
            var int aniID; aniID = MEM_ReadInt(MEM_ReadInt(MEM_ReadInt(actAniOffset))+zCModelAni_aniID_offset);
            if (aniID == MEM_ReadStatArr(ai.s_SwimF,  npc.fmode)) || (aniID == MEM_ReadStatArr(ai.s_SwimB,  npc.fmode)){
                return TRUE;
            };
            actAniOffset += 4;
        end;
    };
    return FALSE;
};
func int Ninja_Stamina_Npc_IsJump(var C_Npc slf) {
    var oCNpc npc; npc = Hlp_GetNpc(slf);
    var int aiPtr; aiPtr = npc.human_ai;

    if (GOTHIC_BASE_VERSION == 2) {
        const int oCAniCtrl_Human__IsRunning = 7004672; //0x6AE200

        const int call = 0;
        if (CALL_Begin(call)) {
            CALL_PutRetValTo(_@(ret));
            CALL__thiscall(_@(aiPtr), oCAniCtrl_Human__IsRunning);
            call = CALL_End();
        };

        var int ret;
        return +ret;

    } else {
        // Gothic 1 does not have the function oCAniCtrl_Human::IsRunning. Re-implement it here
        // These lines require at lease Ikarus 1.2.2

        var oCAniCtrl_Human ai; ai = _^(aiPtr);
        var int modelPtr; modelPtr = ai._zCAIPlayer_model;

        if (!modelPtr) {
            return FALSE;
        };

        // Modified from auxillary.d in GothicFreeAim
        // https://github.com/szapp/GothicFreeAim/blob/v1.2.0/_work/data/Scripts/Content/GFA/_intern/auxiliary.d#L169
        const int zCModel_numActAnis_offset = 52; //0x34
        const int zCModel_actAniList_offset = 56; //0x37
        const int zCModelAni_aniID_offset   = 76; //0x4C
        var int actAniOffset; actAniOffset = modelPtr+zCModel_actAniList_offset;
        repeat(i, MEM_ReadInt(modelPtr+zCModel_numActAnis_offset)); var int i;
            var int aniID; aniID = MEM_ReadInt(MEM_ReadInt(MEM_ReadInt(actAniOffset))+zCModelAni_aniID_offset);
            if (aniID == MEM_ReadStatArr(ai.t_RunStrafeL,  npc.fmode)) || (aniID == MEM_ReadStatArr(ai.t_RunStrafeR,  npc.fmode)){
                return TRUE;
            };
            actAniOffset += 4;
        end;
    };
    return FALSE;
};
/*
 * Breath based sprinting. This function has to be called every single frame
 */
func void _Ninja_Quickloot_CNpc_SetFocusVob(var C_Npc npc, var int vobPtr) {
	const int oCNpc__SetFocusVob_G1 = 6881136; // 0068FF70
	const int oCNpc__SetFocusVob_G2 = 7547744; // 00732B60
    var int npcPtr; npcPtr = MEM_InstToPtr(npc);

    const int call = 0;
    if (CALL_Begin(call)) {
        CALL_PtrParam(_@(vobPtr));
        CALL__thiscall(_@(npcPtr), MEMINT_SwitchG1G2 (oCNpc__SetFocusVob_G1, oCNpc__SetFocusVob_G2));

        call = CALL_End();
    };
};
func int C_BodyStateContainsNew (var C_NPC slf, var int bodystate)
{
	if ((Npc_GetBodyState(slf)&(BS_MAX|BS_FLAG_INTERRUPTABLE|BS_FLAG_FREEHANDS)) == (bodystate&(BS_MAX|BS_FLAG_INTERRUPTABLE|BS_FLAG_FREEHANDS)))
	{ return TRUE; }
	else
	{ return FALSE; };
};
func void Ninja_Stamina_IntegratedSprint() {
    const int THRESHOLD_MS     = 1161527296; // 3000.0f
    const int ACTION_WATERWALK = 4;          // oCAniCtrl_Human.actionMode

    var oCNpc her; her = Hlp_GetNpc(hero);
    var oCAniCtrl_Human ai; ai = _^(her.human_ai);
	var int keyState_disablestatus; keyState_disablestatus = MEM_KeyState(KEY_I);
	var int keyState_normal_arrow; keyState_normal_arrow = MEM_KeyState(KEY_NUMPAD1);
	var int keyState_fire_arrow; keyState_fire_arrow = MEM_KeyState(KEY_NUMPAD2);
	var int keyState_magic_arrow; keyState_magic_arrow = MEM_KeyState(KEY_NUMPAD3);
	var int keyState_novice; keyState_novice = MEM_KeyState(KEY_NUMPAD4);
	var int keyState_adept; keyState_adept = MEM_KeyState(KEY_NUMPAD5);
	var int keyState_master; keyState_master = MEM_KeyState(KEY_NUMPAD6);
	var int keyState_openLock; keyState_openLock = MEM_KeyState(KEY_Y);
	var C_Item weapon;
	var C_Item equippedbow;
    var oCMobLockable mob;
	if (MEM_Game.pause_screen) || (!InfoManager_HasFinished()) 
	{
		//Print_DeleteText(msg_oth_health);
		return;
	};
	var C_Npc oth; oth = _^(her.focus_vob);
	var int party; party = Ninja_ColorFocusVobs_GetAIVarSafe(oth, "AIV_PARTYMEMBER", FALSE);
	if (party)
	{
		if (Npc_HasReadiedMeleeWeapon(her))
		{
			_Ninja_Quickloot_CNpc_SetFocusVob(hero, 0);
		};
	};
	if (Hlp_IsValidNpc(hero) && C_BodyStateContainsNew(hero,BS_CLIMB))
	{
		if(Breath_AvailableMsF(hero, cost_addon))
		{
			Breath_DecreaseMsF(hero, cost_addon);
		}
		else
		{
			Mdl_ApplyOverlayMds(her, NINJA_SPRINT_ANIM);
			Mdl_RemoveOverlayMds(her, NINJA_SPRINT_ANIM);
		};
	};
	if (Wld_GetMin() < 10)
	{
		PrintScreen(ConcatStrings("Czas: ",ConcatStrings(ConcatStrings(IntToString(Wld_GetHour()),":0"), IntToString(Wld_GetMin()))),1,5,"font_old_10_white.tga",1);
	}
	else
	{
		PrintScreen(ConcatStrings("Czas: ",ConcatStrings(ConcatStrings(IntToString(Wld_GetHour()),":"), IntToString(Wld_GetMin()))),1,5,"font_old_10_white.tga",1);
	};
	PrintScreen(ConcatStrings(IntToString(Wld_GetDay()+1), ". Dzieñ"),1,3,"font_old_10_white.tga",1);
	if (keyState_disablestatus == KEY_RELEASED)
	{
		if (ShowPlayerStats == 0)
		{
			ShowPlayerStats = 1;
		}
		else
		{
			ShowPlayerStats = 0;
		};
	};
	if (ShowPlayerStats == 0)
	{
		PrintScreen(ConcatStrings("P¯: ",ConcatStrings(ConcatStrings(IntToString(hero.attribute[ATR_HITPOINTS]),"/"),IntToString(hero.attribute[ATR_HITPOINTS_MAX]))),2,93,"font_old_10_white.tga",1);
		PrintScreen("Wytrzyma³oœæ",-1,93,"font_old_10_white.tga",1);
		PrintScreen(ConcatStrings("Mana: ",ConcatStrings(ConcatStrings(IntToString(hero.attribute[ATR_MANA]),"/"),IntToString(hero.attribute[ATR_MANA_MAX]))),83,93,"font_old_10_white.tga",1);
	};
	if (Hlp_Is_oCNpc(her.focus_vob))
	{
		var C_Npc oth; oth = _^(her.focus_vob);
		if (oth.attribute[ATR_HITPOINTS] >= 1)
		{
			msg_oth_health = Print_Ext(-1,400,ConcatStrings("P¯: ",ConcatStrings(ConcatStrings(IntToString(oth.attribute[ATR_HITPOINTS]),"/"),IntToString(oth.attribute[ATR_HITPOINTS_MAX]))),"font_old_10_white.tga",COL_White,50);
		};
	};
	if (keyState_openLock == KEY_RELEASED)
	{
		if(!C_BodyStateContainsNew(hero,BS_MOBINTERACT_INTERRUPT))
		{
			if(Hlp_Is_oCMobLockable(her.focus_vob))
			{
				mob = _^(her.focus_vob);
				her.interactMob = her.focus_vob;
				//PrintScreen(mob.pickLockStr,2,_YPOS_MESSAGE_XPGAINED+11,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
				var int currCharCount; currCharCount = (mob.bitfield & oCMobLockable_bitfield_pickLockNr) >> 2;
				var int totalCharCount; totalCharCount = STR_Len(mob.pickLockStr);
				if (hero.attribute[ATR_STRENGTH] < totalCharCount*15)
				{
					PrintScreen(ConcatStrings("Wymagana si³a do wy³amania zamka: ",IntToString(totalCharCount*15)),-1,70,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
				}
				else if (!(mob.bitfield & oCMobLockable_bitfield_locked) || STR_Len(mob.keyInstance))
				{
					//PrintScreen("Zamek jest ju¿ otwarty.",2,_YPOS_MESSAGE_XPGAINED+4,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
				}
				else
				{
					currCharCount += totalCharCount;
					Npc_SendPassivePerc(hero, PERC_ASSESSUSEMOB, hero, hero);
					mob.bitfield = mob.bitfield & ~oCMobLockable_bitfield_pickLockNr;
					mob.bitfield = mob.bitfield | (currCharCount << 2);
					if (currCharCount >= totalCharCount) 
					{
						mob.bitfield = mob.bitfield &~ oCMobLockable_bitfield_locked;
					};
					AI_PlayAni(hero,"T_PLUNDER");
					Snd_Play3D(hero, "PICKLOCK_SUCCESS");
					PrintScreen("Pomyœlnie wy³amano zamek!",-1,20,"font_old_10_white.tga",_TIME_MESSAGE_XPGAINED+2);
					her.interactMob = 0;
				};
			
			};
		};
	};
	// Calculate cost per this frame (dynamically, because frame length varies and divetime might be updated)
    var int factor; factor = divf(her.divetime, mkf(hero.attribute[ATR_DEXTERITY]*1000));
	var int factor_swim; factor_swim = divf(her.divetime, mkf(60000));
	var int factor_addon; factor_addon = divf(her.divetime, mkf(50000));
    var int cost; cost = mulf(MEM_Timer.frameTimeFloat, factor);
	var int cost_swim; cost_swim = mulf(MEM_Timer.frameTimeFloat, factor_swim);
	var int cost_addon; cost_addon = mulf(MEM_Timer.frameTimeFloat, factor_addon);
	if (Ninja_Stamina_Npc_IsSneak(hero)) 
	{
		if(Breath_AvailableMsF(hero, cost_addon))
		{
			Breath_DecreaseMsF(hero, cost_addon);
		}
		else
		{
			Mdl_ApplyOverlayMds(her, NINJA_SPRINT_ANIM);
			Mdl_RemoveOverlayMds(her, NINJA_SPRINT_ANIM);
		};
	};
	if (Ninja_Stamina_Npc_IsJump(hero)) 
	{
		if(Breath_AvailableMsF(hero, cost_addon))
		{
			Breath_DecreaseMsF(hero, cost_addon);
		}
		else
		{
			Mdl_ApplyOverlayMds(her, NINJA_SPRINT_ANIM);
			Mdl_RemoveOverlayMds(her, NINJA_SPRINT_ANIM);
		};
	};
	if (Ninja_Stamina_Npc_IsSwim(hero)) 
	{
		if(Breath_AvailableMsF(hero, cost_swim))
		{
			Breath_DecreaseMsF(hero, cost_swim);
		}
		else
		{
			if (hero.attribute[ATR_HITPOINTS] > 1)
			{
				hero.attribute[ATR_HITPOINTS] -= 1;
			};
		};
	};
	if ((MEM_KeyPressed(MEM_GetKey("keyIntSprint"))) || (MEM_KeyPressed(MEM_GetSecondaryKey("keyIntSprint"))))
    && (Breath_AvailableMsF(hero, cost))
    && (ai.actionMode < ACTION_WATERWALK) {

        // Decrease only while running
        if (Ninja_Stamina_Npc_IsRunning(hero)) {
            Breath_DecreaseMsF(hero, cost);

            // Apply overlay after refractory period
            if (!Ninja_Stamina_Mdl_OverlayMdsIsActive(hero, NINJA_SPRINT_ANIM))
            && (Breath_AvailableMsF(hero, THRESHOLD_MS)) {
                Mdl_ApplyOverlayMds(her, NINJA_SPRINT_ANIM);
            };
        };
    } else if (Ninja_Stamina_Mdl_OverlayMdsIsActive(hero, NINJA_SPRINT_ANIM)) {
        Mdl_RemoveOverlayMds(her, NINJA_SPRINT_ANIM);
    };
	weapon = Npc_GetEquippedMeleeWeapon(her);
	equippedbow = Npc_GetEquippedRangedWeapon(her);
	if (Npc_HasReadiedRangedWeapon(her))
	{
		
	} 
	else 
	{
		equippedbow = Npc_GetEquippedRangedWeapon(her);
		if (equippedbow.munition == ItAmArrow)
		{
			Current_arrow_mode = "Strza³a";
		};
		if (equippedbow.munition == ItAmArrow_Fire)
		{
			Current_arrow_mode = "Ognista Strza³a";
		};
		if (equippedbow.munition == ItAmArrow_Magic)
		{
			Current_arrow_mode = "Magiczna Strza³a";
		};
		if (equippedbow.munition == ItAmBolt)
		{
			Current_arrow_mode = "Be³t";
		};
		if (equippedbow.munition == ItAmBolt_Fire)
		{
			Current_arrow_mode = "Ognisty Be³t";
		};
		if (equippedbow.munition == ItAmBolt_Magic)
		{
			Current_arrow_mode = "Magiczny Be³t";
		};
	};
	
	if ((keyState_novice == KEY_PRESSED || keyState_novice == KEY_HOLD))
	{
		//reserved
	};
	if ((keyState_adept == KEY_PRESSED || keyState_adept == KEY_HOLD))
	{
		if(weapon.flags == 1082146818 || weapon.flags == 1082163202) //jednorêczna
		{
			if (Weapon_1H_AlreadyLearned >= 30)
			{
				Npc_SetTalentSkill(her,NPC_TALENT_1H,0);
				Npc_SetTalentSkill(her,NPC_TALENT_1H,1);
				PrintScreen("Wybrano styl walki: adept.",2,80,"FONT_OLD_10_WHITE.tga",_TIME_MESSAGE_XPGAINED+2);
			}
			else
			{
				PrintScreen("Wymagane 30% w umiejêtnoœci: broñ jednorêczna.",2,80,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
			};
		}
		else if(weapon.flags == 1082261506 || weapon.flags == 1082195970)
		{
			PrintScreen("Dwurêka",2,80,"FONT_OLD_10_WHITE.tga",_TIME_MESSAGE_XPGAINED+2);
		};
		
	};
	// walka broni¹ i inne
	if ((keyState_master == KEY_PRESSED || keyState_master == KEY_HOLD))
	{
		if(weapon.flags == 1082146818 || weapon.flags == 1082163202) //jednorêczna
		{
			if (Weapon_1H_AlreadyLearned >= 60)
			{
				Npc_SetTalentSkill(her,NPC_TALENT_1H,0);
				Npc_SetTalentSkill(her,NPC_TALENT_1H,2);
				PrintScreen("Wybrano styl walki: mistrz.",2,80,"FONT_OLD_10_WHITE.tga",_TIME_MESSAGE_XPGAINED+2);
			}
			else
			{
				PrintScreen("Wymagane 60% w umiejêtnoœci: broñ jednorêczna.",2,80,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
			};
		}
		else if(weapon.flags == 1082261506 || weapon.flags == 1082195970)
		{
			PrintScreen("Dwurêka",2,80,"FONT_OLD_10_WHITE.tga",_TIME_MESSAGE_XPGAINED+2);
		};
	};
	var int latest;
	if (her.fmode == FMODE_FAR || her.fmode == FMODE_FAR+1)
	{
		if (!Npc_HasItems(her,latest) == 0)
		{
			PrintScreen(ConcatStrings(Current_arrow_mode, ConcatStrings(": ",IntToString(Npc_HasItems(her,latest)))),bowmunnitiontext_x,bowmunnitiontext_y,"FONT_OLD_10_WHITE.tga",1);
		};
		if(Breath_AvailableMsF(hero, cost) && (ai.actionMode < ACTION_WATERWALK))
		{
			if (Ninja_Stamina_Npc_IsRunning(hero)) {
				Breath_DecreaseMsF(hero, cost);
			};
		};
		return;
	}
	else
	{
		latest = equippedbow.munition;
		if (!Npc_HasItems(her,latest) == 0)
		{
			PrintScreen(ConcatStrings(Current_arrow_mode, ConcatStrings(": ",IntToString(Npc_HasItems(her,latest)))),bowmunnitiontext_x,bowmunnitiontext_y,"FONT_OLD_10_WHITE.tga",1);
			if ((keyState_normal_arrow == KEY_PRESSED || keyState_normal_arrow == KEY_HOLD))
			{
				if(equippedbow.flags & ITEM_BOW)
				{
					if(Npc_HasItems(her, ItAmArrow))
					{
						equippedbow.munition = ItAmArrow;
						equippedbow.damagetype = DAM_POINT;
						equippedbow.damage[DAM_INDEX_FIRE] = 0;
						equippedbow.damage[DAM_INDEX_MAGIC] = 0;
						equippedbow.text[1] = "";
						PrintScreen(ConcatStrings("U¿ywasz: Strza³y x ", IntToString(Npc_HasItems(her,ItAmArrow))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz zwyk³ych strza³.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				}
				else
				{
					if(Npc_HasItems(her, ItAmBolt))
					{
						equippedbow.munition = ItAmBolt;
						equippedbow.damagetype = DAM_POINT;
						equippedbow.damage[DAM_INDEX_FIRE] = 0;
						equippedbow.damage[DAM_INDEX_MAGIC] = 0;
						equippedbow.text[1] = "";
						PrintScreen(ConcatStrings("U¿ywasz: Be³ty x ", IntToString(Npc_HasItems(her,ItAmBolt))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz zwyk³ych be³tów.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				};
			};
			if ((keyState_fire_arrow == KEY_PRESSED || keyState_fire_arrow == KEY_HOLD))
			{
				if(equippedbow.flags & ITEM_BOW)
				{
					if(Npc_HasItems(her, ItAmArrow_Fire))
					{
						equippedbow.munition = ItAmArrow_Fire;
						equippedbow.damagetype = DAM_FIRE;
						equippedbow.damage[DAM_INDEX_FIRE] = equippedbow.damageTotal;
						equippedbow.damage[DAM_INDEX_MAGIC] = 0;
						equippedbow.text[1] = "Ogniste Strza³y";
						PrintScreen(ConcatStrings("U¿ywasz: Ogniste Strza³y x ", IntToString(Npc_HasItems(her,ItAmArrow_Fire))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz ognistych strza³.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				}
				else
				{
					if(Npc_HasItems(her, ItAmBolt_Fire))
					{
						equippedbow.munition = ItAmBolt_Fire;
						equippedbow.damagetype = DAM_FIRE;
						equippedbow.damage[DAM_INDEX_FIRE] = equippedbow.damageTotal;
						equippedbow.damage[DAM_INDEX_MAGIC] = 0;
						equippedbow.text[1] = "Ogniste Be³ty";
						PrintScreen(ConcatStrings("U¿ywasz: Ogniste Be³ty x ", IntToString(Npc_HasItems(her,ItAmBolt_Fire))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz ognistych be³tów.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				};
			};
			if ((keyState_magic_arrow == KEY_PRESSED || keyState_magic_arrow == KEY_HOLD))
			{
				if(equippedbow.flags & ITEM_BOW)
				{
					
					if(Npc_HasItems(her, ItAmArrow_Magic))
					{
						equippedbow.munition = ItAmArrow_Magic;
						equippedbow.damagetype = DAM_MAGIC;
						equippedbow.damage[DAM_INDEX_FIRE] = 0;
						equippedbow.damage[DAM_INDEX_MAGIC] = equippedbow.damageTotal;
						equippedbow.text[1] = "Magiczne Strza³y";
						PrintScreen(ConcatStrings("U¿ywasz: Magiczne Strza³y x ", IntToString(Npc_HasItems(her,ItAmArrow_Magic))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz magicznych strza³.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				}
				else
				{
					if(Npc_HasItems(her, ItAmBolt_Magic))
					{
						equippedbow.munition = ItAmBolt_Magic;
						equippedbow.damagetype = DAM_MAGIC;
						equippedbow.damage[DAM_INDEX_FIRE] = 0;
						equippedbow.damage[DAM_INDEX_MAGIC] = equippedbow.damageTotal;
						equippedbow.text[1] = "Magiczne Be³ty";
						PrintScreen(ConcatStrings("U¿ywasz: Magiczne Be³ty x ", IntToString(Npc_HasItems(her,ItAmBolt_Magic))),bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					}
					else
					{
						PrintScreen("Nie posiadasz magicznych be³tów.",bowmunnitiontext_x,bowmunnitiontext_y+2,"FONT_OLD_10_BLUE.tga",_TIME_MESSAGE_XPGAINED+2);
					};
				};
			};
		
		};
	};
};


/*
 * Initialization function to be called from Init_Global
 */
func void Ninja_Stamina_IntegratedSprint_Init() {
    // Requires LeGo FrameFunctions
    if (_LeGo_Flags & LeGo_FrameFunctions) {
		FF_ApplyOnceExtGT(Ninja_Stamina_IntegratedSprint, 0, -1);
    };
};
