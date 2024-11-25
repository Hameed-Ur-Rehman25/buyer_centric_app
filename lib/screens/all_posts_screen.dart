import 'package:buyer_centric_app/widgets/post_card.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AllPostsScreen extends StatefulWidget {
  @override
  _AllPostsScreenState createState() => _AllPostsScreenState();
}

class _AllPostsScreenState extends State<AllPostsScreen> {
  late Stream<QuerySnapshot> _postsStream;
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late ScrollController _scrollController;
  double _searchBarOpacity = 1.0;
  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchCurrentUserName();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final opacity = 1.0 - (offset / 100).clamp(0.0, 1.0);
    setState(() {
      _searchBarOpacity = opacity;
    });
  }

  Future<void> _fetchCurrentUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _userName = userDoc.data()?['name'] ?? 'User';
          });
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
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

  Widget _buildOffersList(List<dynamic> offers) {
    if (offers.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(8),
        child: Text(
          'No offers yet',
          style: TextStyle(
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    // Sort offers by amount
    offers.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Current Offers:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: offers.length,
          itemBuilder: (context, index) {
            var offer = offers[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: ListTile(
                title: Text(
                  '\$${offer['amount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                subtitle: Text(
                  offer['message'] ?? 'No message',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                trailing: Text(
                  offer['status'] ?? 'pending',
                  style: TextStyle(
                    color: offer['status'] == 'accepted'
                        ? Colors.green
                        : Colors.grey,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Future<void> _toggleFavorite(String postId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favoritesRef = FirebaseFirestore.instance.collection('favorites');
    final existingFavorite = await favoritesRef
        .where('userId', isEqualTo: user.uid)
        .where('postId', isEqualTo: postId)
        .get();

    if (existingFavorite.docs.isEmpty) {
      // Add to favorites
      await favoritesRef.add({
        'userId': user.uid,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added to favorites')),
      );
    } else {
      // Remove from favorites
      await existingFavorite.docs.first.reference.delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Removed from favorites')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _appBar(context),
            // Add back the post list with Expanded
            _postList(),
          ],
        ),
      ),
    );
  }

  SizedBox _appBar(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.24,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.sizeOf(context).height * 0.20,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 213, 247, 41),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Hi!\n',
                              style: TextStyle(
                                fontSize: 27,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: _userName,
                              style: TextStyle(
                                fontSize: 28,
                                color: Colors.grey.shade800,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.grey,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),

                // Adjust the search bar margins
              ],
            ),
          ),
          Positioned(
            bottom: -10,
            left: 0,
            right: 0,
            child: _searchTextField(),
          ),
        ],
      ),
    );
  }

  Container _searchTextField() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search by make or model...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
          suffixIcon: Icon(Icons.tune, color: Colors.grey[600]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value.toLowerCase();
          });
        },
      ),
    );
  }

  Expanded _postList() {
    return Expanded(
      child: StreamBuilder<QuerySnapshot>(
        stream: _postsStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts available'));
          }

          var filteredDocs = snapshot.data!.docs.where((doc) {
            var data = doc.data() as Map<String, dynamic>;
            String make = (data['make'] ?? '').toLowerCase();
            String model = (data['model'] ?? '').toLowerCase();
            return make.contains(_searchQuery) || model.contains(_searchQuery);
          }).toList();

          return ListView.builder(
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              return PostCard(
                post: filteredDocs[index],
                getUserName: _getUserName,
                makeOffer: _makeOffer,
                buildOffersList: _buildOffersList,
                showFavoriteButton: true,
                onFavoriteToggle: _toggleFavorite,
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
