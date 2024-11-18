import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPostScreen extends StatefulWidget {
  @override
  _MyPostScreenState createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  late Stream<QuerySnapshot> _postsStream;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: user?.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> _deletePost(BuildContext context, String postId) async {
    if (!mounted) return;

    try {
      await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post deleted successfully')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post: $e')),
      );
    }
  }

  Widget _buildOfferCard(Map<String, dynamic> offer, String postId) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        title: Row(
          children: [
            Text(
              '\$${offer['amount']}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '(${DateTime.fromMillisecondsSinceEpoch((offer['timestamp'] as Timestamp).millisecondsSinceEpoch).toString().split('.')[0]})',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(offer['message'] ?? 'No message'),
            SizedBox(height: 4),
            Text(
              'From: User ${offer['userId']}',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.check_circle_outline),
              color: Colors.green,
              onPressed: () => _handleOffer(context, postId, offer, true),
              tooltip: 'Accept Offer',
            ),
            IconButton(
              icon: Icon(Icons.cancel_outlined),
              color: Colors.red,
              onPressed: () => _handleOffer(context, postId, offer, false),
              tooltip: 'Reject Offer',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOffer(BuildContext context, String postId,
      Map<String, dynamic> offer, bool accept) async {
    if (!mounted) return;

    try {
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(postId);

      await postRef.update({
        'offers': FieldValue.arrayRemove([offer]),
      });

      offer['status'] = accept ? 'accepted' : 'rejected';
      offer['handledAt'] = Timestamp.now();

      await postRef.update({
        'offers': FieldValue.arrayUnion([offer]),
        if (accept) 'status': 'sold',
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(accept ? 'Offer accepted successfully' : 'Offer rejected'),
          backgroundColor: accept ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error handling offer: $e')),
      );
    }
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
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.post_add, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No posts yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Create a post to get started',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var post = snapshot.data!.docs[index];
            var data = post.data() as Map<String, dynamic>;
            var offers = (data['offers'] ?? []) as List;

            return Card(
              margin: EdgeInsets.all(8),
              elevation: 4,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${data['make']} ${data['model']} ${data['year']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline),
                          onPressed: () => _deletePost(context, post.id),
                          color: Colors.red,
                        ),
                      ],
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
                        Text('Description:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text(data['description'] ?? 'No description'),
                        SizedBox(height: 8),
                        Text('Price Range:',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          '\$${data['minPrice'].round()} - \$${data['maxPrice'].round()}',
                          style: TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                  if (offers.isNotEmpty)
                    ExpansionTile(
                      title: Row(
                        children: [
                          Icon(Icons.local_offer, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Offers (${offers.length})',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      children: offers
                          .map<Widget>(
                              (offer) => _buildOfferCard(offer, post.id))
                          .toList(),
                      initiallyExpanded: true,
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
