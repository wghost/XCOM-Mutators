XCOM-Mutators: UPK Patches
==========================

Patches for game packages (Engine, XComGame, XComStrategyGame) to allow mutators modify certain
aspects of the game.

Install with PatchUPK/PatcherGUI: http://www.nexusmods.com/xcom/mods/448

Since XCOM wasn't build with Mutators support in mind, we have to add this support by modifying
appropriate functions to insert mutator calls.

Only basic existing Engine.Mutator class functions are accessible from inside existing packages.
Most of those can't be used with XCOM. For example, CheckRelevance can't be used to kill spawned
AIBehavior class and spawn a new one: sine Behavior is connected to certain Unit, deleting it will
result in unit with no Behavior at all. Re-spawning it with CheckRelevance will result in orphaned
AIBehavior object with no connections to Unit. The only existing function flexible enough to modify
for XCOM modding needs, is Mutate function. It has string parameter to pass anything through, but,
unfortunately, doesn't have a return value. And it can also be executed with console command.

General rules for inserting a Mutator call:
1. In the absence of appropriate Mutator, vanilla code should execute and run normally.
2. Try to replace an entire class with its subclass, if you can and if this suits your goals.
3. If not - try to modify an existing function as little as possible.