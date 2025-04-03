import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware{
  
  
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vera')), // Barra superior com título
      body: Center (
        child: Semantics(
          label: 'Tirar uma foto',
          button: true,
          child: Tooltip(
            message: "Abrir câmera",
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/camera');
              },
              icon: Icon(Icons.camera),
              label: Text('Tirar uma Foto'),
            ),
          )
            
          
      ),
      ),
    );
  }
} 