package com.moin.item;

import com.moin.addiction.AddictionEvents;
import com.moin.effect.ModEffects;
import com.moin.sound.ModSounds;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.server.level.ServerLevel;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.InteractionResultHolder;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.entity.EquipmentSlot;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.UseAnim;
import net.minecraft.world.level.Level;

/**
 * Pipa reutilizable: en vez de gastarse de un solo uso como los consumibles,
 * tiene durabilidad. Cada calada aplica un buen colocon, gasta 1 de durabilidad
 * y suma a la adiccion. Cuando se acaba la durabilidad, se rompe.
 */
public class PipaItem extends Item {

    public PipaItem(Properties propiedades) {
        super(propiedades);
    }

    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player jugador, InteractionHand mano) {
        ItemStack stack = jugador.getItemInHand(mano);
        jugador.startUsingItem(mano);
        return InteractionResultHolder.consume(stack);
    }

    @Override
    public int getUseDuration(ItemStack stack, LivingEntity entidad) {
        return 40;
    }

    @Override
    public UseAnim getUseAnimation(ItemStack stack) {
        return UseAnim.TOOT_HORN;
    }

    @Override
    public ItemStack finishUsingItem(ItemStack stack, Level level, LivingEntity entidad) {
        if (!level.isClientSide) {
            entidad.addEffect(new MobEffectInstance(ModEffects.COLOCON, 1800, 1));
            entidad.addEffect(new MobEffectInstance(MobEffects.CONFUSION, 200, 0));
            entidad.addEffect(new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 400, 0));

            level.playSound(null, entidad.getX(), entidad.getY(), entidad.getZ(),
                    ModSounds.TOKE.value(), SoundSource.PLAYERS, 1.0F, 1.0F);

            if (level instanceof ServerLevel servidor) {
                servidor.sendParticles(ParticleTypes.CAMPFIRE_COSY_SMOKE,
                        entidad.getX(), entidad.getEyeY(), entidad.getZ(),
                        35, 0.3, 0.3, 0.3, 0.02);
            }

            if (entidad instanceof Player jugador) {
                AddictionEvents.registrarConsumo(jugador, 8);
                stack.hurtAndBreak(1, jugador, EquipmentSlot.MAINHAND);
            }
        }
        return stack;
    }
}
