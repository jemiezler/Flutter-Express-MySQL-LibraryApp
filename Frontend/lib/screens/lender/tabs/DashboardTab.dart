import 'package:flutter/material.dart';

import '../components/DashboardCard.dart';

class DashboardTab extends StatelessWidget {
  final Map<String, dynamic>? dashboardData;

  const DashboardTab({required this.dashboardData, super.key});

  @override
  Widget build(BuildContext context) {
    return dashboardData == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
            children: [
              DashboardCard(
                icon: Icons.check_circle,
                title: 'Available Books',
                value: dashboardData!['available'] ?? 0,
                color: Colors.green,
              ),
              DashboardCard(
                icon: Icons.import_export,
                title: 'Borrowed Books',
                value: dashboardData!['borrowed'] ?? 0,
                color: Colors.blue,
              ),
              DashboardCard(
                icon: Icons.pending,
                title: 'Pending Books',
                value: dashboardData!['pending'] ?? 0,
                color: Colors.orange,
              ),
              DashboardCard(
                icon: Icons.block,
                title: 'Disabled Books',
                value: dashboardData!['disabled'] ?? 0,
                color: Colors.red,
              ),
            ],
          );
  }
}
