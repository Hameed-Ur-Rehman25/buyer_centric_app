import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> getUserPostsStream(String userId) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> createPost(Map<String, dynamic> postData) {
    return _firestore.collection('posts').add(postData);
  }

  static Future<void> updateUserProfile(
      String userId, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).update(data);
  }

  static Future<DocumentSnapshot> getUserData(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }
}
