import 'package:flutter/material.dart';
import 'package:projectmoblie/screens/staff/tabs/history_tab.dart';
import 'package:projectmoblie/screens/staff/tabs/dashboard_tab.dart';
import 'package:projectmoblie/screens/staff/tabs/edit_tab.dart';
import 'package:projectmoblie/screens/staff/tabs/home_tab.dart';

import 'tabs/return_tab.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  StaffState createState() => StaffState();
}

class StaffState extends State<Staff> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Sky Borrow Book',
            style: TextStyle(
              color: Colors.amber[400],
            ),
          ),
          backgroundColor: Colors.blue[300],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.red[300],
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        bottomNavigationBar: Container(
          color: Colors.blue[200],
          child: const TabBar(
            labelColor: Colors.black87,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home'),
              Tab(icon: Icon(Icons.edit), text: 'Edit'),
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.history_edu), text: 'History'),
              Tab(icon: Icon(Icons.history_sharp), text: 'Return'),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              HomeTab(),
              EditTab(),
              DashboardTab(),
              HistoryTab(),
              ReturnTab(),
            ],
          ),
        ),
      ),
    );
  }
}