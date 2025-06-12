import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastMessage {
  void show(String text) {
    Fluttertoast.showToast(
      msg: text,
      fontSize: 16,
      gravity: ToastGravity.CENTER,
      backgroundColor: Colors.black.withOpacity(.5),
    );
  }
}
