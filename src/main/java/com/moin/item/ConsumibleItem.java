package com.moin.item;

import com.moin.addiction.AddictionEvents;
import net.minecraft.core.Holder;
import net.minecraft.core.particles.ParticleOptions;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundEvent;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.UseAnim;
import net.minecraft.world.level.Level;
import org.jetbrains.annotations.Nullable;

import java.util.List;
import java.util.function.Supplier;

/**
 * Item ficticio que se "consume" (se come o se bebe) y al terminar aplica una
 * lista de efectos de pocion, reproduce un sonido y suelta particulas.
 * Todo el efecto es dentro del juego.
 */
public class ConsumibleItem extends Item {
    private final Holder<SoundEvent> sonido;
    private final List<Supplier<MobEffectInstance>> efectos;
    @Nullable
    private final ParticleOptions particula;
    private final boolean beber;
    private final int adictividad;

    public ConsumibleItem(Properties propiedades,
                          Holder<SoundEvent> sonido,
                          @Nullable ParticleOptions particula,
                          boolean beber,
                          int adictividad,
                          List<Supplier<MobEffectInstance>> efectos) {
        super(propiedades);
        this.sonido = sonido;
        this.particula = particula;
        this.beber = beber;
        this.adictividad = adictividad;
        this.efectos = efectos;
    }

    @Override
    public UseAnim getUseAnimation(ItemStack stack) {
        return beber ? UseAnim.DRINK : UseAnim.EAT;
    }

    @Override
    public ItemStack finishUsingItem(ItemStack stack, Level level, LivingEntity entidad) {
        ItemStack resultado = super.finishUsingItem(stack, level, entidad);

        if (!level.isClientSide) {
            for (Supplier<MobEffectInstance> efecto : efectos) {
                entidad.addEffect(efecto.get());
            }
            if (sonido != null) {
                level.playSound(null, entidad.getX(), entidad.getY(), entidad.getZ(),
                        sonido.value(), SoundSource.PLAYERS, 1.0F, 1.0F);
            }
            if (particula != null && level instanceof ServerLevel servidor) {
                servidor.sendParticles(particula,
                        entidad.getX(), entidad.getEyeY(), entidad.getZ(),
                        25, 0.3, 0.3, 0.3, 0.02);
            }
            if (entidad instanceof Player jugador) {
                AddictionEvents.registrarConsumo(jugador, adictividad);
            }
        }
        return resultado;
    }
}
