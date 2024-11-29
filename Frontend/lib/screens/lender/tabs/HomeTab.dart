import 'package:flutter/material.dart';

import '../components/BookCard.dart';

class HomeTab extends StatelessWidget {
  final List<dynamic> books;
  final List<dynamic> filteredBooks;
  final String selectedCategory;
  final String searchQuery;
  final TextEditingController searchController;
  final Function(String) onSearch;
  final Function(String?) onCategoryChange;

  const HomeTab({
    required this.books,
    required this.filteredBooks,
    required this.selectedCategory,
    required this.searchQuery,
    required this.searchController,
    required this.onSearch,
    required this.onCategoryChange,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    fillColor: Colors.amber[200],
                    filled: true,
                    labelText: 'Search',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.keyboard_arrow_down),
                    filled: true,
                    fillColor: Colors.amber[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Sci-fi', child: Text('Sci-fi')),
                    DropdownMenuItem(value: 'Academic', child: Text('Academic')),
                    DropdownMenuItem(value: 'Fantasy', child: Text('Fantasy')),
                    DropdownMenuItem(value: 'Horror', child: Text('Horror')),
                  ],
                  onChanged: onCategoryChange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8.0,
                mainAxisSpacing: 8.0,
                childAspectRatio: 0.75,
              ),
              itemCount: filteredBooks.length,
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return BookCard(
                  bookId: book['book_id'].toString(),
                  title: book['book_name'].toString(),
                  subtitle: book['book_details'] ?? 'No details',
                  status: book['status'] ?? 'Unknown',
                  imageUrl: book['book_image'] ?? '',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
