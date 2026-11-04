import 'package:deme_mali_mobile/repositories/auth_repository.dart';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:deme_mali_mobile/models/preuve_distribution.dart';

final String baseUrlFichiers = AuthRepository.baseUrl;

class PreuveDistributionWidget extends StatelessWidget {
  const PreuveDistributionWidget({
    super.key,
    required this.preuve,
  });

  final PreuveDistribution preuve;

  @override
  Widget build(BuildContext context) {
    final url = _urlComplete(preuve.urlFichier);
    final type = (preuve.typeMedia ?? '').toLowerCase();

    final estVideo = type.contains('video') ||
        type.contains('vidéo') ||
        (url != null &&
            (url.toLowerCase().endsWith('.mp4') ||
                url.toLowerCase().endsWith('.mov') ||
                url.toLowerCase().endsWith('.webm')));

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        color: const Color(0xFFF0EEE8),
        child: url == null
            ? const _ErreurMedia()
            : estVideo
            ? _LecteurVideoInline(url: url)
            : _ImagePreuve(url: url),
      ),
    );
  }

  String? _urlComplete(String? valeur) {
    final chemin = valeur?.trim();

    if (chemin == null || chemin.isEmpty) {
      return null;
    }

    if (chemin.startsWith('http://') ||
        chemin.startsWith('https://')) {
      return chemin;
    }

    final cheminNormalise =
    chemin.startsWith('/') ? chemin : '/$chemin';

    return '$baseUrlFichiers$cheminNormalise';
  }
}

class _ImagePreuve extends StatelessWidget {
  const _ImagePreuve({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const _ErreurMedia(),
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF0F7A4B),
          ),
        );
      },
    );
  }
}

class _LecteurVideoInline extends StatefulWidget {
  const _LecteurVideoInline({required this.url});

  final String url;

  @override
  State<_LecteurVideoInline> createState() =>
      _LecteurVideoInlineState();
}

class _LecteurVideoInlineState extends State<_LecteurVideoInline> {
  late final VideoPlayerController _controller;
  late final Future<void> _initialisation;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
    );

    _initialisation = _controller.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _basculerLecture() {
    if (!_controller.value.isInitialized) return;

    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initialisation,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0F7A4B),
            ),
          );
        }

        if (snapshot.hasError ||
            !_controller.value.isInitialized) {
          return const _ErreurMedia();
        }

        return Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),

            Center(
              child: IconButton(
                onPressed: _basculerLecture,
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 54,
                  color: Colors.white,
                ),
              ),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFFF7B500),
                  bufferedColor: Colors.white54,
                  backgroundColor: Colors.white30,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ErreurMedia extends StatelessWidget {
  const _ErreurMedia();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 34,
            color: Color(0xFF888888),
          ),
          SizedBox(height: 6),
          Text(
            'Média indisponible',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF777777),
            ),
          ),
        ],
      ),
    );
  }
}
