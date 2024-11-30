import 'package:flutter/material.dart';
import '../../../utils/ApiService.dart';
import '../../../utils/DateHelpers.dart';

class ReturnTab extends StatefulWidget {
  const ReturnTab({super.key});

  @override
  ReturnTabState createState() => ReturnTabState();
}

class ReturnTabState extends State<ReturnTab> {
  final ApiService apiService = ApiService(); // Initialize ApiService
  List<dynamic> returnedBooks = []; // List to hold returned books
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchReturnedBooks(); // Fetch books on widget initialization
  }

  // Fetch books with `returned` status from the API
  Future<void> fetchReturnedBooks() async {
    setState(() {
      isLoading = true;
    });
    try {
      final data = await apiService.get('/history?status=returned');
      setState(() {
        returnedBooks = data;
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching returned books: $error');
    }
  }

  // Handle accepting a return
  void acceptReturn(BuildContext context, String historyId) async {
    try {
      await apiService.patch('/history/$historyId/staff', body: {
        'dateTime': DateTime.now().toIso8601String(), // Current date and time
      });

      // Show success feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Return accepted successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );

      await fetchReturnedBooks(); // Refresh data after accepting return
    } catch (error) {
      // Show error feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to accept return.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: fetchReturnedBooks, // Attach refresh logic
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : returnedBooks.isEmpty
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Container(
                    alignment: Alignment.center,
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: const Text(
                      "No returned books available",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: returnedBooks.length,
                  itemBuilder: (context, index) {
                    final book = returnedBooks[index];
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Card(
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
                              Text(
                                DateHelpers.formatDate(book['borrow_date']),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  // Book cover image using network
                                  Container(
                                    width: 125,
                                    height: 175,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          book['book_image'] ??
                                              'https://via.placeholder.com/125x175',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  // Book details section
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[100],
                                        borderRadius: BorderRadius.circular(10),
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
                                                TextSpan(
                                                  text: book['book_name'] ?? '-',
                                                  style: const TextStyle(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Borrower's name: ${book['borrower_name'] ?? '-'}",
                                            style: const TextStyle(
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Loan date: ${DateHelpers.formatDate(book['borrow_date'])}",
                                            style: const TextStyle(
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            "Returned date: ${DateHelpers.formatDate(book['return_date'])}",
                                            style: const TextStyle(
                                                fontSize: 16),
                                          ),
                                          const SizedBox(height: 15),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.green,
                                                  shape:
                                                      RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 20,
                                                    vertical: 10,
                                                  ),
                                                ),
                                                onPressed: () => acceptReturn(
                                                    context,
                                                    book['history_id']
                                                        .toString()),
                                                child: const Text(
                                                  "Accept Return",
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                              ),
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
                      ),
                    );
                  },
                ),
    );
  }
}
