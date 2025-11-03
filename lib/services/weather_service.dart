
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  Future<Map<String, dynamic>> getWeather() async {
    // Replace with a real API call
    await Future.delayed(const Duration(seconds: 1));
    return {
      "weather": [
        {"main": "Clear", "icon": "01d"}
      ],
      "main": {"temp": 25.0}
    };
  }
}
