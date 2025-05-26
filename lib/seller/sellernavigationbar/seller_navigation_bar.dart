import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SellerNavigationBar extends StatefulWidget {
  const SellerNavigationBar({super.key});

  @override
  State<SellerNavigationBar> createState() => _SellerNavigationBarState();
}

class _SellerNavigationBarState extends State<SellerNavigationBar> {
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
        case '/sellerHome':
          _selectedIndex = 0;
          break;
        case '/vouchers':
          _selectedIndex = 1;
          break;
        case '/customers':
          _selectedIndex = 2;
          break;
        case '/profile':
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
            '/sellerHome', (route) => false); // Ensures proper back navigation
        break;
      case 1:
        Get.offNamedUntil('/vouchers', (route) => false);
        break;
      case 2:
        Get.offNamedUntil('/customers', (route) => false);
        break;
      case 3:
        Get.offNamedUntil('/profile', (route) => false);
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
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          _buildNavItem(Icons.home_outlined, Icons.home, "Dashboard", 0),
          _buildNavItem(Icons.confirmation_number_outlined,
              Icons.confirmation_number, "Vouchers", 1),
          _buildNavItem(Icons.people_outline, Icons.people, "Customers", 2),
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
