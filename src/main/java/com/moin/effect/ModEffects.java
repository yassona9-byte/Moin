package com.moin.effect;

import com.moin.Moin;
import net.minecraft.core.registries.Registries;
import net.minecraft.world.effect.MobEffect;
import net.minecraft.world.effect.MobEffectCategory;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModEffects {
    public static final DeferredRegister<MobEffect> EFFECTS =
            DeferredRegister.create(Registries.MOB_EFFECT, Moin.MODID);

    // "Colocon": relajado, te alimenta poco a poco.
    public static final DeferredHolder<MobEffect, MobEffect> COLOCON = EFFECTS.register("colocon",
            () -> new MoinEffect(MobEffectCategory.NEUTRAL, 0x6AA84F, MoinEffect.Tipo.COMER, 40));

    // "Subidon": energia, ligeramente beneficioso.
    public static final DeferredHolder<MobEffect, MobEffect> SUBIDON = EFFECTS.register("subidon",
            () -> new MoinEffect(MobEffectCategory.BENEFICIAL, 0xFFD966, MoinEffect.Tipo.CURAR, 30));

    // "Viaje": alucinante pero peligroso, te va danando.
    public static final DeferredHolder<MobEffect, MobEffect> VIAJE = EFFECTS.register("viaje",
            () -> new MoinEffect(MobEffectCategory.HARMFUL, 0xC27BA0, MoinEffect.Tipo.DANAR, 30));

    // "Resaca": el bajon, te va quitando vida lentamente.
    public static final DeferredHolder<MobEffect, MobEffect> RESACA = EFFECTS.register("resaca",
            () -> new MoinEffect(MobEffectCategory.HARMFUL, 0x7F6000, MoinEffect.Tipo.DANAR, 60));

    // "Euforia": felicidad total, te cura.
    public static final DeferredHolder<MobEffect, MobEffect> EUFORIA = EFFECTS.register("euforia",
            () -> new MoinEffect(MobEffectCategory.BENEFICIAL, 0xFF66CC, MoinEffect.Tipo.CURAR, 25));

    // "Borrachera": mareo y torpeza, te alimenta un poco (las ganas de picar).
    public static final DeferredHolder<MobEffect, MobEffect> BORRACHERA = EFFECTS.register("borrachera",
            () -> new MoinEffect(MobEffectCategory.NEUTRAL, 0xE6B800, MoinEffect.Tipo.COMER, 50));

    // "Mono" (sindrome de abstinencia): el peor bajon, te va danando.
    public static final DeferredHolder<MobEffect, MobEffect> MONO = EFFECTS.register("mono",
            () -> new MoinEffect(MobEffectCategory.HARMFUL, 0x3D3D3D, MoinEffect.Tipo.DANAR, 40));

    public static void register(IEventBus bus) {
        EFFECTS.register(bus);
    }
}
