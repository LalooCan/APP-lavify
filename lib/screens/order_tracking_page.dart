import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/order_service.dart';
import '../services/review_service.dart';
import '../theme/theme.dart';
import '../widgets/live_tracking_map.dart';
import '../widgets/primary_button.dart';

class OrderTrackingPage extends StatelessWidget {
  const OrderTrackingPage({super.key, required this.order});

  static final OrderService _orderService = OrderService();

  final WashOrder order;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _orderService.orders,
        _orderService.pendingSyncOrderIds,
        _orderService.syncErrors,
      ]),
      builder: (context, _) {
        final liveOrder = _orderService.getOrderById(order.id) ?? order;
        final isSyncPending = _orderService.isOrderSyncPending(liveOrder.id);
        final syncError = _orderService.syncErrorForOrder(liveOrder.id);
        final stages = OrderStatus.values;
        final activeIndex = stages.indexOf(liveOrder.status);
        final isSearching = liveOrder.status == OrderStatus.searching;
        final statusAccent = _statusAccent(liveOrder.status);
        final statusSummary = _statusSummary(liveOrder);
        final mapBadgeLabel = isSearching
            ? 'Buscando lavador cerca de ti'
            : liveOrder.etaMinutes > 0
            ? 'Llegando en ${liveOrder.etaMinutes} min'
            : liveOrder.status.label;

        return Scaffold(
          appBar: AppBar(title: Text('Pedido ${liveOrder.id}')),
          body: Container(
            decoration: LavifyTheme.pageDecoration(context),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSyncPending || syncError != null) ...[
                      _OrderSyncBanner(
                        isPending: isSyncPending,
                        errorMessage: syncError,
                        onRetry: syncError == null
                            ? null
                            : () {
                                _orderService
                                    .retryOrderSync(liveOrder.id)
                                    .catchError((Object error) {
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'No se pudo reintentar la sincronizacion.',
                                          ),
                                        ),
                                      );
                                    });
                              },
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: LavifyTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: LavifyTheme.borderColor(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isSearching
                                      ? 'Buscando lavador'
                                      : liveOrder.status.label,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: statusAccent.withAlpha(24),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  isSearching
                                      ? 'Buscando'
                                      : liveOrder.status.label,
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        color: statusAccent,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            statusSummary,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 280,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: LiveTrackingMap(order: liveOrder),
                          ),
                          Positioned(
                            right: 16,
                            bottom: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: LavifyTheme.overlayPanelColor(context),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: LavifyTheme.borderColor(context),
                                ),
                              ),
                              child: Text(
                                mapBadgeLabel,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: LavifyTheme.textPrimaryColor(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSearching) ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: LavifyTheme.surfaceColor(context),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: LavifyTheme.borderColor(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Que esta pasando ahora',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 14),
                            const _TrackingNote(
                              title: 'Solicitud confirmada',
                              subtitle:
                                  'Tu pedido ya entro al flujo y esta listo para asignacion.',
                            ),
                            const SizedBox(height: 12),
                            const _TrackingNote(
                              title: 'Buscando lavador disponible',
                              subtitle:
                                  'Lavify esta revisando trabajadores cercanos y disponibles.',
                            ),
                            const SizedBox(height: 12),
                            const _TrackingNote(
                              title: 'Te avisaremos al asignarlo',
                              subtitle:
                                  'Cuando alguien tome el servicio, esta pantalla cambiara al seguimiento del trayecto.',
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: LavifyTheme.surfaceColor(context),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: LavifyTheme.borderColor(context),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Progreso del servicio',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 18),
                            for (int i = 0; i < stages.length; i++) ...[
                              _TrackingStep(
                                title: stages[i].label,
                                completed: i <= activeIndex,
                                isLast: i == stages.length - 1,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: LavifyTheme.surfaceColor(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: LavifyTheme.borderColor(context),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Detalle del pedido',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 14),
                          _DetailRow(
                            label: 'Paquete',
                            value: liveOrder.request.packageName,
                          ),
                          _DetailRow(
                            label: 'Vehiculo',
                            value: liveOrder.request.vehicleTypeName,
                          ),
                          _DetailRow(
                            label: 'Direccion',
                            value: liveOrder.request.address,
                          ),
                          _DetailRow(
                            label: 'Horario',
                            value: liveOrder.request.scheduleLabel,
                          ),
                          _DetailRow(
                            label: 'Total',
                            value:
                                '\$${liveOrder.request.totalPrice} ${liveOrder.request.currency}',
                          ),
                        ],
                      ),
                    ),
                    if (liveOrder.status == OrderStatus.completed &&
                        liveOrder.workerId != null) ...[
                      const SizedBox(height: 20),
                      _ReviewCard(
                        orderId: liveOrder.id,
                        workerId: liveOrder.workerId!,
                        workerName: liveOrder.assignedWasherName,
                      ),
                    ],
                    const SizedBox(height: 20),
                    PrimaryButton(
                      label: 'Volver al inicio',
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      isExpanded: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _statusSummary(WashOrder order) {
    switch (order.status) {
      case OrderStatus.searching:
        return 'Tu solicitud esta confirmada y estamos buscando un trabajador disponible cerca de tu ubicacion.';
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
        return '${order.assignedWasherName} va en ${order.assignedVehicleLabel}. ETA ${order.etaMinutes} min.';
      case OrderStatus.arrived:
        return '${order.assignedWasherName} ya llego al punto de servicio.';
      case OrderStatus.inProgress:
        return '${order.assignedWasherName} ya esta realizando el lavado.';
      case OrderStatus.completed:
        return 'El servicio fue completado correctamente.';
    }
  }

  Color _statusAccent(OrderStatus status) {
    switch (status) {
      case OrderStatus.searching:
        return const Color(0xFFFFC857);
      case OrderStatus.assigned:
      case OrderStatus.onTheWay:
        return LavifyColors.primary;
      case OrderStatus.arrived:
      case OrderStatus.inProgress:
        return const Color(0xFF9B7BFF);
      case OrderStatus.completed:
        return LavifyColors.success;
    }
  }
}

class _OrderSyncBanner extends StatelessWidget {
  const _OrderSyncBanner({
    required this.isPending,
    required this.errorMessage,
    required this.onRetry,
  });

  final bool isPending;
  final String? errorMessage;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final hasError = errorMessage != null;
    final accent = hasError ? const Color(0xFFFF6B6B) : LavifyColors.primary;
    final title = hasError ? 'Sincronizacion pendiente' : 'Pedido creado';
    final message =
        errorMessage ??
        (isPending
            ? 'Estamos guardando tu pedido en Firestore. Puedes seguir aqui mientras termina.'
            : 'Tu pedido ya esta sincronizado.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withAlpha(LavifyTheme.isLight(context) ? 24 : 20),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: accent.withAlpha(72)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            hasError ? Icons.sync_problem_rounded : Icons.cloud_sync_rounded,
            color: accent,
          ),
          const SizedBox(width: 12),
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
                Text(message, style: Theme.of(context).textTheme.bodyMedium),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Reintentar'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingStep extends StatelessWidget {
  const _TrackingStep({
    required this.title,
    required this.completed,
    required this.isLast,
  });

  final String title;
  final bool completed;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: completed ? LavifyColors.primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: completed
                      ? LavifyColors.primary
                      : LavifyTheme.borderColor(context),
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: completed
                    ? LavifyColors.primary
                    : LavifyTheme.borderColor(context),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: completed
                  ? LavifyTheme.textPrimaryColor(context)
                  : LavifyTheme.textSecondaryColor(context),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: LavifyTheme.textPrimaryColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackingNote extends StatelessWidget {
  const _TrackingNote({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: LavifyTheme.softFillStrongColor(context),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: LavifyTheme.textPrimaryColor(context),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatefulWidget {
  const _ReviewCard({
    required this.orderId,
    required this.workerId,
    required this.workerName,
  });

  final String orderId;
  final String workerId;
  final String workerName;

  @override
  State<_ReviewCard> createState() => _ReviewCardState();
}

class _ReviewCardState extends State<_ReviewCard> {
  static final ReviewService _reviewService = ReviewService();

  int _rating = 5;
  final _commentController = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExisting();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _checkExisting() async {
    final existing = await _reviewService.getReviewForOrder(widget.orderId);
    if (existing != null && mounted) {
      setState(() {
        _rating = existing.rating;
        _commentController.text = existing.comment;
        _submitted = true;
      });
    }
  }

  Future<void> _submit() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    final result = await _reviewService.submitReview(
      orderId: widget.orderId,
      workerId: widget.workerId,
      rating: _rating,
      comment: _commentController.text,
    );
    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _submitted = result != null;
    });
    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo guardar la calificación.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: LavifyTheme.surfaceColor(context),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: LavifyTheme.borderColor(context)),
      ),
      child: _submitted ? _submittedView(rating: _rating) : _formView(),
    );
  }

  Widget _submittedView({required int rating}) {
    return Column(
      children: [
        const Icon(Icons.check_circle_rounded,
            color: LavifyColors.success, size: 40),
        const SizedBox(height: 12),
        Text(
          '¡Gracias por tu calificación!',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => Icon(
              i < rating ? Icons.star_rounded : Icons.star_border_rounded,
              color: const Color(0xFFFFC857),
              size: 28,
            ),
          ),
        ),
      ],
    );
  }

  Widget _formView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¿Cómo fue tu experiencia?',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 4),
        Text(
          'Califica el servicio de ${widget.workerName}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (i) {
            final star = i + 1;
            return GestureDetector(
              onTap: () => setState(() => _rating = star),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Icon(
                  star <= _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: const Color(0xFFFFC857),
                  size: 36,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Deja un comentario (opcional)',
            hintStyle: TextStyle(
                color: LavifyTheme.textSecondaryColor(context)),
            filled: true,
            fillColor: LavifyTheme.surfaceAltColor(context),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: LavifyTheme.borderColor(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: LavifyColors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _isLoading ? null : _submit,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Enviar calificación'),
          ),
        ),
      ],
    );
  }
}
