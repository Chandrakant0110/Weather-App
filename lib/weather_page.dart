import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additional_info.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  Future<Map<String, dynamic>> getCurrentWeather() async {
    final http.Response res;
    final data;
    try {
      String cityName = 'Raipur';
      String apiKey = '42bf2312262f46929a6132333242001';
      res = await http.get(
        Uri.parse(
            'http://api.weatherapi.com/v1/forecast.json?key=$apiKey&q=$cityName&days=1&aqi=no&alerts=no'),
      );
      data = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw 'An unexpected error occured';
        // print(data['current']['temp_c']);
        // data['current']['temp_c'];
      }
      return data;
    } catch (e) {
      throw e.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          print(snapshot);
          print(snapshot.data);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }

          if (snapshot.hasError) {
            throw Text(snapshot.error.toString());
          }

          final data = snapshot.data!;
          final currWeatherData = data['current'];
          final currentTemp = currWeatherData['temp_c'];
          final currSky = currWeatherData['condition']['text'];
          final currHumidity = currWeatherData['humidity'];
          final currWindSpeed = currWeatherData['wind_kph'];
          final currPressure = currWeatherData['pressure_mb'];

          final forecastData = data['forecast']['forecastday'][0]['hour'];
          return SafeArea(
            child: Scaffold(
              appBar: AppBar(
                title: const Center(
                  child: Text(
                    'Weather App',
                    textAlign: TextAlign.center,
                  ),
                ),
                elevation: 0,
                backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                actions: const [
                  // IconButton(
                  //   onPressed: () {
                  //     showSnackbar(context, 'Refresh', 3);
                  //   },
                  //   icon: const Icon(Icons.refresh_outlined),
                  // ),
                ],
              ),
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main card
                      SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 10,
                                sigmaY: 10,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$currentTemp°C',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Icon(
                                      currSky == 'Partly cloudy'
                                          ? Icons.cloud
                                          : Icons.sunny,
                                      size: 64,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      currSky,
                                      style: TextStyle(
                                        fontSize: 20,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Text(
                          'Weather Forecast',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // SingleChildScrollView(
                      //   scrollDirection: Axis.horizontal,
                      //   child: Row(
                      //     children: [
                      //       for (int i = 0; i < 13; i++)
                      //         HourlyForecastItem(
                      //           time: forecastData[i]['time'],
                      //           icon: Icons.cloud,
                      //           temperature:
                      //               forecastData[i]['temp_c'].toString(),
                      //         ),
                      //     ],
                      //   ),
                      // ),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 13,
                          itemBuilder: (context, index) {
                            final time =
                                DateTime.parse(forecastData[index]['time']);

                            return HourlyForecastItem(
                              time: DateFormat.j().format(time),
                              icon: Icons.cloud,
                              temperature:
                                  '${forecastData[index]['temp_c'].toString()}°C',
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 10,
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: Text(
                          'Additional Information',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          AdditionalInfoItem(
                            icon: Icons.water_drop,
                            label: 'Humdity',
                            value: '$currHumidity%',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.air,
                            label: 'Wind Speed',
                            value: '${currWindSpeed}kmph',
                          ),
                          AdditionalInfoItem(
                            icon: Icons.beach_access,
                            label: 'Pressure',
                            value: '${currPressure}mBar',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  setState(() {});
                  showSnackbar(context, 'Refresh', 1);
                },
                // autofocus: true,
                // isExtended: true,
                hoverColor: const Color.fromARGB(255, 226, 157, 238),
                tooltip: 'Tap to Refresh',
                child: const Icon(Icons.refresh_outlined),
              ),
            ),
          );
        });
  }

  void showSnackbar(BuildContext context, String label, int second) {
    final snackBar = SnackBar(
      content: Text('You Pressed $label button!'),
      duration: Duration(seconds: second), // Adjust the duration as needed
      action: SnackBarAction(
        label: label,
        onPressed: () {
          // Code to execute when the "Close" action is pressed
        },
      ),
    );

    // Display the Snackbar
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
