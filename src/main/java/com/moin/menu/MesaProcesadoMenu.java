package com.moin.menu;

import com.moin.block.ModBlocks;
import com.moin.block.entity.MesaProcesadoBlockEntity;
import net.minecraft.network.RegistryFriendlyByteBuf;
import net.minecraft.world.entity.player.Inventory;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.inventory.AbstractContainerMenu;
import net.minecraft.world.inventory.ContainerData;
import net.minecraft.world.inventory.SimpleContainerData;
import net.minecraft.world.inventory.Slot;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.neoforged.neoforge.items.IItemHandler;
import net.neoforged.neoforge.items.SlotItemHandler;

public class MesaProcesadoMenu extends AbstractContainerMenu {

    public final MesaProcesadoBlockEntity blockEntity;
    private final Level level;
    private final ContainerData datos;

    private static final int RANURAS_CONTENEDOR = 2;

    // Constructor del lado cliente (lee la posicion del buffer).
    public MesaProcesadoMenu(int id, Inventory inv, RegistryFriendlyByteBuf buf) {
        this(id, inv, (MesaProcesadoBlockEntity) inv.player.level().getBlockEntity(buf.readBlockPos()), new SimpleContainerData(2));
    }

    // Constructor del lado servidor.
    public MesaProcesadoMenu(int id, Inventory inv, MesaProcesadoBlockEntity be, ContainerData datos) {
        super(ModMenuTypes.MESA_PROCESADO.get(), id);
        this.blockEntity = be;
        this.level = inv.player.level();
        this.datos = datos;

        IItemHandler handler = be.getInventario();
        // Ranura de entrada.
        this.addSlot(new SlotItemHandler(handler, MesaProcesadoBlockEntity.RANURA_ENTRADA, 56, 35));
        // Ranura de salida (no se puede insertar manualmente).
        this.addSlot(new SlotItemHandler(handler, MesaProcesadoBlockEntity.RANURA_SALIDA, 116, 35) {
            @Override
            public boolean mayPlace(ItemStack stack) {
                return false;
            }
        });

        agregarInventarioJugador(inv);
        agregarHotbar(inv);
        addDataSlots(datos);
    }

    public int getProgresoEscalado() {
        int progreso = datos.get(0);
        int maximo = datos.get(1);
        int anchoFlecha = 22;
        return (maximo != 0 && progreso != 0) ? progreso * anchoFlecha / maximo : 0;
    }

    @Override
    public ItemStack quickMoveStack(Player jugador, int indice) {
        ItemStack copia = ItemStack.EMPTY;
        Slot ranura = this.slots.get(indice);
        if (ranura != null && ranura.hasItem()) {
            ItemStack stack = ranura.getItem();
            copia = stack.copy();

            if (indice < RANURAS_CONTENEDOR) {
                // De la mesa hacia el inventario del jugador.
                if (!this.moveItemStackTo(stack, RANURAS_CONTENEDOR, this.slots.size(), true)) {
                    return ItemStack.EMPTY;
                }
            } else {
                // Del jugador hacia la ranura de entrada de la mesa.
                if (!this.moveItemStackTo(stack, MesaProcesadoBlockEntity.RANURA_ENTRADA,
                        MesaProcesadoBlockEntity.RANURA_ENTRADA + 1, false)) {
                    return ItemStack.EMPTY;
                }
            }

            if (stack.isEmpty()) {
                ranura.set(ItemStack.EMPTY);
            } else {
                ranura.setChanged();
            }
        }
        return copia;
    }

    @Override
    public boolean stillValid(Player jugador) {
        return blockEntity != null && !blockEntity.isRemoved()
                && jugador.distanceToSqr(blockEntity.getBlockPos().getCenter()) <= 64.0
                && level.getBlockState(blockEntity.getBlockPos()).is(ModBlocks.MESA_PROCESADO.get());
    }

    private void agregarInventarioJugador(Inventory inv) {
        for (int fila = 0; fila < 3; fila++) {
            for (int columna = 0; columna < 9; columna++) {
                this.addSlot(new Slot(inv, columna + fila * 9 + 9, 8 + columna * 18, 84 + fila * 18));
            }
        }
    }

    private void agregarHotbar(Inventory inv) {
        for (int columna = 0; columna < 9; columna++) {
            this.addSlot(new Slot(inv, columna, 8 + columna * 18, 142));
        }
    }
}
