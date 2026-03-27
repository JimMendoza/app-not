# app-not

Frontend Flutter de NOT. Consume `api-not`, usa Riverpod + GoRouter + Dio y soporta Android con push FCM, inbox de notificaciones, badge interno y badge de icono cuando el launcher lo permite.

## Stack

- Flutter
- `flutter_riverpod`
- `go_router`
- `dio`
- `shared_preferences`
- `flutter_dotenv`
- `firebase_core`
- `firebase_messaging`
- `flutter_local_notifications`
- `app_badge_plus`

## Estructura del proyecto

```text
lib/
  config/              # router, theme, environment
  core/                # red, errores, session bus, push, storage
  features/
    auth/              # login, sesion, entidades, /me
    home/              # home, modulos, resolucion de rutas
    notificaciones/    # inbox, resumen, configuracion, modal, badge
    shared/            # shell principal, header, drawer, servicios comunes
    tramites/          # listado, seguir/no seguir, hoja-ruta
```

## Entornos

La app consume siempre `/.env`.

Archivos auxiliares incluidos:

- `/.env.emulator`: para emulador Android
- `/.env.device`: para celular fisico en LAN
- `/.env`: archivo activo

Valores esperados:

```env
# .env.emulator
API_URL='http://10.0.2.2:8000/api'

# .env.device
API_URL='http://172.16.2.121:8000/api'
```

Cambio manual sugerido en Windows PowerShell:

```powershell
Copy-Item .env.emulator .env -Force
Copy-Item .env.device .env -Force
```

Ademas de `API_URL`, `.env` define `APP_NAME`, `APP_LEMA` y `APP_COPYRIGHT`.

## Arranque local

```powershell
flutter pub get
flutter run
```

Comandos de validacion:

```powershell
flutter analyze
flutter test
```

## Flujo tecnico relevante

- `POST /app/login` autentica y devuelve token.
- `GET /app/me` es la fuente unica de verdad del usuario autenticado.
- `POST /app/logout` se trata como best effort; siempre se limpia sesion local.
- `GET /app/tramites/{id}/hoja-ruta` hoy puede responder `501`; la UI degrada de forma controlada.
- El home resuelve rutas de modulos con IDs canonicos (`tramites`, `mesa_partes`, `mesa_partes_virtual`, `notificaciones`) y deja un fallback acotado solo por nombre exacto para compatibilidad temporal.

## Push y badges

Push real Android requiere:

- `android/app/google-services.json`
- Firebase configurado para el proyecto
- permiso de notificaciones aprobado en Android
- sesion autenticada para registrar token en backend

Comportamiento actual:

- registra token en `PUT /app/dispositivos/push-token`
- invalida token en logout/sesion expirada cuando es viable
- maneja foreground, background, app cerrada y tap sobre notificacion
- resincroniza notificaciones, resumen y tramites al recibir/abrir push
- badge del icono depende del launcher/fabricante; no todos los launchers Android lo muestran

La preferencia `mostrar_contador_no_leidas` controla:

- badge de campana/header
- badge de pestaña `Notificaciones`
- badges visibles derivados en UI
- badge del icono de la app

## Smoke funcional minimo

1. Login con credenciales validas.
2. Verificar carga de `/app/me` y entrada a Home.
3. Verificar modulos del Home.
4. Entrar a `Tramites` y hacer `Seguir` / `No seguir`.
5. Abrir `Notificaciones`, abrir modal con icono ojo y validar marcado como leida.
6. Verificar resumen/badge de no leidas.
7. Entrar a configuracion de notificaciones y probar `mostrar_contador_no_leidas`.
8. Abrir hoja-ruta y validar manejo controlado si backend responde `501`.
9. En Android fisico, validar recepcion push y sincronizacion de badges.

## Testing actual

Cobertura automatizada agregada en `test/`:

