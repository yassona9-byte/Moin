package com.moin.block.entity;

import com.moin.item.ModItems;
import net.minecraft.core.BlockPos;
import net.minecraft.core.HolderLookup;
import net.minecraft.nbt.CompoundTag;
import net.minecraft.network.chat.Component;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.state.BlockState;

/**
 * Laboratorio clandestino: produce polvo bruto solo, poco a poco, hasta un tope.
 * Haz clic derecho para recoger lo acumulado.
 */
public class LaboratorioBlockEntity extends BlockEntity {

    private static final int PROGRESO_MAX = 200; // 10 s por unidad
    private static final int STOCK_MAX = 32;

    private int progreso = 0;
    private int stock = 0;

    public LaboratorioBlockEntity(BlockPos pos, BlockState estado) {
        super(ModBlockEntities.LABORATORIO.get(), pos, estado);
    }

    public void serverTick(Level level, BlockPos pos, BlockState estado) {
        if (stock >= STOCK_MAX) {
            return;
        }
        progreso++;
        if (progreso >= PROGRESO_MAX) {
            progreso = 0;
            stock++;
            setChanged(level, pos, estado);
        }
    }

    public void recoger(Player jugador) {
        if (level == null || level.isClientSide) {
            return;
        }
        if (stock <= 0) {
            jugador.displayClientMessage(Component.translatable("message.moin.lab_vacio"), true);
            return;
        }
        ItemStack producto = new ItemStack(ModItems.POLVO_BRUTO.get(), stock);
        jugador.getInventory().placeItemBackInInventory(producto);
        jugador.displayClientMessage(Component.translatable("message.moin.lab_recoger", stock), true);
        stock = 0;
        setChanged();
    }

    public void soltarContenido() {
        if (level != null && stock > 0) {
            Block.popResource(level, worldPosition, new ItemStack(ModItems.POLVO_BRUTO.get(), stock));
        }
    }

    @Override
    protected void saveAdditional(CompoundTag tag, HolderLookup.Provider registros) {
        super.saveAdditional(tag, registros);
        tag.putInt("Progreso", progreso);
        tag.putInt("Stock", stock);
    }

    @Override
    protected void loadAdditional(CompoundTag tag, HolderLookup.Provider registros) {
        super.loadAdditional(tag, registros);
        progreso = tag.getInt("Progreso");
        stock = tag.getInt("Stock");
    }
}
