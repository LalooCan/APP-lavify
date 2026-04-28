# Lavify — Guía del codebase

App de lavado de autos a domicilio. Cliente pide → lavador acepta → tracking en tiempo real.
Flutter + Firebase (Firestore, Auth, Cloud Functions).

---

## Arquitectura en capas

```
models/ → repositories/ → services/ → controllers/ → screens/ + widgets/
```

Cada capa solo conoce las capas que están por debajo de ella. Una pantalla no habla directo a un repositorio; lo hace a través de un servicio.

| Capa | Qué hace | Ejemplo |
|---|---|---|
| `models/` | Tipos de datos puros, sin lógica de UI ni de red | `WashOrder`, `WashPackage` |
| `repositories/` | Lectura/escritura de datos (Firestore o mock) | `FirestoreOrderRepository` |
| `services/` | Lógica de negocio; usan repositorios | `OrderService` |
| `controllers/` | Estado efímero de flujos UI multi-paso | `WashRequestDraftController` |
| `screens/` | Páginas completas | `HomePage`, `RequestWashFlowPage` |
| `widgets/` | Componentes reutilizables entre pantallas | `PrimaryButton`, `PackageCard` |

---

## Patrones que ya existen — úsalos, no los reinventes

### 1. Servicios como singletons
Todos los servicios usan factory singleton. `OrderService()` siempre devuelve la misma instancia.

```dart
// ✅ Así están todos los servicios
class OrderService {
  OrderService._internal();
  static final OrderService _instance = OrderService._internal();
  factory OrderService() => _instance;
}

// ✅ Usar en cualquier widget o servicio
final _orderService = OrderService();
```

**No** crees nuevas instancias con `new`, no uses `get_it`, no uses Riverpod, no uses Provider. El patrón que existe funciona.

### 2. Estado reactivo con ValueNotifier
No hay BLoC, no hay Riverpod. Solo `ValueNotifier` + `ValueListenableBuilder`.

```dart
// En el servicio
late final ValueNotifier<List<WashOrder>> orders;

// En el widget
ValueListenableBuilder<List<WashOrder>>(
  valueListenable: _orderService.orders,
  builder: (context, orders, _) { ... },
)
```

### 3. Switch mock/Firestore — UN solo lugar
```dart
// lib/app_config.dart
static const BackendMode backendMode = BackendMode.firestore; // ← cambia esto y listo
```

Cada servicio consulta `AppConfig.backendMode` para decidir qué repositorio usar. **No** pongas lógica de `if mock / if firestore` dentro de servicios o pantallas.

### 4. Repositorio con interfaz + dos implementaciones
Cada dominio tiene:
- `order_repository.dart` — interfaz abstracta
- `firestore_order_repository.dart` — producción
- `mock_order_repository.dart` — desarrollo/tests

Al agregar una operación nueva, agrégala en los tres.

### 5. Barrel de modelos
```dart
import '../models/wash_models.dart'; // ← importa todos los modelos de dominio
```
`wash_models.dart` re-exporta todo. Úsalo. No importes archivos de modelo individuales en pantallas o servicios.

### 6. Catálogo de datos (packages, vehículos, horarios)
Los datos del catálogo viven en `lib/models/wash_package.dart` como listas `const`:
- `washPackages` — lista de `WashPackage`
- `vehicleTypes` — lista de `VehicleType`
- `scheduleSlots` — lista de `ScheduleSlot`

Si cambias precios o paquetes, es ahí. No dupliques estos datos en servicios ni pantallas.

---

## Navegación

La app tiene dos modos de navegación:

**Tabs (AppShell)** — navegación principal dentro de la app autenticada.
- Cliente: Inicio / Pedidos / Perfil
- Lavador: Panel / Servicios / Config

**Navigator push** — flujos modales que salen de los tabs:
- `RequestWashFlowPage` — flujo de 3 pasos para pedir un lavado
- `OrderConfirmationPage` — confirmación antes de crear el pedido
- `OrderTrackingPage` — seguimiento de un pedido activo
- `RoleLoginPage` — login

No uses rutas nombradas (`'/home'`) para navegación nueva. Usa `MaterialPageRoute` con `Navigator.of(context).push(...)`.

---

## Flujo principal (cliente)

```
HomePage
  └── [botón "Pedir lavado"]
        └── RequestWashFlowPage (3 pasos con WashRequestDraftController)
              Paso 0: selección de paquete
              Paso 1: ubicación + tipo de vehículo
              Paso 2: horario + resumen
              └── [botón "Confirmar"]
                    └── OrderConfirmationPage
                          └── OrderService.createOrderFromDraft(draft)
                                ├── [mock] → MockOrderRepository
                                └── [firestore] → CloudFunctionsService.createOrder()
                                                   con fallback a FirestoreOrderRepository
```

