class XGStrategyAI_Mod extends XGStrategyAI
	config(StrategyAIMod);

enum EMissionMod
{
	EMissionMod_Abduction,
	EMissionMod_UFO,
	EMissionMod_Terror,
	EMissionMod_Special,
	EMissionMod_BigUFO,
	EMissionMod_Extraction,
	EMissionMod_CaptureAndHold,
	EMissionMod_ExaltRaid,
	EMissionMod_AlienBase,
	EMissionMod_MAX
};
	
enum EPodTypeMod
{
	EPodTypeMod_Commander,
	EPodTypeMod_Soldier,
	EPodTypeMod_Terror,
	EPodTypeMod_Special,
	EPodTypeMod_Elite,
	EPodTypeMod_Exalt,
	EPodTypeMod_ExaltElite,
	EPodTypeMod_Forced,
	EPodTypeMod_MAX
};

struct TPodSpecies
{
	var ECharacter MainAlien;
	var ECharacter SupportAlien1;
	var ECharacter SupportAlien2;
	var int MainChance;
	var int Support1Chance;
	var int Support2Chance;
	var int PodChance;
	var int PodLimit;
	var int MinAliens;
	var int MaxAliens;
	var int LeaderLevel;
	var int PodDifficulty;
	
	structdefaultproperties
	{
		MainChance = 100
		Support1Chance = 100
		Support2Chance = 100
		PodChance = 0
		PodLimit = -1
		MinAliens = 1
		MaxAliens = 3
		LeaderLevel = -1
		PodDifficulty = 0
	}
};

struct TAlienNumbers
{
	var int MinPods;
	var int MaxPods;

	structdefaultproperties
	{
		MinPods = 1
		MaxPods = 4
	}
};

struct TPodType
{
	var EPodTypeMod ID;
	var int TypeChance;

	structdefaultproperties
	{
		TypeChance = 0
	}
};

struct TSpeciesModifier
{
	var int ID; // I'd rather use a map<name,ID> here, but those are native only in uc
	var int Month;
	var int PodChance;
	var int PodLimit;
	var int MinAliens;
	var int MaxAliens;
	var int LeaderLevel;
	var int PodDifficulty;
	
	structdefaultproperties
	{
		ID=0
		Month=999
		PodChance = -1
		PodLimit = -2
		MinAliens = -1
		MaxAliens = -1
		LeaderLevel = -2
		PodDifficulty = -1
	}
};

struct TPodTypeModifier
{
	var EPodTypeMod ID;
	var int Month;
	var int TypeChance;

	structdefaultproperties
	{
		Month=999
		TypeChance = -1
	}
};

struct TAlienNumbersModifiers
{
	var int Month;
	var int MinPods;
	var int MaxPods;

	structdefaultproperties
	{
		Month = 999;
		MinPods = -1
		MaxPods = -1
	}
};

struct TForcedSpecial
{
	var EFCMission FCMissionID;
	var array<int> ForcedPodTypes;
};

// new squad template

struct TAlienPod_Mod
{
    var EPodTypeMod PodType;
    var XGGameData.ECharacter Main;
    var XGGameData.ECharacter Support1;
    var XGGameData.ECharacter Support2;
    var int MainNum;
	var int Support1Num;
	var int Support2Num;
	var bool UseAltWeapon;
	var int LeaderLevel;

	structdefaultproperties
	{
		PodType = EPodTypeMod_Soldier
		Main = eChar_None
		Support1 = eChar_None
		Support2 = eChar_None
		MainNum = 1
		Support1Num = 0
		Support2Num = 0
		UseAltWeapon = false
		LeaderLevel = 0
	}
};

struct TAlienSquad_Mod
{
    var array<TAlienPod_Mod> Pods;
    var int NumDynamicAliens;
	
	structdefaultproperties
	{
		NumDynamicAliens = 0
	}
};

// new squad template end

var config bool EnableAlienResources;
var config bool EnableAlienResearch;
var config bool EnableAlienLeaders;
var config bool EnableRandomCommanders;
var config bool AlwaysSpawnAtLeastOneMainAlien;
var config bool EnableAmbushUFOs;
var config bool DiffDecreaseProbability;

var config float PodsDifficultyMultiplier;
var config EShipType SmallestBigUFO;
var config float ShipSizeMultiplier;
var config int CrashedUFOSurviedPodsPercentage;
var config int CrashedUFOSurvedAliensPercentage;
var config int AmbushUFOAdditionalPodsPercentage;
var config int AmbushUFOAdditionalAliensPercentage;
var config float LeaderLevelProgressionMultiplier;
var config float AdditionalAliensPerPodMultiplier;
var config int SpecialMissionNumDynamicAliens;
var config float SpecialMissionDynamicAliensMultiplier;
var config float DiffProbabilityDivisor;

var config array<EFCMission> ExcludeSpecial;
var config array<TForcedSpecial> ForcedSpecial;

var config TAlienNumbers AbductionPodNumbers;
var config TAlienNumbers TerrorPodNumbers;
var config TAlienNumbers UFOPodNumbers;
var config TAlienNumbers SpecialPodNumbers;
var config TAlienNumbers ExtractionPodNumbers;
var config TAlienNumbers CaptureAndHoldPodNumbers;
var config TAlienNumbers ExaltRaidPodNumbers;
var config TAlienNumbers AlienBasePodNumbers;

