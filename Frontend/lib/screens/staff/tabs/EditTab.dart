import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/book_card.dart';
import '../../../utils/ApiService.dart';

class EditTab extends StatefulWidget {
  const EditTab({super.key});

  @override
  _EditTabState createState() => _EditTabState();
}

class _EditTabState extends State<EditTab> {
  final ApiService apiService = ApiService(); // API service instance
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : books.isEmpty
                ? const Center(child: Text('No books available'))
                : GridView.builder(
                    shrinkWrap: true,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.7,
                    ),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () {
                          editBook(book);
                        },
                        child: BookCard(
                          bookId: book['book_id'].toString(),
                          title: book['book_name'],
                          subtitle: book['book_details'],
                          status: book['status'],
                          imageUrl: book['book_image'],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addBook,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void addBook() {
    _showBookDialog(
      context,
      title: 'Add New Book',
      onSubmit: (bookName, bookDetails, imageFile, category) async {
        try {
          if (imageFile != null) {
            await apiService.postWithFile(
              '/books',
              fields: {
                'book_name': bookName,
                'book_details': bookDetails,
                'category': category,
              },
              file: imageFile,
              fileFieldName: 'book_image',
            );
          } else {
            await apiService.post(
              '/books',
              body: {
                'book_name': bookName,
                'book_details': bookDetails,
                'category': category,
              },
            );
          }
          fetchBooks();
        } catch (e) {
          print('Error adding book: $e');
        }
      },
    );
  }

  void editBook(dynamic book) {
    _showBookDialog(
      context,
      title: 'Edit Book',
      initialName: book['book_name'],
      initialDetails: book['book_details'],
      initialImageUrl: book['book_image'],
      initialCategory: book['category'],
      onSubmit: (bookName, bookDetails, imageFile, category) async {
        try {
          if (imageFile != null) {
            await apiService.postWithFile(
              '/books/${book['book_id']}',
              fields: {
                'book_name': bookName,
                'book_details': bookDetails,
                'category': category,
              },
              file: imageFile,
              fileFieldName: 'file',
            );
          } else {
            await apiService.put(
              '/books/${book['book_id']}',
              body: {
                'book_name': bookName,
                'book_details': bookDetails,
                'category': category,
              },
            );
          }
          fetchBooks();
        } catch (e) {
          print('Error editing book: $e');
        }
      },
    );
  }

  void _showBookDialog(
    BuildContext context, {
    required String title,
    String? initialName,
    String? initialDetails,
    String? initialImageUrl,
    String? initialCategory,
    required Future<void> Function(String, String, File?, String) onSubmit,
  }) {
    final TextEditingController nameController =
        TextEditingController(text: initialName);
    final TextEditingController detailsController =
        TextEditingController(text: initialDetails);
    File? selectedImage;
    final ImagePicker picker = ImagePicker();
    String? selectedCategory = initialCategory;

    // Predefined list of categories
    final List<String> categories = [
      'Sci-Fi',
      'Academic',
      'Fantasy',
      'Horror'
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration:
                          const InputDecoration(labelText: 'Book Title'),
                    ),
                    TextField(
                      controller: detailsController,
                      decoration:
                          const InputDecoration(labelText: 'Book Details'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: categories
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                      decoration: const InputDecoration(labelText: 'Category'),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () async {
                        final pickedFile = await picker.pickImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            selectedImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: selectedImage != null
                            ? Image.file(
                                selectedImage!,
                                fit: BoxFit.cover,
                              )
                            : initialImageUrl != null
                                ? Image.network(
                                    initialImageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : const Center(
                                    child: Text('Tap to select an image'),
                                  ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onSubmit(
                      nameController.text,
                      detailsController.text,
                      selectedImage,
                      selectedCategory ??
                          'Unknown', // Default category if none selected
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
