package com.moin.item;

import net.minecraft.core.Holder;
import net.minecraft.sounds.SoundEvent;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;

import java.util.List;
import java.util.function.Supplier;

/**
 * Item ficticio que se "consume" (se come/usa) y al terminar aplica una lista de
 * efectos de pocion y reproduce un sonido. Todo el efecto es dentro del juego.
 */
public class ConsumibleItem extends Item {
    private final Holder<SoundEvent> sonido;
    private final List<Supplier<MobEffectInstance>> efectos;

    public ConsumibleItem(Properties propiedades,
                          Holder<SoundEvent> sonido,
                          List<Supplier<MobEffectInstance>> efectos) {
        super(propiedades);
        this.sonido = sonido;
        this.efectos = efectos;
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
        }
        return resultado;
    }
}
