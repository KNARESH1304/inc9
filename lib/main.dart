import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const HalloweenStoryApp());
}

class HalloweenStoryApp extends StatelessWidget {
  const HalloweenStoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spooky Halloween Storybook',
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const IntroPage(),
        '/story': (context) => const HalloweenStoryPage(),
        '/end': (context) => const EndingPage(),
      },
    );
  }
}

//
// --------------------------- INTRO PAGE ---------------------------
//
class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/intro.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🎃 Welcome to the\nSpooky Halloween Storybook!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                  ),
                ),
                const SizedBox(height: 50),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/story');
                  },
                  child: const Text(
                    "Begin the Spooky Story 👻",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// --------------------------- STORY PAGE ---------------------------
//
class HalloweenStoryPage extends StatefulWidget {
  const HalloweenStoryPage({super.key});

  @override
  State<HalloweenStoryPage> createState() => _HalloweenStoryPageState();
}

class _HalloweenStoryPageState extends State<HalloweenStoryPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late AudioPlayer _backgroundPlayer;
  final AudioPlayer _effectPlayer = AudioPlayer();

  bool _foundItem = false;
  final Random _random = Random();

  List<_SpookyItem> spookyItems = [];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Generate spooky items
    spookyItems = List.generate(6, (index) {
      return _SpookyItem(
        name: "ghost$index",
        isTrap: index != 3,
        position: Offset(
          _random.nextDouble() * 300,
          _random.nextDouble() * 500,
        ),
      );
    });

    _backgroundPlayer = AudioPlayer();
    _playBackgroundMusic();
  }

  Future<void> _playBackgroundMusic() async {
    try {
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource('sounds/background.mp3'));
    } catch (e) {
      debugPrint("Error playing background music: $e");
    }
  }

  Future<void> _playEffect(String file) async {
    try {
      await _effectPlayer.play(AssetSource('sounds/$file'));
    } catch (e) {
      debugPrint("Error playing sound effect: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _backgroundPlayer.dispose();
    _effectPlayer.dispose();
    super.dispose();
  }

  void _onItemTap(_SpookyItem item) {
    if (_foundItem) return;

    setState(() {
      if (item.isTrap) {
        _playEffect('trap.mp3');
        _showSnack('Boo! It’s a spooky trap!');
      } else {
        _foundItem = true;
        _playEffect('success.mp3');
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, '/end');
        });
      }
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.orange.shade800,
        content: Text(
          message,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Spooky Forest Scene"),
        backgroundColor: Colors.deepOrange.shade900,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
              ),
              ...spookyItems.map((item) {
                double dx =
                    item.position.dx +
                    sin(_controller.value * 2 * pi) * 30 * _random.nextDouble();
                double dy =
                    item.position.dy +
                    cos(_controller.value * 2 * pi) * 20 * _random.nextDouble();

                return Positioned(
                  left: dx,
                  top: dy,
                  child: GestureDetector(
                    onTap: () => _onItemTap(item),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orangeAccent.withOpacity(0.7),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        item.isTrap ? 'assets/ghost.jpg' : 'assets/pumpkin.jpg',
                        height: 80,
                        width: 80,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

//
// --------------------------- ENDING PAGE ---------------------------
//
class EndingPage extends StatefulWidget {
  const EndingPage({super.key});

  @override
  State<EndingPage> createState() => _EndingPageState();
}

class _EndingPageState extends State<EndingPage> {
  final AudioPlayer _endSound = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _playCelebration();
  }

  Future<void> _playCelebration() async {
    try {
      await _endSound.play(AssetSource('sounds/success.mp3'));
    } catch (e) {
      debugPrint("Error playing end sound: $e");
    }
  }

  @override
  void dispose() {
    _endSound.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/end.jpg', fit: BoxFit.cover),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "🎉 You Found It! 🎃\nHappy Halloween!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/',
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 20,
                    ),
                  ),
                  child: const Text(
                    "Play Again 🔁",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// --------------------------- MODEL CLASS ---------------------------
//
class _SpookyItem {
  final String name;
  final bool isTrap;
  final Offset position;

  _SpookyItem({
    required this.name,
    required this.isTrap,
    required this.position,
  });
}
