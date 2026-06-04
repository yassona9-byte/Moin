package com.moin.addiction;

import com.mojang.serialization.Codec;
import com.moin.Moin;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.attachment.AttachmentType;
import net.neoforged.neoforge.registries.DeferredRegister;
import net.neoforged.neoforge.registries.NeoForgeRegistries;

import java.util.function.Supplier;

/**
 * Datos persistentes que se guardan en cada jugador para el sistema de adiccion.
 * - adiccion: nivel de enganche (0-100).
 * - saciedad: ticks que quedan hasta que empiece el mono si no consumes mas.
 */
public class ModAttachments {
    public static final DeferredRegister<AttachmentType<?>> ATTACHMENT_TYPES =
            DeferredRegister.create(NeoForgeRegistries.Keys.ATTACHMENT_TYPES, Moin.MODID);

    public static final Supplier<AttachmentType<Integer>> ADICCION =
            ATTACHMENT_TYPES.register("adiccion",
                    () -> AttachmentType.builder(() -> 0).serialize(Codec.INT).build());

    public static final Supplier<AttachmentType<Integer>> SACIEDAD =
            ATTACHMENT_TYPES.register("saciedad",
                    () -> AttachmentType.builder(() -> 0).serialize(Codec.INT).build());

    public static void register(IEventBus bus) {
        ATTACHMENT_TYPES.register(bus);
    }
}
