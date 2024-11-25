import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:buyer_centric_app/screens/all_posts_screen.dart';
import 'package:buyer_centric_app/screens/my_post_screen.dart';
import 'package:buyer_centric_app/screens/car_search_details_screen.dart';
import 'package:buyer_centric_app/screens/profile_screen.dart';
import 'package:buyer_centric_app/screens/chat_list_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    AllPostsScreen(),
    CarSearchDetailsScreen(),
    MyPostScreen(),
    // ChatListScreen(),
    ProfileScreen(),
  ];

  final List<TabItem> _items = [
    TabItem(
      icon: Icons.home,
      title: 'Home',
    ),
    TabItem(
      icon: Icons.search,
      title: 'Search Car',
    ),
    TabItem(
      icon: Icons.list,
      title: 'My Posts',
    ),
    // TabItem(
    //   icon: Icons.chat,
    //   title: 'Chats',
    // ),
    TabItem(
      icon: Icons.person,
      title: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.transparent,
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 25, right: 25, left: 25),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
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
            borderRadius: BorderRadius.circular(50),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 181, 183, 181),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: BottomBarFloating(
                  items: _items,
                  backgroundColor: const Color.fromARGB(255, 181, 183, 181),
                  color: Colors.white,
                  colorSelected: const Color.fromARGB(255, 213, 247, 41),
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
