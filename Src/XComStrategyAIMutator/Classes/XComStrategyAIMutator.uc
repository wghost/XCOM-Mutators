class XComStrategyAIMutator extends XComMutator;

function MutateStrategyAI(PlayerController Sender)
{
	local XGStrategy Game;
	Game = XComHeadquartersGame(class'Engine'.static.GetCurrentWorldInfo().Game).GetGameCore();
	Game.m_kAI = Spawn(class'XGStrategyAI_Mod');
}
