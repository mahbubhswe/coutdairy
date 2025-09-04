import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<DateTime?> appDateTimePicker() async {
  final initial = DateTime.now();

  final pickedDate = await showDatePicker(
    context: Get.context!,
    initialDate: initial,
    firstDate: DateTime(initial.year - 5),
    lastDate: DateTime(initial.year + 5),
  );

  if (pickedDate == null) return null;

  final pickedTime = await showTimePicker(
    context: Get.context!,
    initialTime: TimeOfDay.fromDateTime(initial),
  );

  return DateTime(
    pickedDate.year,
    pickedDate.month,
    pickedDate.day,
    pickedTime?.hour ?? initial.hour,
    pickedTime?.minute ?? initial.minute,
  );
}
