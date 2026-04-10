using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;
using Vintagestory.API.Datastructures;

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

        Block groundBlock = world.BlockAccessor.GetBlock(blockSel.Position);
        if (!CanPlaceOnGround(groundBlock))
        {
            return false;
        }

        string? rock = Variant["rock"];
        if (string.IsNullOrEmpty(rock))
        {
            return false;
        }

        string? pathBlockCode = Attributes?["pathBlockCode"].AsString();
        if (string.IsNullOrEmpty(pathBlockCode))
        {
            return false;
        }

        Block? pathBlock = world.GetBlock(CodeWithPath($"{pathBlockCode}-{rock}-r1c1"));
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

        Block? existingDecor = world.BlockAccessor.GetDecor(pos, decorIndex);
        bool replacingSamePathSet = IsSamePathSet(existingDecor, pathBlock);

        bool placed = world.BlockAccessor.SetDecor(pathBlock, pos, decorIndex);
        if (!placed)
        {
            return false;
        }

        if (!replacingSamePathSet)
        {
            slot.TakeOut(1);
            slot.MarkDirty();
        }

        return true;
    }

    private static bool CanPlaceOnGround(Block groundBlock)
    {
        string path = groundBlock.Code?.Path ?? string.Empty;

        return path.StartsWith("soil-", System.StringComparison.Ordinal)
            || path.Equals("soil", System.StringComparison.Ordinal)
            || path.StartsWith("sand-", System.StringComparison.Ordinal)
            || path.Equals("sand", System.StringComparison.Ordinal);
    }

    private static bool IsSamePathSet(Block? existingDecor, Block pathBlock)
    {
        string? existingPath = existingDecor?.Code?.Path;
        string? newPath = pathBlock.Code?.Path;
        if (string.IsNullOrEmpty(existingPath) || string.IsNullOrEmpty(newPath))
        {
            return false;
        }

        return BasePath(existingPath) == BasePath(newPath);
    }

    private static string BasePath(string path)
    {
        int lastDash = path.LastIndexOf('-');
        return lastDash >= 0 ? path[..lastDash] : path;
    }
}
