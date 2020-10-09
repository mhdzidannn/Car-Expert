import 'package:flutter/material.dart';


Widget buildLoading() {
  return Container(
    color: Colors.white,
    child: Center(
      child: CircularProgressIndicator(
        strokeWidth: 10,
      ),
    ),
  );
}
