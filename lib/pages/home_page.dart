import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherco/providers/weather_provider.dart';

class HomePage extends StatelessWidget {
  double? _deviceHeight, _deviceWidth;
  final String _cityName = 'Beirut';

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider(
      create: (context) =>
          WeatherProvider(cityName: _cityName, context: context),
      child: Builder(builder: (context) {
        return _buildUI(context);
      }),
    );
  }

  Widget _buildUI(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceHeight! * 0.12,
        backgroundColor: Colors.blue,
        leading: const Icon(
          Icons.wb_sunny,
          color: Colors.yellow,
          size: 40,
        ),
        titleSpacing: 0,
        title: const Text(
          "Weatherco",
          style: TextStyle(
            color: Colors.white,
            fontSize: 35,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: weatherProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: weatherUI(context),
            ),
      floatingActionButton: _refreshButton(context),
    );
  }

  Widget weatherUI(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        searchBar(context),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _displayWeather(context),
            _country(context),
          ],
        ),
        _days(context)
      ],
    );
  }

  Widget searchBar(BuildContext context) {
    return card(
      _deviceWidth! * 0.90,
      _deviceHeight! * 0.07,
      Center(
        child: TextField(
          decoration: const InputDecoration(
            labelText: "Enter a City",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              var _value = value[0].toUpperCase() + value.substring(1);
              Provider.of<WeatherProvider>(context, listen: false)
                  .updateCityName(_value);
            }
          },
        ),
      ),
      40,
    );
  }

  Widget _displayWeather(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return card(
        _deviceWidth! * 0.45,
        _deviceHeight! * 0.20,
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.network(
              height: _deviceHeight! * 0.14,
              width: _deviceWidth! * 0.30,
              'https://openweathermap.org/img/wn/${weatherProvider.weatherDataForNextDays[0]['data'][0]['weather'][0]['icon']}@2x.png',
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.error_outline_rounded),
            ),
            Text(
              "${weatherProvider.weatherDataForNextDays[0]['data'][0]['main']['temp'].toString()}°C",
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        30);
  }

  Widget _country(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return card(
      _deviceWidth! * 0.45,
      _deviceHeight! * 0.20,
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.red,
                size: 25,
              ),
              Text(
                weatherProvider.cityName,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            "min: ${weatherProvider.weatherDataForNextDays[0]['data'][0]['main']['temp_min'].toString()} | max: ${weatherProvider.weatherDataForNextDays[0]['data'][0]['main']['temp_max'].toString()}",
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
          ),
          Text(weatherProvider.weatherDataForNextDays[0]['date']),
        ],
      ),
      30,
    );
  }

  Widget _days(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return card(
      _deviceWidth! * 0.90,
      _deviceHeight! * 0.45,
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        children: [
          _daysList(context),
        ],
      ),
      30,
    );
  }

  Widget _daysList(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    return Expanded(
      // Wrap ListView.builder in Expanded
      child: ListView.separated(
        itemCount: weatherProvider.weatherDataForNextDays.length - 1,
        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey, // Color of the line
          thickness: 1, // Thickness of the line
          indent: 20, // Indent from the left edge
          endIndent: 20, // Indent from the right edge
        ),
        itemBuilder: (context, index) {
          var weather = weatherProvider.weatherDataForNextDays[index + 1];
          var date = weather['date'];
          var dayData =
              weather['data'][0]; // Take the first data entry (can be adjusted)

          // Extract the weather details you want to display
          var temp = dayData['main']['temp'].toString();
          var description = dayData['weather'][0]['description'];
          var windSpeed = dayData['wind']['speed'].toString();

          return Column(
            children: [
              ListTile(
                title: Center(
                  child: Text(
                    'Date: $date',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                subtitle: Text(
                  'Temp: $temp°C | $description | Wind Speed: $windSpeed m/s',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _refreshButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        Provider.of<WeatherProvider>(context, listen: false)
            .getWeatherDetails();
      },
      backgroundColor: Colors.blue,
      child: const Icon(Icons.refresh, color: Colors.white),
    );
  }

  Widget card(double width, double height, Widget child, double radius) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: child,
    );
  }
}
