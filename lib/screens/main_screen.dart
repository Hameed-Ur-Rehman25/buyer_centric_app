import 'package:flutter/material.dart';
import 'package:buyer_centric_app/screens/home_screen.dart';
import 'package:buyer_centric_app/screens/all_posts_screen.dart';
import 'package:buyer_centric_app/screens/my_post_screen.dart';
import 'package:buyer_centric_app/screens/car_search_details_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    HomeScreen(),
    CarSearchDetailsScreen(),
    AllPostsScreen(),
    MyPostScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Search Car',
    'Available Posts',
    'My Posts',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search Car',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'All Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Posts',
          ),
        ],
      ),
    );
  }
}
