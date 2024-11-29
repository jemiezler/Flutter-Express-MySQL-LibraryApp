import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting
import '../../../utils/ApiService.dart';
import '../../../utils/DateHelpers.dart';

class HistoryTab extends StatelessWidget {
  final ApiService apiService = ApiService(); // Initialize ApiService

  HistoryTab({super.key});

  Future<List<dynamic>> fetchBooks() async {
    try {
      final data =
          await apiService.get('/history'); // Use ApiService to fetch data
      return data;
    } catch (error) {
      throw Exception("Error fetching books: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: fetchBooks(),
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
              "No books available",
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
                padding: const EdgeInsets.symmetric(
                  vertical: 8.0,
                  horizontal: 8.0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 177, 218, 236),
                    borderRadius: BorderRadius.circular(20.0),
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
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.network(
                            book['book_image'] ??
                                'https://via.placeholder.com/100x120', // Fallback to a placeholder image if URL is null
                            width: 100,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback UI if the image fails to load
                              return Container(
                                width: 100,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                book['book_name'] ?? 'Unknown Book',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Borrower's Name: ${book['borrowerName'] ?? '-'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Loan Date: ${DateHelpers.formatDate(book['borrow_date'])}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Returned Date: ${DateHelpers.formatDate(book['return_date'])}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Approved By: ${book['approverName'] ?? '-'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              Text(
                                "Asset Back By: ${book['staffName'] ?? '-'}",
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(
                                          book['book_status'] ?? 'unknown'),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      book['book_status'] ?? 'Unknown',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'borrowed':
        return Colors.red;
      case 'returned':
        return Colors.green;
      case 'available':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
