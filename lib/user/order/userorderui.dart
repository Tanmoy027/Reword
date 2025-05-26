import 'package:flutter/material.dart';
import '../usernavbar/usernavigationbar.dart';
import 'userordercontroller.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderHistoryController _controller = OrderHistoryController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final orders = await _controller.fetchBuyerOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load orders: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? const Center(child: Text('No orders found'))
              : RefreshIndicator(
                  onRefresh: _loadOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _orders.length,
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      final sellerId = order['sellerId'];
                      final storeName =
                          sellerId['storeName'] ?? 'Unknown Store';
                      final vouchers = order['vouchers'] as List<dynamic>;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Text(
                              'Order from $storeName',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          ...vouchers.map((voucher) {
                            final voucherDetails = voucher['voucherId'];
                            final title =
                                voucherDetails['title'] ?? 'Unnamed Voucher';
                            final couponCode =
                                voucherDetails['couponCode'] ?? 'N/A';
                            final expiryDate =
                                DateTime.parse(voucher['expiryDate']);
                            final purchaseDate =
                                DateTime.parse(voucher['purchaseDate']);
                            final status = voucher['status'] ?? 'Unknown';
                            final isExpired =
                                expiryDate.isBefore(DateTime.now());

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Center(
                                            child: Icon(
                                              Icons.card_giftcard,
                                              size: 32,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                title,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'From: $storeName',
                                                style: TextStyle(
                                                  color: Colors.grey[700],
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              // Coupon Code Row
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.code,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Coupon Code: $couponCode',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.calendar_today,
                                                    size: 14,
                                                    color: Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Purchased: ${_formatDate(purchaseDate)}',
                                                    style: TextStyle(
                                                      color: Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.event_available,
                                                    size: 14,
                                                    color: isExpired
                                                        ? Colors.red
                                                        : Colors.grey[600],
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'Expires: ${_formatDate(expiryDate)}',
                                                    style: TextStyle(
                                                      color: isExpired
                                                          ? Colors.red
                                                          : Colors.grey[600],
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isExpired
                                                ? Colors.red
                                                : Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Text(
                                            isExpired ? 'Expired' : status,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {
                                            // Show voucher details
                                            _showVoucherDetails(
                                                context, voucher, storeName);
                                          },
                                          icon: const Icon(
                                            Icons.visibility_outlined,
                                            size: 18,
                                            color: Colors.blue,
                                          ),
                                          label: const Text(
                                            'View Details',
                                            style:
                                                TextStyle(color: Colors.blue),
                                          ),
                                        ),
                                        if (!isExpired)
                                          TextButton.icon(
                                            onPressed: () {
                                              // Download or share voucher
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Downloading voucher...'),
                                                  duration:
                                                      Duration(seconds: 2),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.download_outlined,
                                              size: 18,
                                              color: Colors.blue,
                                            ),
                                            label: const Text(
                                              'Download',
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
      bottomNavigationBar: const UserNavigationBar(),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showVoucherDetails(
      BuildContext context, Map<String, dynamic> voucher, String storeName) {
    final voucherDetails = voucher['voucherId'];
    final title = voucherDetails['title'] ?? 'Unnamed Voucher';
    final couponCode = voucherDetails['couponCode'] ?? 'N/A';
    final expiryDate = DateTime.parse(voucher['expiryDate']);
    final purchaseDate = DateTime.parse(voucher['purchaseDate']);
    final status = voucher['status'] ?? 'Unknown';
    final isExpired = expiryDate.isBefore(DateTime.now());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Store: $storeName'),
            const SizedBox(height: 8),
            Text('Coupon Code: $couponCode'),
            const SizedBox(height: 8),
            Text('Status: $status'),
            const SizedBox(height: 8),
            Text('Purchase Date: ${_formatDate(purchaseDate)}'),
            const SizedBox(height: 8),
            Text(
              'Expiry Date: ${_formatDate(expiryDate)}',
              style: TextStyle(
                color: isExpired ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isExpired ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isExpired ? 'EXPIRED' : 'ACTIVE',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          if (!isExpired)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Downloading voucher...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: const Text('Download'),
            ),
        ],
      ),
    );
  }
}
