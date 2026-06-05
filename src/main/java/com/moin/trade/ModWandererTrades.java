package com.moin.trade;

import com.moin.Moin;
import com.moin.item.ModItems;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.village.WandererTradesEvent;

/**
 * El vendedor ambulante hace de "narco": te vende semillas, la pipa, el escaner
 * e ingredientes a cambio de esmeraldas.
 */
@EventBusSubscriber(modid = Moin.MODID)
public class ModWandererTrades {

    @SubscribeEvent
    public static void registrarOfertas(WandererTradesEvent evento) {
        var genericas = evento.getGenericTrades();
        genericas.add(new CompraListing(2, ModItems.SEMILLA_HIERBA.get(), 1, 8, 1));
        genericas.add(new CompraListing(2, ModItems.SEMILLA_COCA.get(), 1, 8, 1));
        genericas.add(new CompraListing(3, ModItems.PIPA.get(), 1, 4, 1));

        var raras = evento.getRareTrades();
        raras.add(new CompraListing(8, ModItems.ESCANER.get(), 1, 2, 1));
        raras.add(new CompraListing(5, ModItems.HONGO_ALUCINANTE.get(), 1, 3, 1));
    }
}
