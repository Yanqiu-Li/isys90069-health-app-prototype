import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../core/services/auth_service.dart';

class LifestyleDashboardPage extends ConsumerWidget {
  const LifestyleDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lifestyle Coaching'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress Overview Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Health Journey',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ProgressItem(
                          icon: Icons.fitness_center,
                          label: 'Exercise',
                          progress: 0.7,
                          value: '105/150',
                          unit: 'min/week',
                        ),
                        _ProgressItem(
                          icon: Icons.dining,
                          label: 'Diet',
                          progress: 0.8,
                          value: '4.2/5',
                          unit: 'g salt/day',
                        ),
                        _ProgressItem(
                          icon: Icons.bedtime,
                          label: 'Sleep',
                          progress: 0.9,
                          value: '7.2/8',
                          unit: 'hrs/night',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Actions
            Text(
              'Daily Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.quiz,
                    title: 'Daily Check-in',
                    subtitle: 'Answer questions',
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.track_changes,
                    title: 'Track Activity',
                    subtitle: 'Log exercise',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Goals Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Active Goals',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            _buildGoalCard(
              context,
              title: 'Exercise 150 minutes per week',
              progress: 0.7,
              description: '105 minutes completed this week',
              icon: Icons.fitness_center,
              color: AppTheme.secondaryColor,
            ),
            
            const SizedBox(height: 12),
            
            _buildGoalCard(
              context,
              title: 'Reduce salt intake to under 5g daily',
              progress: 0.8,
              description: 'Average 4.2g/day this week',
              icon: Icons.dining,
              color: Colors.orange,
            ),
            
            const SizedBox(height: 12),
            
            _buildGoalCard(
              context,
              title: 'Get 7-8 hours of sleep nightly',
              progress: 0.9,
              description: 'Average 7.2 hours this week',
              icon: Icons.bedtime,
              color: Colors.purple,
            ),
            
            const SizedBox(height: 24),
            
            // Weekly Challenge
            Card(
              color: AppTheme.primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.emoji_events,
                          color: Colors.amber,
                          size: 28,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Weekly Challenge',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Take a 10-minute walk after each meal',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Progress: 4/21 walks completed',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: 4/21,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Health Tips
            Text(
              'Today\'s Tips',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppTheme.secondaryColor,
                  child: Icon(Icons.lightbulb, color: Colors.white),
                ),
                title: Text('Stay hydrated throughout the day'),
                subtitle: Text('Drinking water helps maintain healthy blood pressure'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
            
            const SizedBox(height: 12),
            
            Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue,
                  child: Icon(Icons.favorite, color: Colors.white),
                ),
                title: Text('Practice deep breathing'),
                subtitle: Text('5 minutes of deep breathing can reduce stress'),
                trailing: Icon(Icons.chevron_right),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppTheme.secondaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGoalCard(
    BuildContext context, {
    required String title,
    required double progress,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final double progress;
  final String value;
  final String unit;

  const _ProgressItem({
    required this.icon,
    required this.label,
    required this.progress,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 6,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  progress >= 0.8 ? AppTheme.secondaryColor : 
                  progress >= 0.5 ? Colors.orange : Colors.red,
                ),
              ),
            ),
            Icon(
              icon,
              color: AppTheme.primaryColor,
              size: 24,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          unit,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionCard({
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
                color: AppTheme.secondaryColor,
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