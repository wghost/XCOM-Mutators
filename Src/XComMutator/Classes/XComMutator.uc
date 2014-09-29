class XComMutator extends Mutator;

function Mutate(string MutateString, PlayerController Sender)
{
	if (MutateString == "XGBattle_SP.PostLevelLoaded")
	{
		PostLevelLoaded(Sender);
	}
	if (MutateString == "XGBattle_SP.PostLoadSaveGame")
	{
		PostLoadSaveGame(Sender);
	}
	if (MutateString == "XGBattle.Loading.NotifyKismetOfLoad")
	{
		MutateNotifyKismetOfLoad(Sender);
	}
	if (InStr(MutateString, "SeqAct_SpawnAlien.Activated") > -1)
	{
		MutateSpawnAlien(Split(MutateString, "SeqAct_SpawnAlien.Activated:", true), Sender);
	}
	if (InStr(MutateString, "XGPlayer.InitBehavior") > -1)
	{
		MutateTacticalAI(Split(MutateString, "XGPlayer.InitBehavior:", true), Sender);
	}
	// never forget to call for super.Mutate from inside subclass of XComMutator class
	// if you do, you'll stop Mutate propagation along the chain of mutators
	super.Mutate(MutateString, Sender);
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

function MutateNotifyKismetOfLoad(PlayerController Sender)
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