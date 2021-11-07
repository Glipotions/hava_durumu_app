import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hava_durumu_app/search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'daily_weather_card.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String sehir = 'ankara';
  int? sicaklik;
  var locationData;
  var woeid;
  var weatherData;
  var abbr = 'c';
  Position? position;
  List<int> temps = List.filled(5, 0);
  List<String> abbrs = List.filled(5, '');
  List<String> dates = List.filled(5, '');

  Future<void> getDeviceLocation() async {
    try {
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium);
    } catch (e) {}
    print(position);
  }

  Future<void> getLocationData() async {
    var urlLocationData = Uri.https(
        'www.metaweather.com', '/api/location/search/', {'query': sehir});
    locationData = await http.get(urlLocationData);
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
  }

  Future<void> getLocationDataLatLong() async {
    var urlLocationData = Uri.https('www.metaweather.com',
        '/api/location/search/?lattlong=${position!.latitude},${position!.longitude}');
    // {'lattlong=${position!.latitude},${position!.longitude}'});
    locationData = await http.get(urlLocationData);
    var locationDataParsed = jsonDecode(locationData.body);
    woeid = locationDataParsed[0]['woeid'];
    sehir = locationDataParsed[0]['title'];
  }

  Future<void> getLocationWeather() async {
    var urlWeather = Uri.https('www.metaweather.com', '/api/location/$woeid/');
    weatherData = await http.get(urlWeather);
    var weatherDataParsed = jsonDecode(weatherData.body);
    setState(() {
      sicaklik =
          weatherDataParsed['consolidated_weather'][0]['the_temp'].round();
      abbr = weatherDataParsed['consolidated_weather'][0]['weather_state_abbr']
          .toString();
      for (int i = 0; i < temps.length; i++) {
        temps[i] = weatherDataParsed['consolidated_weather'][i + 1]['the_temp']
            .round();
        abbrs[i] = weatherDataParsed['consolidated_weather'][i + 1]
            ['weather_state_abbr'];
        dates[i] =
            weatherDataParsed['consolidated_weather'][i + 1]['applicable_date'];
      }
    });
  }

  Future<void> initStateAsync() async {
    await getDeviceLocation();
    print('1');
    await getLocationData();
    print('2');
    getLocationWeather();
  }

  Future<void> initStateAsyncByCity() async {
    await getLocationData();
    getLocationWeather();
  }

  @override
  void initState() {
    initStateAsync();
    getDeviceLocation();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          image: DecorationImage(
        fit: BoxFit.cover,
        image: AssetImage('assets/$abbr.jpg'),
      )),
      child: sicaklik == null
          ? Center(
              child: SpinKitFadingCircle(
                itemBuilder: (BuildContext context, int index) {
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      color: index.isEven ? Colors.blueAccent : Colors.black,
                    ),
                  );
                },
              ),
            )
          : Scaffold(
              backgroundColor: Colors.transparent,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      child: Image.network(
                          'https://www.metaweather.com/static/img/weather/png/$abbr.png'),
                    ),
                    Text(
                      '$sicaklik° C',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 70,
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              blurRadius: 5,
                              offset: Offset(-3, 3),
                            ),
                          ]),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          sehir,
                          style: const TextStyle(
                            fontSize: 30,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(-3, 3),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            sehir = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SearchPage(),
                              ),
                            );
                            initStateAsyncByCity();
                            setState(() {
                              sehir = sehir;
                            });
                          },
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 120,
                    ),
                    buildDailyWeatherCards(context)
                  ],
                ),
              ),
            ),
    );
  }

  Container buildDailyWeatherCards(BuildContext context) {
    List<Widget> cards = List.empty();

    for (int i = 0; i < 5; i++) {
      cards[i] = DailyWeather(
          image: abbr[i], temp: temps[i].toString(), date: dates[i]);
    }

    return Container(
      height: 120,
      width: MediaQuery.of(context).size.width * 0.9,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: cards,
      ),
    );
  }
}
