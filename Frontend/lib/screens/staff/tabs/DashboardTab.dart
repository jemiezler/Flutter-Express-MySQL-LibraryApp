import 'dart:async';

import 'package:flutter/material.dart';
import '../../../utils/ApiService.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  final ApiService apiService = ApiService(); // API service instance
  Map<String, dynamic> dashboardData = {}; // To store the fetched data
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final response = await apiService.get('/dashboard');
      setState(() {
        dashboardData = response['dashboard'];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : dashboardData.isEmpty
              ? const Center(child: Text('No dashboard data available'))
              : Container(
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CurrentTimeDisplay(),
                      _buildStatCard(
                        icon: Icons.check_circle,
                        title: 'Available Books',
                        count: dashboardData['available'] ?? 0,
                        color: Colors.green[200],
                      ),
                      _buildStatCard(
                        icon: Icons.pending,
                        title: 'Pending Books',
                        count: dashboardData['pending'] ?? 0,
                        color: Colors.orange[200],
                      ),
                      _buildStatCard(
                        icon: Icons.import_export,
                        title: 'Borrowed Books',
                        count: dashboardData['borrowed'] ?? 0,
                        color: Colors.blue[200],
                      ),
                      _buildStatCard(
                        icon: Icons.block,
                        title: 'Disabled Books',
                        count: dashboardData['disabled'] ?? 0,
                        color: Colors.red[200],
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required int count,
    required Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(icon, size: 50, color: Colors.black),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '$count',
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CurrentTimeDisplay extends StatefulWidget {
  const CurrentTimeDisplay({Key? key}) : super(key: key);

  @override
  _CurrentTimeDisplayState createState() => _CurrentTimeDisplayState();
}

class _CurrentTimeDisplayState extends State<CurrentTimeDisplay> {
  late String currentTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const Text(
            'Current Time',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            currentTime,
            style: const TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
