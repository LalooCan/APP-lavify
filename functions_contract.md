# Cloud Functions — Contrato

## assignWorker
- Trigger: onCreate en orders/{orderId}
- Logica: busca lavador disponible mas cercano, lo asigna, cambia estado a assigned
- Por que server-side: evitar que cliente se autoasigne o manipule asignaciones

## updateOrderStatus
- Trigger: callable
- Logica: valida transiciones de estado permitidas (pending->assigned->in_progress->completed)
- Por que server-side: evitar saltar estados o marcar completado sin autorizacion

## processPayment
- Trigger: callable
- Logica: integracion Stripe/MercadoPago, valida monto contra precio real del paquete
- Por que server-side: nunca confiar en precio enviado desde cliente

## calculateCommission
- Trigger: onUpdate en orders/{orderId} cuando status->completed
- Logica: calcula comision Lavify, registra pago a lavador
