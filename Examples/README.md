XCOM-Mutators: Examples
=======================

Examples of XComMutator usage.

To compile your script packages, you'll need a references to existing XComGame and/or
XComStrategyGame packages. You can imitate those references by creating dummy packages
with stub classes and functions inside.

For example, you need access to GetHumanPlayer() function, which is defined inside
XComGame package. First, you need to create <Path-To-UDK>\Development\Src\XComGame\Classes
folder tree. Since GetHumanPlayer() function is defined inside XGBattle_SP class, you need to
create a file named XGBattle_SP.uc and put class header and stub function inside. Since
XGBattle_SP extends XGBattle, you also need to create XGBattle.uc file and put class header there.

You need to do this for each class, you're planing to use.

Decompiled XComGame and XComStrategyGame scripts can be obtained with UE Explorer:
http://eliotvu.com/portfolio/view/21/ue-explorer Unfortunately, those scripts have numerous
decompilation errors and can't be used with UDK directly.