using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class ItemPlaceStonePath : Item
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

        if (TryPlacePath(slot, byEntity.World, blockSel))
        {
            handling = EnumHandHandling.Handled;
        }
    }

    private bool TryPlacePath(ItemSlot slot, IWorldAccessor world, BlockSelection blockSel)
    {
        if (blockSel.Face != BlockFacing.UP)
        {
            return false;
        }

        string? rock = Variant["rock"];
        if (string.IsNullOrEmpty(rock))
        {
            return false;
        }

        Block? pathBlock = world.GetBlock(CodeWithPath($"burnishedstonepath-{rock}-r1c1"));
        if (pathBlock == null || pathBlock.Id == 0)
        {
            return false;
        }

        BlockPos pos = blockSel.Position;
        int decorIndex = (int)new DecorBits(BlockFacing.UP);

        if (world.Side != EnumAppSide.Server)
        {
            return true;
        }

        bool placed = world.BlockAccessor.SetDecor(pathBlock, pos, decorIndex);
        if (!placed)
        {
            return false;
        }

        slot.TakeOut(1);
        slot.MarkDirty();
        return true;
    }
}
