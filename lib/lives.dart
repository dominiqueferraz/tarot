import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class LifePool extends ChangeNotifier {
  LifePool({List<String>? saved, this.save, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now {
    final now = _clock().millisecondsSinceEpoch;
    if (saved?.firstOrNull == _storageVersion) {
      _deadlines.addAll(
        saved!
            .skip(1)
            .map(int.tryParse)
            .whereType<int>()
            .where((deadline) => deadline > now)
            .take(capacity),
      );
      _deadlines.sort();
    } else if (saved != null && saved.length == 2) {
      final count = int.tryParse(saved[0]);
      final deadline = int.tryParse(saved[1]);
      if (count != null && count >= 0 && count < capacity && deadline != null) {
        _restoreLegacyBalance(count, deadline, now);
      }
    }
    _update(now);
  }

  static const capacity = 5;
  static const _storageVersion = 'v2';
  static const _interval = 20 * Duration.millisecondsPerMinute;
  static const _second = Duration.millisecondsPerSecond;

  final Future<void> Function(List<String>)? save;
  final DateTime Function() _clock;
  final _deadlines = <int>[];
  Future<void> _pendingSave = Future.value();
  Timer? _timer;
  int? _secondsUntilNext;

  int get remaining => capacity - _deadlines.length;
  int? get secondsUntilNext => _secondsUntilNext;

  void _restoreLegacyBalance(int count, int deadline, int now) {
    const hour = Duration.millisecondsPerHour;
    final credited = now >= deadline ? 1 + (now - deadline) ~/ hour : 0;
    final missing = math.max(0, capacity - count - credited);
    final next = math.min(deadline + credited * hour, now + _interval);
    _deadlines.addAll(List.filled(missing, next));
    _save();
  }

  void refresh() {
    final now = _clock().millisecondsSinceEpoch;
    _deadlines.removeWhere((deadline) => deadline <= now);
    _update(now);
  }

  void loseLife() {
    final now = _clock().millisecondsSinceEpoch;
    _deadlines.removeWhere((deadline) => deadline <= now);
    if (remaining > 0) {
      _deadlines.add(now + _interval);
      _deadlines.sort();
      _save();
    }
    _update(now);
  }

  void _save() {
    final persist = save;
    if (persist == null) return;
    final state = [
      _storageVersion,
      for (final deadline in _deadlines) '$deadline',
    ];
    _pendingSave = _pendingSave.then((_) async {
      try {
        await persist(state);
      } on PlatformException catch (error) {
        debugPrint('Could not save lives: ${error.code}');
      }
    });
  }

  void _update(int now) {
    _timer?.cancel();
    final deadline = _deadlines.firstOrNull;
    if (deadline == null) {
      _secondsUntilNext = null;
    } else {
      final delay = deadline - now;
      final seconds = (delay + _second - 1) ~/ _second;
      _secondsUntilNext = seconds;
      _timer = Timer(
        Duration(milliseconds: delay - (seconds - 1) * _second),
        refresh,
      );
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
