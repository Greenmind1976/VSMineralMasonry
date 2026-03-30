using System;
using Vintagestory.API.Common;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class BlockSlabCycle : Block
{
    private const int Rows = 3;
    private const int Columns = 3;
    private const int RowOrigin = 1;
    private const int ColumnOrigin = 1;

    public override bool OnBlockInteractStart(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel)
    {
        if (blockSel == null || byPlayer == null || !IsWrench(byPlayer))
        {
            return base.OnBlockInteractStart(world, byPlayer, blockSel);
        }

        if (world.Side != EnumAppSide.Server)
        {
            return true;
        }

        AutoAlignLocal3x3(world, byPlayer, blockSel);
        return true;
    }

    public override ItemStack OnPickBlock(IWorldAccessor world, BlockPos pos)
    {
        return new ItemStack(GetBaseVariant(world));
    }

    public override ItemStack[] GetDrops(IWorldAccessor world, BlockPos pos, IPlayer byPlayer, float dropQuantityMultiplier = 1)
    {
        return new[] { new ItemStack(GetBaseVariant(world)) };
    }

    public override string GetPlacedBlockName(IWorldAccessor world, BlockPos pos)
    {
        string baseName = base.GetPlacedBlockName(world, pos);
        string tile = (LastCodePart(0) ?? "r1c1").ToUpperInvariant();
        return $"{baseName} {tile}";
    }

    private Block GetBaseVariant(IWorldAccessor world)
    {
        Block? block = world.GetBlock(CodeWithParts("r1c1"));
        return block ?? this;
    }

    private void AutoAlignLocal3x3(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel)
    {
        (Vec3i colStep, Vec3i rowStep) = GetPlaneAxes(byPlayer, blockSel.Face);
        BlockPos origin = blockSel.Position;

        for (int rowOffset = -RowOrigin; rowOffset < Rows - RowOrigin; rowOffset++)
        {
            for (int colOffset = -ColumnOrigin; colOffset < Columns - ColumnOrigin; colOffset++)
            {
                BlockPos targetPos = origin.AddCopy(
                    colStep.X * colOffset + rowStep.X * rowOffset,
                    colStep.Y * colOffset + rowStep.Y * rowOffset,
                    colStep.Z * colOffset + rowStep.Z * rowOffset
                );

                Block targetBlock = world.BlockAccessor.GetBlock(targetPos);
                if (!IsSameSet(targetBlock))
                {
                    continue;
                }

                string tile = $"r{rowOffset + RowOrigin + 1}c{colOffset + ColumnOrigin + 1}";
                Block? mappedBlock = world.GetBlock(targetBlock.CodeWithParts(tile));
                if (mappedBlock == null || mappedBlock.Id == 0 || mappedBlock.Id == targetBlock.Id)
                {
                    continue;
                }

                world.BlockAccessor.ExchangeBlock(mappedBlock.Id, targetPos);
            }
        }
    }

    private (Vec3i colStep, Vec3i rowStep) GetPlaneAxes(IPlayer byPlayer, BlockFacing face)
    {
        if (face.IsAxisNS)
        {
            return (new Vec3i(1, 0, 0), new Vec3i(0, -1, 0));
        }

        if (face.IsAxisWE)
        {
            return (new Vec3i(0, 0, 1), new Vec3i(0, -1, 0));
        }

        if (face == BlockFacing.UP)
        {
            return (new Vec3i(1, 0, 0), new Vec3i(0, 0, -1));
        }

        return (new Vec3i(1, 0, 0), new Vec3i(0, 0, -1));
    }

    private bool IsSameSet(Block block)
    {
        if (block is not BlockSlabCycle)
        {
            return false;
        }

        AssetLocation? ownCode = Code;
        AssetLocation? otherCode = block.Code;
        if (ownCode == null || otherCode == null || ownCode.Domain != otherCode.Domain)
        {
            return false;
        }

        return BasePath(ownCode.Path) == BasePath(otherCode.Path);
    }

    private static string BasePath(string path)
    {
        int lastDash = path.LastIndexOf('-');
        return lastDash >= 0 ? path[..lastDash] : path;
    }

    private bool IsWrench(IPlayer byPlayer)
    {
        ItemStack? stack = byPlayer.InventoryManager?.ActiveHotbarSlot?.Itemstack;
        if (stack?.Collectible == null)
        {
            return false;
        }

        if (stack.Collectible.Tool == EnumTool.Wrench)
        {
            return true;
        }

        string path = stack.Collectible.Code?.Path ?? "";
        return path.StartsWith("wrench-") || path == "wrench";
    }
}
