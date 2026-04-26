import * as admin from "firebase-admin";
import { HttpsError, onCall } from "firebase-functions/v2/https";
import {
  KNOWN_PACKAGES,
  KNOWN_VEHICLES,
  calculateTotal,
  packagePrice,
  vehicleExtraFee,
} from "./catalog";

interface CreateOrderData {
  packageId: string;
  vehicleTypeId: string;
  address: string;
  latitude: number;
  longitude: number;
  scheduleId: string;
  notes?: string;
  travelFee: number;
  vehicleTypeName?: string;
  estimatedMinutes?: number;
  currency?: string;
}

export const createOrder = onCall<CreateOrderData>(
  { enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError("unauthenticated", "Debes iniciar sesión.");
    }

    const uid = request.auth.uid;
    const email = request.auth.token.email ?? "";
    const data = request.data;

    if (!KNOWN_PACKAGES.includes(data.packageId)) {
      throw new HttpsError(
        "invalid-argument",
        "Paquete no disponible: " + data.packageId
      );
    }
    if (!KNOWN_VEHICLES.includes(data.vehicleTypeId)) {
      throw new HttpsError(
        "invalid-argument",
        "Tipo de vehículo no disponible: " + data.vehicleTypeId
      );
    }
    if (
      typeof data.travelFee !== "number" ||
      data.travelFee < 0 ||
      data.travelFee > 250
    ) {
      throw new HttpsError("invalid-argument", "Tarifa de traslado inválida.");
    }
    if (!data.address || !data.scheduleId) {
      throw new HttpsError("invalid-argument", "Dirección y horario son requeridos.");
    }

    const servicePrice = packagePrice(data.packageId);
    const extraFee = vehicleExtraFee(data.vehicleTypeId);
    const totalPrice = calculateTotal(data.packageId, data.vehicleTypeId, data.travelFee);

    const orderId = `order_${Date.now()}_${uid.slice(0, 6)}`;
    const now = new Date().toISOString();

    const order = {
      id: orderId,
      status: "searching",
      clientId: uid,
      customerEmail: email,
      assignedWasherName: "Por asignar",
      workerId: null,
      assignedWorkerEmail: null,
      assignedVehicleLabel: data.vehicleTypeName ?? data.vehicleTypeId,
      etaMinutes: data.estimatedMinutes ?? 30,
      createdAt: now,
      request: {
        packageId: data.packageId,
        vehicleTypeId: data.vehicleTypeId,
        vehicleTypeName: data.vehicleTypeName ?? data.vehicleTypeId,
        address: data.address,
        latitude: data.latitude,
        longitude: data.longitude,
        scheduleId: data.scheduleId,
        notes: data.notes ?? "",
        servicePrice,
        travelFee: data.travelFee,
        totalPrice,
        currency: data.currency ?? "MXN",
        estimatedMinutes: data.estimatedMinutes ?? 30,
        extraFee,
      },
    };

    await admin.firestore().collection("orders").doc(orderId).set(order);

    // Notificar a trabajadores disponibles.
    await _notifyAvailableWorkers(orderId, data.address, data.packageId);

    return { orderId, totalPrice, servicePrice, travelFee: data.travelFee };
  }
);

async function _notifyAvailableWorkers(
  orderId: string,
  address: string,
  packageId: string
): Promise<void> {
  const workersSnap = await admin
    .firestore()
    .collection("workers")
    .where("isAvailable", "==", true)
    .get();

  const tokens: string[] = [];
  workersSnap.forEach((doc) => {
    const token = doc.data().fcmToken as string | undefined;
    if (token) tokens.push(token);
  });

  if (tokens.length === 0) return;

  const packageLabels: Record<string, string> = {
    express: "Express",
    "full-care": "Full Care",
    premium: "Premium",
  };

  const message: admin.messaging.MulticastMessage = {
    tokens,
    notification: {
      title: "Nuevo servicio disponible",
      body: `Paquete ${packageLabels[packageId] ?? packageId} en ${address}`,
    },
    data: { orderId, type: "new_order" },
    android: { priority: "high" },
    apns: { payload: { aps: { sound: "default" } } },
  };

  await admin.messaging().sendEachForMulticast(message);
}
