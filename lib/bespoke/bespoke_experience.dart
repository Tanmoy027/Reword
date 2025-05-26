import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'bespoke_experience_controller.dart';

class BespokeExperiencePage extends StatelessWidget {
  final BespokeExperienceController controller =
      Get.put(BespokeExperienceController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Request Bespoke Experience",
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Request Bespoke Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                  "Tell us about your dream experience and we’ll create a custom plan just for you.",
                  style: TextStyle(color: Colors.grey)),

              SizedBox(height: 15),

              // Number of People Input
              TextField(
                controller: controller.numberOfPeople,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Number of People",
                  prefixIcon: Icon(Icons.group),
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // Date Pickers
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          _selectDate(context, controller.setStartDate),
                      child:
                          _buildDateField("Start Date", controller.startDate),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context, controller.setEndDate),
                      child: _buildDateField("End Date", controller.endDate),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 15),

              // Experience Description
              TextField(
                controller: controller.experienceDetails,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "What would you like to do?",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 15),

              // Preferred Contact Method
              Text("Preferred Contact Method",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 5),
              Column(
                children: [
                  _buildRadioOption("Email", Icons.email, controller),
                  _buildRadioOption("Phone", Icons.phone, controller),
                ],
              ),

              SizedBox(height: 15),

              // Email Address
              TextField(
                controller: controller.emailAddress,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                ),
              ),

              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: () {
                  Get.snackbar("Success", "Request Submitted Successfully!");
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text("Request Quote",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateField(String label, RxString dateValue) {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today, size: 18, color: Colors.black54),
              SizedBox(width: 10),
              Text(
                dateValue.value.isEmpty ? label : dateValue.value,
                style: TextStyle(
                    color:
                        dateValue.value.isEmpty ? Colors.grey : Colors.black),
              ),
            ],
          ),
        ));
  }

  Widget _buildRadioOption(
      String label, IconData icon, BespokeExperienceController controller) {
    return Obx(() => ListTile(
          title: Text(label),
          leading: Icon(icon, color: Colors.black),
          trailing: Radio<String>(
            value: label,
            groupValue: controller.preferredContact.value,
            onChanged: (value) {
              controller.setPreferredContact(value!);
            },
          ),
          onTap: () => controller.setPreferredContact(label),
        ));
  }

  Future<void> _selectDate(
      BuildContext context, Function(String) setDate) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setDate("${picked.day}/${picked.month}/${picked.year}");
    }
  }
}
