using System;
using Vintagestory.API.Common;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class BlockCobblestoneCycle : Block
{
    private const int Rows = 3;
    private const int Columns = 3;
    private const int RowOrigin = 1;
    private const int ColumnOrigin = 1;

    public override bool OnBlockInteractStart(IWorldAccessor world, IPlayer byPlayer, BlockSelection blockSel)
    {
        if (blockSel == null || byPlayer == null)
        {
            return base.OnBlockInteractStart(world, byPlayer, blockSel);
        }

        if (IsWrench(byPlayer))
        {
            if (world.Side != EnumAppSide.Server)
            {
                return true;
            }

            CycleSingleBlock(world, blockSel.Position);
            return true;
        }

        if (IsHammer(byPlayer))
        {
            if (world.Side != EnumAppSide.Server)
            {
                return true;
            }

            AutoAlignLocal3x3(world, byPlayer, blockSel);
            return true;
        }

        return base.OnBlockInteractStart(world, byPlayer, blockSel);
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

    private void CycleSingleBlock(IWorldAccessor world, BlockPos pos)
    {
        string currentTile = LastCodePart(0) ?? "r1c1";
        string nextTile = NextTile(currentTile);
        Block? nextBlock = world.GetBlock(CodeWithParts(nextTile));
        if (nextBlock == null || nextBlock.Id == 0 || nextBlock.Id == Id)
        {
            return;
        }

        world.BlockAccessor.ExchangeBlock(nextBlock.Id, pos);
    }

    private static string NextTile(string currentTile)
    {
        int currentIndex = TileIndex(currentTile);
        int nextIndex = (currentIndex + 1) % (Rows * Columns);
        int row = (nextIndex / Columns) + 1;
        int column = (nextIndex % Columns) + 1;
        return $"r{row}c{column}";
    }

    private static int TileIndex(string tile)
    {
        if (tile.Length == 4 &&
            tile[0] == 'r' &&
            tile[2] == 'c' &&
            char.IsDigit(tile[1]) &&
            char.IsDigit(tile[3]))
        {
            int row = tile[1] - '0';
            int column = tile[3] - '0';
            if (row >= 1 && row <= Rows && column >= 1 && column <= Columns)
            {
                return ((row - 1) * Columns) + (column - 1);
            }
        }

        return 0;
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
        if (block is not BlockCobblestoneCycle)
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

    private bool IsHammer(IPlayer byPlayer)
    {
        ItemStack? stack = byPlayer.InventoryManager?.ActiveHotbarSlot?.Itemstack;
        if (stack?.Collectible == null)
        {
            return false;
        }

        if (stack.Collectible.Tool == EnumTool.Hammer)
        {
            return true;
        }

        string path = stack.Collectible.Code?.Path ?? "";
        return path.StartsWith("hammer-") || path == "hammer";
    }
}
