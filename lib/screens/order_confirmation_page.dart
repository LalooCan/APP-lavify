import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../theme/theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/secondary_button.dart';
import '../widgets/section_container.dart';
import 'order_tracking_page.dart';

class OrderConfirmationPage extends StatefulWidget {
  const OrderConfirmationPage({
    super.key,
    required this.draft,
  });

  final WashRequestDraft draft;

  @override
  State<OrderConfirmationPage> createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  static final OrderService _orderService = OrderService();

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final request = widget.draft.toRequest();

    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar pedido')),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A1423),
              Color(0xFF0E1B30),
              LavifyColors.background,
            ],
          ),
        ),
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
                  'Todo listo para confirmar el pedido mock y dejar el payload preparado para backend.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                SectionContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ConfirmationRow(
                        label: 'Paquete',
                        value: request.packageName,
                      ),
                      _ConfirmationRow(
                        label: 'Precio',
                        value: '\$${request.price} ${request.currency}',
                      ),
                      _ConfirmationRow(
                        label: 'Direccion',
                        value: request.address,
                      ),
                      _ConfirmationRow(
                        label: 'Coordenadas',
                        value:
                            '${request.latitude.toStringAsFixed(6)}, ${request.longitude.toStringAsFixed(6)}',
                      ),
                      _ConfirmationRow(
                        label: 'Horario',
                        value: request.scheduleLabel,
                      ),
                      _ConfirmationRow(
                        label: 'Vehiculo',
                        value: request.vehicleTypeName,
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
                        'Payload listo para backend',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: LavifyColors.background,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: LavifyColors.border),
                        ),
                        child: SelectableText(
                          request.toJson(),
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: LavifyColors.textPrimary,
                                    fontFamily: 'monospace',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _isSubmitting
                      ? 'Confirmando pedido...'
                      : 'Confirmar pedido',
                  onPressed: _isSubmitting ? () {} : _handleConfirmOrder,
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
    });

    try {
      final order = await _orderService.createOrder(widget.draft.toRequest());

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => OrderTrackingPage(order: order),
        ),
      );
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
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: LavifyColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
