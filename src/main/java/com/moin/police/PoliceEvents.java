package com.moin.police;

import com.moin.Moin;
import com.moin.util.Contrabando;
import net.minecraft.ChatFormatting;
import net.minecraft.core.BlockPos;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.Difficulty;
import net.minecraft.world.entity.EntityType;
import net.minecraft.world.entity.MobSpawnType;
import net.minecraft.world.entity.ai.attributes.Attributes;
import net.minecraft.world.entity.monster.Vindicator;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.phys.AABB;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.tick.PlayerTickEvent;

import java.util.List;

/**
 * La poli reacciona a la mercancia que llevas encima:
 *  - Mercancia media: aparecen "Polis" sueltos que te persiguen.
 *  - Mercancia muy alta: salta una REDADA (varios polis + un capitan a la vez).
 */
@EventBusSubscriber(modid = Moin.MODID)
public class PoliceEvents {

    private static final int INTERVALO = 100;        // revisa cada 5 segundos
    private static final int UMBRAL = 16;            // poli suelto
    private static final int UMBRAL_REDADA = 40;     // redada
    private static final int MAX_POLIS_CERCA = 4;
    private static final double RADIO_BUSQUEDA = 28.0;

    @SubscribeEvent
    public static void onPlayerTick(PlayerTickEvent.Post evento) {
        Player jugador = evento.getEntity();
        if (jugador.level().isClientSide || jugador.isCreative() || jugador.isSpectator()) {
            return;
        }
        if (!(jugador.level() instanceof ServerLevel nivel)) {
            return;
        }
        if (nivel.getDifficulty() == Difficulty.PEACEFUL || jugador.tickCount % INTERVALO != 0) {
            return;
        }

        int mercancia = Contrabando.contar(jugador);
        if (mercancia < UMBRAL) {
            return;
        }

        AABB zona = jugador.getBoundingBox().inflate(RADIO_BUSQUEDA);
        List<Vindicator> cerca = nivel.getEntitiesOfClass(Vindicator.class, zona, Vindicator::hasCustomName);

        // REDADA: si llevas muchisimo y no hay ya un follon montado.
        if (mercancia >= UMBRAL_REDADA && cerca.size() < 2 && nivel.random.nextFloat() < 0.5F) {
            redada(nivel, jugador);
            return;
        }

        if (cerca.size() >= MAX_POLIS_CERCA) {
            return;
        }

        float probabilidad = Math.min(0.8F, (mercancia - UMBRAL) * 0.04F + 0.15F);
        if (nivel.random.nextFloat() <= probabilidad) {
            Vindicator poli = aparecerPoli(nivel, jugador, false);
            if (poli != null) {
                jugador.displayClientMessage(
                        Component.translatable("message.moin.poli").withStyle(ChatFormatting.RED), true);
            }
        }
    }

    private static void redada(ServerLevel nivel, Player jugador) {
        for (int i = 0; i < 4; i++) {
            aparecerPoli(nivel, jugador, false);
        }
        aparecerPoli(nivel, jugador, true); // el capitan
        jugador.displayClientMessage(
                Component.translatable("message.moin.redada").withStyle(ChatFormatting.DARK_RED, ChatFormatting.BOLD), false);
        nivel.playSound(null, jugador.blockPosition(),
                net.minecraft.sounds.SoundEvents.RAID_HORN.value(),
                net.minecraft.sounds.SoundSource.HOSTILE, 1.0F, 1.0F);
    }

    private static Vindicator aparecerPoli(ServerLevel nivel, Player jugador, boolean capitan) {
        double ang = nivel.random.nextDouble() * Math.PI * 2;
        double dist = 8 + nivel.random.nextDouble() * 5;
        BlockPos pos = BlockPos.containing(
                jugador.getX() + Math.cos(ang) * dist,
                jugador.getY(),
                jugador.getZ() + Math.sin(ang) * dist);

        Vindicator poli = EntityType.VINDICATOR.spawn(nivel, pos, MobSpawnType.EVENT);
        if (poli == null) {
            return null;
        }
        if (capitan) {
            poli.setCustomName(Component.literal("👮‍♂️ Capitán").withStyle(ChatFormatting.GOLD));
            var atributo = poli.getAttribute(Attributes.MAX_HEALTH);
            if (atributo != null) {
                atributo.setBaseValue(40.0);
                poli.setHealth(40.0F);
            }
        } else {
            poli.setCustomName(Component.literal("👮 Poli").withStyle(ChatFormatting.BLUE));
        }
        poli.setCustomNameVisible(true);
        poli.setPersistenceRequired();
        poli.setTarget(jugador);
        return poli;
    }
}
