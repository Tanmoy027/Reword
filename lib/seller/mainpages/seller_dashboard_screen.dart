import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'seller_dashboard_controller.dart';
import 'package:reword_frontend/seller/sellernavigationbar/seller_navigation_bar.dart';

class SellerDashboardScreen extends StatelessWidget {
  SellerDashboardScreen({super.key});

  final SellerDashboardController controller =
      Get.put(SellerDashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          // For the bar chart:
          final active = controller.activeVouchers.toDouble();
          final expired = controller.expiredVouchers.toDouble();
          final sold = controller.voucherStatsSold.value.toDouble();

          // We'll show a bar chart with [Active, Expired, Sold]
          final barData = [
            ChartData('Active', active, Colors.green),
            ChartData('Expired', expired, Colors.red),
            ChartData('Sold', sold, Colors.orange),
          ];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: RefreshIndicator(
              onRefresh: () => controller.fetchStats(),
              child: ListView(
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 20),
                  _buildTitleSection(),
                  const SizedBox(height: 20),

                  // Row #1: "Total Sales" + "Sold Vouchers"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCard(
                        "\€${controller.totalSales.value.toStringAsFixed(2)}",
                        "Total Sales",
                        const Color(0xFFFFC727),
                        Colors.black, // text color
                      ),
                      _buildCard(
                        "${controller.voucherStatsSold.value}",
                        "Sold Vouchers",
                        const Color(0xFF10B981),
                        Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Row #2: "Total Customers" + "Total Vouchers"
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildCard(
                        "${controller.totalCustomers.value}",
                        "Total Customers",
                        Colors.blueAccent,
                        Colors.white,
                      ),
                      _buildCard(
                        "${controller.totalVouchers.value}",
                        "All Vouchers",
                        Colors.deepPurple,
                        Colors.white,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Seller ID info card

                  const SizedBox(height: 20),

                  // Sales breakdown row (dummy filter buttons)
                  _buildSalesBreakdown(),

                  const SizedBox(height: 20),

                  // Bar Chart with real data
                  _buildGraph(barData),

                  const SizedBox(height: 20),

                  // 3-card "Voucher Stats" section
                  _buildVoucherStats(),

                  const SizedBox(height: 20),

                  // Bottom doughnut chart
                  _buildVouchersInsights(),
                ],
              ),
            ),
          );
        }),
      ),
      bottomNavigationBar: const SellerNavigationBar(),
    );
  }

  // ---------------------------------------------
  // UI / Layout Builders
  // ---------------------------------------------

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: const [
            Icon(Icons.notifications, color: Colors.grey, size: 28),
            SizedBox(width: 16),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Welcome, To Dashboard!",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        SizedBox(height: 5),
        Text(
          "Overview of Sales, Revenue,\nand Analytics",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// A row of simple timeframe filter buttons
  Widget _buildSalesBreakdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Sales Breakdown",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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

  /// Bar chart for Active / Expired / Sold
  Widget _buildGraph(List<ChartData> barData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Voucher Overview",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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

  /// 3-card "Voucher Stats": Active, Expired, Sold
  Widget _buildVoucherStats() {
    final active = controller.activeVouchers;
    final expired = controller.expiredVouchers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Voucher Stats",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // 1st row: Active & Expired
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildCard(
              "$active",
              "Active Vouchers",
              Colors.blue,
              Colors.white,
            ),
            _buildCard(
              "$expired",
              "Expired Vouchers",
              Colors.red,
              Colors.white,
            ),
          ],
        ),
        const SizedBox(height: 10),
        // 2nd row: Sold
        _buildCard(
          "${controller.voucherStatsSold.value}",
          "Sold Vouchers",
          const Color(0xFFFFC727),
          Colors.black,
        ),
      ],
    );
  }

  /// Doughnut chart toggling: Experiences vs. Excursions
  Widget _buildVouchersInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Vouchers Insights",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        _buildVoucherToggleButtons(),
        const SizedBox(height: 10),
        Obx(() {
          // Show Active vs Expired for whichever category is selected
          bool isExp = controller.isExperiencesSelected.value;
          final activeCount = isExp
              ? controller.experiencesActive
              : controller.excursionsActive;
          final expiredCount = isExp
              ? controller.experiencesExpired.value
              : controller.excursionsExpired.value;
          final categoryName = isExp ? "Experiences" : "Excursions";

          final chartData = [
            ChartData('Active', activeCount.toDouble(), Colors.green),
            ChartData('Expired', expiredCount.toDouble(), Colors.red),
          ];

          return SizedBox(
            height: 300,
            child: Column(
              children: [
                Text(
                  "$categoryName: Active vs Expired",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: SfCircularChart(
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.bottom,
                    ),
                    series: <CircularSeries>[
                      DoughnutSeries<ChartData, String>(
                        dataSource: chartData,
                        xValueMapper: (ChartData data, _) => data.x,
                        yValueMapper: (ChartData data, _) => data.y,
                        pointColorMapper: (ChartData data, _) => data.color,
                        dataLabelSettings: const DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                        ),
                      ),
                    ],
                    annotations: <CircularChartAnnotation>[
                      CircularChartAnnotation(
                        widget: Text(
                          "Total: ${activeCount + expiredCount}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Toggle row for "Experiences" vs "Excursions"
  Widget _buildVoucherToggleButtons() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Experiences
          Obx(() {
            bool isActive = controller.isExperiencesSelected.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleCategory(true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Experience",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),

          // Excursions
          Obx(() {
            bool isActive = !controller.isExperiencesSelected.value;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.toggleCategory(false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    "Excursion",
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Generic card widget with custom text color
  Widget _buildCard(
    String value,
    String title,
    Color backgroundColor,
    Color textColor,
  ) {
    return Container(
      width: MediaQuery.of(Get.context!).size.width * 0.42,
      height: 90,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(color: textColor)),
        ],
      ),
    );
  }

  Widget _buildFilterButton(String text, bool isSelected) {
    return ElevatedButton(
      onPressed: () {
        // If you have timeframe filters, implement them here
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.teal : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      child: Text(text),
    );
  }
}

/// Helper data class for charts
class ChartData {
  final String x;
  final double y;
  final Color color;

  ChartData(this.x, this.y, this.color);
}
