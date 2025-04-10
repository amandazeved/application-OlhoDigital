import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'result_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with RouteAware {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(FlashMode.auto);
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null) return;

    try {
      final XFile photo = await _cameraController!.takePicture();

      // Salva a foto no armazenamento do app
      final directory = await getApplicationDocumentsDirectory();
      final String filePath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(photo.path).copy(filePath);

      // Vai para a tela de exibição da foto
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(imagePath: filePath)),
      );
    } catch (e) {
      print('Erro ao tirar foto: $e');
    }
  }

  // Apenas para o emulador
  // ignore: unused_element
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultPage(imagePath: pickedFile.path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(),
      ); // Mostra um carregamento enquanto a câmera liga
    }

    return Scaffold(
      body: Stack(
      children: [
        // Câmera ocupa toda a tela
        Positioned.fill(
          child: Semantics(
            label: 'Câmera',
            child: CameraPreview(_cameraController!),
          ),
        ),

        // botao de voltar
        Positioned(
          top: 50,
          left: 10,
          child: Center(
            child: Tooltip(
                message: 'Voltar',
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF062757), size: 36),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Voltar para menu inicial',
                ),
              ),
            ),
        ),

        // Botão de tirar foto
        Positioned(
          bottom: 80,
          left: 0,
          right: 0,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Apenas para o emulador
                // Tooltip(
                //   message: 'Abrir galeria',
                //   child: FloatingActionButton(
                //     tooltip: 'Abrir galeria',
                //     backgroundColor: Colors.grey[300],
                //     onPressed: _pickImageFromGallery,
                //     child: Icon(Icons.photo, color: Colors.black, size: 45),
                //   ),
                // ),
                Tooltip(
                  message: 'Tirar foto',
                  child: FloatingActionButton(
                    tooltip: 'Tirar foto',
                    backgroundColor: Colors.white,
                    onPressed: _takePhoto,
                    shape: const CircleBorder(),
                    elevation: 4,
                    child: const Icon(Icons.camera_alt, color: Colors.black, size: 45),
                  ),
                ),
              ],
            )
          ),
        ),
      ],
    ),
  );
  }
}
