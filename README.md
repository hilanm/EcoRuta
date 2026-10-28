# EcoRuta ♻️

**Recicla hoy, transforma el mañana.**

EcoRuta es una aplicación móvil hecha con Flutter para fomentar el reciclaje comunitario en la comuna de **Ñuñoa, Santiago de Chile**. Permite encontrar puntos de reciclaje en un mapa, registrar actividades de reciclaje, mantener una racha de días consecutivos y seguir el progreso personal.

Proyecto asociado al **Objetivo de Desarrollo Sostenible 12: Producción y consumo responsables**.

> Estado: versión 0.1.0, desarrollo inicial. Plataforma principal: Android. También se puede ejecutar en Windows para desarrollo.

## Funcionalidades

- **Inicio:** saludo con tu alias, racha actual y récord, kg reciclados, número de actividades, progreso semanal, próximo logro y última actividad.
- **Mapa:** mapa de Ñuñoa con OpenStreetMap, marcadores, ficha de cada punto, búsqueda por nombre, dirección o material, filtros por categoría, tu ubicación (opcional), distancia aproximada y botón "Cómo llegar".
- **Reciclar:** formulario con material, cantidad en kg, fecha (también retroactiva) y descripción, con validación. Incluye **historial** filtrable por categoría y rango de fechas.
- **Racha:** calendario mensual, resumen semanal, rachas anteriores, récord, progreso hacia el siguiente logro y lista de **8 logros**.
- **Perfil:** alias editable, estadísticas, logros obtenidos, una preferencia y restablecimiento de datos locales con confirmación.

### Cómo funciona la racha

- Se calcula siempre a partir de las **fechas locales** de las actividades guardadas, sin conversiones a UTC.
- Varias actividades el mismo día cuentan como un solo día.
- La racha sigue viva si hubo actividad hoy o ayer; si pasa un día completo sin actividad, se interrumpe. El récord conserva la mayor racha histórica.
- Las actividades retroactivas cuentan en la fecha elegida, y las fechas futuras se ignoran.

### Importante sobre los registros

Las actividades son **declaradas por el usuario**. La app no las verifica ni las certifica, y no ofrece recompensas monetarias.

## Datos del mapa

Los puntos se cargan desde `assets/data/recycling_points.json`. Esta primera versión incluye:

- Dos campanas de residuos electrónicos con **dirección de fuente oficial** de la Municipalidad de Ñuñoa (Plaza Ñuñoa y Parque Botánico). Según la Municipalidad, ambas estaban temporalmente fuera de servicio por vandalismo; confirma antes de ir.
- Un **punto de demostración**, claramente marcado como ficticio.

Los puntos oficiales todavía **no tienen coordenadas verificadas**, por eso aparecen en la lista "sin ubicación en el mapa" y no como marcador. No se inventan coordenadas.

### Agregar puntos

Edita el JSON sin tocar la interfaz. Cada punto usa estos campos:

```json
{
  "id": "identificador-unico",
  "name": "Nombre",
  "address": "Dirección",
  "latitude": -33.0000,
  "longitude": -70.0000,
  "coordinatesVerified": true,
  "materials": ["glass", "plastic"],
  "schedule": "Horario verificado o null",
  "description": "Descripción",
  "phone": null,
  "website": null,
  "source": "Fuente de los datos",
  "lastVerified": "AAAA-MM-DD",
  "verification": "verified",
  "statusNote": null
}
```

Materiales válidos: `plastic`, `glass`, `paper`, `metal`, `electronic`, `batteries`, `oil`, `textile`. Usa `"verification": "demo"` para datos de ejemplo. Un registro mal formado se descarta sin romper el mapa. Para obtener coordenadas reales: clic derecho sobre el lugar en Google Maps u OpenStreetMap y copia latitud y longitud.

## Requisitos

