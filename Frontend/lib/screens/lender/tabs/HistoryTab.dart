import 'package:flutter/material.dart';

class HistoryTab extends StatelessWidget {
  final List<dynamic>? history;

  const HistoryTab({required this.history, super.key});

  @override
  Widget build(BuildContext context) {
    return history == null || history!.isEmpty
        ? const Center(child: Text("No history available"))
        : ListView.builder(
            itemCount: history!.length,
            itemBuilder: (context, index) {
              final book = history![index];
              final bookName = book['book_name'] ?? 'Unknown';
              final borrowDate = book['borrow_date'] ?? '-';
              final returnDate = book['return_date'] ?? '-';
              final bookStatus = book['book_status'] ?? 'Unknown';

              return ListTile(
                title: Text(bookName),
                subtitle: Text('Borrow Date: $borrowDate\nReturn Date: $returnDate'),
                trailing: Chip(
                  label: Text(
                    bookStatus,
                    style: const TextStyle(color: Colors.white),
                  ),
                  backgroundColor: bookStatus == 'borrowed'
                      ? Colors.green
                      : bookStatus == 'pending'
                          ? Colors.orange
                          : Colors.grey,
                ),
              );
            },
          );
  }
}
