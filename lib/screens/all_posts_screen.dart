import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<String> _getUserName(String userId) async {
    // Get current user
    final currentUser = FirebaseAuth.instance.currentUser;

    // If this post is from the current user
    if (currentUser != null && userId == currentUser.uid) {
      return 'Posted by you';
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        return 'Posted by: ${userData['name'] ?? 'Unknown User'}';
      }
      return 'Posted by: Unknown User';
    } catch (e) {
      print('Error fetching user name: $e');
      return 'Posted by: Unknown User';
    }
  }

  Future<void> _makeOffer(BuildContext context, String postId) async {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController messageController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to make an offer')),
      );
      return;
    }

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
              try {
                // Create the offer data with the current timestamp
                Map<String, dynamic> offerData = {
                  'userId': user.uid,
                  'amount': double.parse(amountController.text),
                  'message': messageController.text,
                  'timestamp':
                      DateTime.now().toIso8601String(), // Store as string
                  'status': 'pending'
                };

                await FirebaseFirestore.instance
                    .collection('posts')
                    .doc(postId)
                    .update({
                  'offers': FieldValue.arrayUnion([offerData])
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
            },
            child: Text('Send Offer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _postsStream,
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
            String userId = data['userId'] ?? '';

            return Card(
              margin: EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: Text(
                      '${data['make']} ${data['model']} ${data['year']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: FutureBuilder<String>(
                      future: _getUserName(userId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Text('Loading user...');
                        }
                        return Text(
                          snapshot.data ?? 'Unknown User',
                          style: TextStyle(
                            color: snapshot.data?.contains('Posted by you') ??
                                    false
                                ? Colors.blue
                                : Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        );
                      },
                    ),
                  ),
                  if (data['imageUrl'] != null)
                    Container(
                      width: double.infinity,
                      height: 200,
                      child: Image.network(
                        data['imageUrl'],
                        fit: BoxFit.cover,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (data['description'] != null &&
                            data['description'].isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(bottom: 8),
                            child: Text(
                              data['description'],
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        Text(
                          'Price Range:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '\$${data['minPrice'].round()} - \$${data['maxPrice'].round()}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton.icon(
                      onPressed: () => _makeOffer(context, post.id),
                      icon: Icon(Icons.local_offer),
                      label: Text('Make Offer'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 45),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