var config array<TPodType> AbductionPodTypes;
var config array<TPodType> TerrorPodTypes;
var config array<TPodType> UFOPodTypes;
var config array<TPodType> SpecialPodTypes;
var config array<TPodType> BigUFOPodTypes;
var config array<TPodType> ExtractionPodTypes;
var config array<TPodType> CaptureAndHoldPodTypes;
var config array<TPodType> ExaltRaidPodTypes;
var config array<TPodType> AlienBasePodTypes;

var config array<TPodSpecies> PossibleCommanders;
var config array<TPodSpecies> PossibleSoldiers;
var config array<TPodSpecies> PossibleTerrorists;
var config array<TPodSpecies> PossibleSpecial;
var config array<TPodSpecies> PossibleElites;
var config array<TPodSpecies> PossibleExalt;
var config array<TPodSpecies> PossibleExaltElite;
var config array<TPodSpecies> PossibleForced;

var config array<TSpeciesModifier> CommandersMonthlyModifiers;
var config array<TSpeciesModifier> SoldiersMonthlyModifiers;
var config array<TSpeciesModifier> TerroristsMonthlyModifiers;
var config array<TSpeciesModifier> SpecialMonthlyModifiers;
var config array<TSpeciesModifier> ElitesMonthlyModifiers;
var config array<TSpeciesModifier> ExaltMonthlyModifiers;
var config array<TSpeciesModifier> ExaltEliteMonthlyModifiers;

var config array<TPodTypeModifier> AbductionPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> TerrorPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> UFOPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> SpecialPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> BigUFOPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> ExtractionPodTypesMonthlyModifiers;
var config array<TPodTypeModifier> CaptureAndHoldPodTypesMonthlyModifiers;

var config array<TAlienNumbersModifiers> AbductionPodNumbersMonthlyModifiers;
var config array<TAlienNumbersModifiers> TerrorPodNumbersMonthlyModifiers;
var config array<TAlienNumbersModifiers> UFOPodNumbersMonthlyModifiers;
var config array<TAlienNumbersModifiers> SpecialPodNumbersMonthlyModifiers;
var config array<TAlienNumbersModifiers> ExtractionPodNumbersMonthlyModifiers;
var config array<TAlienNumbersModifiers> CaptureAndHoldPodNumbersMonthlyModifiers;

var array<int> CommandersPodTypesCounter;
var array<int> SoldiersPodTypesCounter;
var array<int> TerroristsPodTypesCounter;
var array<int> SpecialPodTypesCounter;
var array<int> ElitesPodTypesCounter;
var array<int> ExaltPodTypesCounter;
var array<int> ExaltElitePodTypesCounter;
var array<int> ForcedPodTypesCounter;

var int ForcedID;
var int MissionDifficulty;

event PostBeginPlay()
{
	`Log("XGStrategyAI_Mod is active!");
    super.PostBeginPlay();
}

function TAlienSquad ConvertSquad(out TAlienSquad_Mod AlienSquad_Mod)
{
	local TAlienSquad ConvertedSquad;
	local int I;
	
	ConvertedSquad.arrPods.Add(AlienSquad_Mod.Pods.Length);
	ConvertedSquad.iNumDynamicAliens = AlienSquad_Mod.NumDynamicAliens;
	`Log("XGStrategyAI_Mod: iNumDynamicAliens = " $ ConvertedSquad.iNumDynamicAliens);
	for (I = 0; I < AlienSquad_Mod.Pods.Length; ++I)
	{
		switch (AlienSquad_Mod.Pods[I].PodType)
		{
			case EPodTypeMod_Commander:
				ConvertedSquad.arrPods[I].eType = ePodType_Commander;
				break;
			case EPodTypeMod_Terror:
				ConvertedSquad.arrPods[I].eType = ePodType_Secondary;
				break;
			default:
				ConvertedSquad.arrPods[I].eType = ePodType_Soldier;
				break;
		}
		if (AlienSquad_Mod.Pods[I].MainNum > 0)
		{
			ConvertedSquad.arrPods[I].eMain = AlienSquad_Mod.Pods[I].Main;
			`Log("XGStrategyAI_Mod: eMain = " $ ConvertedSquad.arrPods[I].eMain);
			`Log("XGStrategyAI_Mod: MainNum = " $ AlienSquad_Mod.Pods[I].MainNum);
			if (AlienSquad_Mod.Pods[I].MainNum > 1)
			{
				ConvertedSquad.arrPods[I].eMainAltWeapon = EItemType(ConvertedSquad.arrPods[I].eMainAltWeapon + 64);
			}
		}
		if (AlienSquad_Mod.Pods[I].Support1Num > 0)
		{
			ConvertedSquad.arrPods[I].eSupport1 = AlienSquad_Mod.Pods[I].Support1;
			`Log("XGStrategyAI_Mod: eSupport1 = " $ ConvertedSquad.arrPods[I].eSupport1);
			if (AlienSquad_Mod.Pods[I].Support1Num > 1)
			{
				ConvertedSquad.arrPods[I].eSupport1AltWeapon = EItemType(AlienSquad_Mod.Pods[I].Support1Num - 1);
			}
		}
		if (AlienSquad_Mod.Pods[I].Support2Num > 0)
		{
			ConvertedSquad.arrPods[I].eSupport2 = AlienSquad_Mod.Pods[I].Support2;
			`Log("XGStrategyAI_Mod: eSupport2 = " $ ConvertedSquad.arrPods[I].eSupport2);
			if (AlienSquad_Mod.Pods[I].Support2Num > 1)
			{
				ConvertedSquad.arrPods[I].eSupport2AltWeapon = EItemType(AlienSquad_Mod.Pods[I].Support2Num - 1);
			}
		}
		if (AlienSquad_Mod.Pods[I].UseAltWeapon)
		{
			ConvertedSquad.arrPods[I].eMainAltWeapon = EItemType(ConvertedSquad.arrPods[I].eMainAltWeapon + 128);
		}
		if (EnableAlienLeaders && AlienSquad_Mod.Pods[I].LeaderLevel > 0)
		{
			ConvertedSquad.arrPods[I].eMainAltWeapon = EItemType(ConvertedSquad.arrPods[I].eMainAltWeapon + AlienSquad_Mod.Pods[I].LeaderLevel);
			`Log("XGStrategyAI_Mod: LeaderLevel = " $ AlienSquad_Mod.Pods[I].LeaderLevel);
			`Log("XGStrategyAI_Mod: LeaderLevel = " $ string(int(ConvertedSquad.arrPods[I].eMainAltWeapon)));
		}
	}

	return ConvertedSquad;
}

