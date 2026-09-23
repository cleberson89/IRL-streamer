import 'dart:async';
import 'dart:math';

/// Gerenciador de reconnect agressivo e inteligente para IRL.
/// Prioriza manter o stream vivo sem spam de tentativas.
class ReconnectManager {
  final void Function() onReconnectAttempt;
  final void Function() onGiveUp;
  final Duration initialDelay;
  final Duration maxDelay;
  final int maxAttempts; // -1 = infinito

  int _attempt = 0;
  Timer? _timer;
  bool _isActive = false;

  ReconnectManager({
    required this.onReconnectAttempt,
    required this.onGiveUp,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.maxAttempts = -1,
  });

  void start() {
    if (_isActive) return;
    _isActive = true;
    _attempt = 0;
    _scheduleNext();
  }

  void stop() {
    _isActive = false;
    _timer?.cancel();
    _timer = null;
    _attempt = 0;
  }

  void success() {
    // Conexão restabelecida → zera contador
    _attempt = 0;
    _timer?.cancel();
  }

  void _scheduleNext() {
    if (!_isActive) return;

    if (maxAttempts > 0 && _attempt >= maxAttempts) {
      onGiveUp();
      stop();
      return;
    }

    // Backoff exponencial com jitter
    final base = initialDelay.inMilliseconds * pow(2, _attempt).toInt();
    final clamped = min(base, maxDelay.inMilliseconds);
    final jitter = Random().nextInt(500);
    final delay = Duration(milliseconds: clamped + jitter);

    _timer = Timer(delay, () {
      if (!_isActive) return;
      _attempt++;
      onReconnectAttempt();
      // Agenda a próxima tentativa caso esta também falhe
      // (o controller de stream deve chamar success() ou deixar falhar)
      _scheduleNext();
    });
  }

  int get currentAttempt => _attempt;
  bool get isActive => _isActive;
}
