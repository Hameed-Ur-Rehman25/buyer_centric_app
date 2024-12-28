// Import necessary packages for Flutter UI, Firebase Firestore, and Firebase Authentication
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app/screens/chat_screen.dart';

// Stateful widget for the "My Posts" screen
class MyPostScreen extends StatefulWidget {
  @override
  _MyPostScreenState createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  // Stream to listen for real-time updates to the user's posts
  late Stream<QuerySnapshot> _postsStream;

  // Define primary and contrast colors for consistent styling
  final Color primaryColor = const Color.fromARGB(255, 213, 247, 41);
  final Color contrastColor = Colors.grey.shade800;

  @override
  void initState() {
    super.initState();
    // Get the current user and fetch their posts from Firestore
    final user = FirebaseAuth.instance.currentUser;
    _postsStream = FirebaseFirestore.instance
        .collection('posts')
        .where('userId', isEqualTo: user?.uid) // Filter posts by userId
        .orderBy('timestamp', descending: true) // Order by most recent
        .snapshots(); // Enable real-time updates
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Set background color
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            primaryColor.withOpacity(0.9), // Semi-transparent app bar
        title: Text(
          'My Posts',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        centerTitle: true, // Center the title
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _postsStream, // Listen to the posts stream
              builder: (context, snapshot) {
                // Show a loading spinner while waiting for data
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Display a message if there are no posts
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                // Build a list of post cards
                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var post = snapshot.data!.docs[index];
                    var data = post.data()
                        as Map<String, dynamic>; // Cast document to map
                    return _buildPostCard(
                        context, post, data); // Build individual post card
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget to display when there are no posts
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.post_add, size: 64, color: primaryColor), // Add icon
          SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: contrastColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Create a post to get started',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Build individual post card
  Widget _buildPostCard(
      BuildContext context, DocumentSnapshot post, Map<String, dynamic> data) {
    // Sort offers by amount in descending order
    var offers = (data['offers'] ?? []) as List;
    offers.sort((a, b) => (b['amount'] as num).compareTo(a['amount'] as num));

    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(
              context, data, post.id), // Header with title and delete button
          if (data['imageUrl'] != null)
            _buildPostImage(data['imageUrl']), // Optional image
          _buildPostDetails(data), // Display description and price range
          if (offers.isNotEmpty)
            _buildOffersSection(offers, post.id), // Offer section
        ],
      ),
    );
  }

  // Header section for post card
  Widget _buildPostHeader(
      BuildContext context, Map<String, dynamic> data, String postId) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data['make']} ${data['model']} ${data['year']}', // Display make, model, and year
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: contrastColor,
                  ),
                ),
                SizedBox(height: 4),
                _buildStatusBadge(data['status'] ??
                    'active'), // Status badge (e.g., Active, Sold)
              ],
            ),
          ),
          IconButton(
            icon:
                Icon(Icons.delete_outline, color: Colors.red.withOpacity(0.8)),
            onPressed: () => _deletePost(context, postId), // Delete post action
          ),
        ],
      ),
    );
  }

  // Status badge widget for post status
  Widget _buildStatusBadge(String status) {
    Color badgeColor =
        status.toLowerCase() == 'sold' ? Colors.black : primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(), // Display status in uppercase
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: badgeColor,
        ),
      ),
    );
  }

  // Image section for post
  Widget _buildPostImage(String imageUrl) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl), // Load image from URL
        ),
      ),
    );
  }

  // Details section for post
  Widget _buildPostDetails(Map<String, dynamic> data) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data['description'] ?? 'No description', // Display description
            style: TextStyle(fontSize: 16, color: Colors.grey[800]),
          ),
          SizedBox(height: 12),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${data['minPrice'].round()} - \$${data['maxPrice'].round()}', // Price range
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Offers section for post
  Widget _buildOffersSection(List offers, String postId) {
    offers.sort((a, b) => (a['amount'] as num)
        .compareTo(b['amount'] as num)); // Sort offers by amount

    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          'Offers (${offers.length})', // Display number of offers
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: contrastColor,
          ),
        ),
        children: offers
            .map<Widget>((offer) => _buildOfferCard(offer, postId))
            .toList(), // Build individual offer cards
      ),
    );
  }

  // Individual offer card
  Widget _buildOfferCard(Map<String, dynamic> offer, String postId) {
    return ListTile(
      title: Text('\$${offer['amount']}'), // Display offer amount
      subtitle:
          Text(offer['message'] ?? 'No message'), // Display optional message
      trailing: IconButton(
        icon: Icon(Icons.chat), // Chat icon
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(
                buyerId: offer['userId'], // Pass buyer ID to chat screen
                postId: postId, // Pass post ID to chat screen
                sellerId: '', // Placeholder for seller ID
                postData: {}, // Placeholder for post data
              ),
            ),
          );
        },
      ),
    );
  }

  // Delete post function
  Future<void> _deletePost(BuildContext context, String postId) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .delete(); // Delete post from Firestore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Post deleted successfully')), // Show success message
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting post')), // Show error message
      );
    }
  }
}
