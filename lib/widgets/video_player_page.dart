import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerPage extends StatefulWidget {
  final String videoUrl;
  final String exerciseName;

  const VideoPlayerPage(
      {super.key, required this.videoUrl, required this.exerciseName});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late YoutubePlayerController _controller;
  bool _hasError = false;
  String _errorMessage = '';
  late Timer _progressTimer;

  static const Map<String, Map<String, String>> exerciseDetails = {
    'Calf Raises': {
      'target': 'Calves',
      'purpose':
          'Strengthens calf muscles, improves ankle stability, and reduces knee strain.',
      'steps': '1. Stand with feet hip-width apart...'
    },
    'Hamstring Curls': {
      'target': 'Hamstrings (back of thigh)',
      'purpose':
          'Strengthens hamstrings to provide knee joint support and reduce stiffness.',
      'steps':
          '1. Stand straight, holding a chair or wall for support.\n2. Bend one knee, bringing your heel toward your buttocks.\n3. Hold the position for a few seconds.\n4. Lower your foot back to the floor.\n5. Perform 10-20 repetitions per leg.'
    },
    'Heel Slides': {
      'target': 'Hamstrings and Quadriceps',
      'purpose': 'Enhances knee flexibility and range of motion.',
      'steps':
          '1. Lie on your back with both legs straight.\n2. Slide one heel toward your buttocks, bending the knee.\n3. Hold for a few seconds.\n4. Slowly straighten the leg back.\n5. Repeat 10-15 times per leg.'
    },
    'Isometric Quadriceps': {
      'target': 'Quadriceps',
      'purpose': 'Strengthens quadriceps without putting strain on the knee.',
      'steps':
          '1. Sit with your legs extended.\n2. Tighten your thigh muscle without moving your leg.\n3. Hold for 5-10 seconds.\n4. Relax and repeat 10-15 times.'
    },
    'Leg Press': {
      'target': 'Quadriceps, Hamstrings, and Glutes',
      'purpose': 'Builds lower body strength to support knee function.',
      'steps': '''Steps:
1. Sit on the floor with your back straight and legs extended.

2. Place a resistance band around your feet.

3. Hold the ends of the band firmly with both hands.

4. Bend your knees and bring them towards your chest.

5. Push your feet forward, straightening your legs against the band’s resistance.

6. Slowly return to the starting position.

7. Perform 12-15 reps for 3 sets.'''
    },
    'Lunges': {
      'target': 'Quadriceps, Hamstrings, and Glutes',
      'purpose': 'Strengthens the legs and improves balance.',
      'steps':
          '1. Stand with feet hip-width apart.\n2. Step forward with one leg.\n3. Lower your body until both knees are at 90 degrees.\n4. Push back to the starting position.\n5. Repeat 10-15 times per leg.'
    },
    'Quadriceps Stretch': {
      'target': 'Quadriceps',
      'purpose': 'Improves flexibility and relieves knee tightness.',
      'steps':
          '1. Stand upright, holding a wall for support.\n2. Bend one knee and bring your heel towards your buttocks.\n3. Grab your ankle with your hand.\n4. Hold for 20-30 seconds.\n5. Switch legs and repeat.'
    },
    'Seated Exercises': {
      'target': 'Quadriceps and Hamstrings',
      'purpose': 'Helps maintain knee mobility and reduce stiffness.',
      'steps':
          '1. Sit on a sturdy chair.\n2. Extend one leg straight in front of you.\n3. Hold for a few seconds, then lower it back down.\n4. Repeat 10-15 times per leg.'
    },
    'Squats': {
      'target': 'Quadriceps, Hamstrings, and Glutes',
      'purpose': 'Enhances lower body strength and stability.',
      'steps':
          '1. Stand with feet shoulder-width apart.\n2. Lower your body as if sitting into a chair.\n3. Keep your knees aligned with your toes.\n4. Return to the standing position.\n5. Perform 10-15 repetitions.'
    },
    'Side Lying Leg Lift': {
      'target': 'Glutes and Outer Thighs',
      'purpose': 'Improves hip stability and knee support.',
      'steps':
          '1. Lie on your side with legs straight.\n2. Lift your top leg to about 45 degrees.\n3. Hold for a few seconds.\n4. Lower your leg slowly.\n5. Repeat 10-15 times per leg.'
    },
    'Standing Leg Lifts': {
      'target': 'Lateral (Outer) Glutes',
      'purpose': 'Enhances balance, stability, and knee strength.',
      'steps':
          '1. Stand upright, holding onto a chair for support.\n2. Lift one leg out to the side.\n3. Hold for a few seconds.\n4. Lower it back down.\n5. Perform 10-20 repetitions per leg.'
    },
    'Step Up': {
      'target': 'Quadriceps, Hamstrings, and Glutes',
      'purpose': 'Strengthens leg muscles and improves knee stability.',
      'steps':
          '1. Stand in front of a sturdy step or platform.\n2. Step up with one foot.\n3. Bring the other foot up to meet it.\n4. Step down one foot at a time.\n5. Repeat 10-15 times per leg.'
    },
    'Straight Leg Raise': {
      'target': 'Quadriceps',
      'purpose': 'Enhances knee strength without joint pressure.',
      'steps':
          '1. Lie on your back with one leg bent and the other straight.\n2. Tighten the thigh muscle of the straight leg.\n3. Lift it to the level of the bent knee.\n4. Hold for a few seconds.\n5. Lower it back down.\n6. Perform 10-15 repetitions per leg.'
    }
  };

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(widget.videoUrl);
      if (videoId == null) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Invalid video URL format';
        });
        return;
      }

      _controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          disableDragSeek: true,
          enableCaption: true,
        ),
      )..addListener(_saveWatchProgress);

      // Start progress timer
      _progressTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _saveWatchProgress();
      });

      _controller.addListener(() {
        if (_controller.value.playerState == PlayerState.ended) {
          _saveWatchProgress(forceComplete: true); // Final write at end
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Failed to initialize player: ${e.toString()}';
      });
    }
  }

  Future<void> _saveWatchProgress({bool forceComplete = false}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || !_controller.value.isReady) return;

    final duration = _controller.metadata.duration.inSeconds;
    final current = _controller.value.position.inSeconds;

    if (duration > 0 && current >= 0) {
      int finalWatched = forceComplete ? duration : current;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('watch_progress')
          .doc(widget.exerciseName)
          .set({
        'watchedSeconds': finalWatched,
        'totalSeconds': duration,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (forceComplete) {
        debugPrint(" Completed: ${widget.exerciseName}");
      }
    }
  }

  Widget _buildDetailSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exerciseInfo = exerciseDetails[widget.exerciseName];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exerciseName),
        actions: [
          IconButton(
            icon: const Icon(Icons.fullscreen),
            onPressed: () => _controller.toggleFullScreenMode(),
          ),
        ],
      ),
      body: _hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error loading video\n$_errorMessage",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  YoutubePlayer(
                    controller: _controller,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: Colors.blueAccent,
                  ),
                  if (exerciseInfo != null) ...[
                    _buildDetailSection('🎯 Target', exerciseInfo['target']!),
                    _buildDetailSection('💪 Purpose', exerciseInfo['purpose']!),
                    _buildDetailSection('👟 Steps', exerciseInfo['steps']!),
                  ] else
                    const Text("Exercise details not available."),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _progressTimer.cancel();
  }
}
