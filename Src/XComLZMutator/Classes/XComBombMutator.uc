class XComBombMutator extends XComSpawnMutator
	config(RandomSpawns);

const OBJ_DIST = 128;
	
struct AlienBomb
{
	var XComLevelActor Bomb;
	var XComInteractiveLevelActor Button;
	var XComLevelActor WaypointFloor;
	var Emitter FacingWaypoint;
	var Emitter Destroyed;
	var Emitter Active;
	var Emitter Inactive;
	var Emitter Exploding;
	var XComRebuildWorldDataVolume RebuildVolume;
	var XComSquadVisiblePoint VisiblePoint;
	var array<PointInSpace> ArrPoints;
	var vector Loc;
};

struct PowerNode
{
	var XComLevelActor Node;
	var XComInteractiveLevelActor Button;
	var Emitter Inactive;
	var Emitter Active;
	var XComRebuildWorldDataVolume RebuildVolume;
	var vector Loc;
};

var AlienBomb TheBomb;
var array<PowerNode> ArrNodes;
var array<vector> ArrNewLoc;
var bool Active;
var config int INITIAL_TIMER_VALUE;

struct CheckpointRecord
{
	var AlienBomb TheBomb;
	var array<PowerNode> ArrNodes;
	var Mutator NextMutator;
	var bool Active;
};

function MutateUpdateInteractClaim(string UnitObjName, PlayerController Sender)
{
	local XGUnit Unit, FoundUnit;

	if (!Active)
	{
		return;
	}
	
	`Log("XComBombMutator: UnitObjName = " $ UnitObjName);
	
	foreach AllActors(class'XGUnit', Unit)
	{
		if (string(Unit.Name) == UnitObjName)
		{
			FoundUnit = Unit;
			`Log("XComBombMutator: FoundUnit = " $ FoundUnit);
			break;
		}
	}
	
	if (FoundUnit != none && !Unit.IsAlien() && !Unit.IsExalt() && Unit.m_arrInteractPoints.Length == 0)
	{
		FixUpdateInteractClaim(FoundUnit);
	}
}

