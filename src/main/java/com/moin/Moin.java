package com.moin;

import com.moin.addiction.ModAttachments;
import com.moin.block.entity.ModBlockEntities;
import com.moin.block.ModBlocks;
import com.moin.effect.ModEffects;
import com.moin.item.ModCreativeTabs;
import com.moin.item.ModItems;
import com.moin.menu.ModMenuTypes;
import com.moin.sound.ModSounds;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.fml.ModContainer;
import net.neoforged.fml.common.Mod;
import org.slf4j.Logger;
import com.mojang.logging.LogUtils;

/**
 * Clase principal del mod "Moin".
 *
 * Todo el contenido de este mod es FICTICIO y solo tiene efecto dentro del juego:
 * plantas que se cultivan, items que se consumen y aplican efectos de pocion,
 * una mesa de procesado con su interfaz, y efectos + sonidos personalizados.
 */
@Mod(Moin.MODID)
public class Moin {
    public static final String MODID = "moin";
    public static final Logger LOGGER = LogUtils.getLogger();

    public Moin(IEventBus modEventBus, ModContainer modContainer) {
        // Registramos todos los DeferredRegister en el bus de eventos del mod.
        ModBlocks.register(modEventBus);
        ModItems.register(modEventBus);
        ModBlockEntities.register(modEventBus);
        ModMenuTypes.register(modEventBus);
        ModEffects.register(modEventBus);
        ModSounds.register(modEventBus);
        ModCreativeTabs.register(modEventBus);
        ModAttachments.register(modEventBus);

        LOGGER.info("[Moin] Mod cargado correctamente. Recuerda: todo el contenido es ficticio y solo funciona en el juego.");
    }
}
