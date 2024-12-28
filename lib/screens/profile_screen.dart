import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:buyer_centric_app/screens/auth/login_screen.dart';
import 'package:buyer_centric_app/screens/favorite_posts_screen.dart';
import 'package:buyer_centric_app/screens/chat_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _nameController =
      TextEditingController(); // Controller for name input
  bool _isEditing = false; // Flag to check if the user is editing

  @override
  void initState() {
    super.initState();
    _loadUserData(); // Load user data when the screen initializes
  }

  // Function to load user data from Firestore
  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (userData.exists) {
        setState(() {
          _nameController.text = userData.data()?['name'] ?? '';
        });
      }
    }
  }

  // Function to update user profile in Firestore
  Future<void> _updateProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'name': _nameController.text});
      setState(() {
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  // Function to sign out the user
  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out')),
      );
    }
  }

  // Function to navigate to the Favorites screen
  void _navigateToFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritePostsScreen()),
    );
  }

  // Function to navigate to the Chats screen
  void _navigateToChats() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser; // Get the current user
    final Color primaryColor =
        const Color.fromARGB(255, 213, 247, 41); // Define primary color

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'), // App bar title
        centerTitle: true, // Center the title
        actions: [
          IconButton(
            icon: Icon(
                _isEditing ? Icons.save : Icons.edit), // Icon for edit/save
            onPressed: () {
              if (_isEditing) {
                _updateProfile(); // Save profile if editing
              } else {
                setState(() {
                  _isEditing = true; // Enable editing
                });
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16), // Padding for the body
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person,
                  size: 50, color: Colors.white), // Profile icon
            ),
            SizedBox(height: 20), // Space between elements
            _isEditing
                ? TextField(
                    controller: _nameController, // Text field for name input
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    _nameController.text, // Display name
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
            SizedBox(height: 8), // Space between elements
            Text(
              user?.email ?? '', // Display user email
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 32), // Space between elements
            ListTile(
              leading:
                  Icon(Icons.favorite, color: Colors.red), // Icon for favorites
              title: Text('My Favorites'), // Title for favorites
              trailing: Icon(Icons.arrow_forward_ios), // Trailing arrow icon
              onTap: _navigateToFavorites, // Navigate to favorites
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue), // Icon for chats
              title: Text('My Chats'), // Title for chats
              trailing: Icon(Icons.arrow_forward_ios), // Trailing arrow icon
              onTap: _navigateToChats, // Navigate to chats
            ),
            ElevatedButton.icon(
              onPressed: _signOut, // Sign out button
              icon: Icon(Icons.logout,
                  color: Colors.grey.shade800), // Logout icon
              label: Text('Sign Out',
                  style:
                      TextStyle(color: Colors.grey.shade800)), // Sign out label
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor, // Background color of the button
                padding: EdgeInsets.symmetric(
                    horizontal: 32, vertical: 12), // Padding for the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
