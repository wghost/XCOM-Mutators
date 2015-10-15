class XComLZMutator extends XComMutator
	config(LZMutator);

struct CheckpointRecord
{
    var int IdxSaved;
	var Mutator NextMutator;

    structdefaultproperties
    {
        IdxSaved = -1;
    }
};

// direction, the soldiers will face
enum ELZDirection
{
   ELZD_North,
   ELZD_East,
   ELZD_South,
   ELZD_West
};

enum ESpawnLocation
{
	ESL_Default,						// use default map LZ
	ESL_Normal,							// spawn soldiers near evac zone
	ESL_Inside,							// spawn soldiers inside evac zone
	ESL_Alternate,						// use alternate location provided in config
	ESL_NoEvacZone						// create soldier spawn points only, without an evac zone
};
	
struct LZObjectData
{
	var Actor LevelActorObj;			// this is the base object (LZ FX)
	var Actor BuildingVolumeObj;		// this is Extraction Volume object
	var Actor PlayerStartObj;			// player start central point, probably irrelevant
	var Actor PointObj;					// central point of SoldierSpawns_DrpshipVol prefab, probably irrelevant
	var Actor SpawnPt1;					// spawn point (SoldierSpawns_DrpshipVol_Arc1)
	var Actor SpawnPt2;					// SoldierSpawns_DrpshipVol_Arc2
	var Actor SpawnPt3;					// SoldierSpawns_DrpshipVol_Arc3
	var Actor SpawnPt4;					// SoldierSpawns_DrpshipVol_Arc4
	var Actor SpawnPt5;					// SoldierSpawns_DrpshipVol_Arc5
	var Actor SpawnPt6;					// SoldierSpawns_DrpshipVol_7Arc0
	
	structdefaultproperties
	{
		LevelActorObj = None;
		BuildingVolumeObj = None;
		PlayerStartObj = None;
		PointObj = None;
		SpawnPt1 = None;
		SpawnPt2 = None;
		SpawnPt3 = None;
		SpawnPt4 = None;
		SpawnPt5 = None;
		SpawnPt6 = None;
	}
};
	
struct LZData
{
	// map and mission bias
	var string MapName;
	var XGGameData.EMissionType MissionType;
	var XGGameData.EFCMissionType CouncilType;
	// LZ location
	var vector StartLoc;
	var ELZDirection StartDir;
	var ESpawnLocation ESpawnLoc;
	// alternate spawn location
	var vector AltSpawnLoc;
	var ELZDirection AltSpawnDir;

	structdefaultproperties
	{
		MapName=""
		MissionType=eMission_None
		CouncilType=eFCMType_None
		ESpawnLoc=ESL_Default
		StartLoc=(X=0,Y=0,Z=0)
		StartDir=ELZD_North
		AltSpawnLoc=(X=0,Y=0,Z=0)
		AltSpawnDir=ELZD_North
	}
};
	
var config array <config LZData> LZArray;
var vector dps, dbv, dla, dsp1, dsp2, dsp3, dsp4, dsp5, dsp6, dp;
var vector psLoc, bvLoc, laLoc, sp1Loc, sp2Loc, sp3Loc, sp4Loc, sp5Loc, sp6Loc, pLoc;
var rotator StartRot, FaceRot, BaseRot;
var LZObjectData LZObjects;
var string CurMapName;
var int IdxSaved;

