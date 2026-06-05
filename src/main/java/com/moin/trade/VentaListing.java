package com.moin.trade;

import net.minecraft.world.entity.Entity;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.trading.ItemCost;
import net.minecraft.world.item.trading.MerchantOffer;
import net.minecraft.world.entity.npc.VillagerTrades;
import net.minecraft.world.level.ItemLike;
import net.minecraft.util.RandomSource;
import org.jetbrains.annotations.Nullable;

/**
 * Oferta de venta: el jugador entrega un producto y recibe esmeraldas.
 * (En MerchantOffer, el "coste" es lo que paga el jugador y el "resultado" lo que recibe.)
 */
public record VentaListing(ItemLike producto, int cantidad, int esmeraldas, int maxUsos, int xp)
        implements VillagerTrades.ItemListing {

    @Nullable
    @Override
    public MerchantOffer getOffer(Entity comerciante, RandomSource random) {
        ItemCost coste = new ItemCost(producto, cantidad);
        ItemStack pago = new ItemStack(Items.EMERALD, esmeraldas);
        return new MerchantOffer(coste, pago, maxUsos, xp, 0.05F);
    }
}
