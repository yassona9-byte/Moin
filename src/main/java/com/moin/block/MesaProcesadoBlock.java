package com.moin.block;

import com.mojang.serialization.MapCodec;
import com.moin.block.entity.MesaProcesadoBlockEntity;
import com.moin.block.entity.ModBlockEntities;
import net.minecraft.core.BlockPos;
import net.minecraft.core.Direction;
import net.minecraft.world.InteractionResult;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.level.Level;
import net.minecraft.world.level.block.BaseEntityBlock;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.RenderShape;
import net.minecraft.world.level.block.entity.BlockEntity;
import net.minecraft.world.level.block.entity.BlockEntityTicker;
import net.minecraft.world.level.block.entity.BlockEntityType;
import net.minecraft.world.level.block.state.BlockState;
import net.minecraft.world.level.block.state.StateDefinition;
import net.minecraft.world.level.block.state.properties.BlockStateProperties;
import net.minecraft.world.level.block.state.properties.DirectionProperty;
import net.minecraft.world.phys.BlockHitResult;
import net.minecraft.world.item.context.BlockPlaceContext;
import org.jetbrains.annotations.Nullable;

/**
 * Mesa de procesado: bloque con interfaz que transforma ingredientes ficticios
 * en productos con el paso del tiempo (estilo horno, pero sin combustible).
 */
public class MesaProcesadoBlock extends BaseEntityBlock {
    public static final MapCodec<MesaProcesadoBlock> CODEC = simpleCodec(MesaProcesadoBlock::new);
    public static final DirectionProperty FACING = BlockStateProperties.HORIZONTAL_FACING;

    public MesaProcesadoBlock(Properties propiedades) {
        super(propiedades);
        this.registerDefaultState(this.stateDefinition.any().setValue(FACING, Direction.NORTH));
    }

    @Override
    protected MapCodec<? extends BaseEntityBlock> codec() {
        return CODEC;
    }

    @Override
    protected RenderShape getRenderShape(BlockState estado) {
        return RenderShape.MODEL;
    }

    @Override
    protected void createBlockStateDefinition(StateDefinition.Builder<Block, BlockState> builder) {
        builder.add(FACING);
    }

    @Override
    public BlockState getStateForPlacement(BlockPlaceContext contexto) {
        return this.defaultBlockState().setValue(FACING, contexto.getHorizontalDirection().getOpposite());
    }

    @Nullable
    @Override
    public BlockEntity newBlockEntity(BlockPos pos, BlockState estado) {
        return new MesaProcesadoBlockEntity(pos, estado);
    }

    @Override
    protected InteractionResult useWithoutItem(BlockState estado, Level level, BlockPos pos, Player jugador, BlockHitResult hit) {
        if (!level.isClientSide) {
            BlockEntity be = level.getBlockEntity(pos);
            if (be instanceof MesaProcesadoBlockEntity mesa) {
                jugador.openMenu(mesa, pos);
            }
        }
        return InteractionResult.sidedSuccess(level.isClientSide);
    }

    @Override
    protected void onRemove(BlockState estado, Level level, BlockPos pos, BlockState nuevoEstado, boolean movido) {
        if (!estado.is(nuevoEstado.getBlock())) {
            BlockEntity be = level.getBlockEntity(pos);
            if (be instanceof MesaProcesadoBlockEntity mesa) {
                mesa.soltarContenido();
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
        return createTickerHelper(tipo, ModBlockEntities.MESA_PROCESADO.get(),
                (lvl, pos, st, be) -> be.serverTick(lvl, pos, st));
    }
}
