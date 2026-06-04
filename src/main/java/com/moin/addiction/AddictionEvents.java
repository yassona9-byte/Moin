package com.moin.addiction;

import com.moin.Moin;
import com.moin.effect.ModEffects;
import net.minecraft.network.chat.Component;
import net.minecraft.world.effect.MobEffectInstance;
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
    }

    /** Llamado desde el item al consumir: sube la adiccion y sacia el mono. */
    public static void registrarConsumo(Player jugador, int adictividad) {
        int adiccion = Math.min(100, jugador.getData(ModAttachments.ADICCION.get()) + adictividad);
        jugador.setData(ModAttachments.ADICCION.get(), adiccion);
        // Cuanto mas enganchado, antes vuelve el mono (saciedad mas corta).
        int saciedad = Math.max(400, 1600 - adiccion * 10);
        jugador.setData(ModAttachments.SACIEDAD.get(), saciedad);
        jugador.removeEffect(ModEffects.MONO);
    }
}
