# ⚽ Moin Soccer — app nativa de fútbol (Android / iOS)

Juego de fútbol arcade estilo *Dream League Soccer* hecho como **app nativa** con
**Flutter** (no es una web). Genera un **APK instalable** en Android. El mismo
código compila también para iPhone.

## Cómo conseguir el APK (sin instalar nada en tu PC)

El repositorio compila la app en la nube con GitHub Actions:

1. Ve a la pestaña **Actions** del repositorio en GitHub.
2. Abre el workflow **"Build Android APK (Moin Soccer)"**. Se ejecuta solo en
   cada push; o pulsa **Run workflow** para lanzarlo a mano.
3. Cuando termine (en verde), entra en esa ejecución y descarga el artefacto
   **`moin-soccer-apk`** (un `.zip` que contiene `app-release.apk`).
4. Pasa el `app-release.apk` a tu móvil Android e instálalo (tendrás que
   permitir **"instalar apps de fuentes desconocidas"**).

## iPhone (iOS)

Hay un workflow **"Build iOS (Moin Soccer)"** (manual) que compila la app para
iOS, pero **para instalarla en un iPhone real necesitas un Mac y una cuenta de
desarrollador de Apple** para firmarla. El artefacto que genera es sin firma y
solo sirve para verificar que compila.

## Cómo se juega

- **Joystick** (lado izquierdo): mover al jugador.
- **TIRO** (rojo): dispara; mantén pulsado para más potencia. La dirección es la
  del joystick (o hacia la portería si no mueves).
- **PASE** (azul): pasa al mejor compañero; sin balón, presiona hacia la pelota.
- **CORRER** (amarillo): esprint.
- Controlas al jugador de tu equipo más cercano al balón (cambia solo).

Partidos 5 vs 5 con portero e IA, marcador, reloj con dos mitades, elección de
equipo/rival, dificultad y duración, celebración de gol y revancha.

## Compilar tú mismo (opcional, con Android Studio)

```bash
cd app
flutter create --org com.moin --project-name moin_soccer --platforms=android .
flutter pub get
flutter build apk --release
# APK en build/app/outputs/flutter-apk/app-release.apk
```
