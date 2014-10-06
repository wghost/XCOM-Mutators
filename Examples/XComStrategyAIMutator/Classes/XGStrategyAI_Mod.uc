class XGStrategyAI_Mod extends XGStrategyAI;

event PostBeginPlay()
{
	`Log("XGStrategyAI_Mod is active!");
    super.PostBeginPlay();
}
