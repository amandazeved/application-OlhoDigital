import 'package:flutter/material.dart';
import "accessibility_service.dart";
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final speechProvider = Provider.of<SpeechProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF062757),
        iconTheme: const IconThemeData(color: Colors.white),
        leading:  Tooltip(
            message: 'Voltar',
            child: IconButton(
              tooltip: 'Voltar para menu inicial',
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(), 
            ),
          ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile(
            title: const Text(
              'Ativar feedback de voz',
              style: TextStyle(fontSize: 20),
            ),
            activeColor: const Color(0xFF062757),
            value: speechProvider.speechEnabled,
            onChanged: (value) => speechProvider.set(value),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