- `test/auth/auth_notifier_test.dart`: login, restauracion de sesion, logout
- `test/home/module_route_resolver_test.dart`: resolucion canonica de modulos
- `test/navigation/app_router_shell_test.dart`: shell/tabs alineados
- `test/tramites/tramites_notifier_test.dart`: seguir/no seguir y badge por tramite
- `test/tramites/tramite_hoja_ruta_screen_test.dart`: degradacion controlada para `501`
- `test/notificaciones/notificaciones_provider_test.dart`: orden cronologico, resumen, marcar leida y preferencia de badge
- `test/widget_test.dart`: smoke minimo de pantalla de checking

## Troubleshooting rapido

### La app sigue con sesion o estado viejo

```powershell
adb shell pm clear com.gorecallao.app
```

### El celular no llega al backend

- Revisar que `API_URL` en `/.env` apunte a la IP LAN correcta.
- Confirmar que PC y celular esten en la misma red.
- Si cambiaste `.env`, reinstalar o reiniciar la app.

### No llega push

- Confirmar `google-services.json`.
- Confirmar permiso de notificaciones.
- Confirmar que backend tenga el `pushToken` registrado.
- Revisar conectividad del dispositivo con Firebase.

### No aparece badge en el icono

- Validar launcher del fabricante.
- En algunos launchers Android el badge no se soporta o se comporta distinto.
- El badge interno de la app si debe seguir sincronizado aunque el launcher no lo pinte.

### El test de navegacion falla por entorno

- `test/support/test_app.dart` inicializa un `.env` de pruebas en memoria.
- Si cambias lecturas de `Environment`, actualizar ese bootstrap de test.

## Decision explicita sobre contenido legal

El contenido de `Terminos y condiciones`, `Acerca de` y `Proteccion de datos` permanece hardcodeado en pantallas Flutter.

Decision actual:

- aceptado para el estado actual del frontend
- no bloquea operacion ni QA
- externalizacion a backend/CMS queda como deuda baja, solo si en el futuro se necesita versionado dinamico o administracion remota del contenido

## Notas de mantenimiento

- No usar `flutter_riverpod/legacy.dart`.
- El proyecto quedo unificado en providers basados en `NotifierProvider` y `NotifierProvider.autoDispose`.
- Si se agrega un modulo nuevo al Home, preferir ID canonico backend antes que heuristicas por nombre.

## Alcance de plataformas e identificadores

Estado actual de plataformas:

- Android: plataforma principal y la unica con push FCM real configurado.
- iOS: soporte Flutter base presente, pero sin Firebase/FCM configurado (`ios/Runner/GoogleService-Info.plist` no existe).
- Web: soporte parcial para pruebas y compilacion, sin push nativo configurado.
- Windows, macOS y Linux: soporte de compilacion/escritorio mantenido, sin alcance operativo principal para el MVP movil.

Decision explicita sobre identifiers nativos:

- Android `namespace` y `applicationId`: `com.gorecalloa.app`.
- iOS `PRODUCT_BUNDLE_IDENTIFIER`: `com.gorecalloa.app`.
- macOS `PRODUCT_BUNDLE_IDENTIFIER`: `com.gorecalloa.app`.
- Linux `APPLICATION_ID`: `com.gorecalloa.app`.
- Targets de pruebas nativos (`RunnerTests`): `com.gorecalloa.app.RunnerTests`.

Se mantienen asi por consistencia multiplataforma y compatibilidad con configuraciones ya operativas. No queda metadata legacy ambigua dentro del repo.

Decision explicita sobre Firebase:

- `android/app/google-services.json` conserva `project_id` y `storage_bucket` historicos (`not-gore-callao`) porque pertenecen al proyecto remoto de Firebase.
- Ese naming no afecta el runtime mientras el `package_name` configurado siga siendo `com.gorecalloa.app`.
- No debe editarse manualmente: cualquier cambio ahi debe venir regenerando el archivo desde Firebase Console.


