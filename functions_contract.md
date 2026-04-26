# Cloud Functions - Contrato

Objetivo: mover la autoridad de pedidos al backend sin romper el modo mock ni
el flujo actual de Flutter. La app puede crear estados optimistas, pero el
backend debe ser la fuente de verdad para precios, asignacion, estados y pagos.

## createOrder
- Trigger: callable `createOrder(draft)` o HTTPS endpoint autenticado.
- Entrada: `packageId`, `vehicleTypeId`, `address`, `lat/lng`, `scheduleId`,
  `notes`.
- Logica: valida usuario, recalcula precio desde catalogo server-side,
  normaliza horario/vehiculo, crea `orders/{orderId}` con `status: searching`.
- Seguridad: nunca aceptar `servicePrice`, `travelFee` o `totalPrice` enviados
  por UI como fuente de verdad.

## assignWorker
- Trigger: callable `assignWorker(orderId)` para lavador o job automatico sobre
  `orders/{orderId}` en `searching`.
- Logica: valida perfil `worker`, disponibilidad, que no tenga otro pedido
  activo y que no exista conflicto de horario. Cambia a `assigned` en una
  transaccion.
- Seguridad: evita carreras donde dos lavadores toman el mismo pedido.

## updateOrderStatus
- Trigger: callable `updateOrderStatus(orderId, nextStatus, etaMinutes?)`.
- Logica: valida que el lavador asignado avance solo:
  `assigned -> on_the_way -> arrived -> in_progress -> completed`.
- Seguridad: cliente no puede avanzar estados, lavador no puede cambiar
  cliente, precios ni request original.

## processPayment
- Trigger: callable `processPayment(orderId, paymentMethodId)`.
- Logica: integracion Stripe/MercadoPago, valida monto contra precio real del
  paquete y registra intento de pago.
- Seguridad: no cobrar montos recibidos desde el cliente sin recalculo.

## calculateCommission
- Trigger: onUpdate en `orders/{orderId}` cuando `status` pasa a `completed`.
- Logica: calcula comision Lavify, payout del lavador y registra ledger.
