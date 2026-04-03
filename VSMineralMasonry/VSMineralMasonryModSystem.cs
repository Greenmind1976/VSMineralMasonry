using Vintagestory.API.Common;

namespace VSMineralMasonry;

public class VSMineralMasonryModSystem : ModSystem
{
    public override void Start(ICoreAPI api)
    {
        api.RegisterBlockClass("BlockSlabCycle", typeof(BlockSlabCycle));
        api.RegisterBlockClass("BlockGroutCycle", typeof(BlockGroutCycle));
        api.RegisterBlockClass("BlockTriangleOverlayCycle", typeof(BlockTriangleOverlayCycle));
        api.RegisterItemClass("ItemPlaceGrout", typeof(ItemPlaceGrout));
        api.RegisterItemClass("ItemGroutTrowel", typeof(ItemGroutTrowel));
        api.RegisterItemClass("ItemGroutSponge", typeof(ItemGroutSponge));
        api.RegisterCollectibleBehaviorClass("PreserveGroutOnChisel", typeof(CollectibleBehaviorPreserveGroutOnChisel));
    }
}
