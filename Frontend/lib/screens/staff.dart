import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectmoblie/screens/staff/tabs/HistoryTab.dart';
import 'package:projectmoblie/screens/staff/tabs/DashboardTab.dart';
import 'package:projectmoblie/screens/staff/tabs/EditTab.dart';
import 'dart:async';

import 'package:projectmoblie/screens/staff/tabs/HomeTab.dart';

import 'staff/tabs/ReturnTab.dart';

class Staff extends StatefulWidget {
  const Staff({super.key});

  @override
  _StaffState createState() => _StaffState();
}

class _StaffState extends State<Staff> {
  String? selectedStatus = 'Available'; // Default value
  final List<String> statuses = ['Available', 'Borrow', 'Pending', 'Disable'];
  String NameBook = 'Harrypotter';
  String DetailBook = 'Harry Potter And\nThe Philosopher\'s Stone';
  String currentTitle = '';
  String currentDetail = '';
  String? selectedGenre;
  String? editedTitle;
  String? editedDetail;
  int currentIndex = 1;
  TextEditingController _controller = TextEditingController();
  final List books = [
    {
      'name': 'Harry Potter 5 (Harry Poter And The Order of The Phonemix)',
      'Borrower Name ': 'Jannie Kim',
      'loanDate': '22/10/2567',
      'returnDate': '27/10/2567',
      'image': 'harrypotter3.jpg',
      'status': 'return',
      'approvedby': 'Lalisa Manoban',
      'Asset back to': 'Kim Jisoo'
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green; // สีเขียว
      case 'Disable':
        return Colors.grey; // สีเทา
      case 'Pending':
        return Colors.amber; // สีเหลือง
      case 'Borrow':
        return Colors.red; // สีแดง
      default:
        return Colors.green; // ค่าเริ่มต้น
    }
  }

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
              // Center(
              //   child: Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: Card(
              //       shape: RoundedRectangleBorder(
              //         borderRadius: BorderRadius.circular(20.0),
              //       ),
              //       color: Colors.yellow[200],
              //       elevation: 5,
              //       child: Padding(
              //         padding: const EdgeInsets.all(16.0),
              //         child: Column(
              //           mainAxisSize: MainAxisSize.min,
              //           children: [
              //             Text(
              //               "22/10/2567", // Example date (Thai Buddhist calendar)
              //               style: const TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.bold,
              //               ),
              //             ),
              //             const SizedBox(height: 10),
              //             Row(
              //               children: [
              //                 // Book cover image using asset
              //                 Container(
              //                   width: 125,
              //                   height: 175,
              //                   decoration: BoxDecoration(
              //                     borderRadius: BorderRadius.circular(10),
              //                     image: const DecorationImage(
              //                       image: AssetImage(
              //                           'assets/images/harrypotter1.jpg'), // Local asset image
              //                       fit: BoxFit.cover,
              //                     ),
              //                   ),
              //                 ),
              //                 const SizedBox(width: 10),
              //                 // Book details section
              //                 Expanded(
              //                   child: Container(
              //                     padding: const EdgeInsets.all(8.0),
              //                     decoration: BoxDecoration(
              //                       color: Colors.blue[100],
              //                       borderRadius: BorderRadius.circular(10),
              //                     ),
              //                     child: Column(
              //                       crossAxisAlignment:
              //                           CrossAxisAlignment.start,
              //                       children: [
              //                         Text.rich(
              //                           TextSpan(
              //                             text: 'Book Name: ',
              //                             style: const TextStyle(fontSize: 16),
              //                             children: [
              //                               TextSpan(
              //                                 text: 'Harry Potter 7',
              //                                 style: const TextStyle(),
              //                               ),
              //                             ],
              //                           ),
              //                         ),
              //                         const SizedBox(height: 5),
              //                         const Text(
              //                           "Borrower's name: Jennie Kim",
              //                           style: TextStyle(fontSize: 16),
              //                         ),
              //                         const SizedBox(height: 5),
              //                         const Text(
              //                           "Loan date: 22/10/2567",
              //                           style: TextStyle(fontSize: 16),
              //                         ),
              //                         const SizedBox(height: 5),
              //                         const Text(
              //                           "Returned date: 27/10/2567",
              //                           style: TextStyle(fontSize: 16),
              //                         ),
              //                         const SizedBox(height: 15),
              //                         Row(
              //                           mainAxisAlignment:
              //                               MainAxisAlignment.spaceEvenly,
              //                           children: [
              //                             ElevatedButton(
              //                               style: ElevatedButton.styleFrom(
              //                                 backgroundColor: Colors.green,
              //                                 shape: RoundedRectangleBorder(
              //                                   borderRadius:
              //                                       BorderRadius.circular(10),
              //                                 ),
              //                                 padding:
              //                                     const EdgeInsets.symmetric(
              //                                         horizontal: 20,
              //                                         vertical: 10),
              //                               ),
              //                               onPressed: () {
              //                                 // Handle approve action
              //                               },
              //                               child: const Text(
              //                                 "Return",
              //                                 style: TextStyle(
              //                                     color: Colors.white,
              //                                     fontSize: 16),
              //                               ),
              //                             )
              //                           ],
              //                         ),
              //                       ],
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ],
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            
            ],
          ),
        ),
      ),
    );
  }
}