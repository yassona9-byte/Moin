package com.moin.menu;

import com.moin.Moin;
import net.minecraft.core.registries.Registries;
import net.minecraft.world.inventory.MenuType;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.common.extensions.IMenuTypeExtension;
import net.neoforged.neoforge.registries.DeferredHolder;
import net.neoforged.neoforge.registries.DeferredRegister;

public class ModMenuTypes {
    public static final DeferredRegister<MenuType<?>> MENUS =
            DeferredRegister.create(Registries.MENU, Moin.MODID);

    public static final DeferredHolder<MenuType<?>, MenuType<MesaProcesadoMenu>> MESA_PROCESADO =
            MENUS.register("mesa_procesado",
                    () -> IMenuTypeExtension.create(MesaProcesadoMenu::new));

    public static void register(IEventBus bus) {
        MENUS.register(bus);
    }
}
