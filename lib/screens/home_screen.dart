// import 'package:flutter/material.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:buyer_centric_app/screens/auth/login_screen.dart';

// class HomeScreen extends StatelessWidget {
//   Future<void> _signOut(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       Navigator.of(context).pushAndRemoveUntil(
//         MaterialPageRoute(builder: (context) => LoginScreen()),
//         (route) => false,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error signing out')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             'Welcome to Car Trading App',
//             style: TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Search for cars or view posts to get started',
//             style: TextStyle(
//               fontSize: 16,
//               color: Colors.grey,
//             ),
//           ),
//           SizedBox(height: 40),
//           ElevatedButton.icon(
//             onPressed: () => _signOut(context),
//             icon: Icon(Icons.logout),
//             label: Text('Sign Out'),
//             style: ElevatedButton.styleFrom(
//               padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
