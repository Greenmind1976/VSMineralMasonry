using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;

namespace VSMineralMasonry;

public class CollectibleBehaviorCycleStonePathDecor : CollectibleBehavior
{
    public CollectibleBehaviorCycleStonePathDecor(CollectibleObject collObj) : base(collObj)
    {
    }

    public override void OnHeldInteractStart(
        ItemSlot slot,
        EntityAgent byEntity,
        BlockSelection blockSel,
        EntitySelection entitySel,
        bool firstEvent,
        ref EnumHandHandling handHandling,
        ref EnumHandling handling)
    {
        if (!firstEvent || blockSel == null)
        {
            return;
        }

        DecorEditingHelper.DecorTarget? target = DecorEditingHelper.GetSelectedDecor(byEntity.World, blockSel);
        if (target?.Block is not BlockStonePathDecorCycle)
        {
            return;
        }

        bool changed = false;

        if (collObj.Tool == EnumTool.Wrench)
        {
            if (byEntity.World.Side != EnumAppSide.Server)
            {
                handHandling = EnumHandHandling.Handled;
                handling = EnumHandling.PreventDefault;
                return;
            }

            changed = BlockStonePathDecorCycle.TryCycleDecor(byEntity.World, target);
        }
        else if (collObj.Tool == EnumTool.Hammer)
        {
            if (byEntity.World.Side != EnumAppSide.Server)
            {
                handHandling = EnumHandHandling.Handled;
                handling = EnumHandling.PreventDefault;
                return;
            }

            BlockStonePathDecorCycle.AutoAlignDecor3x3(byEntity.World, target);
            changed = true;
        }

        if (changed)
        {
            handHandling = EnumHandHandling.Handled;
            handling = EnumHandling.PreventDefault;
        }
    }
}
