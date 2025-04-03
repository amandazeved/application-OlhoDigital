import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'accessibility_service.dart';

class ResultPage extends StatefulWidget{
  final String imagePath;

  const ResultPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with RouteAware {
  bool _loading = true;
  List<String> _result = [];

  @override
  void initState() {
    super.initState();
    _sendImage();
  }

  Future<void> _sendImage() async {
    setState(() {
      _loading = true;
    });

    print('enviando foto');
    File imageFile = File(widget.imagePath);
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    try {
      var response = await http.post(
        Uri.parse('http://10.0.2.2:5000/upload'),
        // Uri.parse('https://api-flask-yolo.onrender.com/upload'),
        body: jsonEncode({'image': base64Image}),
        headers: {'Content-Type': 'application/json'},
      );
      print('recebeu resposta');
      if (response.statusCode == 200){
        setState(() {
          _result = List<String>.from(jsonDecode(response.body)['class']);
          _loading = false;
        });

        if (_result.isNotEmpty){
          AccessibilityService().speak("Foi identificados esses elementos na foto: ${_result.join(', ')}");
        }
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pushNamed(context, '/'), 
          icon: Icon(Icons.arrow_back),
          ),
      ),
      body: _loading
      ? Center(child: CircularProgressIndicator())
      : Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Identificado na foto:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ..._result.map((item)=> ListTile(
            leading: Icon(Icons.circle, size: 10),
            title: Text(item),
          ))
        ],
      )
    );
  }
}
