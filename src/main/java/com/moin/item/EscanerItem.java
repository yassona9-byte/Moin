package com.moin.item;

import com.moin.util.Contrabando;
import net.minecraft.ChatFormatting;
import net.minecraft.network.chat.Component;
import net.minecraft.sounds.SoundEvents;
import net.minecraft.sounds.SoundSource;
import net.minecraft.world.InteractionHand;
import net.minecraft.world.InteractionResultHolder;
import net.minecraft.world.entity.player.Player;
import net.minecraft.world.item.Item;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.level.Level;
import net.minecraft.world.phys.AABB;

import java.util.List;

/**
 * Escaner antidroga: al usarlo, "escanea" tu inventario y el de los jugadores
 * cercanos y te dice cuanta mercancia detecta. Util para que la poli (u otros
 * jugadores) sepan quien lleva el material encima.
 */
public class EscanerItem extends Item {

    public EscanerItem(Properties propiedades) {
        super(propiedades);
    }

    @Override
    public InteractionResultHolder<ItemStack> use(Level level, Player jugador, InteractionHand mano) {
        ItemStack stack = jugador.getItemInHand(mano);

        if (!level.isClientSide) {
            int propio = Contrabando.contar(jugador);
            jugador.displayClientMessage(reporte("Tú", propio), false);

            AABB zona = jugador.getBoundingBox().inflate(12.0);
            List<Player> cercanos = level.getEntitiesOfClass(Player.class, zona, p -> p != jugador);
            for (Player otro : cercanos) {
                int n = Contrabando.contar(otro);
                if (n > 0) {
                    jugador.displayClientMessage(reporte(otro.getGameProfile().getName(), n), false);
                }
            }

            level.playSound(null, jugador.getX(), jugador.getY(), jugador.getZ(),
                    SoundEvents.NOTE_BLOCK_PLING.value(), SoundSource.PLAYERS, 0.6F, 2.0F);
            jugador.getCooldowns().addCooldown(this, 40);
        }
        return InteractionResultHolder.sidedSuccess(stack, level.isClientSide());
    }

    private static Component reporte(String quien, int cantidad) {
        ChatFormatting color = cantidad == 0 ? ChatFormatting.GREEN
                : cantidad < 16 ? ChatFormatting.YELLOW : ChatFormatting.RED;
        String estado = cantidad == 0 ? "limpio"
                : cantidad < 16 ? "lleva algo encima" : "¡VA CARGADO!";
        return Component.translatable("message.moin.escaner", quien, cantidad, estado).withStyle(color);
    }
}
