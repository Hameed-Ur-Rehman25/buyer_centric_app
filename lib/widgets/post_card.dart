import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostCard extends StatelessWidget {
  final DocumentSnapshot post;
  final Function(String) getUserName;
  final Function(BuildContext, String) makeOffer;
  final Widget Function(List<dynamic>) buildOffersList;
  final bool showFavoriteButton;
  final Function(String)? onFavoriteToggle;

  const PostCard({
    Key? key,
    required this.post,
    required this.getUserName,
    required this.makeOffer,
    required this.buildOffersList,
    this.showFavoriteButton = true,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var data = post.data() as Map<String, dynamic>;
    String userId = data['userId'] ?? '';

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      shadowColor: Colors.grey.shade500,
      color: Colors.white,
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
              future: getUserName(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Text('Loading user...');
                }
                return Text(
                  'Posted by: ${snapshot.data}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ),
          if (data['imageUrl'] != null)
            Center(
              child: Container(
                // width: double.infinity,
                height: 150,
                child: Image.network(
                  data['imageUrl'],
                  fit: BoxFit.cover,
                ),
              ),
            ),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['description'] != null &&
                    data['description'].isNotEmpty)
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      data['description'],
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Price Range',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '\$${data['minPrice'].round()} - \$${data['maxPrice'].round()}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (data['offers'] != null)
                  Expanded(
                    child: ExpansionTile(
                      title: Text(
                        'Offers (${(data['offers'] as List).length})',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        buildOffersList(data['offers'] as List),
                      ],
                    ),
                  ),
                SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => makeOffer(context, post.id),
                  icon: Icon(Icons.local_offer),
                  label: Text('Make Offer'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(140, 45),
                    backgroundColor: const Color.fromARGB(255, 213, 247, 41),
                  ),
                ),
                if (showFavoriteButton) _buildFavoriteButton(context, post.id),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, String postId) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('favorites')
          .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
          .where('postId', isEqualTo: postId)
          .snapshots(),
      builder: (context, snapshot) {
        bool isFavorite = snapshot.hasData && snapshot.data!.docs.isNotEmpty;

        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () => onFavoriteToggle?.call(postId),
        );
      },
    );
  }
}
