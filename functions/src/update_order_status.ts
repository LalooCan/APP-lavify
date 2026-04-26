import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";

type OrderStatus =
  | "searching"
  | "assigned"
  | "on_the_way"
  | "arrived"
  | "in_progress"
  | "completed";

const ALLOWED_TRANSITIONS: Record<OrderStatus, OrderStatus | null> = {
  searching: null,
  assigned: "on_the_way",
  on_the_way: "arrived",
  arrived: "in_progress",
  in_progress: "completed",
  completed: null,
};

const STATUS_ETA: Record<OrderStatus, number> = {
  searching: 0,
  assigned: 18,
  on_the_way: 12,
  arrived: 0,
  in_progress: 30,
  completed: 0,
};

interface UpdateStatusData {
  orderId: string;
  nextStatus: OrderStatus;
  etaMinutes?: number;
}

export const updateOrderStatus = onCall<UpdateStatusData>(
  { enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }

    const workerUid = request.auth.uid;
    const { orderId, nextStatus, etaMinutes } = request.data;

    if (!orderId || !nextStatus) {
      throw new HttpsError("invalid-argument", "orderId y nextStatus son requeridos.");
    }

    const db = admin.firestore();
    const orderRef = db.collection("orders").doc(orderId);
    const orderSnap = await orderRef.get();

    if (!orderSnap.exists) {
      throw new HttpsError("not-found", "Pedido no encontrado.");
    }

    const order = orderSnap.data()!;

    if (order.workerId !== workerUid) {
      throw new HttpsError("permission-denied", "Solo el lavador asignado puede avanzar el estado.");
    }

    const currentStatus = order.status as OrderStatus;
    const allowedNext = ALLOWED_TRANSITIONS[currentStatus];

    if (allowedNext !== nextStatus) {
      throw new HttpsError(
        "failed-precondition",
        `Transición inválida: ${currentStatus} → ${nextStatus}`
      );
    }

    const resolvedEta = etaMinutes ?? STATUS_ETA[nextStatus] ?? 0;

    await orderRef.update({
      status: nextStatus,
      etaMinutes: resolvedEta,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Notificar al cliente del cambio de estado.
    await _notifyStatusChange(order.clientId as string, orderId, nextStatus);

    return { success: true, status: nextStatus, etaMinutes: resolvedEta };
  }
);

const STATUS_MESSAGES: Record<OrderStatus, string> = {
  searching: "Buscando lavador",
  assigned: "Lavador asignado",
  on_the_way: "Tu lavador está en camino",
  arrived: "Tu lavador ha llegado",
  in_progress: "Lavado en progreso",
  completed: "¡Servicio completado!",
};

async function _notifyStatusChange(
  clientId: string,
  orderId: string,
  status: OrderStatus
): Promise<void> {
  if (!clientId) return;

  const profileSnap = await admin
    .firestore()
    .collection("profiles")
    .doc(clientId)
    .get();
  const token = profileSnap.data()?.fcmToken as string | undefined;
  if (!token) return;

  await admin.messaging().send({
    token,
    notification: {
      title: "Actualización de tu servicio",
      body: STATUS_MESSAGES[status] ?? status,
    },
    data: { orderId, type: "status_update", status },
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
  });
}
