package com.moin.item;

import com.moin.addiction.AddictionEvents;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.UseAnim;
import net.minecraft.world.level.Level;

/**
 * Antidoto (naloxona): al usarlo limpia la toxicidad y quita los efectos
 * peligrosos (sobredosis, mono, resaca, veneno, etc.). Tu salvavidas.
 */
public class AntidotoItem extends Item {

    public AntidotoItem(Properties propiedades) {
        super(propiedades);
    }

    @Override
    public UseAnim getUseAnimation(ItemStack stack) {
        return UseAnim.DRINK;
    }

    @Override
    public ItemStack finishUsingItem(ItemStack stack, Level level, LivingEntity entidad) {
        ItemStack resultado = super.finishUsingItem(stack, level, entidad);
        if (!level.isClientSide && entidad instanceof net.minecraft.world.entity.player.Player jugador) {
            AddictionEvents.limpiar(jugador);
            jugador.addEffect(new MobEffectInstance(MobEffects.REGENERATION, 100, 0));
            level.playSound(null, jugador.getX(), jugador.getY(), jugador.getZ(),
                    SoundEvents.GENERIC_DRINK.value(), SoundSource.PLAYERS, 1.0F, 1.0F);
            if (level instanceof ServerLevel servidor) {
                servidor.sendParticles(ParticleTypes.HEART,
                        jugador.getX(), jugador.getEyeY(), jugador.getZ(),
                        10, 0.3, 0.3, 0.3, 0.01);
            }
        }
        return resultado;
    }
}
