using System.Collections.Generic;
using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;

namespace VSMineralMasonry;

public class ItemStonePolish : Item
{
    private static readonly HashSet<string> SupportedRocks =
    [
        "andesite",
        "basalt",
        "chalk",
        "chert",
        "granite",
        "limestone",
        "phyllite",
        "shale",
        "slate",
        "whitemarble"
    ];

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

        if (TryBurnishBlock(slot, byEntity.World, blockSel))
        {
            handling = EnumHandHandling.Handled;
        }
    }

    private static bool TryBurnishBlock(ItemSlot slot, IWorldAccessor world, BlockSelection blockSel)
    {
        Block sourceBlock = world.BlockAccessor.GetBlock(blockSel.Position);
        if (!IsConvertibleRawRock(sourceBlock, out string? rock))
        {
            return false;
        }

        Block? burnishedBlock = world.GetBlock(new AssetLocation("vsmineralmasonry", $"burnished-{rock}"));
        if (burnishedBlock == null || burnishedBlock.Id == 0)
        {
            return false;
        }

        if (world.Side != EnumAppSide.Server)
        {
            return true;
        }

        world.BlockAccessor.SetBlock(burnishedBlock.BlockId, blockSel.Position);
        world.PlaySoundAt(new AssetLocation("sounds/block/chisel"), blockSel.Position.X, blockSel.Position.Y, blockSel.Position.Z);
        slot.TakeOut(1);
        slot.MarkDirty();
        return true;
    }

    private static bool IsConvertibleRawRock(Block block, out string? rock)
    {
        rock = null;

        if (block.Code == null || block.Code.Domain != "game")
        {
            return false;
        }

        if (!block.Code.Path.StartsWith("rock-", System.StringComparison.Ordinal))
        {
            return false;
        }

        rock = block.Variant?["rock"];
        return !string.IsNullOrEmpty(rock) && SupportedRocks.Contains(rock);
    }
}
