# Manual de Usuario - App NOT

## 1. Objetivo

Este manual explica el uso diario de la aplicacion movil `NOT` para usuarios finales:

- iniciar sesion,
- revisar tramites,
- gestionar notificaciones,
- ajustar preferencias,
- cerrar sesion de forma segura.

## 2. Alcance

Este manual aplica a la app Flutter `app-not` conectada al backend `api-not`, segun el estado canonicamente documentado en:

- `C:\laragon\www\app-not\api-not\docs\architecture\backend-final-handover.md`
- `C:\laragon\www\app-not\app-not\docs\architecture\frontend-final-handover.md`

Unica deuda funcional aceptada: `hoja-ruta` puede no estar disponible y mostrar respuesta controlada.

## 3. Requisitos para usar la app

1. Tener instalada la app `NOT` en Android.
2. Contar con credenciales validas:
   - codigo de usuario,
   - contrasena,
   - entidad/empresa.
3. Tener conexion a internet.
4. Permitir notificaciones del sistema si desea recibir push en tiempo real.

## 4. Ingreso a la aplicacion

1. Abra la app `NOT`.
2. En la pantalla de acceso:
   - seleccione su entidad,
   - ingrese su usuario,
   - ingrese su contrasena.
3. Pulse `Ingresar`.
4. Si es su primera vez o aun no acepto la politica, revise la pantalla de proteccion de datos y pulse `Acepto`.

## 5. Navegacion principal

La app tiene tres secciones principales en la barra inferior:

- `Inicio`
- `Tramites`
- `Notificaciones`

Desde el menu lateral tambien puede acceder a:

- `Mis datos`
- `Tema`
- `Configuracion de notificaciones`
- `Salir`

## 6. Uso de Tramites

En `Tramites` puede:

1. Ver la lista de tramites disponibles.
2. Pulsar `Seguir` para activar seguimiento de un tramite.
3. Pulsar `No seguir` para desactivar seguimiento.
4. Pulsar `Hoja de ruta` para intentar ver movimientos del tramite.

Nota importante:

- si la hoja de ruta aun no esta implementada para el tramite, la app mostrara un mensaje controlado de no disponibilidad (comportamiento esperado).

## 7. Uso de Notificaciones

En `Notificaciones` puede:

1. Ver la bandeja de notificaciones.
2. Identificar si una notificacion esta `Leida` o `No leida`.
3. Abrir el detalle de una notificacion.
4. Marcar una notificacion como leida desde el flujo de detalle cuando corresponda.

El contador de no leidas puede verse en:

- la seccion de notificaciones,
- la cabecera,
- la barra inferior,
- el icono de la app (segun soporte del launcher Android).

## 8. Configuracion de notificaciones

En `Configuracion de notificaciones` puede ajustar:

1. `Silenciar fuera de horario`.
2. `Hora de inicio` y `hora de fin` del silencio.
3. `Mostrar contador de no leidas`.

Despues de cambiar valores, pulse `Guardar cambios`.

## 9. Notificaciones push

Para recibir push:

1. Mantenga sesion iniciada.
2. Acepte permisos de notificaciones del sistema.
3. Mantenga conexion a internet.

Al tocar una notificacion push, la app abre la seccion de `Notificaciones` y, si aplica, intenta abrir el detalle relacionado.

## 10. Tema visual

En `Tema` puede seleccionar:

- claro,
- oscuro,
- segun sistema.

## 11. Cierre de sesion

1. Abra el menu lateral.
2. Pulse `Salir`.
3. Confirme la accion cuando corresponda.

## 12. Problemas frecuentes

### 12.1 No puedo iniciar sesion

- Verifique usuario, contrasena y entidad.
- Revise conectividad de internet.

### 12.2 No me llegan notificaciones push

- Revise permisos de notificaciones en Android.
- Verifique conexion de internet.
- Vuelva a iniciar sesion para resincronizar el dispositivo.

### 12.3 No veo contador en el icono de la app

- Algunos launchers Android no soportan badge en icono.
- Revise tambien el contador interno dentro de la app.

### 12.4 Hoja de ruta no muestra movimientos

- Actualmente puede mostrarse no disponible por deuda funcional aceptada (`hoja-ruta`).
- No es una caida de la app; es comportamiento esperado en el estado actual.

## 13. Buenas practicas de uso

1. Cierre sesion al terminar en dispositivos compartidos.
2. Mantenga la app actualizada.
3. Revise `Notificaciones` con frecuencia para mantener trazabilidad de tramites.
4. Configure horario de silencio para evitar alertas fuera de jornada.