function int GetMonth_Mod()
{
	if (EnableAlienResearch)
	{
		return STAT_GetStat(1) / 28;
	}
	return GetMonth();
}

function TAlienSquad_Mod DetermineCovertOpsSquad_Mod()
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	
	MissionDifficulty = 100;
	
	NumPods = RollNumPods(EMissionMod_Extraction, 0);
	PodTypes = RollPodTypes(EMissionMod_Extraction, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);
	
	return AlienSquad;
}

function TAlienSquad_Mod DetermineCaptureAndHoldSquad_Mod()
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	
	MissionDifficulty = 100;
	
	NumPods = RollNumPods(EMissionMod_CaptureAndHold, 0);
	PodTypes = RollPodTypes(EMissionMod_CaptureAndHold, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);
	
	return AlienSquad;
}

function TAlienSquad_Mod DetermineExaltRaidSquad_Mod()
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	
	MissionDifficulty = 100;
	
	NumPods = RollNumPods(EMissionMod_ExaltRaid, 0);
	PodTypes = RollPodTypes(EMissionMod_ExaltRaid, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);
	
	return AlienSquad;
}

function TAlienSquad_Mod DetermineAlienBaseSquad_Mod()
{
	local TAlienSquad_Mod AlienSquad;
	local TAlienPod_Mod AlienPod;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	
	MissionDifficulty = 100;
	
	NumPods = RollNumPods(EMissionMod_AlienBase, 0);
	PodTypes = RollPodTypes(EMissionMod_AlienBase, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);

	AlienPod.PodType = EPodTypeMod_Commander;
	AlienPod.Main = eChar_SectoidCommander;
	AlienPod.MainNum = 1;
	AlienPod.LeaderLevel = RollLeaderLevel();
	AlienPod.Support1 = eChar_MutonElite;
	AlienPod.Support2 = eChar_MutonElite;
	AlienPod.Support1Num = 1 + Rand(2);
	AlienPod.Support2Num = 1 + Rand(2);
	AlienSquad.Pods.AddItem(AlienPod);
	
	return AlienSquad;
}

function TAlienSquad_Mod DetermineSpecialMissionSquad_Mod(ECharacter eChar, EFCMission eMission, bool bAssault)
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods, I;
	
	MissionDifficulty = 100;

	NumPods = RollNumPods(EMissionMod_Special, 0);
	
	ForcedID = ForcedSpecial.Find('FCMissionID', eMission);
	`Log("XGStrategyAI_Mod: ForcedID = " $ ForcedID);
	if (ForcedID != -1)
	{
		for (I = 0; I < NumPods; ++I)
		{
			PodTypes.AddItem(EPodTypeMod_Forced);
		}
	}
	else
	{
		PodTypes = RollPodTypes(EMissionMod_Special, NumPods);
	}
	if (bAssault)
	{
		AlienSquad = RollAlienSquad(PodTypes, 50); // 50% more aliens per pod for assault missions
		AlienSquad.NumDynamicAliens = 0;
	}
	else
	{
		AlienSquad = RollAlienSquad(PodTypes);
		AlienSquad.NumDynamicAliens = SpecialMissionNumDynamicAliens + GetMonth_Mod()*SpecialMissionDynamicAliensMultiplier;
	}
	`Log("XGStrategyAI_Mod: bAssault = " $ bAssault);
	`Log("XGStrategyAI_Mod: SpecialMissionNumDynamicAliens = " $ SpecialMissionNumDynamicAliens);
	`Log("XGStrategyAI_Mod: NumDynamicAliens = " $ AlienSquad.NumDynamicAliens);
	
	return AlienSquad;
}

function TAlienSquad_Mod DetermineTerrorSquad_Mod()
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	//local int MissionDiff;
	
	MissionDifficulty = 100;
	
	//MissionDiff = Game().GetNumMissionsTaken(eMission_TerrorSite);
	NumPods = RollNumPods(EMissionMod_Terror, 0);
	PodTypes = RollPodTypes(EMissionMod_Terror, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);
	
	return AlienSquad;
}

function EShipType ConvertShipType(EShipType ShipType)
{
	if (ShipType < eShip_MAX)
	{
		return ShipType;
	}
	switch (ShipType)
	{
		case 10:
			return eShip_UFOSmallScout;
		case 11:
			return eShip_UFOLargeScout;
		case 12:
			return eShip_UFOAbductor;
		case 13:
			return eShip_UFOSupply;
		case 14:
			return eShip_UFOBattle;
		default:
			return eShip_UFOSmallScout;
	}
}

