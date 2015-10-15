class XComSpawnAlienMutator extends XComMutator
	config(RandomSpawns);
	
var config bool USE_OVERWATCH;
var config bool DROP_TO_COVER;
var config bool REVEAL_SPAWN;
var config int MAX_DROP_DIST;
var config int MIN_DROP_DIST;
var config array<config string> ExcludeMaps;

var SeqAct_SpawnAlien SpawnAlienObj;
var array<vector> UnitsLoc;
var array<vector> PrevSpawnLoc;
var vector SpawnLoc;
var array<XComCoverPoint> CoverPoints;

function XGBattle BATTLE()
{
	return XComTacticalGRI(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kBattle;
}

function XComWorldData WORLD()
{
	return class'XComWorldData'.static.GetWorldData();
}

function bool IsLocationBlockedByRoof(vector TestLoc)
{
    local Actor kHitActor;
    local Vector vHitLoc, vHitNormal, vTraceStart, vTraceEnd;
	local bool bHit;
	
	vTraceStart = TestLoc + WORLD().WORLD_HalfFloorHeight * vect(0, 0, 1);
	vTraceEnd = TestLoc * vect(1, 1, 0) + SpawnAlienObj.iDropHeight * vect(0, 0, 1);
	bHit = WORLD().WorldTrace(vTraceStart, vTraceEnd, vHitLoc, vHitNormal, kHitActor);
	return bHit;
}

function bool IsCloseToPrevSpawnLoc(vector TestLoc)
{
	local vector kLoc;
	
	foreach PrevSpawnLoc(kLoc)
	{
		if (VSize(kLoc - TestLoc) <= 3 * WORLD().WORLD_StepSize)
		{
			return true;
		}
	}
	return false;
}

function bool IsFlankedByXCOM(XComCoverPoint kCover)
{
	local vector kLoc;
	
	foreach UnitsLoc(kLoc)
	{
		if (class'XGUnitNativeBase'.static.DoesFlankCover(kLoc, kCover))
		{
			return true;
		}
	}
	return false;
}

function bool IsInsideSpawnZone(vector CenterLoc, vector TestLoc)
{
	return (VSize(CenterLoc - TestLoc) >= MIN_DROP_DIST * WORLD().WORLD_StepSize &&
	        VSize(CenterLoc - TestLoc) <= MAX_DROP_DIST * WORLD().WORLD_StepSize);
}

function bool IsValidSpawnLocation(vector TestLoc)
{
	return (WORLD().IsPositionOnFloorAndValidDestination(TestLoc) && WORLD().Volume.EncompassesPoint(TestLoc));
}

function bool IsMutatorValid(string SeqActObjName)
{
	local array<SequenceObject> SequenceObjects;
	local SequenceObject Obj;
	local int SpawnAlienObjCount;
	local string CurMapName;
	
	class'Engine'.static.GetCurrentWorldInfo().GetGameSequence().FindSeqObjectsByClass(class'SeqAct_SpawnAlien', true, SequenceObjects);
	//using FindSeqObjectsByName freezes the game
	//class'Engine'.static.GetCurrentWorldInfo().GetGameSequence().FindSeqObjectsByName(SeqActObjName, false, SequenceObjects);
	
	SpawnAlienObjCount = 0;
	foreach SequenceObjects(Obj)
	{
		if (string(Obj.Name) == SeqActObjName)
		{
			`Log("XComSpawnAlienMutator: found obj " $ Obj.Name);
			SpawnAlienObj = SeqAct_SpawnAlien(Obj);
			++SpawnAlienObjCount;
		}
	}
	`Log("XComSpawnAlienMutator: SeqActObjName = " $ SeqActObjName);
	
	CurMapName = class'Engine'.static.GetCurrentWorldInfo().GetMapName();

	if (XGBattle_SP(BATTLE()).m_kDesc.m_iMissionType == eMission_Final)
	{
		`Log("XComSpawnAlienMutator: Final mission is on, skipping to defaults.");
		return false;
	}
	else if (ExcludeMaps.Find(CurMapName) != -1)
	{
		`Log("XComSpawnAlienMutator: current map(" $ CurMapName $ ") found in ExcludeMaps list, skipping to defaults.");
		return false;
	}
	else if (SpawnAlienObjCount == 0)
	{
		`Log("XComSpawnAlienMutator: Error! Can't find " $ SeqActObjName);
		return false;
	}
	else if (SpawnAlienObjCount > 1)
	{
		`Log("XComSpawnAlienMutator: Error! Multiple " $ SeqActObjName $ " objects found!");
		return false;
	}
	return true;
}

function MutateSpawnAlien(string SeqActObjName, PlayerController Sender)
{
	if (MAX_DROP_DIST == 0 || MAX_DROP_DIST > 100)
	{
		MAX_DROP_DIST = 36;
	}
	if (MAX_DROP_DIST < 14)
	{
		MAX_DROP_DIST = 14;
	}
	if (MAX_DROP_DIST - MIN_DROP_DIST < 7)
	{
		MIN_DROP_DIST = MAX_DROP_DIST - 7;
	}
	if (MIN_DROP_DIST < 1 || MIN_DROP_DIST > MAX_DROP_DIST)
	{
		MIN_DROP_DIST = 1;
	}
	
	`Log("XComSpawnAlienMutator: MutateSpawnAlien");
	`Log("XComSpawnAlienMutator: MIN_DROP_DIST = " $ MIN_DROP_DIST);
	`Log("XComSpawnAlienMutator: MAX_DROP_DIST = " $ MAX_DROP_DIST);
	
	if (IsMutatorValid(SeqActObjName) == true)
	{
		SpawnAlienObj.bUseOverwatch = USE_OVERWATCH;
		SpawnAlienObj.bRevealSpawn = REVEAL_SPAWN;
		if (GetUnitsLoc() == false)
		{
			`Log("XComSpawnAlienMutator: Can't find player location, skipping to defaults.");
			return;
		}
		if (GetRandomSpawnLoc() == false)
		{
			`Log("XComSpawnAlienMutator: Can't find good spawn point, skipping to defaults.");
			return;
		}
		PrevSpawnLoc.AddItem(SpawnLoc);
		MutateSpawnAlienObj();
	}
}

function bool GetUnitsLoc()
{
    local XGUnit kSoldier;
    local XGSquad kSquad;
	
	UnitsLoc.Length = 0;
	kSquad = XGBattle_SP(BATTLE()).GetHumanPlayer().GetSquad();
	kSoldier = kSquad.GetNextGoodMember(,,, false);
	while (kSoldier != none)
	{
		`Log("XComSpawnAlienMutator: Found good unit " $ kSoldier.Name);
		UnitsLoc.AddItem(kSoldier.Location);
        kSoldier = kSquad.GetNextGoodMember(kSoldier,, false);
	}
	if (UnitsLoc.Length < 1)
	{
		`Log("XComSpawnAlienMutator: Error! No good units found!");
		return false;
	}
	return true;
}

function GetCoverPoints()
{
	local vector kLoc;
	local array<XComCoverPoint> kCoverPts;
	local XComCoverPoint kCover;
	local float fRadius;
	
	fRadius = MAX_DROP_DIST * WORLD().WORLD_StepSize;
	
	CoverPoints.Length = 0;

	//foreach UnitsLoc(kLoc)
	//{
		kLoc = UnitsLoc[Rand(UnitsLoc.Length)];
		WORLD().GetCoverPoints(kLoc, fRadius, fRadius, kCoverPts, true);
	    foreach kCoverPts(kCover)
        {
            if(CoverPoints.Find('CoverLocation', kCover.CoverLocation) != -1 ||
			   IsCloseToPrevSpawnLoc(kCover.CoverLocation) ||
			   !IsInsideSpawnZone(kLoc, kCover.CoverLocation) ||
			   !IsValidSpawnLocation(kCover.CoverLocation) ||
			   /*XGAIPlayer(BATTLE().GetAIPlayer()).IsInBadArea(kCover.CoverLocation, none) ||*/
			   IsFlankedByXCOM(kCover) ||
			   IsLocationBlockedByRoof(kCover.CoverLocation))
            {
				//`Log("XComSpawnAlienMutator: Bad cover point at " $ string(kCover.CoverLocation));
                continue;
            }
			CoverPoints.AddItem(kCover);
			`Log("XComSpawnAlienMutator: Found good cover point at " $ string(kCover.CoverLocation));
		}
	//}
}

function bool GetRandomElevatedPoint()
{
	local XComCoverPoint kCover;
	local array<vector> vLocs;

	foreach CoverPoints(kCover)
	{
		if (WORLD().WorldBounds.Max.Z - kCover.CoverLocation.Z < kCover.CoverLocation.Z - WORLD().WorldBounds.Min.Z)
		{
			vLocs.AddItem(kCover.CoverLocation);
		}
	}
	if (vLocs.Length > 0)
	{
		SpawnLoc = vLocs[Rand(vLocs.Length)];
		return true;
	}
	return false;
}

function bool GetRandomSpawnLoc()
{
	local Vector CenterLoc, TestLoc;
	local int I;
	local bool bPrioritizeZ;
    
	/*local TCharacter tempTCharacter;

    tempTCharacter = XComGameReplicationInfo(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kGameCore.GetTCharacter(class'XGGameData'.static.MapPawnToCharacter(SpawnAlienObj.ForceAlienType));
	
	if (tempTCharacter.aProperties[eCP_NoCover] == 0)
	{
		`Log("XComSpawnAlienMutator: can take cover.");
	}*/
	
	if (DROP_TO_COVER == true)
	{
		GetCoverPoints();
		if (CoverPoints.Length > 0)
		{
			if (!GetRandomElevatedPoint())
			{
				SpawnLoc = CoverPoints[Rand(CoverPoints.Length)].CoverLocation;
			}
			`Log("XComSpawnAlienMutator: SpawnLoc = " $ SpawnLoc);
			return true;
		}
	}

	bPrioritizeZ = true;
	I = 0;
	while (I < 100)
	{
		CenterLoc = UnitsLoc[Rand(UnitsLoc.Length)];
		TestLoc = GetRandLoc(CenterLoc);
		`Log("XComSpawnAlienMutator: TestLoc = " $ TestLoc);
		SpawnLoc = WORLD().FindClosestValidLocation(TestLoc, false, bPrioritizeZ, false);
		if (IsValidSpawnLocation(SpawnLoc) && IsInsideSpawnZone(CenterLoc, SpawnLoc) &&
		    !IsCloseToPrevSpawnLoc(SpawnLoc) && !IsLocationBlockedByRoof(SpawnLoc))
		{
			`Log("XComSpawnAlienMutator: SpawnLoc = " $ SpawnLoc);
			return true;
		}
		bPrioritizeZ = !bPrioritizeZ;
		++I;
	}
	return false;
}

function vector GetRandLoc(vector CenterLoc)
{
	local Vector TestLoc, RandVec;
	local Rotator RandRot;
	
	RandVec = vect(0, 0, 0);
	RandVec.X = (MIN_DROP_DIST + (MAX_DROP_DIST -  MIN_DROP_DIST) * FRand()) * WORLD().WORLD_StepSize;
	RandRot = rot(0, 0, 0);
	RandRot.Yaw = Rand(65536);
	RandVec = RandVec >> RandRot;
	TestLoc = (CenterLoc + RandVec) * vect(1, 1, 0) + WORLD().GetPositionFromTileCoordinates(0, 0, Rand(WORLD().NumZ)) * vect(0, 0, 1);
	return TestLoc;
}

function CenterSpawnLocOnTile()
{
	local int X, Y, Z;
	WORLD().GetTileCoordinatesFromPosition(SpawnLoc, X, Y, Z);
	SpawnLoc = WORLD().GetPositionFromTileCoordinates(X, Y, Z);
}

function MutateSpawnAlienObj()
{
	local XComSpawnPoint_Alien SpawnPt;
	
	CenterSpawnLocOnTile();
	SpawnPt = Spawn(class'XComSpawnPoint_Alien',,,SpawnLoc,,, true);
	SpawnAlienObj.SpawnedUnit = none;
	SpawnAlienObj.OutputLinks[1].bHasImpulse = false;
	SpawnAlienObj.m_kDropIn = new class'XGAISpawnMethod_DropIn';
	SpawnAlienObj.m_kDropIn.InitDropIn(SpawnAlienObj.iDropHeight, SpawnAlienObj.bUseOverwatch, SpawnAlienObj.bTriggerOverwatch, SpawnAlienObj.bPlaySound, SpawnAlienObj.bRevealSpawn, SpawnAlienObj.bSpawnImmediately, SpawnAlienObj.ForceAlienType, SpawnAlienObj.kAdditionalSound, SpawnAlienObj);
	SpawnAlienObj.m_kDropIn.AddSpawnPoint(SpawnPt);
	if(SpawnAlienObj.bSpawnImmediately)
	{
		SpawnAlienObj.m_kDropIn.CheckContentLoaded();
	}
	SpawnAlienObj.OutputLinks[0].bHasImpulse = true;
	SpawnAlienObj.ActivateOutputLink(0);
}