import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllPostsScreen extends StatelessWidget {
  Future<void> _makeOffer(BuildContext context, String postId) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make an Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Amount (\$)'),
            ),
            TextField(
              controller: messageController,
              decoration: InputDecoration(labelText: 'Message'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(postId)
                      .update({
                    'offers': FieldValue.arrayUnion([
                      {
                        'userId': user.uid,
                        'amount': double.parse(amountController.text),
                        'message': messageController.text,
                        'timestamp': FieldValue.serverTimestamp(),
                      }
                    ])
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Offer sent successfully!')),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error sending offer: $e')),
                  );
                }
              }
            },
            child: Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var data = post.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text(
                          '${data['make']} ${data['model']} ${data['year']}'),
                      subtitle: Text(data['description'] ?? ''),
                    ),
                    if (data['imageUrl'] != null)
                      Image.network(data['imageUrl']),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Price Range: \$${data['minPrice'].round()} - \$${data['maxPrice'].round()}',
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: ElevatedButton(
                        onPressed: () => _makeOffer(context, post.id),
                        child: Text('Make Offer'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