function TAlienSquad_Mod DetermineUFOSquad_Mod(XGShip_UFO UFO, bool Landed, EShipType ShipType)
{
	local TAlienSquad_Mod AlienSquad;
	local TAlienPod_Mod AlienPod;
	local array<EPodTypeMod> PodTypes;
	local int NumPods, ShipSize, NumPodsModifier, MinNumPods, MaxNumPods, NumAliensModifier;
	local EMissionMod UFOMissionType;

	ShipSize = ShipType - eShip_UFOSmallScout;
	if (ShipType == eShip_UFOEthereal)
	{
		ShipSize = eShip_UFOLargeScout - eShip_UFOSmallScout;
	}
	if (ShipSize >= (SmallestBigUFO - eShip_UFOSmallScout))
	{
		UFOMissionType = EMissionMod_BigUFO;
	}
	else
	{
		UFOMissionType = EMissionMod_UFO;
	}
	`Log("XGStrategyAI_Mod: ShipSize = " $ ShipSize);
	MissionDifficulty = ShipSize;
	NumPodsModifier = ShipSize * ShipSizeMultiplier;
	NumPods = RollNumPods(UFOMissionType, NumPodsModifier);
	NumAliensModifier = 0;
	if (!Landed) // crashed UFOs have less pods
	{
		MaxNumPods = NumPods;
		MinNumPods = float(NumPods) * float(CrashedUFOSurviedPodsPercentage)/100.0;
		NumPods = RollInterval(MinNumPods, MaxNumPods);
		NumAliensModifier = -(100-CrashedUFOSurvedAliensPercentage);
	}
	else if (EnableAmbushUFOs && Rand(30) < STAT_GetStat(21)) // ambush UFOs have more pods
	{
		MaxNumPods = float(NumPods) * (1 + float(AmbushUFOAdditionalPodsPercentage)/100.0);
		MinNumPods = NumPods;
		NumPods = RollInterval(MinNumPods, MaxNumPods);
		NumAliensModifier = AmbushUFOAdditionalAliensPercentage;
	}
	NumPods = Max(1, NumPods);
	PodTypes = RollPodTypes(UFOMissionType, NumPods); // command pods are explicitly excluded for UFO missions
	if (ShipType != eShip_UFOEthereal && EnableRandomCommanders)
	{
		PodTypes.AddItem(EPodTypeMod_Commander); // add command pod with random species
	}
	AlienSquad = RollAlienSquad(PodTypes, NumAliensModifier);
	if (ShipType == eShip_UFOEthereal) // add fixed command pod for Overseer UFO
	{
		AlienPod.PodType = EPodTypeMod_Commander;
		AlienPod.Main = eChar_Ethereal;
		AlienPod.Support1 = eChar_MutonElite;
		AlienPod.Support2 = eChar_MutonElite;
		AlienPod.MainNum = 1;
		AlienPod.Support1Num = 1 + Rand(2);
		AlienPod.Support2Num = 1 + Rand(2);
		AlienSquad.Pods.AddItem(AlienPod);
	}
	else if (!EnableRandomCommanders) // add fixed command pod for non-random commanders case
	{
		AlienPod.PodType = EPodTypeMod_Commander;
		AlienPod.Main = GetCommanderType();
		AlienPod.MainNum = 1;
		AlienPod.LeaderLevel = RollLeaderLevel();
		if (AlienPod.Main == eChar_Outsider || AlienPod.Main == eChar_SectoidCommander)
		{
			AlienPod.Support1 = AlienPod.Main;
			AlienPod.Support2 = AlienPod.Main;
		}
		else
		{
			AlienPod.Support1 = eChar_MutonElite;
			AlienPod.Support2 = eChar_MutonElite;
		}
		AlienPod.Support1Num = 1 + Rand(2) * (Landed ? 1 : 0);
		AlienPod.Support2Num = (1 + Rand(2)) * (Landed ? 1 : 0);
		AlienSquad.Pods.AddItem(AlienPod);
	}
	return AlienSquad;
}

function TAlienSquad_Mod DetermineAbductionSquad_Mod(int MissionDiff)
{
	local TAlienSquad_Mod AlienSquad;
	local array<EPodTypeMod> PodTypes;
	local int NumPods;
	
	if (MissionDiff == 9) // LW interceptor base assault
	{
		MissionDifficulty = 100;
		NumPods = RollNumPods(EMissionMod_Abduction, (int(EMissionDifficulty.eMissionDiff_VeryHard) - int(EMissionDifficulty.eMissionDiff_Moderate)) * PodsDifficultyMultiplier);
	}
	else
	{
		MissionDifficulty = MissionDiff;
		NumPods = RollNumPods(EMissionMod_Abduction, (MissionDiff - int(EMissionDifficulty.eMissionDiff_Moderate)) * PodsDifficultyMultiplier);
	}
	PodTypes = RollPodTypes(EMissionMod_Abduction, NumPods);
	AlienSquad = RollAlienSquad(PodTypes);
	
	return AlienSquad;
}

function int RollNumPods(EMissionMod MissionType, int Modifier)
{
	local TAlienNumbers PodNumbers;
	local int NumPods;

	PodNumbers = AdjustPodNumbersByMonth(MissionType);
	NumPods = RollInterval(PodNumbers.MinPods, PodNumbers.MaxPods) + Modifier;
	return NumPods;
}

function int RollInterval(int Min, int Max)
{
	local int Result;
	Result = Min + Rand(Max - Min);
	Result = Clamp(Result, Min, Max);
	return Result;
}

function TAlienNumbers AdjustPodNumbersByMonth(EMissionMod MissionType)
{
	local TAlienNumbers Result;
	local array<TAlienNumbersModifiers> MonthlyModifiers;
	local TAlienNumbersModifiers Modifier;
	local int CurrentMonth;
	
	CurrentMonth = GetMonth_Mod();

	switch (MissionType)
	{
		case EMissionMod_Abduction:
			Result.MinPods = AbductionPodNumbers.MinPods;
			Result.MaxPods = AbductionPodNumbers.MaxPods;
			MonthlyModifiers = AbductionPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_UFO:
		case EMissionMod_BigUFO:
			Result.MinPods = UFOPodNumbers.MinPods;
			Result.MaxPods = UFOPodNumbers.MaxPods;
			MonthlyModifiers = UFOPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_Terror:
			Result.MinPods = TerrorPodNumbers.MinPods;
			Result.MaxPods = TerrorPodNumbers.MaxPods;
			MonthlyModifiers = TerrorPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_Special:
			Result.MinPods = SpecialPodNumbers.MinPods;
			Result.MaxPods = SpecialPodNumbers.MaxPods;
			MonthlyModifiers = SpecialPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_Extraction:
			Result.MinPods = ExtractionPodNumbers.MinPods;
			Result.MaxPods = ExtractionPodNumbers.MaxPods;
			MonthlyModifiers = ExtractionPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_CaptureAndHold:
			Result.MinPods = CaptureAndHoldPodNumbers.MinPods;
			Result.MaxPods = CaptureAndHoldPodNumbers.MaxPods;
			MonthlyModifiers = CaptureAndHoldPodNumbersMonthlyModifiers;
			break;
		case EMissionMod_ExaltRaid:
			Result.MinPods = ExaltRaidPodNumbers.MinPods;
			Result.MaxPods = ExaltRaidPodNumbers.MaxPods;
			MonthlyModifiers.Length = 0;
			break;
		case EMissionMod_AlienBase:
			Result.MinPods = AlienBasePodNumbers.MinPods;
			Result.MaxPods = AlienBasePodNumbers.MaxPods;
			MonthlyModifiers.Length = 0;
			break;
		default:
			break;
	}
	
	foreach MonthlyModifiers(Modifier)
	{
		if (Modifier.Month <= CurrentMonth)
		{
			if (Modifier.MinPods > -1)
			{
				Result.MinPods = Modifier.MinPods;
			}
			if (Modifier.MaxPods > -1)
			{
				Result.MaxPods = Modifier.MaxPods;
			}
		}
		else
		{
			break;
		}
	}
	
	return Result;
}

function array<EPodTypeMod> RollPodTypes(EMissionMod MissionType, int NumPods)
{
	local array<EPodTypeMod> Result;
	local array<int> PodTypes;
	local int I;

	PodTypes = AdjustPodTypesByMonth(MissionType);
	
	for (I = 0; I < NumPods; ++I)
	{
		Result.AddItem(EPodTypeMod(RollArray(PodTypes)));
	}
	
	return Result;
}

function int RollArray(array<int> Arr)
{
	local int Result;
	local int I, Sum, CurSum, RandNum;
	
	Sum = 0;
	for (I = 0; I < Arr.Length; ++I)
	{
		Sum += Arr[I];
		`Log("XGStrategyAI_Mod: PodType[" $ I $ "] chance = " $ Arr[I]);
	}
	RandNum = Rand(Sum);
	CurSum = 0;
	for (I = 0; I < Arr.Length; ++I)
	{
		CurSum += Arr[I];
		if (RandNum < CurSum)
		{
			Result = I;
			break;
		}
	}

	return Result;
}

