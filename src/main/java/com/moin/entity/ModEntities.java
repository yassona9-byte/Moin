package com.moin.entity;

import com.moin.Moin;
import net.minecraft.core.registries.Registries;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.MobCategory;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModEntities {
    public static final DeferredRegister<EntityType<?>> ENTITY_TYPES =
            DeferredRegister.create(Registries.ENTITY_TYPE, Moin.MODID);

    public static final DeferredHolder<EntityType<?>, EntityType<PoliEntity>> POLI =
            ENTITY_TYPES.register("poli",
                    () -> EntityType.Builder.of(PoliEntity::new, MobCategory.MONSTER)
                            .sized(0.6F, 1.95F)
                            .clientTrackingRange(10)
                            .build("poli"));

    public static void register(IEventBus bus) {
        ENTITY_TYPES.register(bus);
    }
}
