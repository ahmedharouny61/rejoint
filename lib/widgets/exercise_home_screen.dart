import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ExerciseHomeScreen extends StatelessWidget {
  static const Map<String, String> staticExercises = {
    'Calf Raises': 'https://youtu.be/nnPGrBLNlaw',
    'Hamstring Curls': 'https://youtu.be/Ych3qH1FZzY',
    'Heel Slides': 'https://youtu.be/Bz0wSFRjH2c',
    'Isometric Quadriceps': 'https://youtu.be/26hnV630E3Q',
    'Leg Press': 'https://youtu.be/eNYR5BktRQ8',
    'Lunges': 'https://youtu.be/ASdqJoDPMHA',
    'Quadriceps Stretch': 'https://youtu.be/_xU-wIiMxpI',
    'Seated Exercises': 'https://youtu.be/7HFRhtimbtw',
    'Squats': 'https://youtu.be/xqvCmoLULNY',
    'Side Lying Leg Lift': 'https://youtu.be/VlwBJE1WtOQ',
    'Standing Leg Lifts': 'https://youtu.be/l_U2uoePtS4',
    'Step Up': 'https://youtu.be/elhu-WC1qk4',
    'Straight Leg Raise': 'https://youtu.be/JMsqY_UegbM',
  };
  static Map<String, String> get exerciseVideos => staticExercises;
  const ExerciseHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff3e5f5),
      appBar: AppBar(
        title: const Text('Exercise Library'),
        backgroundColor: Color.fromARGB(255, 203, 199, 229),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance
            .collection('exercises')
            .orderBy('createdAt', descending: true)
            .get(),
        builder: (context, snapshot) {
          final List<Map<String, String>> allExercises = [];

          // 1. Add static
          staticExercises.forEach((name, url) {
            allExercises.add({'name': name, 'videoUrl': url});
          });

          // 2. Add Firestore (if loaded)
          if (snapshot.hasData) {
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              allExercises.add({
                'name': data['name'] ?? 'Unknown',
                'videoUrl': data['videoUrl'] ?? '',
              });
            }
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemCount: allExercises.length,
            itemBuilder: (context, index) {
              final item = allExercises[index];
              return ExerciseCard(
                exerciseName: item['name']!,
                videoUrl: item['videoUrl']!,
              );
            },
          );
        },
      ),
    );
  }
}

class ExerciseCard extends StatefulWidget {
  final String exerciseName;
  final String videoUrl;

  const ExerciseCard({
    super.key,
    required this.exerciseName,
    required this.videoUrl,
  });

  @override
  State<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends State<ExerciseCard> {
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadWatchProgress();
  }

  Future<void> _loadWatchProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watch_progress')
        .doc(widget.exerciseName)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      final watched = data['watchedSeconds'] ?? 0;
      final total = data['totalSeconds'] ?? 1;
      setState(() {
        _progress = (watched / total).clamp(0.0, 1.0);
      });
    }
  }

  Future<void> _resetProgress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('watch_progress')
        .doc(widget.exerciseName)
        .set({
      'watchedSeconds': 0,
      'totalSeconds': 1,
    });

    setState(() {
      _progress = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color.fromARGB(255, 76, 10, 123),  width: 5.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      color: const Color.fromARGB(255, 4, 129, 231),
      child: InkWell(
        onTap: () => Navigator.pushNamed(
          context,
          '/video',
          arguments: {
            'videoUrl': widget.videoUrl,
            'exerciseName': widget.exerciseName,
          },
        ).then((_) => _loadWatchProgress()), // refresh after return
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 24), // reserve space for icon
                  Text(
                    widget.exerciseName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white30,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(_progress * 100).toStringAsFixed(0)}% watched',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            // Top-right refresh icon
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.refresh),
                color: Color.fromARGB(255, 76, 10, 123), // Purple icon
                tooltip: 'Reset Progress',
                onPressed: _resetProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
