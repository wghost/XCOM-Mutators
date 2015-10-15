class XComMutator extends Mutator;

function Mutate(string MutateString, PlayerController Sender)
{
	local array<string> SplitStr;
	local string ParamsStr;
	
	if (MutateString == "XComGameInfo.InitGame")
	{
		GameInfoInitGame(Sender);
	}
	if (MutateString == "XGHeadQuarters.InitNewGame")
	{
		HeadQuartersInitNewGame(Sender);
	}
	if (MutateString == "XGBattle_SP.PostLevelLoaded")
	{
		PostLevelLoaded(Sender);
	}
	if (MutateString == "XGBattle_SP.PostLoadSaveGame")
	{
		PostLoadSaveGame(Sender);
	}
	if (MutateString == "XGBattle.DoWorldDataRebuild")
	{
		DoWorldDataRebuild(Sender);
	}
	if (MutateString == "XGBattle.Loading.NotifyKismetOfLoad")
	{
		MutateNotifyKismetOfLoad(Sender);
	}
	if (MutateString == "XGStrategy.NewGame")
	{
		MutateStrategyAI(Sender);
	}
	if (InStr(MutateString, "SeqAct_SpawnAlien.Activated") > -1)
	{
		MutateSpawnAlien(Split(MutateString, "SeqAct_SpawnAlien.Activated:", true), Sender);
	}
	if (InStr(MutateString, "XGPlayer.InitBehavior") > -1)
	{
		MutateTacticalAI(Split(MutateString, "XGPlayer.InitBehavior:", true), Sender);
	}
	if (InStr(MutateString, "XGUnit.UpdateInteractClaim") > -1)
	{
		MutateUpdateInteractClaim(Split(MutateString, "XGUnit.UpdateInteractClaim:", true), Sender);
	}
	if (InStr(MutateString, "XGUnit.RecordKill") > -1)
	{
		ParamsStr = Split(MutateString, "XGUnit.RecordKill:", true);
		SplitStr = SplitString(ParamsStr, ",", false);
		if (SplitStr.Length == 2)
		{
			MutateRecordKill(SplitStr[0], SplitStr[1], Sender);
		}
	}
	`Log("XComMutator: Current = " $ string(Name));
	if (NextMutator != none)
	{
		`Log("XComMutator: Next = " $ string(NextMutator.Name));
	}
	else
	{
		`Log("XComMutator: Next = None");
	}
	// never forget to call for super.Mutate from inside subclass of XComMutator class
	// if you do, you'll stop Mutate propagation along the chain of mutators
	super.Mutate(MutateString, Sender);
}

function GameInfoInitGame(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function HeadQuartersInitNewGame(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function PostLevelLoaded(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function PostLoadSaveGame(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function DoWorldDataRebuild(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateNotifyKismetOfLoad(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateStrategyAI(PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateSpawnAlien(string SeqActObjName, PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateTacticalAI(string UnitObjName, PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateUpdateInteractClaim(string UnitObjName, PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}

function MutateRecordKill(string UnitObjName, string VictimObjName, PlayerController Sender)
{
	// never call for NextMutator from inside a function, called by Mutate!
	// if you do, you'll end up calling the same function twice
}
