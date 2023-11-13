import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class Weather {
  final String description;
  final double temperature;
  final String iconCode;

  Weather({
    required this.description,
    required this.temperature,
    required this.iconCode,
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: WeatherPage(),
    );
  }
}

class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  final TextEditingController _cityController = TextEditingController();
  Weather? currentWeather;
  String errorMessage = '';

  Future<void> fetchWeatherData(String city) async {
    final apiKey = '4bcf8a1f54ca91abc82e2134335d4c55';
    final apiUrl =
        'http://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final weather = Weather(
        description: jsonData['weather'][0]['description'],
        temperature: jsonData['main']['temp'],
        iconCode: jsonData['weather'][0]['icon'],
      );

      setState(() {
        currentWeather = weather;
        errorMessage = '';
      });
    } else {
      setState(() {
        currentWeather = null;
        errorMessage = 'Cidade não encontrada';
      });
    }
  }

  String getWeatherDescription(String description) {
    // Translate English descriptions to Portuguese
    switch (description.toLowerCase()) {
      case 'clear sky':
        return 'Céu Limpo';
      case 'few clouds':
        return 'Poucas Nuvens';
      case 'scattered clouds':
        return 'Nuvens Esparsas';
      case 'broken clouds':
        return 'Nuvens Quebradas';
      case 'shower rain':
        return 'Chuva Leve';
      case 'rain':
        return 'Chuva';
      case 'thunderstorm':
        return 'Tempestade';
      case 'snow':
        return 'Neve';
      case 'mist':
        return 'Névoa';
      default:
        return 'Nublado';
    }
  }

  Color getBackgroundColor(String iconCode) {
    switch (iconCode) {
      case '01d': // Clear sky (day)
      case '01n': // Clear sky (night)
        return Colors.yellow; // Yellow for sunny
      case '02d': // Few clouds (day)
      case '02n': // Few clouds (night)
      case '03d': // Scattered clouds
      case '03n':
      case '04d': // Broken clouds
      case '04n':
        return Colors.grey; // Gray for cloudy
      case '09d': // Shower rain
      case '09n':
      case '10d': // Rain
      case '10n':
        return Colors.lightBlue; // Light blue for rain
      default:
        return Colors.white; // Default background color
    }
  }

  String getWeatherIcon(String iconCode) {
    switch (iconCode) {
      case '01d':
      case '01n':
        return '☀️';
      case '02d':
      case '02n':
        return '⛅';
      case '03d':
      case '03n':
        return '☁️';
      case '04d':
      case '04n':
        return '☁️☁️';
      case '09d':
      case '09n':
        return '🌧️';
      case '10d':
      case '10n':
        return '🌧️☔';
      case '11d':
      case '11n':
        return '⛈️';
      case '13d':
      case '13n':
        return '❄️';
      case '50d':
      case '50n':
        return '🌫️';
      default:
        return '❓';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('                          Climatiza'),
        backgroundColor: Colors.green,
      ),
      body: Container(
        color: currentWeather != null
            ? getBackgroundColor(currentWeather!.iconCode)
            : Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  labelText: 'Pesquise sua cidade aqui para ver o clima dela',
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (_cityController.text.isNotEmpty) {
                    fetchWeatherData(_cityController.text);
                  } else {
                    setState(() {
                      errorMessage = 'Por favor, insira uma cidade válida';
                    });
                  }
                },
                child: Text('Pesquisar'),
              ),
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                  ),
                ),
              if (currentWeather != null)
                Column(
                  children: [
                    Text(
                      'Previsão do Tempo em ${_cityController.text}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      '${currentWeather!.temperature.toStringAsFixed(1)}°C',
                      style: TextStyle(fontSize: 36),
                    ),
                    SizedBox(height: 10),
                    Text(
                      getWeatherDescription(currentWeather!.description),
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(height: 20),
                    Text(
                      getWeatherIcon(currentWeather!.iconCode),
                      style: TextStyle(fontSize: 40),
                    ),
                  ],
                )
              else
                SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
