package com.moin.block;

import com.mojang.serialization.MapCodec;
import com.moin.item.ModItems;
import net.minecraft.world.level.ItemLike;
import net.minecraft.world.level.block.CropBlock;

/**
 * Segunda planta ficticia. Crece como un cultivo y al cosecharla da hojas de coca,
 * que luego se procesan en la mesa para obtener polvo bruto.
 */
public class CocaCropBlock extends CropBlock {
    public static final MapCodec<CocaCropBlock> CODEC = simpleCodec(CocaCropBlock::new);

    public CocaCropBlock(Properties propiedades) {
        super(propiedades);
    }

    @Override
    public MapCodec<? extends CropBlock> codec() {
        return CODEC;
    }

    @Override
    protected ItemLike getBaseSeedId() {
        return ModItems.SEMILLA_COCA.get();
    }
}
