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
    final currentUser = FirebaseAuth.instance.currentUser;
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isNotEqualTo: currentUser?.uid)
        .orderBy('userId')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _makeOffer(BuildContext context, String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to make an offer')),
      );
      return;
    }

    final TextEditingController amountController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make an Offer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (\$)',
                  hintText: 'Enter amount',
                  prefixText: '\$',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Message',
                  hintText: 'Enter your message to the seller',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (amountController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter an amount')),
                );
                return;
              }

              try {
                double amount = double.parse(amountController.text);
                DocumentReference postRef =
                    FirebaseFirestore.instance.collection('posts').doc(postId);

                DocumentSnapshot postDoc = await postRef.get();
                if (!postDoc.exists) {
                  throw 'Post not found';
                }

                Map<String, dynamic> postData =
                    postDoc.data() as Map<String, dynamic>;

                if (postData['userId'] == user.uid) {
                  throw 'Cannot make offer on your own post';
                }

                await postRef.update({
                  'offers': FieldValue.arrayUnion([
                    {
                      'userId': user.uid,
                      'amount': amount,
                      'message': messageController.text.trim(),
                      'timestamp': Timestamp.now(),
                      'status': 'pending',
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
                    subtitle: Text(data['description'] ?? ''),
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
                  if (data['userId'] != FirebaseAuth.instance.currentUser?.uid)
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
