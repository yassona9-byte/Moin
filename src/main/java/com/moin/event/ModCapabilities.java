package com.moin.event;

import com.moin.Moin;
import com.moin.block.entity.MesaProcesadoBlockEntity;
import com.moin.block.entity.ModBlockEntities;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.capabilities.Capabilities;
import net.neoforged.neoforge.capabilities.RegisterCapabilitiesEvent;

/**
 * Expone el inventario de la mesa de procesado como capability de items,
 * para que tolvas y otros mods puedan interactuar con ella.
 */
@EventBusSubscriber(modid = Moin.MODID, bus = EventBusSubscriber.Bus.MOD)
public class ModCapabilities {

    @SubscribeEvent
    public static void registrarCapabilities(RegisterCapabilitiesEvent evento) {
        evento.registerBlockEntity(
                Capabilities.ItemHandler.BLOCK,
                ModBlockEntities.MESA_PROCESADO.get(),
                (MesaProcesadoBlockEntity be, net.minecraft.core.Direction lado) -> be.getInventario());
    }
}
