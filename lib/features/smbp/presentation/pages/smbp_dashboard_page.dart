import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class SMBPDashboardPage extends ConsumerWidget {
  const SMBPDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blood Pressure'),
        actions: [
          IconButton(
            onPressed: () {
              // Navigate to settings or profile
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back, ${user?.name ?? 'Patient'}!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s check your blood pressure readings.',
                      style: Theme.of(context).textTheme.bodyMedium,
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
                    title: 'New Reading',
                    subtitle: 'Record BP',
                    onTap: () {
                      // Navigate to new reading page
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.bluetooth,
                    title: 'Connect Device',
                    subtitle: 'Pair BP Monitor',
                    onTap: () {
                      // Navigate to device pairing
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Latest Readings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Readings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to all readings
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Mock recent readings
            _buildMockReadingCard(
              context,
              systolic: 128,
              diastolic: 82,
              timestamp: DateTime.now().subtract(const Duration(hours: 2)),
              category: 'Normal',
            ),
            
            const SizedBox(height: 12),
            
            _buildMockReadingCard(
              context,
              systolic: 135,
              diastolic: 88,
              timestamp: DateTime.now().subtract(const Duration(days: 1)),
              category: 'Elevated',
            ),
            
            const SizedBox(height: 12),
            
            _buildMockReadingCard(
              context,
              systolic: 122,
              diastolic: 79,
              timestamp: DateTime.now().subtract(const Duration(days: 2)),
              category: 'Normal',
            ),
            
            const SizedBox(height: 24),
            
            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weekly Average',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Systolic',
                          value: '128',
                          unit: 'mmHg',
                          color: AppTheme.normalBPColor,
                        ),
                        _StatItem(
                          label: 'Diastolic',
                          value: '83',
                          unit: 'mmHg',
                          color: AppTheme.normalBPColor,
                        ),
                        _StatItem(
                          label: 'Readings',
                          value: '14',
                          unit: 'this week',
                          color: AppTheme.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to new reading page
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildMockReadingCard(
    BuildContext context, {
    required int systolic,
    required int diastolic,
    required DateTime timestamp,
    required String category,
  }) {
    final color = AppTheme.getBloodPressureColor(systolic.toDouble(), diastolic.toDouble());
    final icon = AppTheme.getBloodPressureIcon(systolic.toDouble(), diastolic.toDouble());

    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          color: color,
          size: 32,
        ),
        title: Text(
          '$systolic/$diastolic mmHg',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '$category • ${_formatTimestamp(timestamp)}',
          style: TextStyle(color: color),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to reading details
        },
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
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
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}