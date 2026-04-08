using Vintagestory.API.Common;

namespace VSMineralMasonry;

public class VSMineralMasonryModSystem : ModSystem
{
    public override void Start(ICoreAPI api)
    {
        api.RegisterBlockClass("BlockSlabCycle", typeof(BlockSlabCycle));
        api.RegisterBlockClass("BlockCobblestoneCycle", typeof(BlockCobblestoneCycle));
        api.RegisterBlockClass("BlockCobblestoneCycle5x5", typeof(BlockCobblestoneCycle5x5));
        api.RegisterBlockClass("BlockStonePathDecorCycle", typeof(BlockStonePathDecorCycle));
        api.RegisterBlockClass("BlockGroutCycle", typeof(BlockGroutCycle));
        api.RegisterBlockClass("BlockTriangleOverlayCycle", typeof(BlockTriangleOverlayCycle));
        api.RegisterItemClass("ItemPlaceGrout", typeof(ItemPlaceGrout));
        api.RegisterItemClass("ItemPlaceStonePath", typeof(ItemPlaceStonePath));
        api.RegisterItemClass("ItemGroutTrowel", typeof(ItemGroutTrowel));
        api.RegisterItemClass("ItemGroutSponge", typeof(ItemGroutSponge));
        api.RegisterCollectibleBehaviorClass("PreserveGroutOnChisel", typeof(CollectibleBehaviorPreserveGroutOnChisel));
        api.RegisterCollectibleBehaviorClass("CycleStonePathDecor", typeof(CollectibleBehaviorCycleStonePathDecor));
        api.RegisterCollectibleBehaviorClass("RemoveGroutDecor", typeof(CollectibleBehaviorRemoveGroutDecor));
    }
}