function FixUpdateInteractClaim(XGUnit Unit)
{
	local XComInteractPoint IntPt;
	local XComInteractiveLevelActor Button;
	local int I;

	if (VSizeSq2D(Unit.GetLocation() - TheBomb.Button.Location) <= WORLD().WORLD_StepSizeSquared)
	{
		if((TheBomb.Button != none) && TheBomb.Button.CanInteract(Unit, 'None'))
		{
			IntPt.Location = TheBomb.Button.Location;
			IntPt.Rotation = TheBomb.Button.Rotation;
			IntPt.InteractiveActor = TheBomb.Button;
			IntPt.InteractSocketName = 'None';
			IntPt.ModifyTileStaticFlags = 0;
			Unit.m_arrInteractPoints.AddItem(IntPt);
		}
	}
	for (I = 0; I < ArrNodes.Length; ++I)
	{
		if (VSizeSq2D(Unit.GetLocation() - ArrNodes[I].Button.Location) <= WORLD().WORLD_StepSizeSquared)
		{
			Button = ArrNodes[I].Button;
			`Log("Button = " $ Button);
			if (ArrNodes[I].Active.bCurrentlyActive && !ArrNodes[I].Button.CanInteract(Unit, 'None'))
			{
				Button.GotoState('_Pristine');
				class'XComWorldData'.static.GetWorldData().RebuildTileData(Button.Location, 96.0 * float(3), 64.0 * float(3));
			}
			if((ArrNodes[I].Button != none) && ArrNodes[I].Button.CanInteract(Unit, 'None'))
			{
				IntPt.Location = ArrNodes[I].Button.Location;
				IntPt.Rotation = ArrNodes[I].Button.Rotation;
				IntPt.InteractiveActor = ArrNodes[I].Button;
				IntPt.InteractSocketName = 'None';
				IntPt.ModifyTileStaticFlags = 0;
				Unit.m_arrInteractPoints.AddItem(IntPt);
			}
		}
	}
	`Log("Unit.m_arrInteractPoints.Length = " $ Unit.m_arrInteractPoints.Length);
}

function DoWorldDataRebuild(PlayerController Sender)
{
	local int I;
	local vector Loc;
		
	`Log("XComBombMutator: DoWorldDataRebuild");
	if (Active)
	{
		`Log("XComBombMutator: restoring from save");
		Loc = TheBomb.Loc;
		MoveBombObjects(Loc);
		for (I = 0; I < ArrNodes.Length; ++I)
		{
			Loc = ArrNodes[I].Loc;
			MoveNodeObjects(I, Loc);
		}
	}
}

function PostLevelLoaded(PlayerController Sender)
{
	local XComMapMetaData MapData;
	
	Active = false;
	
	MapData = class'XComMapManager'.static.GetCurrentMapMetaData();

	`Log("XComBombMutator: PostLevelLoaded");
	
	if (MapData.MissionType == eMission_Special && MapData.CouncilType == eFCMType_Bomb)
	{
		`Log("XComBombMutator: enabled");
	}
	else
	{
		`Log("XComBombMutator: disabled");
		return;
	}
	
	ModifyKismet();
	if (!FindBomb())
	{
		`Log("XComBombMutator: can't find the bomb, skipping to defaults");
		return;
	}
	if (!FindNodes())
	{
		`Log("XComBombMutator: can't find power nodes, skipping to defaults");
		return;
	}
	`Log("XComBombMutator: found " $ string(ArrNodes.Length) $ " nodes");
	
	InitBaseSpawnMutator(ArrNodes.Length + 1);
	ArrNewLoc = GetRandomLocations(false);
	if (ArrNewLoc.Length < ArrNodes.Length + 1)
	{
		`Log("XComBombMutator: can't find enough spawn locations, skipping to defaults");
		return;
	}

	MoveBomb();
	MoveNodes();
	Active = true;
}

function ModifyKismet()
{
	local array<SequenceObject> Objects;
	local array<SequenceObject> IntVariables;
	local SeqVar_Int TimerVariable;
	local int J;
	
	`Log("XComBombMutator: Checking MainSequence");
	
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'Sequence', true, Objects);
	for (J = 0; J < Objects.Length; ++J)
	{
		if (InStr(string(Objects[J].Name), "BombTutorial") != -1)
		{
			`Log("XComBombMutator: disabling BombTutorial sequence");
			Sequence(Objects[J]).SetEnabled(false);
		}
	}
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqVar_Int', true, IntVariables);
	TimerVariable = none;
    for(J = 0; J < IntVariables.Length; ++J)
    {
        if(SeqVar_Int(IntVariables[J]).VarName == 'Timer')
        {
            TimerVariable = SeqVar_Int(IntVariables[J]);
			break;
        }
    }
	if (TimerVariable != none)
	{
		if (INITIAL_TIMER_VALUE > 0)
		{
			TimerVariable.IntValue = INITIAL_TIMER_VALUE;
			`Log("XComBombMutator: initial timer value set to " $ string(TimerVariable.IntValue));
		}
	}
}

function bool FindBomb()
{
	local Actor A;
	local int NumObjs;
	
	`Log("XComBombMutator: locating the bomb");
	
	NumObjs = 0;
	foreach AllActors(class'Actor', A)
	{
		if (A.Class == Class'XComLevelActor' && A.ObjectArchetype.Name == 'ARC_AlienBomb_XLA')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Loc = A.Location;
			TheBomb.Bomb = XComLevelActor(A);
			NumObjs = 1;
		}
	}
	if (NumObjs == 0)
	{
		return false;
	}
	TheBomb.ArrPoints.Length = 0;
	foreach AllActors(class'Actor', A)
	{
		if (A.Class == Class'XComInteractiveLevelActor' && A.ObjectArchetype.Name == 'ARC_IA_HotButtonColumnHigh')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Button = XComInteractiveLevelActor(A);
			++ NumObjs;
		}
		if (A.Class == Class'XComLevelActor' && A.ObjectArchetype.Name == 'ARC_largeWaypoint_Floor')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.WaypointFloor = XComLevelActor(A);
			++ NumObjs;
		}
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_facingWaypoint')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.FacingWaypoint = Emitter(A);
			++ NumObjs;
		}
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Alien_Bomb_Destroyed')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Destroyed = Emitter(A);
			++ NumObjs;
		}
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Alien_Bomb_Active')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Active = Emitter(A);
			++ NumObjs;
		}
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Alien_Bomb_Inactive')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Inactive = Emitter(A);
			++ NumObjs;
		}
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Alien_Bomb_Exploding')
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.Exploding = Emitter(A);
			++ NumObjs;
		}
		if (A.Class == Class'XComRebuildWorldDataVolume' && VSize2D(TheBomb.Loc - A.Location) <= OBJ_DIST)
		{
			`Log("Found actor: " $ A.Name);
			if (TheBomb.RebuildVolume == none || VSize2D(TheBomb.Loc - A.Location) < VSize2D(TheBomb.Loc - TheBomb.RebuildVolume.Location))
			{
				TheBomb.RebuildVolume = XComRebuildWorldDataVolume(A);
				++ NumObjs;
			}
		}
		if (A.Class == Class'XComSquadVisiblePoint' && VSize2D(TheBomb.Loc - A.Location) <= OBJ_DIST)
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.VisiblePoint = XComSquadVisiblePoint(A);
			++ NumObjs;
		}
		if (A.Class == Class'PointInSpace' && VSize2D(TheBomb.Loc - A.Location) <= OBJ_DIST)
		{
			`Log("Found actor: " $ A.Name);
			TheBomb.ArrPoints.AddItem(PointInSpace(A));
			++ NumObjs;
		}
	}
	if (NumObjs < 11)
	{
		return false;
	}
	return true;
}

function MoveBomb()
{
	local vector Loc, FarLoc;
	local float Dist2, FarDist2;
	
	`Log("XComBombMutator: moving the bomb");
	
	FarLoc = ArrNewLoc[0];
	FarDist2 = 0;
	foreach ArrNewLoc(Loc)
	{
		Dist2 = VSizeSq2D(Loc - PlayerStartLoc);
		if (Dist2 > FarDist2)
		{
			FarLoc = Loc;
			FarDist2 = Dist2;
		}
	}
	MoveBombObjects(FarLoc);
	ArrNewLoc.RemoveItem(FarLoc);
}

