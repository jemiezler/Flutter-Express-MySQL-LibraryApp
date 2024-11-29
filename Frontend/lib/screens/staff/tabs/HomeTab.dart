import 'package:flutter/material.dart';
import '../components/book_card.dart';
import '../../../utils/ApiService.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final ApiService apiService = ApiService(); // Initialize ApiService
  List<dynamic> books = []; // List to hold fetched books
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    fetchBooks(); // Fetch books when the widget is initialized
  }

  Future<void> fetchBooks() async {
    try {
      final data = await apiService.get('/books'); // Fetch books from API
      setState(() {
        books = data; // Update the books list
        isLoading = false; // Set loading to false
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
      print('Error fetching books: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator
          : GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of columns
                crossAxisSpacing: 8.0, // Space between columns
                mainAxisSpacing: 8.0, // Space between rows
                childAspectRatio: 0.7, // Adjust the height-to-width ratio of items
              ),
              itemCount: books.length, // Use the length of fetched books
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCard(
                  bookId: book['book_id'].toString(), // Map book_id to bookId
                  title: book['book_name'], // Map book_name to title
                  subtitle: book['book_details'], // Map book_details to subtitle
                  status: book['status'], // Map status
                  imageUrl: book['book_image'], // Map book_image to imageUrl
                );
              },
            ),
    );
  }
}
