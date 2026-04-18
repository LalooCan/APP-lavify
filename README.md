# Lavify

Lavify es una app Flutter para solicitar lavado de autos a domicilio. El proyecto contempla dos roles principales:

- Cliente: solicita paquetes, confirma ubicacion, revisa estado del pedido y consulta historial.
- Lavador: acepta servicios, cambia disponibilidad, avanza estados operativos y comparte tracking.

La app ya integra Firebase y Firestore, y su arquitectura permite alternar entre datos mock y backend remoto con una sola configuracion.

## Stack

- Flutter
- Firebase Core
- Firebase Auth
- Cloud Firestore
- Google Sign-In
- Google Maps Flutter

## Arquitectura

La app esta organizada por capas ligeras:

- `lib/models`
  Define entidades de dominio como `WashOrder`, `WashRequest`, `UserProfile`, tracking, paquetes y estados.
- `lib/services`
  Orquesta reglas de negocio y estado compartido, por ejemplo `OrderService`, `TrackingService`, `AuthService`, `ProfileService` y `SessionService`.
- `lib/repositories`
  Abstrae acceso a datos. Hay implementaciones mock y Firestore para pedidos y tracking.
- `lib/screens`
  Contiene pantallas por flujo y por rol.
- `lib/widgets`
  Componentes reutilizables de UI como cards, botones, mapas y secciones visuales.
- `lib/theme`
  Tema dark/light, tokens de color y helpers visuales.

## Estructura principal

```text
lib/
  app_config.dart
  firebase_options.dart
  main.dart
  controllers/
  models/
  repositories/
  screens/
  services/
  theme/
  widgets/
```

## Flujo por rol

### Cliente

1. Inicia sesion desde `RoleLoginPage` o `LoginPage`
2. Entra al `AppShell` en modo cliente
3. Desde `HomePage` selecciona paquete
4. Completa el flujo en `RequestWashFlowPage`
5. Confirma el pedido en `OrderConfirmationPage`
6. Sigue el estado en `OrderTrackingPage`
7. Consulta historial en `OrdersPage`

### Lavador

1. Inicia sesion con rol `worker`
2. Entra al `AppShell` en modo lavador
3. Consulta resumen operativo en `WorkerDashboardPage`
4. Acepta y avanza servicios en `WorkerServicesPage`
5. Publica progreso y tracking del servicio

## Firebase

La app inicializa Firebase en `lib/main.dart` usando `lib/firebase_options.dart`.

### Configuracion base

1. Crea un proyecto Firebase
2. Activa Authentication con Google Sign-In
3. Activa Cloud Firestore
4. Registra las apps objetivo
5. Genera `firebase_options.dart` con FlutterFire CLI

### Colecciones esperadas

- `profiles`
  Guarda nombre, email, foto, rol y metadatos del usuario autenticado.
- `orders`
  Guarda pedidos serializados desde `WashOrder` y `WashRequest`.
- `order_tracking`
  Guarda snapshots de tracking en vivo por pedido.

## Cambiar entre mock y Firestore

El switch global vive en `lib/app_config.dart`.

```dart
static const BackendMode backendMode = BackendMode.firestore;
```

Valores disponibles:

- `BackendMode.mock`
- `BackendMode.firestore`

Con esa sola linea cambian:

- repositorio de pedidos
- repositorio de tracking
- retardos artificiales usados solo para demo

## Autenticacion y sesion

- `AuthService` maneja Google Sign-In con Firebase Auth.
- Al autenticarse, se asegura la existencia del perfil base en `profiles`.
- `main.dart` usa un gate de autenticacion para saltar login si ya hay sesion activa.
- El rol actual se resuelve desde Firestore para abrir el `AppShell` correcto.

## Pantallas clave

- `lib/screens/role_login_page.dart`
- `lib/screens/login_page.dart`
- `lib/screens/home_page.dart`
- `lib/screens/request_wash_flow_page.dart`
- `lib/screens/order_confirmation_page.dart`
- `lib/screens/order_tracking_page.dart`
- `lib/screens/orders_page.dart`
- `lib/screens/worker_dashboard_page.dart`
- `lib/screens/worker_services_page.dart`
- `lib/screens/profile_hub_page.dart`

## Variables y configuracion necesarias

Este repo no usa aun un sistema formal de variables de entorno dentro de Flutter, pero para operar correctamente necesitas:

- configuracion Firebase valida en `firebase_options.dart`
- Google Sign-In configurado en Firebase Auth
- SHA keys y configuracion Android/iOS cuando aplique
- reglas de Firestore compatibles con `profiles`, `orders` y `order_tracking`

## Estado actual del proyecto

- UI principal cliente y lavador montada
- flujo moderno de solicitud consolidado en `request_wash_flow_page.dart`
- modo Firestore preparado desde `app_config.dart`
- tracking mock y Firestore coexistiendo segun configuracion
- autenticacion Google conectada a Firebase Auth
- home con secciones premium rediseñadas para paquetes, confianza y como funciona

## Pendientes recomendados

- correr `dart analyze`
- correr `flutter test`
- validar imports rotos despues de eliminar flujo legacy
- completar placeholders marcados con `TODO`
- endurecer `ProfileService` para que toda la lectura de perfil venga de Firestore
- validar reglas, indices y permisos de Firestore

## Desarrollo

Antes de considerar estable una sesion de trabajo larga:

1. revisa `app_config.dart`
2. confirma Firebase
3. ejecuta analisis estatico
4. corre pruebas
5. valida flujo cliente
6. valida flujo lavador
