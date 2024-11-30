import 'package:flutter/material.dart';
import '../../../utils/ApiService.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  HomeTabState createState() => HomeTabState();
}

class HomeTabState extends State<HomeTab> {
  final ApiService apiService = ApiService(); // Initialize ApiService
  List<dynamic> books = []; // List to hold all fetched books
  List<dynamic> filteredBooks = []; // List to hold filtered books
  bool isLoading = true; // Loading state
  String searchQuery = ""; // Store search query
  String? selectedCategory; // Store selected category

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
        filteredBooks = books; // Initially show all books
        isLoading = false; // Set loading to false
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading even if there's an error
      });
    }
  }

  void filterBooks() {
    setState(() {
      filteredBooks = books.where((book) {
        final matchesSearch = searchQuery.isEmpty ||
            book['book_name']
                .toString()
                .toLowerCase()
                .contains(searchQuery.toLowerCase());
        final matchesCategory =
            selectedCategory == null || book['category'] == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          // Search Bar
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    searchQuery = value;
                    filterBooks();
                  },
                  decoration: InputDecoration(
                    fillColor: Colors.amber[200],
                    filled: true,
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search books by name...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
              // Category Filter
              SizedBox(
                width: 16,
              ),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                      filterBooks();
                    });
                  },
                  items: [
                    const DropdownMenuItem(
                        value: null, child: Text("All Categories")),
                    ...books
                        .map<String>((book) => book['category'])
                        .toSet()
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                  ],
                  decoration: InputDecoration(
                    labelText: "Filter by Category",
                    prefixIcon: const Icon(Icons.keyboard_arrow_down),
                    filled: true,
                    fillColor: Colors.amber[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: const BorderSide(
                        color: Colors.amber,
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16,
          ),
          // Book List
          Expanded(
            child: isLoading
                ? const Center(
                    child:
                        CircularProgressIndicator()) // Show loading indicator
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                      crossAxisSpacing: 8.0, // Space between columns
                      mainAxisSpacing: 8.0, // Space between rows
                      childAspectRatio:
                          0.7, // Adjust the height-to-width ratio of items
                    ),
                    itemCount: filteredBooks
                        .length, // Use the length of filtered books
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];
                      return _HomeCard(
                        bookId:
                            book['book_id'].toString(), // Map book_id to bookId
                        title: book['book_name'], // Map book_name to title
                        subtitle: book[
                            'book_details'], // Map book_details to subtitle
                        status: book['status'], // Map status
                        imageUrl:
                            book['book_image'], // Map book_image to imageUrl
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _HomeCard extends StatelessWidget {
  final ApiService apiService = ApiService(); // API service instance
  final String bookId;
  final String title;
  final String subtitle;
  final String status;
  final String imageUrl;

  _HomeCard({
    required this.bookId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.imageUrl,
  });

  Color getStatusColor() {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      color: Colors.blue[100],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // รูป
                Expanded(
                  flex: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.fitHeight,
                      width: double.infinity,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                //ข้อมูลข้างรูป
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Centers vertically
                    crossAxisAlignment:
                        CrossAxisAlignment.center, // Centers horizontally
                    children: [
                      const Text(
                        'Book ID',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.lightBlue,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue[300], // Background color
                          borderRadius: BorderRadius.circular(
                              8), // Optional rounded corners
                        ),
                        child: Text(
                          'B0$bookId',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed: () {},
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.grey,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text(
                                'Detail',
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            // Title with Overflow Handling
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Subtitle with Overflow Handling
            Flexible(
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            // Status Button
            Flexible(
              child: FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: getStatusColor(),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