- [Flutter](https://docs.flutter.dev/get-started/install) estable (incluye Dart).
- Para Android: Android Studio con el SDK de Android y un teléfono o emulador (`flutter doctor --android-licenses`).
- Para Windows: Visual Studio 2022 o posterior con la carga **Desarrollo para el escritorio con C++**, y el **Modo de desarrollador** de Windows activado (`start ms-settings:developers`).

## Instalación y ejecución

```bash
git clone https://github.com/TU_USUARIO/ecoruta.git
cd ecoruta

# Solo la primera vez, si faltan las carpetas de plataforma (android/, windows/):
flutter create . --project-name ecoruta --platforms android,windows

flutter pub get
flutter run                 # elige el dispositivo disponible
flutter run -d windows      # vista previa en Windows
```

Si `flutter pub get` reporta conflictos de versiones, prueba `flutter pub upgrade --major-versions`.

## Pruebas

```bash
flutter analyze
flutter test
```

Las pruebas cubren: cálculo de rachas (incluidos cambios de día, fin de año y horario de verano), estadísticas, validación de actividades, logros sin duplicados, calendario, filtros del mapa y del historial, y pruebas de widgets de la navegación, la pestaña Racha y el perfil.

## Compilar el APK de Android

```bash
flutter build apk --release
```

El archivo queda en `build/app/outputs/flutter-apk/app-release.apk`. Por defecto usa la firma de depuración, suficiente para pruebas y demostraciones. Para publicar en una tienda hay que configurar una firma propia (ver la [documentación de Flutter](https://docs.flutter.dev/deployment/android)).

## Permisos de Android

Agrégalos dentro de `<manifest>` en `android/app/src/main/AndroidManifest.xml`:

| Permiso | Para qué |
|---|---|
| `INTERNET` | Descargar las teselas del mapa. |
| `ACCESS_FINE_LOCATION` / `ACCESS_COARSE_LOCATION` | Mostrar tu posición y calcular distancias. |

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

La ubicación se pide solo cuando pulsas el botón de "mi ubicación", con una explicación previa. Si la rechazas, el mapa sigue funcionando. La ubicación no se guarda ni se envía a ningún servidor.

## Arquitectura

```
lib/
  main.dart, app.dart
  core/        tema, widgets comunes, utilidades de fechas, providers
  data/        modelos, base de datos SQLite, repositorios
  features/
    home/ map/ recycling/ streak/ profile/ achievements/
assets/data/   puntos de reciclaje (JSON)
test/          pruebas unitarias y de widgets
```

- **Estado:** Riverpod. **Persistencia:** SQLite con `sqflite` (en escritorio, `sqflite_common_ffi`) y `shared_preferences` solo para una preferencia.
- Las estadísticas, la racha y los logros se **derivan de las actividades guardadas**; no se guardan indicadores sueltos.
- La app funciona sin cuenta y sin servidor. Los repositorios están separados de la interfaz para poder agregar sincronización más adelante.

## Dependencias principales

| Paquete | Uso |
|---|---|
| `flutter_riverpod` | Gestión de estado |
| `sqflite`, `sqflite_common_ffi`, `sqlite3_flutter_libs`, `path` | Base de datos local (móvil y escritorio) |
| `shared_preferences` | Preferencias sencillas |
| `flutter_map`, `latlong2` | Mapa y coordenadas |
| `geolocator` | Ubicación del usuario |
| `url_launcher` | Abrir indicaciones y enlaces externos |
| `intl`, `flutter_localizations` | Fechas y textos en español |

## Servicios externos y atribución

- **Mapa:** © colaboradores de [OpenStreetMap](https://www.openstreetmap.org/copyright), mostrado en la app. Se usan las teselas públicas de OpenStreetMap con identificación de la app; respeta su [política de uso](https://operations.osmfoundation.org/policies/tiles/) y no hagas descargas masivas. El mapa requiere conexión.
- **Puntos de reciclaje:** Municipalidad de Ñuñoa ([nunoa.cl](https://www.nunoa.cl)).
- **Indicaciones:** se abren en Google Maps mediante un enlace externo.

## Pendiente

- Coordenadas verificadas y más puntos reales de Ñuñoa.
- Fotografía opcional en las actividades y asociar una actividad a un punto del mapa.
- Sincronización opcional con un servidor.

## Licencia

[MIT](LICENSE).
