package com.moin.police;

import com.moin.Moin;
import com.moin.entity.ModEntities;
import com.moin.entity.PoliEntity;
import com.moin.util.Contrabando;
import net.minecraft.ChatFormatting;
import net.minecraft.core.BlockPos;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.world.Difficulty;
import net.minecraft.world.entity.MobSpawnType;
import net.minecraft.world.entity.ai.attributes.Attributes;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.phys.AABB;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.tick.PlayerTickEvent;

import java.util.List;

/**
 * La poli reacciona a la mercancia que llevas encima, pero con calma:
 *  - Mercancia media: rara vez aparece algun "Poli" suelto que te persigue.
 *  - Mercancia muy alta: puede saltar una REDADA (un par de polis + un capitan).
 *  - Si te quedas limpio (sueltas la mercancia), los polis pierden interes y se van.
 */
@EventBusSubscriber(modid = Moin.MODID)
public class PoliceEvents {

    private static final int INTERVALO = 200;        // revisa cada 10 segundos
    private static final int UMBRAL = 24;            // poli suelto
    private static final int UMBRAL_REDADA = 64;     // redada
    private static final int MAX_POLIS_CERCA = 2;
    private static final double RADIO_BUSQUEDA = 40.0;

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

        AABB zona = jugador.getBoundingBox().inflate(RADIO_BUSQUEDA);
        List<PoliEntity> cerca = nivel.getEntitiesOfClass(PoliEntity.class, zona);

        // Si vas limpio, la poli pierde el interes y se larga poco a poco.
        if (mercancia < UMBRAL) {
            if (mercancia == 0 && !cerca.isEmpty()) {
                cerca.get(0).discard();
            }
            return;
        }

        // REDADA: solo con muchisima mercancia, sin follon ya montado y de vez en cuando.
        if (mercancia >= UMBRAL_REDADA && cerca.isEmpty() && nivel.random.nextFloat() < 0.25F) {
            redada(nivel, jugador);
            return;
        }

        if (cerca.size() >= MAX_POLIS_CERCA) {
            return;
        }

        // Probabilidad baja y con tope suave.
        float probabilidad = Math.min(0.30F, (mercancia - UMBRAL) * 0.01F + 0.06F);
        if (nivel.random.nextFloat() <= probabilidad) {
            PoliEntity poli = aparecerPoli(nivel, jugador, false);
            if (poli != null) {
                jugador.displayClientMessage(
                        Component.translatable("message.moin.poli").withStyle(ChatFormatting.RED), true);
            }
        }
    }

    private static void redada(ServerLevel nivel, Player jugador) {
        for (int i = 0; i < 2; i++) {
            aparecerPoli(nivel, jugador, false);
        }
        aparecerPoli(nivel, jugador, true); // el capitan
        jugador.displayClientMessage(
                Component.translatable("message.moin.redada").withStyle(ChatFormatting.DARK_RED, ChatFormatting.BOLD), false);
        nivel.playSound(null, jugador.blockPosition(),
                net.minecraft.sounds.SoundEvents.RAID_HORN.value(),
                net.minecraft.sounds.SoundSource.HOSTILE, 1.0F, 1.0F);
    }

    private static PoliEntity aparecerPoli(ServerLevel nivel, Player jugador, boolean capitan) {
        double ang = nivel.random.nextDouble() * Math.PI * 2;
        double dist = 10 + nivel.random.nextDouble() * 6;
        BlockPos pos = BlockPos.containing(
                jugador.getX() + Math.cos(ang) * dist,
                jugador.getY(),
                jugador.getZ() + Math.sin(ang) * dist);

        PoliEntity poli = ModEntities.POLI.get().spawn(nivel, pos, MobSpawnType.EVENT);
        if (poli == null) {
            return null;
        }
        if (capitan) {
            poli.setCustomName(Component.literal("👮‍♂️ Capitán").withStyle(ChatFormatting.GOLD));
            poli.setCustomNameVisible(true);
            var atributo = poli.getAttribute(Attributes.MAX_HEALTH);
            if (atributo != null) {
                atributo.setBaseValue(40.0);
                poli.setHealth(40.0F);
            }
        }
        poli.setPersistenceRequired();
        poli.setTarget(jugador);
        return poli;
    }
}
