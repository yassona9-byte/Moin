package com.moin.client;

import com.moin.Moin;
import com.moin.menu.ModMenuTypes;
import net.minecraft.resources.ResourceLocation;
import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.client.event.RegisterGuiLayersEvent;
import net.neoforged.neoforge.client.event.RegisterMenuScreensEvent;

/**
 * Eventos del lado cliente: registra la pantalla de la mesa de procesado
 * y la capa visual de "ir colocado".
 */
@EventBusSubscriber(modid = Moin.MODID, bus = EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ModClientEvents {

    @SubscribeEvent
    public static void registrarPantallas(RegisterMenuScreensEvent evento) {
        evento.register(ModMenuTypes.MESA_PROCESADO.get(), MesaProcesadoScreen::new);
    }

    @SubscribeEvent
    public static void registrarCapas(RegisterGuiLayersEvent evento) {
        evento.registerAboveAll(
                ResourceLocation.fromNamespaceAndPath(Moin.MODID, "colocado"),
                new ColocadoOverlay());
    }
}
