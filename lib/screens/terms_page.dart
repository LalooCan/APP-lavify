import 'package:flutter/material.dart';

import '../theme/theme.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: LavifyTheme.pageDecoration(context),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.transparent,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                title: Text(
                  'Términos y condiciones',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Section(
                      title: '1. Uso del servicio',
                      body:
                          'Lavify es una plataforma que conecta clientes con lavadores de autos a domicilio. Al usar la app, aceptas que el servicio se presta en la ubicación que indiques y en el horario seleccionado.\n\nLavify actúa como intermediario. La relación de servicio es directamente entre el cliente y el lavador asignado.',
                    ),
                    _Section(
                      title: '2. Responsabilidades del cliente',
                      body:
                          '• Proporcionar una dirección válida y accesible.\n• Asegurarte de que el vehículo esté disponible en el horario seleccionado.\n• Realizar el pago acordado al momento de la solicitud o al finalizar el servicio, según el método elegido.',
                    ),
                    _Section(
                      title: '3. Responsabilidades del lavador',
                      body:
                          '• Presentarse en el horario acordado.\n• Realizar el servicio con los materiales adecuados.\n• Tratar el vehículo con cuidado y profesionalismo.\n• Reportar cualquier daño preexistente antes de iniciar el servicio.',
                    ),
                    _Section(
                      title: '4. Cancelaciones',
                      body:
                          'Los clientes pueden cancelar su pedido mientras está en estado "Buscando lavador" o "Lavador asignado" sin cargo. Cancelaciones posteriores pueden generar un cargo del 50% del servicio.\n\nLos lavadores pueden cancelar únicamente en estado "Lavador asignado". Cancelaciones frecuentes pueden resultar en suspensión de cuenta.',
                    ),
                    _Section(
                      title: '5. Pagos',
                      body:
                          'Los precios mostrados incluyen el costo del servicio y la tarifa de desplazamiento cuando aplica. El pago puede realizarse en efectivo, tarjeta u otros métodos disponibles en la app.\n\nLavify retiene una comisión del 12.5% sobre cada servicio completado.',
                    ),
                    _Section(
                      title: '6. Modificaciones',
                      body:
                          'Lavify se reserva el derecho de modificar estos términos en cualquier momento. Los cambios se notificarán a través de la app. El uso continuado de la plataforma implica la aceptación de los términos vigentes.',
                    ),
                    _Section(
                      title: '7. Contacto',
                      body:
                          'Para dudas o reportes, escríbenos a soporte@lavify.app. Respondemos en un plazo máximo de 48 horas hábiles.',
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Última actualización: abril 2025',
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
