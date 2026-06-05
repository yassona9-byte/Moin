package com.moin.client;

import com.moin.effect.ModEffects;
import net.minecraft.client.DeltaTracker;
import net.minecraft.client.Minecraft;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.LayeredDraw;
import net.minecraft.client.player.LocalPlayer;

/**
 * Capa de pantalla que tine la vista del jugador segun el efecto que tenga,
 * para simular el "ir colocado". Se dibuja por encima de todo el HUD.
 */
public class ColocadoOverlay implements LayeredDraw.Layer {

    @Override
    public void render(GuiGraphics g, DeltaTracker delta) {
        if (!com.moin.Config.DISTORSION_PANTALLA.get()) {
            return;
        }
        Minecraft mc = Minecraft.getInstance();
        LocalPlayer p = mc.player;
        if (p == null || mc.options.hideGui) {
            return;
        }

        int w = g.guiWidth();
        int h = g.guiHeight();
        long t = System.currentTimeMillis();

        if (p.hasEffect(ModEffects.VIAJE)) {
            // Psicodelico: el color va cambiando y late.
            int alpha = 55 + (int) (35 * Math.sin(t / 280.0));
            float hue = (t % 4000) / 4000.0F;
            int rgb = java.awt.Color.HSBtoRGB(hue, 0.65F, 0.95F) & 0xFFFFFF;
            g.fill(0, 0, w, h, (clamp(alpha) << 24) | rgb);
        } else if (p.hasEffect(ModEffects.SUBIDON)) {
            int alpha = 35 + (int) (15 * Math.sin(t / 200.0));
            g.fill(0, 0, w, h, (clamp(alpha) << 24) | 0xFFE066); // amarillo energico
        } else if (p.hasEffect(ModEffects.COLOCON)) {
            g.fill(0, 0, w, h, (45 << 24) | 0x66AA44);          // verde relajado
        } else if (p.hasEffect(ModEffects.BORRACHERA)) {
            int alpha = 40 + (int) (20 * Math.sin(t / 400.0));
            g.fill(0, 0, w, h, (clamp(alpha) << 24) | 0xCC9933); // ambar de borrachera
        } else if (p.hasEffect(ModEffects.EUFORIA)) {
            g.fill(0, 0, w, h, (40 << 24) | 0xFF80D0);          // rosa eufórico
        }
    }

    private static int clamp(int a) {
        return Math.max(0, Math.min(255, a));
    }
}
