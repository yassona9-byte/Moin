package com.moin.item;

import com.moin.Moin;
import com.moin.block.ModBlocks;
import com.moin.effect.ModEffects;
import com.moin.sound.ModSounds;
import net.minecraft.core.Holder;
import net.minecraft.core.particles.ParticleOptions;
import net.minecraft.core.particles.ParticleTypes;
import net.minecraft.sounds.SoundEvent;
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

    // ---- Semillas: plantan los cultivos al usarse sobre tierra de cultivo ----
    public static final DeferredItem<Item> SEMILLA_HIERBA = ITEMS.registerItem("semilla_hierba",
            props -> new ItemNameBlockItem(ModBlocks.COGOLLO_CROP.get(), props),
            new Item.Properties());

    public static final DeferredItem<Item> SEMILLA_COCA = ITEMS.registerItem("semilla_coca",
            props -> new ItemNameBlockItem(ModBlocks.COCA_CROP.get(), props),
            new Item.Properties());

    // ---- Ingredientes (se procesan en la mesa, no se consumen) ----
    public static final DeferredItem<Item> COGOLLO = ITEMS.registerSimpleItem("cogollo");
    public static final DeferredItem<Item> HOJA_COCA = ITEMS.registerSimpleItem("hoja_coca");
    public static final DeferredItem<Item> POLVO_BRUTO = ITEMS.registerSimpleItem("polvo_bruto");

    // ---- Consumibles con efectos ----
    public static final DeferredItem<Item> PORRO = ITEMS.registerItem("porro",
            props -> new ConsumibleItem(props, ModSounds.TOKE, ParticleTypes.CAMPFIRE_COSY_SMOKE, false, 8, List.of(
                    () -> new MobEffectInstance(ModEffects.COLOCON, 1200, 0),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 300, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 600, 0),
                    () -> new MobEffectInstance(MobEffects.HUNGER, 400, 0))),
            comida(2, 0.2F));

    public static final DeferredItem<Item> POLVO_BLANCO = ITEMS.registerItem("polvo_blanco",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, ParticleTypes.CLOUD, false, 15, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 600, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 600, 1),
                    () -> new MobEffectInstance(MobEffects.DIG_SPEED, 600, 1),
                    () -> new MobEffectInstance(ModEffects.RESACA, 1200, 0))),
            comida(1, 0.1F));

    public static final DeferredItem<Item> HONGO_ALUCINANTE = ITEMS.registerItem("hongo_alucinante",
            props -> new ConsumibleItem(props, ModSounds.VIAJE, ParticleTypes.WITCH, false, 10, List.of(
                    () -> new MobEffectInstance(ModEffects.VIAJE, 800, 0),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 800, 0),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 800, 0),
                    () -> new MobEffectInstance(MobEffects.JUMP, 800, 1))),
            comida(2, 0.1F));

    public static final DeferredItem<Item> PASTILLA = ITEMS.registerItem("pastilla",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, ParticleTypes.HAPPY_VILLAGER, false, 18, List.of(
                    () -> new MobEffectInstance(ModEffects.EUFORIA, 900, 0),
                    () -> new MobEffectInstance(MobEffects.REGENERATION, 200, 0),
                    () -> new MobEffectInstance(MobEffects.ABSORPTION, 900, 1),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 900, 0),
                    () -> new MobEffectInstance(ModEffects.RESACA, 1800, 1))),
            comida(1, 0.1F));

    public static final DeferredItem<Item> CERVEZA = ITEMS.registerItem("cerveza",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, ParticleTypes.SPLASH, true, 5, List.of(
                    () -> new MobEffectInstance(ModEffects.BORRACHERA, 900, 0),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 300, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 600, 0))),
            comida(3, 0.3F));

    public static final DeferredItem<Item> TRIPI = ITEMS.registerItem("tripi",
            props -> new ConsumibleItem(props, ModSounds.VIAJE, ParticleTypes.ENCHANT, false, 12, List.of(
                    () -> new MobEffectInstance(ModEffects.VIAJE, 2400, 1),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 1200, 0),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 2400, 0),
                    () -> new MobEffectInstance(MobEffects.SLOW_FALLING, 2400, 0),
                    () -> new MobEffectInstance(MobEffects.JUMP, 2400, 2))),
            comida(1, 0.0F));

    public static final DeferredItem<Item> CRISTAL = ITEMS.registerItem("cristal",
            props -> new ConsumibleItem(props, ModSounds.ESNIFAR, ParticleTypes.CRIT, false, 25, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 1200, 1),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 1200, 2),
                    () -> new MobEffectInstance(MobEffects.DIG_SPEED, 1200, 2),
                    () -> new MobEffectInstance(ModEffects.RESACA, 2400, 1),
                    () -> new MobEffectInstance(ModEffects.MONO, 2400, 0))),
            comida(1, 0.0F));

    // ---- Mezclas (estilo Schedule 1: base + ingrediente = mezcla con efectos combinados) ----
    public static final DeferredItem<Item> SPEEDBALL = mezcla("speedball",
            ModSounds.ESNIFAR, ParticleTypes.CRIT, 30, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 1200, 1),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 1200, 2),
                    () -> new MobEffectInstance(MobEffects.DIG_SPEED, 1200, 2),
                    () -> new MobEffectInstance(MobEffects.DAMAGE_BOOST, 1200, 0),
                    () -> new MobEffectInstance(ModEffects.RESACA, 2400, 1),
                    () -> new MobEffectInstance(ModEffects.MONO, 2400, 0)));

    public static final DeferredItem<Item> MARIA_DORADA = mezcla("maria_dorada",
            ModSounds.TOKE, ParticleTypes.HAPPY_VILLAGER, 12, List.of(
                    () -> new MobEffectInstance(ModEffects.COLOCON, 1800, 0),
                    () -> new MobEffectInstance(MobEffects.REGENERATION, 200, 0),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 1200, 0),
                    () -> new MobEffectInstance(MobEffects.SATURATION, 1, 1)));

    public static final DeferredItem<Item> POLVO_ANGEL = mezcla("polvo_angel",
            ModSounds.ESNIFAR, ParticleTypes.FLAME, 22, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 900, 0),
                    () -> new MobEffectInstance(MobEffects.DAMAGE_BOOST, 900, 1),
                    () -> new MobEffectInstance(MobEffects.FIRE_RESISTANCE, 900, 0),
                    () -> new MobEffectInstance(ModEffects.RESACA, 1200, 0)));

    public static final DeferredItem<Item> CARAMELO = mezcla("caramelo",
            ModSounds.ESNIFAR, ParticleTypes.HEART, 16, List.of(
                    () -> new MobEffectInstance(ModEffects.EUFORIA, 900, 0),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 900, 0),
                    () -> new MobEffectInstance(MobEffects.JUMP, 900, 1),
                    () -> new MobEffectInstance(MobEffects.REGENERATION, 100, 0)));

    public static final DeferredItem<Item> BOMBA_MENTAL = mezcla("bomba_mental",
            ModSounds.ESNIFAR, ParticleTypes.EXPLOSION, 28, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 1200, 1),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 600, 0),
                    () -> new MobEffectInstance(MobEffects.WEAKNESS, 1200, 0),
                    () -> new MobEffectInstance(ModEffects.RESACA, 2400, 1),
                    () -> new MobEffectInstance(ModEffects.MONO, 2400, 0)));

    public static final DeferredItem<Item> TRIPI_DOBLE = mezcla("tripi_doble",
            ModSounds.VIAJE, ParticleTypes.ENCHANT, 18, List.of(
                    () -> new MobEffectInstance(ModEffects.VIAJE, 3600, 1),
                    () -> new MobEffectInstance(MobEffects.CONFUSION, 1800, 1),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 3600, 0),
                    () -> new MobEffectInstance(MobEffects.JUMP, 3600, 2)));

    public static final DeferredItem<Item> MIEL_LOCA = mezcla("miel_loca",
            ModSounds.TOKE, ParticleTypes.FALLING_HONEY, 10, List.of(
                    () -> new MobEffectInstance(ModEffects.COLOCON, 1200, 0),
                    () -> new MobEffectInstance(MobEffects.SATURATION, 1, 2),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SLOWDOWN, 600, 1),
                    () -> new MobEffectInstance(MobEffects.ABSORPTION, 1200, 0)));

    public static final DeferredItem<Item> ELECTRICA = mezcla("electrica",
            ModSounds.ESNIFAR, ParticleTypes.ELECTRIC_SPARK, 20, List.of(
                    () -> new MobEffectInstance(ModEffects.SUBIDON, 900, 0),
                    () -> new MobEffectInstance(MobEffects.DIG_SPEED, 900, 2),
                    () -> new MobEffectInstance(MobEffects.MOVEMENT_SPEED, 900, 1),
                    () -> new MobEffectInstance(MobEffects.GLOWING, 900, 0)));

    // ---- Escaner antidroga (detector) ----
    public static final DeferredItem<Item> ESCANER = ITEMS.registerItem("escaner",
            EscanerItem::new, new Item.Properties().stacksTo(1));

    // ---- Antidoto (naloxona): cura la sobredosis y limpia efectos ----
    public static final DeferredItem<Item> ANTIDOTO = ITEMS.registerItem("antidoto",
            AntidotoItem::new, new Item.Properties().food(new net.minecraft.world.food.FoodProperties.Builder()
                    .nutrition(0).saturationModifier(0F).alwaysEdible().build()));

    // ---- Pipa reutilizable (con durabilidad) ----
    public static final DeferredItem<Item> PIPA = ITEMS.registerItem("pipa",
            PipaItem::new, new Item.Properties().durability(64));

    // ---- Items de los bloques ----
    public static final DeferredItem<net.minecraft.world.item.BlockItem> MESA_PROCESADO =
            ITEMS.registerSimpleBlockItem("mesa_procesado", ModBlocks.MESA_PROCESADO);

    public static final DeferredItem<net.minecraft.world.item.BlockItem> LABORATORIO =
            ITEMS.registerSimpleBlockItem("laboratorio", ModBlocks.LABORATORIO);

    private static DeferredItem<Item> mezcla(String nombre, Holder<SoundEvent> sonido,
                                             ParticleOptions particula, int adictividad,
                                             List<java.util.function.Supplier<net.minecraft.world.effect.MobEffectInstance>> efectos) {
        return ITEMS.registerItem(nombre,
                props -> new ConsumibleItem(props, sonido, particula, false, adictividad, efectos),
                comida(1, 0.1F));
    }

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
