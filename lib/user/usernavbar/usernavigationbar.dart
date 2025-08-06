import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserNavigationBar extends StatefulWidget {
  const UserNavigationBar({super.key});

  @override
  State<UserNavigationBar> createState() => _UserNavigationBarState();
}

class _UserNavigationBarState extends State<UserNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateIndexFromRoute();
  }

  void _updateIndexFromRoute() {
    String? currentRoute = Get.currentRoute;
    setState(() {
      switch (currentRoute) {
        case '/userhome':
          _selectedIndex = 0;
          break;
        case '/userorder':
          _selectedIndex = 1;
          break;
        case '/saved':
          _selectedIndex = 2;
          break;
        case '/profileuser':
          _selectedIndex = 3;
          break;
        default:
          _selectedIndex = 0;
          break;
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent unnecessary rebuilds

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Get.offNamedUntil(
            '/userhome', (route) => false); // Ensures proper back navigation
        break;
      case 1:
        Get.offNamedUntil('/userorder', (route) => false);
        break;
      case 2:
        Get.offNamedUntil('/saved', (route) => false);
        break;
      case 3:
        Get.offNamedUntil('/profileuser', (route) => false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Colors.black26,
            width: 0.5,
          ),
        ),
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF158482),
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _buildNavItem(Icons.home_outlined, Icons.home, "Home", 0),
          _buildNavItem(Icons.confirmation_number_outlined,
              Icons.confirmation_number, "Your Voucher", 1),
          _buildNavItem(Icons.favorite_border, Icons.favorite, "Saved", 2),
          _buildNavItem(Icons.person_outline, Icons.person, "Profile", 3),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
      IconData icon, IconData activeIcon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Icon(
        _selectedIndex == index ? activeIcon : icon,
        size: 24,
      ),
      label: label,
    );
  }
}