function MoveBombObjects(vector Loc)
{
	local int I;
	local vector NewLoc;
	
	NewLoc = Loc;
	NewLoc.Z = WORLD().GetFloorZForPosition(NewLoc, true);
	TheBomb.Bomb.SetLocation(NewLoc);
	`Log("XComBombMutator: Bomb " $ TheBomb.Bomb.Name $ " Location " $ TheBomb.Bomb.Location);
	//TheBomb.Bomb.SnapToGround();
	TheBomb.Loc = TheBomb.Bomb.Location;
	TheBomb.Button.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: Button " $ TheBomb.Button.Name $ " Location " $ TheBomb.Button.Location);
	TheBomb.WaypointFloor.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: WaypointFloor " $ TheBomb.WaypointFloor.Name $ " Location " $ TheBomb.WaypointFloor.Location);
	TheBomb.Destroyed.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: Destroyed " $ TheBomb.Destroyed.Name $ " Location " $ TheBomb.Destroyed.Location);
	TheBomb.Active.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: Active " $ TheBomb.Active.Name $ " Location " $ TheBomb.Active.Location);
	TheBomb.Inactive.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: Inactive " $ TheBomb.Inactive.Name $ " Location " $ TheBomb.Inactive.Location);
	TheBomb.Exploding.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: Exploding " $ TheBomb.Exploding.Name $ " Location " $ TheBomb.Exploding.Location);
	TheBomb.RebuildVolume.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: RebuildVolume " $ TheBomb.RebuildVolume.Name $ " Location " $ TheBomb.RebuildVolume.Location);
	TheBomb.VisiblePoint.SetLocation(TheBomb.Loc);
	`Log("XComBombMutator: VisiblePoint " $ TheBomb.VisiblePoint.Name $ " Location " $ TheBomb.VisiblePoint.Location);
	for (I = 0; I < TheBomb.ArrPoints.Length; ++I)
	{
		TheBomb.ArrPoints[I].SetLocation(TheBomb.Loc + vect(0,0,206));
		`Log("XComBombMutator: ArrPoints[" $ I $ "] " $ TheBomb.ArrPoints[I].Name $ " Location " $ TheBomb.ArrPoints[I].Location);
	}
	DestroyFacingWaypoint();
}

function DestroyFacingWaypoint()
{
	local Actor A;
	
	foreach AllActors(class'Actor', A)
	{
		if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_facingWaypoint')
		{
			`Log("Found FacingWaypoint actor: " $ A.Name);
			TheBomb.FacingWaypoint = Emitter(A);
			TheBomb.FacingWaypoint.ShutDown();
			TheBomb.FacingWaypoint.SetHidden(true);
			TheBomb.FacingWaypoint.Destroy();
		}
	}
}

