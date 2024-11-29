import 'package:flutter/material.dart';
import '../../../utils/ApiService.dart';
import '../../../utils/DateHelpers.dart';

class ReturnTab extends StatelessWidget {
  final ApiService apiService = ApiService(); // Initialize ApiService

  ReturnTab({super.key});

  // Fetch books with `return` status from the API
  Future<List<dynamic>> fetchReturnedBooks() async {
    try {
      final data = await apiService.get('/history?status=returned'); // Query for returned books
      return data;
    } catch (error) {
      throw Exception("Error fetching returned books: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchReturnedBooks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              "No returned books available",
              style: TextStyle(fontSize: 16),
            ),
          );
        } else {
          final books = snapshot.data!;
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

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
                          DateHelpers.formatDate(book['borrow_date']), // Display borrow date
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
                                        'https://via.placeholder.com/125x175', // Fallback to placeholder
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                        text: 'Book Name: ',
                                        style: const TextStyle(fontSize: 16),
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
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Loan date: ${DateHelpers.formatDate(book['borrow_date'])}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Returned date: ${DateHelpers.formatDate(book['return_date'])}",
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                    const SizedBox(height: 15),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 20,
                                              vertical: 10,
                                            ),
                                          ),
                                          onPressed: () {
                                            // Handle return action
                                          },
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
          );
        }
      },
    );
  }
}