function MutateNotifyKismetOfLoad(PlayerController Sender)
{
	local array<SequenceObject> Variables;
	local array<SequenceObject> Events;
	local array<SequenceObject> Objects;
	local int I, J;
	local bool DisableKismetHideLZ;
	
	`Log("XComLZMutator: Checking MainSequence");
	DisableKismetHideLZ = false;
	
	/// if mutator is inactive for this map
	if (IdxSaved == -1)
	{
		return;
	}
	
	/// find Kismet int variables
	WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqVar_Int', true, Variables);
	for (J = 0; J < Variables.Length; ++J)
	{
		/// if Kismet variable named "SpawnGroupIndex" exists
		if (SequenceVariable(Variables[J]).VarName == 'SpawnGroupIndex')
		{
			`Log("XComLZMutator: found SpawnGroupIndex");
			DisableKismetHideLZ = true;
		}
	}
	
	if (DisableKismetHideLZ)
	{
		/// find OnKismetDataSerialized events
		WorldInfo.GetGameSequence().FindSeqObjectsByClass(class'SeqEvent_OnKismetDataSerialized', true, Events);
		for (I = 0; I < Events.Length; ++I)
		{
			Objects.Length = 0;
			/// check if this event has SeqAct_ToggleHidden action linked
			SequenceEvent(Events[I]).GetLinkedObjects(Objects, class'SeqAct_ToggleHidden', false);
			if (Objects.Length != 0)
			{
				`Log("XComLZMutator: found SeqAct_ToggleHidden: " $ Events[I].Name);
				/// disable SeqAct_ToggleHidden action
				SequenceEvent(Events[I]).bEnabled = false;
			}
		}
	}
}

function PostLoadSaveGame(PlayerController Sender)
{
	`Log("XComLZMutator: PostLoadSaveGame");
	`Log("XComLZMutator: saved idx = " $ IdxSaved);
	if (IdxSaved != -1)
	{
		`Log("XComLZMutator: Re-spawning LZ using saved idx");
		/// re-spawn saved LZ
		PostLevelLoaded(Sender);
	}
}

function PostLevelLoaded(PlayerController Sender)
{
	local LZData Data;
	local XGBattle Battle;
	local array<LZData> DataArray;
	local int idx;
    local XComMapMetaData MapData;
	local Mutator FindMutator;
	local array<XComSpawnPoint> SquadSpawnPts;
	local XComSpawnPoint Pt;
	
	`Log("XComLZMutator: PostLevelLoaded");
	`Log("XComLZMutator: LZArray.Length = " $ LZArray.Length);
	
	Battle = XComTacticalGRI(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kBattle;
	CurMapName = class'Engine'.static.GetCurrentWorldInfo().GetMapName();
	`Log("XComLZMutator: CurMapName = " $ CurMapName);
	MapData = class'XComMapManager'.static.GetCurrentMapMetaData();
	
	if (Battle == None)
	{
		`Log("XComLZMutator: Error! Battle == None!");
	}
	else if ( MapData.MissionType == eMission_CovertOpsExtraction ||
				MapData.MissionType == eMission_CaptureAndHold ||
				MapData.CouncilType == eFCMType_Extraction ||
				MapData.CouncilType == eFCMType_Rescue )
	{
		`Log("XComLZMutator: Disabled for MissionType " $ MapData.MissionType $ ", CouncilType " $ MapData.CouncilType);
	}
	else
	{
		if (MapData.CouncilType == eFCMType_Bomb)
		{
			FindMutator = class'Engine'.static.GetCurrentWorldInfo().Game.BaseMutator;
			while (FindMutator != none)
			{
				if (XComBombMutator(FindMutator) != none)
				{
					`Log("XComLZMutator: XComBombMutator is active, enabling LZ randomization for Bomb Defusal missions.");
					break;
				}
				FindMutator = FindMutator.NextMutator;
			}
			if (XComBombMutator(FindMutator) == none)
			{
				`Log("XComLZMutator: Disabled for MissionType " $ MapData.MissionType $ ", CouncilType " $ MapData.CouncilType);
				return;
			}
		}
		foreach LZArray(Data)
		{
			`Log("XComLZMutator: Data.MapName = " $ Data.MapName);
			// if current map name equals to config map name
			if ( CurMapName ~= Data.MapName )
			{
				// if mission type is not set for this config entry or matches with current mission type
				if ( Data.MissionType == eFCMType_None || MapData.MissionType == Data.MissionType )
				{
					// if council type is not set or matches with current mission council type
					if ( Data.CouncilType == eFCMType_None || MapData.CouncilType == Data.CouncilType )
					{
						`Log("XComLZMutator: config entry matches current map, adding");
						DataArray.AddItem(Data);
					}
				}
			}
		}
		if (DataArray.Length > 0)
		{
			`Log("XComLZMutator: DataArray.Length = " $ DataArray.Length);
			/// restore saved LZ on loading from save
			if (IdxSaved >= 0 && IdxSaved < DataArray.Length)
			{
				`Log("XComLZMutator: using saved idx");
				idx = IdxSaved;
			}
			/// choose random LZ
			else
			{
				`Log("XComLZMutator: using random idx");
				idx = Rand(DataArray.Length);
				IdxSaved = idx;
			}
			`Log("XComLZMutator: #" $ idx);
			Data = DataArray[idx];
			HideDropShip();
			if (Data.ESpawnLoc == ESL_Default)
			{
				`Log("XComLZMutator: using default map LZ");
			}
			else
			{
				if (!FindLZObjectsByArchetype(Data))
				{
					`Log("XComLZMutator: Error! Can't find LZ objects!");
				}
				else
				{
					if (LZObjects.LevelActorObj != None)
					{
						BaseRot = LZObjects.LevelActorObj.Rotation;
					}
					CalcLocations(Data);
					if (CurMapName ~= "LSupplyShip_ForestGrove" || CurMapName ~= "LSupplyShip_RockyGorge")
					{
						XComTacticalController(Sender).SetCameraYaw(FaceRot.Yaw * UnrRotToDeg - 180);
					}
					else
					{
						XComTacticalController(Sender).SetCameraYaw(FaceRot.Yaw * UnrRotToDeg + 270);
					}
					RemoveUnknownSpawnPoints();
					RespawnLZObjects(Data);
					/// re-initialize level volumes
					Battle.m_kLevel.m_arrBuildings.Length = 0;
					Battle.m_kLevel.InitFloorVolumes();
				}
			}
		}
		// do some logging
		SquadSpawnPts = XGBattle_SP(Battle).GetSpawnPoints(eTeam_XCom);
		foreach SquadSpawnPts(Pt)
		{
			`Log("XComLZMutator Test: SpawnPoint " $ Pt.Name $ " at " $ Pt.Location);
		}
	}
}

function RemoveUnknownSpawnPoints()
{
	local XComSpawnPoint Pt;
	
	foreach AllActors(class'XComSpawnPoint', Pt)
	{
		if (XComSpawnPoint_Alien(Pt) == none)
		{
			LogInternal("XComLZMutator: Found a SpawnPoint " $ Pt.Name $ " at " $ Pt.Location);
			if (Pt != LZObjects.SpawnPt1 && Pt != LZObjects.SpawnPt2 && Pt != LZObjects.SpawnPt3 &&
				Pt != LZObjects.SpawnPt4 && Pt != LZObjects.SpawnPt5 && Pt != LZObjects.SpawnPt6)
			{
				LogInternal("XComLZMutator: Found Bad SpawnPoint " $ Pt.Name $ " at " $ Pt.Location);
				Pt.Destroy();
			}
		}
	}
}

function RespawnLZObjects(LZData Data)
{
	if (LZObjects.LevelActorObj != None)
	{
		if (Data.ESpawnLoc != ESL_NoEvacZone)
		{
			Spawn(class'XComLevelActor', LZObjects.LevelActorObj.Owner, LZObjects.LevelActorObj.Tag, laLoc, StartRot, LZObjects.LevelActorObj, true);
		}
		LZObjects.LevelActorObj.SetHidden(true);
		LZObjects.LevelActorObj.Destroy();
	}
	if (LZObjects.BuildingVolumeObj != None)
	{
		if (Data.ESpawnLoc != ESL_NoEvacZone)
		{
			Spawn(class'XComBuildingVolume', LZObjects.BuildingVolumeObj.Owner, LZObjects.BuildingVolumeObj.Tag, bvLoc, AdjRotation(LZObjects.BuildingVolumeObj.Rotation), LZObjects.BuildingVolumeObj, true);
		}
		LZObjects.BuildingVolumeObj.SetHidden(true);
		LZObjects.BuildingVolumeObj.Destroy();
	}
	if (LZObjects.PlayerStartObj != None)
	{
		if (Data.ESpawnLoc != ESL_NoEvacZone)
		{
			Spawn(class'PlayerStart', LZObjects.PlayerStartObj.Owner, LZObjects.PlayerStartObj.Tag, psLoc, AdjRotation(LZObjects.PlayerStartObj.Rotation), LZObjects.PlayerStartObj, true);
		}
		LZObjects.PlayerStartObj.SetHidden(true);
		LZObjects.PlayerStartObj.Destroy();
	}
	if (LZObjects.PointObj != None)
	{
		if (Data.ESpawnLoc != ESL_NoEvacZone)
		{
			Spawn(class'PointInSpace', LZObjects.PointObj.Owner, LZObjects.PointObj.Tag, pLoc, AdjRotation(LZObjects.PointObj.Rotation), LZObjects.PointObj, true);
		}
		LZObjects.PointObj.SetHidden(true);
		LZObjects.PointObj.Destroy();
	}
	if (LZObjects.SpawnPt1 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt1.Owner, LZObjects.SpawnPt1.Tag, sp1Loc, FaceRot, LZObjects.SpawnPt1, true);
		LZObjects.SpawnPt1.SetHidden(true);
		LZObjects.SpawnPt1.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp1Loc, FaceRot, , true);
	}
	if (LZObjects.SpawnPt2 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt2.Owner, LZObjects.SpawnPt2.Tag, sp2Loc, FaceRot, LZObjects.SpawnPt2, true);
		LZObjects.SpawnPt2.SetHidden(true);
		LZObjects.SpawnPt2.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp2Loc, FaceRot, , true);
	}
	if (LZObjects.SpawnPt3 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt3.Owner, LZObjects.SpawnPt3.Tag, sp3Loc, FaceRot, LZObjects.SpawnPt3, true);
		LZObjects.SpawnPt3.SetHidden(true);
		LZObjects.SpawnPt3.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp3Loc, FaceRot, , true);
	}
	if (LZObjects.SpawnPt4 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt4.Owner, LZObjects.SpawnPt4.Tag, sp4Loc, FaceRot, LZObjects.SpawnPt4, true);
		LZObjects.SpawnPt4.SetHidden(true);
		LZObjects.SpawnPt4.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp4Loc, FaceRot, , true);
	}
	if (LZObjects.SpawnPt5 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt5.Owner, LZObjects.SpawnPt5.Tag, sp5Loc, FaceRot, LZObjects.SpawnPt5, true);
		LZObjects.SpawnPt5.SetHidden(true);
		LZObjects.SpawnPt5.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp5Loc, FaceRot, , true);
	}
	if (LZObjects.SpawnPt6 != None)
	{
		Spawn(class'XComSpawnPoint', LZObjects.SpawnPt6.Owner, LZObjects.SpawnPt6.Tag, sp6Loc, FaceRot, LZObjects.SpawnPt6, true);
		LZObjects.SpawnPt6.SetHidden(true);
		LZObjects.SpawnPt6.Destroy();
	}
	else
	{
		Spawn(class'XComSpawnPoint', , , sp6Loc, FaceRot, , true);
	}
}

