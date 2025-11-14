import 'package:flutter/material.dart';

void main() {
  runApp(const DrinkApp());
}

class DrinkApp extends StatelessWidget {
  const DrinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Drink Reminder",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int current = 0;
  int target = 2000;

  void addWater(int ml) {
    setState(() {
      current += ml;
      if (current > target) current = target;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drink Reminder"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Target: $target ml"),
            const SizedBox(height: 10),
            Text("Saat ini: $current ml",
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => addWater(200),
              child: const Text("+200 ml"),
            ),
          ],
        ),
      ),
    );
  }
}
