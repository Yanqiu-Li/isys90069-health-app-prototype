import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'smbp/presentation/pages/smbp_dashboard_page.dart';
import 'lifestyle/presentation/pages/lifestyle_dashboard_page.dart';
import 'medication/presentation/pages/medication_dashboard_page.dart';
import 'assistant/presentation/pages/assistant_page.dart';
import '../shared/themes/app_theme.dart';

final selectedIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    final pages = [
      const SMBPDashboardPage(),
      const LifestyleDashboardPage(),
      const MedicationDashboardPage(),
      const AssistantPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: selectedIndex,
        onTap: (index) => ref.read(selectedIndexProvider.notifier).state = index,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'Blood Pressure',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Lifestyle',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            activeIcon: Icon(Icons.medication),
            label: 'Medications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assistant),
            activeIcon: Icon(Icons.assistant),
            label: 'Assistant',
          ),
        ],
      ),
    );
  }
}