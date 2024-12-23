import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<ScanScreen> {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    if (await requestCameraPermission()) {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![_selectedCameraIndex],
          ResolutionPreset.medium,
          enableAudio: false,
        );

        try {
          await _controller!.initialize();
          if (mounted) {
            setState(() {
              _isCameraInitialized = true;
            });
          }
        } on CameraException catch (e) {
          print('Error initializing camera: $e');
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No cameras found.')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission not granted.')),
        );
      }
    }
  }

  Future<bool> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isGranted) {
      return true;
    } else {
      if (await Permission.camera.request().isGranted) {
        return true;
      } else {
        if (status.isPermanentlyDenied) {
          openAppSettings();
        }
        return false;
      }
    }
  }

  Future<void> _takePicture() async {
    try {
      if (_controller != null && _controller!.value.isInitialized) {
        final XFile image = await _controller!.takePicture();

        final Directory appDocDir = await getApplicationDocumentsDirectory();
        final String imagePath =
            '${appDocDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

        await File(image.path).copy(imagePath);

        if (!mounted) return;

        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => DisplayPictureScreen(
              imagePath: imagePath,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카메라가 초기화되지 않았습니다.')),
        );
      }
    } catch (e) {
      print('Error taking picture: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 촬영 중 오류가 발생했습니다: $e')),
      );
    }
  }

  Future<void> _openGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => DisplayPictureScreen(imagePath: image.path),
        ),
      );
    }
  }

  void _switchCamera() {
    if (_cameras != null && _cameras!.length > 1) {
      setState(() {
        _selectedCameraIndex = (_selectedCameraIndex + 1) % _cameras!.length;
        _isCameraInitialized = false;
      });
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '폐기물 스캔',
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<bool>(
              future: Future.value(requestCameraPermission()),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasData && snapshot.data!) {
                  if (_isCameraInitialized && _controller != null) {
                    return Column(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            color: Colors.black,
                            width: double.infinity,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.previewSize!.height,
                                height: _controller!.value.previewSize!.width,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          ),
                        ),
                        buildControlPanel(),
                      ],
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                } else {
                  return const Center(child: Text('카메라 권한이 필요합니다.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlPanel() {
    return Container(
      color: Colors.grey,
      padding: const EdgeInsets.fromLTRB(15, 25, 15, 60),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: _openGallery,
            icon: const Icon(Icons.photo_library, color: Colors.white),
            iconSize: 30,
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _controller?.initialize();

                final image = await _controller?.takePicture();

                if (!mounted) return;

                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => DisplayPictureScreen(
                      imagePath: image!.path,
                    ),
                  ),
                );
              } catch (e) {
                print(e);
              }
            },
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(7),
              backgroundColor: Colors.white,
            ),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 3),
              ),
            ),
          ),
          IconButton(
            onPressed: _switchCamera,
            icon: const Icon(Icons.switch_camera, color: Colors.white),
            iconSize: 30,
          ),
        ],
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.white,//색변경
        ),
        backgroundColor: Colors.black87,
        title: const Text('사진 보기', style: TextStyle(color: Colors.white),),
        centerTitle: true,
        actions: [
          TextButton(onPressed: () {}, child: Text("분석", style: TextStyle(color: Colors.white, fontSize: 16),),),
        ],
    ),
      body: Container(
        color: Colors.black87,
        child: Center(
          child: Image.file(File(imagePath)),
        ),
      )
    );
  }
}