function array<int> AdjustPodTypesByMonth(EMissionMod MissionType)
{
	local array<int> Result;
	local array<TPodTypeModifier> MonthlyModifiers;
	local TPodTypeModifier Modifier;
	local array<TPodType> PodTypes;
	local int I, CurrentMonth;

	CurrentMonth = GetMonth_Mod();
	
	switch (MissionType)
	{
		case EMissionMod_Abduction:
			PodTypes = AbductionPodTypes;
			MonthlyModifiers = AbductionPodTypesMonthlyModifiers;
			break;
		case EMissionMod_UFO:
			PodTypes = UFOPodTypes;
			MonthlyModifiers = UFOPodTypesMonthlyModifiers;
			break;
		case EMissionMod_Terror:
			PodTypes = TerrorPodTypes;
			MonthlyModifiers = TerrorPodTypesMonthlyModifiers;
			break;
		case EMissionMod_Special:
			PodTypes = SpecialPodTypes;
			MonthlyModifiers = SpecialPodTypesMonthlyModifiers;
			break;
		case EMissionMod_BigUFO:
			PodTypes = BigUFOPodTypes;
			MonthlyModifiers = BigUFOPodTypesMonthlyModifiers;
			break;
		case EMissionMod_Extraction:
			PodTypes = ExtractionPodTypes;
			MonthlyModifiers = ExtractionPodTypesMonthlyModifiers;
			break;
		case EMissionMod_CaptureAndHold:
			PodTypes = CaptureAndHoldPodTypes;
			MonthlyModifiers = CaptureAndHoldPodTypesMonthlyModifiers;
			break;
		case EMissionMod_ExaltRaid:
			PodTypes = ExaltRaidPodTypes;
			MonthlyModifiers.Length = 0;
			break;
		case EMissionMod_AlienBase:
			PodTypes = AlienBasePodTypes;
			MonthlyModifiers.Length = 0;
			break;
		default:
			break;
	}

	Result.Add(EPodTypeMod_MAX);
	for (I = 0; I < PodTypes.Length; ++I)
	{
		Result[PodTypes[I].ID] = PodTypes[I].TypeChance;
	}
	
	foreach MonthlyModifiers(Modifier)
	{
		if (Modifier.Month <= CurrentMonth)
		{
			if (Modifier.TypeChance > -1)
			{
				Result[Modifier.ID] = Modifier.TypeChance;
			}
		}
		else
		{
			break;
		}
	}
	// force manual one and only one command pod for UFO missions
	if (MissionType == EMissionMod_UFO || MissionType == EMissionMod_BigUFO)
	{
		Result[EPodTypeMod_Commander] = 0;
	}
	
	return Result;
}

