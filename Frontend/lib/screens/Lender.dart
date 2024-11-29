import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:projectmoblie/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import 'lender/tabs/DashboardTab.dart';
import 'lender/tabs/HistoryTab.dart';
import 'lender/tabs/HomeTab.dart';
import 'lender/tabs/RequestTab.dart';

class Lender extends StatefulWidget {
  const Lender({super.key});

  @override
  State<Lender> createState() => _LenderState();
}

class _LenderState extends State<Lender> {
  final String url = '${dotenv.env['BASE_URL']}:5001';
  List<dynamic> books = [];
  List<dynamic> filteredBooks = [];
  Map<String, dynamic>? dashboardData;
  String selectedCategory = 'All';
  String searchQuery = '';
  bool isLoading = false;
  String username = '';
  List? history = [];
  List<dynamic> requests = [];

  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
    getbooks();
    fetchBooksHistory();
    fetchRequests();
  }

  void popDialog(String title, String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        });
  }

  void getbooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      // get JWT token from local storage
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        // no token, jump to login page
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        // token found
        // decode JWT to get username and role
        final jwt = JWT.decode(token);
        Map payload = jwt.payload;

        // get books
        Uri uri = Uri.http(url, '/books');
        http.Response response =
            await http.get(uri, headers: {'authorization': token}).timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200) {
          setState(() {
            books = jsonDecode(response.body);
            username = payload['username'];
          });
        } else {
          popDialog('Error', response.body);
        }
      }
    } on TimeoutException catch (e) {
      debugPrint(e.message);
      popDialog('Error', 'Timeout error, try again!');
    } catch (e) {
      debugPrint(e.toString());
      popDialog('Error', 'Unknown error, try again!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      Uri uri = Uri.http(url, '/dashboard');
      http.Response response =
          await http.get(uri, headers: {'authorization': token}).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        setState(() {
          dashboardData = jsonDecode(response.body)['dashboard'];
        });
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      print('Error fetching dashboard data: \$e');
    }
  }

  void filterBooks() {
    setState(() {
      filteredBooks = books.where((book) {
        final matchesCategory =
            selectedCategory == 'All' || book['category'] == selectedCategory;
        final matchesSearch = book['book_name']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Login()),
        );
      } else {
        Uri uri = Uri.http(url, '/request/Lender');
        http.Response response =
            await http.get(uri, headers: {'authorization': token}).timeout(
          const Duration(seconds: 10),
        );

        if (response.statusCode == 200) {
          setState(() {
            requests = jsonDecode(response.body); // Extract the results field
          });
        } else {
          throw Exception('Failed to load requests');
        }
      }
    } catch (e) {
      debugPrint(e.toString());
      popDialog('Error', 'Unknown error, try again!');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> approveRequest(int historyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      // Decode JWT to get username
      final jwt = JWT.decode(token);
      final username = jwt.payload['username'];

      Uri uri = Uri.http(url, '/approve/lender/$historyId');
      http.Response response = await http
          .post(
            uri,
            headers: {
              'authorization': token,
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'approver_id': username, // Use decoded username here
            }),
          )
          .timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        fetchRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request approved successfully!')),
        );
      } else {
        throw Exception('Failed to approve request');
      }
    } catch (e) {
      print('Error approving request: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error approving request')),
      );
    }
  }

  Future<void> disapproveRequest(int historyId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('No token found');
      }

      Uri uri = Uri.http(url, '/disapprove/lender/$historyId');
      http.Response response = await http.post(uri, headers: {
        'authorization': token,
        'Content-Type': 'application/json'
      }).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        fetchRequests();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request disapproved successfully!')),
        );
      } else {
        throw Exception('Failed to disapprove request');
      }
    } catch (e) {
      print('Error disapproving request: \$e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error disapproving request')),
      );
    }
  }

  void confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sure to logout?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: logout,
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void logout() async {
    // remove stored token
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // to prevent warning of using context in async function
    if (!mounted) return;
    // Cannot use only pushReplacement() because the dialog is showing
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false,
    );
  }

  void fetchBooksHistory() async {
    try {
      Uri uri = Uri.http(url, '/Allhistory');
      http.Response response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      }).timeout(
        const Duration(seconds: 10),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data received: $data'); // ตรวจสอบว่าข้อมูลได้รับหรือไม่
        setState(() {
          // Ensure that 'history' is present in the response
          history = (data['history'] as List).map((book) {
            return {
              ...book,
              'username': username, // Add the username to each book
            };
          }).toList(); // อัปเดตตัวแปรที่ใช้แสดงข้อมูล
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Sky Borrow Book',
            style: TextStyle(color: Colors.amber[400]),
          ),
          backgroundColor: Colors.blue[300],
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              color: Colors.red[300],
              onPressed: () {
                confirmLogout();
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
              Tab(icon: Icon(Icons.history_edu), text: 'History'),
              Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
              Tab(icon: Icon(Icons.find_in_page), text: 'Request'),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Container(
                color: Colors.white,
                child: TabBarView(
                  children: [
                    HomeTab(
                      books: books,
                      filteredBooks: filteredBooks,
                      selectedCategory: selectedCategory,
                      searchQuery: searchQuery,
                      searchController: searchController,
                      onSearch: (value) {
                        setState(() {
                          searchQuery = value;
                          filterBooks();
                        });
                      },
                      onCategoryChange: (value) {
                        setState(() {
                          selectedCategory = value ?? 'All';
                          filterBooks();
                        });
                      },
                    ),
                    HistoryTab(history: history),
                    DashboardTab(dashboardData: dashboardData),
                    RequestTab(
                      requests: requests,
                      onApprove: approveRequest,
                      onDisapprove: disapproveRequest,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String bookId;
  final String title;
  final String subtitle;
  final String status;
  final String imageUrl;

  const BookCard({
    required this.bookId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.imageUrl,
    Key? key,
  }) : super(key: key);

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'borrowed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[300],
                  ),
                  child: imageUrl.isNotEmpty
                      ? Image.asset(imageUrl, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 80, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Book ID',
                      style: TextStyle(color: Colors.blue),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bookId,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => showDetail(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: const Text('Detail'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getStatusColor(),
                  ),
                  child: Text(
                    status,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int value;
  final Color color;

  const DashboardCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(width: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  value.toString(),
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// class LenderRequestPage extends StatefulWidget {
//   const LenderRequestPage({Key? key}) : super(key: key);

//   @override
//   _LenderRequestPageState createState() => _LenderRequestPageState();
// }

// class _LenderRequestPageState extends State<LenderRequestPage> {
//   final String url = 'http://${dotenv.env['BASE_URL']}:5001';
//   List<dynamic> requests = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     fetchRequests();
//   }

//   Future<void> fetchRequests() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');

//       if (token == null) {
//         throw Exception('No token found');
//       }

//       Uri uri = Uri.http(url, '/request/Lender');
//       http.Response response = await http.get(uri, headers: {
//         'authorization': token,
//         'Content-Type': 'application/json'
//       }).timeout(
//         const Duration(seconds: 10),
//       );

//       if (response.statusCode == 200) {
//         setState(() {
//           requests = jsonDecode(response.body);
//         });
//       } else {
//         throw Exception('Failed to load requests');
//       }
//     } catch (e) {
//       print('Error fetching requests: \$e');
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

  // Future<void> approveRequest(int historyId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //     if (token == null) {
  //       throw Exception('No token found');
  //     }

  //     Uri uri = Uri.http(url, '/approve/lender/$historyId');
  //     http.Response response = await http.post(uri, headers: {
  //       'authorization': token,
  //       'Content-Type': 'application/json'
  //     }).timeout(
  //       const Duration(seconds: 10),
  //     );

  //     if (response.statusCode == 200) {
  //       fetchRequests();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Request approved successfully!')),
  //       );
  //     } else {
  //       throw Exception('Failed to approve request');
  //     }
  //   } catch (e) {
  //     print('Error approving request: \$e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Error approving request')),
  //     );
  //   }
  // }

  // Future<void> disapproveRequest(int historyId) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final token = prefs.getString('token');

  //     if (token == null) {
  //       throw Exception('No token found');
  //     }

  //     Uri uri = Uri.http(url, '/disapprove/lender/$historyId');
  //     http.Response response = await http.post(uri, headers: {
  //       'authorization': token,
  //       'Content-Type': 'application/json'
  //     }).timeout(
  //       const Duration(seconds: 10),
  //     );

  //     if (response.statusCode == 200) {
  //       fetchRequests();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Request disapproved successfully!')),
  //       );
  //     } else {
  //       throw Exception('Failed to disapprove request');
  //     }
  //   } catch (e) {
  //     print('Error disapproving request: \$e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text('Error disapproving request')),
  //     );
  //   }
  // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Borrower Requests'),
//         backgroundColor: Colors.blue[300],
//       ),
//     );
//   }
// }
