package com.moin.block;

import com.moin.Moin;
import net.minecraft.world.level.block.Blocks;
import net.minecraft.world.level.block.SoundType;
import net.minecraft.world.level.block.state.BlockBehaviour;
import net.minecraft.world.level.material.MapColor;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredBlock;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModBlocks {
    public static final DeferredRegister.Blocks BLOCKS = DeferredRegister.createBlocks(Moin.MODID);

    public static final DeferredBlock<CogolloCropBlock> COGOLLO_CROP = BLOCKS.register("cogollo_crop",
            () -> new CogolloCropBlock(BlockBehaviour.Properties.ofFullCopy(Blocks.WHEAT)));

    public static final DeferredBlock<CocaCropBlock> COCA_CROP = BLOCKS.register("coca_crop",
            () -> new CocaCropBlock(BlockBehaviour.Properties.ofFullCopy(Blocks.POTATOES)));

    public static final DeferredBlock<MesaProcesadoBlock> MESA_PROCESADO = BLOCKS.register("mesa_procesado",
            () -> new MesaProcesadoBlock(BlockBehaviour.Properties.of()
                    .mapColor(MapColor.WOOD)
                    .strength(2.5F)
                    .sound(SoundType.WOOD)
                    .noOcclusion()));

    public static void register(IEventBus bus) {
        BLOCKS.register(bus);
    }
}
