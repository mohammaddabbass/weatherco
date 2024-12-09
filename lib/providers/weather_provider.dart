import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WeatherProvider with ChangeNotifier {
  final Dio dio = Dio();
  // String minTemp = '';
  // String maxTemp = '';
  // String temp = '';
  // String windSpeed = '';
  // String date = '';
  // String description = '';
  // String icon = '';
  String cityName = '';
  bool isLoading = false;
  BuildContext context;

  final String _apiKey = dotenv.env['OPENWEATHER_API_KEY']!;
  final String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  // A list to hold the weather data for the next 5 days
  List<Map<String, dynamic>> weatherDataForNextDays = [];

  WeatherProvider({required this.cityName, required this.context}) {
    getWeatherDetails();
  }

  void updateCityName(String newCityName) {
    cityName = newCityName;
    getWeatherDetails();
  }

  Future<void> getWeatherDetails() async {
    isLoading = true;
    notifyListeners();
    try {
      Response _response = await dio.get('$_baseUrl/forecast?q=$cityName&units=metric&appid=$_apiKey');
      var data = jsonDecode(_response.toString());
      
      // Group weather data by date
      Map<String, List<Map<String, dynamic>>> groupedWeatherData = {};

      // Loop through the list of forecasts and group them by date
      for (var entry in data['list']) {
        String forecastDate = entry['dt_txt'].split(' ')[0];  // Extract date part (YYYY-MM-DD)
        
        // If the date is already in the map, add the entry to the list for that date
        if (!groupedWeatherData.containsKey(forecastDate)) {
          groupedWeatherData[forecastDate] = [];
        }
        
        groupedWeatherData[forecastDate]!.add(entry);
      }

      // Limit the grouped data to 5 days (you can adjust this depending on your needs)
      var next5Days = groupedWeatherData.keys.take(5).toList();

      // Store the weather data for the next 5 days in a list
      weatherDataForNextDays = next5Days.map((date) {
        return {
          'date': date,
          'data': groupedWeatherData[date],
        };
      }).toList();

      print(weatherDataForNextDays);

    } catch (e) {
      print("Unable to perform a get request");
      print(e);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
