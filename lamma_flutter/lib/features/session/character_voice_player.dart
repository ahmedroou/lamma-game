import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widget_previews.dart';

import '../../core/app_theme.dart';
import '../../domain/models/question_audio.dart';

/// Plays a bundled clip without revealing its attribution or the speaker's name.
class CharacterVoicePlayer extends StatefulWidget {
  const CharacterVoicePlayer({
    super.key,
    required this.audio,
    this.points,
    this.isActive = true,
  });

  final QuestionAudio audio;
  final int? points;
  final bool isActive;

  @override
  State<CharacterVoicePlayer> createState() => _CharacterVoicePlayerState();
}

class _CharacterVoicePlayerState extends State<CharacterVoicePlayer>
    with WidgetsBindingObserver {
  static const _loadTimeout = Duration(seconds: 15);
  static const _commandTimeout = Duration(seconds: 6);
  static const _releaseTimeout = Duration(seconds: 3);
  AudioPlayer? _player;
  final List<StreamSubscription<dynamic>> _subscriptions = [];
  Future<void> _commands = Future<void>.value();
  int _epoch = 0;
  bool _foreground = true;
  bool _disposed = false;
  bool _sourceReady = false;
  bool _playing = false;
  bool _busy = false;
  bool _completed = false;
  Duration _position = Duration.zero;
  late Duration _duration;
  String? _error;

  bool get _enabled =>
      widget.isActive && widget.audio.isApproved && _foreground && !_disposed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _duration = Duration(milliseconds: widget.audio.durationMs);
    // No platform player or source is created before the user's first gesture.
  }

  bool _current(int epoch, [AudioPlayer? player]) =>
      mounted &&
      _enabled &&
      epoch == _epoch &&
      (player == null || identical(player, _player));

  void _enqueue(Future<void> Function() command) {
    _commands = _commands.then((_) async {
      // Each operation below handles its own failures, preserving the queue.
      await command();
    });
  }

  Future<void> _release(
    AudioPlayer? player,
    List<StreamSubscription<dynamic>> subscriptions,
  ) async {
    for (final subscription in subscriptions) {
      try {
        await subscription.cancel().timeout(_releaseTimeout);
      } catch (_) {
        // Closed plugin streams must not prevent native audio from stopping.
      }
    }
    if (player == null) return;
    try {
      await player.stop().timeout(_releaseTimeout);
    } catch (_) {
      // Dispose must still run if the native source has already been released.
    }
    try {
      await player.dispose().timeout(_releaseTimeout);
    } catch (_) {
      // Teardown never updates the UI or escapes as an unhandled Future error.
    }
  }

  void _invalidate({bool clearError = true}) {
    _epoch++;
    final player = _player;
    final subscriptions = List<StreamSubscription<dynamic>>.of(_subscriptions);
    _player = null;
    _subscriptions.clear();
    _sourceReady = false;
    _playing = false;
    _busy = false;
    _completed = false;
    _position = Duration.zero;
    if (clearError) _error = null;
    // Pending loads check their epoch before resume. A pending resume checks
    // again immediately afterwards and stops, followed by this queued teardown.
    _enqueue(() => _release(player, subscriptions));
  }

  @override
  void didUpdateWidget(CharacterVoicePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.audio.assetPath != widget.audio.assetPath ||
        oldWidget.audio.contentSha256 != widget.audio.contentSha256 ||
        (oldWidget.audio.isApproved && !widget.audio.isApproved) ||
        (oldWidget.isActive && !widget.isActive)) {
      _invalidate();
      _duration = Duration(milliseconds: widget.audio.durationMs);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed) return;
    setState(() {
      _foreground = state == AppLifecycleState.resumed;
      if (!_foreground) _invalidate();
    });
    // Returning to the app never resumes audio automatically.
  }

  void _streamError(int epoch, AudioPlayer player) {
    if (!_current(epoch, player)) return;
    setState(() {
      _invalidate(clearError: false);
      _error = 'تعذّر تشغيل المقطع. حاول مرة أخرى.';
    });
  }

  AudioPlayer _createPlayer(int epoch) {
    final player = AudioPlayer();
    _player = player;
    void error(Object _, StackTrace __) => _streamError(epoch, player);
    _subscriptions.addAll([
      player.onPlayerStateChanged.listen((state) {
        if (!_current(epoch, player)) return;
        setState(() => _playing = state == PlayerState.playing);
      }, onError: error),
      player.onPositionChanged.listen((position) {
        if (!_current(epoch, player) || _completed) return;
        setState(
          () => _position = position.isNegative ? Duration.zero : position,
        );
      }, onError: error),
      player.onDurationChanged.listen((duration) {
        if (!_current(epoch, player) || duration <= Duration.zero) return;
        setState(() => _duration = duration);
      }, onError: error),
      player.onPlayerComplete.listen((_) {
        if (!_current(epoch, player)) return;
        setState(() {
          _playing = false;
          _completed = true;
          _position = _duration;
        });
      }, onError: error),
    ]);
    return player;
  }

  Future<void> _stopStale(AudioPlayer player) async {
    // Invalidation can happen while a native load or resume is awaiting.
    try {
      await player.stop().timeout(_releaseTimeout);
    } catch (_) {
      // Its queued teardown will still dispose the player.
    }
  }

  void _operate({bool replay = false}) {
    if (!_enabled || _busy) return;
    final epoch = _epoch;
    final path = widget.audio.assetPath;
    final digest = widget.audio.contentSha256;
    final pause = _playing && !replay;
    setState(() {
      _busy = true;
      _error = null;
    });
    _enqueue(() async {
      try {
        if (!_current(epoch)) return;
        final player = _player ?? _createPlayer(epoch);
        if (!_sourceReady) {
          if (digest.isNotEmpty) {
            final data = await rootBundle.load(path).timeout(_loadTimeout);
            if (sha256
                    .convert(
                      data.buffer.asUint8List(
                        data.offsetInBytes,
                        data.lengthInBytes,
                      ),
                    )
                    .toString() !=
                digest) {
              throw const FormatException(
                'Voice clip differs from reviewed bytes.',
              );
            }
            if (!_current(epoch, player)) return;
          }
          await player.setReleaseMode(ReleaseMode.stop).timeout(_loadTimeout);
          if (!_current(epoch, player)) {
            await _stopStale(player);
            return;
          }
          final asset = path.startsWith('assets/') ? path.substring(7) : path;
          await player.setSource(AssetSource(asset)).timeout(_loadTimeout);
          if (!_current(epoch, player)) {
            await _stopStale(player);
            return;
          }
          _sourceReady = true;
        }
        if (pause) {
          await player.pause().timeout(_commandTimeout);
        } else {
          if (replay || _completed) {
            await player.seek(Duration.zero).timeout(_commandTimeout);
            if (!_current(epoch, player)) {
              await _stopStale(player);
              return;
            }
            _completed = false;
            _position = Duration.zero;
          }
          if (!_current(epoch, player)) return;
          // Ordinary pause/resume preserves position instead of reloading.
          await player.resume().timeout(_commandTimeout);
        }
        if (!_current(epoch, player)) {
          await _stopStale(player);
          return;
        }
        setState(() => _playing = !pause && !_completed);
      } catch (_) {
        if (_current(epoch)) {
          setState(() {
            _invalidate(clearError: false);
            _error = 'تعذّر تشغيل المقطع. حاول مرة أخرى.';
          });
        }
      } finally {
        if (_current(epoch)) setState(() => _busy = false);
      }
    });
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _invalidate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _VoicePlayerSurface(
    position: _position,
    duration: _duration,
    playing: _playing,
    busy: _busy,
    enabled: _enabled,
    completed: _completed,
    reviewPending: !widget.audio.isApproved,
    error: _error,
    points: widget.points,
    onToggle: () => _operate(),
    onReplay: () => _operate(replay: true),
  );
}

