package com.moin.effect;

import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectCategory;
import net.minecraft.world.entity.LivingEntity;
import net.minecraft.world.entity.player.Player;

/**
 * Efecto generico configurable. Cada cierto numero de ticks aplica una pequena
 * accion (curar, danar o alimentar) segun el "tipo". Asi todos los efectos del
 * mod comparten una sola clase.
 */
public class MoinEffect extends MobEffect {

    public enum Tipo {
        CURAR,   // restaura un poco de vida
        DANAR,   // hace un poco de dano (mal viaje / resaca)
        COMER    // restaura un poco de hambre
    }

    private final Tipo tipo;
    private final int intervalo;

    public MoinEffect(MobEffectCategory categoria, int color, Tipo tipo, int intervalo) {
        super(categoria, color);
        this.tipo = tipo;
        this.intervalo = Math.max(1, intervalo);
    }

    @Override
    public boolean applyEffectTick(LivingEntity entidad, int amplificador) {
        switch (tipo) {
            case CURAR -> entidad.heal(1.0F + amplificador);
            case DANAR -> entidad.hurt(entidad.damageSources().magic(), 1.0F);
            case COMER -> {
                if (entidad instanceof Player jugador) {
                    jugador.getFoodData().eat(1 + amplificador, 0.2F);
                }
            }
        }
        return true;
    }

    @Override
    public boolean shouldApplyEffectTickThisTick(int duracion, int amplificador) {
        return duracion % intervalo == 0;
    }
}
