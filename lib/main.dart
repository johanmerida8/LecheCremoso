import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flight Seating',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SeatingScreen(),
    );
  }
}

class SeatingScreen extends StatefulWidget {
  @override
  _SeatingScreenState createState() => _SeatingScreenState();
}

class _SeatingScreenState extends State<SeatingScreen> {
  final TextEditingController _passenger = TextEditingController();
  final TextEditingController _location = TextEditingController();

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
      seats[row][col] = 'reserved';
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ),
              const SizedBox(height: 20),
              DropdownButton(
                items: [
                  const DropdownMenuItem(
                    child: Text('Server'),
                    value: '',
                  ),
                  const DropdownMenuItem(
                    child: Text('Economy Class'),
                    value: 'Economy Class',
                  ),
                ],
                onChanged: (value) {
                  print(value);
                },
              ),
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
                                : Colors.yellow,
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
