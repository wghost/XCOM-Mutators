class XComSHIVXPMutator extends XComMutator
	config(SHIVXP);

var config float SHIV_KILL_MOD;

function MutateRecordKill(string UnitObjName, string VictimObjName, PlayerController Sender)
{
	local XGUnit Unit, FoundUnit, FoundVictim;
	local array<XGUnit> VisibleFriends;
	local int XP;
	local bool WasLeveledUp;

	`Log("XComSHIVXPMutator: UnitObjName = " $ UnitObjName);
	`Log("XComSHIVXPMutator: VictimObjName = " $ VictimObjName);
	
	foreach AllActors(class'XGUnit', Unit)
	{
		if (string(Unit) == UnitObjName)
		{
			FoundUnit = Unit;
			`Log("XComSHIVXPMutator: FoundUnit = " $ FoundUnit);
		}
		if (string(Unit) == VictimObjName)
		{
			FoundVictim = Unit;
			`Log("XComSHIVXPMutator: FoundVictim = " $ FoundVictim);
		}
		if (FoundUnit != none && FoundVictim != none)
		{
			break;
		}
	}
	
	if (FoundUnit != none && FoundVictim != none)
	{
		if (FoundUnit.IsATank())
		{
			VisibleFriends = FoundUnit.GetVisibleFriends();
			if (VisibleFriends.Length > 0)
			{
				foreach VisibleFriends(Unit)
				{
					If (Unit.IsVisibleEnemy(FoundVictim))
					{
						XP = SHIV_KILL_MOD * XComGameReplicationInfo(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kGameCore.CalcXP(Unit, 0, FoundVictim);
						`Log("XComSHIVXPMutator: Unit = " $ Unit $ " (" $ Unit.SafeGetCharacterName() $ ")");
						`Log("XComSHIVXPMutator: XP = " $ XP);
						WasLeveledUp = XGCharacter_Soldier(Unit.GetCharacter()).LeveledUp();
						XGCharacter_Soldier(Unit.GetCharacter()).AddXP(XP);
						if(XGCharacter_Soldier(Unit.GetCharacter()).LeveledUp() && !WasLeveledUp)
						{
							XComTacticalController(Unit.Owner).ClientPHUDLevelUp(XGCharacter_Soldier(Unit.GetCharacter()));
						}
					}
				}
			}
		}
	}
}
