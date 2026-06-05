package com.moin.client;

import com.moin.Moin;
import com.moin.entity.ModEntities;
import com.moin.menu.ModMenuTypes;
import net.minecraft.client.model.HumanoidModel;
import net.minecraft.client.model.geom.ModelLayerLocation;
import net.minecraft.client.model.geom.builders.CubeDeformation;
import net.minecraft.client.model.geom.builders.LayerDefinition;
import net.minecraft.resources.ResourceLocation;
import net.neoforged.api.distmarker.Dist;
import net.neoforged.bus.api.SubscribeEvent;
import net.neoforged.fml.common.EventBusSubscriber;
import net.neoforged.neoforge.client.event.EntityRenderersEvent;
import net.neoforged.neoforge.client.event.RegisterGuiLayersEvent;
import net.neoforged.neoforge.client.event.RegisterMenuScreensEvent;

/**
 * Eventos del lado cliente: pantallas, capa visual de "ir colocado" y el
 * renderer/modelo de la entidad Poli.
 */
@EventBusSubscriber(modid = Moin.MODID, bus = EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ModClientEvents {

    public static final ModelLayerLocation POLI_LAYER =
            new ModelLayerLocation(ResourceLocation.fromNamespaceAndPath(Moin.MODID, "poli"), "main");

    @SubscribeEvent
    public static void registrarPantallas(RegisterMenuScreensEvent evento) {
        evento.register(ModMenuTypes.MESA_PROCESADO.get(), MesaProcesadoScreen::new);
    }

    @SubscribeEvent
    public static void registrarCapas(RegisterGuiLayersEvent evento) {
        evento.registerAboveAll(
                ResourceLocation.fromNamespaceAndPath(Moin.MODID, "colocado"),
                new ColocadoOverlay());
    }

    @SubscribeEvent
    public static void registrarRenderers(EntityRenderersEvent.RegisterRenderers evento) {
        evento.registerEntityRenderer(ModEntities.POLI.get(), PoliRenderer::new);
    }

    @SubscribeEvent
    public static void registrarCapasModelo(EntityRenderersEvent.RegisterLayerDefinitions evento) {
        evento.registerLayerDefinition(POLI_LAYER,
                () -> LayerDefinition.create(HumanoidModel.createMesh(new CubeDeformation(0.0F), 0.0F), 64, 64));
    }
}
