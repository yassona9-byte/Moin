package com.moin.police;

import com.moin.Moin;
import com.moin.item.ConsumibleItem;
import com.moin.item.ModItems;
import net.minecraft.ChatFormatting;
import net.minecraft.core.BlockPos;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.Difficulty;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.MobSpawnType;
import net.minecraft.world.entity.monster.Vindicator;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.phys.AABB;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.tick.PlayerTickEvent;

import java.util.List;

/**
 * Si el jugador lleva mucha "mercancia" encima, de vez en cuando aparece un
 * "Poli" (un vindicador con nombre) que le persigue y ataca. Cuanta mas mercancia,
 * mas probable. Si la sueltas o la gastas, dejan de aparecer.
 */
@EventBusSubscriber(modid = Moin.MODID)
public class PoliceEvents {

    private static final int INTERVALO = 100;       // revisa cada 5 segundos
    private static final int UMBRAL = 16;           // a partir de 16 items de mercancia
    private static final int MAX_POLIS_CERCA = 3;
    private static final double RADIO_BUSQUEDA = 24.0;

    @SubscribeEvent
    public static void onPlayerTick(PlayerTickEvent.Post evento) {
        Player jugador = evento.getEntity();
        if (jugador.level().isClientSide || jugador.isCreative() || jugador.isSpectator()) {
            return;
        }
        if (!(jugador.level() instanceof ServerLevel nivel)) {
            return;
        }
        if (nivel.getDifficulty() == Difficulty.PEACEFUL) {
            return;
        }
        if (jugador.tickCount % INTERVALO != 0) {
            return;
        }

        int mercancia = contarMercancia(jugador);
        if (mercancia < UMBRAL) {
            return;
        }

        // Probabilidad creciente segun la mercancia (tope 80%).
        float probabilidad = Math.min(0.8F, (mercancia - UMBRAL) * 0.04F + 0.15F);
        if (nivel.random.nextFloat() > probabilidad) {
            return;
        }

        // No saturar: limita los polis cercanos.
        AABB zona = jugador.getBoundingBox().inflate(RADIO_BUSQUEDA);
        List<Vindicator> cerca = nivel.getEntitiesOfClass(Vindicator.class, zona,
                v -> v.hasCustomName());
        if (cerca.size() >= MAX_POLIS_CERCA) {
            return;
        }

        aparecerPoli(nivel, jugador);
    }

    private static void aparecerPoli(ServerLevel nivel, Player jugador) {
        // Posicion a 8-12 bloques del jugador.
        double ang = nivel.random.nextDouble() * Math.PI * 2;
        double dist = 8 + nivel.random.nextDouble() * 4;
        BlockPos pos = BlockPos.containing(
                jugador.getX() + Math.cos(ang) * dist,
                jugador.getY(),
                jugador.getZ() + Math.sin(ang) * dist);

        Vindicator poli = EntityType.VINDICATOR.spawn(nivel, pos, MobSpawnType.EVENT);
        if (poli == null) {
            return;
        }
        poli.setCustomName(Component.literal("👮 Poli").withStyle(ChatFormatting.BLUE));
        poli.setCustomNameVisible(true);
        poli.setPersistenceRequired();
        poli.setTarget(jugador);
        jugador.displayClientMessage(
                Component.translatable("message.moin.poli").withStyle(ChatFormatting.RED), true);
    }

    private static int contarMercancia(Player jugador) {
        int total = 0;
        for (ItemStack stack : jugador.getInventory().items) {
            if (esMercancia(stack)) {
                total += stack.getCount();
            }
        }
        return total;
    }

    private static boolean esMercancia(ItemStack stack) {
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
}
