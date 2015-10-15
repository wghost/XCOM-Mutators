class XComMeldSpawnMutator extends XComSpawnMutator
	config(RandomSpawns);

var config int NumContainers;
var config float EqSlope;
var config float EqConst;
var array<vector> MeldSpawnPts;

function PostLevelLoaded(PlayerController Sender)
{
	`Log("XComMeldSpawnMutator: PostLevelLoaded");
	// to always have 1 easy and 1 hard container
	if (NumContainers < 2)
	{
		NumContainers = 2;
	}
	`Log("XComMeldSpawnMutator: NumContainers = " $ NumContainers);
	if (EqSlope == 0)
	{
		EqSlope = 1;
	}
	if (!XGBattle_SP(BATTLE()).m_kDesc.ShouldSpawnMeldCanisters())
	{
		`Log("XComMeldSpawnMutator: no need to spawn Meld, skipping.");
		return;
	}
	InitBaseSpawnMutator(NumContainers);
	MeldSpawnPts = GetRandomLocations();
	if (MeldSpawnPts.Length < NumContainers)
	{
		`Log("XComMeldSpawnMutator: Error, can't find enough spawn locations, skipping!");
		return;
	}
	RemoveOriginalSpawnPoints();
	AddNewSpawnPoints();
}

function RemoveOriginalSpawnPoints()
{
	local XComMeldContainerSpawnPoint SpawnPoint;
	
	foreach AllActors(class'XComMeldContainerSpawnPoint', SpawnPoint)
	{
		SpawnPoint.Destroy();
	}
}

function AddNewSpawnPoints()
{
	local vector SpawnPtLoc;
	local XComMeldContainerSpawnPoint SpawnPoint;
	local float AvgDist, Dist;

	AvgDist = 0;
	foreach MeldSpawnPts(SpawnPtLoc)
	{
		AvgDist += VSize(PlayerStartLoc - SpawnPtLoc);
	}
	AvgDist /= MeldSpawnPts.Length;
	
	foreach MeldSpawnPts(SpawnPtLoc)
	{
		SpawnPoint = Spawn(class'XComMeldContainerSpawnPoint',, 'XComMeldContainerSpawnPoint', SpawnPtLoc,,, true);
		Dist = VSize(PlayerStartLoc - SpawnPtLoc);
		if (Dist < AvgDist)
		{
			SpawnPoint.m_eDifficulty = eMeldContainerDifficulty_Easy;
		}
		else
		{
			SpawnPoint.m_eDifficulty = eMeldContainerDifficulty_Hard;
		}
		SpawnPoint.m_iDestroyedOnTurn = (Dist / (96 * 8)) * EqSlope + EqConst;
	}
}