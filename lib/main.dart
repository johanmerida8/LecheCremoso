// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Seating',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SeatingScreen(),
    );
  }
}

class SeatingScreen extends StatefulWidget {
  const SeatingScreen({super.key});

  @override
  _SeatingScreenState createState() => _SeatingScreenState();
}

class _SeatingScreenState extends State<SeatingScreen> {
  final TextEditingController _passenger = TextEditingController();
  final TextEditingController _location = TextEditingController();

  List<Map<String, String>> countries = [];
  Map<String, dynamic>? selectedCountry;

  String filter = '';

  @override
  void initState() {
    super.initState();
    fetchCountries().then((List<Map<String, String>> countryData) {
      setState(() {
        countries = countryData;
        selectedCountry = countries[0];
        selectedDestination = {
          'index': 0,
          'destination': destinations[0],
        };
      });
    });
  }

  Map<String, dynamic>? selectedDestination;

  List<Map<String, String>> destinations = [
    {
      'name': 'Miami',
      'region': 'Americas',
    },
    {
      'name': 'New York',
      'region': 'Americas',
    },
    {
      'name': 'London',
      'region': 'Europe',
    },
    {
      'name': 'Paris',
      'region': 'Europe',
    },
  ];

  Future<List<Map<String, String>>> fetchCountries() async {
    final res = await http.get(Uri.parse('https://restcountries.com/v3.1/all'));

    if (res.statusCode == 200) {
      List<dynamic> countriesJson = jsonDecode(res.body);
      List<Map<String, String>> countryData = countriesJson
          .map((country) => {
                'name': country['name']['common'] as String,
                'capital':
                    country['capital'] != null && country['capital'].isNotEmpty
                        ? country['capital'][0] as String
                        : '',
                'utc': (country['timezones'] as List<dynamic>).isEmpty
                    ? ''
                    : country['timezones'][0] as String,
                'region': country['region'] as String,
              })
          .toList();
      // Sort the list of country data by name
      countryData.sort((a, b) => a['name']!.compareTo(b['name']!));
      return countryData;
    } else {
      throw Exception('Failed to load countries');
    }
  }

  List<List<String>> seats = List.generate(
      27,
      (i) => List.generate(
          i < 2
              ? 4
              : i < 7
                  ? 6
                  : i < 9
                      ? 4
                      : 6,
          (j) => 'available'));

  void reserveSeat(int row, int col) {
    setState(() {
      if (seats[row][col] == 'available') {
        // Show a dialog here asking if the user wants to buy the seat
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Seat Availability'),
              content: const Text('Do you want to reserve or buy this seat?'),
              actions: [
                TextButton(
                  child: const Text('Reserve'),
                  onPressed: () {
                    setState(() {
                      seats[row][col] = 'reserved';
                    });
                    Navigator.of(context).pop();
                    //start a timer of 5 minutes
                    Future.delayed(const Duration(minutes: 5), () {
                      if (seats[row][col] == 'reserved') {
                        returnSeat(row, col);
                      }
                    });
                  },
                ),
                TextButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    buySeat(row, col);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else if (seats[row][col] == 'reserved') {
        // Show a dialog here asking if the user wants to return the seat
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Seat Confirmation'),
              content: const Text('Do you want to return this seat or buy it?'),
              actions: [
                TextButton(
                  child: const Text('Return'),
                  onPressed: () {
                    returnSeat(row, col);
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Buy'),
                  onPressed: () {
                    buySeat(row, col);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    });
  }

  void buySeat(int row, int col) {
    setState(() {
      seats[row][col] = 'sold';
    });
  }

  void returnSeat(int row, int col) {
    setState(() {
      seats[row][col] = 'available';
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredCountries = countries
        .where((country) =>
            (country['name']!.toLowerCase().contains(filter.toLowerCase()) ||
                country['capital']!
                    .toLowerCase()
                    .contains(filter.toLowerCase())) &&
            (country['region'] == 'Americas' || country['region'] == 'Europe'))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flight Seating'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _passenger,
                decoration: const InputDecoration(
                  labelText: 'Passenger Name',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                ),
                onChanged: (value) {
                  setState(() {
                    filter = value;
                    if (filteredCountries.isNotEmpty) {
                      selectedCountry = filteredCountries[0];
                    } else {
                      selectedCountry = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 20),
              filter.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text('${filteredCountries[index]['name']}'),
                          subtitle: Text(
                              '${filteredCountries[index]['capital']} - ${filteredCountries[index]['utc']}'),
                          onTap: () {
                            setState(() {
                              selectedCountry = filteredCountries[index];
                              _location.text = selectedCountry!['name']! +
                                  ' - ' +
                                  selectedCountry!['capital']! +
                                  ' - ' +
                                  selectedCountry!['utc']!;
                              filter = '';
                            });
                          },
                        );
                      })
                  : Container(),
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: selectedDestination?['index'],
                items: destinations.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, String> destination = entry.value;
                  return DropdownMenuItem<int>(
                    value: index,
                    child: Text(destination['name']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDestination = {
                      'index': value,
                      'destination': destinations[value!]
                    };
                  });
                },
              ),
              const SizedBox(height: 20),
              for (int i = 0; i < seats.length; i++)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (int j = 0; j < seats[i].length; j++)
                      if (i >= 7 && i < 9 && (j == 1 || j == 2))
                        const SizedBox(width: 40)
                      else
                        GestureDetector(
                          onTap: () => reserveSeat(i, j),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            width: 40,
                            height: 40,
                            color: seats[i][j] == 'available'
                                ? Colors.green
                                : (seats[i][j] == 'reserved'
                                    ? Colors.yellow
                                    : Colors.red),
                            child: Center(
                              child: Text(
                                '${String.fromCharCode(65 + j)}${i + 1}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
