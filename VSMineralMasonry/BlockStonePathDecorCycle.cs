using System;
using Vintagestory.API.Common;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class BlockStonePathDecorCycle : Block
{
    private const int Rows = 3;
    private const int Columns = 3;
    private const int RowOrigin = 1;
    private const int ColumnOrigin = 1;

    public static bool TryCycleDecor(IWorldAccessor world, DecorEditingHelper.DecorTarget target)
    {
        if (target.Block is not BlockStonePathDecorCycle cycleBlock)
        {
            return false;
        }

        string currentTile = cycleBlock.LastCodePart(0) ?? "r1c1";
        string nextTile = NextTile(currentTile);
        Block? nextBlock = world.GetBlock(cycleBlock.CodeWithParts(nextTile));
        if (nextBlock == null || nextBlock.Id == 0 || nextBlock.Id == cycleBlock.Id)
        {
            return false;
        }

        return world.BlockAccessor.SetDecor(nextBlock, target.Position, target.DecorIndex);
    }

    public static void AutoAlignDecor3x3(IWorldAccessor world, DecorEditingHelper.DecorTarget target)
    {
        if (target.Block is not BlockStonePathDecorCycle cycleBlock)
        {
            return;
        }

        BlockPos origin = target.Position;
        bool mirrorColumns = cycleBlock.Attributes?["autoAlignMirrorColumns"].AsBool(false) ?? false;

        for (int rowOffset = -RowOrigin; rowOffset < Rows - RowOrigin; rowOffset++)
        {
            for (int colOffset = -ColumnOrigin; colOffset < Columns - ColumnOrigin; colOffset++)
            {
                BlockPos targetPos = origin.AddCopy(colOffset, 0, rowOffset);
                Block? decor = world.BlockAccessor.GetDecor(targetPos, target.DecorIndex);
                if (!IsSameSet(cycleBlock, decor))
                {
                    continue;
                }

                int column = mirrorColumns
                    ? ColumnOrigin - colOffset + 1
                    : colOffset + ColumnOrigin + 1;
                string tile = $"r{rowOffset + RowOrigin + 1}c{column}";
                Block? mapped = world.GetBlock(decor.CodeWithParts(tile));
                if (mapped == null || mapped.Id == 0 || mapped.Id == decor.Id)
                {
                    continue;
                }

                world.BlockAccessor.SetDecor(mapped, targetPos, target.DecorIndex);
            }
        }
    }

    private static bool IsSameSet(BlockStonePathDecorCycle own, Block? other)
    {
        if (other is not BlockStonePathDecorCycle)
        {
            return false;
        }

        AssetLocation? ownCode = own.Code;
        AssetLocation? otherCode = other.Code;
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
}
