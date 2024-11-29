import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectmoblie/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
// import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final String url = '${dotenv.env['BASE_URL']}:5001'; // Corrected URL with http
  bool isWaiting = false;
  bool isWaiting1 = false;
  String username = '';
  List? books = [];
  List? statusbook = [];
  List? statusbook1 = [];
  List? status = [];
  List? history = [];
  final String availability = 'avaliable';
  List? filteredBooks = [];
  String selectedCategory = 'All';
  String searchQuery = '';

  final TextEditingController searchController = TextEditingController();

  // This function filters books based on search query and category
  void filterBooks() {
    setState(() {
      filteredBooks = books?.where((book) {
        final matchesCategory =
            selectedCategory == 'All' || book['category'] == selectedCategory;
        final matchesSearch =
            book['book_name'].toLowerCase().contains(searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
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
      isWaiting = true;
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

          // เรียก fetchBooksStatus() หลังจากตั้งค่า username แล้ว
          fetchBooksStatus();
          fetchBooksReturn();
          fetchBooksHistory();
          returnBook();
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
        isWaiting = false;
      });
    }
  }

  void fetchBooksStatus() async {
    try {
      final response = await http
          .get(Uri.parse('http://${dotenv.env['BASE_URL']}:5001/status?name=$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data received: $data'); // ตรวจสอบว่าข้อมูลได้รับหรือไม่
        setState(() {
          statusbook = (data['results'] as List).map((book) {
            // เพิ่ม username ในแต่ละ book
            return {
              ...book,
              'username': username,
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

  void fetchBooksReturn() async {
    try {
      final response = await http.get(
          Uri.parse('http://${dotenv.env['BASE_URL']}:5001/status/return?name=$username'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Data received: $data'); // ตรวจสอบว่าข้อมูลได้รับหรือไม่
        setState(() {
          statusbook1 = (data['results'] as List).map((book) {
            // เพิ่ม username ในแต่ละ book
            return {
              ...book,
              'username': username,
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

  void fetchBooksHistory() async {
    try {
      final response = await http.get(
          Uri.parse(
              'http://${dotenv.env['BASE_URL']}:5001/borrower/history?username=$username'), // Adjusted the endpoint
          headers: {
            'Content-Type': 'application/json',
            'username': username
          }); // Send username in header or body if needed

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

  // Method to show the confirmation dialog
  Future<void> showConfirmReturn(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to close the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Return'),
          content: const Text('Are you sure you want to return this book?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without returning the book
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog and proceed with the return
                returnBook(); // Call the return method
              },
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

// Method to handle the return action
  void returnBook() async {
    try {
      // Prepare the body data with the username
      Map<String, String> name = {'name': username};

      // Define the URL and make the POST request with JSON-encoded body
      final response = await http.post(
        Uri.parse('http://${dotenv.env['BASE_URL']}:5001/return/borrower'),
        body: jsonEncode(name),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
      );

      // Check the server's response status code
      if (response.statusCode == 200) {
        popDialog('Success', 'Return date set successfully.');
      }
    } on TimeoutException catch (e) {
      print('Timeout error: $e');
      popDialog('Error', 'Timeout error, please try again.');
    } catch (e) {
      print('Error: $e');
      popDialog('Error', 'Unknown error, please try again.');
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

  late String availabilityStatus;
  late Color buttonColor;

  @override
  void initState() {
    super.initState();
    getbooks();
    fetchBooksStatus();
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
              Tab(icon: Icon(Icons.menu_book), text: 'Status'),
              Tab(icon: Icon(Icons.history_edu), text: 'History'),
              Tab(icon: Icon(Icons.history_sharp), text: 'Return'),
            ],
          ),
        ),
        body: Container(
          color: Colors.white,
          child: TabBarView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              style: const TextStyle(color: Colors.black),
                              decoration: InputDecoration(
                                fillColor: Colors.amber[200],
                                filled: true,
                                labelText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  searchQuery = value;
                                  filterBooks(); // [เปลี่ยน] เรียกใช้ filterBooks() ทุกครั้งที่มีการค้นหา
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                prefixIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                filled: true,
                                fillColor: Colors.amber[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                    color: Colors.amber,
                                    width: 2,
                                  ),
                                ),
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'All',
                                  child: Text('All',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: 'Sci-fi',
                                  child: Text('Sci-fi',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: 'Academic',
                                  child: Text('Academic',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: 'Fantasy',
                                  child: Text('Fantasy',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                DropdownMenuItem(
                                  value: 'Horror',
                                  child: Text('Horror',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ],
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCategory = newValue ?? 'All';
                                  filterBooks(); // [เปลี่ยน] เรียกใช้ filterBooks() ทุกครั้งที่เลือกหมวดหมู่
                                });
                              },
                              dropdownColor: Colors.white,
                              iconEnabledColor: Colors.amber[200],
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: isWaiting
                            ? Container(child: CircularProgressIndicator())
                            : GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredBooks
                                    ?.length, // [เปลี่ยน] ใช้ filteredBooks ที่ถูกกรอง
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 8.0,
                                  mainAxisSpacing: 8.0,
                                  childAspectRatio: 0.75,
                                ),
                                itemBuilder: (context, index) {
                                  var bookId = filteredBooks![index]['book_id']
                                          ?.toString() ??
                                      'No book id';
                                  var bookName = filteredBooks![index]
                                              ['book_name']
                                          ?.toString() ??
                                      'No book name';
                                  var bookDetail = filteredBooks![index]
                                              ['book_details']
                                          ?.toString() ??
                                      'No details available';
                                  var bookstatus = filteredBooks![index]
                                              ['status']
                                          ?.toString() ??
                                      'No details available';
                                  var images = filteredBooks![index]
                                              ['book_image']
                                          ?.toString() ??
                                      '';

                                  return BookCard(
                                    bookId: bookId,
                                    title: bookName,
                                    subtitle: bookDetail,
                                    availability: bookstatus,
                                    imageUrl: images,
                                    Username: username,
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Expanded(
                      child: isWaiting
                          ? const Center(child: CircularProgressIndicator())
                          : ListView.builder(
                              itemCount: statusbook?.length,
                              itemBuilder: (context, index) {
                                var bookName = statusbook?[index]['book_name']
                                        as String? ??
                                    '-';
                                var borrowdate = statusbook?[index]
                                        ['borrow_date'] as String? ??
                                    '-';
                                var returndate = statusbook?[index]
                                        ['return_date'] as String? ??
                                    '-';
                                var bookimage = statusbook?[index]['book_image']
                                        as String? ??
                                    '';
                                var status =
                                    statusbook?[index]['status'] as String? ??
                                        'Unknown';

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 255, 223, 116),
                                      borderRadius: BorderRadius.circular(45.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(19.0),
                                              child: Image.asset(
                                                bookimage,
                                                height: 180,
                                                width: 90,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 133, 215, 253),
                                                borderRadius:
                                                    BorderRadius.circular(58.0),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Book Name: $bookName", // Handle null book name
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Loen Date: $borrowdate", // Handle null loan date
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    "Return Date: $returndate", // Handle null return date
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          'Status: ',
                                                          style: TextStyle(
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.black,
                                                          ),
                                                        ),
                                                        Container(
                                                          decoration:
                                                              BoxDecoration(
                                                            color: status ==
                                                                    'Approved'
                                                                ? const Color(
                                                                    0xFF4CAF50)
                                                                : const Color(
                                                                    0xFFF44336),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                          ),
                                                          child: Text(
                                                            status, // แสดงสถานะโดยตรง
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: isWaiting
                        ? const Center(child: CircularProgressIndicator())
                        : ListView.builder(
                            itemCount: history!.length, // Use history list here
                            itemBuilder: (context, index) {
                              // Extracting data with default values
                              var historyId =
                                  history?[index]['history_id'] as int? ?? 0;
                              var bookId =
                                  history?[index]['book_id'] as int? ?? 0;
                              var borrowDate =
                                  history?[index]['borrow_date'] as String? ??
                                      '-';
                              var returnDate =
                                  history?[index]['return_date'] as String? ??
                                      '-';
                              String formatDate(String dateString) {
                                if (dateString == '-') return dateString;

                                try {
                                  DateTime dateTime =
                                      DateTime.parse(dateString);
                                  return "${dateTime.day}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
                                } catch (e) {
                                  return 'Invalid date';
                                }
                              }

                              String formattedBorrowDate =
                                  formatDate(borrowDate);
                              String formattedReturnDate =
                                  formatDate(returnDate);
                              var approverId =
                                  history?[index]['approver_id'] as int? ?? 0;
                              var approverName =
                                  history?[index]['approver_name'] as String? ??
                                      '-';
                              var staffId =
                                  history?[index]['staff_id'] as int? ?? 0;
                              var bookStatus =
                                  history?[index]['book_status'] as String? ??
                                      'Unknown';
                              var bookName =
                                  history?[index]['book_name'] as String? ??
                                      '-';
                              var bookDetails =
                                  history?[index]['book_details'] as String? ??
                                      '-';

                              return SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                          255, 177, 218, 236),
                                      borderRadius: BorderRadius.circular(45.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.3),
                                          spreadRadius: 2,
                                          blurRadius: 4,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: const Color.fromARGB(
                                                    255, 243, 243, 243),
                                                borderRadius:
                                                    BorderRadius.circular(58.0),
                                              ),
                                              padding:
                                                  const EdgeInsets.all(12.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Text(
                                                    'Book Name',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    bookName,
                                                    textAlign: TextAlign.center,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Loan date:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    formattedBorrowDate,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const Text(
                                                    'Returned date:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    formattedReturnDate,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text(
                                                          'Status: ',
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 20,
                                                          ),
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 4),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: bookStatus ==
                                                                    'borrowed'
                                                                ? const Color(
                                                                    0xFF4CAF50) // Green for borrowed
                                                                : bookStatus ==
                                                                        'pending'
                                                                    ? const Color(
                                                                        0xFFFFC107) // Amber for pending
                                                                    : const Color(
                                                                        0xFF9E9E9E), // Grey for other statuses
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        18),
                                                          ),
                                                          child: Text(
                                                            bookStatus,
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.black,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(height: 20),
                                                  const Text(
                                                    'Approved By:',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20,
                                                    ),
                                                  ),
                                                  Text(
                                                    approverName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.blue,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: isWaiting
                    ? const Center(
                        child: CircularProgressIndicator(),
                      ) // แสดงการโหลดข้อมูล
                    : ListView.builder(
                        itemCount: statusbook1?.length ?? 0,
                        itemBuilder: (context, index) {
                          var bookName =
                              statusbook1?[index]['book_name'] as String? ??
                                  '-';
                          var borrowdate =
                              statusbook1?[index]['borrow_date'] as String? ??
                                  '-';
                          var returndate =
                              statusbook1?[index]['return_date'] as String? ??
                                  '-';
                          var bookimage =
                              statusbook1?[index]['book_image'] as String? ??
                                  '';
                          var status =
                              statusbook1?[index]['status'] as String? ??
                                  'Unknown';
                          var user_name =
                              statusbook1?[index]['username'] as String? ??
                                  'Unknown';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            color: Colors.yellow[200],
                            elevation: 5,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SizedBox(height: 10),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Book cover image using asset
                                      Container(
                                        width: 125,
                                        height: 185,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            image: AssetImage(
                                                bookimage), // ใช้ AssetImage แทน Image.asset
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Container(
                                          padding: const EdgeInsets.all(8.0),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[100],
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text.rich(
                                                TextSpan(
                                                  text: 'Book Name: ',
                                                  style: const TextStyle(
                                                      fontSize: 16),
                                                  children: [
                                                    TextSpan(text: bookName),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "Borrower's name: $user_name",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "Loan date: $borrowdate",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "Returned date: $returndate",
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                              const SizedBox(height: 15),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          Colors.green,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                      ),
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 20,
                                                          vertical: 10),
                                                    ),
                                                    onPressed: () {
                                                      // Show the confirmation dialog before returning the book
                                                      showConfirmReturn(
                                                          context);
                                                    },
                                                    child: const Text(
                                                      "Return",
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}

class BookCard extends StatefulWidget {
  final String bookId;
  final String title;
  final String subtitle;
  final String availability;
  final String imageUrl;
  final String Username;

  const BookCard({
    required this.bookId,
    required this.title,
    required this.subtitle,
    required this.availability,
    required this.imageUrl,
    required this.Username,
    Key? key,
  }) : super(key: key);

  @override
  _BookCardState createState() => _BookCardState();
}

class _BookCardState extends State<BookCard> {
  late String availabilityStatus;
  late Color buttonColor;

  @override
  void initState() {
    super.initState();
    availabilityStatus = widget.availability;
    buttonColor = getColorBasedOnStatus(availabilityStatus);
  }

  Color getColorBasedOnStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'borrowed':
        return Colors.red;
      case 'approved': // เพิ่มการตรวจสอบสำหรับ 'Approved'
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void handleReserve() {
    if (availabilityStatus == 'available') {
      // ส่ง API request ไปยังเซิร์ฟเวอร์ทันทีเมื่อคลิกปุ่ม "OK"
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: const Text('Sending reservation request...'),
          actions: [
            TextButton(
              onPressed: () async {
                try {
                  // ส่ง API request เพื่อจองหนังสือ
                  final response = await http.post(
                    Uri.parse(
                        'http://${dotenv.env['BASE_URL']}:5001/request'), // URL ของ API
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                    },
                    body: jsonEncode(<String, String>{
                      'username': widget.Username, // ระบุ user_id ของคุณ
                      'book_id': widget.bookId,
                    }),
                  );

                  if (response.statusCode == 200) {
                    // ถ้าการจองสำเร็จ
                    setState(() {
                      availabilityStatus = 'pending';
                      buttonColor = getColorBasedOnStatus(availabilityStatus);
                    });

                    // ปิด dialog และแสดงการจองสำเร็จ
                    Navigator.pop(context);

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: const Text(
                            'Reserved successfully. Please return the book within 1 week.'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                MaterialPageRoute(builder: (context) => Home());
                              });

                              // Close the dialog
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('OK',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // ถ้ามีข้อผิดพลาดจาก API
                    final message = jsonDecode(response.body)['message'];
                    Navigator.pop(context); // ปิด dialog

                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        content: Text(message),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Text('OK',
                                style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );
                  }
                } catch (error) {
                  // หากเกิดข้อผิดพลาดจากเครือข่าย
                  Navigator.pop(context); // ปิด dialog

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: const Text(
                          'An error occurred. Please try again later.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Text('OK',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.pop(context), // ปิด dialog เมื่อกด Cancel
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  void showDetail() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(widget.title),
        content: Text(widget.subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
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
                  child: widget.imageUrl.isNotEmpty
                      ? Image.asset(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.image, size: 80, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
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
                        widget.bookId,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: showDetail,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text('Detail'),
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
                  widget.title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: handleReserve,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                  ),
                  child: Text(availabilityStatus),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