---

## Flujo principal (lavador)

```
WorkerDashboardPage
  └── OrderService.orders (ValueNotifier) — ve todas las órdenes en searching
        └── [botón "Tomar pedido"]
              └── OrderService.takeOrder(orderId)
                    └── [firestore] → CloudFunctionsService.assignWorker() (atómico)
        └── [botón "Avanzar estado"]
              └── OrderService.advanceOrder(orderId)
```

---

## Tema y estilos

Todo el sistema de colores y estilos está en `lib/theme/theme.dart`.

```dart
LavifyTheme.isLight(context)         // bool — evita Theme.of(context).brightness
LavifyTheme.textPrimaryColor(context) // colores sensibles al tema
LavifyTheme.surfaceColor(context)
LavifyTheme.borderColor(context)
LavifyTheme.panelShadow(context)
LavifyTheme.premiumPanelGradient(context)
LavifyColors.primary                  // azul principal
LavifyColors.primaryStrong
LavifyColors.accent
LavifyColors.success
LavifyColors.lightNavy               // navy para modo claro
```

**Excepción:** `request_wash_flow_page.dart` tiene helpers `_flow*Color()` propios al final del archivo. Es intencional: el flujo tiene su propia identidad visual independiente del shell principal. No los borres ni los muevas a `LavifyTheme`.

---

## Widgets privados en el mismo archivo

Cuando un widget solo se usa dentro de una pantalla, se declara como clase privada (`_ClassName`) en el mismo archivo. Esto es el patrón Flutter idiomático.

```dart
// ✅ Correcto — widget privado en home_page.dart
class _StatusChip extends StatelessWidget { ... }

// ❌ Incorrecto — no crear un archivo separado solo para un widget que nadie más usa
// lib/widgets/status_chip.dart  ← no
```

Mueve un widget a `lib/widgets/` solo si se usa en dos o más pantallas distintas.

---

## Dónde va cada cosa nueva

| Qué quieres agregar | Dónde va |
|---|---|
| Nuevo tipo de dato / modelo | `lib/models/` |
| Nueva operación de base de datos | `lib/repositories/` (interfaz + mock + firestore) |
| Nueva lógica de negocio | `lib/services/` |
| Estado de un formulario multi-paso | `lib/controllers/` |
| Nueva pantalla | `lib/screens/` |
| Widget reutilizable (≥2 pantallas) | `lib/widgets/` |
| Widget usado solo en una pantalla | Clase privada `_X` en el mismo archivo de la pantalla |
| Nuevo color o estilo global | `lib/theme/theme.dart` |
| Cambio al catálogo (paquetes, vehículos, horarios) | `lib/models/wash_package.dart` |

---

## Reglas para no romper cosas

1. **No toques `AppConfig`** sin entender que afecta toda la app al mismo tiempo.
2. **No agregues lógica de negocio en pantallas.** Si un widget necesita calcular algo que no es puramente presentación, ese cálculo va en un servicio.
3. **`createOrderFromDraft`** tiene lógica de retry y fallback a Firestore. Si modificas el flujo de creación de orden, respeta ese manejo de errores.
4. **Los `ValueNotifier` de los servicios son la fuente de verdad.** No cachees `orders.value` en variables locales de widget sin suscribirte con `ValueListenableBuilder`.
5. **El modelo `WashOrder` tiene `isVisibleToClient` y `isVisibleToWorker`.** Úsalos para filtrar — no implementes esa lógica de visibilidad en otro lugar.
6. **`OrderService.activeClientOrder` y `activeWorkerOrder`** ya resuelven cuál pedido está activo. No reimplementes esa lógica.

---

## Tests

```
test/models/         — tests de lógica pura de modelos
test/repositories/   — tests de repositorios mock
test/services/       — tests de servicios con mocks
```

Correr todos los tests: `flutter test`

---

## Onboarding rápido (5 min para un dev nuevo)

1. Leer este archivo completo.
2. Leer `lib/app_config.dart` — entiende el switch mock/firestore.
3. Leer `lib/models/wash_package.dart` — entiende el catálogo de datos.
4. Leer `lib/services/order_service.dart` — es el servicio central.
5. Correr la app con `backendMode = BackendMode.mock` para desarrollar sin Firebase.
6. Antes de agregar algo nuevo, buscar si ya existe un patrón similar en el código.