function HideDropShip()
{
	local Actor A;
	
	foreach AllActors(class'Actor', A)
	{
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_12Arc1' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc10')
		{
			`Log("Test find prefabs: SoldierSpawns_DrpshipVol arc found: " $ string(A.Name));
			A.SetHidden(true);
			A.Destroy();
		}
		else if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc0' || 
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc1' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc2' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc3' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc4' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc5' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc6' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc7' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc8' ||
			A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_8Arc9')
		{
			`Log("Test find prefabs: SoldierSpawns_DrpshipVol arc found: " $ string(A.Name));
			Emitter(A).ShutDown();
			A.SetHidden(true);
			A.Destroy();
		}
		else if (A.ObjectArchetype.Name == 'PRE_SkyrangerGrounded_4Arc0' ||
				 A.ObjectArchetype.Name == 'PRE_SkyrangerGrounded_Arc2')
		{
			`Log("Test find prefabs: SkyrangerGrounded arc found: " $ string(A.Name));
			A.SetHidden(true);
			A.Destroy();
		}
		else if (A.ObjectArchetype.Name == 'PRE_SkyrangerGrounded_5Arc0')
		{
			`Log("Test find prefabs: SkyrangerGrounded arc found: " $ string(A.Name));
			AmbientSoundSimpleToggleable(A).StopPlaying();
			A.SetHidden(true);
			A.Destroy();
		}
		else if (A.ObjectArchetype.Name == 'PRE_SkyrangerGrounded_Arc1')
		{
			`Log("Test find prefabs: SkyrangerGrounded arc found: " $ string(A.Name));
			Emitter(A).ShutDown();
			A.SetHidden(true);
			A.Destroy();
		}
		else if (A.ObjectArchetype.Name == 'ARC_Skyranger_Ground_Periphery')
		{
			`Log("Test find prefabs: Skyranger_Ground_Periphery arc found: " $ string(A.Name));
			Emitter(A).ShutDown();
			A.SetHidden(true);
			A.Destroy();
		}
	}
}

