import 'package:flutter/material.dart';

import 'home_page.dart';
import 'orders_page.dart';
import 'profile_hub_page.dart';
import 'worker_home_page.dart';
import 'worker_jobs_page.dart';

enum AppMode { client, worker }

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.mode});

  final AppMode mode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = widget.mode == AppMode.client
        ? <Widget>[
            const HomePage(),
            const OrdersPage(),
            const ProfileHubPage(mode: AppMode.client),
          ]
        : <Widget>[
            const WorkerHomePage(),
            const WorkerJobsPage(),
            const ProfileHubPage(mode: AppMode.worker),
          ];

    final destinations = widget.mode == AppMode.client
        ? const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded),
              label: 'Pedidos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'Perfil',
            ),
          ]
        : const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded),
              label: 'Panel',
            ),
            NavigationDestination(
              icon: Icon(Icons.local_car_wash_outlined),
              selectedIcon: Icon(Icons.local_car_wash_rounded),
              label: 'Servicios',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Config',
            ),
          ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: destinations,
      ),
    );
  }
}
