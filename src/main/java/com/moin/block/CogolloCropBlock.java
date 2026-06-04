package com.moin.block;

import com.mojang.serialization.MapCodec;
import com.moin.item.ModItems;
import net.minecraft.world.level.ItemLike;
import net.minecraft.world.level.block.CropBlock;

/**
 * Cultivo ficticio que crece como el trigo (8 fases). Al cosecharlo da cogollos.
 */
public class CogolloCropBlock extends CropBlock {
    public static final MapCodec<CogolloCropBlock> CODEC = simpleCodec(CogolloCropBlock::new);

    public CogolloCropBlock(Properties propiedades) {
        super(propiedades);
    }

    @Override
    public MapCodec<? extends CropBlock> codec() {
        return CODEC;
    }

    @Override
    protected ItemLike getBaseSeedId() {
        return ModItems.SEMILLA_HIERBA.get();
    }
}
