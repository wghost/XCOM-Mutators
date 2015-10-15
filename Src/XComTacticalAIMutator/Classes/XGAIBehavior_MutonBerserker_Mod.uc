class XGAIBehavior_MutonBerserker_Mod extends XGAIBehavior_MutonBerserker
    notplaceable;

simulated function PostBuildAbilities()
{
    local bull_rush_point kBullRush;
    local XGAbility kAbility;

    m_bBullRushActive = false;
    m_kNearestEnemy = m_kPlayer.GetNearestEnemy(m_kUnit.Location, m_fDistFromEnemy, false);
    foreach m_arrBullRushPoints(kBullRush)
    {
        if(IsValidPathDestination(kBullRush.vWallLoc))
        {
            m_kActiveBRPoint = kBullRush;
            m_bBullRushActive = true;
            kAbility = m_kUnit.FindAbility(55, none);
            if(XGAbility_BullRush(kAbility) != none)
            {
                XGAbility_BullRush(kAbility).m_bValidDestination = true;
            }
        }        
    }    
    if(!m_bBullRushActive)
    {
        if(FindNearestDestructible(m_kNearestEnemy, m_kActiveBRPoint.kWall))
        {
            m_kActiveBRPoint.vWallLoc = m_kActiveBRPoint.kWall.Location;
            if(IsValidPathDestination(m_kActiveBRPoint.vWallLoc))
            {
                if(VSizeSq(m_kActiveBRPoint.vWallLoc - m_kNearestEnemy.Location) < Square(128.0))
                {
                    m_kActiveBRPoint.kTargetEnemy = m_kNearestEnemy;
                    m_bBullRushActive = true;
                }
            }
        }
    }
}

simulated function int GetPredeterminedAbility()
{
    if(IsInMeleeRange())
    {
        return 7;
    }
    if(m_bBullRushActive)
    {
        return 55;
    }
    return 1;
}

