import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GenderProvider with ChangeNotifier {
  String _gender = "male"; // default gender

  String get gender => _gender;

  // Method to load gender from shared preferences
  Future<void> loadGender() async {
    final prefs = await SharedPreferences.getInstance();
    _gender = prefs.getString('gender') ?? 'male';
    notifyListeners();
  }

  // Method to set and save gender
  Future<void> setGender(String newGender) async {
    if (_gender != newGender) {
      _gender = newGender;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gender', newGender);
      notifyListeners();
    }
  }
}
