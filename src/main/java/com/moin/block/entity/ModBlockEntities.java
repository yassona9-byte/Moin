package com.moin.block.entity;

import com.moin.Moin;
import com.moin.block.ModBlocks;
import net.minecraft.core.registries.Registries;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModBlockEntities {
    public static final DeferredRegister<BlockEntityType<?>> BLOCK_ENTITIES =
            DeferredRegister.create(Registries.BLOCK_ENTITY_TYPE, Moin.MODID);

    public static final DeferredHolder<BlockEntityType<?>, BlockEntityType<MesaProcesadoBlockEntity>> MESA_PROCESADO =
            BLOCK_ENTITIES.register("mesa_procesado",
                    () -> BlockEntityType.Builder.of(MesaProcesadoBlockEntity::new, ModBlocks.MESA_PROCESADO.get()).build(null));

    public static void register(IEventBus bus) {
        BLOCK_ENTITIES.register(bus);
    }
}
