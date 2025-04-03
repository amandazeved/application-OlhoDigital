import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'result_page.dart';
import 'main.dart';
import 'accessibility_service.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute){
      routeObserver.subscribe(this, route); // Registra a página no RouteObserver
    }
  }

  @override
  void didPush() {
    super.didPush();
    print("Tela de camere foi exibida! (didPush)");
    AccessibilityService().speak("Posicione o celular para poder tirar a foto");
  }

  // @override
  // void didPopNext() {
  //   super.didPopNext();
  //   print("Usuário voltou para a tela de camera! (didPopNext)");
  //   AccessibilityService().speak("Posicione o celular para poder tirar a foto");
  // }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _cameraController = CameraController(cameras![0], ResolutionPreset.high);
      await _cameraController!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    routeObserver.unsubscribe(this); // Remove o registro ao sair da tela
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null) return;

    try {
      final XFile photo = await _cameraController!.takePicture();
      final File imageFile = File(photo.path);

      // Salva a foto no armazenamento do app
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await imageFile.copy(filePath);

      // Vai para a tela de exibição da foto
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(imagePath: filePath),
        ),
      );
    } catch (e) {
      print('Erro ao tirar foto: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(imagePath: pickedFile.path),
        ),
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
      appBar: AppBar(
        leading: Semantics(
          label: 'Voltar para tela inicial',
          button: true,
          child: Tooltip(
            message: 'Voltar',
            child: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          CameraPreview(_cameraController!), // Mostra a câmera na tela
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Semantics(
                    label: 'Escolher uma foto da galeria',
                    button: true,
                    child: Tooltip(
                      message: 'Abrir galeria',
                      child: FloatingActionButton(
                        heroTag: 'gallery_button',
                        backgroundColor: Colors.grey[300],
                        onPressed: _pickImageFromGallery,
                        child: Icon(Icons.photo, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                  Semantics(
                    label: 'Tirar uma foto',
                    button: true,
                    child: Tooltip(
                      message: 'Tirar foto',
                      child: FloatingActionButton(
                        heroTag: 'camera_button',
                        backgroundColor: Colors.white,
                        onPressed: _takePhoto,
                        child: Icon(Icons.camera, color: Colors.black, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
