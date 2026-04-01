using Vintagestory.API.Common;

namespace VSMineralMasonry;

public class VSMineralMasonryModSystem : ModSystem
{
    public override void Start(ICoreAPI api)
    {
        api.RegisterBlockClass("BlockSlabCycle", typeof(BlockSlabCycle));
        api.RegisterBlockClass("BlockGroutCycle", typeof(BlockGroutCycle));
        api.RegisterBlockClass("BlockTriangleOverlayCycle", typeof(BlockTriangleOverlayCycle));
        api.RegisterItemClass("ItemGroutTrowel", typeof(ItemGroutTrowel));
        api.RegisterCollectibleBehaviorClass("PreserveGroutOnChisel", typeof(CollectibleBehaviorPreserveGroutOnChisel));
    }
}
