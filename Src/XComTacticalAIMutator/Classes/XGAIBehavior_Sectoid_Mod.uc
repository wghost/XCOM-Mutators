class XGAIBehavior_Sectoid_Mod extends XGAIBehavior_Sectoid
    notplaceable;

event PostBeginPlay()
{
	`Log("XGAIBehavior_Sectoid_Mod is active!");
    super.PostBeginPlay();
}
