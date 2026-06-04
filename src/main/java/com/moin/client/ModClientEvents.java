package com.moin.client;

import com.moin.Moin;
import com.moin.menu.ModMenuTypes;
import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.client.event.RegisterMenuScreensEvent;

/**
 * Eventos del lado cliente: registra la pantalla de la mesa de procesado.
 */
@EventBusSubscriber(modid = Moin.MODID, bus = EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ModClientEvents {

    @SubscribeEvent
    public static void registrarPantallas(RegisterMenuScreensEvent evento) {
        evento.register(ModMenuTypes.MESA_PROCESADO.get(), MesaProcesadoScreen::new);
    }
}
