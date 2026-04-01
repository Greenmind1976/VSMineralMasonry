using Vintagestory.API.Common;
using Vintagestory.API.Common.Entities;
using Vintagestory.API.MathTools;

namespace VSMineralMasonry;

public class ItemGroutTrowel : Item
{
    private sealed class DecorTarget
    {
        public required BlockPos Position { get; init; }
        public required int DecorIndex { get; init; }
        public required Block Block { get; init; }
    }

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

        if (HasEditableTarget(byEntity.World, blockSel) && byEntity.World.Side != EnumAppSide.Server)
        {
            handling = EnumHandHandling.Handled;
            return;
        }

        if (TryCycleTarget(byEntity.World, blockSel))
        {
            handling = EnumHandHandling.Handled;
        }
    }

    private static bool HasEditableTarget(IWorldAccessor world, BlockSelection blockSel)
    {
        return GetSelectedGrout(world, blockSel) != null;
    }

    private static bool TryCycleTarget(IWorldAccessor world, BlockSelection blockSel)
    {
        DecorTarget? target = GetSelectedGrout(world, blockSel);

        if (target == null)
        {
            return false;
        }

        if (world.Side != EnumAppSide.Server)
        {
            return true;
        }

        Block? nextBlock = GetNextCycleBlock(world, target.Block);
        if (nextBlock == null || nextBlock.Id == 0)
        {
            return false;
        }

        return world.BlockAccessor.SetDecor(nextBlock, target.Position, target.DecorIndex);
    }

    private static Block? GetNextCycleBlock(IWorldAccessor world, Block block)
    {
        if (block is BlockGroutCycle grout)
        {
            return GetNextBlock(world, grout, BlockGroutCycle.Parts);
        }

        if (block is BlockTriangleOverlayCycle triangle)
        {
            return GetNextBlock(world, triangle, BlockTriangleOverlayCycle.Parts);
        }

        return null;
    }

    private static Block? GetNextBlock(IWorldAccessor world, Block block, string[] parts)
    {
        string currentPart = block.LastCodePart(0) ?? parts[0];
        int currentIndex = 0;
        for (int i = 0; i < parts.Length; i++)
        {
            if (parts[i] == currentPart)
            {
                currentIndex = i;
                break;
            }
        }

        string nextPart = parts[(currentIndex + 1) % parts.Length];
        return world.GetBlock(block.CodeWithParts(nextPart));
    }

    private static DecorTarget? GetSelectedGrout(IWorldAccessor world, BlockSelection blockSel)
    {
        foreach (BlockPos pos in CandidatePositions(blockSel))
        {
            DecorTarget? target = GetSelectedGroutAt(world, pos, blockSel);
            if (target != null)
            {
                return target;
            }
        }

        return null;
    }

    private static DecorTarget? GetSelectedGroutAt(IWorldAccessor world, BlockPos pos, BlockSelection blockSel)
    {
        int exactIndex = blockSel.ToDecorIndex();
        Block? decor = world.BlockAccessor.GetDecor(pos, exactIndex);
        if (IsEditableDecor(decor))
        {
            return new DecorTarget { Position = pos.Copy(), DecorIndex = exactIndex, Block = decor };
        }

        int faceIndex = (int)new DecorBits(blockSel.Face);
        decor = world.BlockAccessor.GetDecor(pos, faceIndex);
        if (IsEditableDecor(decor))
        {
            return new DecorTarget { Position = pos.Copy(), DecorIndex = faceIndex, Block = decor };
        }

        var subDecors = world.BlockAccessor.GetSubDecors(pos);
        if (subDecors != null)
        {
            foreach (var entry in subDecors)
            {
                if (IsEditableDecor(entry.Value) && entry.Key % 6 == blockSel.Face.Index)
                {
                    return new DecorTarget { Position = pos.Copy(), DecorIndex = entry.Key, Block = entry.Value };
                }
            }
        }

        return null;
    }

    private static bool IsEditableDecor(Block? block)
    {
        return block is BlockGroutCycle || block is BlockTriangleOverlayCycle;
    }

    private static BlockPos[] CandidatePositions(BlockSelection blockSel)
    {
        BlockPos origin = blockSel.Position;
        return
        [
            origin.Copy(),
            origin.AddCopy(blockSel.Face),
            origin.AddCopy(blockSel.Face.Opposite),
            origin.AddCopy(BlockFacing.NORTH),
            origin.AddCopy(BlockFacing.EAST),
            origin.AddCopy(BlockFacing.SOUTH),
            origin.AddCopy(BlockFacing.WEST),
            origin.AddCopy(BlockFacing.UP),
            origin.AddCopy(BlockFacing.DOWN)
        ];
    }
}
