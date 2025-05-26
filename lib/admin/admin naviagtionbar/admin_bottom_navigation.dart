import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AdminBottomNavigation extends StatefulWidget {
  const AdminBottomNavigation({super.key});

  @override
  State<AdminBottomNavigation> createState() => _AdminBottomNavigationState();
}

class _AdminBottomNavigationState extends State<AdminBottomNavigation> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateIndexFromRoute();
  }

  // Update the selected index based on the current route
  void _updateIndexFromRoute() {
    String? currentRoute = Get.currentRoute;
    setState(() {
      switch (currentRoute) {
        case '/adminDashboard':
          _selectedIndex = 0;
          break;
        case '/customersForAdmin':
          _selectedIndex = 1;
          break;
        case '/profileForAdmin':
          _selectedIndex = 2;
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
            '/adminDashboard', (route) => false); // Admin Dashboard
        break;
      case 1:
        Get.offNamedUntil(
            '/customersForAdmin', (route) => false); // Customers for Admin
        break;
      case 2:
        Get.offNamedUntil(
            '/profileForAdmin', (route) => false); // Admin Profile
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
        selectedItemColor: const Color(0xFF158482), // Keep your custom color
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _buildNavItem(
              Icons.dashboard_outlined, Icons.dashboard, "Dashboard", 0),
          _buildNavItem(Icons.people_outline, Icons.people, "Customers", 1),
          _buildNavItem(Icons.person_outline, Icons.person, "Profile", 2),
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
