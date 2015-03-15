class XComMutatorLoader extends XComMutator
	config(MutatorLoader);

var config array<config string> arrTacticalMutators;
var config array<config string> arrStrategicMutators;

function GameInfoInitGame(PlayerController Sender)
{
	local string MutatorName;
	local Class MutatorClass;
	local XComGameInfo CurrentGameInfo;
	
	CurrentGameInfo = XComGameInfo(WorldInfo.Game);
	
	`Log("XComMutatorLoader: arrTacticalMutators.Length = " $ string(arrTacticalMutators.Length));
	`Log("XComMutatorLoader: arrStrategicMutators.Length = " $ string(arrStrategicMutators.Length));

	if (XComTacticalGame(CurrentGameInfo) != none)
	{
		`Log("XComMutatorLoader: CurrentGameInfo == XComTacticalGame");
		foreach arrTacticalMutators(MutatorName)
		{
			MutatorClass = class<Mutator>(DynamicLoadObject(MutatorName, class'Class'));
			if(MutatorClass != none)
			{
				CurrentGameInfo.AddMutator(MutatorName, true);
			}
		}
	}
	else if (XComHeadquartersGame(CurrentGameInfo) != none)
	{
		`Log("XComMutatorLoader: CurrentGameInfo == XComHeadquartersGame");
		foreach arrStrategicMutators(MutatorName)
		{
			MutatorClass = class<Mutator>(DynamicLoadObject(MutatorName, class'Class'));
			if(MutatorClass != none)
			{
				CurrentGameInfo.AddMutator(MutatorName, true);
			}
		}
	}
}
