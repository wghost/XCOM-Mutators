class XGFundingCouncil_Mod extends XGFundingCouncil
    notplaceable;

function TFCMission BuildMission(EFCMission eMission, ECountry ECountry)
{
	local TFCMission kMission;
	
	if (eMission < eFCM_MAX)
	{
		kMission = super.BuildMission(eMission, ECountry);
		FixDisplayName(kMission);
	}
	else
	{
		kMission = BuildExtendedMission(eMission, ECountry);
	}
	return kMission;
}

function FixDisplayName(out TFCMission kMission)
{
	local array<string> MapNames;
	local int i;
	class'XComMapManager'.static.GetSpecialMissionDisplayNames(kMission.eType, MapNames);
	for (i = 0; i < MapNames.Length; ++i)
	{
		if (InStr(MapNames[i], kMission.strMapName) != -1)
		{
			kMission.strMapName = MapNames[i];
		}
	}
}

function TFCMission BuildExtendedMission(EFCMission eMission, ECountry ECountry)
{
	local TFCMission kMission;
	local array<string> MapNames;
	// use Slaughterhouse Bomb mission as a template for all bomb missions
	kMission = super.BuildMission(eFCM_SlaughterBomb, ECountry);
	class'XComMapManager'.static.GetSpecialMissionDisplayNames(kMission.eType, MapNames);
	FilterVanillaMaps(MapNames);
	if (MapNames.Length > eMission - eFCM_MAX)
	{
		kMission.eMission = eMission;
		kMission.strMapName = MapNames[eMission - eFCM_MAX];
	}
	return kMission;
}

function FilterVanillaMaps(out array<string> MapNames)
{
	local int i;
	for (i = 0; i < eFCM_MAX; ++i)
	{
		if (MapNames.Find(m_arrTMissions[i].strMapName) != -1)
		{
			MapNames.RemoveItem(m_arrTMissions[i].strMapName);
		}
	}
}

function Init()
{
	local array<string> MapNames;
	local int i, idx, tmp;
	local EFCMission eMission;
	super.Init();
	class'XComMapManager'.static.GetSpecialMissionDisplayNames(eFCMType_Bomb, MapNames);
	FilterVanillaMaps(MapNames);
	`Log("XGFundingCouncil_Mod: extended special maps array length = " $ MapNames.Length);
	if (MapNames.Length > 0)
	{
		m_arrTMissions.Add(MapNames.Length);
		for (i = 0; i < MapNames.Length; ++i)
		{
			idx = eFCM_MAX + i;
			eMission = EFCMission(idx);
			m_arrTMissions[idx] = BuildMission(eMission, 0);
			tmp = int(m_arrTMissions[idx].eMission);
			`Log("XGFundingCouncil_Mod: m_arrTMissions[" $ idx $ "].eMission = " $ tmp);
		}
	}
	`Log("XGFundingCouncil_Mod: m_arrTMissions.Length = " $ m_arrTMissions.Length);
}

function EFCMission ChooseNextMissionByType(EMissionRegion eRegion, ECountry fcCountry)
{
	local EFCMission eMission;
	local int SavedLength, i;
	SavedLength = m_arrPreviousMissions.Length;
	eMission = super.ChooseNextMissionByType(eRegion, fcCountry);
	if (m_arrPreviousMissions.Length != SavedLength)
	{
		`Log("XGFundingCouncil_Mod: all missions taken, clearing extended maps play history.");
		for (i = eFCM_MAX; i < m_arrTMissions.Length; ++i)
		{
			m_arrPreviousMissions.RemoveItem(EFCMission(i));
		}
	}
	return eMission;
}
