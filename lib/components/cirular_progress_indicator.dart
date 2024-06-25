import 'package:flutter/material.dart';

void Circular_ProgressIndicator(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => Center(child: CircularProgressIndicator(color: Colors.black))
  );
}