package com.moin.item;

import com.moin.Moin;
import net.minecraft.core.registries.Registries;
import net.minecraft.network.chat.Component;
import net.minecraft.world.item.CreativeModeTab;
import net.minecraft.world.item.ItemStack;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModCreativeTabs {
    public static final DeferredRegister<CreativeModeTab> TABS =
            DeferredRegister.create(Registries.CREATIVE_MODE_TAB, Moin.MODID);

    public static final DeferredHolder<CreativeModeTab, CreativeModeTab> MOIN_TAB = TABS.register("moin_tab",
            () -> CreativeModeTab.builder()
                    .title(Component.translatable("itemGroup.moin.moin_tab"))
                    .icon(() -> new ItemStack(ModItems.PORRO.get()))
                    .displayItems((parametros, salida) -> {
                        salida.accept(ModItems.SEMILLA_HIERBA.get());
                        salida.accept(ModItems.SEMILLA_COCA.get());
                        salida.accept(ModItems.COGOLLO.get());
                        salida.accept(ModItems.HOJA_COCA.get());
                        salida.accept(ModItems.PORRO.get());
                        salida.accept(ModItems.POLVO_BRUTO.get());
                        salida.accept(ModItems.POLVO_BLANCO.get());
                        salida.accept(ModItems.CRISTAL.get());
                        salida.accept(ModItems.HONGO_ALUCINANTE.get());
                        salida.accept(ModItems.TRIPI.get());
                        salida.accept(ModItems.PASTILLA.get());
                        salida.accept(ModItems.CERVEZA.get());
                        salida.accept(ModItems.PIPA.get());
                        salida.accept(ModItems.MESA_PROCESADO.get());
                    })
                    .build());

    public static void register(IEventBus bus) {
        TABS.register(bus);
    }
}
