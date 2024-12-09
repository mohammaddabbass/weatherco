import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:weatherco/pages/home_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
      return MaterialApp(
      title: 'Weatherco',
      theme: ThemeData(
        // fontFamily: 'MyCustomFont',
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF87CEEB)), // Sky blue color
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }
}
