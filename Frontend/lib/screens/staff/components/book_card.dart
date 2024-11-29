import 'package:flutter/material.dart';
import '../../../utils/ApiService.dart';

class BookCard extends StatelessWidget {
  final ApiService apiService = ApiService(); // API service instance
  final String bookId;
  final String title;
  final String subtitle;
  final String status;
  final String imageUrl;

  BookCard({
    required this.bookId,
    required this.title,
    required this.subtitle,
    required this.status,
    required this.imageUrl,
    super.key,
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

  void _showDisableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Status for "$title"'),
          content: const Text('Do you want to disabled or enable this book?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateBookStatus(context, 'disabled');
              },
              child: const Text(
                'Disable',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateBookStatus(context, 'available');
              },
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  void _updateBookStatus(BuildContext context, String newStatus) async {
    try {
      await apiService.patch(
        '/books/status/$bookId',
        body: {'status': newStatus},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Book status updated to $newStatus',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: newStatus == 'disabled' ? Colors.red : Colors.green,
        ),
      );
      // Optionally refresh data after the update
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to update status',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDisableDialog(context),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section with Network Loading and Error Handling
              Flexible(
                flex: 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    height: 100,
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
              const SizedBox(height: 8),

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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 8),

              // Status Button
              Flexible(
                child: ElevatedButton(
                  onPressed: () => _showDisableDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: getStatusColor(),
                    minimumSize: const Size(80, 30),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
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
      ),
    );
  }
}
