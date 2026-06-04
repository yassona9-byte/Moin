package com.moin.block.entity;

import com.moin.item.ModItems;
import com.moin.menu.MesaProcesadoMenu;
import net.minecraft.core.BlockPos;
import net.minecraft.core.HolderLookup;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.network.chat.Component;
import net.minecraft.world.MenuProvider;
import net.minecraft.world.entity.player.Inventory;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.inventory.AbstractContainerMenu;
import net.minecraft.world.inventory.ContainerData;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.state.BlockState;
import net.neoforged.neoforge.items.ItemStackHandler;
import org.jetbrains.annotations.Nullable;

/**
 * Logica de la mesa de procesado. Tiene 2 ranuras (entrada y salida) y procesa
 * un ingrediente en otro tras cierto tiempo. Las recetas estan definidas en
 * codigo en {@link #resultadoPara(ItemStack)}.
 */
public class MesaProcesadoBlockEntity extends BlockEntity implements MenuProvider {

    public static final int RANURA_ENTRADA = 0;
    public static final int RANURA_SALIDA = 1;

    private final ItemStackHandler inventario = new ItemStackHandler(2) {
        @Override
        protected void onContentsChanged(int ranura) {
            setChanged();
        }

        @Override
        public boolean isItemValid(int ranura, ItemStack stack) {
            // No se puede insertar manualmente en la ranura de salida.
            return ranura != RANURA_SALIDA;
        }
    };

    private int progreso = 0;
    private int progresoMaximo = 200;

    private final ContainerData datos = new ContainerData() {
        @Override
        public int get(int indice) {
            return indice == 0 ? progreso : progresoMaximo;
        }

        @Override
        public void set(int indice, int valor) {
            if (indice == 0) {
                progreso = valor;
            } else {
                progresoMaximo = valor;
            }
        }

        @Override
        public int getCount() {
            return 2;
        }
    };

    public MesaProcesadoBlockEntity(BlockPos pos, BlockState estado) {
        super(ModBlockEntities.MESA_PROCESADO.get(), pos, estado);
    }

    public ItemStackHandler getInventario() {
        return inventario;
    }

    public ContainerData getDatos() {
        return datos;
    }

    public void soltarContenido() {
        if (level == null) {
            return;
        }
        for (int i = 0; i < inventario.getSlots(); i++) {
            Block.popResource(level, worldPosition, inventario.getStackInSlot(i));
        }
    }

    public void serverTick(Level level, BlockPos pos, BlockState estado) {
        ItemStack entrada = inventario.getStackInSlot(RANURA_ENTRADA);
        ItemStack resultado = resultadoPara(entrada);

        if (!resultado.isEmpty() && puedeColocarSalida(resultado)) {
            progreso++;
            if (progreso >= progresoMaximo) {
                inventario.extractItem(RANURA_ENTRADA, 1, false);
                inventario.insertItem(RANURA_SALIDA, resultado.copy(), false);
                progreso = 0;
            }
            setChanged(level, pos, estado);
        } else if (progreso != 0) {
            progreso = 0;
            setChanged(level, pos, estado);
        }
    }

    private boolean puedeColocarSalida(ItemStack resultado) {
        ItemStack salida = inventario.getStackInSlot(RANURA_SALIDA);
        if (salida.isEmpty()) {
            return true;
        }
        if (!ItemStack.isSameItemSameComponents(salida, resultado)) {
            return false;
        }
        return salida.getCount() + resultado.getCount() <= salida.getMaxStackSize();
    }

    /** Recetas de la mesa (ingrediente -> producto ficticio). */
    private ItemStack resultadoPara(ItemStack entrada) {
        if (entrada.isEmpty()) {
            return ItemStack.EMPTY;
        }
        if (entrada.is(ModItems.COGOLLO.get())) {
            return new ItemStack(ModItems.PORRO.get());
        }
        if (entrada.is(ModItems.HOJA_COCA.get())) {
            return new ItemStack(ModItems.POLVO_BRUTO.get());
        }
        if (entrada.is(ModItems.POLVO_BRUTO.get())) {
            return new ItemStack(ModItems.POLVO_BLANCO.get());
        }
        if (entrada.is(ModItems.POLVO_BLANCO.get())) {
            return new ItemStack(ModItems.PASTILLA.get());
        }
        return ItemStack.EMPTY;
    }

    @Override
    protected void saveAdditional(CompoundTag tag, HolderLookup.Provider registros) {
        super.saveAdditional(tag, registros);
        tag.put("Inventario", inventario.serializeNBT(registros));
        tag.putInt("Progreso", progreso);
        tag.putInt("ProgresoMaximo", progresoMaximo);
    }

    @Override
    protected void loadAdditional(CompoundTag tag, HolderLookup.Provider registros) {
        super.loadAdditional(tag, registros);
        inventario.deserializeNBT(registros, tag.getCompound("Inventario"));
        progreso = tag.getInt("Progreso");
        progresoMaximo = tag.contains("ProgresoMaximo") ? tag.getInt("ProgresoMaximo") : 200;
    }

    @Override
    public Component getDisplayName() {
        return Component.translatable("block.moin.mesa_procesado");
    }

    @Nullable
    @Override
    public AbstractContainerMenu createMenu(int id, Inventory inventarioJugador, Player jugador) {
        return new MesaProcesadoMenu(id, inventarioJugador, this, datos);
    }
}