function TAlienSquad_Mod RollAlienSquad(array<EPodTypeMod> PodTypes, optional int NumAliensModifier = 0)
{
	local TAlienSquad_Mod AlienSquad;
	local int I;
	
	ClearAllPodTypesCounters();
	AlienSquad.Pods.Add(PodTypes.Length);
	for (I = 0; I < PodTypes.Length; ++I)
	{
		AlienSquad.Pods[I] = RollPodAliens(PodTypes[I], NumAliensModifier);
	}
	return AlienSquad;
}

function TAlienPod_Mod RollPodAliens(EPodTypeMod PodType,  optional int NumAliensModifier = 0)
{
	local TAlienPod_Mod AlienPod;
	local int ID, NumAliens, I, MinAliens, MaxAliens;
	local int AlienNumbers[3];
	local array<TPodSpecies> PossibleSpecies;
	
	PossibleSpecies = AdjustPossibleSpeciesByMonth(PodType);
	ID = RollSpeciesID(PossibleSpecies);
	AdjustPodTypesCounter(PodType, ID);
	NumAliens = RollInterval(PossibleSpecies[ID].MinAliens, PossibleSpecies[ID].MaxAliens);
	if (EnableAlienResources)
	{
		NumAliens += STAT_GetStat(19) * AdditionalAliensPerPodMultiplier;
	}
	if (NumAliensModifier < 0)
	{
		MinAliens = NumAliens * (1 + float(NumAliensModifier)/100);
		MaxAliens = NumAliens;
		NumAliens = RollInterval(MinAliens, MaxAliens);
	}
	else if (NumAliensModifier > 0)
	{
		MaxAliens = NumAliens * (1 + float(NumAliensModifier)/100);
		MinAliens = NumAliens;
		NumAliens = RollInterval(MinAliens, MaxAliens);
	}
	NumAliens = Clamp(NumAliens, 1, 8);
	for (I = 0; I < NumAliens; ++I)
	{
		++AlienNumbers[RollIndividualSpecies(PossibleSpecies[ID], AlienNumbers[0] > 1)];
	}

    AlienPod.PodType = PodType;
    AlienPod.Main = PossibleSpecies[ID].MainAlien;
    AlienPod.Support1 = PossibleSpecies[ID].SupportAlien1;
    AlienPod.Support2 = PossibleSpecies[ID].SupportAlien2;
    AlienPod.MainNum = AlienNumbers[0];
	AlienPod.Support1Num = AlienNumbers[1];
	AlienPod.Support2Num = AlienNumbers[2];
	AlienPod.LeaderLevel = RollLeaderLevel(PossibleSpecies[ID].LeaderLevel);
	
	if (AlwaysSpawnAtLeastOneMainAlien && AlienPod.MainNum == 0)
	{
		AlienPod.MainNum = 1;
		if (AlienPod.Support1Num > AlienPod.Support2Num)
		{
			--AlienPod.Support1Num;
		}
		else
		{
			--AlienPod.Support2Num;
		}
	}

	AlienPod.UseAltWeapon = NeedToUseAltWeapon(AlienPod);
	
	return AlienPod;
}

function bool NeedToUseAltWeapon(TAlienPod_Mod AlienPod)
{
	if (GetMonth_Mod() < 4)
	{
		if (AlienPod.Main == eChar_Muton || AlienPod.Support1 == eChar_Muton || AlienPod.Support2 == eChar_Muton)
		{
			return true;
		}
	}
	return false;
}

function int RollLeaderLevel(optional int ForcedLeaderLevel = -1)
{
	local int Range, RandNum, Result;

	if (!EnableAlienLeaders)
	{
		return 0;
	}
	if (ForcedLeaderLevel > -1)
	{
		return ForcedLeaderLevel;
	}

    Range = Clamp(STAT_GetStat(1) * LeaderLevelProgressionMultiplier + 1, 1, 15);
    RandNum = Rand(Range);
    if(RandNum > 7)
    {
        RandNum = 7 - Rand(16 - Range);
    }
    Result = Clamp(RandNum, 0, 7);
	return Result;
}

function int RollIndividualSpecies(TPodSpecies Species, bool ExcludeMain)
{
	local int Sum, RandNum, MainChance;
	
	if (!ExcludeMain)
	{
		MainChance = Species.MainChance;
	}
	else
	{
		MainChance = 0;
		if (Species.Support1Chance == 0 && Species.Support2Chance == 0)
		{
			Species.Support1Chance = 100;
			Species.Support2Chance = 100;
		}
	}
	Sum = MainChance + Species.Support1Chance + Species.Support2Chance;
	RandNum = Rand(Sum);
	if (RandNum < MainChance)
	{
		return 0;
	}
	if (RandNum < MainChance + Species.Support1Chance)
	{
		return 1;
	}
	return 2;
}

