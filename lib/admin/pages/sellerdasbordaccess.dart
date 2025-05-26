import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../admin controller/adminsellerdasboard_controller.dart';

class AdminSellerDashboardView extends StatelessWidget {
  const AdminSellerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the sellerId from arguments
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String sellerId = args['sellerId'] ?? '';

    print("AdminSellerDashboardView received sellerId: $sellerId");

    if (sellerId.isEmpty) {
      return Scaffold(
        body: Center(child: Text("Error: No seller ID provided")),
      );
    }

    // Initialize the controller using GetX with the sellerId
    final SellerDashboardController dashboardController =
        Get.put(SellerDashboardController(sellerId: sellerId));

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (dashboardController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (dashboardController.error.value.isNotEmpty) {
            return Center(
                child: Text('Error: ${dashboardController.error.value}'));
          } else if (dashboardController.sellerData.value == null) {
            return const Center(child: Text('No seller data found'));
          }

          final seller = dashboardController.sellerData.value!;
          print("Displaying data for seller: ${seller.name}");

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: ListView(
              children: [
                _buildAppBar(context, dashboardController),
                const SizedBox(height: 20),
                _buildTitleSection(seller),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCard("\$${seller.totalRevenue.toStringAsFixed(2)}",
                        "Total Sales", const Color(0xFFFFC727), Colors.black),
                    _buildCard("${dashboardController.soldVouchers.value}",
                        "Sold Vouchers", const Color(0xFF10B981), Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCard("${dashboardController.totalCustomers.value}",
                        "Total Customers", Colors.blueAccent, Colors.white),
                    _buildCard(
                        "${seller.activeVouchers + dashboardController.soldVouchers.value}",
                        "All Vouchers",
                        Colors.deepPurple,
                        Colors.white),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSalesBreakdown(),
                const SizedBox(height: 20),
                _buildGraph(dashboardController, seller),
                const SizedBox(height: 20),
                _buildVoucherStats(dashboardController, seller),
                const SizedBox(height: 20),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(
      BuildContext context, SellerDashboardController dashboardController) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.teal, size: 28),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          onPressed: () {
            dashboardController.goBack();
          },
        ),
      ],
    );
  }

  Widget _buildTitleSection(Seller seller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Welcome, ${seller.name}!",
            style: const TextStyle(fontSize: 16, color: Colors.grey)),
        const SizedBox(height: 5),
        Text("${seller.storeName}\nSales and Analytics",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        // Handle filter button tap
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.teal : Colors.grey[300],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSalesBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Sales Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildFilterButton("Week", true),
            _buildFilterButton("Month", false),
            _buildFilterButton("6 Months", false),
            _buildFilterButton("Year", false),
          ],
        ),
      ],
    );
  }

  Widget _buildGraph(SellerDashboardController controller, Seller seller) {
    final List<ChartData> barData = [
      ChartData('Active', seller.activeVouchers.toDouble(), Colors.green),
      ChartData(
          'Expired', controller.expiredVouchers.value.toDouble(), Colors.red),
      ChartData(
          'Sold', controller.soldVouchers.value.toDouble(), Colors.orange),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Voucher Overview",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 200,
          child: SfCartesianChart(
            primaryXAxis: CategoryAxis(),
            legend: Legend(isVisible: true),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<ChartData, String>>[
              ColumnSeries<ChartData, String>(
                dataSource: barData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => data.color,
                name: 'Vouchers',
                dataLabelSettings: const DataLabelSettings(isVisible: true),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVoucherStats(
      SellerDashboardController controller, Seller seller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Voucher Stats",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard("${seller.activeVouchers}", "Active Vouchers",
                Colors.blue, Colors.white),
            _buildCard("${controller.expiredVouchers.value}",
                "Expired Vouchers", Colors.red, Colors.white),
          ],
        ),
        const SizedBox(height: 10),
        _buildCard("${controller.soldVouchers.value}", "Sold Vouchers",
            const Color(0xFFFFC727), Colors.black),
      ],
    );
  }

  Widget _buildCard(
      String value, String title, Color backgroundColor, Color textColor) {
    return Container(
      width: MediaQuery.of(Get.context!).size.width * 0.42,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }
}

class ChartData {
  final String x;
  final double y;
  final Color color;
  ChartData(this.x, this.y, this.color);
}
