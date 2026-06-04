package com.moin.client;

import com.moin.menu.MesaProcesadoMenu;
import net.minecraft.client.gui.GuiGraphics;
import net.minecraft.client.gui.screens.inventory.AbstractContainerScreen;
import net.minecraft.network.chat.Component;
import net.minecraft.world.entity.player.Inventory;

/**
 * Pantalla de la mesa de procesado. Se dibuja con rectangulos de color
 * (sin texturas externas) para que funcione sin necesidad de archivos PNG.
 */
public class MesaProcesadoScreen extends AbstractContainerScreen<MesaProcesadoMenu> {

    public MesaProcesadoScreen(MesaProcesadoMenu menu, Inventory inv, Component titulo) {
        super(menu, inv, titulo);
        this.imageWidth = 176;
        this.imageHeight = 166;
    }

    @Override
    protected void init() {
        super.init();
        this.titleLabelX = (this.imageWidth - this.font.width(this.title)) / 2;
        this.inventoryLabelY = this.imageHeight - 94;
    }

    @Override
    protected void renderBg(GuiGraphics g, float partialTick, int mouseX, int mouseY) {
        int x = this.leftPos;
        int y = this.topPos;

        // Panel exterior e interior.
        g.fill(x, y, x + imageWidth, y + imageHeight, 0xFFC6C6C6);
        g.fill(x + 4, y + 4, x + imageWidth - 4, y + imageHeight - 4, 0xFF8B8B8B);

        // Recuadros de las ranuras de entrada y salida.
        dibujarRanura(g, x + 56, y + 35);
        dibujarRanura(g, x + 116, y + 35);

        // Recuadros del inventario del jugador.
        for (int fila = 0; fila < 3; fila++) {
            for (int columna = 0; columna < 9; columna++) {
                dibujarRanura(g, x + 8 + columna * 18, y + 84 + fila * 18);
            }
        }
        for (int columna = 0; columna < 9; columna++) {
            dibujarRanura(g, x + 8 + columna * 18, y + 142);
        }

        // Flecha de progreso.
        int flechaX = x + 80;
        int flechaY = y + 39;
        g.fill(flechaX, flechaY, flechaX + 22, flechaY + 4, 0xFF555555);
        int progreso = this.menu.getProgresoEscalado();
        if (progreso > 0) {
            g.fill(flechaX, flechaY, flechaX + progreso, flechaY + 4, 0xFF44CC44);
        }
    }

    private void dibujarRanura(GuiGraphics g, int x, int y) {
        g.fill(x - 1, y - 1, x + 17, y + 17, 0xFF373737);
        g.fill(x, y, x + 16, y + 16, 0xFF8B8B8B);
    }

    @Override
    public void render(GuiGraphics g, int mouseX, int mouseY, float partialTick) {
        super.render(g, mouseX, mouseY, partialTick);
        this.renderTooltip(g, mouseX, mouseY);
    }
}
