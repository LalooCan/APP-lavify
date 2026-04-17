import 'package:flutter/material.dart';

import 'package:lavify_app/models/session_models.dart';
import 'package:lavify_app/screens/home_page.dart';
import 'package:lavify_app/screens/orders_page.dart';
import 'package:lavify_app/screens/profile_hub_page.dart';
import 'package:lavify_app/screens/worker_dashboard_page.dart';
import 'package:lavify_app/screens/worker_services_page.dart';
import 'package:lavify_app/theme/theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.mode});

  final AppRole mode;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  bool _isSidebarExpanded = false;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1024;

    final pages = widget.mode == AppRole.client
        ? <Widget>[
            const HomePage(),
            const OrdersPage(),
            const ProfileHubPage(mode: AppRole.client),
          ]
        : <Widget>[
            const WorkerDashboardPage(),
            const WorkerServicesPage(),
            const ProfileHubPage(mode: AppRole.worker),
          ];

    final destinations = widget.mode == AppRole.client
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

    if (isDesktop) {
      final isWideDesktop = width >= 1440;
      final isExpanded = isWideDesktop || _isSidebarExpanded;

      return Scaffold(
        body: Row(
          children: [
            MouseRegion(
              onEnter: (_) {
                if (!isWideDesktop) {
                  setState(() {
                    _isSidebarExpanded = true;
                  });
                }
              },
              onExit: (_) {
                if (!isWideDesktop) {
                  setState(() {
                    _isSidebarExpanded = false;
                  });
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: isExpanded ? 176 : 78,
                decoration: BoxDecoration(
                  color: LavifyTheme.navRailColor(context),
                  boxShadow: LavifyTheme.panelShadow(context, floating: false),
                  border: Border(
                    right: BorderSide(
                      color: LavifyTheme.navRailBorderColor(context),
                    ),
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                    child: Column(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 220),
                          alignment: isExpanded
                              ? Alignment.centerLeft
                              : Alignment.center,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [
                                  LavifyColors.primaryStrong,
                                  LavifyColors.primary,
                                ],
                              ),
                              boxShadow: LavifyTheme.panelShadow(
                                context,
                                floating: false,
                              ),
                            ),
                            child: const Icon(
                              Icons.water_drop_rounded,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: isExpanded
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 12),
                                  child: Text(
                                    'Lavify',
                                    style: TextStyle(
                                      color: LavifyTheme.textPrimaryColor(
                                        context,
                                      ),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 22),
                        Expanded(
                          child: Column(
                            children: List.generate(destinations.length, (
                              index,
                            ) {
                              final destination = destinations[index];
                              final isSelected = index == _selectedIndex;

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: _SidebarDestination(
                                  icon: isSelected
                                      ? (destination.selectedIcon ??
                                            destination.icon)
                                      : destination.icon,
                                  label: destination.label,
                                  selected: isSelected,
                                  expanded: isExpanded,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = index;
                                    });
                                  },
                                ),
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      );
    }

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        decoration: BoxDecoration(
          color: LavifyTheme.navRailColor(context),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: LavifyTheme.navRailBorderColor(context)),
          boxShadow: LavifyTheme.panelShadow(context, floating: false),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            backgroundColor: Colors.transparent,
            destinations: destinations,
          ),
        ),
      ),
    );
  }
}

class _SidebarDestination extends StatelessWidget {
  const _SidebarDestination({
    required this.icon,
    required this.label,
    required this.selected,
    required this.expanded,
    required this.onTap,
  });

  final Widget icon;
  final String label;
  final bool selected;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 52,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 12 : 0),
          decoration: BoxDecoration(
            color: selected
                ? LavifyTheme.navSelectedColor(context)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisAlignment: expanded
                ? MainAxisAlignment.start
                : MainAxisAlignment.center,
            children: [
              IconTheme(
                data: IconThemeData(
                  color: selected
                      ? LavifyTheme.textPrimaryColor(context)
                      : LavifyTheme.navInactiveColor(context),
                  size: 24,
                ),
                child: icon,
              ),
              if (expanded) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? LavifyTheme.textPrimaryColor(context)
                          : LavifyTheme.navInactiveColor(context),
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
