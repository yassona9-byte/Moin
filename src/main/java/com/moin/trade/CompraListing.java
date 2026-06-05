package com.moin.trade;

import net.minecraft.util.RandomSource;
import net.minecraft.world.entity.Entity;
import net.minecraft.world.entity.npc.VillagerTrades;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.trading.ItemCost;
import net.minecraft.world.item.trading.MerchantOffer;
import net.minecraft.world.level.ItemLike;
import org.jetbrains.annotations.Nullable;

/**
 * Oferta de compra: el jugador paga esmeraldas y recibe un producto.
 * La usan los "narcos" (vendedor ambulante) para venderte material.
 */
public record CompraListing(int esmeraldas, ItemLike producto, int cantidad, int maxUsos, int xp)
        implements VillagerTrades.ItemListing {

    @Nullable
    @Override
    public MerchantOffer getOffer(Entity comerciante, RandomSource random) {
        ItemCost coste = new ItemCost(Items.EMERALD, esmeraldas);
        ItemStack producto = new ItemStack(this.producto, cantidad);
        return new MerchantOffer(coste, producto, maxUsos, xp, 0.05F);
    }
}
