import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'accessibility_service.dart';

class ResultPage extends StatefulWidget{
  final String imagePath;
  const ResultPage({super.key, required this.imagePath});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> with RouteAware {
  bool _loading = true;
  List<Map<String, dynamic>> _result = [];
  String _speechText = "";
  double? _imageWidth;
  double? _imageHeight; 

  @override
  void initState() {
    super.initState();
    _sendImage();
  }

  Future<void> _sendImage() async {
    setState(() {
      _loading = true;
    });

    final speechProvider = Provider.of<SpeechProvider>(context, listen: false);

		// Convertendo imagem para base64
    File imageFile = File(widget.imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();
    String base64Image = base64Encode(imageBytes);

    final decodedImage = await decodeImageFromList(imageBytes);
    _imageWidth = decodedImage.width.toDouble();
    _imageHeight = decodedImage.height.toDouble();

    try {
    	print('Enviando imagem...');
      var response = await http.post(
        Uri.parse('http://10.0.2.2:5000/process_image'),
        // Uri.parse('https://api-flask-yolo.onrender.com/upload'),
        body: jsonEncode({'image': base64Image}),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 90));
      print('Recebeu resposta');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> responseData = data["resultados"];

        setState(() {
          _speechText = data["descricao"];
          _result = List<Map<String, dynamic>>.from(responseData);
          _loading = false;
        });

        await speechProvider.speak(_speechText);

      } else {
				_showRetryDialog("Erro ao processar imagem: ${response.statusCode}");
      }
    } catch (e) {
      print('Erro ao enviar imagem: $e');
      _showRetryDialog("Erro de conexão ou tempo limite excedido.");
    }
  }

	// Função para exibir diálogo de erro com opção de tentar novamente
  void _showRetryDialog(String message) {
    setState(() {
      _loading = false;
    });

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erro'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              },
            ),
            TextButton(
              child: Text('Tentar novamente'),
              onPressed: () {
                Navigator.of(context).pop();
                _sendImage();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOverlayedImage() {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _imageWidth,
        height: _imageHeight,
        child: Stack(
          children: [
            Semantics(
              label: 'Imagem com objetos detectados',
              image: true,
              child: Image.file(File(widget.imagePath)),
            ),
            for (var obj in _result) _buildLabel(obj),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(Map<String, dynamic> obj) {
    final List<int> box = List<int>.from(obj['box']);
    final double x1 = box[0].toDouble();
    final double y1 = box[1].toDouble();
    final double x2 = box[2].toDouble();
    final double y2 = box[3].toDouble();

    final double centerX = (x1 + x2) / 2;
    final double centerY = (y1 + y2) / 2;

    final text = obj['class'];
    final double distance = (obj['distance'] as num).toDouble();

    final textSpan = TextSpan(
      text: '${obj['class']} ${obj['distance'].toStringAsFixed(1)} m',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 105,
        fontWeight: FontWeight.bold,
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final double textWidth = textPainter.width + 20;
    final double textHeight = textPainter.height;

    final double left =
        (centerX - textWidth / 2).clamp(0.0, (_imageWidth ?? 0) - textWidth);
    final double top =
        (centerY - textHeight / 2).clamp(0.0, (_imageHeight ?? 0) - textHeight);

    return Positioned(
      left: left,
      top: top,
      child: Semantics(
        label: '$text detectado a ${distance.toStringAsFixed(1)} metros',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Text.rich(textSpan),
        ),
      )
    );
  }

  Widget _buildLoadingFeedback() {
    // Fala apenas uma vez
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechProvider = Provider.of<SpeechProvider>(context, listen: false);
      speechProvider.speak("Aguarde um momento, a imagem está sendo processada");
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Semantics(
            label: 'Imagem sendo processada. Por favor, aguarde.',
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF062757)),
              strokeWidth: 6,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'Aguarde um momento\nA imagem está sendo processada...',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading:  Tooltip(
            message: 'Voltar',
            child: IconButton(
              tooltip: 'Voltar para menu inicial',
              icon: Icon(Icons.arrow_back, color: Color(0xFF062757), size: 36),
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false), // Voltar para a tela inicial
            ),
          ),
      ),
      body: _loading
        ? _buildLoadingFeedback() // Exibe indicador de carregamento
        : Center(child: _buildOverlayedImage())
    );
  }
}
