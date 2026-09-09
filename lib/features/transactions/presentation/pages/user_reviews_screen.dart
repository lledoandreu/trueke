import 'package:flutter/material.dart';
import '../widgets/user_reviews_list_widget.dart';
import '../widgets/add_review_dialog.dart';

class UserReviewsScreen extends StatelessWidget {
  final String userId;
  final String userName;

  const UserReviewsScreen({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Valoraciones de $userName')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Opiniones de la comunidad',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            UserReviewsListWidget(userId: userId),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AddReviewDialog(receiverId: userId),
          );

          if (result == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('¡Valoración enviada con éxito!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        label: const Text('Valorar'),
        icon: const Icon(Icons.rate_review),
      ),
    );
  }
}
