// In admin_clients_customers.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'dart:typed_data';

import '../admin controller/admin_clients_customers_controller.dart';
import '../admin naviagtionbar/admin_bottom_navigation.dart';

class AdminClientsCustomersPage extends StatelessWidget {
  final AdminClientsCustomersController controller =
      Get.put(AdminClientsCustomersController());

  // Function to export customer emails to PDF
  Future<void> exportCustomerEmailsToPdf() async {
    final pdf = pw.Document();

    // Add customer emails in the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            children: [
              pw.Text('Customer Emails', style: pw.TextStyle(fontSize: 20)),
              pw.SizedBox(height: 20),
              pw.Column(
                children: controller.customers
                    .map((customer) => pw.Text(customer.email))
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    // Convert to PDF and trigger printing
    final Uint8List bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (format) => bytes);
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF116A68),
          ),
          SizedBox(height: 16),
          Text(
            "Loading clients and customers data...",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Clients & Customers',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        // Show loading screen while data is being fetched
        if (controller.isLoading.value) {
          return _buildLoadingView();
        }

        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Clients",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Column(
                  children: controller.clients
                      .map((client) => Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: InkWell(
                              onTap: () {
                                // Navigate to seller dashboard when client name is clicked
                                controller.navigateToAdminSellerDashboardView(
                                    client.sellerId);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          client.name,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.settings),
                                              onPressed: () {
                                                // Handle settings
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Text(client.email,
                                        style:
                                            TextStyle(color: Colors.grey[600])),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        const Text("Published"),
                                        const Spacer(),
                                        Switch(
                                          value: client.published,
                                          onChanged: (value) {
                                            controller.togglePublished(client);
                                          },
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Text("Active"),
                                        const Spacer(),
                                        Switch(
                                          value: client.active,
                                          onChanged: (value) {
                                            controller.toggleActive(client);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Customers",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListView.separated(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: controller.customers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return InkWell(
                      onTap: () {
                        // Navigate to seller dashboard when customer email is clicked
                        controller.navigateToAdminSellerDashboardView(
                            customer.sellerId);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              customer.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              customer.email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                            const Divider(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: exportCustomerEmailsToPdf, // Trigger PDF export
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF158482),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text(
                      'Export Customer Emails',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: AdminBottomNavigation(),
    );
  }
}
