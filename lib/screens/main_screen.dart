import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:buyer_centric_app/screens/auth/login_screen.dart';
import 'package:buyer_centric_app/screens/home_screen.dart';
import 'package:buyer_centric_app/screens/my_post_screen.dart';
import 'package:buyer_centric_app/screens/settings_screen.dart';
import 'package:buyer_centric_app/screens/all_posts_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    AllPostsScreen(),
    MyPostScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return Scaffold(
            body: _widgetOptions.elementAt(_selectedIndex),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'All Posts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  label: 'My Posts',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.settings),
                  label: 'Settings',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.amber[800],
              unselectedItemColor: Colors.black,
              elevation: 10,
              onTap: _onItemTapped,
            ),
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
