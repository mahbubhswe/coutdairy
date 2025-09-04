import 'package:flutter/material.dart';

Widget appInfoRow(String label, String value) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: const TextStyle(fontSize: 14)),
      Text(value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    ],
  );
}
