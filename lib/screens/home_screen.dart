import 'package:flutter/material.dart';

import 'emergencies_screen.dart';
import 'labor_analgesia_screen.dart';
import 'risk_safety_screen.dart';
import 'spinal_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int index = 0;

  static const pages = <Widget>[
    SpinalScreen(),
    LaborAnalgesiaScreen(),
    RiskSafetyScreen(),
    EmergenciesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(index: index, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: index,
          height: 68,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          onDestinationSelected: (value) => setState(() => index = value),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.medication_liquid_outlined),
              selectedIcon: Icon(Icons.medication_liquid),
              label: 'Raqui',
            ),
            NavigationDestination(
              icon: Icon(Icons.timeline_outlined),
              selectedIcon: Icon(Icons.timeline),
              label: 'Parto',
            ),
            NavigationDestination(
              icon: Icon(Icons.health_and_safety_outlined),
              selectedIcon: Icon(Icons.health_and_safety),
              label: 'Segurança',
            ),
            NavigationDestination(
              icon: Icon(Icons.emergency_outlined),
              selectedIcon: Icon(Icons.emergency),
              label: 'Emergências',
            ),
          ],
        ),
      ),
    );
  }
}
