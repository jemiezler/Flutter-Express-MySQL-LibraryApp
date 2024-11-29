import 'package:flutter/material.dart';

class RequestTab extends StatelessWidget {
  final List<dynamic> requests;
  final Function(int) onApprove;
  final Function(int) onDisapprove;

  const RequestTab({
    required this.requests,
    required this.onApprove,
    required this.onDisapprove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return requests.isEmpty
        ? const Center(child: Text("No requests available"))
        : ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final bookName = request['namebook'] ?? 'Unknown';
              final borrowerName = request['borrower_name'] ?? 'Unknown';
              final borrowDate = request['borrow_date'] ?? 'Unknown';

              return Card(
                child: ListTile(
                  title: Text(bookName),
                  subtitle: Text("Borrower: $borrowerName\nDate: $borrowDate"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.check, color: Colors.green),
                        onPressed: () => onApprove(request['history_id']),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () => onDisapprove(request['history_id']),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}
