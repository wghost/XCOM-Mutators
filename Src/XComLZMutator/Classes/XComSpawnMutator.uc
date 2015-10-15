class XComSpawnMutator extends XComMutator
	config(RandomSpawns);

const MAX_NUM_SEC = 16;

struct GridSection
{
    var Vector Center;
    var Vector Size;
	
	structdefaultproperties
	{
		Center=(X=0,Y=0,Z=0)
		Size=(X=0,Y=0,Z=0)
	}
};

var array<GridSection> Grid;
var vector PlayerStartLoc;
var vector OpStartLoc;
var bool CheckOp;
var bool IsCaptureAndHoldMission;
var int NumSecOrig;
var int NumSec;
var array<vector> RandLoc;

var config float PLAYER_PROXIMITY;
var config float OP_PROXIMITY;
var config bool AVOID_CAPTURE_ZONES;

function XGBattle BATTLE()
{
	return XComTacticalGRI(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kBattle;
}

function XComWorldData WORLD()
{
	return class'XComWorldData'.static.GetWorldData();
}

function InitBaseSpawnMutator(int aNumSec)
{
	NumSec = aNumSec;
	if (NumSec == 0)
	{
		`Log("XComSpawnMutator: Error! Num sections mus be non-zero!");
	}
	else if (NumSec > MAX_NUM_SEC)
	{
		NumSec = MAX_NUM_SEC;
	}
	NumSecOrig = NumSec; // save num sections needed
	if (PLAYER_PROXIMITY == 0)
	{
		PLAYER_PROXIMITY = 27;
	}
	if (OP_PROXIMITY == 0)
	{
		OP_PROXIMITY = 27;
	}
	`Log("XComSpawnMutator: NumSec = " $ NumSec);
	`Log("XComSpawnMutator: PLAYER_PROXIMITY = " $ PLAYER_PROXIMITY);
	IsCaptureAndHoldMission = (XGBattle_SP(BATTLE()).m_kDesc.m_iMissionType == eMission_CaptureAndHold);
	if (IsCaptureAndHoldMission)
	{
		`Log("XComSpawnMutator: AVOID_CAPTURE_ZONES = " $ AVOID_CAPTURE_ZONES);
	}
	if (!InitPlayerStartLoc())
	{
		`Log("XComSpawnMutator: Can't find player start location, skipping to defaults.");
		return;
	}
	CheckOp = false;
	if (InitOpStartLoc())
	{
		//NumSec += 1; // count covert operative in
		CheckOp = true;
		`Log("XComSpawnMutator: OP_PROXIMITY = " $ OP_PROXIMITY);
	}
	//NumSec += 1; // count player in
	//NumSec += NumSec % 2; // make NumSec even
	//`Log("XComSpawnMutator: Adjusted NumSec = " $ NumSec);
	BuildGrid();
}

function bool InitPlayerStartLoc()
{
	local array<XComSpawnPoint> SquadSpawnPts;
	local XComSpawnPoint Pt;
	local vector AvPt;
	local int NumPts;
	
	SquadSpawnPts = XGBattle_SP(BATTLE()).GetSpawnPoints(eTeam_XCom);
	NumPts = 0;
	foreach SquadSpawnPts(Pt)
	{
		if (Pt.Class == class'XComSpawnPoint')
		{
			`Log("XComSpawnMutator: Found SpawnPoint " $ Pt.Name $ " at " $ Pt.Location);
			AvPt += Pt.Location;
			++NumPts;
		}
	}
	if (NumPts == 0)
	{
		`Log("XComSpawnMutator: Error! No player spawn points found!");
		return false;
	}
	AvPt /= NumPts;
	`Log("XComSpawnMutator: Player Central Location " $ AvPt);
	PlayerStartLoc = AvPt;
	return true;
}

function bool InitOpStartLoc()
{
    local array<XComSpawnPoint> arrSpawnPoints;
    local XComSpawnPoint kSpawnPoint;
	
	if(XGBattle_SP(BATTLE()).m_kDesc.m_iMissionType == eMission_CovertOpsExtraction ||
	   XGBattle_SP(BATTLE()).m_kDesc.m_iMissionType == eMission_CaptureAndHold)
	{
		foreach AllActors(class'XComSpawnPoint', kSpawnPoint)
		{
			if(kSpawnPoint.GetUnitType() == UNIT_TYPE_CovertOperative)
			{
				arrSpawnPoints.AddItem(kSpawnPoint);
			}
		}
		//there can potentially be more than one spawn point on map, but for all existing maps there is just one
		if (arrSpawnPoints.Length != 1)
		{
			return false;
		}
		OpStartLoc = arrSpawnPoints[0].Location;
		`Log("XComSpawnMutator: Covert Operative start location = " $ OpStartLoc);
		return true;
	}
	return false;
}

function bool IsCloseToOtherRandLoc(vector TestLoc)
{
	local vector vLoc;
	
	foreach RandLoc(vLoc)
	{
		// 8 tiles "safety radius"
		if (VSizeSq(TestLoc - vLoc) < 8 * 8 * 96 * 96)
		{
			return true;
		}
	}
	return false;
}

function bool IsCloseToPlayerSpawnPoint(vector TestLoc)
{
	local array<XComSpawnPoint> SquadSpawnPts;
	local XComSpawnPoint Pt;
	
	SquadSpawnPts = XGBattle_SP(BATTLE()).GetSpawnPoints(eTeam_XCom);
	foreach SquadSpawnPts(Pt)
	{
		if (Pt.Class == class'XComSpawnPoint')
		{
			if (VSizeSq(Pt.Location - TestLoc) < PLAYER_PROXIMITY * PLAYER_PROXIMITY * 64 * 64)
			{
				return true;
			}
		}
	}
	return false;
}

function bool IsInsideCaptureVolume(vector TestLoc)
{
	local bool IsInside;
	local XComCapturePointVolume kVolume;
	IsInside = false;
	if (AVOID_CAPTURE_ZONES && IsCaptureAndHoldMission)
	{
		foreach AllActors(class'XComCapturePointVolume', kVolume)
		{
			if (kVolume.EncompassesPoint(TestLoc))
			{
				IsInside = true;
			}
		}
	}
	return IsInside;
}

function bool IsCloseToLZ(vector TestLoc)
{
	return (VSizeSq(PlayerStartLoc - TestLoc) < PLAYER_PROXIMITY * PLAYER_PROXIMITY * 64 * 64);
}

function bool IsCloseToOp(vector TestLoc)
{
	return (CheckOp && VSizeSq(OpStartLoc - TestLoc) < OP_PROXIMITY * OP_PROXIMITY * 64 * 64);
}

function bool IsInsideLevelVolume(vector TestLoc)
{
	return (WORLD().Volume.EncompassesPoint(TestLoc));
}

function bool IsValidSpawnLocation(vector TestLoc)
{
	return (WORLD().IsPositionOnFloorAndValidDestination(TestLoc) && !IsCloseToPlayerSpawnPoint(TestLoc) && !IsCloseToOtherRandLoc(TestLoc));
}

function bool IsBadLocation(vector TestLoc)
{
	return (!IsInsideLevelVolume(TestLoc) || IsCloseToLZ(TestLoc) || IsCloseToOp(TestLoc) || IsInsideCaptureVolume(TestLoc));
}

function BuildGrid()
{
	local GridSection Section;
	local array<GridSection> ArrRemove;
	// magic number to prevent infinite loops
	while (NumSec < 100)
	{
		CalculateGrid();
		ArrRemove.Length = 0;
		foreach Grid(Section)
		{
			if (IsBadLocation(Section.Center))
			{
				ArrRemove.AddItem(Section);
			}
		}
		//found enough points
		if (Grid.Length - ArrRemove.Length >= NumSecOrig)
		{
			break;
		}
		//NumSec += 2;
		++NumSec;
		`Log("XComSpawnMutator: Not enough sections left: " $ (Grid.Length - ArrRemove.Length) $ ", increasing NumSec to " $ NumSec);
	}
	foreach ArrRemove(Section)
	{
		Grid.RemoveItem(Section);
	}
	NumSec = Grid.Length;
	`Log("XComSpawnMutator: Final NumSec = " $ NumSec);
	/*foreach Grid(Section)
	{
		`Log("XComSpawnMutator: Section.Center " $ Section.Center);
	}*/
}

function CalculateGrid()
{
    local int NumSecX, NumSecY, X, Y, StepX, StepY, BeginX, BeginY;

	`Log("XComSpawnMutator: WORLD().NumX = " $ WORLD().NumX);
	`Log("XComSpawnMutator: WORLD().NumY = " $ WORLD().NumY);
	//NumSecX * NumSecY = NumSec
	if (WORLD().NumX > WORLD().NumY)
	{
		NumSecY = Sqrt(NumSec);
		NumSecX = NumSec / NumSecY + ((NumSecX * NumSecY) < NumSec ? 1 : 0);
	}
	else
	{
		NumSecX = Sqrt(NumSec);
		NumSecY = NumSec / NumSecX + ((NumSecX * NumSecY) < NumSec ? 1 : 0);
	}
	`Log("XComSpawnMutator: NumSecX = " $ NumSecX);
	`Log("XComSpawnMutator: NumSecY = " $ NumSecY);
	
	Grid.Length = 0;
	Grid.Add(NumSecX * NumSecY);
	
	BeginX = 4;
	BeginY = 4;
	StepX = (WORLD().NumX - 2 * BeginX) / NumSecX;
	StepY = (WORLD().NumY - 2 * BeginY) / NumSecY;
	
	`Log("XComSpawnMutator: BeginX = " $ BeginX);
	`Log("XComSpawnMutator: BeginY = " $ BeginY);
	`Log("XComSpawnMutator: StepX = " $ StepX);
	`Log("XComSpawnMutator: StepY = " $ StepY);
	
	for (X = 0; X < NumSecX; ++X)
	{
		for (Y = 0; Y < NumSecY; ++Y)
		{
			Grid[X + NumSecX * Y].Center = WORLD().GetPositionFromTileCoordinates(X * StepX + StepX / 2 + BeginX, Y * StepY + StepY / 2 + BeginY, WORLD().NumZ / 2);
			Grid[X + NumSecX * Y].Size.X = StepX * 96;
			Grid[X + NumSecX * Y].Size.Y = StepY * 96;
			Grid[X + NumSecX * Y].Size.Z = (WORLD().NumZ - 1) * 96;
		}
	}
}

function array<vector> GetRandomLocations(optional bool bRandomZ = true)
{
	local GridSection Section;
	local vector TestLoc, SpawnLoc;
	local int NumAttempts;
	local bool BadLoc;

	RandLoc.Length = 0;
	foreach Grid(Section)
	{
		NumAttempts = 0;
		BadLoc = true;
		while (NumAttempts < 100)
		{
			TestLoc.X = Section.Center.X + Section.Size.X * (FRand() - 0.5);
			TestLoc.Y = Section.Center.Y + Section.Size.Y * (FRand() - 0.5);
			if (bRandomZ)
			{
				TestLoc.Z = Section.Center.Z + Section.Size.Z * (FRand() - 0.5);
			}
			else
			{
				TestLoc.Z = 0;
			}
			SpawnLoc = WORLD().FindClosestValidLocation(TestLoc, false, false, false);
			if (!IsBadLocation(SpawnLoc) && IsValidSpawnLocation(SpawnLoc))
			{
				BadLoc = false;
				break;
			}
			++NumAttempts;
		}
		if (BadLoc)
		{
			SpawnLoc = WORLD().FindClosestValidLocation(Section.Center, false, false, false);
			`Log("XComSpawnMutator: Failed to find random location, using section center!");
		}
		RandLoc.AddItem(SpawnLoc);
	}
	`Log("XComSpawnMutator: Found " $ RandLoc.Length $ " random locations.");
	return RandLoc;
}
