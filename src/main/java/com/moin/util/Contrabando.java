package com.moin.util;

import com.moin.item.ConsumibleItem;
import com.moin.item.ModItems;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;

/**
 * Utilidades para saber cuanta "mercancia" lleva un jugador encima.
 * Lo usan tanto la poli como el escaner antidroga.
 */
public final class Contrabando {

    private Contrabando() {
    }

    public static boolean esMercancia(ItemStack stack) {
        if (stack.isEmpty()) {
            return false;
        }
        if (stack.getItem() instanceof ConsumibleItem) {
            return true;
        }
        return stack.is(ModItems.COGOLLO.get())
                || stack.is(ModItems.HOJA_COCA.get())
                || stack.is(ModItems.POLVO_BRUTO.get());
    }

    /** Cantidad total de items de mercancia en el inventario del jugador. */
    public static int contar(Player jugador) {
        int total = 0;
        for (ItemStack stack : jugador.getInventory().items) {
            if (esMercancia(stack)) {
                total += stack.getCount();
            }
        }
        return total;
    }
}
