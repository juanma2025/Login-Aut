import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:audio_session/audio_session.dart';

import '../models/sound.dart';

class PlayerScreen extends ConsumerStatefulWidget {
  final Sound sound;
  const PlayerScreen({super.key, required this.sound});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  late final AudioPlayer _player;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _init();
  }

  Future<void> _init() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
      final source = AudioSource.uri(
        Uri.parse(widget.sound.url),
        tag: MediaItem(
          id: widget.sound.id,
          album: 'SoundVault',
          title: widget.sound.name,
          artUri: null,
        ),
      );
      await _player.setAudioSource(source);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sound.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 24),
            Icon(Icons.graphic_eq, size: 96, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading) ...[
              StreamBuilder<Duration?>(
                stream: _player.durationStream,
                builder: (context, snapshot) {
                  final duration = snapshot.data ?? Duration.zero;
                  return StreamBuilder<Duration>(
                    stream: _player.positionStream,
                    builder: (context, snap) {
                      final position = snap.data ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            min: 0,
                            max: duration.inMilliseconds.toDouble(),
                            value: position.inMilliseconds.clamp(0, duration.inMilliseconds).toDouble(),
                            onChanged: (v) => _player.seek(Duration(milliseconds: v.toInt())),
                          ),
                          Text('${_fmt(position)} / ${_fmt(duration)}'),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.replay_10),
                    onPressed: () async {
                      final pos = await _player.position;
                      _player.seek(pos - const Duration(seconds: 10));
                    },
                  ),
                  StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return FilledButton(
                        onPressed: () => playing ? _player.pause() : _player.play(),
                        child: Icon(playing ? Icons.pause : Icons.play_arrow),
                      );
                    },
                  ),
                  IconButton(
                    iconSize: 40,
                    icon: const Icon(Icons.forward_10),
                    onPressed: () async {
                      final pos = await _player.position;
                      _player.seek(pos + const Duration(seconds: 10));
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(Duration d) => '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:${(d.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
      ;
}