function bool FindNodes()
{
	local Actor A;
	local PowerNode PNode;
	local int NumObjs, NumSubObjs, I;
	
	`Log("XComBombMutator: locating nodes");
	
	ArrNodes.Length = 0;
	NumObjs = 0;
	foreach AllActors(class'Actor', A)
	{
		if (A.Class == Class'XComLevelActor' && A.ObjectArchetype.Name == 'ARC_AlienEnergyNode_XLA')
		{
			`Log("Found actor: " $ A.Name);
			PNode.Node = XComLevelActor(A);
			PNode.Loc = A.Location;
			ArrNodes.AddItem(PNode);
			++NumObjs;
		}
	}
	if (NumObjs < 1)
	{
		return false;
	}
	NumSubObjs = 0;
	foreach AllActors(class'Actor', A)
	{
		for (I = 0; I < ArrNodes.Length; ++I)
		{
			if (A.Class == Class'XComInteractiveLevelActor' && A.ObjectArchetype.Name == 'ARC_IA_HotButtonColumnLow' && VSize2D(ArrNodes[I].Loc - A.Location) <= OBJ_DIST)
			{
				`Log("Found actor: " $ A.Name);
				ArrNodes[I].Button = XComInteractiveLevelActor(A);
				++ NumSubObjs;
			}
			if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Energy_Node_Inactive' && VSize2D(ArrNodes[I].Loc - A.Location) <= OBJ_DIST)
			{
				`Log("Found actor: " $ A.Name);
				ArrNodes[I].Inactive = Emitter(A);
				++ NumSubObjs;
			}
			if (A.Class == Class'Emitter' && A.ObjectArchetype.Name == 'ARC_Energy_Node_Active' && VSize2D(ArrNodes[I].Loc - A.Location) <= OBJ_DIST)
			{
				`Log("Found actor: " $ A.Name);
				ArrNodes[I].Active = Emitter(A);
				++ NumSubObjs;
			}
			if (A.Class == Class'XComRebuildWorldDataVolume' && VSize2D(ArrNodes[I].Loc - A.Location) <= OBJ_DIST)
			{
				`Log("Found actor: " $ A.Name);
				if (ArrNodes[I].RebuildVolume == none || VSize2D(ArrNodes[I].Loc - A.Location) < VSize2D(ArrNodes[I].Loc - ArrNodes[I].RebuildVolume.Location))
				{
					ArrNodes[I].RebuildVolume = XComRebuildWorldDataVolume(A);
					++ NumSubObjs;
				}
			}
		}
	}
	if (NumSubObjs < NumObjs * 4)
	{
		return false;
	}
	return true;
}

function MoveNodes()
{
	local int I;
	local vector Loc;
	
	`Log("XComBombMutator: moving nodes");
	
	for (I = 0; I < ArrNodes.Length; ++I)
	{
		Loc = ArrNewLoc[0];
		MoveNodeObjects(I, Loc);
		ArrNewLoc.RemoveItem(Loc);
	}
}

function MoveNodeObjects(int I, vector Loc)
{
	local vector NewLoc;
	NewLoc = Loc;
	NewLoc.Z = WORLD().GetFloorZForPosition(NewLoc, true);
	ArrNodes[I].Node.SetLocation(NewLoc);
	`Log("XComBombMutator: Node " $ ArrNodes[I].Node.Name $ " Location " $ ArrNodes[I].Node.Location);
	//ArrNodes[I].Node.SnapToGround();
	ArrNodes[I].Loc = ArrNodes[I].Node.Location;
	ArrNodes[I].Button.SetLocation(ArrNodes[I].Loc);
	`Log("XComBombMutator: Button " $ ArrNodes[I].Button.Name $ " Location " $ ArrNodes[I].Button.Location);
	ArrNodes[I].Inactive.SetLocation(ArrNodes[I].Loc);
	`Log("XComBombMutator: Inactive " $ ArrNodes[I].Inactive.Name $ " Location " $ ArrNodes[I].Inactive.Location);
	ArrNodes[I].Active.SetLocation(ArrNodes[I].Loc);
	`Log("XComBombMutator: Active " $ ArrNodes[I].Active.Name $ " Location " $ ArrNodes[I].Active.Location);
	ArrNodes[I].RebuildVolume.SetLocation(ArrNodes[I].Loc);
	`Log("XComBombMutator: Active " $ ArrNodes[I].Active.Name $ " Location " $ ArrNodes[I].Active.Location);
}