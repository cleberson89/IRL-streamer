import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'features/ui/home_screen.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const ProviderScope(child: IrlStreamerApp()));
}

class IrlStreamerApp extends StatelessWidget {
  const IrlStreamerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IRL Streamer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const PermissionGate(child: HomeScreen()),
    );
  }
}

class PermissionGate extends StatefulWidget {
  final Widget child;
  const PermissionGate({super.key, required this.child});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _ready = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final statuses = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    final cameraOk = statuses[Permission.camera]?.isGranted ?? false;
    final micOk = statuses[Permission.microphone]?.isGranted ?? false;

    if (cameraOk && micOk) {
      setState(() => _ready = true);
    } else {
      setState(() {
        _error = 'Câmera e microfone são obrigatórios para lives IRL.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Abrir Configurações'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_ready) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return widget.child;
  }
}
