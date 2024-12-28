// ignore_for_file: deprecated_member_use

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:buyer_centric_app/screens/all_posts_screen.dart';
import 'package:buyer_centric_app/screens/my_post_screen.dart';
import 'package:buyer_centric_app/screens/car_search_details_screen.dart';
import 'package:buyer_centric_app/screens/profile_screen.dart';

// MainScreen is a StatefulWidget that represents the main screen of the app
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

// _MainScreenState is the state class for MainScreen
class _MainScreenState extends State<MainScreen> {
  // _selectedIndex keeps track of the currently selected bottom navigation tab
  int _selectedIndex = 0;

  // _screens is a list of widgets representing the different screens in the app
  final List<Widget> _screens = [
    AllPostsScreen(),
    CarSearchDetailsScreen(),
    MyPostScreen(),
    // ChatListScreen(), // This screen is currently commented out
    ProfileScreen(),
  ];

  // _items is a list of TabItem objects representing the bottom navigation tabs
  final List<TabItem> _items = [
    TabItem(
      icon: Icons.home, // Icon for the home tab
      title: 'Home',
    ),
    TabItem(
      icon: Icons.search, // Icon for the search car tab
      title: 'Search Car',
    ),
    TabItem(
      icon: Icons.list, // Icon for the my posts tab
      title: 'My Posts',
    ),
    // TabItem(
    //   icon: Icons.chat, // Icon for the chats tab
    //   title: 'Chats',
    // ),
    TabItem(
      icon: Icons.person, // Icon for the profile tab
      title: 'Profile',
    ),
  ];

  // _onItemTapped is called when a bottom navigation tab is tapped
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      backgroundColor: Colors.white,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 5, right: 10, left: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 3,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  // color: const Color.fromARGB(255, 181, 183, 181),
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: BottomBarFloating(
                  items: _items,
                  // backgroundColor: const Color.fromARGB(255, 181, 183, 181),
                  backgroundColor: Colors.white.withOpacity(0.5),
                  color: Colors.grey.shade600,
                  colorSelected: Colors.black,
                  indexSelected: _selectedIndex,
                  paddingVertical: 10,
                  onTap: _onItemTapped,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
