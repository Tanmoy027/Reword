import 'package:get/get.dart';
import 'package:flutter/material.dart';

class BespokeExperienceController extends GetxController {
  // Using Rx to make it observable
  var numberOfPeople = TextEditingController();
  var startDate = "".obs;
  var endDate = "".obs;
  var experienceDetails = TextEditingController();
  var emailAddress = TextEditingController();
  var preferredContact = "Email".obs; // Default to Email

  void setStartDate(String date) {
    startDate.value = date;
  }

  void setEndDate(String date) {
    endDate.value = date;
  }

  void setPreferredContact(String contact) {
    preferredContact.value = contact;
  }
}
