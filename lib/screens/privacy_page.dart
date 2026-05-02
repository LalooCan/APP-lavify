import 'package:flutter/material.dart';

import '../theme/theme.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

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
                  'Política de privacidad',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _Section(
                      title: '1. Datos que recopilamos',
                      body:
                          '• Nombre y correo electrónico (al registrarte).\n• Foto de perfil (opcional).\n• Ubicación GPS (solo al solicitar un servicio o durante el tracking activo).\n• Historial de pedidos y calificaciones.\n• Token de notificaciones push (para enviarte alertas del servicio).',
                    ),
                    _Section(
                      title: '2. Cómo usamos tus datos',
                      body:
                          '• Para conectarte con lavadores disponibles en tu zona.\n• Para mostrar el seguimiento en tiempo real de tu servicio.\n• Para enviarte notificaciones sobre el estado de tu pedido.\n• Para calcular comisiones y ganancias de los lavadores.\n• Para mejorar la calidad del servicio a través de métricas agregadas y anónimas.',
                    ),
                    _Section(
                      title: '3. Uso del GPS',
                      body:
                          'La ubicación de tu dispositivo se solicita únicamente cuando:\n• Completas el campo de dirección en un pedido.\n• Hay un servicio activo (para el mapa de seguimiento).\n\nNunca almacenamos tu ubicación en segundo plano ni fuera de una sesión de servicio activa.',
                    ),
                    _Section(
                      title: '4. Con quién compartimos tus datos',
                      body:
                          '• Con el lavador asignado a tu pedido (nombre y dirección del servicio).\n• Con Firebase (Google) como proveedor de backend, bajo sus propias políticas de privacidad.\n• No vendemos ni compartimos tu información con terceros para fines publicitarios.',
                    ),
                    _Section(
                      title: '5. Tus derechos',
                      body:
                          '• Puedes solicitar la eliminación de tu cuenta y datos en cualquier momento escribiendo a soporte@lavify.app.\n• Puedes revocar el permiso de ubicación desde Configuración > Lavify en cualquier momento.\n• Tus datos se eliminan permanentemente dentro de los 30 días posteriores a la solicitud.',
                    ),
                    _Section(
                      title: '6. Seguridad',
                      body:
                          'Todos los datos se transmiten cifrados mediante HTTPS. El acceso a Firestore está protegido por reglas de seguridad que impiden que un usuario acceda a datos de otro usuario.',
                    ),
                    _Section(
                      title: '7. Contacto',
                      body:
                          'Para ejercer tus derechos o reportar un problema de privacidad, escríbenos a privacidad@lavify.app.',
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