function int RollSpeciesID(out array<TPodSpecies> PossibleSpecies)
{
	local int Result;
	local int I, Sum, CurSum, RandNum;
	
	Sum = 0;
	for (I = 0; I < PossibleSpecies.Length; ++I)
	{
		Sum += PossibleSpecies[I].PodChance;
	}
	RandNum = Rand(Sum);
	CurSum = 0;
	for (I = 0; I < PossibleSpecies.Length; ++I)
	{
		CurSum += PossibleSpecies[I].PodChance;
		if (RandNum < CurSum)
		{
			Result = I;
			break;
		}
	}

	return Result;
}

function array<TPodSpecies> AdjustPossibleSpeciesByMonth(EPodTypeMod PodType)
{
	local array<TPodSpecies> PossibleSpecies, Result;
	local array<TSpeciesModifier> MonthlyModifiers;
	local TSpeciesModifier Modifier;
	local int CurrentMonth, I;
	local array<int> PodLimitCounter;

	CurrentMonth = GetMonth_Mod();
	
	switch (PodType)
	{
		case EPodTypeMod_Commander:
			PossibleSpecies = PossibleCommanders;
			MonthlyModifiers = CommandersMonthlyModifiers;
			PodLimitCounter = CommandersPodTypesCounter;
			break;
		case EPodTypeMod_Soldier:
			PossibleSpecies = PossibleSoldiers;
			MonthlyModifiers = SoldiersMonthlyModifiers;
			PodLimitCounter = SoldiersPodTypesCounter;
			break;
		case EPodTypeMod_Terror:
			PossibleSpecies = PossibleTerrorists;
			MonthlyModifiers = TerroristsMonthlyModifiers;
			PodLimitCounter = TerroristsPodTypesCounter;
			break;
		case EPodTypeMod_Special:
			PossibleSpecies = PossibleSpecial;
			MonthlyModifiers = SpecialMonthlyModifiers;
			PodLimitCounter = SpecialPodTypesCounter;
			break;
		case EPodTypeMod_Elite:
			PossibleSpecies = PossibleElites;
			MonthlyModifiers = ElitesMonthlyModifiers;
			PodLimitCounter = ElitesPodTypesCounter;
			break;
		case EPodTypeMod_Exalt:
			PossibleSpecies = PossibleExalt;
			MonthlyModifiers = ExaltMonthlyModifiers;
			PodLimitCounter = ExaltPodTypesCounter;
			break;
		case EPodTypeMod_ExaltElite:
			PossibleSpecies = PossibleExaltElite;
			MonthlyModifiers = ExaltEliteMonthlyModifiers;
			PodLimitCounter = ExaltElitePodTypesCounter;
			break;
		case EPodTypeMod_Forced:
			PodLimitCounter = ForcedPodTypesCounter;
			break;
		default:
			break;
	}
	
	`Log("XGStrategyAI_Mod: PossibleSpecies.Length = " $ PossibleSpecies.Length);
	`Log("XGStrategyAI_Mod: MonthlyModifiers.Length = " $ MonthlyModifiers.Length);
	
	if (PodType == EPodTypeMod_Forced && ForcedID != -1)
	{
		for (I = 0; I < ForcedSpecial[ForcedID].ForcedPodTypes.Length; ++I)
		{
			Result.AddItem(PossibleForced[ForcedSpecial[ForcedID].ForcedPodTypes[I]]);
		}
	}
	else
	{
		Result.Add(PossibleSpecies.Length);
		for (I = 0; I < PossibleSpecies.Length; ++I)
		{
			Result[I] = PossibleSpecies[I];
		}
	}
	
	foreach MonthlyModifiers(Modifier)
	{
		if (Modifier.Month <= CurrentMonth)
		{
			if (Modifier.PodChance > -1)
			{
				Result[Modifier.ID].PodChance = Modifier.PodChance;
			}
			if (Modifier.PodLimit > -2)
			{
				Result[Modifier.ID].PodLimit = Modifier.PodLimit;
			}
			if (Modifier.MinAliens > -1)
			{
				Result[Modifier.ID].MinAliens = Modifier.MinAliens;
			}
			if (Modifier.MaxAliens > -1)
			{
				Result[Modifier.ID].MaxAliens = Modifier.MaxAliens;
			}
			if (Modifier.LeaderLevel > -2)
			{
				Result[Modifier.ID].LeaderLevel = Modifier.LeaderLevel;
			}
			if (Modifier.PodDifficulty > -1)
			{
				Result[Modifier.ID].PodDifficulty = Modifier.PodDifficulty;
			}
		}
		else
		{
			break;
		}
	}
	for (I = 0; I < Result.Length; ++I)
	{
		/// check for limits
		if (Result[I].PodLimit > -1 && PodLimitCounter[I] >= Result[I].PodLimit)
		{
			Result[I].PodChance = 0;
		}
		/// check for difficulty adjustments
		else if (Result[I].PodDifficulty > MissionDifficulty)
		{
			if (DiffDecreaseProbability && DiffProbabilityDivisor > 0)
			{
				Result[I].PodChance /= DiffProbabilityDivisor * (Result[I].PodDifficulty - MissionDifficulty);
			}
			else
			{
				Result[I].PodChance = 0;
			}
		}
	}
	
	return Result;
}

