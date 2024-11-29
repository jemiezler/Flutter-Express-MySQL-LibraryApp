import 'package:flutter/material.dart';

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
            // Book Image Section
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
                      ? Image.network(imageUrl, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 80, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                // Book Details Section
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
            // Book Title and Status
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
