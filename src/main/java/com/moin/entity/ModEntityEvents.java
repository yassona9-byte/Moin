package com.moin.entity;

import com.moin.Moin;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.entity.EntityAttributeCreationEvent;

/**
 * Registra los atributos (vida, velocidad, dano...) de las entidades del mod.
 */
@EventBusSubscriber(modid = Moin.MODID, bus = EventBusSubscriber.Bus.MOD)
public class ModEntityEvents {

    @SubscribeEvent
    public static void registrarAtributos(EntityAttributeCreationEvent evento) {
        evento.put(ModEntities.POLI.get(), PoliEntity.crearAtributos().build());
    }
}