function ClearAllPodTypesCounters()
{
	CommandersPodTypesCounter.Length = 0;
	CommandersPodTypesCounter.Add(PossibleCommanders.Length);
	SoldiersPodTypesCounter.Length = 0;
	SoldiersPodTypesCounter.Add(PossibleSoldiers.Length);
	TerroristsPodTypesCounter.Length = 0;
	TerroristsPodTypesCounter.Add(PossibleTerrorists.Length);
	SpecialPodTypesCounter.Length = 0;
	SpecialPodTypesCounter.Add(PossibleSpecial.Length);
	ElitesPodTypesCounter.Length = 0;
	ElitesPodTypesCounter.Add(PossibleElites.Length);
	ExaltPodTypesCounter.Length = 0;
	ExaltPodTypesCounter.Add(PossibleExalt.Length);
	ExaltElitePodTypesCounter.Length = 0;
	ExaltElitePodTypesCounter.Add(PossibleExaltElite.Length);
	ForcedPodTypesCounter.Length = 0;
	ForcedPodTypesCounter.Add(PossibleForced.Length);
}

function AdjustPodTypesCounter(EPodTypeMod PodType, int ID)
{
	switch (PodType)
	{
		case EPodTypeMod_Commander:
			++CommandersPodTypesCounter[ID];
			break;
		case EPodTypeMod_Soldier:
			++SoldiersPodTypesCounter[ID];
			break;
		case EPodTypeMod_Terror:
			++TerroristsPodTypesCounter[ID];
			break;
		case EPodTypeMod_Special:
			++SpecialPodTypesCounter[ID];
			break;
		case EPodTypeMod_Elite:
			++ElitesPodTypesCounter[ID];
			break;
		case EPodTypeMod_Exalt:
			++ExaltPodTypesCounter[ID];
			break;
		case EPodTypeMod_ExaltElite:
			++ExaltElitePodTypesCounter[ID];
			break;
		case EPodTypeMod_Forced:
			++ForcedPodTypesCounter[ID];
			break;
		default:
			break;
	}
}

function TAlienSquad DetermineFirstMissionSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineFirstMissionSquad");
	AlienSquad = DetermineAbductionSquad_Mod(EMissionDifficulty.eMissionDiff_Moderate);
	kSquad = ConvertSquad(AlienSquad);
	return kSquad;
}

function TAlienSquad DetermineAbductionSquad(int iMissionDiff)
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineAbductionSquad");
	AlienSquad = DetermineAbductionSquad_Mod(iMissionDiff);
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineUFOSquad(XGShip_UFO kUFO, bool bLanded, optional EShipType eShip = 0)
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineUFOSquad");
    if(eShip == 0)
    {
        eShip = kUFO.m_kTShip.eType;
    }
	AlienSquad = DetermineUFOSquad_Mod(kUFO, bLanded, ConvertShipType(eShip));
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineTerrorSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineTerrorSquad");
	AlienSquad = DetermineTerrorSquad_Mod();
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineSpecialMissionSquad(ECharacter eChar, EFCMission eMission, bool bAssault)
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineSpecialMissionSquad");
	if (ExcludeSpecial.Find(eMission) != -1)
	{
		`Log("XGStrategyAI_Mod: exclusion found, skipping to defaults.");
		return super.DetermineSpecialMissionSquad(eChar, eMission, bAssault);
	}
	AlienSquad = DetermineSpecialMissionSquad_Mod(eChar, eMission, bAssault);
	kSquad = ConvertSquad(AlienSquad);
	return kSquad;
}

function XGMission CreateCovertOpsExtractionMission(ECountry eMissionCountry)
{
    local XGMission_CovertOpsExtraction kMission;
    local XGCountry kCountry;

    kCountry = Country(eMissionCountry);
    kMission = Spawn(class'XGMission_CovertOpsExtraction');
    kMission.m_kDesc = Spawn(class'XGBattleDesc');
    kMission.m_iContinent = kCountry.GetContinent();
    kMission.m_iCountry = eMissionCountry;
    kMission.m_kDesc.m_kAlienSquad = DetermineCovertOpsSquad();
    kMission.m_iDuration = 96;
    kMission.m_v2Coords = kCountry.GetCoords();
    return kMission;
}

function XGMission CreateCaptureAndHoldMission(ECountry eMissionCountry)
{
    local XGMission_CaptureAndHold kMission;
    local XGCountry kCountry;

    kCountry = Country(eMissionCountry);
    kMission = Spawn(class'XGMission_CaptureAndHold');
    kMission.m_kDesc = Spawn(class'XGBattleDesc');
    kMission.m_iContinent = kCountry.GetContinent();
    kMission.m_iCountry = eMissionCountry;
    kMission.m_kDesc.m_kAlienSquad = DetermineCaptureAndHoldSquad();
    kMission.m_iDuration = 96;
    kMission.m_v2Coords = kCountry.GetCoords();
    return kMission;
}

function TAlienSquad DetermineCovertOpsSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineCovertOpsSquad");
	AlienSquad = DetermineCovertOpsSquad_Mod();
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineCaptureAndHoldSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineCaptureAndHoldSquad");
	AlienSquad = DetermineCaptureAndHoldSquad_Mod();
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineExaltRaidSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineExaltRaidSquad");
	AlienSquad = DetermineExaltRaidSquad_Mod();
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}

function TAlienSquad DetermineAlienBaseSquad()
{
    local TAlienSquad kSquad;
	local TAlienSquad_Mod AlienSquad;
	
	`Log("XGStrategyAI_Mod: DetermineAlienBaseSquad");
	AlienSquad = DetermineAlienBaseSquad_Mod();
	kSquad = ConvertSquad(AlienSquad);
    return kSquad;
}
