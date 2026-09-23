import 'package:flutter/material.dart';
import '../../models/stream_profile.dart';

class SettingsScreen extends StatefulWidget {
  final StreamProfile initialProfile;
  final ValueChanged<StreamProfile> onSave;

  const SettingsScreen({
    super.key,
    required this.initialProfile,
    required this.onSave,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _keyController;
  late int _bitrate;
  late int _fps;
  late String _resolution;
  late String _protocol; // rtmp ou srt

  @override
  void initState() {
    super.initState();
    _urlController = TextEditingController(text: widget.initialProfile.rtmpUrl);
    _keyController = TextEditingController(text: widget.initialProfile.streamKey);
    _bitrate = widget.initialProfile.targetBitrate;
    _fps = widget.initialProfile.fps;
    _resolution = '${widget.initialProfile.width}x${widget.initialProfile.height}';
    _protocol = widget.initialProfile.rtmpUrl.toLowerCase().startsWith('srt') ? 'srt' : 'rtmp';
  }

  @override
  void dispose() {
    _urlController.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('Configurações do Stream'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Salvar', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Protocolo (recomendado SRT para IRL)', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'srt', label: Text('SRT')),
              ButtonSegment(value: 'rtmp', label: Text('RTMP')),
            ],
            selected: {_protocol},
            onSelectionChanged: (s) => setState(() => _protocol = s.first),
          ),
          const SizedBox(height: 16),
          const Text('Destino', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          TextField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: _protocol == 'srt' ? 'URL SRT' : 'URL RTMP',
              hintText: _protocol == 'srt'
                  ? 'srt://seu-servidor:port?streamid=...'
                  : 'rtmp://live.twitch.tv/app',
            ),
            style: const TextStyle(color: Colors.white),
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _keyController,
            decoration: const InputDecoration(labelText: 'Stream Key / Stream ID (se necessário)'),
            style: const TextStyle(color: Colors.white),
            obscureText: true,
          ),
          const SizedBox(height: 24),
          const Text('Qualidade (priorize estabilidade)', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Bitrate alvo', style: TextStyle(color: Colors.white)),
            subtitle: Text('$_bitrate kbps', style: const TextStyle(color: Colors.white54)),
            trailing: SizedBox(
              width: 160,
              child: Slider(
                value: _bitrate.toDouble(),
                min: 800,
                max: 6000,
                divisions: 26,
                label: '$_bitrate',
                onChanged: (v) => setState(() => _bitrate = v.round()),
              ),
            ),
          ),
          ListTile(
            title: const Text('Resolução', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<String>(
              value: _resolution,
              dropdownColor: const Color(0xFF1E1E1E),
              items: const [
                DropdownMenuItem(value: '854x480', child: Text('480p')),
                DropdownMenuItem(value: '1280x720', child: Text('720p (recomendado)')),
                DropdownMenuItem(value: '1920x1080', child: Text('1080p')),
              ],
              onChanged: (v) => setState(() => _resolution = v!),
            ),
          ),
          ListTile(
            title: const Text('FPS', style: TextStyle(color: Colors.white)),
            trailing: DropdownButton<int>(
              value: _fps,
              dropdownColor: const Color(0xFF1E1E1E),
              items: const [
                DropdownMenuItem(value: 24, child: Text('24')),
                DropdownMenuItem(value: 30, child: Text('30')),
                DropdownMenuItem(value: 60, child: Text('60')),
              ],
              onChanged: (v) => setState(() => _fps = v!),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.withOpacity(0.3)),
            ),
            child: Text(
              _protocol == 'srt'
                  ? 'SRT é bem melhor para IRL (rede instável).\n'
                    'Exemplo: srt://seu-servidor:9000?streamid=#!::r=live/stream,m=publish\n\n'
                    'Recomendado: 720p30 @ 2000-3000 kbps'
                  : 'RTMP é mais simples, mas menos tolerante a perda de pacotes.\n'
                    'Twitch: rtmp://live.twitch.tv/app\n'
                    'YouTube: rtmp://a.rtmp.youtube.com/live2\n\n'
                    'Recomendado: 720p30 @ 2000-2800 kbps',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final parts = _resolution.split('x');
    final width = int.tryParse(parts[0]) ?? 1280;
    final height = int.tryParse(parts[1]) ?? 720;

    final profile = widget.initialProfile.copyWith(
      rtmpUrl: _urlController.text.trim(),
      streamKey: _keyController.text.trim(),
      targetBitrate: _bitrate,
      width: width,
      height: height,
      fps: _fps,
    );

    widget.onSave(profile);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configurações salvas')),
    );
    Navigator.pop(context);
  }
}
