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
    final double screenWidth = MediaQuery.of(context).size.width;

     return Scaffold(
      backgroundColor: const Color(0xFFA3CCD0) ,
      body: Stack(
        children: [
          // Círculo no fundo
          Positioned(
            top: 400,
            left: -screenWidth * 0.5,
            child: Container(
              width: screenWidth * 2,
              height: screenWidth * 2,
              decoration: const BoxDecoration(
                color: Color(0xFFD9D9D9),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Logo centralizada
          Positioned(
            top: 147,
            left: (screenWidth - 259) / 2,
            child: Semantics(
              label: "Logo do aplicativo Olho Digital",
              child: SizedBox(
                width: 259,
                height: 259,
                child: Image.asset(
                  'assets/logo_olhoDigital.png', 
                  fit: BoxFit.contain,
                ),
              ),
            )
            
          ),

          // Botão para abrir camera
          Positioned(
            top: 478,
            left: (screenWidth - 200) / 2,
            child: Tooltip(
                message: 'Abrir câmera',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 50),
                    backgroundColor: const Color(0xFF062757),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/camera');
                  },
                  child: const Text(
                    'Abrir câmera', // o que vai ser lido pelo leitor de tela
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ),

          // Botão de configuracao
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              tooltip: 'Configurações',
              onPressed: () => Navigator.pushNamed(context, '/settings'), 
              icon: Icon(Icons.settings, color: Color(0xFF062757), size: 36)
            )
          ),
        ],
      ),
    );
  }
} 