class _VoicePlayerSurface extends StatelessWidget {
  const _VoicePlayerSurface({
    required this.position,
    required this.duration,
    required this.playing,
    required this.busy,
    required this.enabled,
    required this.completed,
    this.reviewPending = false,
    this.points,
    this.error,
    this.onToggle,
    this.onReplay,
  });

  final Duration position, duration;
  final bool playing, busy, enabled, completed;
  final bool reviewPending;
  final int? points;
  final String? error;
  final VoidCallback? onToggle, onReplay;

  String _time(Duration duration) {
    final seconds = duration.inSeconds;
    return '${(seconds ~/ 60).toString().padLeft(2, '0')}:'
        '${(seconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = duration.inMilliseconds > 0
        ? (position.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final ready = enabled && !busy;
    final status = reviewPending
        ? 'هذا التسجيل قيد المراجعة'
        : !enabled
        ? 'الاستماع متوقف الآن'
        : busy
        ? 'لحظة… نجهّز المقطع'
        : playing
        ? 'استمع… من صاحب الصوت؟'
        : completed
        ? 'انتهى المقطع · استمع مجددًا'
        : position > Duration.zero
        ? 'متوقف مؤقتًا · أكمل الاستماع'
        : 'اسمع وتعرّف على صاحب الصوت';
    final playLabel = error != null
        ? 'إعادة محاولة تشغيل المقطع'
        : playing
        ? 'إيقاف المقطع مؤقتًا'
        : completed
        ? 'تشغيل المقطع من البداية'
        : position > Duration.zero
        ? 'متابعة المقطع'
        : 'تشغيل المقطع الصوتي';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (playing ? AppColors.lime : AppColors.purple).withValues(
              alpha: playing ? .65 : .35,
            ),
          ),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final stacked =
                constraints.maxWidth < 250 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.4;
            final controls = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filled(
                  tooltip: playLabel,
                  onPressed: ready ? onToggle : null,
                  style: IconButton.styleFrom(
                    minimumSize: const Size(48, 48),
                    backgroundColor: playing
                        ? AppColors.lime
                        : AppColors.purple,
                    foregroundColor: AppColors.ink,
                    disabledBackgroundColor: AppColors.border,
                    disabledForegroundColor: AppColors.muted,
                  ),
                  icon: busy
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.muted,
                          ),
                        )
                      : Icon(
                          playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          size: 30,
                        ),
                ),
                IconButton(
                  tooltip: 'إعادة الاستماع من البداية',
                  onPressed: ready ? onReplay : null,
                  color: AppColors.blue,
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  icon: const Icon(Icons.replay_rounded),
                ),
              ],
            );
            final timeline = Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  status,
                  maxLines: stacked ? null : 2,
                  overflow: stacked ? null : TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: playing ? AppColors.lime : AppColors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Semantics(
                  label: 'تقدّم المقطع الصوتي',
                  value: '${position.inSeconds} من ${duration.inSeconds} ثانية',
                  child: ExcludeSemantics(
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          color: playing ? AppColors.lime : AppColors.purple,
                          backgroundColor: AppColors.border,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '${_time(position)} / ${_time(duration)}',
                    textAlign: TextAlign.end,
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 11,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            );
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (points != null) ...[
                  Text(
                    '$points نقطة',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (stacked) ...[
                  timeline,
                  const SizedBox(height: 6),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: controls,
                  ),
                ] else
                  Row(
                    children: [
                      controls,
                      const SizedBox(width: 8),
                      Expanded(child: timeline),
                    ],
                  ),
                if (error != null) ...[
                  const SizedBox(height: 6),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      error!,
                      style: const TextStyle(
                        color: AppColors.peach,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      onPressed: ready ? onToggle : null,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('إعادة المحاولة'),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

@Preview(name: 'صوت الشخصية · المشغّل', group: 'الجولة', size: Size(390, 280))
@Preview(name: 'صوت الشخصية · ضيق', group: 'الجولة', size: Size(240, 340))
Widget characterVoicePlayerPreview() => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: AppTheme.dark,
  home: Directionality(
    textDirection: TextDirection.rtl,
    child: Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: const _VoicePlayerSurface(
          position: Duration(seconds: 3),
          duration: Duration(seconds: 12),
          playing: true,
          busy: false,
          enabled: true,
          completed: false,
          points: 200,
        ),
      ),
    ),
  ),
);
