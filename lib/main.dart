import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // Importa las opciones de Firebase
import 'Vista/SocioVista.dart'; // Importa la vista de Socios

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegura la inicialización de Flutter
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Inicializa Firebase
  );
  runApp(const MyApp()); // Inicia la aplicación
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Firebase Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema principal
      ),
      home: const MyHomePage(title: 'Usuarios'), // Pantalla principal
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _situacionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _situacionController,
              decoration: const InputDecoration(labelText: 'Situación (socio/deudor)'),
            ),
            ElevatedButton(
              onPressed: () {
               
              },
              child: const Text('Agregar Usuario'),
            ),
            ElevatedButton(
              onPressed: () {
                
              },
              child: const Text('Ver Usuarios'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SocioVista()),
                );
              },
              child: const Text('Ver Socios'),
            ),
          ],
        ),
      ),
    );
  }
}