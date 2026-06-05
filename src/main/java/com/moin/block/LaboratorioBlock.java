package com.moin.block;

import com.mojang.serialization.MapCodec;
import com.moin.block.entity.LaboratorioBlockEntity;
import com.moin.block.entity.ModBlockEntities;
import net.minecraft.core.BlockPos;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.BaseEntityBlock;
import net.minecraft.world.level.block.RenderShape;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.entity.BlockEntityTicker;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.phys.BlockHitResult;
import org.jetbrains.annotations.Nullable;

public class LaboratorioBlock extends BaseEntityBlock {
    public static final MapCodec<LaboratorioBlock> CODEC = simpleCodec(LaboratorioBlock::new);

    public LaboratorioBlock(Properties propiedades) {
        super(propiedades);
    }

    @Override
    protected MapCodec<? extends BaseEntityBlock> codec() {
        return CODEC;
    }

    @Override
    protected RenderShape getRenderShape(BlockState estado) {
        return RenderShape.MODEL;
    }

    @Nullable
    @Override
    public BlockEntity newBlockEntity(BlockPos pos, BlockState estado) {
        return new LaboratorioBlockEntity(pos, estado);
    }

    @Override
    protected InteractionResult useWithoutItem(BlockState estado, Level level, BlockPos pos, Player jugador, BlockHitResult hit) {
        if (!level.isClientSide) {
            BlockEntity be = level.getBlockEntity(pos);
            if (be instanceof LaboratorioBlockEntity lab) {
                lab.recoger(jugador);
            }
        }
        return InteractionResult.sidedSuccess(level.isClientSide);
    }

    @Override
    protected void onRemove(BlockState estado, Level level, BlockPos pos, BlockState nuevoEstado, boolean movido) {
        if (!estado.is(nuevoEstado.getBlock())) {
            BlockEntity be = level.getBlockEntity(pos);
            if (be instanceof LaboratorioBlockEntity lab) {
                lab.soltarContenido();
            }
        }
        super.onRemove(estado, level, pos, nuevoEstado, movido);
    }

    @Nullable
    @Override
    public <T extends BlockEntity> BlockEntityTicker<T> getTicker(Level level, BlockState estado, BlockEntityType<T> tipo) {
        if (level.isClientSide) {
            return null;
        }
        return createTickerHelper(tipo, ModBlockEntities.LABORATORIO.get(),
                (lvl, pos, st, be) -> be.serverTick(lvl, pos, st));
    }
}