function bool FindLZObjectsByArchetype(LZData Data)
{
	local Actor A;
	local int EvacObjCount, SpawnPointsCount, OtherObjCount;

	EvacObjCount = 0;
	SpawnPointsCount = 0;
	OtherObjCount = 0;
	
	foreach AllActors(class'Actor', A)
	{
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_12Arc0')
		{
			if (LZObjects.LevelActorObj == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_12Arc0 found: " $ string(A.Name));
				LZObjects.LevelActorObj = A;
				++EvacObjCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_12Arc0 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc0')
		{
			if (LZObjects.BuildingVolumeObj == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc0 found: " $ string(A.Name));
				LZObjects.BuildingVolumeObj = A;
				++EvacObjCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc0 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_2Arc0')
		{
			if (LZObjects.PlayerStartObj == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_2Arc0 found: " $ string(A.Name));
				LZObjects.PlayerStartObj = A;
				++OtherObjCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_2Arc0 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_12Arc1')
		{
			if (LZObjects.PointObj == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_12Arc1 found: " $ string(A.Name));
				LZObjects.PointObj = A;
				++OtherObjCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_12Arc1 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc1')
		{
			if (LZObjects.SpawnPt1 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc1 found: " $ string(A.Name));
				LZObjects.SpawnPt1 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc1 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc2')
		{
			if (LZObjects.SpawnPt2 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc2 found: " $ string(A.Name));
				LZObjects.SpawnPt2 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc2 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc3')
		{
			if (LZObjects.SpawnPt3 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc3 found: " $ string(A.Name));
				LZObjects.SpawnPt3 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc3 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc4')
		{
			if (LZObjects.SpawnPt4 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc4 found: " $ string(A.Name));
				LZObjects.SpawnPt4 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc4 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_Arc5')
		{
			if (LZObjects.SpawnPt5 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc5 found: " $ string(A.Name));
				LZObjects.SpawnPt5 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_Arc5 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
		if (A.ObjectArchetype.Name == 'SoldierSpawns_DrpshipVol_7Arc0')
		{
			if (LZObjects.SpawnPt6 == None)
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_7Arc0 found: " $ string(A.Name));
				LZObjects.SpawnPt6 = A;
				++SpawnPointsCount;
			}
			else
			{
				`Log("Find LZ objects: SoldierSpawns_DrpshipVol_7Arc0 found duplicate: " $ string(A.Name));
				A.SetHidden(true);
				A.Destroy();
			}
		}
	}
	if ( Data.ESpawnLoc != ESL_NoEvacZone && (EvacObjCount + SpawnPointsCount) != 8 )
	{
		return false;
	}
	return true;
}

function AdjustOffsets(ESpawnLocation ESpawnLoc)
{
	if (ESpawnLoc == ESL_Inside || ESpawnLoc == ESL_Alternate || ESpawnLoc == ESL_NoEvacZone)
	{
		dsp1.Y -= 288;
		dsp2.Y -= 288;
		dsp3.Y -= 288;
		dsp4.Y -= 288;
		dsp5.Y -= 288;
		dsp6.Y -= 288;
	}
}

function CalcLocations(LZData Data)
{
	local vector SpawnStartLoc;
	local rotator SpawnStartRot;

	// evac zone rotation
	StartRot.Yaw = int(Data.StartDir) * 16384;
	// soldier spawn rotation
	if (Data.ESpawnLoc == ESL_Alternate)
	{
		// alternate spawn location
		SpawnStartLoc = Data.AltSpawnLoc;
		SpawnStartRot.Yaw = int(Data.AltSpawnDir) * 16384;
	}
	else
	{
		// default spawn location
		SpawnStartLoc = Data.StartLoc;
		SpawnStartRot = StartRot;
	}
	// soldier face direction
	FaceRot.Yaw = (SpawnStartRot.Yaw + 16384)%65536;
	// adjust offsets for alternate spawn
	AdjustOffsets(Data.ESpawnLoc);
	// calc locations
	laLoc  = Data.StartLoc + (dla >> StartRot);
	bvLoc  = Data.StartLoc + (dbv >> StartRot);
	psLoc  = Data.StartLoc + (dps >> StartRot);
	pLoc   = Data.StartLoc + (dp >> StartRot);
	sp1Loc = SpawnStartLoc + (dsp1 >> SpawnStartRot);
	sp2Loc = SpawnStartLoc + (dsp2 >> SpawnStartRot);
	sp3Loc = SpawnStartLoc + (dsp3 >> SpawnStartRot);
	sp4Loc = SpawnStartLoc + (dsp4 >> SpawnStartRot);
	sp5Loc = SpawnStartLoc + (dsp5 >> SpawnStartRot);
	sp6Loc = SpawnStartLoc + (dsp6 >> SpawnStartRot);
	`Log("XComLZMutator: Spawn Point 1 Location: " $ string(sp1Loc));
	`Log("XComLZMutator: Spawn Point 2 Location: " $ string(sp2Loc));
	`Log("XComLZMutator: Spawn Point 3 Location: " $ string(sp3Loc));
	`Log("XComLZMutator: Spawn Point 4 Location: " $ string(sp4Loc));
	`Log("XComLZMutator: Spawn Point 5 Location: " $ string(sp5Loc));
	`Log("XComLZMutator: Spawn Point 6 Location: " $ string(sp6Loc));
}

function rotator AdjRotation(rotator ObjRot)
{
	local rotator adjRot;
	// compensate for evac volume non-zero default rotation
	adjRot.Yaw = StartRot.Yaw + (ObjRot.Yaw - BaseRot.Yaw);
	// another dirty fix
	if (CurMapName ~= "URB_SmallCemetery" || CurMapName ~= "DLC1_1_LowFriends")
	{
		adjRot.Yaw += 32768;
	}
	return adjRot;
}

defaultproperties
{
	IdxSaved = -1;
	//NewGroupTag = "LZMutatorGroup"
	LZObjects=(LevelActorObj=None,BuildingVolumeObj=None,PlayerStartObj=None,PointObj=None,SpawnPt1=None,SpawnPt2=None,SpawnPt3=None,SpawnPt4=None,SpawnPt5=None,SpawnPt6=None)
	// relative offsets for all the LZ objects
	// set for direct use of in-game mouse position coordinates
	dla  = (X =  0,  Y = 0,   Z =-64)
	dbv  = (X =  0,  Y =-47,  Z = 32)
	dps  = (X =  8,  Y = 189, Z = 16)
	dp   = (X =-240, Y = 432, Z =-64)
	dsp1 = (X = 192, Y = 384, Z =-16)
	dsp2 = (X = 0,   Y = 480, Z =-16)
	dsp3 = (X = 192, Y = 192, Z =-16)
	dsp4 = (X = 0,   Y = 288, Z =-16)
	dsp5 = (X =-192, Y = 384, Z =-16)
	dsp6 = (X =-192, Y = 192, Z =-16)
}