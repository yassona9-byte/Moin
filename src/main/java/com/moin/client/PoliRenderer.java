package com.moin.client;

import com.moin.Moin;
import com.moin.entity.PoliEntity;
import net.minecraft.client.model.HumanoidModel;
import net.minecraft.client.renderer.entity.EntityRendererProvider;
import net.minecraft.client.renderer.entity.HumanoidMobRenderer;
import net.minecraft.resources.ResourceLocation;

/**
 * Renderer del Poli: usa el modelo humanoide estandar con nuestra skin propia.
 */
public class PoliRenderer extends HumanoidMobRenderer<PoliEntity, HumanoidModel<PoliEntity>> {

    private static final ResourceLocation TEXTURA =
            ResourceLocation.fromNamespaceAndPath(Moin.MODID, "textures/entity/poli.png");

    public PoliRenderer(EntityRendererProvider.Context contexto) {
        super(contexto, new HumanoidModel<>(contexto.bakeLayer(ModClientEvents.POLI_LAYER)), 0.5F);
    }

    @Override
    public ResourceLocation getTextureLocation(PoliEntity entidad) {
        return TEXTURA;
    }
}
