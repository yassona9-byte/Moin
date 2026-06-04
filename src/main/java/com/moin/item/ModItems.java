package com.moin.item;

import com.moin.Moin;
import com.moin.block.ModBlocks;
import com.moin.effect.ModEffects;
import com.moin.sound.ModSounds;
import net.minecraft.world.effect.MobEffectInstance;
import net.minecraft.world.effect.MobEffects;
import net.minecraft.world.food.FoodProperties;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemNameBlockItem;
import net.neoforged.bus.api.IEventBus;
import net.neoforged.neoforge.registries.DeferredItem;
import net.neoforged.neoforge.registries.DeferredRegister;

import java.util.List;

public class ModItems {
    public static final DeferredRegister.Items ITEMS = DeferredRegister.createItems(Moin.MODID);

    // ---- Semilla: planta el cultivo de cogollo al usarla sobre tierra de cultivo ----
    public static final DeferredItem<Item> SEMILLA_HIERBA = ITEMS.registerItem("semilla_hierba",
            props -> new ItemNameBlockItem(ModBlocks.COGOLLO_CROP.get(), props),
            new Item.Properties());

    // ---- Ingredientes (no se consumen, se procesan en la mesa) ----
    public static final DeferredItem<Item> COGOLLO = ITEMS.registerSimpleItem("cogollo");
    public static final DeferredItem<Item> POLVO_BRUTO = ITEMS.registerSimpleItem("polvo_bruto");

    // ---- Consumibles con efectos ----
    public static final DeferredItem<Item> PORRO = ITEMS.registerItem("porro",
            props -> new ConsumibleItem(props, ModSounds.TOKE, List.of(
                    () -> new MobEffectInstance(ModEffects.COLOCON, 1200, 0),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 300, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 600, 0),
                    () -> new MobEffectInstance(MobEffects.HUNGER, 400, 0))),
            comida(2, 0.2F));

    public static final DeferredItem<Item> POLVO_BLANCO = ITEMS.registerItem("polvo_blanco",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 600, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 600, 1),
                    () -> new MobEffectInstance(MobEffects.DIG_SPEED, 600, 1),
                    () -> new MobEffectInstance(ModEffects.RESACA, 1200, 0))),
            comida(1, 0.1F));

    public static final DeferredItem<Item> HONGO_ALUCINANTE = ITEMS.registerItem("hongo_alucinante",
            props -> new ConsumibleItem(props, ModSounds.VIAJE, List.of(
                    () -> new MobEffectInstance(ModEffects.VIAJE, 800, 0),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 800, 0),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 800, 0),
                    () -> new MobEffectInstance(MobEffects.JUMP, 800, 1))),
            comida(2, 0.1F));

    public static final DeferredItem<Item> PASTILLA = ITEMS.registerItem("pastilla",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, List.of(
                    () -> new MobEffectInstance(ModEffects.EUFORIA, 900, 0),
                    () -> new MobEffectInstance(MobEffects.REGENERATION, 200, 0),
                    () -> new MobEffectInstance(MobEffects.ABSORPTION, 900, 1),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 900, 0),
                    () -> new MobEffectInstance(ModEffects.RESACA, 1800, 1))),
            comida(1, 0.1F));

    // ---- Item del bloque de la mesa de procesado ----
    public static final DeferredItem<net.minecraft.world.item.BlockItem> MESA_PROCESADO =
            ITEMS.registerSimpleBlockItem("mesa_procesado", ModBlocks.MESA_PROCESADO);

    private static Item.Properties comida(int nutricion, float saturacion) {
        return new Item.Properties().food(new FoodProperties.Builder()
                .nutrition(nutricion)
                .saturationModifier(saturacion)
                .alwaysEdible()
                .build());
    }

    public static void register(IEventBus bus) {
        ITEMS.register(bus);
    }
}
