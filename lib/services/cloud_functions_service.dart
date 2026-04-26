import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

import '../models/wash_models.dart';

class CloudFunctionsException implements Exception {
  const CloudFunctionsException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

class CloudFunctionsService {
  CloudFunctionsService._internal();

  static final CloudFunctionsService _instance =
      CloudFunctionsService._internal();

  factory CloudFunctionsService() => _instance;

  FirebaseFunctions get _functions => FirebaseFunctions.instance;

  Future<Map<String, dynamic>> createOrder(WashRequestDraft draft) async {
    final request = draft.toRequest();
    try {
      final result = await _functions.httpsCallable('createOrder').call({
        'packageId': request.packageId,
        'vehicleTypeId': request.vehicleTypeId,
        'vehicleTypeName': request.vehicleTypeName,
        'address': request.address,
        'latitude': request.latitude,
        'longitude': request.longitude,
        'scheduleId': request.scheduleId,
        'notes': request.notes,
        'travelFee': request.travelFee,
        'estimatedMinutes': request.estimatedMinutes,
        'currency': request.currency,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        'CloudFunctions createOrder error: ${error.code} - ${error.message}',
      );
      throw CloudFunctionsException(
        _mapFunctionError(error),
        code: error.code,
      );
    }
  }

  Future<void> assignWorker(String orderId) async {
    try {
      await _functions.httpsCallable('assignWorker').call({
        'orderId': orderId,
      });
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        'CloudFunctions assignWorker error: ${error.code} - ${error.message}',
      );
      throw CloudFunctionsException(
        _mapFunctionError(error),
        code: error.code,
      );
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    OrderStatus nextStatus, {
    int? etaMinutes,
  }) async {
    try {
      final result = await _functions.httpsCallable('updateOrderStatus').call({
        'orderId': orderId,
        'nextStatus': nextStatus.apiValue,
        'etaMinutes': etaMinutes,
      });
      return Map<String, dynamic>.from(result.data as Map);
    } on FirebaseFunctionsException catch (error) {
      debugPrint(
        'CloudFunctions updateOrderStatus error: ${error.code} - ${error.message}',
      );
      throw CloudFunctionsException(
        _mapFunctionError(error),
        code: error.code,
      );
    }
  }

  String _mapFunctionError(FirebaseFunctionsException error) {
    switch (error.code) {
      case 'unauthenticated':
        return 'Debes iniciar sesion para continuar.';
      case 'permission-denied':
        return error.message ?? 'No tienes permiso para esta accion.';
      case 'not-found':
        return 'El servicio de backend no esta disponible todavia.';
      case 'failed-precondition':
        return error.message ?? 'La operacion no es valida en este momento.';
      case 'invalid-argument':
        return error.message ?? 'Datos invalidos en la solicitud.';
      case 'unavailable':
        return 'Servicio no disponible. Intenta de nuevo.';
      case 'internal':
        return 'El backend de pedidos respondio con error.';
      default:
        return error.message ?? 'Ocurrio un error inesperado.';
    }
  }
}
