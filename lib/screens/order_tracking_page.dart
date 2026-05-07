import 'package:flutter/material.dart';

import '../models/wash_models.dart';
import '../services/chat_service.dart';
import '../services/order_service.dart';
import '../services/profile_service.dart';
import '../services/review_service.dart';
import '../theme/theme.dart';
import '../widgets/live_tracking_map.dart';
import 'chat_screen.dart';

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
        const stages = [
          OrderStatus.searching,
          OrderStatus.assigned,
          OrderStatus.onTheWay,
          OrderStatus.arrived,
          OrderStatus.inProgress,
          OrderStatus.completed,
        ];
        final activeIndex = stages.indexOf(liveOrder.status);
        final currentProfile = ProfileService().profile.value;
        final canChat = ChatService().canChat(liveOrder, currentProfile);
        final isSearching = liveOrder.status == OrderStatus.searching;
        final statusAccent = _statusAccent(liveOrder.status);
        final statusSummary = _statusSummary(liveOrder);
        final padding = MediaQuery.of(context).padding;

        return Scaffold(
          body: Stack(
            children: [
              Positioned.fill(
                child: LiveTrackingMap(
                  order: liveOrder,
                  showLegend: false,
                  borderRadius: 0,
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        _MapOverlayBtn(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const Spacer(),
                        if (canChat)
                          _MapOverlayBtn(
                            icon: Icons.chat_bubble_outline_rounded,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ChatScreen(order: liveOrder),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              if (isSyncPending || syncError != null)
                Positioned(
                  top: padding.top + 64,
                  left: 16,
                  right: 16,
                  child: _OrderSyncBanner(
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'No se pudo reintentar la sincronizacion.',
                                      ),
                                    ),
                                  );
                                });
                          },
                  ),
                ),
              DraggableScrollableSheet(
                initialChildSize: 0.38,
                minChildSize: 0.28,
                maxChildSize: 0.75,
                snap: true,
                snapSizes: const [0.38, 0.55, 0.75],
                builder: (ctx, sc) => _TrackingSheet(
                  scrollController: sc,
                  order: liveOrder,
                  statusAccent: statusAccent,
                  statusSummary: statusSummary,
                  isSearching: isSearching,
                  stages: stages,
                  activeIndex: activeIndex,
                ),
              ),
            ],
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
      case OrderStatus.cancelled:
        return 'Este pedido fue cancelado.';
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
      case OrderStatus.cancelled:
        return const Color(0xFFFF6B6B);
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

class _MapOverlayBtn extends StatelessWidget {
  const _MapOverlayBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: LavifyTheme.overlayPanelColor(context),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: LavifyTheme.navRailBorderColor(context)),
          boxShadow: LavifyTheme.panelShadow(context),
        ),
        child: Icon(
          icon,
          size: 20,
          color: LavifyTheme.textPrimaryColor(context),
        ),
      ),
    );
  }
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({
    required this.scrollController,
    required this.order,
    required this.statusAccent,
    required this.statusSummary,
    required this.isSearching,
    required this.stages,
    required this.activeIndex,
  });

  final ScrollController scrollController;
  final WashOrder order;
  final Color statusAccent;
  final String statusSummary;
  final bool isSearching;
  final List<OrderStatus> stages;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final completed = order.status == OrderStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: LavifyTheme.overlayPanelColor(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 40,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: ListView(
        controller: scrollController,
        padding: EdgeInsets.zero,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 6),
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: LavifyTheme.borderColor(context),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          // Status header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isSearching ? 'Buscando lavador' : order.status.label,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: LavifyTheme.textPrimaryColor(context),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: statusAccent.withAlpha(24),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: statusAccent.withAlpha(50)),
                      ),
                      child: Text(
                        isSearching ? 'Buscando' : order.status.label,
                        style: TextStyle(
                          color: statusAccent,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  statusSummary,
                  style: TextStyle(
                    color: LavifyTheme.textSecondaryColor(context),
                  ),
                ),
                if (order.etaMinutes > 0 && !isSearching) ...[
                  Container(
                    margin: const EdgeInsets.only(top: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusAccent.withAlpha(18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: statusAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${order.etaMinutes} min',
                          style: TextStyle(
                            color: LavifyTheme.textPrimaryColor(context),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (order.workerId != null && !isSearching) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: LavifyTheme.surfaceColor(context),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: LavifyTheme.borderColor(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: LavifyColors.primary.withAlpha(28),
                          child: const Icon(
                            Icons.person_rounded,
                            color: LavifyColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.assignedWasherName,
                                style: TextStyle(
                                  color: LavifyTheme.textPrimaryColor(context),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                order.assignedVehicleLabel,
                                style: TextStyle(
                                  color:
                                      LavifyTheme.textSecondaryColor(context),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: List.generate(
                            3,
                            (_) => const Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFC857),
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Progress section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROGRESO',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 8),
                if (isSearching)
                  const _TrackingNote(
                    title: 'Confirmada',
                    subtitle: 'Tu pedido esta en cola para asignacion.',
                  )
                else
                  for (int i = 0; i < stages.length; i++)
                    _TrackingStep(
                      title: stages[i].label,
                      completed: i <= activeIndex,
                      isLast: i == stages.length - 1,
                    ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Detail section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DETALLE',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: LavifyTheme.textSecondaryColor(context),
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: LavifyTheme.surfaceColor(context),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: LavifyTheme.borderColor(context),
                    ),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                        label: 'Paquete',
                        value: order.request.packageName,
                      ),
                      _DetailRow(
                        label: 'Vehiculo',
                        value: order.request.vehicleTypeName,
                      ),
                      _DetailRow(
                        label: 'Direccion',
                        value: order.request.address,
                      ),
                      _DetailRow(
                        label: 'Horario',
                        value: order.request.scheduleLabel,
                      ),
                      _DetailRow(
                        label: 'Total',
                        value:
                            '\$${order.request.totalPrice} ${order.request.currency}',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Review card
          if (completed && order.workerId != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: _ReviewCard(
                orderId: order.id,
                workerId: order.workerId!,
                workerName: order.assignedWasherName,
              ),
            ),

          const SizedBox(height: 24),

          // Home button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: OutlinedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              icon: const Icon(Icons.home_outlined),
              label: const Text('Volver al inicio'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
