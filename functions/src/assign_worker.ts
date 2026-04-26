import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";

interface AssignWorkerData {
  orderId: string;
}

export const assignWorker = onCall<AssignWorkerData>(
  { enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }

    const workerUid = request.auth.uid;
    const workerEmail = request.auth.token.email ?? "";
    const { orderId } = request.data;

    if (!orderId) {
      throw new HttpsError("invalid-argument", "orderId es requerido.");
    }

    const db = admin.firestore();

    // Verificar perfil worker.
    const profileSnap = await db.collection("profiles").doc(workerUid).get();
    if (!profileSnap.exists || profileSnap.data()?.role !== "worker") {
      throw new HttpsError(
        "permission-denied",
        "Solo lavadores pueden tomar pedidos."
      );
    }

    const workerName: string = profileSnap.data()?.name ?? "Lavador";

    // Ejecutar en transacción para evitar race conditions.
    await db.runTransaction(async (tx) => {
      const orderRef = db.collection("orders").doc(orderId);
      const orderSnap = await tx.get(orderRef);

      if (!orderSnap.exists) {
        throw new HttpsError("not-found", "Pedido no encontrado.");
      }

      const order = orderSnap.data()!;

      if (order.status !== "searching") {
        throw new HttpsError(
          "failed-precondition",
          "El pedido ya fue tomado por otro lavador."
        );
      }

      // Verificar que el worker no tenga otro pedido activo.
      const activeSnap = await db
        .collection("orders")
        .where("workerId", "==", workerUid)
        .where("status", "in", ["assigned", "on_the_way", "arrived", "in_progress"])
        .get();

      if (!activeSnap.empty) {
        throw new HttpsError(
          "failed-precondition",
          "Ya tienes un servicio activo. Complétalo antes de tomar otro."
        );
      }

      // Verificar conflicto de horario.
      const scheduleSnap = await db
        .collection("orders")
        .where("workerId", "==", workerUid)
        .where("request.scheduleId", "==", order.request.scheduleId)
        .get();

      if (!scheduleSnap.empty) {
        throw new HttpsError(
          "failed-precondition",
          "Ya tienes un servicio en ese horario."
        );
      }

      tx.update(orderRef, {
        status: "assigned",
        workerId: workerUid,
        assignedWorkerEmail: workerEmail,
        assignedWasherName: workerName,
        assignedVehicleLabel: "Unidad activa",
        etaMinutes: 18,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });
    });

    // Notificar al cliente.
    await _notifyClient(orderId, workerName);

    return { success: true };
  }
);

async function _notifyClient(orderId: string, workerName: string): Promise<void> {
  const orderSnap = await admin.firestore().collection("orders").doc(orderId).get();
  const clientId = orderSnap.data()?.clientId as string | undefined;
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
      title: "¡Lavador asignado!",
      body: `${workerName} está en camino. ETA: ~18 min`,
    },
    data: { orderId, type: "worker_assigned" },
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
  });
}
