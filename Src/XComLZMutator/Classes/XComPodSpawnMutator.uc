class XComPodSpawnMutator extends XComSpawnMutator
	config(RandomSpawns);

var int NumPods;
var array<vector> PodSpawnPts;
var bool bKeepCommander;

function int MissionType()
{
	return XGBattle_SP(BATTLE()).m_kDesc.m_iMissionType;
}

function XGGameData.EShipType ShipType()
{
	return class'XComMapManager'.static.GetCurrentMapMetaData().ShipType;
}

function PostLevelLoaded(PlayerController Sender)
{
	local TAlienSquad AlienSquad;
	
	`Log("XComPodSpawnMutator: PostLevelLoaded");
	if (MissionType() == eMission_Final || MissionType() == eMission_HQAssault)
	{
		`Log("XComSpawnAlienMutator: Storyline mission is on, skipping to defaults.");
		return;
	}
	AlienSquad = XGBattle_SP(BATTLE()).m_kDesc.m_kAlienSquad;
	NumPods = AlienSquad.arrPods.Length;
	if (NumPods == 0)
	{
		`Log("XComPodSpawnMutator: Error! No pods found, skipping to defaults.");
		return;
	}
	`Log("XComPodSpawnMutator: NumPods = " $ NumPods);
	//check for UFO storyline missions
	bKeepCommander = false;
	if (MissionType() == eMission_AlienBase || ShipType() == eShip_UFOEthereal || ShipType() == eShip_UFOBattle)
	{
		`Log("XComPodSpawnMutator: saving original Commander spawn point.");
		bKeepCommander = true;
		--NumPods;
	}
	//check for UFO mission and Commander Pods
	else if (MissionType() == eMission_Crash || MissionType() == eMission_LandedUFO)
	{
		`Log("XComPodSpawnMutator: UFO mission is on, generating Commander spawn point.");
		GenerateCommanderSpawnPt();
		bKeepCommander = true;
		--NumPods;
	}
	InitBaseSpawnMutator(NumPods);
	PodSpawnPts = GetRandomLocations();
	if (PodSpawnPts.Length < NumPods)
	{
		`Log("XComPodSpawnMutator: Error, can't find enough spawn locations, skipping!");
		return;
	}
	RemoveOriginalSpawnPoints();
	AddNewSpawnPoints();
}

function vector GetRandomCommandPoint(vector Origin, vector Extent)
{
	local float X, Y;
	local vector vLoc;

	`Log("XComPodSpawnMutator: UFO Type = " $ string(ShipType()));
	if (ShipType() == eShip_UFOSmallScout || ShipType() == eShip_UFOLargeScout)
	{
		X = (FRand() - 0.5) * 2 * 0.6;
		if (Abs(X) < 0.3)
		{
			Y = (FRand() - 0.5) * 2 * 0.6;
		}
		else
		{
			Y = (FRand() - 0.5) * 2 * 0.3;
		}
	}
	else if (ShipType() == eShip_UFOAbductor)
	{
		if (Extent.X > Extent.Y)
		{
			X = (FRand() - 0.5) * 2 * 0.8;
			Y = (FRand() - 0.5) * 2 * 0.3;
		}
		else
		{
			X = (FRand() - 0.5) * 2 * 0.3;
			Y = (FRand() - 0.5) * 2 * 0.8;
		}
	}
	else
	{
		X = (FRand() - 0.5) * 2 * 0.7;
		Y = (FRand() - 0.5) * 2 * 0.7;
	}
	vLoc.X = Origin.X + Extent.X * X;
	vLoc.Y = Origin.Y + Extent.Y * Y;
	vLoc.Z = Origin.Z - Extent.Z / 2;
	return vLoc;
}

function GenerateCommanderSpawnPt()
{
	local array<XComBuildingVolume> LevelBuildings;
	local XComBuildingVolume Building;
	local vector UFOOrigin, UFOExtent, SpawnLoc, TestLoc, OriginalLoc;
	local int NumAttempts;
	local bool BadLoc, FoundOriginalLoc;
	local XComAlienPod SpawnPoint;
	
	// get original command pod Z coordinate
	FoundOriginalLoc = false;
	foreach AllActors(class'XComAlienPod', SpawnPoint)
	{
		if (SpawnPoint.bCommanderPod)
		{
			FoundOriginalLoc = true;
			OriginalLoc = SpawnPoint.Location;
		}
	}
	LevelBuildings = BATTLE().m_kLevel.m_arrBuildings;
	BadLoc = true;
	foreach LevelBuildings(Building)
	{
		if (Building.IsUfo)
		{
			`Log("XComPodSpawnMutator: found UFO.");
			UFOOrigin = Building.BrushComponent.Bounds.Origin;
			UFOExtent = Building.BrushComponent.Bounds.BoxExtent;
			`Log("XComPodSpawnMutator: Origin: " $ string(UFOOrigin));
			`Log("XComPodSpawnMutator: Extent: " $ string(UFOExtent));
			NumAttempts = 0;
			BadLoc = true;
			while (NumAttempts < 100)
			{
				TestLoc = GetRandomCommandPoint(UFOOrigin, UFOExtent);
				if (FoundOriginalLoc)
				{
					TestLoc.Z = OriginalLoc.Z;
				}
				SpawnLoc = WORLD().FindClosestValidLocation(TestLoc, false, false, false);
				if (IsValidSpawnLocation(SpawnLoc) && !IsCloseToLZ(SpawnLoc))
				{
					`Log("XComPodSpawnMutator: found good random Commander spawn point: " $ string(SpawnLoc));
					BadLoc = false;
					break;
				}
				++NumAttempts;
			}
		}
	}
	// if failed to create random point, keep original
	if (BadLoc)
	{
		`Log("XComPodSpawnMutator: failed to create random Commander spawn point, keeping original.");
		return;
	}
	// destroy existing commander pods
	foreach AllActors(class'XComAlienPod', SpawnPoint)
	{
		if (SpawnPoint.bCommanderPod)
		{
			SpawnPoint.Destroy();
		}
	}
	// spawn new commander pod
	SpawnPoint = Spawn(class'XComAlienPod',,, SpawnLoc,,, true);
	SpawnPoint.bCommanderPod = true;
}

function RemoveOriginalSpawnPoints()
{
	local XComAlienPod SpawnPoint;
	
	foreach AllActors(class'XComAlienPod', SpawnPoint)
	{
		if (bKeepCommander && SpawnPoint.bCommanderPod)
		{
		}
		else
		{
			SpawnPoint.Destroy();
		}
	}
}

function AddNewSpawnPoints()
{
	local vector SpawnPtLoc;

	foreach PodSpawnPts(SpawnPtLoc)
	{
		Spawn(class'XComAlienPod',,, SpawnPtLoc,,, true);
	}
}