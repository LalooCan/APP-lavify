// Catálogo de precios server-side — fuente de verdad para validación de órdenes.

export const PACKAGE_PRICES: Record<string, number> = {
  express: 99,
  "full-care": 149,
  premium: 199,
};

export const VEHICLE_EXTRA_FEES: Record<string, number> = {
  compact: 0,
  sedan: 0,
  suv: 30,
};

export const KNOWN_PACKAGES = Object.keys(PACKAGE_PRICES);
export const KNOWN_VEHICLES = Object.keys(VEHICLE_EXTRA_FEES);

export const PLATFORM_COMMISSION_RATE = 0.2; // 20% Lavify

export function packagePrice(packageId: string): number {
  return PACKAGE_PRICES[packageId] ?? -1;
}

export function vehicleExtraFee(vehicleTypeId: string): number {
  return VEHICLE_EXTRA_FEES[vehicleTypeId] ?? 0;
}

export function calculateTotal(
  packageId: string,
  vehicleTypeId: string,
  travelFee: number
): number {
  return packagePrice(packageId) + vehicleExtraFee(vehicleTypeId) + travelFee;
}
