using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class ItemPlaceGrout : Item
{
    public override void OnHeldInteractStart(
        ItemSlot slot,
        EntityAgent byEntity,
        BlockSelection blockSel,
        EntitySelection entitySel,
        bool firstEvent,
        ref EnumHandHandling handling)
    {
        if (!firstEvent || blockSel == null)
        {
            return;
        }

        if (TryPlaceGrout(slot, byEntity.World, blockSel))
        {
            handling = EnumHandHandling.Handled;
        }
    }

    private bool TryPlaceGrout(ItemSlot slot, IWorldAccessor world, BlockSelection blockSel)
    {
        string color = Variant["color"] ?? "white";
        Block? groutBlock = world.GetBlock(CodeWithPath($"groutvsm-{color}-blob"));
        if (groutBlock == null || groutBlock.Id == 0)
        {
            return false;
        }

        BlockPos pos = blockSel.Position;
        int decorIndex = (int)new DecorBits(blockSel.Face);

        if (world.Side != EnumAppSide.Server)
        {
            return true;
        }

        bool placed = world.BlockAccessor.SetDecor(groutBlock, pos, decorIndex);
        if (!placed)
        {
            return false;
        }

        slot.TakeOut(1);
        slot.MarkDirty();
        return true;
    }
}
