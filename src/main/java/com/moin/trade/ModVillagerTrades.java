package com.moin.trade;

import com.moin.Moin;
import com.moin.item.ModItems;
import net.minecraft.world.entity.npc.VillagerProfession;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.village.VillagerTradesEvent;

import java.util.List;

/**
 * Anade ofertas de venta a los aldeanos para crear el bucle economico:
 * cultivar -> procesar -> vender por esmeraldas.
 *
 * - El GRANJERO te compra la materia prima barata (cogollos, hoja de coca).
 * - El CLERIGO (el "camello") te compra los productos ya procesados, mas caros.
 */
@EventBusSubscriber(modid = Moin.MODID)
public class ModVillagerTrades {

    @SubscribeEvent
    public static void registrarOfertas(VillagerTradesEvent evento) {
        if (!com.moin.Config.TRAPICHEO.get()) {
            return;
        }
        var ofertas = evento.getTrades();

        if (evento.getType() == VillagerProfession.FARMER) {
            List<net.minecraft.world.entity.npc.VillagerTrades.ItemListing> nivel1 = ofertas.get(1);
            nivel1.add(new VentaListing(ModItems.COGOLLO.get(), 4, 1, 16, 2));
            nivel1.add(new VentaListing(ModItems.HOJA_COCA.get(), 4, 1, 16, 2));
            ofertas.get(2).add(new VentaListing(ModItems.POLVO_BRUTO.get(), 3, 2, 12, 5));
        }

        if (evento.getType() == VillagerProfession.CLERIC) {
            ofertas.get(1).add(new VentaListing(ModItems.PORRO.get(), 2, 3, 12, 5));
            ofertas.get(2).add(new VentaListing(ModItems.POLVO_BLANCO.get(), 1, 4, 10, 8));
            ofertas.get(3).add(new VentaListing(ModItems.PASTILLA.get(), 1, 5, 8, 10));
            ofertas.get(3).add(new VentaListing(ModItems.TRIPI.get(), 1, 6, 8, 10));
            ofertas.get(4).add(new VentaListing(ModItems.CRISTAL.get(), 1, 9, 6, 15));
        }
    }
}
