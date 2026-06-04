package com.moin.sound;

import com.moin.Moin;
import net.minecraft.resources.ResourceLocation;
import net.minecraft.sounds.SoundEvent;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModSounds {
    public static final DeferredRegister<SoundEvent> SOUNDS =
            DeferredRegister.create(net.minecraft.core.registries.Registries.SOUND_EVENT, Moin.MODID);

    public static final DeferredHolder<SoundEvent, SoundEvent> TOKE = registrar("toke");
    public static final DeferredHolder<SoundEvent, SoundEvent> ESNIFAR = registrar("esnifar");
    public static final DeferredHolder<SoundEvent, SoundEvent> VIAJE = registrar("viaje");

    private static DeferredHolder<SoundEvent, SoundEvent> registrar(String nombre) {
        return SOUNDS.register(nombre,
                () -> SoundEvent.createVariableRangeEvent(ResourceLocation.fromNamespaceAndPath(Moin.MODID, nombre)));
    }

    public static void register(IEventBus bus) {
        SOUNDS.register(bus);
    }
}
