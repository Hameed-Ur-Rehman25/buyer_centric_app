import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPostScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Posts'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .where('userId', isEqualTo: user?.uid)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts yet'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var post = snapshot.data!.docs[index];
              var data = post.data() as Map<String, dynamic>;
              var offers =
                  List<Map<String, dynamic>>.from(data['offers'] ?? []);

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
                    ExpansionTile(
                      title: Text('Offers (${offers.length})'),
                      children: offers.map((offer) {
                        return ListTile(
                          title: Text('\$${offer['amount']}'),
                          subtitle: Text(offer['message'] ?? ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check),
                                onPressed: () {
                                  // Accept offer logic
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () {
                                  // Reject offer logic
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
