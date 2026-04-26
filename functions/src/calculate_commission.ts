import * as admin from "firebase-admin";
import { onDocumentUpdated } from "firebase-functions/v2/firestore";
import { PLATFORM_COMMISSION_RATE } from "./catalog";

export const calculateCommission = onDocumentUpdated(
  "orders/{orderId}",
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // Solo actuar cuando la orden pasa a completed.
    if (before.status === after.status || after.status !== "completed") return;

    const orderId = event.params.orderId;
    const workerId = after.workerId as string | undefined;
    const totalPrice: number = after.request?.totalPrice ?? 0;

    if (!workerId || totalPrice <= 0) return;

    const commission = Math.round(totalPrice * PLATFORM_COMMISSION_RATE);
    const workerEarning = totalPrice - commission;

    const db = admin.firestore();

    // Registrar ledger en subcolección.
    const ledgerRef = db.collection("ledger").doc(orderId);
    await ledgerRef.set({
      orderId,
      workerId,
      totalPrice,
      commission,
      workerEarning,
      completedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Actualizar acumulado de ganancias del worker.
    const workerRef = db.collection("workers").doc(workerId);
    await workerRef.set(
      {
        totalEarnings: admin.firestore.FieldValue.increment(workerEarning),
        completedServicesCount: admin.firestore.FieldValue.increment(1),
        lastServiceAt: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Marcar orden con datos de comisión.
    await db.collection("orders").doc(orderId).update({
      commission,
      workerEarning,
    });
  }
);
