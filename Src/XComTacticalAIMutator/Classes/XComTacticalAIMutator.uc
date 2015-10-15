class XComTacticalAIMutator extends XComMutator;

function MutateTacticalAI(string UnitObjName, PlayerController Sender)
{
	local class<XGAIBehavior> ModifiedAI;
	local XGUnit Unit, FoundUnit;

	`Log("XComTacticalAIMutator: UnitObjName = " $ UnitObjName);
	
	foreach AllActors(class'XGUnit', Unit)
	{
		if (string(Unit) == UnitObjName)
		{
			FoundUnit = Unit;
			`Log("XComTacticalAIMutator: FoundUnit = " $ FoundUnit);
			break;
		}
	}
	
	if (FoundUnit != none)
	{
		ModifiedAI = GetModifiedBehaviorClass(FoundUnit.GetCharacter().m_eType);
		if (ModifiedAI != none)
		{
			FoundUnit.m_kBehavior = Spawn(ModifiedAI, FoundUnit);
		}
	}
}

function class<XGAIBehavior> GetModifiedBehaviorClass(XGGameData.EPawnType eAlienType)
{
	switch (eAlienType)
	{
		case ePawnType_Muton_Berserker:
			return class'XGAIBehavior_MutonBerserker_Mod';
		case ePawnType_Sectoid:
			return class'XGAIBehavior_Sectoid_Mod';
	}

	return none;
}