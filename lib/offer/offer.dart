import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Offer {
  final String title;
  final String description;
  final double price;
  final String expiryDate;

  Offer({
    required this.title,
    required this.description,
    required this.price,
    required this.expiryDate,
  });
}

class OfferController extends GetxController {
  var offers = <Offer>[
    Offer(
      title: "King Spa & Sauna NJ",
      description: "Enjoy a romantic dinner at a top restaurant",
      price: 50,
      expiryDate: "2023-12-31",
    ),
    Offer(
      title: "Adventure Park",
      description: "Thrilling rides and fun for the whole family",
      price: 40,
      expiryDate: "2024-01-31",
    ),
  ].obs;
}

class OfferScreen extends StatelessWidget {
  final OfferController controller = Get.put(OfferController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Offers"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Obx(
          () => ListView.builder(
            itemCount: controller.offers.length,
            itemBuilder: (context, index) {
              final offer = controller.offers[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    offer.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Container(
                    padding: EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          offer.description,
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "€${offer.price}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        ),
                        Text(
                          "Expires: ${offer.expiryDate}",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: BorderSide(color: Colors.black),
                                ),
                                onPressed: () {},
                                icon: Icon(Icons.account_balance_wallet,
                                    color: Colors.black),
                                label: Text("Add to Wallet",
                                    style: TextStyle(color: Colors.black)),
                              ),
                            ),
                            SizedBox(width: 10),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.black),
                              ),
                              onPressed: () {},
                              icon: Icon(Icons.card_giftcard,
                                  color: Colors.black),
                              label: Text("Gift",
                                  style: TextStyle(color: Colors.black)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
