package com.moin.addiction;

import com.moin.Moin;
import com.moin.effect.ModEffects;
import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.entity.player.Player;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.event.tick.PlayerTickEvent;

/**
 * Logica del sistema de adiccion. Se revisa cada segundo en el servidor:
 * mientras estes "saciado" no pasa nada, pero cuando se acaba la saciedad y tu
 * adiccion es alta, te entra el mono (efecto MONO) hasta que vuelvas a consumir.
 * Si aguantas sin consumir, la adiccion baja poco a poco.
 */
@EventBusSubscriber(modid = Moin.MODID)
public class AddictionEvents {

    private static final int INTERVALO = 20; // ticks (1 segundo)
    private static final int UMBRAL_MONO = 30;
    private static final int UMBRAL_SOBREDOSIS = 100;

    @SubscribeEvent
    public static void onPlayerTick(PlayerTickEvent.Post evento) {
        Player jugador = evento.getEntity();
        if (jugador.level().isClientSide) {
            return;
        }
        if (jugador.tickCount % INTERVALO != 0) {
            return;
        }

        int adiccion = jugador.getData(ModAttachments.ADICCION.get());
        int saciedad = jugador.getData(ModAttachments.SACIEDAD.get());

        if (saciedad > 0) {
            jugador.setData(ModAttachments.SACIEDAD.get(), Math.max(0, saciedad - INTERVALO));
            return;
        }

        if (adiccion >= UMBRAL_MONO) {
            // Aviso solo la primera vez que aparece el mono.
            if (!jugador.hasEffect(ModEffects.MONO)) {
                jugador.displayClientMessage(
                        Component.translatable("message.moin.mono")
                                .withStyle(net.minecraft.ChatFormatting.DARK_GRAY), true);
            }
            // Mono: el efecto se refresca para que no se quite hasta que consumas.
            int nivel = adiccion >= 70 ? 1 : 0;
            jugador.addEffect(new MobEffectInstance(ModEffects.MONO, 60, nivel, false, true));
        }

        // Sin consumir, la adiccion baja lentamente.
        if (adiccion > 0) {
            jugador.setData(ModAttachments.ADICCION.get(), adiccion - 1);
        }

        // La toxicidad baja poco a poco con el tiempo.
        int toxicidad = jugador.getData(ModAttachments.TOXICIDAD.get());
        if (toxicidad > 0) {
            jugador.setData(ModAttachments.TOXICIDAD.get(), Math.max(0, toxicidad - 3));
        }
    }

    /** Provoca una sobredosis: efectos graves y un buen golpe de dano. */
    public static void sobredosis(Player jugador) {
        jugador.addEffect(new MobEffectInstance(MobEffects.WITHER, 200, 1));
        jugador.addEffect(new MobEffectInstance(MobEffects.POISON, 200, 1));
        jugador.addEffect(new MobEffectInstance(MobEffects.BLINDNESS, 160, 0));
        jugador.addEffect(new MobEffectInstance(MobEffects.CONFUSION, 300, 0));
        jugador.addEffect(new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 200, 2));
        jugador.hurt(jugador.damageSources().magic(), 6.0F);
        jugador.displayClientMessage(
                Component.translatable("message.moin.sobredosis")
                        .withStyle(ChatFormatting.DARK_RED, ChatFormatting.BOLD), false);
        // Tras la sobredosis baja la toxicidad para no encadenar otra al instante.
        jugador.setData(ModAttachments.TOXICIDAD.get(), 50);
    }

    /** Llamado desde el item al consumir: sube la adiccion, la toxicidad y sacia el mono. */
    public static void registrarConsumo(Player jugador, int adictividad) {
        int adiccion = Math.min(100, jugador.getData(ModAttachments.ADICCION.get()) + adictividad);
        jugador.setData(ModAttachments.ADICCION.get(), adiccion);
        // Cuanto mas enganchado, antes vuelve el mono (saciedad mas corta).
        int saciedad = Math.max(400, 1600 - adiccion * 10);
        jugador.setData(ModAttachments.SACIEDAD.get(), saciedad);
        jugador.removeEffect(ModEffects.MONO);

        // Toxicidad: las cosas mas fuertes (mas adictivas) intoxican mas.
        int toxicidad = jugador.getData(ModAttachments.TOXICIDAD.get()) + Math.max(4, adictividad);
        jugador.setData(ModAttachments.TOXICIDAD.get(), toxicidad);
        if (toxicidad >= UMBRAL_SOBREDOSIS) {
            sobredosis(jugador);
        }
    }

    /** Usado por el antidoto: limpia la toxicidad y los efectos peligrosos. */
    public static void limpiar(Player jugador) {
        jugador.setData(ModAttachments.TOXICIDAD.get(), 0);
        jugador.removeEffect(ModEffects.MONO);
        jugador.removeEffect(ModEffects.RESACA);
        jugador.removeEffect(MobEffects.WITHER);
        jugador.removeEffect(MobEffects.POISON);
        jugador.removeEffect(MobEffects.BLINDNESS);
        jugador.removeEffect(MobEffects.CONFUSION);
    }
}
