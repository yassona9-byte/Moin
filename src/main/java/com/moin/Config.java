package com.moin;

import net.neoforged.neoforge.common.ModConfigSpec;

/**
 * Configuracion del mod. Genera el archivo "config/moin-common.toml", donde
 * puedes activar/desactivar sistemas (true/false) y ajustar algunos numeros
 * sin tocar el codigo.
 */
public class Config {
    public static final ModConfigSpec.Builder BUILDER = new ModConfigSpec.Builder();

    // ---- Sistemas (on/off) ----
    public static final ModConfigSpec.BooleanValue ADICCION;
    public static final ModConfigSpec.BooleanValue SOBREDOSIS;
    public static final ModConfigSpec.BooleanValue POLICIA;
    public static final ModConfigSpec.BooleanValue REDADAS;
    public static final ModConfigSpec.BooleanValue TRAPICHEO;
    public static final ModConfigSpec.BooleanValue DISTORSION_PANTALLA;
    public static final ModConfigSpec.BooleanValue LAB_PRODUCE;

    // ---- Ajustes numericos ----
    public static final ModConfigSpec.IntValue UMBRAL_POLI;
    public static final ModConfigSpec.IntValue UMBRAL_REDADA;
    public static final ModConfigSpec.IntValue MAX_POLIS_CERCA;

    public static final ModConfigSpec SPEC;

    static {
        BUILDER.comment("Configuracion del mod Moin. Cambia true/false para activar o desactivar sistemas.");

        BUILDER.push("sistemas");
        ADICCION = BUILDER
                .comment("Sistema de adiccion (engancharte y que te entre el mono).")
                .define("adiccion", true);
        SOBREDOSIS = BUILDER
                .comment("Sistema de sobredosis (toxicidad que puede matarte si abusas).")
                .define("sobredosis", true);
        POLICIA = BUILDER
                .comment("Que aparezcan polis si llevas mucha mercancia encima.")
                .define("policia", true);
        REDADAS = BUILDER
                .comment("Redadas (varios polis + capitan de golpe). Necesita 'policia' activado.")
                .define("redadas", true);
        TRAPICHEO = BUILDER
                .comment("Ofertas de compra/venta con aldeanos y vendedor ambulante (narcos).")
                .define("trapicheo", true);
        DISTORSION_PANTALLA = BUILDER
                .comment("Efecto visual de tintar la pantalla cuando vas colocado.")
                .define("distorsionPantalla", true);
        LAB_PRODUCE = BUILDER
                .comment("Que el laboratorio clandestino produzca polvo bruto solo con el tiempo.")
                .define("laboratorioProduce", true);
        BUILDER.pop();

        BUILDER.push("ajustes");
        UMBRAL_POLI = BUILDER
                .comment("Cantidad de mercancia a partir de la cual pueden aparecer polis.")
                .defineInRange("umbralPoli", 24, 1, 1000);
        UMBRAL_REDADA = BUILDER
                .comment("Cantidad de mercancia a partir de la cual puede saltar una redada.")
                .defineInRange("umbralRedada", 64, 1, 2000);
        MAX_POLIS_CERCA = BUILDER
                .comment("Maximo de polis que pueden estar cerca de ti a la vez.")
                .defineInRange("maxPolisCerca", 2, 1, 20);
        BUILDER.pop();

        SPEC = BUILDER.build();
    }
}
