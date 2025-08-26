import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class MedicationDashboardPage extends ConsumerWidget {
  const MedicationDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to medication history
            },
            icon: const Icon(Icons.history),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Adherence Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Adherence This Week',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.secondaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '92%',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _AdherenceItem(
                          label: 'Taken',
                          value: '23',
                          color: AppTheme.secondaryColor,
                        ),
                        _AdherenceItem(
                          label: 'Missed',
                          value: '2',
                          color: AppTheme.errorColor,
                        ),
                        _AdherenceItem(
                          label: 'Late',
                          value: '1',
                          color: AppTheme.warningColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.add_circle,
                    title: 'Add Medication',
                    subtitle: 'New prescription',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.qr_code_scanner,
                    title: 'Scan Barcode',
                    subtitle: 'Quick add',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Today's Medications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Schedule',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  DateTime.now().toString().substring(0, 10),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationCard(
              context,
              name: 'Lisinopril',
              dosage: '10mg',
              time: '8:00 AM',
              taken: true,
              nextTime: null,
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationCard(
              context,
              name: 'Amlodipine',
              dosage: '5mg',
              time: '2:00 PM',
              taken: false,
              nextTime: Duration(hours: 2, minutes: 30),
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationCard(
              context,
              name: 'Metoprolol',
              dosage: '25mg',
              time: '8:00 PM',
              taken: false,
              nextTime: Duration(hours: 8, minutes: 30),
            ),
            
            const SizedBox(height: 24),
            
            // Active Medications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Medications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationListCard(
              context,
              name: 'Lisinopril (ACE Inhibitor)',
              dosage: '10mg once daily',
              refills: 2,
              lastTaken: 'This morning',
              color: AppTheme.primaryColor,
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationListCard(
              context,
              name: 'Amlodipine (Calcium Channel Blocker)',
              dosage: '5mg once daily',
              refills: 1,
              lastTaken: 'Yesterday',
              color: Colors.blue,
            ),
            
            const SizedBox(height: 12),
            
            _buildMedicationListCard(
              context,
              name: 'Metoprolol (Beta Blocker)',
              dosage: '25mg twice daily',
              refills: 3,
              lastTaken: 'This morning',
              color: Colors.green,
            ),
            
            const SizedBox(height: 24),
            
            // Side Effects Tracking
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Side Effects Tracker',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Log any side effects you experience to help your healthcare provider.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Report Side Effect'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMedicationCard(
    BuildContext context, {
    required String name,
    required String dosage,
    required String time,
    required bool taken,
    Duration? nextTime,
  }) {
    final statusColor = taken ? AppTheme.secondaryColor : AppTheme.primaryColor;
    final statusText = taken ? 'Taken' : 'Scheduled';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                taken ? Icons.check_circle : Icons.schedule,
                color: statusColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name $dosage',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Scheduled for $time',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  if (nextTime != null && !taken) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Due in ${nextTime.inHours}h ${nextTime.inMinutes % 60}m',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationListCard(
    BuildContext context, {
    required String name,
    required String dosage,
    required int refills,
    required String lastTaken,
    required Color color,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.medication,
            color: color,
            size: 24,
          ),
        ),
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dosage),
            Text(
              'Last taken: $lastTaken • $refills refills left',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}

class _AdherenceItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AdherenceItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}