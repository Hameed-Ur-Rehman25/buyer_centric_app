import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // Method to login user
  static Future<void> loginUser(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Method to sign up user
  static Future<void> signUpUser(
      String email, String password, Map<String, String> additionalData) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user?.uid).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        ...additionalData,
      });
    } catch (e) {
      throw Exception('Sign up failed: $e');
    }
  }

  // Method to fetch user data
  static Future<DocumentSnapshot> getUserData(String userId) async {
    try {
      return await _firestore.collection('users').doc(userId).get();
    } catch (e) {
      throw Exception('Fetching user data failed: $e');
    }
  }

  // Method to update user profile
  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(userId).update(data);
    } catch (e) {
      throw Exception('Updating user profile failed: $e');
    }
  }

  // Method to logout user
  static Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  // Method to create a post
  static Future<void> createPost(Map<String, dynamic> postData) async {
    try {
      await _firestore.collection('posts').add(postData);
    } catch (e) {
      throw Exception('Creating post failed: $e');
    }
  }

  // Method to fetch all posts
  static Stream<QuerySnapshot> getPostsStream() {
    try {
      return _firestore
          .collection('posts')
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Fetching posts failed: $e');
    }
  }

  // Method to fetch user-specific posts
  static Stream<QuerySnapshot> getUserPostsStream(String userId) {
    try {
      return _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();
    } catch (e) {
      throw Exception('Fetching user posts failed: $e');
    }
  }

  // Method to delete a post
  static Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      throw Exception('Deleting post failed: $e');
    }
  }

  // Method to update a post
  static Future<void> updatePost(
      String postId, Map<String, dynamic> updatedData) async {
    try {
      await _firestore.collection('posts').doc(postId).update(updatedData);
    } catch (e) {
      throw Exception('Updating post failed: $e');
    }
  }

  // Method to reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw Exception('Password reset failed: $e');
    }
  }

  // Method to check user authentication state
  static Stream<User?> authStateChanges() {
    try {
      return _auth.authStateChanges();
    } catch (e) {
      throw Exception('Error listening to auth state changes: $e');
    }
  }
}
