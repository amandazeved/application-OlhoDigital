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
  int selectedCameraIndex = 0;
  FlashMode _flashMode = FlashMode.auto; // Flash auto por padrão
  String _strFlashMode = "automático";
  String _strCameraMode = "traseira";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      // Escolhe a câmera traseira por padrão
      final backCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras!.first,
      );
      selectedCameraIndex = cameras!.indexOf(backCamera);

      _cameraController = CameraController(
        cameras![selectedCameraIndex],
        ResolutionPreset.high,
      );
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);
      setState(() {});
    }
  }

  Future<void> _switchCamera() async {
    if (cameras == null || cameras!.isEmpty) return;

    selectedCameraIndex = (selectedCameraIndex + 1) % cameras!.length;
    _cameraController = CameraController(
      cameras![selectedCameraIndex],
      ResolutionPreset.high,
    );
    await _cameraController!.initialize();
    await _cameraController!.setFlashMode(_flashMode);
    setState(() {});
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null) return;

    if (_flashMode == FlashMode.auto) {
      _flashMode = FlashMode.always;
    } else if (_flashMode == FlashMode.always) {
      _flashMode = FlashMode.off;
    } else {
      _flashMode = FlashMode.auto;
    }

    await _cameraController!.setFlashMode(_flashMode);
    setState(() {});
  }

  Future<void> _takePhoto() async {
    if (_cameraController == null) return;

    try {
      final XFile photo = await _cameraController!.takePicture();

      // Salva a foto no armazenamento do app
      final directory = await getApplicationDocumentsDirectory();
      final String filePath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
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
  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(imagePath: pickedFile.path),
        ),
      );
    }
  }

  IconData _getFlashIcon() {
    switch (_flashMode) {
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
        return Icons.flash_on;
      case FlashMode.off:
        return Icons.flash_off;
      default:
        return Icons.flash_auto;
    }
  }

  // Atualiza o texto descritivo do flash
  void _updateFlashModeLabel() {
    switch (_flashMode) {
      case FlashMode.auto:
        _strFlashMode = "automático";
        break;
      case FlashMode.always:
        _strFlashMode = "ligado";
        break;
      case FlashMode.off:
        _strFlashMode = "desligado";
        break;
      default:
        _strFlashMode = "automático";
    }
  }

  // Atualiza o texto descritivo da câmera
  void _updateCameraModeLabel() {
    final lensDirection = cameras?[selectedCameraIndex].lensDirection;
    switch (lensDirection) {
      case CameraLensDirection.back:
        _strCameraMode = "traseira";
        break;
      case CameraLensDirection.front:
        _strCameraMode = "frontal";
        break;
      case CameraLensDirection.external:
        _strCameraMode = "externa";
        break;
      default:
        _strCameraMode = "desconhecido";
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      // Mostra um carregamento enquanto a câmera liga
      return Center(child: CircularProgressIndicator());
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
              child: Semantics(
                label: 'Voltar',
                button: true,
                child: ExcludeSemantics(
                  child: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF062757),
                      size: 36,
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Voltar para menu inicial',
                  ),
                ),
              ),
            ),
          ),
          // Botão para trocar o modo do flash
          Positioned(
            top: 50,
            right: 80,
            child: Semantics(
              label: 'Flash $_strFlashMode: Trocar Flash',
              button: true,
              child: ExcludeSemantics(
                child: IconButton(
                  icon: Icon(_getFlashIcon(), color: Colors.white, size: 32),
                  onPressed: _toggleFlash,
                  tooltip: 'Trocar Flash',
                ),
              ),
            ),
          ),
          // Botão para trocar câmera
          Positioned(
            top: 50,
            right: 10,
            child: Semantics(
              label: 'Câmera $_strCameraMode: Trocar modo de câmera',
              button: true,
              child: ExcludeSemantics(
                child: IconButton(
                  icon: const Icon(
                    Icons.cameraswitch,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: _switchCamera,
                  tooltip: 'Trocar Câmera',
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Apenas para o emulador
                  Tooltip(
                    message: 'Abrir galeria',
                    child: FloatingActionButton(
                      tooltip: 'Abrir galeria',
                      backgroundColor: Colors.grey[300],
                      onPressed: _pickImageFromGallery,
                      child: Icon(Icons.photo, color: Colors.black, size: 45),
                    ),
                  ),
                  // Botão de tirar foto
                  Semantics(
                    label: 'Tirar foto',
                    button: true,
                    child: ExcludeSemantics(
                      child: Tooltip(
                        message: 'Tirar foto',
                        child: FloatingActionButton(
                          tooltip: 'Tirar foto',
                          backgroundColor: Colors.white,
                          onPressed: _takePhoto,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 45,
                          ),
                        ),
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
