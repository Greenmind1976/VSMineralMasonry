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
        public required BlockGroutCycle Block { get; init; }
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

        string currentPart = target.Block.LastCodePart(0) ?? BlockGroutCycle.Parts[0];
        int currentIndex = 0;
        for (int i = 0; i < BlockGroutCycle.Parts.Length; i++)
        {
            if (BlockGroutCycle.Parts[i] == currentPart)
            {
                currentIndex = i;
                break;
            }
        }

        string nextPart = BlockGroutCycle.Parts[(currentIndex + 1) % BlockGroutCycle.Parts.Length];
        Block? nextBlock = world.GetBlock(target.Block.CodeWithParts(nextPart));
        if (nextBlock == null || nextBlock.Id == 0)
        {
            return false;
        }

        return world.BlockAccessor.SetDecor(nextBlock, target.Position, target.DecorIndex);
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
        if (decor is BlockGroutCycle exactGrout)
        {
            return new DecorTarget { Position = pos.Copy(), DecorIndex = exactIndex, Block = exactGrout };
        }

        int faceIndex = (int)new DecorBits(blockSel.Face);
        decor = world.BlockAccessor.GetDecor(pos, faceIndex);
        if (decor is BlockGroutCycle faceGrout)
        {
            return new DecorTarget { Position = pos.Copy(), DecorIndex = faceIndex, Block = faceGrout };
        }

        var subDecors = world.BlockAccessor.GetSubDecors(pos);
        if (subDecors != null)
        {
            foreach (var entry in subDecors)
            {
                if (entry.Value is BlockGroutCycle subGrout && entry.Key % 6 == blockSel.Face.Index)
                {
                    return new DecorTarget { Position = pos.Copy(), DecorIndex = entry.Key, Block = subGrout };
                }
            }
        }

        return null;
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
