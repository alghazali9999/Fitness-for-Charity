import 'package:flutter/material.dart';

class GenderProvider with ChangeNotifier {
  String _gender = "male";

  String get gender => _gender;

  void setGender(String gender) {
    _gender = gender;
    notifyListeners();
  }
}
