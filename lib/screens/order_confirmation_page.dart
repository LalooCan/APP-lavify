import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../repositories/firestore_order_repository.dart';
import '../services/cloud_functions_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_container.dart';
import 'order_tracking_page.dart';

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({super.key, required this.draft});

  final WashRequestDraft draft;

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  static final OrderService _orderService = OrderService();
  static final ProfileService _profileService = ProfileService();

  bool _isSubmitting = false;
  String? _submitError;

  @override
  Widget build(BuildContext context) {
    final request = widget.draft.toRequest();
    final vehicleExtraFee = widget.draft.vehicleExtraFee;
    final paymentMethod = _profileService.profile.value.paymentMethod.trim();
    final paymentLabel = paymentMethod.isEmpty
        ? 'Pago pendiente al asignar lavador'
        : paymentMethod;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Revisa tu pedido',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Confirma los detalles y nosotros buscamos un lavador disponible para tu horario.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Resumen',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _ConfirmationRow(
                        label: 'Paquete',
                        value: request.packageName,
                      ),
                      _ConfirmationRow(
                        label: 'Direccion',
                        value: request.address,
                      ),
                      _ConfirmationRow(
                        label: 'Horario',
                        value: request.scheduleLabel,
                      ),
                      _ConfirmationRow(
                        label: 'Vehiculo',
                        value: request.vehicleTypeName,
                      ),
                      _ConfirmationRow(
                        label: 'Metodo de pago',
                        value: paymentLabel,
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                SectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total estimado',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      _PriceRow(
                        label: 'Lavado ${request.packageName}',
                        value: '\$${request.servicePrice}',
                      ),
                      _PriceRow(
                        label: 'Traslado',
                        value: '\$${request.travelFee}',
                      ),
                      if (vehicleExtraFee > 0)
                        _PriceRow(
                          label: 'Extra vehiculo',
                          value: '\$$vehicleExtraFee',
                        ),
                      Divider(color: LavifyTheme.borderColor(context)),
                      _PriceRow(
                        label: 'Total',
                        value: '\$${request.price} ${request.currency}',
                        isTotal: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _SyncInfoCard(
                  title: 'Sin cargo hasta la asignacion',
                  subtitle:
                      'Crearemos tu solicitud y, si Firestore tarda, la app continuara con seguimiento mientras termina de sincronizar.',
                ),
                const SizedBox(height: 24),
                if (_submitError != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0x22FF6B6B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0x55FF6B6B)),
                    ),
                    child: Text(
                      _submitError!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: LavifyTheme.isLight(context)
                            ? const Color(0xFF8B2424)
                            : Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                PrimaryButton(
                  label: _isSubmitting
                      ? 'Creando solicitud...'
                      : 'Confirmar solicitud \u00B7 \$${request.price}',
                  onPressed: _isSubmitting ? null : _handleConfirmOrder,
                  isExpanded: true,
                ),
                const SizedBox(height: 14),
                SecondaryButton(
                  label: 'Volver',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icons.arrow_back_rounded,
                  isExpanded: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleConfirmOrder() async {
    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    try {
      final order = await _orderService.createOrderFromDraft(widget.draft);

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderTrackingPage(order: order),
        ),
      );
    } catch (error, stack) {
      if (!mounted) {
        return;
      }

      debugPrint('Error al confirmar pedido: $error\n$stack');
      final message = switch (error) {
        OrderSubmissionException(:final message) => message,
        CloudFunctionsException(:final message) => message,
        FirestoreOrderRepositoryException(:final code)
            when code == 'permission-denied' =>
          'No tienes permisos para confirmar este pedido. Cierra sesion e inicia de nuevo.',
        FirestoreOrderRepositoryException(:final message) => message,
        _ =>
          'No se pudo confirmar el pedido. Verifica tu conexion e intenta de nuevo.',
      };

      setState(() {
        _submitError = message;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(_submitError!)));
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}

class _ConfirmationRow extends StatelessWidget {
  const _ConfirmationRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  final String label;
  final String value;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleLarge
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: EdgeInsets.only(bottom: isTotal ? 0 : 10, top: isTotal ? 10 : 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: textStyle?.copyWith(
                color: isTotal
                    ? LavifyTheme.textPrimaryColor(context)
                    : LavifyTheme.textSecondaryColor(context),
                fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: textStyle?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: isTotal ? FontWeight.w800 : FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SyncInfoCard extends StatelessWidget {
  const _SyncInfoCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LavifyTheme.selectedTileColor(context),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: LavifyTheme.isLight(context)
                  ? LavifyColors.lightNavy
                  : LavifyColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: LavifyTheme.textPrimaryColor(context),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