function bool GetBullRushRange(XGUnit kEnemy, out array<bull_rush_point> arrEndPoint, float fMaxMoveDist)
{
    local Actor kHitActorOut, kHitActorIn;
    local XComCoverPoint kCover;
    local Vector VDir, vTraceStartOut, vTraceEndOut, vHitLocOut, vHitLocIn, vHitNormal,
	    vHeightOffset, vTraceStartIn, vTraceEndIn;

    local bool bHasBullRushPoints;
    local int iCoverDir, IPT;

    if(!kEnemy.IsInCover())
    {
        return false;
    }
    vHeightOffset = vect(0.0, 0.0, 0.0);
    vHeightOffset.Z = 32.0;
    kCover = kEnemy.GetCoverPoint();
    for (iCoverDir =0; iCoverDir < 4; ++iCoverDir)
    {
        if(!bool(kCover.Flags & (1 << iCoverDir)) != false)
        {
        }
        else
        {
            switch(1 << iCoverDir)
            {
                case 1:
                    VDir = vect(0.0, 1.0, 0.0);
                    break;
                case 2:
                    VDir = vect(0.0, -1.0, 0.0);
                    break;
                case 4:
                    VDir = vect(-1.0, 0.0, 0.0);
                    break;
                case 8:
                    VDir = vect(1.0, 0.0, 0.0);
                    break;
                default:
			}
            vTraceStartOut = (kCover.CoverLocation + (VDir * 192.0)) + vHeightOffset;
            vTraceEndOut = vTraceStartOut + (VDir * fMaxMoveDist);
            kHitActorOut = XComTacticalGRI(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kTraceMgr.XTrace(5, vHitLocOut, vHitNormal, vTraceEndOut, vTraceStartOut, vect(1.0, 1.0, 1.0));
            vTraceEndIn = kCover.CoverLocation + vHeightOffset;
            if(kHitActorOut != none)
            {
                vTraceStartIn = vHitLocOut - VDir;
            }
            else
            {
                vTraceStartIn = vTraceEndOut;
                vHitLocOut = vTraceEndOut;
            }
            vHitLocOut = vHitLocOut - (VDir * 48.0);
            kHitActorIn = XComTacticalGRI(class'Engine'.static.GetCurrentWorldInfo().GRI).m_kTraceMgr.XTrace(5, vHitLocIn, vHitNormal, vTraceEndIn, vTraceStartIn, vect(1.0, 1.0, 1.0));
            if((kHitActorIn != none) && kHitActorIn.IsA('XComFracLevelActor') || kHitActorIn.IsA('XComDestructibleActor'))
            {
                if(IsInBadArea(vHitLocIn))
                {
                }
                else
                {
                    if(VSizeSq2D(vHitLocIn - kCover.CoverLocation) < Square(192.0))
                    {
                        IPT = arrEndPoint.Length;
                        if(arrEndPoint.Find('vOuterLimit', vHitLocOut) == -1)
                        {
                            arrEndPoint.Add(1);
                            arrEndPoint[IPT].kWall = kHitActorIn;
                            arrEndPoint[IPT].vOuterLimit = vHitLocOut;
                            arrEndPoint[IPT].vWallLoc = vHitLocIn;
                            arrEndPoint[IPT].kTargetEnemy = kEnemy;
                        }
                        bHasBullRushPoints = true;
                    }
                }
            }
        }
    }
    return bHasBullRushPoints;
}

function bool AddTilePositionsBetween(const out Vector vSource, out bull_rush_point kBRPoint, out array<XComCoverPoint> Points)
{
    local int TileX, TileY, TileZ, SourceX, SourceY, SourceZ,
	    EndX, EndY, EndZ, iMyX, iMyY,
	    iMyZ, DX, DY, MaxIterations, iIter;

    local XComCoverPoint kPoint;
    local bool bAdded, bBullRushAvailable;
    local Vector vEnd;

    vEnd = kBRPoint.vOuterLimit;
    class'XComWorldData'.static.GetWorldData().GetFloorTileForPosition(vSource, SourceX, SourceY, SourceZ, true);
    class'XComWorldData'.static.GetWorldData().GetFloorTileForPosition(vEnd, EndX, EndY, EndZ, true);
    class'XComWorldData'.static.GetWorldData().GetFloorTileForPosition(m_kUnit.Location, iMyX, iMyY, iMyZ, true);
    if(SourceX == EndX)
    {
        DX = 0;
        if(SourceY < EndY)
        {
            DY = 2;
            MaxIterations = (EndY - SourceY) - 2;
        }
        else
        {
            DY = -2;
            MaxIterations = (SourceY - EndY) - 2;
        }
    }
    else
    {
        DY = 0;
        if(SourceX < EndX)
        {
            DX = 2;
            MaxIterations = (EndX - SourceX) - 2;
        }
        else
        {
            DX = -2;
            MaxIterations = (SourceX - EndX) - 2;
        }
    }
    if(MaxIterations > 0)
    {
        TileZ = SourceZ;
        for(iIter = 2; iIter < MaxIterations; ++iIter)
        {
            TileX = SourceX + (DX * iIter);
            TileY = SourceY + (DY * iIter);
            if(((TileX == iMyX) && TileY == iMyY) && TileZ == iMyZ)
            {
                bBullRushAvailable = true;
            }
            kPoint.CoverLocation = class'XComWorldData'.static.GetWorldData().GetPositionFromTileCoordinates(TileX, TileY, TileZ);
            kPoint.TileLocation = kPoint.CoverLocation;
            kPoint.X = iIter;
            kPoint.Y = 0;
            kPoint.Z = 0;
            Points.AddItem(kPoint);
            kBRPoint.arrMoveToLoc.AddItem(kPoint.TileLocation);
            bAdded = true;
        }
    }
    if(bBullRushAvailable && IsValidPathDestination(kBRPoint.vWallLoc))
    {
        m_kActiveBRPoint = kBRPoint;
        m_bBullRushActive = true;
        m_kUnit.m_bIsDoingBullRush = true;
    }
    return bAdded;
}
