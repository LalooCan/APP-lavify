import 'package:flutter/foundation.dart';

import '../models/wash_models.dart';

enum PaymentMethodType { cash, card, digitalWallet }

extension PaymentMethodTypeX on PaymentMethodType {
  String get label {
    switch (this) {
      case PaymentMethodType.cash:
        return 'Efectivo';
      case PaymentMethodType.card:
        return 'Tarjeta';
      case PaymentMethodType.digitalWallet:
        return 'Billetera digital';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethodType.cash:
        return '💵';
      case PaymentMethodType.card:
        return '💳';
      case PaymentMethodType.digitalWallet:
        return '📱';
    }
  }

  String get apiValue => name;
}

class PaymentService {
  PaymentService._internal();
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;

  List<PaymentMethodType> getSupportedMethods() => PaymentMethodType.values;

  // Placeholder — swappable con Stripe/MercadoPago implementando la misma firma.
  Future<bool> processPayment({
    required WashOrder order,
    required PaymentMethodType method,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    debugPrint(
      'PaymentService.processPayment: orden=${order.id} método=${method.label}',
    );
    return true;
  }
}
