import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Add this import

class StatingPage extends StatefulWidget {
  const StatingPage({super.key});

  @override
  State<StatingPage> createState() => _StatingPageState();
}

class _StatingPageState extends State<StatingPage> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;
  Timer? _autoSlideTimer; // Add this timer variable

  final List<PageData> _pageData = [
    PageData(
      image: 'assets/images/newstarting1.png',
      title: 'Exclusive Experiences at Amazing Prices',
      description: 'Indulge in the finest activities Lanzarote has to offer.',
    ),
    PageData(
      image: 'assets/images/teststart.png',
      title: 'Thrilling Adventures Await',
      description: 'Explore action-packed excursions across the island.',
    ),
    PageData(
      image: 'assets/images/newstarting3.png',
      title: 'Sell Your Vouchers Effortlessly',
      description:
          'Join our community and share your experiences with travelers.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  void _startAutoSlide() {
    // Use a Timer instead of recursive Future.delayed calls
    _autoSlideTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && mounted) {
        int nextPage = (_currentPage + 1) % _pageData.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _autoSlideTimer?.cancel();
    _pageController.dispose(); // Also dispose of the page controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              if (mounted) {
                setState(() {
                  _currentPage = index;
                });
              }
            },
            itemCount: _pageData.length,
            itemBuilder: (context, index) {
              return PageViewContent(pageData: _pageData[index]);
            },
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pageData.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == _currentPage ? Colors.orange : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PageData {
  final String image;
  final String title;
  final String description;

  PageData({
    required this.image,
    required this.title,
    required this.description,
  });
}

class PageViewContent extends StatelessWidget {
  final PageData pageData;

  const PageViewContent({super.key, required this.pageData});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 6,
          child: ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
            child: Image.asset(
              pageData.image,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pageData.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  pageData.description,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF158482),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                    ),
                    onPressed: () {
                      Get.toNamed('/notification');
                    },
                    child: const Text(
                      "Start your journey",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
